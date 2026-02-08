# Project Research Summary

**Project:** Director - Opinionated, spec-driven orchestration framework for vibe coders
**Domain:** Claude Code plugin / AI orchestration framework
**Researched:** 2026-02-07
**Confidence:** HIGH

## Executive Summary

Director is a Claude Code plugin that brings professional development practices to vibe coding — solo builders who use AI to build software. The research reveals a critical architectural insight: Director is not a traditional software application with compiled code and runtime dependencies. It is a structured collection of Markdown files, JSON configuration, and shell scripts that Claude Code discovers and loads at session start. The "stack" is the Claude Code Plugin System itself — all capabilities (skills, agents, hooks) are registered through plugin manifests and directory conventions.

The recommended approach is to build Director as an interview-driven workflow orchestrator that spawns specialized sub-agents within fresh context windows per task. This architecture delivers 80%+ cost savings and prevents quality degradation. The core differentiator is translating all developer jargon to plain language throughout the entire workflow — "The login page isn't connected yet" instead of "artifact wiring verification failed." The three-tier verification strategy (structural AI-driven code reading, behavioral plain-language checklists, optional automated tests) is unique in the space and serves non-developers without requiring test frameworks.

The key risk is Claude Code platform coupling. The plugin system is relatively new and breaking changes could silently disable Director. Mitigation: build self-diagnostics from day one, pin to known-good Claude Code versions, and monitor GSD's issue tracker as an early warning system. Secondary risks include context rot leaking into fresh agent windows (requiring context budget measurement) and documentation sync creating more problems than it solves (requiring user confirmation before committing syncer changes).

## Key Findings

### Recommended Stack

Director's "stack" is fundamentally different from traditional software. There is no programming language choice, no build system, no runtime dependencies. The deliverable is a directory of `.md` and `.json` files following Claude Code's plugin conventions.

**Core technologies:**
- **Claude Code Plugin System (v1.0.33+):** The platform itself. Director registers skills, agents, and hooks through the plugin manifest and directory structure. This IS the stack.
- **Markdown with YAML frontmatter:** Native format for defining skills (`SKILL.md`) and agents (`.md` files with frontmatter). Every skill and agent is a Markdown file. Not optional.
- **JSON:** Plugin manifest (`plugin.json`), hook definitions (`hooks.json`), and project state (`config.json`, `STATE.md`). Machine-readable configuration.
- **Bash/Shell Scripts:** Hook handlers must be implemented as executable shell scripts. Claude Code hooks execute shell commands.
- **Git (2.x):** Already required by Claude Code. Director uses git for atomic task commits, revertability, and context for fresh agent windows.

**Critical version requirement:** Claude Code v1.0.33+ for `context: fork` in skills (required for fresh-context architecture), agent memory field, and agent-type hooks.

### Expected Features

Research of 8 primary competitors (GSD, Autospec, Beads, OpenSpec, Spec-Kit, Superpowers, Claude Task Master, Vibe-Kanban) plus newer entrants reveals a clear feature landscape.

**Must have (table stakes):**
- Spec/plan generation from natural language — every competitor does this, users assume it exists
- Task breakdown and sequencing — all frameworks decompose work into ordered tasks
- Fresh context per task / context isolation — GSD and Autospec proved 80%+ cost savings; community now expects it
- Atomic git commits per task — users expect independent revertability
- Dependency-aware task ordering — Beads set the standard with ready-work filtering
- Session continuity / resume — state must persist across terminal closures and machine switches
- Progress tracking / status display — minimum: which tasks are done, in progress, or remaining
- Error messages with actionable guidance — mature frameworks provide fix suggestions
- Existing project (brownfield) support — most real projects are modifications to existing code
- Documentation/spec generation — structured documents (vision, plan, architecture) from planning process

**Should have (competitive differentiators):**
- **Interview-based onboarding** — No competitor asks structured questions one at a time to surface decisions the user hasn't made yet (auth strategy, deployment target, tech stack). Director's strongest differentiator.
- **Plain-language everything** — No other framework translates developer jargon to plain English throughout the entire workflow. Low technical complexity but requires disciplined prompt engineering.
- **Goal-backward verification (three-tier)** — Tier 1 (structural: AI reads code for stubs/orphans), Tier 2 (behavioral: plain-language checklists), Tier 3 (automated tests, opt-in). Tier 1 is the most innovative: AI-driven code reading without any test framework.
- **Proactive decision surfacing** — During onboarding, Director asks about decisions the user hasn't considered systematically
- **Documentation auto-sync** — After every task, verify .director/ docs match codebase state. No competitor does this automatically.
- **Brainstorming with full project context** — Open-ended thinking with VISION.md, GAMEPLAN.md, STATE.md loaded, routing to idea capture or pivot
- **Pivot support with delta impact analysis** — When requirements change, map current state against new direction using ADDED/MODIFIED/REMOVED format. No competitor has a dedicated pivot workflow.
- **Quick mode with smart escalation** — Small changes without full planning, but AI recognizes when a "quick" request is complex and recommends guided mode

**Defer (v2+):**
- Full DAG-based parallel task execution (Phase 3: coordinated agent teams)
- Visual web dashboard (Phase 3: CLI serves core workflow first)
- Multi-platform support (Phase 3: Claude Code only for v1)
- Smart testing integration (Phase 2: opt-in)
- Learning tips (Phase 2: after core workflow proven)

**Anti-features (deliberately NOT building):**
- Git worktree management — vibe coders don't understand branches, let alone worktrees
- YAML/JSON user-facing artifacts — human readability over machine parsability
- TDD dogmatism / mandatory test frameworks — hostile to vibe coders still learning
- Exposing Director as MCP server (MVP) — different architectural pattern, deferred to Phase 3

### Architecture Approach

Director is a skill-as-orchestrator architecture. Each skill's SKILL.md contains workflow logic that chains agents together. The skill IS the workflow definition — there is no separate workflow engine. Claude itself follows the markdown instructions to orchestrate agent invocations.

**Major components:**
1. **Plugin manifest** — Registers Director with Claude Code, defines namespace (`/director:*`)
2. **Skills (11 slash commands)** — User-facing entry points in `skills/` directories with SKILL.md + templates/reference docs
3. **Agents (8 subagents)** — Specialized AI roles with focused prompts and tool permissions: interviewer, planner, researcher, mapper, builder, verifier, debugger, syncer
4. **Hooks (5-8 event handlers)** — Guardrails and automation tied to Claude Code lifecycle events (PostToolUse, Stop, SubagentStop, SessionStart)
5. **Context assembler** — Collects Markdown artifacts (VISION.md, STEP.md, task file, git history), wraps in XML boundary tags, delivers to fresh agent windows
6. **State manager** — `.director/STATE.md` + `config.json` for progress tracking and project configuration
7. **Template system** — Markdown templates bundled with skills that constrain AI output quality

**Key patterns:**
- Fresh context per task via `context: fork` — each task spawns a subagent with clean context window
- State as Markdown files — all project state in `.director/` as human-readable Markdown with single `config.json` for machine settings
- Agent specialization via tool restrictions — verifier/mapper are read-only, builder has full access, syncer restricted by instructions
- Hooks as guardrails — enforce invariants (state integrity validation, documentation sync) that skills/agents can't guarantee
- Sub-agent chaining — skills spawn agents sequentially, passing results from one to the next; no direct agent-to-agent communication

**Critical build order:** Plugin manifest → .director/ initialization → interviewer + planner + builder agents → onboard → blueprint → build → inspect. Cannot test any skill without manifest. Cannot test onboard without interviewer. Cannot test blueprint without VISION.md. Cannot test build without GAMEPLAN.md.

### Critical Pitfalls

1. **Claude Code platform coupling / breaking changes** — Plugin system is relatively new; API changes could silently disable Director. After GSD experienced namespaced commands breaking in subdirectories, this is a proven risk. **Prevention:** Pin to specific Claude Code versions in docs, build self-diagnostic that runs on first invocation, monitor Claude Code changelog and GSD issue tracker.

2. **Context rot leaking into fresh agent windows** — Fresh context isn't automatically clean context. VISION.md can grow unbounded, git history pollutes the window, STEP.md accumulates cruft. Models become unreliable around 60-70% of advertised context capacity. **Prevention:** Implement context budget calculator that measures payload size before spawning agents. Cap VISION.md word count. Limit git history to N most recent relevant commits. Compress or truncate if payload exceeds 60% capacity.

3. **Documentation sync creating more problems than it solves** — AI-driven doc sync is diff-and-patch on natural language, which is unreliable. Syncer can make incorrect updates (adding implementation details to VISION.md) or miss changes made outside Director. **Prevention:** Never auto-commit syncer changes. Always present findings to user first. Use git diff as detection mechanism. Scope syncer responsibility narrowly to .director/ files only.

4. **State file corruption and race conditions** — Multiple agents reading/writing STATE.md can create corruption. File-based state has no concurrency control. Agent crashes during writes leave half-written files. **Prevention:** Serialize all state writes through lead agent only. Write atomically (temp file + rename). State validation check at start of every command.

5. **The "translation tax" — plain language becoming inaccurate language** — Translating technical state to plain language is lossy. "Everything looks good" hides nuance. Oversimplified info leads to incorrect decisions. **Prevention:** Define translation rubric for each verification tier. Always pair plain-language summaries with actionable verification steps. Never use generic positives ("all done") without specifics.

## Implications for Roadmap

Based on research, suggested phase structure:

### Goal 1 (MVP): Core Workflow

**Rationale:** Cannot validate Director's value proposition without the full loop: onboard → plan → execute → verify. Every feature in this goal is table stakes or a core differentiator. Build the foundation correctly before any enhancements.

**Delivers:**
- Interview-based onboarding with VISION.md generation
- Gameplan creation (Goals > Steps > Tasks with dependencies)
- Execution engine (fresh context, atomic commits, builder agent)
- Structural verification (Tier 1: AI reads code for stubs/orphans)
- Behavioral verification (Tier 2: plain-language checklists)
- Progress tracking and session continuity
- Error handling with plain-language guidance
- Quick mode with smart escalation
- Pivot support with delta impact analysis
- Idea capture and brainstorming

**Addresses features:**
- All table stakes (spec generation, task breakdown, fresh context, atomic commits, dependency tracking, session continuity, progress, errors, brownfield)
- All core differentiators (interview, plain language, three-tier verification, decision surfacing, doc sync, brainstorming, pivot, quick mode)

**Avoids pitfalls:**
- Plugin structure must be correct from first buildable artifact (Pitfall 1)
- Context assembly with budget measurement from day one (Pitfall 2)
- Syncer built late, requires user confirmation (Pitfall 3)
- State management design with atomic writes from foundation (Pitfall 4)
- Translation rubric and behavioral checklists from verification step (Pitfall 5)

**Suggested step breakdown:**
1. **Foundation** — Plugin manifest, .director/ initialization, reference docs, templates, state management design
2. **Core Agents** — Build all 8 agents in parallel (interviewer, mapper, planner, researcher, builder, verifier, debugger, syncer)
3. **Primary Workflow** — /director:onboard → /director:blueprint → /director:build → /director:inspect (sequential, critical path)
4. **Supporting Commands** — /director:status, /director:resume, /director:quick, /director:idea, /director:brainstorm, /director:pivot (parallel, after primary workflow works)
5. **Guardrails** — Hooks for validation, self-diagnostic, context budget calculator

### Goal 2 (Intelligence): Quality & Learning

**Rationale:** Once core workflow is validated with real usage, address the quality gaps that will surface. These features make Director smarter but aren't needed to prove the concept.

**Delivers:**
- Learning tips (toggleable contextual explanations)
- Research summaries in plain language
- Two-stage review (spec compliance, then code quality)
- Complexity-aware task breakdown
- Smart testing integration (auto-detect existing setups, opt-in new setup)

**Uses stack elements:**
- Agent memory (memory: project) for persistent learning
- Existing context assembly layer for research summaries
- Verifier agent enhancement for two-stage review

**Implements architecture:**
- Enhanced builder agent with learning memory
- Enhanced planner agent with complexity scoring
- Optional test framework integration (Vitest/Jest/pytest detection)

**Phase ordering rationale:** Build these after validating that the core workflow serves users. Phase 2 features are refinements and enhancements, not foundation.

### Goal 3 (Power Features): Scale & Multi-Platform

**Rationale:** After product-market fit is established, add features that require experimental platform capabilities or significantly expand scope.

**Delivers:**
- Coordinated agent teams (multi-task parallelism using CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS)
- Effort controls (map thinking effort to task complexity)
- Visual web dashboard (Kanban board, progress charts)
- Multi-platform support (Cursor, Codex, Gemini CLI, OpenCode)

**Uses:**
- Claude Code Agent Teams (experimental, currently disabled by default)
- Web frontend stack (separate from plugin)
- MCP-server exposure for multi-editor support

**Phase ordering rationale:** Agent teams are experimental and add coordination complexity. Visual dashboard doubles scope. Multi-platform requires architectural abstraction. All are valuable but not needed to validate Director's core value.

### Phase Ordering Rationale

- **Goal 1 must come first** because you cannot test whether Director serves vibe coders without the full workflow loop. Every step in Goal 1 depends on the prior step: onboard creates VISION.md, blueprint requires VISION.md, build requires GAMEPLAN.md, inspect requires built code.

- **Foundation before agents before skills** because the plugin manifest must register before anything loads, .director/ structure must exist before agents write state, and agents must exist before skills can invoke them.

- **Primary workflow (onboard→blueprint→build→inspect) before supporting commands** because resume/status/quick/pivot all assume the primary workflow exists and has created state files.

- **Guardrails last in Goal 1** because hooks validate behavior that must exist first. You cannot write a state integrity check before state management is implemented.

- **Goal 2 after Goal 1 validation** because learning tips, research summaries, and complexity awareness are refinements. Build them in response to real usage patterns, not speculation.

- **Goal 3 after product-market fit** because agent teams, dashboards, and multi-platform are force multipliers for a proven workflow. Building them before validating the core is premature optimization.

### Research Flags

Phases likely needing deeper research during planning:

- **Goal 1, Step 2 (Core Agents):** Agent prompt engineering is the most critical design decision in Director. Each agent needs focused research on prompt structure, tool restrictions, and output format. Not technical integration research — prompt design research.

- **Goal 1, Step 5 (Guardrails):** Hook script implementation for state validation and integrity checks. Requires understanding hook JSON input format and exit code semantics. Short research window needed.

- **Goal 2, Testing Integration:** Auto-detection of Vitest/Jest/pytest setups and plain-language test result translation. Niche domain for each testing framework.

- **Goal 3, Agent Teams:** Experimental feature with sparse documentation. Requires research into coordination patterns and error handling for parallel multi-task execution.

Phases with standard patterns (skip research):

- **Goal 1, Step 1 (Foundation):** Plugin structure and directory conventions are well-documented in official Claude Code docs. No research needed — follow the spec.

- **Goal 1, Step 3 (Primary Workflow):** Workflow logic is prompt engineering and state file manipulation, both documented in PRD. Implementation is execution, not research.

- **Goal 1, Step 4 (Supporting Commands):** Simplified versions of primary workflow. No new patterns.

- **Goal 2, Learning Tips:** Simple enhancement to agent prompts. No research needed.

- **Goal 3, Visual Dashboard:** Standard web frontend development. If needed, research web stack separately (outside Director planning).

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | Verified from official Claude Code documentation (plugins, skills, subagents, hooks, plugin reference, marketplace). Plugin structure and component registration are authoritative. |
| Features | HIGH | Analyzed 8 primary competitors plus newer entrants. Feature matrix cross-referenced. Director's differentiators are validated against market gaps. Table stakes confirmed by universal presence across competitors. |
| Architecture | HIGH | Claude Code architectural patterns verified from official docs. Skill-as-orchestrator, context: fork, agent tool restrictions, hooks — all confirmed as best practices. Build order derived from dependency analysis. |
| Pitfalls | HIGH | Multiple sources cross-referenced: official Claude Code docs (platform coupling risks), GSD issue tracker (breaking changes, state corruption), competitive analysis (context rot, doc sync), industry reports (translation challenges), Noah's firsthand experience (pivot pain, doc drift). |

**Overall confidence:** HIGH

### Gaps to Address

**Context budget measurement specifics:** Research identified the need for context budget calculation but didn't specify the exact token counting method. During implementation, determine whether to use Claude API's token counting endpoint, approximate with character-based heuristics, or use a library. Test actual token counts of assembled payloads with real VISION.md/STEP.md/task files to calibrate thresholds.

**Hook script platform portability:** Shell scripts may need platform-specific handling (macOS vs Linux vs Windows). Research noted this as medium risk but didn't provide specific mitigation patterns. During Goal 1 Step 5, test hooks on macOS and Linux. Document any platform-specific differences. Consider Python for complex hooks if portability issues surface.

**Agent memory file format:** Research confirmed that Claude Code supports `memory: project` in agent frontmatter and loads the first 200 lines of `MEMORY.md` into context. Format of MEMORY.md and how agents write to it is not specified in research. During Goal 2, test agent memory behavior to determine whether agents auto-append or need explicit instructions to update memory.

**Gameplan dependency representation:** Research suggests referencing dependencies by capability ("needs user authentication") rather than task ID, but the exact data structure in GAMEPLAN.md wasn't specified. During Goal 1 Step 1 (Foundation), design the task dependency format with mutability in mind — test pivot workflow early to validate that dependencies survive gameplan regeneration.

**Plain-language verification checklist generation:** Research identified behavioral checklists (Tier 2) as a differentiator but didn't specify the checklist format or generation logic. During Goal 1 Step 3, design the checklist template and test with real tasks to ensure the AI generates specific, testable actions (not generic "make sure it works" statements).

## Sources

### Primary (HIGH confidence)

**Official Claude Code Documentation:**
- [Claude Code Skills Documentation](https://code.claude.com/docs/en/skills) — Skill/command system, YAML frontmatter options, context: fork
- [Claude Code Sub-agents Documentation](https://code.claude.com/docs/en/sub-agents) — Agent definitions, tool restrictions, models, permissions
- [Claude Code Hooks Reference](https://code.claude.com/docs/en/hooks) — Complete hook event lifecycle, matchers, JSON input/output
- [Claude Code Plugins Documentation](https://code.claude.com/docs/en/plugins) — Plugin creation guide, directory structure
- [Claude Code Plugins Reference](https://code.claude.com/docs/en/plugins-reference) — Full manifest schema, distribution
- [Claude Code Plugin Marketplaces](https://code.claude.com/docs/en/plugin-marketplaces) — Marketplace structure, installation flow
- [Claude Code Memory Documentation](https://code.claude.com/docs/en/memory) — Agent memory field, persistence
- [Claude Code Agent Teams](https://code.claude.com/docs/en/agent-teams) — Experimental multi-agent coordination

**Verified Repositories:**
- [Anthropic Official Plugin Directory](https://github.com/anthropics/claude-plugins-official) — Distribution target
- [GSD (Get Shit Done)](https://github.com/glittercowboy/get-shit-done) — Context engineering patterns, issue tracker for platform coupling warnings

**Director Design Docs (Authoritative):**
- `/Users/noahrasheta/Dev/GitHub/director/docs/design/PRD.md` — Feature requirements, architectural decisions
- `/Users/noahrasheta/Dev/GitHub/director/docs/design/research-competitive-analysis.md` — 8 competitor architectures
- `/Users/noahrasheta/Dev/GitHub/director/docs/design/research-director-brainstorm.md` — Foundation brainstorm
- `/Users/noahrasheta/Dev/GitHub/director/docs/design/research-followup-questions.md` — Deep-dive Q&A, Noah's experience
- `/Users/noahrasheta/Dev/GitHub/director/docs/design/research-opus-46-strategy.md` — AI capability integration

### Secondary (MEDIUM confidence)

**Competitor Repositories (GitHub):**
- Autospec: https://github.com/ariel-frischer/autospec — YAML artifacts, phase-based execution, cost isolation
- Beads: https://github.com/beads — DAG dependencies, ready-work filtering, influenced Anthropic's Tasks system
- OpenSpec: https://github.com/Fission-AI/OpenSpec — Delta specs (ADDED/MODIFIED/REMOVED), brownfield-first
- Spec-Kit: https://github.com/github/spec-kit — Template-driven quality, [UNCLEAR] markers
- Superpowers: https://github.com/obra/superpowers — Brainstorming workflow, two-stage review
- Claude Task Master: https://github.com/eyaltoledano/claude-task-master — Complexity scoring, multi-model abstraction
- Vibe-Kanban: https://github.com/BloopAI/vibe-kanban — Visual Kanban, parallel execution, worktrees
- Claude-Flow: https://github.com/ruvnet/claude-flow — Agent sprawl warning (60+ agents, 250K+ LOC)

**Newer Entrants:**
- Deep Trilogy: https://pierce-lamb.medium.com/the-deep-trilogy-claude-code-plugins-for-writing-good-software-fast-33b76f2a022d — Multi-plugin composition
- cc-sdd: https://github.com/gotalab/cc-sdd — Spec-driven development validation
- Kiro: https://kiro.dev/ — AWS-backed spec-driven IDE, validates market
- Claude Code native Tasks: https://venturebeat.com/orchestration/claude-codes-tasks-update-lets-agents-work-longer-and-coordinate-across — Built-in task management

**Industry Analysis:**
- [Context Rot: From Agent Loop to Agent Swarm](https://dev.to/simone_callegari_1f56a902/context-rot-from-agent-loop-to-agent-swarm-solving-context-persistence-in-ai-assisted-development-3ada) — Context degradation patterns
- [Context Rot: Why AI Gets Worse the Longer You Chat](https://www.producttalk.org/context-rot/) — 60-70% effective context capacity
- [AI Coding Agents: Coherence Through Orchestration](https://mikemason.ca/writing/ai-coding-agents-jan-2026/) — Orchestration patterns
- [Spec-Driven Development: Unpacking 2025's Key Practice](https://www.thoughtworks.com/en-us/insights/blog/agile-engineering-practices/spec-driven-development-unpacking-2025-new-engineering-practices) — Industry validation
- [Addy Osmani on conductors vs orchestrators](https://addyosmani.com/blog/future-agentic-coding/) — Market context

**Documented Issues:**
- [GSD command compatibility issue (GitHub Issue #218)](https://github.com/glittercowboy/get-shit-done/issues/218) — Claude Code breaking changes
- [GSD CLAUDE.md injection issue (GitHub Issue #50)](https://github.com/glittercowboy/get-shit-done/issues/50) — State corruption patterns
- [Claude Code plugin update bug (GitHub Issue #19197)](https://github.com/anthropics/claude-code/issues/19197) — Plugin update reliability

### Tertiary (LOW confidence)

- [Vibe coding catastrophic explosions warning](https://thenewstack.io/vibe-coding-could-cause-catastrophic-explosions-in-2026/) — Industry speculation, needs validation
- [Beads influencing Anthropic](https://paddo.dev/blog/from-beads-to-tasks/) — Anecdotal, correlation not confirmed
- [Awesome Claude Code](https://github.com/hesreallyhim/awesome-claude-code) — Curated list, may not be comprehensive

---
*Research completed: 2026-02-07*
*Ready for roadmap: yes*
