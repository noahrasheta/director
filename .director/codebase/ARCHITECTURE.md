# Architecture

**Analysis Date:** 2026-02-16

## Pattern Overview

**Overall:** Multi-agent orchestration framework with pluggable skill architecture and deep context assembly pattern

**Key Characteristics:**
- **Skill-based command structure** -- Each slash command (`/director:onboard`, `/director:build`, etc.) is a self-contained skill with its own workflow logic. See `skills/` directory structure.
- **Sub-agent spawning** -- Skills invoke specialized agents (builder, verifier, mapper, syncer, etc.) to decompose work. See `agents/` directory for agent definitions.
- **Fresh context per invocation** -- Each agent receives only the context it needs: vision, current step, task definition, decisions, recent git history. No accumulated conversation history. See `agents/director-builder.md` for the pattern.
- **State machine progression** -- The framework models projects as Goal > Step > Task hierarchy with explicit state tracking in `.director/STATE.md`. The build pipeline uses this to filter ready work.
- **XML-wrapped assembly** -- Context for agents is assembled by skills and wrapped with XML boundary tags (`<vision>`, `<task>`, `<instructions>`, etc.) to improve AI parsing. This is internal wiring; users never see the XML.

## Layers

**Command/Skill Layer:**
- Purpose: User-facing entry points; orchestrate multi-step workflows (onboarding, planning, building, verification, inspection)
- Location: `skills/` with 14 subdirectories (one per command)
- Contains: SKILL.md file defining each command's workflow, plus templates for artifact generation
- Depends on: Agent specifications (in `agents/`), project state (in `.director/`), scripts (in `scripts/`)
- Used by: Claude Code plugin runtime; invoked when user types `/director:command`

**Agent Layer:**
- Purpose: Specialized sub-agents that execute specific responsibilities within skills
- Location: `agents/` directory
- Contains: Agent definitions (one `.md` file per agent type) describing capabilities, context requirements, tools, and execution rules
- Key agents:
  - `director-builder.md` -- Writes code, makes changes, produces atomic commits
  - `director-verifier.md` -- Checks code for stubs, placeholders, wiring issues
  - `director-syncer.md` -- Updates `.director/` docs to reflect codebase changes
  - `director-deep-mapper.md` -- Analyzes existing codebase for tech/arch/quality/concerns (spawned in parallel during onboard)
  - `director-mapper.md` -- Quick structural scan of codebase to detect breaking changes during refresh
  - `director-interviewer.md` -- Conducts guided interviews to capture vision (used by onboard skill)
  - `director-planner.md` -- Generates goals, steps, and tasks from vision (used by blueprint skill)
  - `director-deep-researcher.md`, `director-researcher.md` -- Domain and ecosystem research (parallel execution during onboard and blueprint)
  - `director-synthesizer.md` -- Summarizes research findings into actionable guidance
  - `director-debugger.md` -- Diagnoses failures and suggests fixes
- Depends on: Project state, tools (Read, Write, Bash, Grep, etc.)
- Used by: Skills spawn agents when needed via Task() syntax in skill definitions

**Project State Layer:**
- Purpose: Source of truth for project state, vision, gameplan, and progress
- Location: `.director/` directory
- Contains:
  - `VISION.md` -- What is being built, why, for whom, constraints, technical preferences
  - `GAMEPLAN.md` -- Goals, steps, tasks structure (derived from vision)
  - `STATE.md` -- Progress tracking (per-goal/step/task completion, current position, timestamps, token costs)
  - `IDEAS.md` -- Captured ideas for future work
  - `config.json` -- Project settings (model selection, cost limits, verification flags)
  - `goals/` subdirectory -- Stores actual goal, step, and task markdown files in a tree structure
  - `codebase/` subdirectory -- Analysis documents written by deep mapper agents (STACK.md, ARCHITECTURE.md, CONVENTIONS.md, TESTING.md, CONCERNS.md, etc.)
  - `brainstorms/` subdirectory -- Saved brainstorm session transcripts
- Depends on: Nothing (is source of truth)
- Used by: All agents load relevant pieces when assembling context

**Document Assembly System (implicit):**
- Purpose: Build custom context packages for each agent invocation
- How it works: Skills read project state files and assemble them into XML-wrapped packages before spawning agents
- Example: Build skill reads VISION.md + current STEP.md + TASK.md + recent git log, wraps them in `<vision>` / `<current_step>` / `<task>` / `<recent_changes>` tags, then passes to builder agent
- No dedicated location; logic is embedded in skill workflows and referenced in agent definitions
- Used by: Every skill uses this pattern implicitly

**Templating & Generation System:**
- Purpose: Generate new artifacts (visions, goals, steps, tasks, analysis docs) by interpolating templates
- Location: `skills/*/templates/` subdirectories
- Contains:
  - `skills/onboard/templates/vision-template.md` -- Template for VISION.md
  - `skills/blueprint/templates/goal-template.md`, `step-template.md`, `task-template.md` -- Templates for gameplan artifacts
  - `skills/onboard/templates/codebase/ARCHITECTURE.md`, `STACK.md`, etc. -- Templates for codebase analysis documents
  - `skills/brainstorm/templates/` -- Templates for brainstorm sessions
- Depends on: Nothing (are reusable templates)
- Used by: Skills populate these templates and write filled-in versions to `.director/` or directly to files

**Scripting & Hooks Layer:**
- Purpose: Lifecycle hooks and utility scripts that integrate with Claude Code runtime
- Location: `scripts/` and `hooks/`
- Contains:
  - `scripts/init-director.sh` -- Initializes `.director/` structure on first run
  - `scripts/session-start.sh` -- Hook that runs at Claude Code session start (loads context summary)
  - `scripts/state-save.sh` -- Hook that runs at session end (saves progress)
  - `scripts/self-check.sh` -- Validates plugin integrity
  - `hooks/hooks.json` -- Registers SessionStart and SessionEnd hooks
- Depends on: Nothing (bash utilities)
- Used by: Skills invoke scripts; Claude Code runtime invokes hooks at session boundaries

## Data Flow

**Onboarding Flow:**

1. User runs `/director:onboard` (invokes `skills/onboard/SKILL.md`)
2. Onboard skill determines if project is new (greenfield) or existing (brownfield)
3. If brownfield: spawn 4 deep mapper agents in parallel (one per focus area: tech, arch, quality, concerns) to analyze codebase → write `STACK.md`, `ARCHITECTURE.md`, etc. to `.director/codebase/`
4. If greenfield or after mapping: spawn interviewer agent to ask user questions conversationally → collect responses
5. Onboard skill synthesizes responses + codebase analysis into VISION.md → write to `.director/VISION.md`
6. Onboard skill spawns 4 researchers in parallel to investigate domain/ecosystem → produce research summaries
7. Onboard skill shows user results, asks if they want to create gameplan next

**Blueprint (Planning) Flow:**

1. User runs `/director:blueprint` (invokes `skills/blueprint/SKILL.md`)
2. Blueprint skill reads VISION.md + existing GAMEPLAN.md (if any)
3. Blueprint skill checks for [UNCLEAR] markers in vision; prompts user to resolve ambiguities if present
4. Blueprint skill spawns planner agent with vision → planner generates Goals > Steps > Tasks hierarchy
5. Blueprint skill spawns researcher agent to investigate each step's domain (what libraries exist, what are common patterns)
6. Blueprint skill writes GAMEPLAN.md + goal/step/task files to `.director/goals/` tree
7. Build skill uses this structure to filter ready work (tasks with dependencies met)

**Build (Execution) Flow:**

1. User runs `/director:build` (invokes `skills/build/SKILL.md`)
2. Build skill scans `.director/goals/*/NN-step-slug/tasks/` for next ready task (first task with no unmet dependencies)
3. Build skill reads task file + current step + vision + recent git history
4. Build skill spawns builder agent with assembled context (wrapped in XML tags)
5. Builder writes code, creates commit
6. Builder spawns verifier sub-agent to check for stubs/placeholders/wiring issues
7. Builder spawns syncer sub-agent to update `.director/` docs (mark task `.done.md`, update STATE.md progress)
8. Build skill displays results to user

**Verification (Inspection) Flow:**

1. User runs `/director:inspect` (invokes `skills/inspect/SKILL.md`)
2. Inspect skill determines scope: current task, current step, current goal, or entire project
3. Inspect skill reads relevant completed tasks + their acceptance criteria
4. Inspect skill spawns verifier agent to check code against criteria
5. Verifier reads actual files, runs tests if present, checks for integration wiring
6. Inspect skill displays results to user

**Refresh (Re-scan) Flow:**

1. User runs `/director:refresh` (invokes `skills/refresh/SKILL.md`)
2. Refresh skill spawns mapper agent to do quick scan of codebase (detect new files, breaking changes)
3. Mapper agent updates `.director/codebase/` analysis docs with new findings
4. Mapper agent updates STATE.md to flag staleness warnings if major changes detected

**State Management:**

- Follow the event-log pattern in `scripts/state-save.sh` and syncer agent logic (`agents/director-syncer.md`)
- STATE.md is the only mutable document tracking progress; it's updated by syncer after each task
- Task completion is tracked two ways: (1) rename task file to `.done.md` in filesystem, (2) update STATE.md progress section
- All agents read from `.director/` to understand context but only syncer writes to STATE.md (to avoid conflicts)

## Key Abstractions

**Skill:**
- Purpose: Represents a command (`/director:onboard`, `/director:build`, etc.) and its workflow
- Examples: `skills/onboard/SKILL.md`, `skills/build/SKILL.md`, `skills/inspect/SKILL.md`
- Pattern: Each SKILL.md file is a numbered step-by-step workflow that (1) checks prerequisites, (2) routes to different paths, (3) spawns agents, (4) assembles context, (5) presents results. Skills are the orchestration layer; they call agents to do the actual work.
- Follow this pattern when creating new commands: check state, route on conditions, spawn agents with fresh context, aggregate results

**Agent:**
- Purpose: Specialized AI worker with specific responsibilities, tools, and instructions
- Examples: `agents/director-builder.md` (writes code), `agents/director-verifier.md` (checks code), `agents/director-syncer.md` (updates docs)
- Pattern: Each agent `.md` file defines role, context assumptions, tools available, execution rules, and sub-agents it can spawn. Agents receive fresh context each invocation.
- Follow this pattern when adding new agent types: define clear role boundaries, specify required context in XML tags, document tools and execution rules, note which sub-agents it can spawn

**Goal / Step / Task:**
- Purpose: Decompose vision into executable work hierarchy
- Examples: Goal: "MVP" > Step: "Authentication" > Task: "Implement login form"
- Pattern: Each level is a markdown file in `.director/goals/NN-goal-slug/NN-step-slug/tasks/NN-task-slug.md`. Completion tracked by renaming to `.done.md`. Builder uses these files as task specification; verifier checks them as acceptance criteria.
- Follow this pattern when planning work: break vision into goals, each goal into steps, each step into small tasks with clear "Done When" criteria

**Context Assembly:**
- Purpose: Gather relevant state information and wrap it for agent consumption
- Pattern: Skills read multiple files (VISION.md, GAMEPLAN.md, task files, git history) and assemble them with XML boundary tags. This creates a portable context package that can be passed to any agent. The agent expects specific tags and reads only what it needs.
- Follow this pattern when spawning agents: load vision first, then add task/step/goal context, add recent history, add relevant config or decisions, wrap each section in XML tags, pass to agent

**Marker-Based Templating:**
- Purpose: Detect template vs. real content by scanning for placeholder markers
- Pattern: Onboard and blueprint skills detect whether docs are still templates by looking for these markers:
  - VISION.md template: `> This file will be populated when you run /director:onboard` or headings with no content
  - GAMEPLAN.md template: `_No goals defined yet_` or `This file will be populated when you run /director:blueprint`
- Follow this pattern: always include explicit template placeholders that skills can detect programmatically

## Entry Points

**User-Facing Commands (14 total):**
- Location: `skills/*/SKILL.md` (14 directories)
- Triggers: User types `/director:command` in Claude Code
- Responsibilities: Orchestrate multi-step workflow, spawn agents, assemble context, present results to user
- List: onboard, blueprint, build, inspect, quick, status, resume, pivot, brainstorm, idea, ideas, refresh, undo, help

**Session Start Hook:**
- Location: `scripts/session-start.sh` and registered in `hooks/hooks.json` as SessionStart hook
- Triggers: Claude Code session starts (user opens Claude Code)
- Responsibilities: Check if Director project exists, load context summary, display status
- See: `skills/resume/SKILL.md` for related resume command that resumes a project after a break

**Session End Hook:**
- Location: `scripts/state-save.sh` and registered in `hooks/hooks.json` as SessionEnd hook
- Triggers: Claude Code session ends (user closes Claude Code or long idle)
- Responsibilities: Persist any uncommitted progress, save state snapshots

**Plugin Initialization:**
- Location: `scripts/init-director.sh`
- Triggers: First run of any Director command when `.director/` does not exist
- Responsibilities: Create `.director/` directory structure, generate template VISION.md, GAMEPLAN.md, STATE.md, config.json, create goals/ and codebase/ subdirectories

## Error Handling

**Strategy:** Progressive disclosure of issues to the user. Skills detect problems at routing steps and show diagnostic messages before attempting work.

**Patterns:**

- **Missing prerequisites** -- If user runs `/director:build` without a vision, build skill detects this and shows:
  > "We're not ready to build yet -- you need to define what you're building first. Want to start with `/director:onboard`?"
  See `skills/build/SKILL.md` steps 1-3 for routing logic.

- **Blocked dependencies** -- If next task has unmet dependencies, build skill detects and shows:
  > "The next tasks need [description] first. Here's what's complete and what's waiting:"
  See `skills/build/SKILL.md` step 4c for edge case handling.

- **Verification failures** -- If builder spawns verifier and it finds issues, builder shows them to user for human judgment:
  > "Verification found N issues: [list of issues with severity, location, type (auto-fixable vs. needs input)]"
  See `agents/director-builder.md` "Verification Status" section.

- **Ambiguous vision** -- If vision has [UNCLEAR] markers, blueprint skill prompts user before planning:
  > "Before we plan, I noticed some open questions in your vision: [list] Want to resolve these now?"
  See `skills/blueprint/SKILL.md` "Check for Open Questions" section.

## Cross-Cutting Concerns

**Language & Terminology:**

Use Director vocabulary in all user-facing output:
- Say "Goal / Step / Task" -- never "phase", "sprint", "epic", "ticket", "milestone"
- Say "Project" -- never "repository"
- Say "Vision" / "Gameplan" / "Launch" -- never "spec", "roadmap", "deploy"
- Say "Progress saved" -- never mention commits, branches, SHAs, or git details

Target vibe coders (solo builders, non-engineers), so avoid jargon:
- No "dependencies", "artifact wiring", "integration testing", "worktrees"
- Say "needs X first", not "has dependency on" or "blocked by"
- Could someone who has never written code understand this? If not, rewrite.

See `reference/plain-language-guide.md` and `reference/terminology.md` for detailed guidelines.

**Context Management:**

Design principle: Fresh AI context per task to prevent degradation.

- Each agent gets a clean workspace with only the context it needs
- No accumulated conversation history carried between invocations
- Context is assembled dynamically by skills from `.director/` state files
- Vision is always loaded (source of truth for what's being built)
- Relevant history is included (recent git commits, previous steps)
- Decisions from users (locked/flexible/deferred) are passed to builder

See `reference/context-management.md` for detailed patterns and token budgets.

**Git & Commits:**

Design principle: Atomic commits per task for independent revertability.

- Builder creates exactly one commit when task is done
- Commit message is plain-language description of what was built (not how)
- Builder never mentions git, commits, or SHAs to user -- skill handles all git messaging
- User sees "Progress saved" (handled by build skill), not commit SHA
- Syncer renames task file to `.done.md` to mark completion (file system is ground truth)

See `agents/director-builder.md` "Git Rules" section.

**Verification & Quality Gates:**

Three-tier strategy:
- **Tier 1 (Structural):** Automated, runs after every task. Builder spawns verifier to check for stubs, TODOs, orphaned files, wiring issues. No test framework needed.
- **Tier 2 (Behavioral):** Plain-language checklists. User confirms acceptance criteria at step/goal boundaries via `/director:inspect`.
- **Tier 3 (Automated):** Optional, if user has Vitest/Jest/pytest. Director integrates with test frameworks but never requires them.

See `reference/verification-patterns.md` for detailed patterns.

**Staleness Detection:**

Codebase analysis becomes stale after major changes. Manager agent (`director-mapper.md`) can detect this during `/director:refresh`. If breaking changes detected:

- Alert user: "Your codebase has changed significantly. Want to run a deep re-scan to update my understanding?"
- Update `.director/codebase/` analysis documents to reflect new state
- Update STATE.md to flag staleness so future agents are aware

## Quality Gate

Before considering this file complete, verify:
- [x] Every finding includes at least one file path in backticks
- [x] Voice is prescriptive ("Use X", "Place files in Y") not descriptive ("X is used")
- [x] No section left empty -- use "Not detected" or "Not applicable"
- [x] Layers documented with file paths
- [x] Data flow described with file references
- [x] Entry points listed with paths
