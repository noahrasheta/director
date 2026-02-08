# Director

## What This Is

Director is an opinionated, spec-driven orchestration framework for vibe coders — solo builders who use AI coding agents to bring their ideas to life. It is a Claude Code plugin (skills + slash commands + agents + hooks) that provides structure, guardrails, and workflow intelligence on top of Claude Code, turning ad-hoc AI prompting into disciplined, repeatable development. It uses the `/director` command prefix and will be distributed via a self-hosted plugin marketplace.

## Core Value

Vibe coders can go from idea to working product through a guided, plain-language workflow (Blueprint / Build / Inspect) that gives them professional development structure without requiring them to think like a developer.

## Requirements

### Validated

(None yet — ship to validate)

### Active

- [ ] Interview-based onboarding that surfaces decisions the user hasn't considered (auth, hosting, tech stack, data storage) and creates a Vision document
- [ ] Vision document generation — plain-language summary of what's being built, who it's for, what success looks like, stored as `.director/VISION.md` and loaded into every agent context
- [ ] Gameplan creation (`/director:blueprint`) — breaks vision into Goals > Steps > Tasks with dependency ordering, complexity indicators, and ready-work filtering
- [ ] Execution engine (`/director:build`) — fresh AI context per task, atomic git commits, automatic documentation sync, dependency-aware task selection
- [ ] Goal-backward verification (`/director:inspect`) — three-tier strategy: structural verification (AI reads code for stubs/orphans/wiring), behavioral checklists (user confirms features work), and debugger agent spawning for auto-fix (3-5 retry cap)
- [ ] Progress tracking (`/director:status`) — visual progress at goal/step/task level with status indicators (Ready / In Progress / Complete / Needs Attention) and API cost tracking
- [ ] Session continuity (`/director:resume`) — automatic state persistence to files, no explicit pause needed, plain-language context restoration on return
- [ ] Error handling — all errors in plain language with what went wrong, why, and recommended action; never blames the user; spawns debugger agents for complex issues
- [ ] Quick mode (`/director:quick "..."`) — fast task execution for small changes with complexity analysis that recommends guided mode when the request is too complex
- [ ] Pivot support (`/director:pivot`) — handles mid-project requirement changes by mapping codebase against new direction, updating vision/gameplan/docs, preserving valid work, using delta format (ADDED/MODIFIED/REMOVED)
- [ ] Idea capture (`/director:idea "..."`) — quick idea storage separate from active gameplan, with later analysis that routes to quick task, planned feature, or dismissal
- [ ] Brainstorming (`/director:brainstorm`) — open-ended exploration with full project context, one question at a time, routes to idea/task/pivot/nothing, sessions saved to dated files
- [ ] Context-aware command routing — every command detects project state and redirects if invoked out of sequence; no wrong door
- [ ] Inline context support — every command accepts optional text after it to focus or accelerate the interaction
- [ ] Documentation auto-sync — after every task, an agent verifies `.director/` docs match codebase state and updates any that have drifted
- [ ] `.director/` folder structure with VISION.md, GAMEPLAN.md, STATE.md, IDEAS.md, config.json, brainstorms/, and goals/ hierarchy
- [ ] Hybrid formatting — Markdown for user-facing artifacts, XML boundary tags at agent context assembly layer (invisible to users), JSON for machine state
- [ ] ~8 specialized agents (interviewer, planner, researcher, mapper, builder, verifier, debugger, syncer) orchestrated by workflows, invisible to the user
- [ ] ~11 slash commands total — simplicity is a feature
- [ ] Git integration abstracted behind plain language ("Progress saved" not commit SHAs, `/director:undo` for revertability)
- [ ] Plain-language terminology: Project > Goals > Steps > Tasks > Actions (Actions invisible to user)
- [ ] Self-hosted plugin marketplace for distribution
- [ ] Brownfield support — maps existing codebases, presents findings in plain language, infers current capabilities before asking what to change
- [ ] Sensible defaults in config.json — works out of the box with zero required configuration

### Out of Scope

- Multi-platform support (Cursor, Codex, Gemini CLI) — Claude Code only for v1; architect for portability but don't implement
- Visual web dashboard — CLI only for v1; Phase 3 feature
- Coordinated agent teams across tasks — Phase 3 feature; sub-agents within a single task ARE in MVP
- Multi-language support — English only for v1
- Pre-built project templates — dynamic brainstorming replaces static templates (user validated this preference)
- Collaboration / multi-user features — solo vibe coder only
- Automated test framework execution — MVP uses structural verification + behavioral checklists; test framework integration (Vitest/Jest/pytest) is Phase 2 and always opt-in
- Git branch management — single branch, linear history for v1
- Deployment automation — Director guides deployment thinking in onboarding but doesn't execute deployment
- Exposing Director as an MCP server — Director is a plugin, not a server; MCP server exposure is future consideration for multi-platform support
- Local/private LLM support — Claude API only for v1
- Git worktree management — not part of vibe coding workflow
- Constitutional governance / role-based access — enterprise features, irrelevant for solo vibe coders

## Context

- **Creator/primary user:** Noah Rasheta — a vibe coder who experienced the exact problems Director solves (documentation drift, lost context, architecture breaking as codebase grew, authentication migration issues from not having a thorough plan)
- **Competitive landscape:** 8 competing frameworks analyzed (GSD, OpenSpec, Beads, Autospec, Spec-Kit, Superpowers, Claude Task Master, Vibe-Kanban). All built for traditional developers. None serve vibe coders. Director occupies a unique strategic position.
- **Key patterns adopted:** Fresh agent windows per task (GSD + Autospec), goal-backward verification (GSD), delta specs (OpenSpec), ready-work filtering (Beads), interview-based vision capture (Superpowers), [UNCLEAR] markers (Spec-Kit), documentation auto-sync (Director original)
- **Build strategy:** Using GSD to build Director, then dogfood Director for its own continued development once MVP is functional
- **Existing design assets:** 7 design documents in `docs/design/` covering manifesto, full PRD, competitive analysis, brainstorm, follow-up Q&A, Opus 4.6 strategy, and user guide notes
- **Plugin marketplace docs:** https://code.claude.com/docs/en/plugin-marketplaces
- **Website:** director.cc (owned, will host documentation)
- **Noah's motivation:** Prove ability to implement AI effectively into real-world applications; build a tool that empowers non-coders; create portfolio evidence for AI leadership roles; selfishly needs it for his own pipeline of projects

## Constraints

- **Platform**: Claude Code plugin only — skills, slash commands, agents, hooks. Not a standalone app, not a web app, not an MCP server.
- **Language**: All user-facing output must be plain English. Never use jargon like "dependencies", "artifact wiring", "worktrees", or "integration testing" in anything the user sees.
- **Command budget**: ~11 slash commands total. Simplicity is a feature. Resist adding more.
- **Agent budget**: ~8 specialized agents. Orchestration handled by workflows, not by exposing every agent as a separate command.
- **Terminology**: Must use Director's own vocabulary (Goal/Step/Task/Action, Vision/Gameplan, Launch) — not developer terminology. See PRD §5 for full mapping.
- **Git**: Required, but fully abstracted. Users see "Progress saved" and undo capability, never SHAs or branch names.
- **Context strategy**: Fresh agent windows per task with targeted context loading (VISION.md + relevant STEP.md + task file + recent git history). Never accumulate full conversation history.
- **Atomic commits**: One commit per task for independent revertability.
- **Cost**: Fresh context per task should achieve 80%+ API cost reduction vs single-session approaches.

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Claude Code only for v1 | Simpler to build and maintain; Opus 4.6 features are Claude-specific; Noah's primary platform | — Pending |
| `/director` prefix (not `/d`) | Clearer, no collision risk with other plugins | — Pending |
| All 12 MVP features before first real use | Noah needs the full core workflow to trust it on a real project | — Pending |
| No pre-built templates | Space moves too fast; dynamic brainstorming creates relevant scaffolding on the spot | — Pending |
| Build independently from GSD | Different terminology, incorporating patterns from many systems, need full control | — Pending |
| Self-hosted plugin marketplace | Following Claude Code's plugin marketplace documentation for distribution | — Pending |
| Open source, solo-maintained | Public repo for visibility; Noah maintains; no contributor management overhead | — Pending |
| Teaching tips (toggleable) | On by default for new users, can be turned off; short contextual explanations of Director's decisions | — Pending |
| Three-tier verification | Structural (automated AI code reading) + Behavioral (user checklists) + Automated testing (opt-in Phase 2) | — Pending |
| Documentation auto-sync | Non-coders don't naturally keep docs updated; Director handles it after every task | — Pending |

---
*Last updated: 2026-02-07 after initialization*
