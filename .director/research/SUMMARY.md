# Research Summary

**Project:** Director -- Claude Code Plugin
**Analysis Date:** 2026-02-16
**Confidence:** HIGH

## Executive Summary

Director is a Claude Code plugin that functions as an AI coding workflow orchestration framework for vibe coders -- solo builders who think in outcomes rather than syntax. The product sits at the intersection of AI coding agents, project management tooling, and spec-driven development. What makes it distinctive is the way it solves the core problems of AI-assisted development: context degradation over long sessions, lack of structured planning, and the mismatch between technical output and non-technical users. Expert builders in this category prioritize fresh AI context per task, plain-language communication throughout, and goal-backward verification over task completion counting.

The recommended approach is the layered plugin architecture already in place: a Skill layer handles user-facing orchestration, an Agent layer executes specialized work with scoped context, and a State layer persists all project intelligence as human-readable Markdown files. This architecture is well-matched to the domain. The key technical insight is that fresh XML-wrapped context packages per agent invocation -- rather than accumulated conversation history -- produce significantly better AI output at lower token cost. Parallel agent execution during onboarding keeps the one-time analysis fast while delivering comprehensive domain coverage.

The main risks break along two axes: security (mapper agents could expose secrets committed to the codebase) and reliability (syncer failure after task completion creates silent state drift). Both are known issues with clear mitigations. A third risk -- context accumulation via builder memory across pivots -- is more subtle and harder to detect. The gameplan should prioritize hardening these failure modes early, not leaving them as technical debt.

## Key Findings

### Recommended Stack

Director runs entirely as a Claude Code plugin with no external runtime dependencies. The stack is intentionally minimal: Markdown for all skills, agent definitions, reference docs, and templates; Bash for lifecycle hooks and scripts; JSON for manifests and machine-readable state; Git for atomic task commits. Claude Code v1.0.33+ is the required host platform -- this version requirement is currently not enforced at runtime, which is a known gap.

No npm, no Python frameworks, no templating engines, no databases, no CI/CD pipelines are needed or appropriate. The install model ("just add files") depends on this zero-dependency approach. Python 3.6+ is used only for reliable JSON parsing in one script, with a grep fallback if absent.

**Core technologies:**
- Claude Code Plugin System (v1.0.33+): Host platform for all slash commands, agents, and hooks -- the only supported runtime; no alternative exists
- Markdown (CommonMark): All skill workflows and agent definitions -- Claude Code reads `.md` files as instructions natively; no build step required
- Bash (v3+, v5+ preferred): Lifecycle scripts for session hooks and initialization -- zero additional dependencies, available everywhere Director runs
- Git (v2.0+): Atomic commits per task -- required; no alternative path exists in the current architecture
- JSON: Plugin manifest, hooks config, project config -- required format for Claude Code plugin infrastructure

### Expected Features

Director v1.0 and v1.1 ship a complete must-have feature set. Every table-stakes capability for an AI coding workflow orchestration tool is implemented: interview-based vision capture, structured gameplan generation (Goals > Steps > Tasks), fresh-context task execution, progress tracking, session resume, goal-backward verification, undo/revert, plain-language output throughout, brownfield onboarding via parallel deep mappers, idea capture, pivot handling, and atomic progress saves.

The differentiating features already implemented include parallel researcher agents during onboarding (4 simultaneous domain researchers), three-tier verification without requiring a test framework, and a forbidden jargon enforcement mechanism. Features planned for Goal 2 (intelligence layer) include learning tips, two-stage review, and automated test framework integration. Features deferred to Goal 3 include coordinated multi-task agent teams, a visual Kanban board, and effort controls mapped to task complexity.

**Must-haves (all implemented):**
- Interview-based vision capture -- prevents users from jumping to code without a clear plan
- Gameplan generation (Goals > Steps > Tasks) -- the structured plan is the product's core promise
- Task execution with fresh AI context -- prevents quality degradation; 80%+ cost savings vs. accumulated context
- Session resume after breaks -- users close terminals; losing context kills productivity
- Goal-backward verification -- completing tasks is not the same as achieving goals
- Undo / revert last change -- safe escape hatch abstracted from git internals
- Plain-language output throughout -- vibe coders are not developers; jargon destroys trust
- Brownfield (existing project) onboarding -- most users have an existing codebase
- Mid-project pivot handling -- real projects change; tools that can't pivot get abandoned

**Nice-to-haves (partially implemented):**
- Complexity indication per task -- labels exist in blueprint but not prominently surfaced in status
- Version check enforcement -- Claude Code v1.0.33+ required but not checked at runtime
- Two-stage review -- structural + behavioral tiers exist; quality review not formally separated from spec compliance

**Defer for later:**
- Coordinated multi-task agent teams -- Goal 3; sub-agents within a task are the MVP equivalent
- Visual Kanban board -- Goal 3; current status is text-based
- Effort controls mapped to task complexity -- Goal 3; Opus 4.6 effort control integration
- Multi-model AI provider abstraction -- Goal 3; Claude-only for v1

### Architecture Approach

The architecture is a three-layer system: a Skill layer (user-facing orchestration, 14 slash commands), an Agent layer (specialized AI workers with scoped tools and models), and a State layer (`.director/` project files as the single source of truth). Skills spawn agents via Task() with freshly assembled XML-wrapped context packages. Agents read from and write to the state layer but follow single-writer discipline (only the syncer writes STATE.md). Lifecycle hooks (SessionStart/SessionEnd) integrate with Claude Code's event system via Bash scripts.

The architecture is intentionally additive: new agents are added by creating `director-*.md` files; new commands are added by creating `skills/command-name/SKILL.md`. There is no auto-registration -- skills must explicitly spawn agents. This design keeps behavior intentional and traceable.

**Major components:**
1. Skill layer (`skills/*/SKILL.md`) -- User-facing orchestration; checks prerequisites, routes on conditions, assembles XML context, spawns agents, presents results in plain language
2. Agent layer (`agents/director-*.md`) -- Specialized AI workers (builder, verifier, syncer, planner, interviewer, researcher, deep-researcher, synthesizer, mapper, deep-mapper, debugger); each receives a minimal, scoped context package
3. State layer (`.director/`) -- VISION.md (source of truth), GAMEPLAN.md (plan), STATE.md (progress, syncer-owned), goals/ tree (task files), codebase/ and research/ analysis outputs; all committed to git
4. Hooks/scripts layer (`scripts/`, `hooks/`) -- Bash lifecycle integration; session-start loads project state summary automatically

### Critical Pitfalls

1. **Secret exposure via mapper agents** -- Mapper agents read source files to produce codebase analysis. If a user has committed `.env` or credential files, sensitive values can be quoted into `.director/codebase/` files and then committed to git permanently. Protection is instruction-based only (no tooling enforcement). Add a pre-onboard Bash scan for secret file patterns and present a warning before proceeding. This is the only HIGH-priority security issue.

2. **Silent state drift from syncer failure** -- The syncer runs after the builder commits code. If the syncer crashes or times out, the code commit exists but STATE.md and task file renaming do not complete. The next build scan may re-run, skip, or missequence tasks. The build skill should verify syncer completion before reporting task done, and surface an explicit error if the syncer fails.

3. **Context accumulation via builder memory across pivots** -- The builder uses `memory: project` for consistency. Memory is not cleared when `/director:pivot` or `/director:refresh` runs. After a major architecture change, the builder may apply stale patterns from old goals. Add explicit memory-clearing guidance to the pivot skill and a "Pattern Changes" section to STEP.md files.

4. **Deep mapper timeout on large codebases** -- The deep mapper is capped at 40 turns. For projects with 500+ source files, a single mapper may exhaust its limit before completing. The fallback to the v1.0 mapper runs silently, producing degraded codebase context. Add a pre-onboard file count check and warn users with large codebases. Implement graceful partial results rather than silent degradation.

5. **Template detection failures in skill routing** -- Skills route based on detecting placeholder strings in VISION.md and GAMEPLAN.md. If users manually edit these files and change the placeholder text, routing breaks silently. Build secondary content checks (section character count) alongside string matching to make detection more robust.

## Implications for Gameplan

Based on combined research, the following goal/step structure is suggested.

### Suggested Structure

**Goal 1: Core Workflow (MVP)**
- **Rationale:** All 12 must-have features (P1) are already implemented. Goal 1 is about hardening, not building. The syncer failure, template detection, and secret exposure pitfalls affect every user on their first run -- they need to be mitigated before feature work expands.
- **Delivers:** A reliable core loop (onboard → blueprint → build → inspect) that users can trust completely.
- **Addresses:** Session resume, progress tracking, undo, brownfield onboarding, pivot, atomic saves, plain-language output (all implemented); version check enforcement (known gap; low effort, high trust value)
- **Avoids:** Syncer failure state drift (Pitfall 2), template detection failures (Pitfall 5), context accumulation across pivots (Pitfall 3)
- **Steps:**
  - Security hardening: add pre-onboard secret file scan (addresses Pitfall 1 directly)
  - Reliability hardening: syncer health check + explicit failure surfacing (addresses Pitfall 2)
  - Version check at onboard: enforce Claude Code v1.0.33+ requirement at runtime (addresses known FEATURES.md gap)
  - Pivot memory reset: add memory-clearing guidance and "Pattern Changes" section to pivot workflow (addresses Pitfall 3)
  - Template detection robustness: secondary content check alongside string matching (addresses Pitfall 5)

**Goal 2: Intelligence Layer**
- **Rationale:** Once the core loop is reliable, the differentiating features from FEATURES.md (P2) add meaningful competitive value. These features build on a stable foundation -- implementing them on top of an unreliable core loop creates confusing failure modes.
- **Delivers:** Learning tips, two-stage review, automated test framework integration, enhanced research summaries, complexity indication in status.
- **Addresses:** Complexity indication per task (P2 -- labels exist but not surfaced), two-stage review (P2 -- partial), automated test framework integration (P2), learning tips (P2), staleness detection thresholds for `/director:refresh` (flagged in FEATURES.md as a known gap)
- **Avoids:** Deep mapper timeout on large codebases (Pitfall 4 -- needs explicit threshold logic for refresh staleness detection)
- **Steps:**
  - Complexity display in `/director:status` output (low effort, high user value per FEATURES.md priority table)
  - Staleness threshold logic for `/director:refresh` (addresses FEATURES.md gap and Pitfall 4 co-concern)
  - Two-stage review formalization (separate spec compliance from quality check in the verify loop)
  - Automated test framework integration (opt-in Tier 3 verification for Jest/Vitest/pytest)
  - Learning tips based on usage patterns

**Goal 3: Power Features**
- **Rationale:** Coordinated multi-task agent teams, visual Kanban board, and effort controls are P3 features with HIGH build cost. They should only be attempted after the core loop is proven reliable and the intelligence layer is delivering value. The parallel agent timeout concern (Pitfall 4) must be resolved before multi-task parallelism is expanded.
- **Delivers:** Full coordinated agent teams, visual progress board, effort-to-model mapping, multi-platform portability.
- **Addresses:** Coordinated multi-task agent teams (P3), visual Kanban board (P3), effort controls mapped to task complexity (P3), multi-model provider abstraction (P3)
- **Avoids:** Parallel agent hardcoded dependency (Architecture anti-pattern) -- explicit fallback handling required before expanding parallelism; accumulating conversation history (Architecture anti-pattern) -- must not regress when adding team coordination
- **Steps:**
  - Parallel agent fallback handling (resolve the anti-pattern before expanding agent parallelism)
  - Coordinated multi-task agent teams (spawns multiple build workers across independent tasks)
  - Visual Kanban board (replaces text-only `/director:status`)
  - Effort controls: map Low/Medium/High/Max to Action/Task/Step/Gameplan hierarchy using Opus 4.6 effort controls

### Ordering Rationale

- Goal 1 before Goal 2 because hardening failures (pitfalls 1-5) affect every user and every feature; adding intelligence on top of a broken core wastes effort
- Goal 2 before Goal 3 because multi-task parallelism (Goal 3) requires a reliable single-task loop (Goal 1 + Goal 2) as its foundation; expanding a broken loop multiplies failure surface
- Security hardening (Pitfall 1) comes first within Goal 1 because secret exposure is permanent and irreversible once committed -- it cannot be undone after the fact
- Complexity indication and staleness thresholds are early Goal 2 items because they are low-effort, high-signal for users who are already running the core workflow
- Multi-platform support is the last Goal 3 item because it requires the entire plugin to be stable and battle-tested before abstracting away the Claude Code dependency

### Research Flags

Areas likely needing deeper investigation during step planning:
- **Parallel agent fallback handling:** The current architecture has no explicit fallback when a parallel mapper or researcher fails. Before expanding multi-task agent teams (Goal 3), this needs a concrete design -- how to detect partial results, what to retry, and what to surface to the user.
- **Staleness detection thresholds:** FEATURES.md flags this as a known gap with no specific rules. The blueprint step for this will need to define concrete criteria (e.g., "7 days or 10+ tasks since last refresh") -- this requires user research or at least opinionated defaults.
- **Builder memory management after pivot:** The mechanism for clearing or invalidating builder memory is not well-defined. The `.claude/agent-memory/director-builder/` directory structure needs documentation and the pivot skill needs explicit guidance on when/how to clear it.
- **Mapper maxTurns calibration:** The 40-turn limit is a safety cap with no documented rationale. Before raising it (or implementing adaptive limits), understand what a 40-turn mapper actually covers at different codebase sizes.

Areas with standard patterns (minimal additional research needed):
- **Skill routing patterns:** Well-documented in the existing `build/SKILL.md` and `blueprint/SKILL.md` implementations; new skills follow the same canonical pattern.
- **Agent YAML frontmatter:** Fully verified against official Claude Code docs; no ambiguity about supported fields.
- **Atomic commit model:** Git amend-commit pattern is already implemented and working; no new design needed.
- **XML context assembly:** The context package format is defined and working; extensions follow the same `<tag>content</tag>` convention.
- **Plain-language output enforcement:** The forbidden jargon list and style guide are complete; new features just need to follow the existing reference docs.

## Don't Hand-Roll

Problems with existing library solutions. Building these from scratch wastes time and introduces bugs.

| Problem | Existing Solution | Why Not Build It |
|---------|-------------------|------------------|
| JSON parsing in Bash scripts | Python 3 `json.load()` (already used) or `jq` | Hand-rolled grep-based JSON parsing breaks on nested values, escaping edge cases, and multi-line strings; Python's json module handles all these correctly |
| Session lifecycle hooks (start/end events) | Claude Code's native `SessionStart`/`SessionEnd` hooks via `hooks/hooks.json` | Building a custom session management layer outside the hooks system means losing the guaranteed invocation timing and the `${CLAUDE_PLUGIN_ROOT}` environment injection that the hooks system provides |
| Plugin manifest and command registration | Claude Code plugin manifest (`plugin.json` + `skills/*/SKILL.md`) | Building a custom command dispatch system bypasses Claude Code's slash command routing and breaks the `/director:` prefix convention; the platform handles invocation and argument passing |
| Atomic version control per task | Git (already used for atomic commits) | Any hand-rolled "save progress" mechanism would need to replicate git's content-addressable storage, history traversal, and revert semantics -- months of work to get a worse result |
| Parallel agent execution | Claude Code's Task() tool (already used) | Building a custom async worker pool inside a plugin would require managing concurrency, timeouts, and result collection manually -- Task() handles all of this natively |
| Structured document templates with placeholder detection | Markdown with conventional marker strings (already implemented) | A full templating engine (Handlebars, Jinja2, Mustache) adds a rendering pipeline, compilation step, and escape-sequence complexity for what is currently solved with a single `grep` check |
| Secret scanning before codebase analysis | Pre-built secret detection patterns (truffleHog, git-secrets, or simple grep patterns) | Writing a comprehensive secret-detection regex library from scratch misses common patterns and adds ongoing maintenance; a curated grep pattern list for the most common formats (API keys, `.env` files, credential files) covers 90% of cases with 5% of the effort |

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | All findings verified against official Claude Code docs (code.claude.com/docs) and live codebase files read directly; no speculative dependencies |
| Features | HIGH | Feature landscape cross-referenced against competitive analysis of 8 comparable tools, the Director PRD, and the live changelog; all must-haves confirmed implemented |
| Architecture | HIGH | Patterns verified against official Claude Code plugin and sub-agent docs; component responsibilities verified against actual skill and agent files read directly |
| Pitfalls | HIGH | All pitfalls grounded in specific confirmed files (CONCERNS.md, build/SKILL.md, deep-mapper.md); warning signs are observable, not speculative |

**Overall confidence:** HIGH

## Gaps to Address

Areas where research was inconclusive or needs validation during implementation.

- **Staleness threshold for `/director:refresh`:** No concrete criteria exist for when codebase analysis is "too old." Must define opinionated defaults during Goal 2 step planning -- recommend starting with "7 days or 10+ completed tasks since last refresh."
- **Builder memory directory structure:** The `.claude/agent-memory/director-builder/` path is referenced in pitfall documentation but the actual format of memory files and how to safely clear them is not documented. Needs investigation during the pivot hardening step.
- **Mapper turn limit calibration:** The 40-turn limit for deep mappers has no documented rationale tied to actual codebase size measurements. Before implementing adaptive limits in Goal 1 or 2, run empirical tests on small/medium/large codebases to understand actual turn consumption.
- **Parallel agent partial result handling:** The architecture anti-pattern (hardcoded dependency on parallel agent success) is identified but no concrete implementation pattern for fallback is documented. Needs design work before Goal 3 multi-task agent teams.
- **Version check enforcement location:** The FEATURES.md identifies `/director:onboard` as the obvious fix location for the Claude Code version check, but this leaves users of other commands (e.g., `/director:build`) unprotected on older versions. Consider a session-start hook check as an alternative.

## Sources

### Primary (HIGH confidence)
- Claude Code official documentation (code.claude.com/docs/en/plugins, /sub-agents, /overview) -- plugin structure, manifest format, agent YAML frontmatter, skill format, hooks; verified 2026-02-16
- Director live codebase files (`.claude-plugin/plugin.json`, `hooks/hooks.json`, `scripts/session-start.sh`, `agents/director-builder.md`, `skills/build/SKILL.md`) -- confirmed implementation patterns and version compatibility
- `.director/codebase/CONCERNS.md` -- Director's own self-analysis identifying confirmed HIGH and MEDIUM priority issues

### Secondary (MEDIUM confidence)
- Director competitive analysis (`docs/design/research-competitive-analysis.md`) -- 8 open-source projects analyzed; feature landscape informed by competitor behavior, not just stated goals
- Director PRD (`docs/design/PRD.md`) -- stated feature requirements and target user persona; reflects intended behavior, which may differ from implemented behavior in edge cases
- Director marketing website (director.cc) -- current positioning; useful for understanding the user promise but not a technical reference

### Tertiary (LOW confidence)
- Staleness threshold defaults -- no empirical data exists; the "7 days or 10+ tasks" suggestion is an informed estimate, not a measured finding
- Mapper turn limit calibration -- the 40-turn limit impact at various codebase sizes has not been empirically tested; the 500-file threshold is an estimate from the pitfalls analysis

## Quality Gate

Before considering this file complete, verify:
- [x] Executive summary can stand alone -- someone reading only this section understands the conclusions
- [x] Key findings summarize, not duplicate, individual research files
- [x] Gameplan implications include specific goal/step suggestions
- [x] Don't Hand-Roll section has at least 3 entries
- [x] Confidence assessment is honest about uncertainties
- [x] All sections populated -- no placeholders remaining from researcher output
