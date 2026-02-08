# Requirements: Director

**Defined:** 2026-02-07
**Core Value:** Vibe coders can go from idea to working product through a guided, plain-language workflow (Blueprint / Build / Inspect) that gives them professional development structure without requiring them to think like a developer.

## v1 Requirements

Requirements for initial release. Each maps to roadmap phases.

### Plugin Foundation

- [ ] **PLUG-01**: Plugin manifest registers Director with Claude Code (name, version, description, command prefix `/director`)
- [ ] **PLUG-02**: Plugin creates `.director/` folder structure on initialization (VISION.md, GAMEPLAN.md, STATE.md, IDEAS.md, config.json, brainstorms/, goals/)
- [ ] **PLUG-03**: Plugin initializes Git repo if none exists, abstracted behind "Progress saved" language
- [ ] **PLUG-04**: Plugin stores configuration in `.director/config.json` with sensible defaults (guided mode, tips on, max 3 retry cycles, cost tracking on)
- [ ] **PLUG-05**: Plugin registers ~11 slash commands under `/director:` prefix
- [ ] **PLUG-06**: Plugin registers ~8 specialized agents (interviewer, planner, researcher, mapper, builder, verifier, debugger, syncer)
- [ ] **PLUG-07**: Plugin includes templates for all `.director/` artifacts (VISION.md, STEP.md, GOAL.md, task files, etc.)
- [ ] **PLUG-08**: Plugin includes reference docs loaded into agent context (terminology, verification patterns, plain-language guidelines)
- [ ] **PLUG-09**: Plugin uses hybrid formatting — Markdown user-facing, XML boundary tags at agent context assembly, JSON for machine state
- [ ] **PLUG-10**: Plugin is installable via self-hosted plugin marketplace

### Onboarding

- [ ] **ONBR-01**: `/director:onboard` detects whether project is new or existing
- [ ] **ONBR-02**: For new projects, conducts structured interview one question at a time, multiple choice when possible
- [ ] **ONBR-03**: Interview adapts questions based on previous answers (doesn't ask about deployment framework if user already chose one)
- [ ] **ONBR-04**: Interview surfaces decisions the user may not have considered (authentication, deployment target, tech stack, data storage)
- [ ] **ONBR-05**: Interview gauges how much preparation the user has already done
- [ ] **ONBR-06**: Uses `[UNCLEAR]` markers for ambiguous answers, flags for clarification before proceeding
- [ ] **ONBR-07**: Generates VISION.md — plain-language summary of project purpose, target users, key features, tech stack, deployment plan, success criteria
- [ ] **ONBR-08**: For existing projects, spawns parallel sub-agents to map codebase (architecture, tech stack, file structure, concerns)
- [ ] **ONBR-09**: For existing projects, presents mapping findings in plain language
- [ ] **ONBR-10**: For existing projects, uses delta format (ADDED/MODIFIED/REMOVED) for desired changes
- [ ] **ONBR-11**: Initializes project structure (`.director/` folder, Git repo, initial config)

### Planning

- [ ] **PLAN-01**: `/director:blueprint` reads VISION.md and breaks the vision into Goals (major milestones like v1, v2)
- [ ] **PLAN-02**: Each Goal is broken into Steps ordered by dependencies ("Needs X first")
- [ ] **PLAN-03**: Each Step generates specific, actionable Tasks
- [ ] **PLAN-04**: Each Task includes: plain-language description, why it matters, complexity indicator (small/medium/large), verification criteria, dependencies
- [ ] **PLAN-05**: Ready-work filtering shows only tasks where all dependencies are satisfied
- [ ] **PLAN-06**: Gameplan is presented for user review before execution begins
- [ ] **PLAN-07**: Gameplan is stored at `.director/GAMEPLAN.md`
- [ ] **PLAN-08**: `/director:blueprint` can update existing gameplan (not just create new ones)
- [ ] **PLAN-09**: Inline context support — `/director:blueprint "add payment processing"` focuses the update

### Execution

- [ ] **EXEC-01**: `/director:build` identifies the next ready task (all dependencies satisfied)
- [ ] **EXEC-02**: Each task gets a fresh AI agent window with targeted context (VISION.md, relevant STEP.md, task file, recent git history)
- [ ] **EXEC-03**: Context is assembled with XML boundary tags for AI parsing accuracy (invisible to user)
- [ ] **EXEC-04**: Each task produces exactly one atomic git commit, independently revertable
- [ ] **EXEC-05**: Git operations shown as "Progress saved. You can type `/director:undo` to go back."
- [ ] **EXEC-06**: After each task, documentation sync agent verifies `.director/` docs match codebase state
- [ ] **EXEC-07**: Documentation sync catches changes made outside Director's workflow
- [ ] **EXEC-08**: After each task, reports what was built in plain language
- [ ] **EXEC-09**: Lead agent can spawn sub-agents for research, exploration, and verification within a task

### Verification

- [ ] **VRFY-01**: Tier 1 structural verification runs after every task — AI reads code checking files exist, contain real implementation, and are wired together
- [ ] **VRFY-02**: Tier 1 detects stubs and placeholders (TODO comments, empty returns, placeholder text, components that render nothing, hardcoded data)
- [ ] **VRFY-03**: Tier 1 detects orphaned code (files that exist but aren't imported or used)
- [ ] **VRFY-04**: Tier 1 is invisible to user unless issues found — "The login page was created but it's not connected to anything yet. Want me to fix this?"
- [ ] **VRFY-05**: Tier 2 behavioral verification runs at step/goal boundaries — generates plain-language acceptance criteria checklist
- [ ] **VRFY-06**: Tier 2 checklist format — user tries things and reports back ("Try logging in with a wrong password. What happens?")
- [ ] **VRFY-07**: When issues found, explains what went wrong in plain language, never blames user, suggests clear next action
- [ ] **VRFY-08**: Auto-fix capability — spawns debugger agents to investigate and create fix plans
- [ ] **VRFY-09**: Maximum 3-5 retry cycles before stopping and explaining what needs manual attention
- [ ] **VRFY-10**: `/director:inspect` runs full verification on demand
- [ ] **VRFY-11**: Celebrates completion when verification passes ("Step 2 is complete! You're 3 of 5 steps through your first goal.")

### Progress & Continuity

- [ ] **PROG-01**: `/director:status` shows goal progress ("Goal 1: 4 of 6 steps complete")
- [ ] **PROG-02**: `/director:status` shows step progress ("Step 2: 3 of 7 tasks complete")
- [ ] **PROG-03**: Status indicators per task: Ready / In Progress / Complete / Needs Attention
- [ ] **PROG-04**: Shows what's ready to work on next and what's blocked (with plain-language reasons)
- [ ] **PROG-05**: State stored in `.director/STATE.md` (machine-readable) with human-friendly CLI display
- [ ] **PROG-06**: API cost tracking per goal/step/task
- [ ] **PROG-07**: Automatic state persistence — no explicit pause command needed
- [ ] **PROG-08**: `/director:resume` reads project state, shows what was last completed, identifies what's next
- [ ] **PROG-09**: Plain-language resume: "Welcome back. Last time, you finished building the login page. Next up: the user profile page."

### Flexibility

- [ ] **FLEX-01**: `/director:quick "..."` executes small changes without full planning workflow
- [ ] **FLEX-02**: Quick mode analyzes complexity before executing — recommends guided mode when request is complex
- [ ] **FLEX-03**: Quick mode still uses atomic commits and documentation sync
- [ ] **FLEX-04**: `/director:pivot` starts focused conversation about what changed
- [ ] **FLEX-05**: Pivot maps current codebase against new direction
- [ ] **FLEX-06**: Pivot generates updated gameplan that supersedes the old one
- [ ] **FLEX-07**: Pivot updates all relevant documentation (VISION.md, GAMEPLAN.md, architecture docs)
- [ ] **FLEX-08**: Pivot preserves completed work that's still relevant
- [ ] **FLEX-09**: Pivot uses delta format showing impact in plain language ("3 tasks no longer needed, 2 new tasks required, everything else stays the same")
- [ ] **FLEX-10**: `/director:idea "..."` saves idea to IDEAS.md instantly
- [ ] **FLEX-11**: Ideas stored separately from active gameplan
- [ ] **FLEX-12**: When acting on an idea, Director analyzes complexity and routes: quick task, needs planning, or too complex for now
- [ ] **FLEX-13**: `/director:brainstorm` loads full project context (VISION.md, GAMEPLAN.md, STATE.md, codebase awareness)
- [ ] **FLEX-14**: Brainstorm uses one question at a time, multiple choice when possible, follows user's lead
- [ ] **FLEX-15**: Brainstorm considers impact on existing codebase and gameplan when exploring changes
- [ ] **FLEX-16**: At brainstorm end, suggests appropriate next action (save idea, create task, trigger pivot, or just save conversation)
- [ ] **FLEX-17**: Brainstorm sessions saved to `.director/brainstorms/YYYY-MM-DD-<topic>.md`

### UX & Command Intelligence

- [ ] **CMDI-01**: Context-aware routing — every command detects project state and redirects if invoked out of sequence
- [ ] **CMDI-02**: `/director:build` with no `.director/` → routes to onboard
- [ ] **CMDI-03**: `/director:onboard` on already-onboarded project → shows status, suggests next action
- [ ] **CMDI-04**: Every command accepts optional inline text to focus or accelerate the interaction
- [ ] **CMDI-05**: All error messages in plain language with what went wrong, why, and recommended action
- [ ] **CMDI-06**: Never uses jargon in user-facing output (no "artifact wiring", "dependencies", "worktrees", "integration testing")
- [ ] **CMDI-07**: Uses Director's terminology throughout (Goal, Step, Task, Vision, Gameplan, Launch, "Needs X first")
- [ ] **CMDI-08**: `/director:help` shows available commands with examples
- [ ] **CMDI-09**: `/director:undo` reverts the last task's commit, shown as "Going back to before that task"

### Distribution

- [ ] **DIST-01**: Self-hosted plugin marketplace with marketplace.json manifest
- [ ] **DIST-02**: Users can add the marketplace and install Director via Claude Code's plugin system
- [ ] **DIST-03**: Plugin versioning and update mechanism

## v2 Requirements

Deferred to future release. Tracked but not in current roadmap.

### Intelligence (Goal 2)

- **INTL-01**: Learning tips — short, contextual explanations of Director's decisions, toggleable on/off
- **INTL-02**: Research summaries with "What this means for your project" section in plain language
- **INTL-03**: Two-stage review — spec compliance first, then code quality
- **INTL-04**: Complexity-aware task breakdown — AI scores difficulty, recommends appropriate breakdown
- **INTL-05**: Smart testing integration — auto-detect existing test setups, opt-in new setup, plain-language results

### Power Features (Goal 3)

- **POWR-01**: Coordinated agent teams — multiple tasks executed in parallel by specialized teams
- **POWR-02**: Effort controls — map thinking effort to task complexity for cost optimization
- **POWR-03**: Visual web dashboard with Kanban board, progress charts, architecture diagrams
- **POWR-04**: Multi-platform support (Cursor, Codex, Gemini CLI, OpenCode)

## Out of Scope

| Feature | Reason |
|---------|--------|
| Git branch management | Single branch, linear history for v1. Vibe coders don't understand branches. |
| Git worktree management | Too technical for target audience |
| Deployment automation | Director guides deployment thinking in onboarding but doesn't execute deployment |
| Pre-built project templates | Dynamic brainstorming replaces static templates; templates go stale |
| Multi-language support | English only for v1 |
| Collaboration / multi-user | Solo vibe coder only |
| Exposing Director as MCP server | Director is a plugin, not a server; MCP exposure is future consideration |
| Local/private LLM support | Claude API only for v1 |
| Constitutional governance | Enterprise overhead, irrelevant for solo builders |
| Real-time live monitoring of agent work | Creates anxiety for non-technical users; results-only reporting is calmer |
| YAML/JSON user-facing artifacts | Vibe coders close YAML files; Markdown only for human-readable content |
| Mandatory TDD | Hostile to non-developers; three-tier verification replaces this |
| 60+ agent ecosystem | Agent sprawl creates confusion; ~8 focused agents produce more consistent results |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| PLUG-01 | Phase 1 | Pending |
| PLUG-02 | Phase 1 | Pending |
| PLUG-03 | Phase 1 | Pending |
| PLUG-04 | Phase 1 | Pending |
| PLUG-05 | Phase 1 | Pending |
| PLUG-06 | Phase 1 | Pending |
| PLUG-07 | Phase 1 | Pending |
| PLUG-08 | Phase 1 | Pending |
| PLUG-09 | Phase 1 | Pending |
| PLUG-10 | Phase 1 | Pending |
| ONBR-01 | Phase 2 | Pending |
| ONBR-02 | Phase 2 | Pending |
| ONBR-03 | Phase 2 | Pending |
| ONBR-04 | Phase 2 | Pending |
| ONBR-05 | Phase 2 | Pending |
| ONBR-06 | Phase 2 | Pending |
| ONBR-07 | Phase 2 | Pending |
| ONBR-08 | Phase 2 | Pending |
| ONBR-09 | Phase 2 | Pending |
| ONBR-10 | Phase 2 | Pending |
| ONBR-11 | Phase 2 | Pending |
| PLAN-01 | Phase 3 | Pending |
| PLAN-02 | Phase 3 | Pending |
| PLAN-03 | Phase 3 | Pending |
| PLAN-04 | Phase 3 | Pending |
| PLAN-05 | Phase 3 | Pending |
| PLAN-06 | Phase 3 | Pending |
| PLAN-07 | Phase 3 | Pending |
| PLAN-08 | Phase 3 | Pending |
| PLAN-09 | Phase 3 | Pending |
| EXEC-01 | Phase 4 | Pending |
| EXEC-02 | Phase 4 | Pending |
| EXEC-03 | Phase 4 | Pending |
| EXEC-04 | Phase 4 | Pending |
| EXEC-05 | Phase 4 | Pending |
| EXEC-06 | Phase 4 | Pending |
| EXEC-07 | Phase 4 | Pending |
| EXEC-08 | Phase 4 | Pending |
| EXEC-09 | Phase 4 | Pending |
| VRFY-01 | Phase 5 | Pending |
| VRFY-02 | Phase 5 | Pending |
| VRFY-03 | Phase 5 | Pending |
| VRFY-04 | Phase 5 | Pending |
| VRFY-05 | Phase 5 | Pending |
| VRFY-06 | Phase 5 | Pending |
| VRFY-07 | Phase 5 | Pending |
| VRFY-08 | Phase 5 | Pending |
| VRFY-09 | Phase 5 | Pending |
| VRFY-10 | Phase 5 | Pending |
| VRFY-11 | Phase 5 | Pending |
| PROG-01 | Phase 6 | Pending |
| PROG-02 | Phase 6 | Pending |
| PROG-03 | Phase 6 | Pending |
| PROG-04 | Phase 6 | Pending |
| PROG-05 | Phase 6 | Pending |
| PROG-06 | Phase 6 | Pending |
| PROG-07 | Phase 6 | Pending |
| PROG-08 | Phase 6 | Pending |
| PROG-09 | Phase 6 | Pending |
| FLEX-01 | Phase 7 | Pending |
| FLEX-02 | Phase 7 | Pending |
| FLEX-03 | Phase 7 | Pending |
| FLEX-04 | Phase 7 | Pending |
| FLEX-05 | Phase 7 | Pending |
| FLEX-06 | Phase 7 | Pending |
| FLEX-07 | Phase 7 | Pending |
| FLEX-08 | Phase 7 | Pending |
| FLEX-09 | Phase 7 | Pending |
| FLEX-10 | Phase 7 | Pending |
| FLEX-11 | Phase 7 | Pending |
| FLEX-12 | Phase 7 | Pending |
| FLEX-13 | Phase 7 | Pending |
| FLEX-14 | Phase 7 | Pending |
| FLEX-15 | Phase 7 | Pending |
| FLEX-16 | Phase 7 | Pending |
| FLEX-17 | Phase 7 | Pending |
| CMDI-01 | Phase 8 | Pending |
| CMDI-02 | Phase 8 | Pending |
| CMDI-03 | Phase 8 | Pending |
| CMDI-04 | Phase 8 | Pending |
| CMDI-05 | Phase 8 | Pending |
| CMDI-06 | Phase 8 | Pending |
| CMDI-07 | Phase 8 | Pending |
| CMDI-08 | Phase 8 | Pending |
| CMDI-09 | Phase 8 | Pending |
| DIST-01 | Phase 9 | Pending |
| DIST-02 | Phase 9 | Pending |
| DIST-03 | Phase 9 | Pending |

**Coverage:**
- v1 requirements: 82 total
- Mapped to phases: 82
- Unmapped: 0 ✓

---
*Requirements defined: 2026-02-07*
*Last updated: 2026-02-07 after initial definition*
