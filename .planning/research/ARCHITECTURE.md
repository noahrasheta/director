# Architecture Research

**Domain:** Claude Code plugin / AI orchestration framework
**Researched:** 2026-02-07
**Confidence:** HIGH

## Standard Architecture

### System Overview

Director is a Claude Code plugin. It lives entirely within the Claude Code runtime, using the official plugin system to register skills (slash commands), agents (subagents), and hooks (event handlers). There is no separate server, no standalone binary, and no external process. Everything Director does happens through Claude Code's plugin infrastructure.

```
                        USER
                         |
                    /director:*
                         |
         ┌───────────────┴───────────────┐
         │        PLUGIN LAYER           │
         │  .claude-plugin/plugin.json   │
         │                               │
         │  ┌─────────┐  ┌───────────┐   │
         │  │ Skills  │  │   Hooks   │   │
         │  │ (11)    │  │ (events)  │   │
         │  └────┬────┘  └─────┬─────┘   │
         │       │             │          │
         ├───────┴─────────────┴──────────┤
         │         AGENT LAYER            │
         │                                │
         │  ┌──────────┐  ┌───────────┐   │
         │  │ Agents   │  │ Workflows │   │
         │  │ (8)      │  │ (7)       │   │
         │  └────┬─────┘  └─────┬─────┘   │
         │       │              │          │
         ├───────┴──────────────┴──────────┤
         │       CONTEXT ASSEMBLY          │
         │                                 │
         │  VISION.md + STEP.md + task.md  │
         │  + git history → XML wrapper    │
         │  → fresh agent window           │
         │                                 │
         ├─────────────────────────────────┤
         │       STATE & STORAGE           │
         │                                 │
         │  .director/                     │
         │  ├── VISION.md   (Markdown)     │
         │  ├── GAMEPLAN.md (Markdown)     │
         │  ├── STATE.md    (Markdown)     │
         │  ├── config.json (JSON)         │
         │  └── goals/      (Markdown)     │
         │                                 │
         │  .git/ (atomic commits)         │
         └─────────────────────────────────┘
```

### Component Responsibilities

| Component | Responsibility | Typical Implementation |
|-----------|----------------|------------------------|
| **Plugin manifest** | Registers Director with Claude Code, defines namespace and metadata | `.claude-plugin/plugin.json` |
| **Skills (slash commands)** | User-facing entry points (`/director:build`, etc.) | `skills/<name>/SKILL.md` or `commands/<name>.md` |
| **Agents (subagents)** | Specialized AI roles with focused prompts and tool permissions | `agents/<name>.md` with YAML frontmatter |
| **Hooks** | Guardrails and automation tied to Claude Code lifecycle events | `hooks/hooks.json` |
| **Context assembler** | Collects Markdown artifacts, wraps in XML boundary tags, delivers to fresh agent windows | Logic embedded in skill/workflow instructions |
| **State manager** | Tracks progress, dependencies, and project configuration | `.director/STATE.md` + `config.json` |
| **Template system** | Markdown templates that constrain AI output quality for `.director/` artifacts | Bundled files in skill directories |
| **Reference docs** | Internal guidance loaded into agent context (verification patterns, terminology rules, etc.) | Files referenced from SKILL.md or agent markdown |

## Recommended Plugin Structure

```
director/                                 # Plugin root
├── .claude-plugin/
│   └── plugin.json                       # Plugin manifest (name, version, description)
│
├── skills/                               # User-facing slash commands
│   ├── onboard/
│   │   ├── SKILL.md                      # /director:onboard entry point + workflow instructions
│   │   └── templates/
│   │       ├── vision-template.md        # Template for VISION.md generation
│   │       └── interview-questions.md    # Question bank for onboarding interview
│   ├── blueprint/
│   │   ├── SKILL.md                      # /director:blueprint entry point
│   │   └── templates/
│   │       ├── gameplan-template.md      # Template for GAMEPLAN.md
│   │       ├── goal-template.md          # Template for GOAL.md
│   │       ├── step-template.md          # Template for STEP.md
│   │       └── task-template.md          # Template for task files
│   ├── build/
│   │   ├── SKILL.md                      # /director:build entry point
│   │   └── reference/
│   │       └── context-assembly.md       # How to assemble context for fresh agent
│   ├── inspect/
│   │   ├── SKILL.md                      # /director:inspect entry point
│   │   └── reference/
│   │       ├── structural-checks.md      # Tier 1 verification patterns
│   │       └── behavioral-checklist.md   # Tier 2 checklist generation
│   ├── status/
│   │   └── SKILL.md                      # /director:status entry point
│   ├── resume/
│   │   └── SKILL.md                      # /director:resume entry point
│   ├── quick/
│   │   └── SKILL.md                      # /director:quick entry point
│   ├── pivot/
│   │   ├── SKILL.md                      # /director:pivot entry point
│   │   └── reference/
│   │       └── delta-spec-format.md      # ADDED/MODIFIED/REMOVED patterns
│   ├── brainstorm/
│   │   ├── SKILL.md                      # /director:brainstorm entry point
│   │   └── templates/
│   │       └── brainstorm-session.md     # Template for saved sessions
│   ├── idea/
│   │   └── SKILL.md                      # /director:idea entry point
│   └── help/
│       └── SKILL.md                      # /director:help entry point
│
├── agents/                               # Specialized subagents
│   ├── director-interviewer.md           # Conversation agent (onboard, brainstorm, pivot)
│   ├── director-planner.md               # Gameplan creation and updates
│   ├── director-researcher.md            # Implementation research
│   ├── director-mapper.md                # Codebase analysis (existing projects)
│   ├── director-builder.md               # Task execution with fresh context
│   ├── director-verifier.md              # Structural + behavioral verification
│   ├── director-debugger.md              # Issue investigation and fix plans
│   └── director-syncer.md                # Documentation sync after tasks
│
├── hooks/
│   └── hooks.json                        # Event hooks for guardrails
│
├── reference/                            # Internal docs loaded by agents/skills
│   ├── terminology.md                    # Director vocabulary rules
│   ├── plain-language-guide.md           # How to communicate with vibe coders
│   ├── verification-patterns.md          # Stub/orphan/wiring detection patterns
│   └── context-management.md             # Fresh agent window assembly rules
│
├── scripts/                              # Hook scripts and utilities
│   ├── validate-commit.sh                # Pre-commit validation
│   └── check-state-integrity.sh          # State file validation
│
├── CHANGELOG.md
├── LICENSE
└── README.md
```

### Structure Rationale

- **`skills/`**: Each slash command gets its own directory with SKILL.md as entry point. Supporting files (templates, reference docs) live alongside the skill. This follows Claude Code's plugin convention where each skill is a folder with SKILL.md.
- **`agents/`**: Each agent is a single Markdown file with YAML frontmatter defining its name, description, tools, model, and permissions. The Markdown body is the system prompt. This follows Claude Code's subagent format.
- **`hooks/`**: A single `hooks.json` handles all lifecycle events. Scripts in `scripts/` are referenced via `${CLAUDE_PLUGIN_ROOT}`.
- **`reference/`**: Internal docs that skills and agents reference for domain knowledge (like terminology rules). These are NOT loaded into every context; they are loaded on demand when a skill references them.
- **Templates live inside their skill**: The `onboard` skill needs the vision template. The `blueprint` skill needs the gameplan template. Co-locating templates with skills keeps dependencies clear.

## Architectural Patterns

### Pattern 1: Skill-as-Orchestrator

**What:** Each skill's SKILL.md contains the workflow logic that chains agents together. The skill IS the workflow definition. There is no separate workflow engine.
**When to use:** For every `/director:` command.
**Trade-offs:** Simple (no workflow runtime to build), but workflow logic is embedded in skill markdown. Changes to workflow require editing SKILL.md.

A skill like `/director:build` functions as follows: its SKILL.md contains instructions that tell Claude to (1) read STATE.md to find the next ready task, (2) spawn the `director-builder` agent with assembled context via `context: fork`, (3) after the builder returns, spawn `director-verifier` as a subagent, (4) then spawn `director-syncer` as a subagent, and (5) update STATE.md and report results. The orchestration is expressed as step-by-step instructions in the skill's markdown, which Claude follows sequentially.

```yaml
# Example: skills/build/SKILL.md frontmatter
---
name: build
description: Execute the next ready task in your gameplan. Use when
  the user wants to make progress on their project.
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, Task
---

# Build Workflow

1. Read `.director/STATE.md` to find the next task with status "ready"
2. If no tasks are ready, explain what is blocked and why
3. Assemble context for the builder agent (see reference/context-assembly.md)
4. Spawn the `director-builder` agent with the assembled context
5. When the builder completes, spawn `director-verifier` to check the work
6. Spawn `director-syncer` to update documentation
7. Update `.director/STATE.md` with the task's new status
8. Report results to the user in plain language
...
```

### Pattern 2: Fresh Context per Task via context: fork

**What:** Each task execution spawns a subagent with `context: fork`, giving it a clean context window with only the necessary information. The skill assembles a focused prompt from Markdown artifacts wrapped in XML boundary tags.
**When to use:** For `/director:build` and `/director:quick` task execution.
**Trade-offs:** Prevents context degradation and reduces API costs by 80%+, but each fresh agent must reconstruct understanding from the assembled context (no conversation memory).

The assembled context follows this structure:

```
<vision>
[Contents of .director/VISION.md]
</vision>

<current_step>
[Contents of the relevant STEP.md]
</current_step>

<task>
[Task description, acceptance criteria, relevant files]
</task>

<recent_changes>
[Recent git log summary]
</recent_changes>

<instructions>
Complete only this task. Do not modify files outside the listed scope.
Verify your work matches the acceptance criteria before committing.
</instructions>
```

The builder skill constructs this prompt from files on disk, then spawns `director-builder` with `context: fork` and `agent: director-builder` in the SKILL.md frontmatter (or instructs Claude to delegate to the builder agent with this assembled prompt).

### Pattern 3: State as Markdown Files

**What:** All project state lives in `.director/` as Markdown files (human-readable) with a single `config.json` for machine settings. Progress tracking uses structured Markdown in STATE.md rather than a database.
**When to use:** For all state persistence.
**Trade-offs:** Human-readable and git-diffable, but parsing structured data from Markdown is less reliable than JSON. Mitigated by keeping STATE.md in a predictable format with clear section headers.

STATE.md structure:

```markdown
# Project State

## Current Position
- **Active Goal:** 01-mvp
- **Active Step:** 02-core-features
- **Active Task:** 03-build-login-page
- **Status:** in-progress

## Progress
| Goal | Steps | Complete | Status |
|------|-------|----------|--------|
| 01-mvp | 6 | 3 | In Progress |
| 02-v2 | 4 | 0 | Not Started |

## Task Queue
| Task | Step | Status | Needs First |
|------|------|--------|-------------|
| 03-build-login-page | 02-core-features | in-progress | - |
| 04-user-profile | 02-core-features | ready | 03-build-login-page |
| 05-settings-page | 02-core-features | blocked | 04-user-profile |
```

### Pattern 4: Agent Specialization via Tool Restrictions

**What:** Each agent has a restricted tool set matching its role. The mapper and verifier are read-only (denied Write, Edit). The builder has full tool access. The syncer has Write access but only to `.director/` files (enforced via instructions, not hard restrictions).
**When to use:** For all agent definitions.
**Trade-offs:** Reduces risk of agents modifying things they should not, but Claude Code's tool restrictions are coarse-grained (tool-level, not path-level). Path-level restrictions must be enforced via agent instructions.

```yaml
# Example: agents/director-verifier.md
---
name: director-verifier
description: Verifies that built code is real implementation, not stubs
  or placeholders. Checks for orphaned files and wiring issues. Use
  proactively after any build task completes.
tools: Read, Grep, Glob, Bash
model: sonnet
---

You are Director's verification agent. Your job is to check that code
is real, connected, and complete. You CANNOT modify code - only report
findings.

Check for:
1. Stub detection: TODO comments, empty returns, placeholder text
2. Orphan detection: files that exist but are not imported anywhere
3. Wiring verification: components render, routes connect, APIs respond
...
```

### Pattern 5: Hooks as Guardrails

**What:** Hooks enforce invariants that skills and agents alone cannot guarantee. For example, a `PostToolUse` hook on `Write|Edit` can validate that changes to `.director/` files maintain valid structure. A `Stop` hook can verify that documentation was synced before Claude finishes.
**When to use:** For constraints that must always hold, regardless of which skill or agent is running.
**Trade-offs:** Hooks add latency to every matched event. Keep them fast. Use hooks for validation, not for workflow logic.

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/check-state-integrity.sh",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
```

## Data Flow

### Command Invocation Flow

```
User types /director:build
    |
    v
Claude Code loads skills/build/SKILL.md
    |
    v
SKILL.md instructions tell Claude to:
    |
    ├─→ Read .director/STATE.md (find next ready task)
    |
    ├─→ Read .director/VISION.md
    |     Read goals/<goal>/<step>/STEP.md
    |     Read goals/<goal>/<step>/tasks/<task>.md
    |     Read recent git log
    |
    ├─→ Assemble context (Markdown wrapped in XML tags)
    |
    ├─→ Spawn director-builder subagent
    |     (context: fork, fresh window)
    |     Builder executes task, writes code, commits
    |     Builder returns summary
    |
    ├─→ Spawn director-verifier subagent
    |     (reads codebase, checks for stubs/orphans/wiring)
    |     Returns verification report
    |
    ├─→ Spawn director-syncer subagent
    |     (compares codebase against .director/ docs)
    |     Updates any docs that are out of date
    |
    ├─→ Update .director/STATE.md
    |     Create goals/<goal>/<step>/tasks/<task>.done.md
    |
    └─→ Report to user in plain language
         "Login page is built. Here's what it does..."
```

### State Management Flow

```
                    ┌──────────────────┐
                    │   .director/     │
                    │                  │
       ┌───────────┤  VISION.md       │ ← Written by: onboard, pivot
       │           │  GAMEPLAN.md     │ ← Written by: blueprint, pivot
       │           │  STATE.md        │ ← Written by: build, inspect, resume
       │  Read by  │  IDEAS.md        │ ← Written by: idea, brainstorm
       │  all      │  config.json     │ ← Written by: onboard (initial)
       │  agents   │  brainstorms/    │ ← Written by: brainstorm
       │           │  goals/          │ ← Written by: blueprint, build
       │           │    GOAL.md       │
       │           │    STEP.md       │
       │           │    RESEARCH.md   │ ← Written by: researcher
       │           │    tasks/        │
       │           │      *.md        │ ← Written by: blueprint
       │           │      *.done.md   │ ← Written by: build
       │           └──────────────────┘
       │
       │           ┌──────────────────┐
       │           │    .git/         │
       └──────────►│                  │
                   │  One commit per  │ ← Written by: builder agent
                   │  completed task  │
                   │                  │
                   │  Read by fresh   │ → Recent commits loaded into
                   │  agents via      │   agent context as history
                   │  git log         │
                   └──────────────────┘
```

### Agent-to-Agent Communication

Agents do NOT communicate directly with each other. All agent coordination flows through the orchestrating skill:

```
SKILL.md (orchestrator)
    │
    ├──→ Spawn Agent A
    │    Agent A completes, returns summary to skill
    │
    ├──→ Skill reads Agent A's output
    │    Decides what to do next
    │
    ├──→ Spawn Agent B (with relevant context from A's output)
    │    Agent B completes, returns summary to skill
    │
    └──→ Skill synthesizes results, updates state
```

This is the "subagent chaining" pattern from Claude Code's documentation: the main conversation (driven by the skill) spawns subagents sequentially, passing relevant results from one to the next. There is no shared memory, no message bus, and no event system between agents. The skill's instructions are the orchestration layer.

**Exception (Phase 3):** Agent Teams introduce direct inter-agent messaging for coordinated multi-task parallelism. This is NOT part of MVP architecture.

### Key Data Flows

1. **Onboarding flow:** User answers interview questions -> `director-interviewer` captures answers -> answers assembled into VISION.md template -> for existing projects, `director-mapper` runs in parallel to analyze codebase -> mapper findings merged into vision -> `director-planner` creates initial GAMEPLAN.md
2. **Build flow:** Skill reads STATE.md -> assembles context from Markdown files -> spawns `director-builder` in fresh context -> builder writes code and commits -> `director-verifier` checks work -> `director-syncer` updates docs -> STATE.md updated
3. **Resume flow:** Skill reads STATE.md + git log -> reconstructs project position -> reports status in plain language -> identifies next ready task

## Scaling Considerations

Director does not have traditional scaling concerns (no server, no database, no concurrent users). Its relevant concerns are context and cost efficiency.

| Concern | Small Project (<50 files) | Medium Project (50-500 files) | Large Project (500+ files) |
|---------|---------------------------|-------------------------------|----------------------------|
| Context assembly | Load full VISION.md + task context directly | Same approach; STEP.md keeps scope narrow | Mapper agent summarizes relevant sections; STEP.md critical for scoping |
| Codebase mapping | Single mapper pass sufficient | Parallel mapper sub-agents for speed | Must chunk analysis; mapper returns summaries not full file contents |
| State file size | STATE.md is tiny | STATE.md grows but remains parseable | Consider splitting STATE.md per goal if >100 tasks |
| Git history context | Full recent log fits easily | Limit to last 20-30 commits for agent context | Limit to last 10-15 commits; filter to relevant files |
| Cost per build cycle | Low (small context payloads) | Medium (VISION.md + STEP.md + task) | Same as medium (fresh context isolates to task scope) |

### Scaling Priorities

1. **First bottleneck:** STATE.md parsing for large projects with many tasks. If STATE.md exceeds 200-300 lines, agents may struggle to parse it reliably. Mitigation: keep STATE.md in a predictable table format; consider splitting state per goal.
2. **Second bottleneck:** Codebase mapping for very large existing projects. The mapper agent may hit context limits trying to analyze the full codebase. Mitigation: chunk the analysis into parallel sub-agents (architecture, tech stack, patterns, concerns), each summarizing its findings.

## Anti-Patterns

### Anti-Pattern 1: Accumulated Context

**What people do:** Keep the same agent conversation running across multiple tasks, adding more context as the project grows.
**Why it's wrong:** Claude's output quality degrades as context accumulates. Costs increase linearly with context size. The agent starts confusing earlier task context with current task requirements.
**Do this instead:** Fresh agent window per task. Assemble only the context needed for that specific task. Use git log as the lightweight "memory" of what was built before.

### Anti-Pattern 2: Agents Modifying State Directly

**What people do:** Let any agent read and write STATE.md, GAMEPLAN.md, or VISION.md at any time.
**Why it's wrong:** Multiple agents writing to the same state files creates race conditions (especially with parallel sub-agents) and inconsistent state. An agent that modifies the gameplan during a build task could invalidate the task it is currently executing.
**Do this instead:** Only the orchestrating skill (the top-level SKILL.md instructions being followed by Claude) should write to state files. Agents return their results to the skill, and the skill updates state. The one exception is `director-syncer`, which is specifically designed to update `.director/` documentation as a controlled post-task operation.

### Anti-Pattern 3: Workflow Engine Complexity

**What people do:** Build a separate workflow runtime that parses workflow definitions, manages state transitions, and orchestrates agent invocations programmatically.
**Why it's wrong:** Adds a layer of complexity that must be built, tested, and maintained. Claude Code already provides the orchestration primitive (skills that invoke subagents). The workflow IS the skill's instructions.
**Do this instead:** Encode workflows directly in SKILL.md as step-by-step instructions. Claude follows them naturally. The "workflow engine" is Claude itself following markdown instructions.

### Anti-Pattern 4: Overloading Agent Context

**What people do:** Load VISION.md + GAMEPLAN.md + STATE.md + all STEP.md files + all task files + full git log into every agent context.
**Why it's wrong:** Wastes tokens, increases costs, and can push agents past effective context limits. Most agents only need a subset of this information.
**Do this instead:** Each agent receives only what it needs. The builder gets VISION.md + its STEP.md + its task file + recent git history. The verifier gets the task's acceptance criteria + the relevant source files. The syncer gets the diff of what changed. The skill instructions specify what to load for each agent.

### Anti-Pattern 5: Hard-Coding Tool Restrictions at Path Level

**What people do:** Try to use Claude Code's tool system to restrict agents to specific file paths (e.g., "only allow Write to .director/ files").
**Why it's wrong:** Claude Code's `allowed-tools` and `disallowedTools` work at the tool level (Write, Edit, Bash), not at the file path level. You cannot say "allow Write but only to .director/*.md" in frontmatter.
**Do this instead:** Use tool-level restrictions (e.g., deny Write/Edit for read-only agents) and path-level constraints in the agent's instructions (e.g., "Only modify files within .director/"). Claude follows instructions reliably for scoping.

## Integration Points

### External Services

| Service | Integration Pattern | Notes |
|---------|---------------------|-------|
| Git | Direct CLI via Bash tool | Agent runs `git add`, `git commit`, `git log`. Abstracted from user as "progress saved." |
| User's MCP servers | Inherited automatically | Director agents can use Supabase, Stripe, GitHub MCP tools if the user has them configured. No Director-side configuration needed. |
| Claude Code Agent Teams | Phase 3 only | Director would use Claude Code's experimental agent teams feature for multi-task parallelism. Not part of MVP. |

### Internal Boundaries

| Boundary | Communication | Notes |
|----------|---------------|-------|
| Skill -> Agent | Task tool delegation (`context: fork` or inline subagent spawn) | Skill assembles context, agent executes in isolation, returns summary |
| Agent -> State files | Agent returns results to skill; skill writes to `.director/` | Agents do NOT write state directly (except syncer for doc updates) |
| Skill -> Hooks | Hooks fire automatically on Claude Code lifecycle events | Hooks validate invariants; they don't drive workflow logic |
| Plugin -> Claude Code | Plugin registers components at install time | Skills appear in `/help`, agents in `/agents`, hooks fire automatically |
| `.director/` -> Fresh agents | Skill reads files, assembles context payload | XML boundary tags wrap Markdown content for AI parsing accuracy |

## Build Order & Dependencies

The following build order reflects component dependencies. Each numbered item depends on the items above it.

### Phase 1: Foundation (no inter-component dependencies)

These can be built in parallel as they are independent:

1. **Plugin manifest** (`.claude-plugin/plugin.json`) -- Registers the plugin with Claude Code. Required for anything else to load.
2. **Reference docs** (`reference/`) -- Terminology rules, plain-language guide, verification patterns. These are static content with no code dependencies.
3. **Templates** (within skill directories) -- VISION.md template, GAMEPLAN.md template, task template. Static markdown files.

### Phase 2: State & Storage (depends on Phase 1)

4. **`.director/` folder initialization logic** -- Logic for creating the folder structure, initializing STATE.md, config.json. This must be defined before any skill can write state. Lives inside the `onboard` skill.

### Phase 3: Core Agents (depends on Phase 1 reference docs)

These agents can be built in parallel as they are independent of each other:

5. **director-interviewer** -- Conducts conversations. Depends on: reference/terminology.md, reference/plain-language-guide.md.
6. **director-mapper** -- Analyzes codebases. Depends on: reference docs for output format.
7. **director-planner** -- Creates gameplans. Depends on: templates for GAMEPLAN.md, GOAL.md, STEP.md, task files.
8. **director-builder** -- Executes tasks. Depends on: reference/context-management.md for understanding assembled context.
9. **director-verifier** -- Checks work. Depends on: reference/verification-patterns.md.
10. **director-debugger** -- Investigates issues. Depends on: nothing beyond standard agent definition.
11. **director-researcher** -- Explores implementation approaches. Depends on: nothing beyond standard agent definition.
12. **director-syncer** -- Updates docs. Depends on: understanding of `.director/` structure.

### Phase 4: Core Skills (depends on Phase 2 state + Phase 3 agents)

Skills depend on agents and state, and some depend on each other:

13. **`/director:help`** -- No dependencies beyond plugin manifest. Build first as smoke test.
14. **`/director:onboard`** -- Depends on: interviewer, mapper, planner agents + `.director/` initialization + vision template.
15. **`/director:blueprint`** -- Depends on: planner, researcher agents + gameplan template. Requires VISION.md to exist (created by onboard).
16. **`/director:build`** -- Depends on: builder, verifier, syncer agents + context assembly logic. Requires GAMEPLAN.md and STATE.md to exist.
17. **`/director:inspect`** -- Depends on: verifier, debugger agents. Requires built code to verify.
18. **`/director:status`** -- Depends on: STATE.md parser. Lightweight, no agents needed.
19. **`/director:resume`** -- Depends on: STATE.md + git log reading. Lightweight.
20. **`/director:quick`** -- Depends on: builder, verifier, syncer agents. Simplified version of build.
21. **`/director:idea`** -- Depends on: IDEAS.md write logic. Very lightweight.
22. **`/director:brainstorm`** -- Depends on: interviewer agent + full project context loading.
23. **`/director:pivot`** -- Depends on: interviewer, mapper, planner agents + delta spec patterns. Most complex skill.

### Phase 5: Hooks & Guardrails (depends on Phase 4 skills)

24. **hooks.json** -- Guardrails that validate state integrity after writes. Should be added after the core workflow is functional, so there is behavior to guard against.

### Build Order Summary

```
Phase 1 (parallel):  manifest + reference docs + templates
                           |
Phase 2:              .director/ initialization
                           |
Phase 3 (parallel):   all 8 agents
                           |
Phase 4 (sequential): help → onboard → blueprint → build → inspect
         (parallel):  status, resume, quick, idea, brainstorm, pivot
                           |
Phase 5:              hooks & guardrails
```

**Critical path:** manifest -> .director/ init -> interviewer + planner + builder agents -> onboard -> blueprint -> build -> inspect

**Why this order:**
- You cannot test any skill without the plugin manifest registered.
- You cannot test onboard without the interviewer and mapper agents.
- You cannot test blueprint without a VISION.md (created by onboard).
- You cannot test build without a GAMEPLAN.md (created by blueprint).
- You cannot test inspect without built code (created by build).
- help, status, resume, quick, idea, brainstorm, and pivot can be built in parallel once the core loop (onboard -> blueprint -> build -> inspect) is functional.
- Hooks are refinements; add them after the workflow works without them.

## Sources

- [Claude Code Plugins documentation](https://code.claude.com/docs/en/plugins) -- Official plugin creation guide (HIGH confidence)
- [Claude Code Skills documentation](https://code.claude.com/docs/en/skills) -- Skill/command system with frontmatter options (HIGH confidence)
- [Claude Code Subagents documentation](https://code.claude.com/docs/en/sub-agents) -- Agent definitions, tool restrictions, models, permissions (HIGH confidence)
- [Claude Code Hooks reference](https://code.claude.com/docs/en/hooks) -- Complete hook event lifecycle, matchers, JSON input/output (HIGH confidence)
- [Claude Code Plugins reference](https://code.claude.com/docs/en/plugins-reference) -- Full manifest schema, directory structure, distribution (HIGH confidence)
- [Claude Code Agent Teams documentation](https://code.claude.com/docs/en/agent-teams) -- Experimental multi-agent coordination (HIGH confidence, but experimental feature)
- Director PRD v1.0 (docs/design/PRD.md) -- Feature requirements and architectural decisions (HIGH confidence, authoritative)
- Director Competitive Analysis (docs/design/research-competitive-analysis.md) -- 8 competitor architectures analyzed (HIGH confidence)
- Director Opus 4.6 Strategy (docs/design/research-opus-46-strategy.md) -- AI capability integration plan (HIGH confidence)

---
*Architecture research for: Claude Code plugin / AI orchestration framework*
*Researched: 2026-02-07*
