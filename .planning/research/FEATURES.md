# Feature Research

**Domain:** AI coding orchestration frameworks / Claude Code plugins for vibe coders
**Researched:** 2026-02-07
**Confidence:** HIGH

Comprehensive feature landscape analysis based on 8 primary competitors (GSD, Autospec, Beads, OpenSpec, Spec-Kit, Superpowers, Claude Task Master, Vibe-Kanban) plus newer entrants (Claude-Flow, Deep Trilogy, cc-sdd, Claude Squad, Simone, RIPER, Claude Code native Tasks), as well as adjacent IDE-level products (Kiro, Cursor, Windsurf).

---

## Feature Landscape

### Table Stakes (Users Expect These)

Features users assume exist. Missing these = product feels incomplete. Every serious orchestration framework in this space has these.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| **Spec/plan generation from natural language** | Every competitor does this. Users describe what they want; the tool creates a plan. Without this, there is no product. | MEDIUM | GSD, Autospec, Spec-Kit, OpenSpec, Kiro all generate specs from input. Director's interview-based approach adds a twist but the core capability is table stakes. |
| **Task breakdown and sequencing** | All frameworks decompose work into ordered tasks. Users expect to see their project broken into steps. | MEDIUM | GSD uses Phase > Plan > Task. Beads uses DAG dependencies. Spec-Kit uses User Story > Task. Director uses Goal > Step > Task. The hierarchy varies but the capability is universal. |
| **Fresh context per task / context isolation** | GSD and Autospec proved this delivers 80%+ cost savings and prevents quality degradation. Community now expects it. | MEDIUM | GSD pioneered this, Autospec validated it at scale. Claude Code native Tasks system (2.1+) now provides built-in sub-agent spawning that makes this easier. Any framework without context isolation feels broken after long sessions. |
| **Atomic git commits per task** | GSD, Autospec, and Vibe-Kanban all do this. Users expect every unit of work to be independently revertable. | LOW | Standard pattern. Claude Code itself supports this natively. The challenge is messaging it to vibe coders ("Progress saved" not "committed SHA"). |
| **Dependency-aware task ordering** | Beads' ready-work filtering set the standard. Users expect to be told "what can I work on right now" rather than choosing from a flat list. | MEDIUM | Beads uses full DAG. GSD uses phase ordering. Claude Code native Tasks added dependency/blocker support in 2.1+. Director needs at minimum "Needs X first" dependency tracking. |
| **Session continuity / resume** | Users close terminals, switch machines, take breaks. State must persist. | MEDIUM | GSD uses STATE.md + git history. Claude Code native Tasks writes to ~/.claude/tasks with CLAUDE_CODE_TASK_LIST_ID for cross-session sharing. Director needs automatic persistence with zero manual save commands. |
| **Progress tracking / status display** | Every tool provides some way to see where you are. Minimum: which tasks are done, in progress, or remaining. | LOW | GSD has text-based STATE.md. Vibe-Kanban has visual Kanban. Claude Task Master has CLI tables. Director should provide at minimum clear text progress with status indicators. |
| **Error messages with actionable guidance** | When something fails, users need to know what happened and what to do next. All mature frameworks provide this. | LOW | GSD and Superpowers both include fix suggestions. The differentiator for Director is translating these to plain language. |
| **Existing project (brownfield) support** | Most real projects are modifications to existing code, not greenfield. Users expect to point the tool at an existing codebase. | HIGH | GSD has /gsd:map-codebase. OpenSpec is brownfield-first with delta specs. Kiro analyzes existing repos. Director needs codebase mapping via sub-agents. |
| **Documentation/spec generation** | Producing structured documents (vision, plan, architecture) from the planning process. | MEDIUM | Universal across all competitors. Format varies (Markdown, YAML, JSON). Director uses Markdown for human readability. |

### Differentiators (Competitive Advantage)

Features that set Director apart. Not expected by the market, but highly valued by the target audience.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| **Interview-based onboarding** | No competitor asks structured questions one at a time with multiple choice options to build a vision document. Superpowers' brainstorming is closest but is a general-purpose skill, not a project onboarding flow. Director is the ONLY tool that interviews the user to surface decisions they haven't made yet (auth strategy, deployment target, tech stack). | HIGH | This is Director's strongest differentiator. Every other tool assumes the user already knows what to build and how. Director helps them figure it out. Requires the director-interviewer agent to be exceptionally well-designed. |
| **Plain-language everything** | No other framework translates developer jargon to plain English throughout the entire workflow. GSD says "artifact wiring verification failed." Director says "The login page isn't connected to the database yet." This applies to error messages, research summaries, progress updates, and all user-facing output. | LOW | Low technical complexity but requires disciplined prompt engineering across all agents and templates. This is a design decision more than a technical challenge. The entire agent roster must enforce plain language. |
| **Goal-backward verification (three-tier)** | GSD has goal-backward verification but it is technical. Director's Tier 1 (structural: AI reads code for stubs/orphans), Tier 2 (behavioral: plain-language checklists), and Tier 3 (automated tests, opt-in Phase 2) is unique in its layered approach and accessibility to non-developers. | HIGH | Tier 1 is the most innovative: AI-driven code reading without any test framework. No other tool does structural verification this way. Tier 2 translates acceptance criteria into human-friendly checklists. The combination is a strong differentiator. |
| **Proactive decision surfacing** | During onboarding, Director asks about decisions the user hasn't considered: "Have you thought about how users will log in?" "Where will this be deployed?" No competitor does this systematically. | MEDIUM | Requires a well-curated question bank and branching logic. Must feel helpful, not interrogative. Depends on director-interviewer agent quality. |
| **Documentation auto-sync** | After every task, Director verifies that all .director/ docs, CLAUDE.md, and architecture docs still match the codebase state. Catches drift from changes made outside Director's workflow. No competitor does this automatically. | MEDIUM | The director-syncer agent runs as a sub-agent after every build. Must be fast enough not to feel like overhead. GSD requires manual updates. This addresses a real pain point Noah experienced. |
| **Brainstorming with full project context** | Open-ended thinking sessions where the AI has the entire project context loaded. Routes to idea capture, task creation, pivot, or just understanding. Superpowers has brainstorming but without persistent project context integration and routing. | MEDIUM | Requires loading VISION.md, GAMEPLAN.md, STATE.md, and codebase awareness. The routing logic (save as idea vs create task vs trigger pivot) is the differentiator. |
| **Complexity/effort indicators** | "Small tweak" / "Medium feature" / "Major addition" visible on every task. Claude Task Master scores 1-10 but the output is for developers. Director translates this to intuitive language. | LOW | Claude Task Master proved the AI can estimate complexity well. The translation to vibe-coder language is the value-add. |
| **Pivot support with delta impact analysis** | When requirements change mid-project, Director maps current state against new direction and shows what changes in plain language. Uses delta format (ADDED/MODIFIED/REMOVED) from OpenSpec. No competitor has a dedicated pivot workflow. | HIGH | Requires codebase re-mapping, gameplan diffing, and documentation updates. The /director:pivot command is unique in the space. |
| **Quick mode with smart escalation** | Small changes without full planning, but the AI can recognize when a "quick" request is actually complex and recommend switching to guided mode. GSD has quick mode but without the smart escalation behavior. | MEDIUM | The complexity analysis before execution is the differentiator. Must avoid being annoying (don't over-escalate). |
| **Idea capture and promotion** | Capture half-formed ideas during builds, review them later, promote to tasks or dismiss. No competitor has a dedicated idea capture workflow separate from the active plan. | LOW | Simple capture to IDEAS.md. The value is in the promotion workflow: analyzing whether an idea is quick, needs planning, or is too complex for now. |
| **Custom terminology for non-developers** | Goal/Step/Task/Action hierarchy with plain-English dependency language ("Needs X first"). Git abstracted as "Progress saved." Every competing framework uses developer terminology. | LOW | Zero technical cost. Pure design decision. But it compounds across the entire user experience. |

### Anti-Features (Commonly Requested, Often Problematic)

Features that seem good but create problems. Director should deliberately NOT build these.

| Feature | Why Requested | Why Problematic | Alternative |
|---------|---------------|-----------------|-------------|
| **Full DAG-based parallel task execution (MVP)** | Beads and Claude-Flow show impressive parallelism. Users see "3 tasks at once" and want it. | Adds enormous complexity to MVP. Coordination bugs, merge conflicts, and context collision are hard to debug. Claude-Flow's 250K+ LOC is a warning. Sub-agents within a single task provide sufficient parallelism for MVP. | Sub-agents for research/verification/debugging within each task (MVP). Coordinated agent teams across tasks deferred to Phase 3. |
| **Git worktree management** | Vibe-Kanban uses worktrees for parallel agent execution. Power users request it. | Vibe coders don't understand branches, let alone worktrees. Adds configuration complexity and potential for state confusion. One branch, linear history is dramatically simpler. | Single branch, atomic commits. Parallel execution deferred to Phase 3 where agent teams handle git coordination. |
| **YAML/JSON user-facing artifacts** | Autospec uses YAML-first artifacts for machine readability. Spec-Kit uses structured templates. Developers prefer machine-parseable formats. | Vibe coders see YAML and close the file. Machine-readable formats create a barrier to understanding. Human readability is more important than machine parsability for the target audience. | Markdown for all user-facing artifacts. JSON only for machine state (config.json, STATE.md internals). XML only at agent context assembly layer (invisible to users). |
| **TDD dogmatism / mandatory test frameworks** | Superpowers enforces TDD. Spec-Kit requires tests before implementation. Testing is considered best practice. | Requiring test setup before any code can run is hostile to vibe coders who are still learning. Adds friction, jargon, and a mental model most non-developers don't have. | Three-tier verification: Tier 1 structural (AI reads code, no framework), Tier 2 behavioral (user confirms features work), Tier 3 automated tests (opt-in Phase 2, never required). |
| **Multi-model provider abstraction (MVP)** | Claude Task Master supports Claude, GPT, Gemini with auto-fallback. Users want provider choice. | Adds API key management, response format normalization, and per-provider prompt tuning. Doubles or triples the testing surface. Director runs inside Claude Code, so Claude is the model. | Claude Code only for v1. Multi-platform support (which implies other models) is Phase 3. |
| **Constitutional governance / role-based access** | Enterprise frameworks include approval workflows and access controls. Teams request permission systems. | Solo builders ARE all roles. Governance adds overhead without value for the target audience. Director is for one person, not a team. | None needed. Solo builder assumption throughout. |
| **Visual web dashboard (MVP)** | Vibe-Kanban's web UI and desktop app are impressive. Users want dashboards. | Building a web frontend doubles the scope of MVP. CLI output with clear formatting serves the core workflow. The dashboard is a Phase 3 feature after the core loop is proven. | CLI-based progress display with status indicators (Ready/In Progress/Complete/Needs Attention). Phase 3 adds web dashboard with Kanban board. |
| **Exposing Director as an MCP server** | Would allow Cursor, VS Code, and other editors to call Director commands. Seems forward-looking. | Director is a Claude Code plugin, not a server. Adding MCP server capabilities is a different architectural pattern that complicates the plugin design. | MCP-compatible (uses user's configured MCP servers) but not MCP-dependent. MCP server exposure deferred to Phase 3 multi-platform support. |
| **Pre-built project templates (static)** | Many tools ship with "Next.js starter" or "API boilerplate" templates. Users expect scaffolding. | Static templates go stale, create maintenance burden, and assume tech stack decisions. Director's interview-based onboarding dynamically generates the right structure for each project. | Dynamic vision capture via interview. The AI generates project-appropriate structure based on answers, not from templates. |
| **60+ agent ecosystem** | Claude-Flow boasts 60+ agents across 8 categories. More agents seems better. | Agent sprawl creates confusion, increases maintenance cost, and makes prompt engineering harder. GSD's 11 agents are already complex. Director targets ~8 focused agents. | ~8 agents with clear roles. Workflows chain agents together. Fewer, more focused agents produce more consistent results. |
| **Real-time live monitoring of agent work** | Vibe-Kanban shows live terminal output from agents. Users want to watch the AI work. | Creates anxiety for non-technical users who can't interpret terminal output. The scrolling text feels like "something might go wrong." Results-only reporting is calmer and more useful. | Report results in plain language after completion. Expandable detail logs available but not default. Phase 3 dashboard could add optional live view. |

---

## Feature Dependencies

```
[Interview-based onboarding]
    +--generates--> [Vision document]
                       +--feeds into--> [Gameplan creation]
                                            +--drives--> [Execution engine]
                                            |                +--triggers--> [Structural verification (Tier 1)]
                                            |                +--triggers--> [Documentation auto-sync]
                                            |                +--reports to--> [Progress tracking]
                                            |
                                            +--drives--> [Ready-work filtering / dependency ordering]
                                                             +--feeds into--> [Execution engine]

[Session continuity]
    +--reads from--> [Progress tracking (STATE.md)]
    +--reads from--> [Git history]

[Goal-backward verification (Tier 2)]
    +--requires--> [Gameplan creation] (needs goals/acceptance criteria to verify against)
    +--requires--> [Execution engine] (needs completed tasks to verify)

[Quick mode]
    +--requires--> [Execution engine] (uses builder agent)
    +--requires--> [Structural verification] (runs after quick tasks)
    +--enhances with--> [Complexity analysis] (for smart escalation)

[Brainstorming]
    +--requires--> [Vision document] (for project context)
    +--routes to--> [Idea capture] OR [Gameplan update] OR [Pivot]

[Pivot support]
    +--requires--> [Vision document] (reads current state)
    +--requires--> [Gameplan creation] (regenerates plan)
    +--triggers--> [Documentation auto-sync] (updates all docs)
    +--uses--> [Codebase mapping] (brownfield analysis)

[Error handling]
    +--enhances--> [Execution engine] (retry cycles)
    +--spawns--> [Debugger agents] (diagnosis)
    +--requires--> [Plain-language translation] (user-facing output)

[Idea capture]
    +--independent standalone feature--
    +--promotion requires--> [Gameplan creation] OR [Quick mode]
```

### Dependency Notes

- **Vision document requires onboarding:** Can't plan without understanding what to build. Onboarding must come first.
- **Gameplan requires vision:** The plan derives from the vision document. No vision = no gameplan.
- **Execution requires gameplan:** Tasks come from the gameplan. No gameplan = nothing to execute.
- **Verification requires completed tasks:** Can't verify what hasn't been built. Tier 1 runs after each task; Tier 2 runs at step/goal boundaries.
- **Session continuity requires progress tracking:** Resume reads STATE.md + git history to reconstruct where the user left off.
- **Brainstorming requires vision for full context:** Without project context loaded, brainstorming is just a chat. The value is contextual awareness.
- **Pivot requires both vision and codebase mapping:** Must understand current state AND current plan to generate deltas.
- **Quick mode requires execution engine but NOT gameplan:** Quick mode bypasses planning. However, smart escalation depends on complexity analysis to know when to recommend guided mode.
- **Idea capture is independent:** Works standalone. Promotion to tasks depends on gameplan or quick mode existing.

---

## MVP Definition

### Launch With (v1)

Minimum viable product -- what Director needs to validate the core workflow.

- [ ] **Interview-based onboarding** -- The primary differentiator. Without this, Director is just another task runner.
- [ ] **Vision document generation** -- Output of onboarding. Source of truth for all agents.
- [ ] **Gameplan creation (Goals > Steps > Tasks)** -- The plan users follow. Must include dependency ordering and complexity indicators.
- [ ] **Execution engine (fresh context, atomic commits)** -- The build loop. One task at a time, fresh agent, clean commit.
- [ ] **Structural verification (Tier 1)** -- AI reads code for stubs, placeholders, and orphans. No test framework. Runs after every task.
- [ ] **Behavioral verification (Tier 2)** -- Plain-language checklists at step/goal boundaries. User confirms features work.
- [ ] **Progress tracking** -- Visual status of what's done, in progress, and remaining. CLI-based with clear formatting.
- [ ] **Session continuity** -- Automatic state persistence. Close terminal, come back, resume seamlessly.
- [ ] **Error handling** -- Plain-language errors with actionable guidance. Debugger agent for complex issues.
- [ ] **Quick mode** -- Small changes without full planning. Smart escalation when complexity warrants it.
- [ ] **Pivot support** -- Handle requirement changes gracefully with delta impact analysis.
- [ ] **Idea capture** -- Quick capture to IDEAS.md with promotion workflow.
- [ ] **Brainstorming** -- Open-ended thinking with full project context and smart routing.

### Add After Validation (v1.x / Phase 2)

Features to add once the core workflow is proven with real usage.

- [ ] **Learning tips (toggleable)** -- Contextual one-line explanations of why Director makes certain decisions. Trigger: user feedback requesting more transparency.
- [ ] **Research summaries in plain language** -- "What this means for your project" section on AI research findings. Trigger: users confused by technical research output.
- [ ] **Two-stage review** -- Spec compliance first, then code quality. Trigger: tasks passing verification but producing low-quality code.
- [ ] **Complexity-aware task breakdown** -- AI scores difficulty and recommends subtask counts. Trigger: tasks consistently too large or too small.
- [ ] **Smart testing integration** -- Auto-detect existing test setups, opt-in new setup, plain-language results. Trigger: users requesting automated quality assurance.

### Future Consideration (v2+ / Phase 3)

Features to defer until product-market fit is established.

- [ ] **Coordinated agent teams** -- Multiple tasks in parallel by specialized teams. Defer because sub-agents within tasks provide sufficient parallelism for MVP, and coordination complexity is high.
- [ ] **Effort controls** -- Map thinking effort to task complexity for cost optimization. Defer because it requires significant tuning and telemetry.
- [ ] **Visual web dashboard** -- Kanban board, progress charts, architecture diagrams. Defer because CLI serves the core workflow and building a frontend doubles scope.
- [ ] **Multi-platform support** -- Cursor, Codex, Gemini CLI, OpenCode. Defer because Claude Code only for v1; portable architecture is designed in but not activated.

---

## Feature Prioritization Matrix

| Feature | User Value | Implementation Cost | Priority |
|---------|------------|---------------------|----------|
| Interview-based onboarding | HIGH | HIGH | P1 |
| Vision document generation | HIGH | MEDIUM | P1 |
| Gameplan creation | HIGH | HIGH | P1 |
| Execution engine (fresh context) | HIGH | HIGH | P1 |
| Structural verification (Tier 1) | HIGH | MEDIUM | P1 |
| Progress tracking | HIGH | LOW | P1 |
| Session continuity | HIGH | MEDIUM | P1 |
| Error handling (plain language) | HIGH | LOW | P1 |
| Quick mode with smart escalation | MEDIUM | MEDIUM | P1 |
| Pivot support | MEDIUM | HIGH | P1 |
| Behavioral verification (Tier 2) | MEDIUM | MEDIUM | P1 |
| Idea capture | MEDIUM | LOW | P1 |
| Brainstorming with context | MEDIUM | MEDIUM | P1 |
| Documentation auto-sync | HIGH | MEDIUM | P1 |
| Learning tips | LOW | LOW | P2 |
| Research summaries (plain language) | MEDIUM | LOW | P2 |
| Two-stage review | MEDIUM | MEDIUM | P2 |
| Complexity-aware breakdown | MEDIUM | MEDIUM | P2 |
| Smart testing integration | MEDIUM | HIGH | P2 |
| Coordinated agent teams | HIGH | HIGH | P3 |
| Effort controls | MEDIUM | HIGH | P3 |
| Visual dashboard | HIGH | HIGH | P3 |
| Multi-platform support | MEDIUM | HIGH | P3 |

**Priority key:**
- P1: Must have for launch (MVP / Goal 1)
- P2: Should have, add after core is proven (Phase 2 / Goal 2)
- P3: Nice to have, future consideration (Phase 3 / Goal 3)

---

## Competitor Feature Analysis

### Feature Matrix: What Each Competitor Does

| Feature | GSD | Autospec | Beads | OpenSpec | Spec-Kit | Superpowers | Task Master | Vibe-Kanban | Director |
|---------|-----|----------|-------|---------|----------|-------------|-------------|-------------|----------|
| Spec/plan generation | XML plans | YAML artifacts | Issue tracker | Delta specs | Templates | Brainstorm | PRD parsing | Manual tasks | Interview-driven Markdown |
| Task breakdown | Phase > Plan > Task | 4-stage pipeline | DAG graph | Change folders | User Story > Task | Micro-tasks | Tasks + subtasks | Kanban cards | Goal > Step > Task |
| Fresh context per task | Yes (sub-agents) | Yes (phases) | Per-session | Minimal | No | Yes (sub-agents) | File-based | Per-task agents | Yes (fresh agents) |
| Atomic git commits | Yes | Yes (auto-commit) | Git-backed SQLite | No (manual) | No | Partial | No | Yes (PR creation) | Yes |
| Dependency tracking | Phase ordering | Stage ordering | Full DAG | Folder structure | Priority (P1/P2/P3) | Skill dependencies | Task dependencies | None | "Needs X first" |
| Verification | Goal-backward | Stage validation | Ready-work check | Archive review | Quality gates | 2-stage review | Dependency check | Code diff review | Three-tier (structural + behavioral + opt-in testing) |
| Visual progress | None (text STATE.md) | Status command | None | Terminal output | None | None | CLI tables | Kanban board + web UI | CLI progress board (Phase 3: web dashboard) |
| Session continuity | Manual pause/resume | History tracking | Git persistence | Spec persistence | None | None | File persistence | Session management | Automatic (no manual save) |
| Error handling | Technical jargon | Retry on failure | SQLite recovery | Manual | None | None | None | Agent monitoring | Plain-language with fix suggestions |
| Brownfield support | /gsd:map-codebase | No | Issue import | Delta specs (brownfield-first) | Existing codebase | No | Existing PRD | Existing repo | Sub-agent codebase mapping |
| Plain language output | No | No | No | No | No | Partial | No | No | Yes (core principle) |
| Interview/onboarding | "What to build?" | None | None | None | None | Brainstorm questions | None | Setup wizard | Structured interview with decision surfacing |
| Brainstorming | None | None | None | None | None | /brainstorm skill | None | None | /director:brainstorm with project context |
| Quick mode | No (depth settings) | No | No | Fluid workflow | No | No | No | Direct task creation | /director:quick with smart escalation |
| Pivot support | None | None | None | Delta specs | None | None | None | None | /director:pivot with impact analysis |
| Idea capture | None | None | None | None | None | None | None | None | /director:idea with promotion |
| Doc auto-sync | None (manual) | None | None | Spec persistence | None | None | None | None | Automatic after every task |
| Agent count | 11 | 6 | Multi-agent | 20+ tools | 17 | 3 | 10+ models | 10+ | ~8 |
| Command count | 24+ | ~8 | ~15 | ~10 | ~12 | ~6 | ~20 | ~10 | ~11 |

### What Competitors Do Well (Director Should Learn From)

| Competitor | What They Do Well | Director Takeaway |
|-----------|-------------------|-------------------|
| **GSD** | Context engineering is the most sophisticated in the space. 6-layer context management, atomic commits as queryable history, goal-backward verification, wave-based parallelization. The system is architecturally excellent. | Adopt context engineering principles: fresh agents, targeted context loading, XML boundary tags for AI parsing, git history as context source. Simplify the user-facing complexity. |
| **Autospec** | Phase-based execution with cost isolation proved the 80%+ cost savings model. YAML validation ensures artifacts are well-formed before proceeding. Auto-commit with conventional commit messages. | Adopt cost-saving model (fresh context per task). Skip YAML in favor of Markdown but keep the validation concept (structural verification). |
| **Beads** | Ready-work filtering is brilliant. "Here's what you can work on right now" eliminates decision paralysis. DAG-based dependency tracking is the most rigorous in the space. Influenced Anthropic's native Tasks system. | Adopt ready-work filtering. Use simpler dependency model than full DAG ("Needs X first") but ensure the same filtering behavior. |
| **OpenSpec** | Delta specs (ADDED/MODIFIED/REMOVED) are the best approach for brownfield projects. Agent-agnostic design supporting 20+ tools shows how to build for portability. Brownfield-first philosophy is correct for the real world. | Adopt delta spec format for pivot support and brownfield modifications. Design for portability from day one even though v1 is Claude Code only. |
| **Spec-Kit** | Template-driven quality is an underrated insight. The template IS the quality gate for AI output. [NEEDS CLARIFICATION] markers force explicit uncertainty. GitHub backing gives it institutional credibility. Agent-agnostic. | Adopt template-driven quality for all agent outputs (~8-10 templates for .director/ artifacts). Adopt uncertainty markers for onboarding. |
| **Superpowers** | Brainstorming workflow (one question at a time, multiple choice, 200-300 word sections with validation) is the gold standard for conversational design. Two-stage review (spec compliance then quality) is well-ordered. 29K+ GitHub stars prove the approach resonates. Self-evolving skill system is innovative. | Adopt brainstorming interaction pattern for onboarding and brainstorming. Adopt two-stage review for Phase 2. Study their skill system for Director's agent design. |
| **Claude Task Master** | Complexity scoring (1-10) and subtask generation give users scope awareness. Multi-model abstraction shows how to be provider-agnostic. Research tool provides fresh information beyond training cutoff. | Adopt complexity estimation translated to plain language. Defer multi-model to Phase 3. |
| **Vibe-Kanban** | Visual Kanban board is the best progress visualization in the space. Parallel execution with git worktrees and automatic PR creation is technically impressive. Multi-agent support (Claude Code, Codex, Gemini CLI, etc.). | Adopt visual progress concept for Phase 3 dashboard. Skip worktrees for MVP (too complex for vibe coders). Learn from their multi-agent support for Phase 3. |

### What Competitors Do Poorly (Director Should Avoid)

| Competitor | What They Do Poorly | Director Should Avoid |
|-----------|---------------------|----------------------|
| **GSD** | Confusing terminology (Milestone vs Phase vs Plan). Plans are XML and unreadable. No visual dashboard. Error messages use jargon. Research findings not translated to plain language. Requires manual pause command. 24+ commands create choice paralysis. | Avoid developer jargon throughout. Never expose XML to users. Provide visual progress from day one. Keep to ~11 commands. Auto-resume without manual save. |
| **Autospec** | YAML-first artifacts are developer-only. No guided onboarding. No brownfield support. No visual progress. CLI-only interface assumes developer comfort. | Avoid YAML user-facing artifacts. Include guided onboarding. Support brownfield projects. |
| **Beads** | No planning capability. No spec generation. Purely a task tracker. Technical CLI interface. Documentation is sparse. Not a full workflow solution. | Avoid building just a tracker. Director must cover the full lifecycle: plan, build, verify, track. |
| **OpenSpec** | Minimal context management. No built-in execution engine. Users must manually run their AI tool against specs. No progress tracking or visual feedback. | Avoid leaving execution to the user. Director must automate the build loop. |
| **Spec-Kit** | No execution engine. No progress tracking. Requires manual AI invocation after spec creation. TDD requirement is hostile to non-developers. No session continuity. | Avoid requiring TDD. Never leave execution as a manual step. |
| **Superpowers** | No project management. No persistent gameplan. Each brainstorm is independent. No progress tracking across tasks. Skills are powerful but disconnected from a project lifecycle. | Avoid isolated skills without project context. Every command should know where the user is in their project. |
| **Claude Task Master** | Developer-facing output. Complexity scores are numbers, not plain language. Multi-model setup requires API key management. No visual progress. | Avoid raw numerical output. Translate everything to plain language. |
| **Vibe-Kanban** | Setup complexity is high. Requires understanding git worktrees, PRs, and agent configuration. The visual UI is great but the setup is developer-only. No spec-driven workflow. | Avoid complex setup. Director should work with zero configuration. |
| **Claude-Flow** | 250K+ LOC, 60+ agents, 170+ MCP tools. Massive scope creates maintenance burden and cognitive overload. Enterprise-grade architecture is overkill for solo builders. Self-promotional positioning ("Ranked #1") raises credibility questions. | Avoid feature/agent sprawl. Keep the system small, focused, and maintainable. ~8 agents, ~11 commands. |

### Newer Entrants Worth Monitoring

| Entrant | What They Bring | Relevance to Director |
|---------|----------------|----------------------|
| **Claude Code native Tasks (2.1+)** | Built-in task management with DAG dependencies, session persistence, and multi-session coordination via CLAUDE_CODE_TASK_LIST_ID. Inspired by Beads. | HIGH -- Director should build on top of native Tasks rather than reimplementing task state management. Native Tasks provides the persistence and dependency layer; Director adds the workflow intelligence (interview, verification, documentation sync) on top. |
| **Deep Trilogy** | Three plugins (/deep-project, /deep-plan, /deep-implement) that decompose ideas into components, plan thoroughly with research and interviews, and implement with TDD and adversarial code review. | MEDIUM -- Shows that multi-plugin composition works. Director is a single unified plugin rather than three separate ones, which is simpler for vibe coders. The adversarial review sub-agent pattern is worth studying. |
| **cc-sdd** | Kiro-style spec-driven development commands for Claude Code. 8 agents, requirements-design-tasks workflow, parallel execution ready. Multi-tool support. | MEDIUM -- Validates the spec-driven approach. Targets teams rather than solo vibe coders. Director differentiates on plain language and guided workflow. |
| **Kiro (AWS)** | Full IDE with spec-driven development (requirements.md, design.md, tasks.md). Agent hooks trigger on file save. Dual mode: spec-driven and vibe coding. | LOW for direct competition (different product category -- IDE vs plugin), but HIGH for validating the market. AWS putting weight behind spec-driven development confirms the approach is mainstream. Kiro's EARS format for acceptance criteria is worth studying. |
| **Claude Squad** | Manages multiple Claude Code instances in separate workspaces for parallel tasks. | LOW -- Solves parallelism but not planning or verification. Director's Phase 3 agent teams serve a similar purpose with more structure. |
| **Simone** | Project management workflow with documents, guidelines, and processes. | LOW -- General-purpose PM workflow without the spec-driven or vibe-coder focus. |

---

## Sources

### Primary Competitors (Verified via GitHub + Official Docs)
- GSD: https://github.com/glittercowboy/get-shit-done -- HIGH confidence
- Autospec: https://github.com/ariel-frischer/autospec -- HIGH confidence
- Beads: https://github.com/beads (Steve Yegge) -- HIGH confidence
- OpenSpec: https://github.com/Fission-AI/OpenSpec -- HIGH confidence
- Spec-Kit: https://github.com/github/spec-kit -- HIGH confidence
- Superpowers: https://github.com/obra/superpowers -- HIGH confidence
- Claude Task Master: https://github.com/eyaltoledano/claude-task-master -- HIGH confidence
- Vibe-Kanban: https://github.com/BloopAI/vibe-kanban -- HIGH confidence

### Newer Entrants (Verified via GitHub)
- Claude-Flow: https://github.com/ruvnet/claude-flow -- MEDIUM confidence (claims require independent verification)
- Deep Trilogy: https://pierce-lamb.medium.com/the-deep-trilogy-claude-code-plugins-for-writing-good-software-fast-33b76f2a022d -- MEDIUM confidence
- cc-sdd: https://github.com/gotalab/cc-sdd -- MEDIUM confidence
- Kiro: https://kiro.dev/ -- HIGH confidence (AWS-backed)

### Market Context
- Addy Osmani on conductors vs orchestrators: https://addyosmani.com/blog/future-agentic-coding/ -- HIGH confidence
- Claude Code native Tasks: https://venturebeat.com/orchestration/claude-codes-tasks-update-lets-agents-work-longer-and-coordinate-across -- MEDIUM confidence
- Awesome Claude Code: https://github.com/hesreallyhim/awesome-claude-code -- MEDIUM confidence (curated list, may not be comprehensive)
- Beads influencing Anthropic: https://paddo.dev/blog/from-beads-to-tasks/ -- MEDIUM confidence

### Director's Own Design Docs (Analyzed)
- /Users/noahrasheta/Dev/GitHub/director/docs/design/research-competitive-analysis.md -- PRIMARY source
- /Users/noahrasheta/Dev/GitHub/director/docs/design/PRD.md -- PRIMARY source
- /Users/noahrasheta/Dev/GitHub/director/docs/design/research-director-brainstorm.md -- PRIMARY source

---
*Feature research for: AI coding orchestration frameworks / Claude Code plugins*
*Researched: 2026-02-07*
