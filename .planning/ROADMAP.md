# Roadmap: Director

## Overview

Director delivers a complete vibe coding workflow in 11 phases, starting with the plugin foundation and progressing through each layer of the core loop (onboard, plan, build, verify), then adding progress tracking, lightweight escape hatches (quick mode, idea capture), heavy context-aware workflows (pivot, brainstorm), command intelligence polish, distribution, and a landing page. Each phase delivers a coherent, independently verifiable capability that builds on the previous phase. The full roadmap covers 88 v1 requirements.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [x] **Phase 1: Plugin Foundation** - Plugin manifest, folder structure, agent/command registration, templates, and configuration
- [x] **Phase 2: Onboarding** - Interview-based project setup that generates VISION.md for new and existing projects
- [x] **Phase 3: Planning** - Gameplan creation that breaks vision into Goals, Steps, and Tasks with dependencies
- [x] **Phase 4: Execution** - Fresh-context task execution with atomic commits and documentation sync
- [x] **Phase 5: Verification** - Three-tier verification: structural code reading, behavioral checklists, and auto-fix
- [x] **Phase 6: Progress & Continuity** - Status display, state persistence, session resume, and cost tracking
- [x] **Phase 7: Quick Mode & Ideas** - Lightweight escape hatches for small changes and idea capture
- [x] **Phase 7.1: User Decisions Context** - Decisions artifact in STEP.md flows into builder context (INSERTED)
- [x] **Phase 8: Pivot & Brainstorm** - Context-heavy workflows for requirement changes and open-ended exploration
- [x] **Phase 9: Command Intelligence** - Context-aware routing, error handling, terminology enforcement, help, and undo
- [x] **Phase 10: Distribution** - Self-hosted plugin marketplace, installation flow, and versioning
- [x] **Phase 11: Landing Page** - Design and create the director.cc homepage

## Phase Details

### Phase 1: Plugin Foundation
**Goal**: Director exists as a valid Claude Code plugin that creates project structure and registers all commands and agents
**Depends on**: Nothing (first phase)
**Requirements**: PLUG-01, PLUG-02, PLUG-03, PLUG-04, PLUG-05, PLUG-06, PLUG-07, PLUG-08, PLUG-09, PLUG-10
**Success Criteria** (what must be TRUE):
  1. Running `/director:help` in Claude Code shows Director is loaded and lists available commands
  2. Running `/director:onboard` on a fresh project creates the `.director/` folder with all expected files (VISION.md, GAMEPLAN.md, STATE.md, IDEAS.md, config.json, brainstorms/, goals/)
  3. Config.json contains sensible defaults and the user did not have to edit any configuration file
  4. All ~8 agent definitions exist and are loadable by Claude Code (interviewer, planner, researcher, mapper, builder, verifier, debugger, syncer)
  5. All artifact templates produce well-structured Markdown when rendered, and XML boundary tags are present in agent context assembly but invisible to users
**Plans**: 7 plans

Plans:
- [x] 01-01-PLAN.md -- Plugin manifest, init script, hooks, and plugin CLAUDE.md
- [x] 01-02-PLAN.md -- Reference docs (terminology, plain-language, verification, context management)
- [x] 01-03-PLAN.md -- Help skill (functional) + onboard and blueprint skills with templates
- [x] 01-04-PLAN.md -- Remaining 8 skills (build, quick, inspect, status, resume, brainstorm, pivot, idea)
- [x] 01-05-PLAN.md -- Agents: interviewer, planner, researcher, mapper
- [x] 01-06-PLAN.md -- Agents: builder, verifier, debugger, syncer
- [x] 01-07-PLAN.md -- Marketplace manifest + integration verification

### Phase 2: Onboarding
**Goal**: Users can go from zero to a complete Vision document through a guided, adaptive interview -- for both new and existing projects
**Depends on**: Phase 1
**Requirements**: ONBR-01, ONBR-02, ONBR-03, ONBR-04, ONBR-05, ONBR-06, ONBR-07, ONBR-08, ONBR-09, ONBR-10, ONBR-11
**Success Criteria** (what must be TRUE):
  1. Running `/director:onboard` on a new project asks questions one at a time (multiple choice when possible) and surfaces decisions the user has not considered (auth, hosting, data storage, tech stack)
  2. The interview adapts -- it skips questions the user has already answered and gauges preparation level
  3. Ambiguous answers are flagged with `[UNCLEAR]` markers and clarified before proceeding
  4. After the interview completes, `.director/VISION.md` exists with a plain-language summary of project purpose, target users, key features, tech stack, deployment plan, and success criteria
  5. Running `/director:onboard` on an existing codebase maps the project (architecture, tech stack, file structure) and presents findings in plain language with delta format for desired changes
**Plans**: 2 plans

Plans:
- [x] 02-01-PLAN.md -- Greenfield onboarding: detection, adaptive interview, VISION.md generation
- [x] 02-02-PLAN.md -- Brownfield onboarding: mapper spawning, findings presentation, delta-format vision

### Phase 3: Planning
**Goal**: Users have a complete, reviewable gameplan that breaks their vision into ordered Goals, Steps, and Tasks with dependency awareness
**Depends on**: Phase 2
**Requirements**: PLAN-01, PLAN-02, PLAN-03, PLAN-04, PLAN-05, PLAN-06, PLAN-07, PLAN-08, PLAN-09
**Success Criteria** (what must be TRUE):
  1. Running `/director:blueprint` reads VISION.md and produces a hierarchy of Goals, Steps, and Tasks stored in `.director/GAMEPLAN.md` and the `goals/` directory
  2. Each Task has a plain-language description, why it matters, complexity indicator (small/medium/large), verification criteria, and dependencies expressed as capabilities ("needs user authentication")
  3. The gameplan is presented to the user for review before any execution begins
  4. Running `/director:blueprint` on an existing gameplan updates it rather than replacing it
  5. Running `/director:blueprint "add payment processing"` uses the inline text to focus the update
**Plans**: 2 plans

Plans:
- [x] 03-01-PLAN.md -- Blueprint skill rewrite: new gameplan creation with two-phase conversation flow
- [x] 03-02-PLAN.md -- Blueprint update mode with delta summary and inline context support

### Phase 4: Execution
**Goal**: Users can build their project one task at a time, with each task getting fresh AI context, producing an atomic commit, and keeping documentation in sync
**Depends on**: Phase 3
**Requirements**: EXEC-01, EXEC-02, EXEC-03, EXEC-04, EXEC-05, EXEC-06, EXEC-07, EXEC-08, EXEC-09
**Success Criteria** (what must be TRUE):
  1. Running `/director:build` identifies the next ready task and executes it in a fresh agent window loaded with VISION.md, relevant STEP.md, the task file, and recent git history
  2. Each completed task produces exactly one git commit, and the user sees "Progress saved. You can type `/director:undo` to go back." instead of any git jargon
  3. After each task completes, a documentation sync agent checks `.director/` docs against codebase state and reports what was built in plain language
  4. The builder agent can spawn sub-agents for research, exploration, and verification within a single task
  5. Documentation sync catches changes made outside Director's workflow
**Plans**: 2 plans

Plans:
- [x] 04-01-PLAN.md -- Agent updates: builder gets researcher tool, syncer gets .done.md rename and amend-commit awareness
- [x] 04-02-PLAN.md -- Build skill rewrite: complete 10-step execution pipeline (routing, task selection, context assembly, builder spawning, atomic commit, doc sync, post-task summary)

### Phase 5: Verification
**Goal**: Users can trust that what was built actually works -- through automatic structural checks, guided behavioral testing, and auto-fix for issues found
**Depends on**: Phase 4
**Requirements**: VRFY-01, VRFY-02, VRFY-03, VRFY-04, VRFY-05, VRFY-06, VRFY-07, VRFY-08, VRFY-09, VRFY-10, VRFY-11
**Success Criteria** (what must be TRUE):
  1. After every task, Tier 1 structural verification automatically runs -- AI reads code checking that files exist, contain real implementation (not stubs/placeholders/TODOs), and are wired together (no orphaned files)
  2. Tier 1 is invisible unless issues are found, in which case it reports in plain language: "The login page was created but it's not connected to anything yet. Want me to fix this?"
  3. At step and goal boundaries, Tier 2 behavioral verification generates a plain-language checklist the user works through ("Try logging in with a wrong password. What happens?")
  4. When issues are found, Director spawns debugger agents to investigate and create fix plans, retrying up to 3-5 cycles before stopping and explaining what needs manual attention
  5. Running `/director:inspect` triggers full verification on demand, and passing verification celebrates progress ("Step 2 is complete! You're 3 of 5 steps through your first goal.")
**Plans**: 3 plans

Plans:
- [x] 05-01-PLAN.md -- Agent output updates: builder verification status, verifier auto-fixable classification, debugger status consistency
- [x] 05-02-PLAN.md -- Build skill post-task verification flow: issue surfacing, auto-fix retry loop, boundary detection, Tier 2 checklists
- [x] 05-03-PLAN.md -- Inspect skill rewrite: scope-aware on-demand verification with Tier 1, Tier 2, auto-fix, and celebration

### Phase 6: Progress & Continuity
**Goal**: Users always know where they are, what happened, and what is next -- even after closing their terminal and coming back days later
**Depends on**: Phase 4
**Requirements**: PROG-01, PROG-02, PROG-03, PROG-04, PROG-05, PROG-06, PROG-07, PROG-08, PROG-09
**Success Criteria** (what must be TRUE):
  1. Running `/director:status` shows progress at goal level ("Goal 1: 4 of 6 steps complete"), step level ("Step 2: 3 of 7 tasks complete"), and task level (Ready / In Progress / Complete / Needs Attention)
  2. Status shows what is ready to work on next and what is blocked, with plain-language reasons for blocks ("Needs user authentication first")
  3. State persists automatically to `.director/STATE.md` -- no explicit pause command needed
  4. Running `/director:resume` after any break reads project state and responds in plain language: "Welcome back. Last time, you finished building the login page. Next up: the user profile page."
  5. API cost tracking is visible per goal, step, and task
**Plans**: 4 plans

Plans:
- [x] 06-01-PLAN.md -- STATE.md format redesign, session lifecycle hooks, and config updates
- [x] 06-02-PLAN.md -- Syncer expansion for rich STATE.md management and cost tracking
- [x] 06-03-PLAN.md -- Status skill rewrite with progress bars, step counts, and cost display
- [x] 06-04-PLAN.md -- Resume skill rewrite with context restoration and external change detection

### Phase 7: Quick Mode & Ideas
**Goal**: Users can make small changes without full planning and capture ideas without interrupting their flow
**Depends on**: Phase 4
**Requirements**: FLEX-01, FLEX-02, FLEX-03, FLEX-10, FLEX-11, FLEX-12
**Success Criteria** (what must be TRUE):
  1. Running `/director:quick "change the button color to blue"` executes the change immediately with an atomic commit and documentation sync, no planning workflow required
  2. Quick mode analyzes complexity before executing -- if the request is too complex, it recommends switching to guided mode instead of proceeding
  3. Running `/director:idea "add dark mode support"` saves the idea to `.director/IDEAS.md` instantly, separate from the active gameplan
  4. When the user decides to act on a saved idea, Director analyzes complexity and routes appropriately: quick task, needs planning, or too complex for now
**Plans**: 3 plans

Plans:
- [x] 07-01-PLAN.md -- Quick skill rewrite: scope-based complexity analysis and full execution pipeline with [quick] commits
- [x] 07-02-PLAN.md -- Idea capture rewrite: newest-first insertion in IDEAS.md and init script template update
- [x] 07-03-PLAN.md -- Ideas viewer skill: numbered display, conversational routing, and idea removal

### Phase 7.1: User Decisions Context (INSERTED)
**Goal**: When a task executes in a fresh agent window, the builder knows what the user decided, what it can decide on its own, and what's out of scope -- without needing the original conversation
**Depends on**: Phase 7
**Requirements**: None (gap closure -- no new FLEX/CMDI requirements, modifies existing artifacts)
**Success Criteria** (what must be TRUE):
  1. STEP.md includes a Decisions section with three categories: Locked (user explicitly decided -- non-negotiable), Flexible (AI can decide -- user has no preference), and Deferred (out of scope for this step)
  2. The build skill's context assembly includes decisions from the current step's STEP.md, wrapped in XML boundary tags, with instructions for the builder to honor Locked, exercise judgment on Flexible, and ignore Deferred
  3. Blueprint skill captures user decisions at step granularity during the planning conversation, flowing preferences about implementation approach, tech choices, and design direction into relevant STEP.md Decisions sections
  4. Backward-compatible -- if STEP.md has no Decisions section, the build skill skips it gracefully with no errors
**Plans**: 3 plans

Plans:
- [x] 07.1-01-PLAN.md -- STEP.md template update with Decisions section, builder agent and context reference updates
- [x] 07.1-02-PLAN.md -- Build skill context assembly update with decisions extraction and loading
- [x] 07.1-03-PLAN.md -- Blueprint skill decision capture and planner agent awareness

### Phase 8: Pivot & Brainstorm
**Goal**: Users can change direction mid-project without losing valid work, and explore ideas freely with full project context
**Depends on**: Phase 4
**Requirements**: FLEX-04, FLEX-05, FLEX-06, FLEX-07, FLEX-08, FLEX-09, FLEX-13, FLEX-14, FLEX-15, FLEX-16, FLEX-17
**Success Criteria** (what must be TRUE):
  1. Running `/director:pivot` starts a focused conversation about what changed, maps the current codebase against the new direction, and generates an updated gameplan that supersedes the old one
  2. Pivot uses delta format in plain language ("3 tasks no longer needed, 2 new tasks required, everything else stays the same") and preserves completed work that is still relevant
  3. All relevant documentation (VISION.md, GAMEPLAN.md, architecture docs) is updated by pivot
  4. Running `/director:brainstorm` loads full project context (VISION.md, GAMEPLAN.md, STATE.md, codebase awareness) and explores ideas one question at a time with multiple choice when possible
  5. At the end of a brainstorm, Director suggests the appropriate next action (save idea, create task, trigger pivot, or just save conversation) and saves the session to `.director/brainstorms/YYYY-MM-DD-<topic>.md`
**Plans**: 7 plans

Plans:
- [x] 08-01-PLAN.md -- Pivot conversation flow: init routing, direction capture, scope detection
- [x] 08-02-PLAN.md -- Pivot state assessment: in-progress work check, conditional mapper spawning
- [x] 08-03-PLAN.md -- Pivot impact analysis: gameplan classification, delta summary, approval gate
- [x] 08-04-PLAN.md -- Pivot apply changes: doc updates, file operations, STATE.md, wrap-up
- [x] 08-05-PLAN.md -- Brainstorm template update, init, context loading, session open
- [x] 08-06-PLAN.md -- Brainstorm exploration loop: adaptive context loading, code awareness
- [x] 08-07-PLAN.md -- Brainstorm session save, exit routing, IDEAS.md integration

### Phase 9: Command Intelligence
**Goal**: Every command is smart about project state -- it redirects when invoked out of sequence, speaks plain English, and provides undo capability
**Depends on**: Phases 2, 3, 4, 5, 6, 7, 8
**Requirements**: CMDI-01, CMDI-02, CMDI-03, CMDI-04, CMDI-05, CMDI-06, CMDI-07, CMDI-08, CMDI-09
**Success Criteria** (what must be TRUE):
  1. Running `/director:build` with no `.director/` folder routes the user to onboard instead of failing; running `/director:onboard` on an already-onboarded project shows status and suggests the next action
  2. Every command accepts optional inline text to focus or accelerate the interaction (e.g., `/director:build "focus on the signup form"`)
  3. All error messages use plain language with what went wrong, why, and what to do next -- never blaming the user, never using jargon
  4. Director uses its own terminology throughout (Goal, Step, Task, Vision, Gameplan, Launch, "Needs X first") and never leaks developer jargon
  5. Running `/director:undo` reverts the last task's commit, shown as "Going back to before that task"
**Plans**: 3 plans

Plans:
- [x] 09-01-PLAN.md -- Undo skill creation and help skill update with all 12 commands + topic-specific mode
- [x] 09-02-PLAN.md -- Routing audit and standardization across key-entry commands (build, blueprint, inspect, pivot, onboard)
- [x] 09-03-PLAN.md -- Inline text for resume, error messaging audit, and terminology reference updates

### Phase 10: Distribution
**Goal**: Users can discover, install, and update Director through Claude Code's plugin marketplace
**Depends on**: Phase 9
**Requirements**: DIST-01, DIST-02, DIST-03
**Success Criteria** (what must be TRUE):
  1. A self-hosted plugin marketplace exists with a valid `marketplace.json` manifest
  2. A user can add the marketplace URL in Claude Code and install Director as a plugin without manual file copying
  3. Plugin updates are versioned and users can update to the latest version through Claude Code's plugin system
**Plans**: 3 plans

Plans:
- [x] 10-01-PLAN.md -- Marketplace manifest fix (correct schema and location) and version bump to 1.0.0
- [x] 10-02-PLAN.md -- Self-check script and session-start update notification
- [x] 10-03-PLAN.md -- README rewrite as install-focused landing page

### Phase 11: Landing Page
**Goal**: director.cc has a compelling landing page that communicates what Director is, who it's for, and how to get started
**Depends on**: Phase 10
**Plans**: 3 plans

Plans:
- [x] 11-01-PLAN.md -- Site foundation (directory structure, assets, design system) and hero section with sticky navigation
- [x] 11-02-PLAN.md -- Content sections: Problem, terminal walkthrough animation, Features, Why Director, Commands
- [x] 11-03-PLAN.md -- Bottom sections (Get Started CTA, newsletter, footer), scroll behaviors, deployment workflow

## Progress

**Execution Order:**
Phases execute in numeric order: 1 -> 2 -> 3 -> 4 -> 5 -> 6 -> 7 -> 7.1 -> 8 -> 9 -> 10 -> 11

Note: Phases 5, 6, 7, and 8 all depend on Phase 4 and can potentially be worked in parallel. Phase 7.1 depends on Phase 7 (needs blueprint and build skills functional). Phase 9 depends on all command phases (2-8). Phase 10 depends on Phase 9. Phase 11 depends on Phase 10.

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Plugin Foundation | 7/7 | Complete | 2026-02-08 |
| 2. Onboarding | 2/2 | Complete | 2026-02-08 |
| 3. Planning | 2/2 | Complete | 2026-02-08 |
| 4. Execution | 2/2 | Complete | 2026-02-08 |
| 5. Verification | 3/3 | Complete | 2026-02-08 |
| 6. Progress & Continuity | 4/4 | Complete | 2026-02-08 |
| 7. Quick Mode & Ideas | 3/3 | Complete | 2026-02-08 |
| 7.1. User Decisions Context | 3/3 | Complete | 2026-02-09 |
| 8. Pivot & Brainstorm | 7/7 | Complete | 2026-02-09 |
| 9. Command Intelligence | 3/3 | Complete | 2026-02-09 |
| 10. Distribution | 3/3 | Complete | 2026-02-09 |
| 11. Landing Page | 3/3 | Complete | 2026-02-09 |

---
*Roadmap created: 2026-02-07*
*Last updated: 2026-02-09 -- Completed 11-03 (bottom sections, deployment) -- All phases complete*
