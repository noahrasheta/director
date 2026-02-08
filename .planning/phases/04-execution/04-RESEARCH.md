# Phase 4: Execution - Research

**Researched:** 2026-02-08
**Domain:** Claude Code skill-to-agent orchestration, fresh context assembly, atomic git commits, documentation sync, sub-agent spawning
**Confidence:** HIGH

## Summary

Phase 4 transforms the build skill from a routing placeholder into Director's execution engine. When a user runs `/director:build`, Director must: (1) identify the next ready task from the gameplan hierarchy, (2) assemble targeted context wrapped in XML boundary tags, (3) spawn the builder agent in a fresh context via `context: fork`, (4) produce exactly one atomic git commit, (5) run documentation sync, and (6) report what was built in plain language.

The research confirms that all required capabilities are supported by Claude Code's current plugin system. The `context: fork` frontmatter field in skills runs the skill content as an isolated sub-agent with a separate conversation history. The builder agent already has full system prompts, tool access (`Task(director-verifier, director-syncer)`), and sub-agent spawning capability defined in Phase 1. The key technical challenge is the context assembly layer -- the build skill must dynamically read the right files (VISION.md, relevant STEP.md, task file, recent git log), wrap them in XML tags, and inject that assembled context into the skill content that becomes the builder's prompt. This is achievable using the `!`command`` dynamic context injection syntax already used by status and resume skills.

The documentation sync agent (syncer) is already defined with the right scope rules and reporting format. The primary work in this phase is wiring everything together: the build skill orchestrates the full flow, the context assembly handles the XML wrapping, and the post-task reporting combines the builder's output with the syncer's findings into the user-facing summary format decided by the user (plain-language paragraph + structured bullet list).

**Primary recommendation:** Build the execution pipeline as a single skill rewrite (`skills/build/SKILL.md`) that uses `context: fork` with `agent: director-builder`, dynamic context injection for XML assembly, and post-task orchestration for git commit, sync, and reporting.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

#### Doc sync scope
- Claude's Discretion: whether to check code changes only or do a broader codebase scan -- pick what makes sense technically per task

#### Doc sync reporting
- When sync finds out-of-date docs, show the diff in plain language and ask the user to confirm before applying changes
- Never auto-update docs silently -- user always sees what changed and approves

#### External change detection
- Check for outside-Director changes (manual edits, other tools) only on `/director:resume`, not after every task
- Per-task sync focuses on the task's own changes to keep it fast

#### Post-task summary format
- Both: a plain-language paragraph summarizing what was built, followed by a structured bullet list of specific file changes
- Paragraph gives the narrative; bullets give the specifics

### Claude's Discretion
- Task selection algorithm (how to pick next ready task when multiple are available)
- Context assembly strategy (what gets loaded into fresh agent window, how much git history)
- Commit message formatting
- Sub-agent spawning decisions within tasks
- How to handle partial task success
- Doc sync technical approach (code-change-only vs full scan, per task)

### Deferred Ideas (OUT OF SCOPE)
None -- discussion stayed within phase scope
</user_constraints>

## Standard Stack

This phase uses no external libraries. Director is a declarative Claude Code plugin -- all components are Markdown files, JSON configuration, and shell scripts. The "stack" is the Claude Code plugin system itself.

### Core

| Component | Format | Purpose | Why Standard |
|-----------|--------|---------|--------------|
| `skills/build/SKILL.md` | Markdown + YAML frontmatter | Build command orchestration with `context: fork` | Official skills format; `context: fork` runs in isolated sub-agent context |
| `agents/director-builder.md` | Markdown + YAML frontmatter | Builder agent system prompt (already exists) | Official sub-agent format; receives skill content as prompt |
| `agents/director-syncer.md` | Markdown + YAML frontmatter | Doc sync agent system prompt (already exists) | Official sub-agent format; spawned by builder as sub-agent |
| `agents/director-verifier.md` | Markdown + YAML frontmatter | Verification agent (already exists) | Spawned by builder for post-task structural checks |
| `reference/context-management.md` | Markdown | Context assembly rules and budget guidelines | Already exists with complete specification |

### Supporting

| Component | Format | Purpose | When to Use |
|-----------|--------|---------|-------------|
| `.director/STATE.md` | Markdown | Task status tracking, progress counts | Updated by syncer after each task |
| `.director/goals/*/STEP.md` | Markdown | Step context loaded into builder | Read during context assembly |
| `.director/goals/*/tasks/*.md` | Markdown | Task descriptions with acceptance criteria | Read during context assembly, renamed to `.done.md` after completion |
| `scripts/session-start.sh` | Bash | Loads project state on session start | Already exists; may need minor updates |

### What NOT to Use

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| Node.js/TypeScript runtime code | No runtime in plugins; everything is declarative | Dynamic context injection (`!`command``) in SKILL.md |
| Custom state machine or workflow engine | The skill IS the workflow; Claude follows it step by step | Sequential instructions in SKILL.md |
| External task queue or scheduler | Director executes one task at a time; no parallelism needed | Skill instructions + `context: fork` |
| Agent teams (experimental) | Phase 3 feature; overkill for serial task execution | Sub-agents within a single builder session |
| Custom token counting library | Approximate counting is sufficient for context budgeting | Character count / 4 estimation per context-management.md |

## Architecture Patterns

### Pattern 1: Skill-Driven Orchestration with `context: fork`

**What:** The build skill uses `context: fork` to run the builder agent in an isolated context window. The skill content becomes the builder's prompt, prepopulated with dynamically assembled project context. Results are summarized and returned to the main conversation.

**When to use:** Every `/director:build` invocation that reaches a ready task.

**How it works:**
1. Build SKILL.md contains `context: fork` and `agent: director-builder` in frontmatter
2. Skill body contains dynamic context injection (`!`command``) that reads project files
3. At invocation time, commands execute and their output replaces the placeholders
4. The fully-rendered skill content (with XML-wrapped context) becomes the builder agent's prompt
5. Builder works in isolation, spawns verifier and syncer sub-agents
6. Results return to the main conversation as a summary

**Source:** [Claude Code Skills Documentation](https://code.claude.com/docs/en/skills) -- "Run skills in a subagent" section

**Key constraint from official docs:** "Subagents cannot spawn other subagents." This means the builder (spawned via `context: fork`) CAN spawn director-verifier and director-syncer (these are sub-agents of the builder), but the verifier/syncer CANNOT spawn further sub-agents. This is exactly the flat nesting model Director already designed for.

### Pattern 2: Dynamic Context Assembly with XML Boundary Tags

**What:** The build skill uses `!`command`` syntax to read project files at invocation time and wrap them in XML boundary tags before the content reaches the builder agent.

**When to use:** Every time the build skill is invoked.

**Example:**
```yaml
---
name: build
description: "Work on the next ready task in your project"
context: fork
agent: director-builder
disable-model-invocation: true
---

<vision>
!`cat .director/VISION.md 2>/dev/null`
</vision>

<current_step>
!`cat "$STEP_PATH" 2>/dev/null`
</current_step>

<task>
!`cat "$TASK_PATH" 2>/dev/null`
</task>

<recent_changes>
!`git log --oneline -10 2>/dev/null || echo "No git history yet."`
</recent_changes>

<instructions>
Complete only this task. Do not modify files outside the listed scope.
Verify your work matches the acceptance criteria before committing.
Follow reference/terminology.md and reference/plain-language-guide.md for user-facing output.
</instructions>
```

**Critical implementation detail:** The `!`command`` syntax executes BEFORE the content reaches Claude. The shell commands run first and their output replaces the placeholder. This means the XML tags are populated with real file content by the time the builder agent sees them. However, there is a challenge: the skill needs to know WHICH step and task to load. This requires pre-computation in the skill's routing logic before the fork happens.

**Resolution approach:** The build skill should NOT use `context: fork` in a simple way. Instead, it should:
1. Run inline (no fork) to do routing, task selection, and context assembly
2. Once it has identified the ready task, use the Task tool to spawn the builder agent directly with the assembled context as the task message
3. After the builder returns, handle git commit, sync reporting, and user-facing summary inline

This matches the pattern used by onboard and blueprint -- those skills run their workflows inline rather than forking. The builder agent is spawned via `Task(director-builder)` from the skill's inline context.

### Pattern 3: Task Selection Algorithm

**What:** Scan the gameplan hierarchy to find the next task that has all prerequisites satisfied. This is the ready-work filtering from PLAN-05 and EXEC-01.

**When to use:** Every `/director:build` invocation.

**Algorithm (recommended):**
1. Read `.director/STATE.md` for current position (goal, step, task)
2. Read `.director/GAMEPLAN.md` for the goals list and current focus
3. Starting from the current goal/step, scan task files in order
4. For each task, read its "Needs First" section
5. Check if the capability described in "Needs First" has been completed (by checking STATE.md or `.done.md` files)
6. The first task whose prerequisites are all met is the "next ready task"
7. If no tasks are ready in the current step, check the next step; if no steps, check the next goal

**Tiebreaker when multiple tasks are ready:** Use the task with the lowest number in the current step. This follows natural order and is predictable for the user.

**Source:** This is a Claude's Discretion area. The recommendation is to use simple sequential ordering within each step, progressing through goals/steps in document order.

### Pattern 4: Atomic Git Commit with Plain-Language Abstraction

**What:** After the builder completes its work, create exactly one git commit. Show the user "Progress saved" language, never git terminology.

**When to use:** After every successful task completion.

**Implementation:**
```bash
# Stage all changes made by the builder
git add -A

# Create commit with descriptive message
git commit -m "Add [what was built in plain language]"
```

**Commit message format (recommended):**
- Use present tense: "Add user login page" not "Added user login page"
- Describe what was built, not how: "Add user login page with form validation" not "Create LoginPage.tsx with useState hooks"
- Keep under 72 characters
- No conventional commit prefixes (feat:, fix:) -- too developer-y for Director's context

**User-facing output after commit:**
> "Progress saved. You can type `/director:undo` to go back."

### Pattern 5: Post-Task Documentation Sync

**What:** After the builder commits, spawn the syncer agent to check `.director/` docs against codebase state. The syncer reports findings; the skill presents them to the user for confirmation before applying changes.

**When to use:** After every successful task commit.

**Flow:**
1. Builder completes task and creates commit
2. Skill spawns director-syncer via Task tool with context about what was just built
3. Syncer reads STATE.md, GAMEPLAN.md, checks for drift
4. Syncer returns findings:
   - STATE.md updates (task marked complete, progress counts updated)
   - Any GAMEPLAN.md drift detected
   - Any VISION.md drift detected
5. Skill presents sync findings to user in plain language
6. If sync found changes to make: show diff and ask user to confirm
7. If user confirms: apply changes (STATE.md can be auto-updated; VISION.md/GAMEPLAN.md drift is flagged only)

**Important constraint from prior decisions:**
- Doc sync should never auto-commit (present findings first)
- Per-task sync focuses on the task's own changes only (not a full codebase scan)
- External change detection (manual edits, other tools) only happens on `/director:resume`

### Pattern 6: Post-Task Summary Format

**What:** After build + commit + sync, present the user with a combined summary following the locked decision format: plain-language paragraph + structured bullet list.

**When to use:** After every completed task.

**Example:**
```
The login page is ready. Users can type their email and password to sign
in, and the page handles errors gracefully -- showing a message if the
credentials are wrong.

**What changed:**
- Created the login page with email and password fields
- Added form validation that checks for valid email format
- Connected the login form to the authentication system from Step 1
- Added error messages for wrong credentials

Progress saved. You can type `/director:undo` to go back.
```

### Pattern 7: Sub-Agent Spawning Within Tasks

**What:** The builder agent can spawn sub-agents for research and exploration within a single task using the Task tool.

**When to use:** When the builder encounters a decision that needs investigation, or needs to understand a part of the codebase before modifying it.

**Already configured:** The builder agent's frontmatter includes `tools: Read, Write, Edit, Bash, Grep, Glob, Task(director-verifier, director-syncer)`. The builder can spawn verifier and syncer sub-agents.

**Extension needed:** The builder should also be able to spawn the researcher agent for within-task research. Update the builder's tools to include `Task(director-verifier, director-syncer, director-researcher)`.

**Flat nesting constraint:** Sub-agents spawned by the builder cannot spawn further sub-agents. The verifier, syncer, and researcher are leaf nodes in the agent tree.

### Pattern 8: Context Budget Calculator

**What:** Before spawning the builder, estimate token usage of the assembled context to ensure it stays under 30% of the context window.

**When to use:** Every `/director:build` invocation, before spawning.

**Implementation (from context-management.md design notes):**
```
Context Budget Report:
  Vision:          ~chars/4 tokens (X%)
  Current Step:    ~chars/4 tokens (X%)
  Task:            ~chars/4 tokens (X%)
  Recent Changes:  ~chars/4 tokens (X%)
  Instructions:    ~chars/4 tokens (X%)
  Reference Docs:  ~chars/4 tokens (X%)
  ─────────────────────────────
  Total:           ~tokens (X%)
  Budget:          30% of window
  Status:          Within budget / Over budget
```

**Truncation strategy (in priority order):**
1. Git log first -- reduce to most recent N commits
2. Reference docs second -- include only sections relevant to the task
3. Step context third -- summarize rather than include full STEP.md
4. Never truncate task or vision -- essential for correct execution

**Note:** Token counting does not need to be exact. Character count / 4 is sufficient for budget management. This calculator runs in the skill's routing logic before spawning the builder.

### Anti-Patterns to Avoid

- **Using `context: fork` for the entire build workflow:** The build skill needs to do routing, task selection, and post-task orchestration (commit, sync, reporting) BEFORE and AFTER the builder runs. This multi-step flow requires inline execution with the builder spawned via Task tool, not a simple fork. If you fork the entire skill, you lose the ability to orchestrate the pre/post steps.
- **Letting the builder create the git commit directly:** The builder should stage and commit as part of its execution rules (it already has this in its system prompt). However, the SKILL.md must verify the commit happened and handle the user-facing "Progress saved" message. The builder creates the commit; the skill reports it.
- **Auto-updating VISION.md during sync:** The syncer is explicitly prohibited from modifying VISION.md. Vision changes require user confirmation. The syncer can only flag drift.
- **Full codebase scan during per-task sync:** Per the locked decision, per-task sync focuses on the task's own changes only. Full external change detection happens on `/director:resume`.
- **Using agent teams for sub-agent spawning:** Agent teams are an experimental feature for multi-session coordination (Phase 3). Within a single task, use standard sub-agent spawning via the Task tool.
- **Accumulating context across tasks:** Each task gets a FRESH context. No conversation history carries over. The build skill runs fresh each time the user types `/director:build`.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Agent spawning | Custom agent launcher or process manager | `Task(director-builder)` tool from skill | Claude Code handles spawning, context isolation, result collection |
| Context isolation | Manual context clearing or session management | `context: fork` or Task tool spawning | Platform provides fresh context automatically |
| Dynamic file injection | Custom template engine or file reader | `!`command`` syntax in SKILL.md | Preprocessed before prompt reaches Claude |
| Task dependency resolution | Graph traversal library or topological sort | Sequential scan through gameplan hierarchy | Tasks have plain-language prerequisites, not a formal dependency graph |
| Git operations | Custom git wrapper library | Direct `git add` / `git commit` in Bash | Simple operations; no branching, no merging, no rebasing |
| Token counting | tiktoken or tokenizer library | `character_count / 4` rough estimate | Budget management needs approximation, not precision |
| State persistence | Database or custom file format | Direct updates to `.director/STATE.md` | Syncer agent already knows how to update STATE.md |
| Task completion tracking | Custom status tracker | `.done.md` rename convention per PRD | Task file renamed from `NN-task-slug.md` to `NN-task-slug.done.md` |

**Key insight:** Director's execution engine is fundamentally a prompt orchestration problem, not a software engineering problem. The build skill assembles context, spawns an agent, and handles the aftermath. All the hard work (code writing, verification, debugging) happens inside the builder agent's system prompt following rules already defined in Phase 1.

## Common Pitfalls

### Pitfall 1: Context Assembly Path Resolution

**What goes wrong:** The build skill needs to read the correct STEP.md and task file from the gameplan hierarchy. If the path resolution is wrong (e.g., wrong goal directory, wrong step number), the builder gets the wrong context and builds the wrong thing.

**Why it happens:** The gameplan hierarchy uses zero-padded numbers with kebab-case slugs (`01-user-accounts/01-login-flow/tasks/01-setup-database.md`). The skill needs to map from STATE.md's current position to the actual file paths.

**How to avoid:** Read STATE.md to get the current goal/step/task reference. Then scan the `.director/goals/` directory to find the matching files. Use Glob patterns rather than constructing paths manually. Verify the file exists before reading it.

**Warning signs:** Builder agent says "I don't see a task to work on" or works on the wrong task.

### Pitfall 2: Builder Spawning Returns Empty or Truncated Results

**What goes wrong:** The builder completes its work but the summary returned to the main conversation is too terse or missing critical information about what was built.

**Why it happens:** When using Task tool or `context: fork`, results are summarized before returning. If the builder produces very detailed output, it may be compacted.

**How to avoid:** The build skill should not rely solely on the builder's returned summary. After the builder returns, the skill can independently check `git diff --stat HEAD~1` to get the list of files changed, and combine that with the builder's narrative summary.

**Warning signs:** Post-task summary is generic ("task completed") rather than specific ("the login page is ready with form validation").

### Pitfall 3: Git Commit Includes Unrelated Changes

**What goes wrong:** The atomic commit includes changes not related to the current task -- files the user modified manually, or changes from a previous incomplete task.

**Why it happens:** `git add -A` stages everything. If there are unstaged changes from before the task started, they get included.

**How to avoid:** Before spawning the builder, check for existing unstaged/uncommitted changes. If found, either stash them or warn the user. After the builder completes, use `git diff --cached` to verify only task-relevant files are staged. Alternatively, use `git add` with specific file paths rather than `-A`.

**Warning signs:** The commit diff includes files the builder didn't touch. The undo command reverts more than expected.

### Pitfall 4: Syncer Tries to Auto-Commit

**What goes wrong:** The syncer agent modifies `.director/STATE.md` and creates its own commit, violating the "one commit per task" rule.

**Why it happens:** The syncer has Write access and might create a commit as part of "saving" its changes.

**How to avoid:** The syncer's system prompt already says "Never auto-commit documentation changes." Reinforce this in the instructions passed to the syncer. The build skill should handle committing sync changes -- either amending the task commit or creating a separate doc-sync commit. Recommendation: amend the task commit to include sync changes (keeps it to one commit per task).

**Warning signs:** Multiple commits appear for a single task. Undo reverts only part of the task.

### Pitfall 5: Ready Task Detection Fails on Complex Dependencies

**What goes wrong:** The "Needs First" field in task files uses plain-language capabilities ("needs the login page built first"), but matching these against completed work is fuzzy.

**Why it happens:** There's no formal ID system for task prerequisites. A task says "needs user authentication" and we need to figure out if that capability exists.

**How to avoid:** Use a pragmatic approach: check if the task file has been renamed to `.done.md` for tasks that precede the current one. Within a step, tasks are ordered sequentially -- task N is ready if tasks 1 through N-1 are done. Cross-step dependencies are harder; check if the prerequisite step is marked complete in STATE.md. For the first pass, sequential ordering within steps is sufficient.

**Warning signs:** A task is marked ready when its prerequisites aren't actually done. Or a task that should be ready is skipped.

### Pitfall 6: Context Budget Exceeded for Large Projects

**What goes wrong:** As the project grows, VISION.md gets longer, STEP.md has more context, and git history accumulates. The assembled context exceeds 30% of the window, degrading builder quality.

**Why it happens:** No active monitoring of context size during assembly.

**How to avoid:** Implement the context budget calculator before spawning. Apply truncation strategy: trim git log first (most recent 5-7 commits instead of 10), then reference docs, then summarize step context. Never truncate task or vision.

**Warning signs:** Builder produces lower-quality output. Builder "forgets" parts of the task or ignores acceptance criteria.

### Pitfall 7: Partial Task Success -- Builder Crashes Mid-Work

**What goes wrong:** The builder hits maxTurns, encounters an error, or the user interrupts. Some files are written but the task isn't complete. No commit was created.

**Why it happens:** Builder has maxTurns: 50 but complex tasks might exceed this. Network errors can interrupt. User might Ctrl+C.

**How to avoid:** The build skill should check whether the builder returned successfully. If not, check whether any files were modified. If files were modified but no commit was created: (a) show the user what was partially built, (b) offer to commit what exists with a "partial" note, or (c) offer to discard changes and try again. This is a Claude's Discretion area -- recommendation is to preserve partial work and let the user decide.

**Warning signs:** Modified files with no commit. Task still marked as "in progress" after `/director:build` returns.

## Code Examples

### Example 1: Build Skill Structure (Recommended Architecture)

```yaml
# Source: Pattern synthesis from official Claude Code docs + Director's established skill patterns
---
name: build
description: "Work on the next ready task in your project. Picks up where you left off automatically."
disable-model-invocation: true
---

# Director Build

## Step 1: Init check
[Check .director/ exists, run init script if not]

## Step 2: Vision check
[Read VISION.md, route to onboard if template-only]

## Step 3: Gameplan check
[Read GAMEPLAN.md, route to blueprint if template-only]

## Step 4: Find next ready task
[Scan goals/ hierarchy, check STATE.md, find first ready task]

## Step 5: Assemble context
[Read VISION.md, relevant STEP.md, task file, git log]
[Calculate context budget]
[Build XML-wrapped context string]

## Step 6: Spawn builder
[Use Task tool to spawn director-builder with assembled context]

## Step 7: Handle builder results
[Check if builder completed successfully]
[If partial success, handle per partial-success rules]

## Step 8: Create atomic commit
[git add -A && git commit]
[Report "Progress saved"]

## Step 9: Run doc sync
[Spawn director-syncer with task context]
[Present sync findings to user]
[If user confirms updates, apply and amend commit]

## Step 10: Post-task summary
[Plain-language paragraph + bullet list of changes]
[Show next ready task or step/goal completion]

$ARGUMENTS
```

### Example 2: Context Assembly with Dynamic Injection

```markdown
<!-- This is what the builder agent receives as its prompt -->
<vision>
# My Social Media App
Build a platform where creators can share short-form content...
[Full contents of VISION.md, dynamically injected]
</vision>

<current_step>
# Step 2: Core Features
Build the main user-facing features: feed, posting, profiles...
[Full contents of relevant STEP.md]
</current_step>

<task>
# Task: Build the user profile page
## What To Do
Show user's name, bio, avatar, and their recent posts.

## Why It Matters
Profiles let users personalize their presence and see their content history.

## Size
**Estimate:** medium

## Done When
- [ ] Profile page loads and displays user data from the database
- [ ] Avatar, name, and bio are visible
- [ ] Recent posts by this user are listed

## Needs First
Nothing -- the user database and basic layout are already done.
</task>

<recent_changes>
Recent progress:
- Login and signup pages are working
- Database has users table with authentication
- Navigation bar links to all main pages
</recent_changes>

<instructions>
Complete only this task. Do not modify files outside the listed scope.
Verify your work matches the acceptance criteria before committing.
Follow reference/terminology.md and reference/plain-language-guide.md for any user-facing output.
Create exactly one git commit when finished.
After committing, spawn director-verifier to check for stubs and orphans.
After verification passes, spawn director-syncer to update .director/ docs.
</instructions>
```

### Example 3: Task Completion Flow (Done File Convention)

```
# Before task execution:
.director/goals/01-mvp/01-foundation/tasks/
  01-setup-database.md       # Active task file

# After task execution:
.director/goals/01-mvp/01-foundation/tasks/
  01-setup-database.done.md  # Renamed to indicate completion
```

The `.done.md` rename is done by the syncer as part of STATE.md updates. The syncer marks the task complete in STATE.md and renames the task file. The original task content is preserved in the `.done.md` file for reference.

### Example 4: Ready Task Detection Logic

```
# Pseudocode for task selection:

1. Read STATE.md -> current_goal, current_step
2. Read GAMEPLAN.md -> verify goal/step still valid
3. List tasks in current step's tasks/ directory
4. For each task file (excluding .done.md files):
   a. Read task's "Needs First" section
   b. If "Nothing" or "can start right away" -> task is ready
   c. If it references a capability -> check if prerequisite tasks are .done.md
   d. First ready task wins (lowest number)
5. If no tasks ready in current step:
   a. Check if all tasks in step are .done.md
   b. If yes -> step is complete, move to next step
   c. If no -> tasks are blocked, report what's needed
6. If no steps available in current goal:
   a. Goal is complete, move to next goal
   b. Or all goals complete -> project is done!
```

### Example 5: Git Log for Recent Changes Context

```bash
# Generate plain-language recent changes for builder context
# Limit to last 10 commits, short format
git log --oneline -10 2>/dev/null | while read hash msg; do
  echo "- $msg"
done
```

This produces output like:
```
- Add user login page with form validation
- Set up database tables for user accounts and sessions
- Create navigation bar with links to all pages
- Set up project structure and configuration
```

### Example 6: Post-Task Summary Generation

```markdown
<!-- Template for post-task summary (locked decision: paragraph + bullets) -->

[Plain-language paragraph describing what was built, written from the
user's perspective. Focuses on what the user can do now that they
couldn't before. Mentions how this connects to what was built before.]

**What changed:**
- [File/feature change 1, in plain language]
- [File/feature change 2, in plain language]
- [File/feature change 3, in plain language]

Progress saved. You can type `/director:undo` to go back.

[If step is now complete:]
Step [N] is done! You're [X] of [Y] steps through [goal name].

[If more tasks in step:]
Next up: [next task name]. Want to keep building?
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `commands/` directory for skills | `skills/` directory with SKILL.md | Late 2025 | Skills support `context: fork`, supporting files, frontmatter control |
| No context isolation for skills | `context: fork` in skill frontmatter | Claude Code v1.0.33+ | Skills can run in isolated sub-agent context with separate conversation history |
| Manual agent spawning | Task tool with `Task(agent-name)` restriction | Claude Code v1.0.33+ | Skills can restrict which sub-agents can be spawned |
| No dynamic context injection | `!`command`` syntax in SKILL.md | Claude Code v1.0.33+ | Commands execute before content reaches Claude; output replaces placeholder |
| No agent memory | `memory: project` in agent frontmatter | Claude Code v1.0.33+ | Builder agent persists learning across sessions (already configured) |

**Important version note:** Claude Code agent teams (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`) exist but are experimental and NOT used in Phase 4. Phase 4 uses standard sub-agent spawning within a single task, which is stable and well-documented.

## Claude's Discretion Recommendations

Based on research, here are recommendations for the areas left to Claude's discretion:

### Task selection algorithm: Sequential ordering within steps

**Recommendation:** When multiple tasks in the same step are ready, select the one with the lowest number (e.g., task 01 before task 02). This follows natural document order and is predictable. Cross-step dependencies are handled by checking if the prerequisite step is complete. No need for a complex dependency graph -- the gameplan is already ordered by the planner using vertical slices.

### Context assembly strategy: Full files with budget monitoring

**Recommendation:** Load full VISION.md, full STEP.md, full task file, and last 10 git commits. Calculate rough token budget (chars/4). If over 30% of estimated window (~200K tokens for Opus), truncate in order: git log first (reduce to 5), then reference docs, then summarize STEP.md. Never truncate task or vision.

### Commit message formatting: Plain-language descriptions

**Recommendation:** Use present-tense, plain-language descriptions of what was built. No conventional commit prefixes (feat:, fix:, chore:). Format: "Add [feature]", "Set up [infrastructure]", "Connect [thing] to [thing]". Keep under 72 characters. This aligns with Director's plain-language philosophy and the builder agent's existing output rules.

### Sub-agent spawning decisions: Verifier always, syncer always, researcher on demand

**Recommendation:** The builder should ALWAYS spawn the verifier after completing work and ALWAYS spawn the syncer after verification passes. The researcher should be spawned ON DEMAND when the builder encounters a decision point (which library to use, how an API works, etc.). Update the builder's tools to include `Task(director-verifier, director-syncer, director-researcher)`.

### How to handle partial task success: Preserve and inform

**Recommendation:** If the builder fails mid-task (maxTurns hit, error, interruption):
1. Check if any files were modified (`git status`)
2. If yes: show the user what was partially built, suggest keeping changes and trying again with `/director:build`
3. If no: inform the user nothing was built, suggest trying again
4. Never silently discard partial work
5. Do NOT create a commit for partial work unless the user explicitly asks

### Doc sync technical approach: Code-change-only per task

**Recommendation:** Per-task sync should focus on the task's own changes only:
1. Read the task description to understand what was supposed to change
2. Check `git diff --stat HEAD~1` to see what files actually changed
3. Update STATE.md (mark task complete, update progress counts)
4. Flag any GAMEPLAN.md or VISION.md drift (don't modify, just report)
5. Full codebase scan for drift happens only on `/director:resume`

This keeps per-task sync fast (< 30 seconds) while still catching the most important drift.

## Open Questions

1. **`context: fork` vs inline Task spawning for the build workflow**
   - What we know: `context: fork` runs the skill content as an isolated sub-agent prompt. The Task tool spawns a named sub-agent with a message.
   - What's unclear: Whether `context: fork` is the right pattern when the skill needs significant pre/post orchestration (routing, task selection, commit, sync, reporting). The skill content becomes the agent's prompt, so routing logic would be wasted.
   - Recommendation: Use inline execution (no `context: fork`) with the Task tool to spawn the builder. This matches the pattern established by onboard and blueprint skills. The build skill does routing, assembles context, spawns the builder via Task, handles the result, commits, runs sync, and reports. This is the most flexible approach and aligns with existing patterns.

2. **How to pass assembled context to the builder via Task tool**
   - What we know: The Task tool sends a message to the sub-agent. The sub-agent receives the message as its task.
   - What's unclear: Whether there is a character limit on Task tool messages. Whether the XML-wrapped context will be correctly parsed.
   - Recommendation: Assemble the context as a string with XML tags in the skill instructions, then tell Claude to spawn the builder with that assembled context as the task message. The builder's system prompt already describes expected XML tags. This should work within normal message limits (~100K characters).

3. **Syncer changes -- amend commit or separate commit?**
   - What we know: The "one commit per task" rule is clear. The syncer modifies STATE.md and potentially other `.director/` files.
   - What's unclear: Whether amending the task commit to include sync changes is better than creating a separate "doc sync" commit.
   - Recommendation: Amend the task commit. This keeps the "one commit per task" principle clean. The undo command reverts everything at once. Run `git add .director/ && git commit --amend --no-edit` after sync completes.

4. **Task file `.done.md` rename timing**
   - What we know: The PRD shows `01-setup-database.done.md` as the convention for completed tasks.
   - What's unclear: Whether the builder, the syncer, or the build skill should perform the rename.
   - Recommendation: The syncer should rename the file as part of STATE.md updates. The syncer already has the task context and Write access. Renaming happens during sync, before the amend commit.

## Sources

### Primary (HIGH confidence)
- [Claude Code Skills Documentation](https://code.claude.com/docs/en/skills) -- Complete skill frontmatter reference, `context: fork`, dynamic context injection, agent selection. Fetched 2026-02-08.
- [Claude Code Sub-agents Documentation](https://code.claude.com/docs/en/sub-agents) -- Sub-agent frontmatter, Task tool, spawning patterns, nesting limitations, foreground/background modes. Fetched 2026-02-08.
- Director codebase (existing Phase 1-3 artifacts) -- All agent definitions, skill patterns, templates, reference docs. Read directly from `/Users/noahrasheta/Dev/GitHub/director/`. HIGH confidence.
- PRD Section 8.1.4 (Execution Engine) -- Requirements specification for `/director:build`. Read directly from `docs/design/PRD.md`.
- `reference/context-management.md` -- Context assembly rules, XML boundary tags, budget allocation, truncation strategy. Read from codebase.

### Secondary (MEDIUM confidence)
- [Claude Code Agent Teams](https://code.claude.com/docs/en/agent-teams) -- Confirmed agent teams are experimental and NOT needed for Phase 4. WebSearch verified with official docs.
- [Claude Code Plugin Issue #17283](https://github.com/anthropics/claude-code/issues/17283) -- `context: fork` and `agent:` fields ignored when skill invoked via Skill tool (not via `/`). This affects how we think about skill-based forking.

### Tertiary (LOW confidence)
- None -- all findings verified with official documentation or codebase inspection.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH -- All components verified from official Claude Code documentation and existing codebase
- Architecture patterns: HIGH -- Context assembly, sub-agent spawning, and skill patterns verified from official docs and established project patterns (onboard, blueprint skills)
- Pitfalls: HIGH -- Informed by real experience across 11 completed plans and official documentation on sub-agent limitations
- Code examples: HIGH -- Based on existing Director patterns adapted for execution workflow
- Discretion recommendations: MEDIUM -- Based on analysis of requirements and existing patterns but not yet validated in execution

**Research date:** 2026-02-08
**Valid until:** 2026-03-08 (30 days -- Claude Code plugin system is stable)
