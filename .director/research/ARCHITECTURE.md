# Architecture Research

**Analysis Date:** 2026-02-16
**Confidence:** HIGH

## Recommended Architecture

Director is a Claude Code plugin implementing a multi-agent orchestration framework. Its architecture is well-matched to the domain -- the layered skill/agent/state design reflects the authoritative Claude Code plugin patterns verified against official documentation. The findings below describe the current architecture as verified, note extension points for planned work, and call out where improvements are warranted.

### System Overview

```
User
  |
  | types /director:command
  v
┌─────────────────────────────────────────────────────────┐
│  COMMAND/SKILL LAYER  (skills/*/SKILL.md)               │
│  Orchestration: reads state, assembles context, routes  │
│  14 slash commands -- one SKILL.md per command          │
└────────────────────────┬────────────────────────────────┘
                         │ spawns via Task()
                         v
┌─────────────────────────────────────────────────────────┐
│  AGENT LAYER  (agents/director-*.md)                    │
│  Specialized workers: builder, verifier, syncer,        │
│  planner, researcher, mapper, interviewer, debugger     │
│  Each receives fresh, scoped XML-wrapped context        │
└────────────────────────┬────────────────────────────────┘
                         │ reads from / writes to
                         v
┌─────────────────────────────────────────────────────────┐
│  PROJECT STATE LAYER  (.director/)                      │
│  VISION.md, GAMEPLAN.md, STATE.md, goals/ tree,        │
│  codebase/ analysis, research/, brainstorms/            │
│  Single writer per document (syncer owns STATE.md)      │
└─────────────────────────────────────────────────────────┘
         ^
         |  lifecycle events (session start/end)
┌────────┴────────────────────────────────────────────────┐
│  SCRIPTING & HOOKS LAYER  (scripts/, hooks/)            │
│  Bash lifecycle scripts + hooks.json event registration │
└─────────────────────────────────────────────────────────┘
```

### Component Responsibilities

| Component | Responsibility | Implementation |
|-----------|----------------|----------------|
| Skill files (`skills/*/SKILL.md`) | User-facing orchestration; check prerequisites, route on conditions, assemble context, spawn agents, present results | Markdown with YAML frontmatter; `disable-model-invocation: true` prevents auto-triggering; `$ARGUMENTS` for user input |
| Agent files (`agents/director-*.md`) | Specialized AI workers with scoped tools, models, and maxTurns | Markdown with YAML frontmatter (`tools`, `model`, `maxTurns`, `memory`); receive XML-wrapped context |
| Project state (`.director/`) | Source of truth for vision, plan, and progress | Markdown (human-readable) + JSON (machine state); committed to git |
| Document assembly (embedded in skills) | Build XML-wrapped context packages before spawning agents | `<vision>`, `<task>`, `<current_step>`, `<decisions>`, `<recent_changes>`, `<instructions>` tags; max 30% context budget |
| Templates (`skills/*/templates/`) | Generate artifacts (vision, goals, steps, tasks, analysis docs) from canonical formats | Markdown files with placeholder markers for detection logic |
| Hooks/scripts (`scripts/`, `hooks/`) | Session lifecycle integration | Bash + `hooks/hooks.json` for SessionStart/SessionEnd events |

## Suggested Project Structure

The current structure is correct and well-organized. This is the canonical layout to follow:

```
director/
  .claude-plugin/
    plugin.json              # Plugin manifest (name, version, author)
  agents/
    director-builder.md      # Implements tasks; spawns verifier + syncer
    director-verifier.md     # Checks for stubs, orphans, wiring issues
    director-syncer.md       # Updates .director/ docs post-build
    director-planner.md      # Generates Goals > Steps > Tasks from vision
    director-interviewer.md  # Guided vision capture interviews
    director-researcher.md   # Step-level ecosystem research
    director-deep-researcher.md  # Domain research (parallel during onboard)
    director-synthesizer.md  # Summarizes research findings
    director-mapper.md       # Quick codebase re-scan (refresh command)
    director-deep-mapper.md  # Full codebase analysis (parallel during onboard)
    director-debugger.md     # Diagnoses and fixes verification failures
  skills/
    build/SKILL.md           # Execute next ready task
    blueprint/SKILL.md       # Create/update gameplan
    onboard/SKILL.md         # Project setup + vision capture
    inspect/SKILL.md         # Goal-backward verification
    quick/SKILL.md           # Fast one-off task
    status/SKILL.md          # Visual progress board
    resume/SKILL.md          # Restore context after break
    pivot/SKILL.md           # Handle requirement changes
    brainstorm/SKILL.md      # Think out loud with project context
    idea/SKILL.md            # Capture idea for later
    ideas/SKILL.md           # Review saved ideas
    refresh/SKILL.md         # Re-scan codebase
    undo/SKILL.md            # Revert most recent change
    help/SKILL.md            # Show commands with examples
    */templates/             # Artifact templates per command
  reference/
    context-management.md    # Context assembly rules + token budgets
    terminology.md           # Director vocabulary + forbidden jargon
    plain-language-guide.md  # Communication style guide
    verification-patterns.md # Structural verification patterns
  scripts/
    init-director.sh         # Initialize .director/ structure
    session-start.sh         # Session hook: load context summary
    state-save.sh            # Session hook: persist progress
    self-check.sh            # Plugin integrity validation
  hooks/
    hooks.json               # SessionStart + SessionEnd registrations
  docs/design/               # Design documents (not loaded at runtime)
  .director/                 # Runtime: created per user project, committed to git
    VISION.md
    GAMEPLAN.md
    STATE.md
    IDEAS.md
    config.json
    goals/
      NN-goal-slug/
        GOAL.md
        NN-step-slug/
          STEP.md
          RESEARCH.md        # Step-level research (blueprint skill)
          tasks/
            NN-task-slug.md
            NN-task-slug.done.md
    codebase/                # Deep mapper analysis output
      SUMMARY.md
      STACK.md
      ARCHITECTURE.md
      CONVENTIONS.md
      STRUCTURE.md
      TESTING.md
      CONCERNS.md
      INTEGRATIONS.md
    research/                # Deep researcher output (onboard + blueprint)
      SUMMARY.md
      STACK.md
      FEATURES.md
      ARCHITECTURE.md
      PITFALLS.md
    brainstorms/
      YYYY-MM-DD-topic.md
```

## Patterns That Work

### Pattern: Fresh Context Per Agent Invocation

**What:** Each time an agent is spawned, the orchestrating skill assembles a minimal context package containing only what that agent needs -- no accumulated conversation history, no unrelated state.

**When to use:** Every agent invocation. This is the core execution pattern for the entire system.

**Trade-offs:** Higher overhead per invocation (skills must read and assemble files each time), but dramatically better AI quality and lower token costs. Context isolation also makes agent behavior reproducible.

```
# Skill assembles context before spawning builder:
<vision>
[Full contents of .director/VISION.md]
</vision>

<current_step>
[Full contents of relevant STEP.md]
</current_step>

<decisions>
[Locked/Flexible/Deferred choices from STEP.md]
</decisions>

<task>
[Full contents of the specific task file]
</task>

<recent_changes>
[Last 10 git commits, plain-language]
</recent_changes>

<instructions>
Complete only this task. Create one git commit when done.
Spawn director:director-verifier after committing.
Spawn director:director-syncer after verification passes.
</instructions>
```

### Pattern: Parallel Agent Execution for Independent Research

**What:** When multiple independent research or analysis domains exist, spawn multiple agents simultaneously using the Task tool. Each agent works in its own context and returns results to the orchestrator.

**When to use:** Onboarding (4 deep mapper agents scan tech/arch/quality/concerns simultaneously; 4 deep researcher agents investigate domain simultaneously). Use whenever work is genuinely independent.

**Trade-offs:** Faster execution (parallel vs. serial). Risk: if one agent fails or times out, the orchestrator must handle partial results gracefully. The current implementation has no explicit fallback when a parallel agent fails -- this is a known concern in `.director/codebase/CONCERNS.md`.

```
# Onboard skill spawns 4 mappers in parallel:
Task(director:director-deep-mapper, focus: "technology stack")
Task(director:director-deep-mapper, focus: "architecture patterns")
Task(director:director-deep-mapper, focus: "code quality")
Task(director:director-deep-mapper, focus: "concerns and risks")

# Wait for all 4 to return, then synthesize
```

### Pattern: Single-Writer State Management

**What:** Only the syncer agent writes to `STATE.md`. All other agents read from it but never write to it. This eliminates concurrent write conflicts in the hierarchical state.

**When to use:** Any time multiple agents could modify shared state. The pattern generalizes: for each shared mutable document, designate exactly one agent responsible for writing it.

**Trade-offs:** Creates a critical dependency on the syncer. If the syncer fails after the builder commits, state drifts. The single-writer pattern trades flexibility for consistency.

```
# Builder commits code → spawns syncer with task context
# Syncer is the ONLY agent that:
# - Renames task file to .done.md
# - Updates STATE.md progress tracking
# - Flags drift between GAMEPLAN.md and actual state
# Build skill then amend-commits .director/ changes atomically
```

### Pattern: Marker-Based Template Detection

**What:** Skills detect whether a document is still a template (unfilled) by scanning for specific placeholder text. When placeholder markers are present, the skill routes to the setup flow rather than the execution flow.

**When to use:** Any skill that needs to verify a prerequisite document has real content. The `build` skill uses this for VISION.md and GAMEPLAN.md.

**Trade-offs:** Simple and requires no schema. Relies on templates containing specific detectable markers -- adding new templates without markers breaks routing logic.

```
# build/SKILL.md Step 2:
Read .director/VISION.md.
If file contains "> This file will be populated when you run /director:onboard"
  OR italic prompts like "_What are you calling this project?_"
  OR headings with no substantive content:
  → Route to onboarding flow
Else:
  → Continue to gameplan check
```

### Pattern: Atomic Commit Per Task

**What:** Each task execution produces exactly one git commit containing both the code changes and the updated `.director/` documentation. The build skill amend-commits any post-task updates (syncer doc changes, drift fixes, Tier 2 auto-fixes) into the same commit.

**When to use:** Always during `/director:build`. The pattern makes every task independently revertable.

**Trade-offs:** Requires careful amend-commit management across multiple post-task steps. The build skill's Step 9 and 10g cleanup steps handle this, but they add complexity.

```
Builder creates commit → verifier checks → syncer updates .director/
Build skill: git add .director/ && git commit --amend --no-edit
Tier 2 auto-fixes (if any): git add -A && git commit --amend --no-edit
Final cleanup: git status --porcelain → if dirty, amend-commit again
Result: one atomic commit containing task code + updated docs
```

### Pattern: Three-Tier Verification

**What:** Quality checking happens at three levels with different scopes and triggers.

**When to use:** Tier 1 always (structural, automated, invisible). Tier 2 at step/goal boundaries (behavioral, user confirms). Tier 3 optionally if project has test frameworks.

**Trade-offs:** No traditional test framework required. Tier 2 depends on user engagement -- a user who skips checklists gets weaker verification.

```
Tier 1 (Structural - always runs):
  Builder spawns verifier after every commit
  Checks: stubs, TODO markers, placeholder text, orphaned files, broken imports
  Output: "Verification: clean" or issues list

Tier 2 (Behavioral - at step/goal boundaries):
  Build skill generates checklist: "Try X. What happens?"
  User confirms each item passes
  Failed items trigger auto-fix loop or manual guidance

Tier 3 (Automated tests - optional):
  If project has jest/vitest/pytest configured, builder runs them
  Director never requires test frameworks
```

## Patterns to Avoid

### Anti-Pattern: Accumulating Conversation History Across Agents

**What people do:** Pass the full previous conversation or all prior agent outputs to each new agent invocation, building up a growing context window.

**Why it causes problems:** AI quality degrades with very long contexts. Cost per invocation grows linearly. Irrelevant information from earlier tasks contaminates agent focus. The 80% cost savings Director claims come specifically from NOT doing this.

**Do this instead:** Assemble a minimal, targeted context package for each agent. Include VISION.md (always), the relevant STEP.md and task file (for build), recent git log (for continuity), and relevant codebase/research files (task-type-keyed). Apply the 30% context budget rule from `reference/context-management.md`.

---

### Anti-Pattern: Multiple Agents Writing to the Same State File

**What people do:** Have both the builder and the syncer (or any two agents) both update STATE.md independently, reasoning that both have up-to-date information.

**Why it causes problems:** Concurrent or sequential writes without coordination cause last-writer-wins conflicts. The agent that runs second overwrites progress from the first. Ordering bugs are subtle and hard to detect.

**Do this instead:** Designate exactly one agent as the sole writer for each shared mutable document. For STATE.md, that is the syncer. For VISION.md and GAMEPLAN.md, changes require explicit user confirmation (handled by the build skill drift detection). All other agents are read-only for shared state.

---

### Anti-Pattern: Hardcoded Dependency on Parallel Agent Success

**What people do:** Spawn multiple agents in parallel and assume all of them succeed before synthesizing results.

**Why it causes problems:** If any single parallel agent fails (timeout, malformed output, API error), the entire pipeline stalls or produces incomplete results. The current deep mapper pattern is vulnerable here -- if one of the 4 parallel domain mappers fails, the resulting codebase analysis files will be missing or incomplete, and the synthesizer will operate on partial data.

**Do this instead:** Design parallel agent orchestration with explicit fallback handling. Check each agent's output before synthesizing. For the mapper specifically: if a domain's output file is missing or suspiciously short, re-run that domain agent serially before synthesizing. Flag incomplete results explicitly rather than silently producing degraded output.

---

### Anti-Pattern: Template Files Without Detectable Placeholders

**What people do:** Create a new template in `skills/*/templates/` that the user fills in, but omit the placeholder markers that routing logic scans for.

**Why it causes problems:** The skill routing in `build/SKILL.md` and `blueprint/SKILL.md` detects template state by looking for specific placeholder text. If a new template doesn't include these markers, the routing logic treats an empty template as real content and tries to execute work without a valid plan.

**Do this instead:** Every template that will be detected by skill routing must include the standard placeholder markers: VISION.md templates use `> This file will be populated when you run /director:onboard` or `_What are you calling this project?_`; GAMEPLAN.md templates use `_No goals defined yet_` or `This file will be populated when you run /director:blueprint`. Add new detectable patterns to ALL routing skills when adding new template types.

---

### Anti-Pattern: Exposing Technical Details in User-Facing Output

**What people do:** Have an agent report "Created `src/pages/Login.tsx` with `handleSubmit` calling the auth API" or "Committed SHA `abc1234`" in its output to the user.

**Why it causes problems:** Vibe coders do not think in file paths, commit SHAs, or technical implementation details. This language excludes them, creates anxiety about the internals, and violates Director's core design contract. It is the primary way Director could feel like a developer tool rather than a project manager.

**Do this instead:** Translate all technical output to user outcomes before presenting. "The login page is ready. Users can type their email and password to sign in." File paths, commit SHAs, and implementation details should only appear in internal agent-to-agent communication (XML context, instructions), never in anything shown to the user.

## How Data Flows

### Request Flow

```
User: /director:build
          |
    Skill: build/SKILL.md
    ├── [1] Check .director/ exists (init if not)
    ├── [2] Check VISION.md has real content (route to onboard if template)
    ├── [3] Check GAMEPLAN.md has real content (route to blueprint if template)
    ├── [4] Scan goals/ tree for next ready task (lowest numbered, prerequisites met)
    ├── [5] Assemble XML context package:
    │       vision + step + decisions + task + recent_changes + instructions + codebase
    ├── [6] Check for uncommitted changes (stash/commit/discard)
    ├── [7] Spawn director:director-builder with assembled context
    │         |
    │    Builder agent:
    │    ├── Read existing codebase for context
    │    ├── Implement task (write/edit files)
    │    ├── Create one git commit
    │    ├── Spawn director:director-verifier (stubs/orphans/wiring check)
    │    │       Verifier finds issues → builder fixes + amend-commit (up to 5 retries)
    │    └── Spawn director:director-syncer (update .director/ docs)
    │             Syncer: rename task.md → task.done.md
    │             Syncer: update STATE.md progress
    │             Syncer: flag drift between docs and code
    ├── [8] Verify builder created a commit (handle partial/no-work cases)
    │   └── Parse verification status from builder output
    │       If remaining issues: offer auto-fix via director:director-debugger
    ├── [9] Amend-commit syncer's .director/ changes (keep one atomic commit)
    │       Present drift warnings to user if any
    └── [10] Post-task summary + boundary detection
              Step complete → Tier 2 behavioral checklist
              Goal complete → Tier 2 goal-level checklist
              More tasks → show next task name
              All done → celebrate + suggest inspect/blueprint
```

### Onboarding Flow

```
User: /director:onboard
          |
    Skill: onboard/SKILL.md
    ├── Detect project type (greenfield vs. brownfield)
    │
    ├── [BROWNFIELD] Spawn 4 deep mapper agents IN PARALLEL:
    │   ├── director:director-deep-mapper (focus: technology stack → STACK.md)
    │   ├── director:director-deep-mapper (focus: architecture → ARCHITECTURE.md)
    │   ├── director:director-deep-mapper (focus: quality → TESTING.md, CONVENTIONS.md)
    │   └── director:director-deep-mapper (focus: concerns → CONCERNS.md)
    │   Wait for all 4 → write outputs to .director/codebase/
    │
    ├── Spawn director:director-interviewer (vision capture interview)
    │   One question at a time, collect answers, synthesize into VISION.md
    │
    ├── Spawn 4 deep researcher agents IN PARALLEL:
    │   ├── director:director-deep-researcher (domain: stack)
    │   ├── director:director-deep-researcher (domain: features)
    │   ├── director:director-deep-researcher (domain: architecture)
    │   └── director:director-deep-researcher (domain: pitfalls)
    │   Wait for all 4 → write outputs to .director/research/
    │
    └── Spawn director:director-synthesizer
        Synthesizer reads research/ → writes .director/research/SUMMARY.md
        Present findings + prompt for /director:blueprint
```

### Blueprint (Planning) Flow

```
User: /director:blueprint
          |
    Skill: blueprint/SKILL.md
    ├── Read VISION.md + existing GAMEPLAN.md (if any)
    ├── Check for [UNCLEAR] markers in vision; resolve ambiguities
    ├── Spawn director:director-planner with vision context
    │       Planner generates Goals > Steps > Tasks hierarchy
    │       Output presented to user for review/approval
    ├── For each step: optionally spawn director:director-deep-researcher
    │       (step-level research → writes to goals/NN/NN/RESEARCH.md)
    └── Write GAMEPLAN.md + goal/step/task .md files to .director/goals/
```

### State Management

Director uses a three-layer state model:

**Layer 1 -- Human-readable Markdown** (`.director/VISION.md`, `GAMEPLAN.md`, task files): Users read and edit these directly. Source of truth for intent.

**Layer 2 -- Machine JSON** (`.director/STATE.md` progress section, `config.json`): Tracks completion status, timestamps, cost estimates. Only syncer writes to STATE.md.

**Layer 3 -- Filesystem signals** (`.done.md` file extension): Task completion is signaled by renaming `task.md` to `task.done.md`. The build skill's task scanner reads directory listings rather than parsing STATE.md to find ready work -- making the filesystem the ground truth for task status.

The syncer keeps Layers 2 and 3 in sync. If syncer fails, Layer 3 (filesystem) remains authoritative and the next build scan still finds the correct tasks. STATE.md staleness only affects cost reporting and progress display, not execution correctness.

## Scaling Notes

Director's architecture is stable at its current scale (solo/small team projects, up to dozens of tasks). Key scaling considerations as the plugin grows:

| Scale | Approach |
|-------|----------|
| Current (single project, <100 tasks) | Current architecture works well. Parallel agent execution at onboard keeps startup fast. Single-writer state avoids conflicts. |
| Growing projects (100-500 tasks) | Task scanning in `build/SKILL.md` Step 4 reads every file in the tasks directory. As tasks accumulate, scan time grows linearly. Add STATE.md indexing of completed tasks to enable fast lookup instead of directory traversal. |
| Multi-project or team use | The plugin model (one `.director/` per project) naturally partitions state. No architectural change needed. Context management becomes more important as codebases grow -- the 30% budget rule and deep context truncation strategy handle this. |
| New agent types | Agents are additive -- adding a new `director-*.md` to `agents/` does not require changes elsewhere. Skills must explicitly spawn new agents; there is no auto-registration. This is the right design: intentional over magic. |
| New commands | New skills are additive -- create `skills/command-name/SKILL.md` and it registers as `/director:command-name`. Follow the canonical skill pattern: check prerequisites → route on conditions → spawn agents → assemble context → present results. Do NOT add a 15th command without removing an existing one -- simplicity is a feature. |

## Sources

- Claude Code plugin architecture: https://code.claude.com/docs/en/plugins (verified 2026-02-16, HIGH confidence)
- Claude Code sub-agents reference: https://code.claude.com/docs/en/sub-agents (verified 2026-02-16, HIGH confidence)
- Claude Code skills reference: https://code.claude.com/docs/en/skills (verified 2026-02-16, HIGH confidence)
- Director existing architecture analysis: `.director/codebase/ARCHITECTURE.md` (generated by deep mapper, HIGH confidence)
- Director context management reference: `reference/context-management.md` (authoritative project document)
- Director verification patterns: `reference/verification-patterns.md` (authoritative project document)
- Build skill implementation: `skills/build/SKILL.md` (ground truth for execution patterns)
- Builder agent definition: `agents/director-builder.md` (ground truth for agent patterns)

## Quality Gate

Before considering this file complete, verify:
- [x] Architecture diagram or description present
- [x] Component responsibilities clearly defined
- [x] At least 2 patterns to follow and 2 to avoid
- [x] Code examples included for recommended patterns
- [x] Scaling notes are realistic for the project's expected size
- [x] No section left empty -- use "Not applicable" if nothing found
