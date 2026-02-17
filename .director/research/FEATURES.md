# Feature Research

**Analysis Date:** 2026-02-16
**Confidence:** HIGH

---

## Feature Landscape

Director is an AI coding workflow orchestration plugin for Claude Code, targeting vibe coders (solo builders who think in outcomes, not syntax). The product category sits at the intersection of AI coding agents, project management tooling, and spec-driven development frameworks. Features are evaluated against this product type, its target user, and the competitive landscape (8 comparable tools analyzed: GSD, OpenSpec, Beads, Autospec, Spec-Kit, Superpowers, Claude Task Master, Vibe-Kanban).

### Must-Haves

Features users expect when they adopt an AI coding workflow orchestration tool. Missing these makes the product feel incomplete or untrustworthy.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Interview-based vision capture | Users need help articulating what they want to build before planning begins; jumping to code without this is the core problem the product solves | LOW | Implemented via `director-interviewer` agent; one question at a time, multiple choice when possible |
| Gameplan generation (Goals > Steps > Tasks) | Users need a structured, reviewable plan before executing; building without a plan is what they are running away from | MEDIUM | Implemented in `/director:blueprint`; hierarchy is the simplest that preserves meaning |
| Task execution with fresh AI context | Context accumulation is the primary cause of quality degradation in long AI sessions; this is the product's core technical insight | MEDIUM | Implemented in `/director:build`; each task gets fresh XML-wrapped context package |
| Progress tracking and status board | Users need to know what is done, what is in progress, and what is next; text-only status files are not enough for vibe coders | LOW | Implemented in `/director:status`; visual progress board showing all Goals/Steps/Tasks |
| Session resume after breaks | Users close the terminal and come back later; losing context kills productivity | LOW | Implemented in `/director:resume`; session-start hook loads state summary automatically |
| Goal-backward verification | Completing tasks is not the same as achieving the goal; users need to confirm that what was built matches what was asked for | MEDIUM | Implemented in `/director:inspect`; three-tier strategy (structural + behavioral checklist + optional tests) |
| Undo / revert last change | Mistakes happen; users need a safe escape hatch without needing to understand git | LOW | Implemented in `/director:undo`; wraps git revert in plain language |
| Plain-language output throughout | Vibe coders are not traditional developers; jargon like "dependencies", "worktrees", "artifact wiring" destroys confidence and trust | LOW | Enforced via `reference/terminology.md` and `reference/plain-language-guide.md`; forbidden jargon list maintained |
| Brownfield (existing project) onboarding | Most users already have a codebase they want to extend; greenfield-only tools miss this critical use case | HIGH | Implemented via deep-mapper pipeline; 4 parallel agents analyze stack, architecture, quality, concerns |
| Idea capture outside of active planning | Good ideas arrive at inconvenient moments; users need a lightweight capture mechanism that does not interrupt the build loop | LOW | Implemented in `/director:idea` (capture) and `/director:ideas` (review); stored in `IDEAS.md` |
| Mid-project direction changes | Real projects change; a tool that cannot handle a pivot forces the user to start over or abandon the framework entirely | MEDIUM | Implemented in `/director:pivot`; delta-spec approach tracks what was added, modified, or removed |
| Atomic, reversible progress saves | Users need to trust that every completed task is safely preserved; "I lost my work" is a trust-destroying failure mode | LOW | Implemented via atomic git commits per task; abstracted to "Progress saved" in user-facing output |

### Nice-to-Haves

Features that provide meaningful competitive advantage without being essential for a working product.

| Feature | Value | Complexity | Notes |
|---------|-------|------------|-------|
| Domain research before building | Surfaces ecosystem best practices, pitfalls, and tech choices before the user makes mistakes that require rewrites | HIGH | Implemented in v1.1 via parallel researcher agents during onboard; produces STACK.md, FEATURES.md, ARCHITECTURE.md, PITFALLS.md |
| Complexity indication per task | Vibe coders have no intuition for scope; knowing "this is a large task" vs "this is a small tweak" sets expectations and prevents surprise | LOW | Partially in blueprint (small/medium/large labels); not yet surfaced prominently in user-facing output |
| Brainstorming mode with full project context | Users need a thinking partner who knows their project; generic chatting forgets the codebase | LOW | Implemented in `/director:brainstorm`; loads VISION.md + GAMEPLAN.md + recent state |
| Quick task without full planning | Not every task needs a full plan; power users need an escape hatch for one-off work | LOW | Implemented in `/director:quick`; full context loading but no gameplan required |
| Codebase refresh / re-analysis | As projects grow, the initial codebase analysis becomes stale; users need a way to bring it back up to date | MEDIUM | Implemented in `/director:refresh`; threshold logic for detecting staleness is still undefined (known gap) |
| Parallel agent execution during analysis | Users tolerate one-time onboarding delay if it is short; serial analysis of large codebases is unacceptably slow | HIGH | Implemented; 4 parallel mapper agents + 4 parallel researcher agents during onboard |
| Two-stage review (spec compliance then quality) | Polishing code that does not match the spec wastes time; order of verification matters | MEDIUM | Partial implementation; Tier 1 (structural) + Tier 2 (behavioral) but quality review is not formally separated from spec compliance |
| Coordinated multi-task agent teams | For experienced users with large gameplans, running independent tasks in parallel dramatically reduces total build time | HIGH | Planned for Goal 3 (Phase 3); sub-agents within a single task are the MVP equivalent |
| Visual Kanban board | Vibe coders respond to visual feedback better than text-only status files; a board makes progress emotionally satisfying | HIGH | Planned for Goal 3; current `/director:status` is text-based |
| Effort controls mapped to task complexity | Cost optimization: do not pay for deep AI reasoning on trivial operations | MEDIUM | Planned; Opus 4.6 effort controls (Low/Medium/High/Max) mapped to Action/Task/Step/Gameplan hierarchy |
| Version check enforcement | Silent failures when the plugin is installed on an incompatible Claude Code version destroy user trust | LOW | Currently a known gap; no version check exists at runtime despite requirement for Claude Code v1.0.33+ |
| Learning tips based on usage patterns | Vibe coders are learning the craft; contextual tips accelerate their development as AI directors | MEDIUM | Planned for Goal 2 (Intelligence); not yet implemented |
| Automated test framework integration | Power users who adopt Jest/Vitest/pytest should get Tier 3 verification automatically | MEDIUM | Planned for Goal 2; opt-in, never required |

### Avoid Building

Features that seem valuable but create problems for this product and audience.

| Feature | Why Tempting | Why Problematic | Better Approach |
|---------|--------------|-----------------|-----------------|
| Git workflow exposure (branches, commits, SHAs, merges) | Power users ask for it; it feels like a missing feature | Vibe coders did not sign up for a git tutorial; exposing git operations destroys the "AI handles the details" promise and creates a new failure domain the user is not equipped to navigate | Abstract all git to "Progress saved" and "Undo last change"; never surface branch names, commit SHAs, or merge operations to users |
| Full DAG-based parallel task execution (MVP) | Makes the system feel more sophisticated; promises faster builds | Dependency graph resolution for parallel tasks requires the user to understand what "blocked" means, creates race conditions in the `.director/` state files, and multiplies the failure surface before the core workflow is proven | Use sub-agents within a single task for MVP parallelism; graduate to coordinated agent teams in Goal 3 only after the single-task loop is battle-hardened |
| TDD enforcement | Makes the product look serious to developers | Vibe coders do not write tests first; enforcing TDD breaks the workflow before it starts, adds a mandatory learning curve, and signals "this tool is for developers, not me" | Offer a three-tier verification strategy: structural AI checks (automatic), behavioral checklists (user confirms), automated test frameworks (opt-in for users who already have them) |
| Role-based handoffs (designer / developer / reviewer personas) | Makes the tool feel like a real team | Solo builders play all roles; adding persona switching creates cognitive overhead with no benefit; a solo builder does not need to "hand off to reviewer mode" | Keep Director opinionated about the workflow; the user directs, Director orchestrates, AI executes — no role-switching needed |
| Git worktree management | Sophisticated users want feature branch isolation | Worktrees require understanding branches, merge strategies, and conflict resolution — exactly the expertise vibe coders do not have | Use atomic commits on the main branch; the undo command is the safety net |
| Constitutional governance / approval gates | Enterprise-facing feature; signals maturity | Solo builders find approval gates frustrating and condescending; they chose solo building specifically to escape process overhead | Use behavioral checklists at Step/Goal boundaries (user confirms, not approves); keep confirmation lightweight |
| Risk assessment in plans | Developers find this reassuring | Vibe coders do not have the technical context to evaluate risk; showing risk scores without explanation creates anxiety; showing them with explanation adds jargon | Surface concerns in plain language when they are actionable ("This step changes how login works — test it before moving on"); do not quantify risk |
| Exposing Director as an MCP server | Makes Director integrable with other tools | Director is a plugin, not a server; building MCP exposure before the core workflow is proven fragments the maintenance surface and distracts from the primary use case | Keep Director as a plugin; it inherits whatever MCP servers the user has configured in Claude Code automatically |

---

## Feature Priorities

Ordered by user value and build cost for planning purposes.

| Feature | User Value | Build Cost | Priority |
|---------|------------|------------|----------|
| Interview-based vision capture | HIGH | LOW | P1 |
| Gameplan generation (Goals > Steps > Tasks) | HIGH | MEDIUM | P1 |
| Task execution with fresh AI context | HIGH | MEDIUM | P1 |
| Plain-language output throughout | HIGH | LOW | P1 |
| Progress tracking and status board | HIGH | LOW | P1 |
| Session resume after breaks | HIGH | LOW | P1 |
| Goal-backward verification | HIGH | MEDIUM | P1 |
| Undo / revert last change | HIGH | LOW | P1 |
| Brownfield onboarding | HIGH | HIGH | P1 |
| Mid-project direction changes (pivot) | HIGH | MEDIUM | P1 |
| Idea capture mechanism | MEDIUM | LOW | P1 |
| Atomic progress saves (abstracted git) | HIGH | LOW | P1 |
| Domain research before building | HIGH | HIGH | P2 |
| Brainstorming mode | MEDIUM | LOW | P2 |
| Quick task without planning | MEDIUM | LOW | P2 |
| Codebase refresh / re-analysis | MEDIUM | MEDIUM | P2 |
| Complexity indication per task | MEDIUM | LOW | P2 |
| Version check enforcement | MEDIUM | LOW | P2 |
| Two-stage review | MEDIUM | MEDIUM | P2 |
| Learning tips based on usage patterns | MEDIUM | MEDIUM | P2 |
| Automated test framework integration | LOW | MEDIUM | P2 |
| Coordinated multi-task agent teams | HIGH | HIGH | P3 |
| Visual Kanban board | MEDIUM | HIGH | P3 |
| Effort controls mapped to task complexity | MEDIUM | MEDIUM | P3 |
| Multi-model AI provider abstraction | LOW | HIGH | P3 |

Priority key: P1 = must have for launch, P2 = should have when possible, P3 = future consideration.

---

## What Competitors Do

How similar products handle the key differentiating features.

| Feature | How Others Do It | Director's Approach |
|---------|------------------|---------------------|
| Vision capture | GSD uses free-form text requirements; OpenSpec uses delta-spec diffs; most others skip vision entirely and start from task lists | Interview one question at a time, multiple choice when possible; surfaces decisions users have not considered (auth, hosting, tech stack); produces plain-language Vision document |
| Plan hierarchy | GSD: Project > Milestone > Phase > Plan; OpenSpec: flat delta-spec changes; Beads: dependency graph; Claude Task Master: tasks + subtasks | Director: Project > Goal > Step > Task; four levels simplified to three user-visible levels; Actions are invisible; terminology maps to natural English |
| Context management | GSD: 6-layer context management (STATE.md, @-loading, history files, continue-here.md, per-agent allocation, git history); Autospec: phase isolation; most others: accumulate everything | Fresh XML-wrapped context package per task; session-start hook auto-loads project state summary; VISION.md is source of truth loaded into every agent |
| Verification | GSD: goal-backward structural checks; Spec-Kit: two-stage review; Vibe-Kanban: code review queue | Three-tier: Tier 1 structural AI checks (automatic, no test framework), Tier 2 behavioral checklists (user confirms), Tier 3 automated tests (opt-in); goal-backward framing not task completion |
| Progress visualization | GSD: text-only STATE.md; Vibe-Kanban: Kanban board desktop app; most others: CLI status commands | Text-based status board for MVP (Goal 1); full visual Kanban board planned for Goal 3 |
| Error / research output | All 8 competitors: raw technical language, developer jargon, XML/YAML formats | Plain English throughout; VISION.md written in natural language; forbidden jargon list enforced via reference docs; research summaries translated before presenting to user |
| Git abstraction | GSD: requires understanding branches and commits; most others: expose git directly | All git abstracted to "Progress saved" and "Undo last change"; branch names, SHAs, commit messages are never surfaced |
| Pivot / mid-project change | Most: require manual editing of spec files; OpenSpec: delta-spec system for changes | Dedicated `/director:pivot` command; delta-spec approach (ADDED/MODIFIED/REMOVED) preserves what was decided before the change |
| Brownfield support | GSD: `/gsd:map-codebase` (single agent, sequential); most: no brownfield support | 4 parallel deep-mapper agents (stack, architecture, quality, concerns) plus 4 parallel researcher agents; produces comprehensive codebase analysis before planning begins |

---

## Unexpected Features Worth Flagging

These are features that users of this product type often expect but may not have been mentioned explicitly. Flagged for gameplan consideration.

1. **Staleness detection thresholds** -- The infrastructure to track when codebase analysis was generated exists, but no rules define when it is "too old." Users do not know when to run `/director:refresh`. This is a known gap (Medium priority in Concerns). A clear threshold (e.g., "refresh recommended after 7 days or after 10+ tasks") would prevent silent context drift.

2. **Claude Code version check** -- The plugin requires Claude Code v1.0.33+ but no version check exists at runtime. Silent failures on older versions destroy user trust at first impression. A version check in `/director:onboard` is the obvious fix location.

3. **Onboarding for teams (future)** -- Director is explicitly solo-focused for v1. However, the marketing tagline and architecture are portable. Teams of 2-3 who use vibe coding workflows will ask about this. Explicitly marking the team use case as "future / not supported" in the documentation prevents confused expectations.

4. **Plugin discovery / marketplace listing** -- Users of similar tools (GSD, Superpowers) find tools via GitHub search, community forums, and the Claude Code marketplace. Director's marketplace listing metadata is now documented (v1.1.4) but the description and keywords matter for discoverability.

5. **Effort / scope estimation** -- Complexity labels (small/medium/large) exist in blueprint generation but are not prominently surfaced in the status board or task lists. Vibe coders specifically need scope signals — "is this a morning or a week?" — more than accuracy. Displaying complexity in `/director:status` output is low-effort, high-value.

---

## Sources

- Director competitive analysis (`docs/design/research-competitive-analysis.md`) — 8 open-source projects analyzed (GSD, OpenSpec, Beads, Autospec, Spec-Kit, Superpowers, Claude Task Master, Vibe-Kanban)
- Director PRD (`docs/design/PRD.md`) — feature requirements, target user persona, core principles
- Director codebase summary (`.director/codebase/SUMMARY.md`) — current implementation state and known gaps
- Claude Code official documentation (`https://code.claude.com/docs/en/overview`) — platform capabilities and skill/hook system
- Director marketing website (`https://director.cc`) — current positioning and feature advertising
- Director changelog (`CHANGELOG.md`) — v1.0 through v1.1.4 feature history
- Opus 4.6 strategy document (`docs/design/research-opus-46-strategy.md`) — planned capability integration

---

## Quality Gate

- [x] Must-haves represent genuine user expectations, not aspirational features
- [x] Avoid Building section has at least 2 entries with alternatives
- [x] Priorities reflect user value, not technical interest
- [x] No section left empty
- [x] Plain language throughout — no jargon
