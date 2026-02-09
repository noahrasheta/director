# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-02-07)

**Core value:** Vibe coders can go from idea to working product through a guided, plain-language workflow (Blueprint / Build / Inspect) that gives them professional development structure without requiring them to think like a developer.
**Current focus:** Phase 8 - Pivot & Brainstorm -- In progress

## Current Position

Phase: 8 of 10 (Pivot & Brainstorm)
Plan: 5 of 7 in current phase
Status: In progress
Last activity: 2026-02-09 -- Completed 08-05-PLAN.md (brainstorm template + opening steps)

Progress: [██████████░░░░░░] 67% (28/42 plans)

## Performance Metrics

**Velocity:**
- Total plans completed: 28
- Average duration: ~2m 16s
- Total execution time: ~63m 49s

**By Phase:**

| Phase | Plans | Total | Avg/Plan |
|-------|-------|-------|----------|
| 01-plugin-foundation | 7/7 | ~21.5m | ~3m |
| 02-onboarding | 2/2 | 6m 34s | 3m 17s |
| 03-planning | 2/2 | 4m 43s | 2m 22s |
| 04-execution | 2/2 | ~5m 30s | ~2m 45s |
| 05-verification | 3/3 | 5m 51s | 1m 57s |
| 06-progress-continuity | 4/4 | 7m | 1m 45s |
| 07-quick-mode-ideas | 3/3 | 5m 43s | 1m 54s |
| 07.1-user-decisions-context | 3/3 | 4m 13s | 1m 24s |
| 08-pivot-brainstorm | 2/7 | 2m 41s | 1m 21s |

**Recent Trend:**
- Last 5 plans: 07.1-01 (1m 34s), 07.1-02 (1m 01s), 07.1-03 (1m 38s), 08-01 (1m 14s), 08-05 (1m 27s)
- Trend: stable, consistently under 2m 30s

*Updated after each plan completion*

## Accumulated Context

### Roadmap Evolution

- Phase 7.1 inserted after Phase 7: User decisions context -- Decisions artifact in STEP.md flows into builder context (INSERTED)

### Decisions

Decisions are logged in PROJECT.md Key Decisions table.
Recent decisions affecting current work:

- [Roadmap]: 10 phases derived from 88 requirements across 9 categories, with FLEX split into Quick/Ideas (Phase 7) and Pivot/Brainstorm (Phase 8) for cleaner delivery boundaries
- [Roadmap]: Phases 5-8 all depend on Phase 4, enabling potential parallel work after execution engine is built
- [Roadmap]: Phase 7.1 inserted to close gap where user intent gets lost between blueprint interview and task execution
- [01-01]: Plugin manifest uses name "director" to namespace all skills as /director:*
- [01-01]: Only plugin.json inside .claude-plugin/; all other components at plugin root
- [01-01]: Config defaults are opinionated (guided mode, tips/verification/cost-tracking/doc-sync all on)
- [01-01]: Agent models: inherit for complex agents, haiku for lightweight (mapper, verifier, syncer)
- [01-02]: Never-use word list has 30+ jargon terms in 4 categories for consistent plain-language output
- [01-02]: Two verification severity levels: "needs attention" (blocking) and "worth checking" (informational)
- [01-02]: Agent-specific context profiles table defines what each of 8 agents receives
- [01-02]: Context budget calculator deferred to Phase 4 with design notes captured in reference doc
- [01-03]: Help skill uses dynamic context injection (cat STATE.md) for mini-status
- [01-03]: Help groups commands into Blueprint/Build/Inspect/Other matching Director's core loop
- [01-03]: Onboard routing checks VISION.md content quality (not just existence) to detect empty templates
- [01-03]: Blueprint routing redirects to onboard conversationally when vision is missing
- [01-03]: Config defaults template uses nested object format for agent models (matching plan spec)
- [01-03]: All routing messages follow four-step pattern: state situation, explain why, suggest action, wait for response
- [01-04]: All routing messages are conversational ("Want to..." not "Run /director:...")
- [01-04]: Idea skill is partially functional in Phase 1 -- actually captures ideas to IDEAS.md
- [01-04]: Build skill has exact multi-step routing: project -> vision -> gameplan -> ready task
- [01-04]: Status and resume use dynamic context injection to load STATE.md at invocation time
- [01-05]: Interviewer disallows WebFetch in addition to Write/Edit (research is researcher's domain)
- [01-05]: Mapper disallows WebFetch in addition to Write/Edit (local codebase only)
- [01-05]: All agents document XML context expectations inline for self-documenting prompts
- [01-06]: Builder is the only agent with memory: project in Phase 1 (others deferred to Phase 2)
- [01-06]: Verifier uses hard deny (disallowedTools); syncer uses soft instruction for scope restriction
- [01-06]: Debugger has full write access to apply fixes directly during verification cycles
- [01-07]: Marketplace manifest uses GitHub source type with min_claude_code_version 1.0.33
- [01-07]: README targets vibe coders, not developers -- consistent with Director's audience
- [01-07]: Plugin verified working: all 11 commands register, all 8 agents load, routing works
- [02-01]: Interview runs inline (Approach A) rather than spawning interviewer as sub-agent -- simpler, more natural conversation
- [02-01]: Brownfield detection present but temporarily redirects to greenfield interview (full brownfield is Plan 02-02)
- [02-01]: Dual-template detection handles both init-script and onboard template placeholders
- [02-02]: Mapper runs in foreground (not background) so user sees findings before interview begins
- [02-02]: Brownfield interview has 7 sections adapted from 8 greenfield sections, skipping mapper-answered questions
- [02-02]: Delta format uses Existing/Adding/Changing/Removing labels in VISION.md Key Features
- [02-02]: Already-onboarded re-entry path fully functional with both update and map options
- [03-01]: Planner rules 1-6 embedded inline in blueprint skill rather than referencing agent file
- [03-01]: Two approval checkpoints in blueprint: goal-level review, then full hierarchy review
- [03-01]: Update mode detection uses triple-signal check (init phrase + placeholder text + absence of real goals)
- [03-01]: [UNCLEAR] markers checked before planning with option to resolve or defer
- [03-02]: Update mode uses same two-phase approval flow as new mode (goals first, then full hierarchy)
- [03-02]: Completed work is FROZEN during updates -- never removed/reordered/modified without explicit user agreement
- [03-02]: Delta summary always includes "Already done" section for reassurance
- [03-02]: Holistic re-evaluation even with focused $ARGUMENTS -- additions may affect ordering/grouping elsewhere
- [03-02]: Removed items require explicit reasoning in delta summary -- no silent deletions
- [04-01]: Builder may amend its own task commit during verification fix cycles
- [04-01]: Syncer changes get amend-committed by build skill, not by syncer itself
- [04-01]: Task file rename (.done.md) is the syncer's responsibility
- [04-02]: Build skill runs inline (no context: fork) with Task tool spawning for builder agent
- [04-02]: Context budget threshold is 30% of 200K tokens (60K tokens), estimated via chars/4
- [04-02]: Truncation order: git log first, reference docs second, STEP.md third, never task/vision
- [04-02]: Syncer changes amend-committed to maintain one commit per task
- [04-02]: STATE.md and .done.md renames applied automatically; VISION.md/GAMEPLAN.md drift requires user confirmation
- [05-01]: Agent output contracts: structured parseable lines alongside plain-language output for downstream skill consumption
- [05-01]: Auto-fixable classification uses simple yes/no with category-based rules (stubs/wiring = yes; design decisions = no)
- [05-01]: Debugger already had correct Status format; only addition was context sentence for build skill
- [05-02]: Celebration timing: always AFTER Tier 2 results, not before -- prevents premature celebration
- [05-02]: Behavioral checklist is guidance, not a gate -- users can continue building without completing it
- [05-02]: Defensive fallback: missing Status line in debugger output treated as "Needs manual attention"
- [05-02]: Step 9 unchanged from Phase 4 -- sync verification logic needs no modification for verification flow
- [05-03]: Inspect always shows results (even clean) since the user explicitly asked -- differs from build pipeline behavior
- [05-03]: Tier 2 behavioral checklist always runs for inspect regardless of scope (build only triggers at boundaries)
- [05-03]: Focused scope searches GAMEPLAN/step/task files for matching text and stops with helpful message if no match
- [05-03]: Checklist is guidance, not a gate -- user can stop without completing it
- [06-01]: Keep flat-array hooks.json format rather than migrating to nested event-keyed format (existing format works since Phase 1)
- [06-01]: cost_rate defaults to $10/1M tokens for Opus-class models, stored in config-defaults.json
- [06-01]: SessionEnd hook only updates timestamps (lightweight), never recalculates progress
- [06-02]: Cost formula uses (context_chars / 4) * 2.5 for estimated tokens (input + output/reasoning)
- [06-02]: Idempotent cost tracking via task file path in Recent Activity entries (prevents double-counting on retries)
- [06-02]: Decisions extraction uses phrase detection from builder output (no structured output required)
- [06-03]: File system is authoritative over STATE.md for progress counts (ground truth via .done.md counting)
- [06-03]: Blocked step detection reads first pending task's Needs First section (consistent with build skill algorithm)
- [06-04]: Default to 1-7 days tone when Last session is missing or unparseable (safest middle ground)
- [06-04]: Same-day Last session uses under-2-hours tone since field stores dates not times
- [06-04]: Skip external changes section entirely for short breaks with no changes (reduces noise)
- [06-04]: Lockfiles only flagged if corresponding manifest also changed
- [07-01]: Quick mode does not require vision or gameplan -- works on bare .director/ projects
- [07-01]: Scope-based complexity detection uses semantic patterns (architectural language, multi-system, cross-cutting) not file counting
- [07-01]: Builder instructions explicitly override default commit format with [quick] prefix; skill has fallback amend
- [07-01]: Verification and doc sync are builder-internal via instructions, not separate skill steps
- [07-01]: Post-task summary adapts verbosity: one-liner for trivial, paragraph for substantial
- [07-02]: IDEAS.md insertion anchored to `_Captured ideas_` description line (shared contract between idea skill, ideas skill, and init template)
- [07-02]: Idea text preserved exactly as typed -- no reformatting, summarizing, or editing
- [07-02]: Single-line confirmation ("Got it -- saved to your ideas list.") with no follow-up questions or suggestions
- [07-03]: Brainstorm route keeps idea in IDEAS.md (exploration is not action); quick and blueprint routes remove it
- [07-03]: Quick route executes inline via builder (same flow as quick skill); blueprint/brainstorm direct user to run command
- [07-03]: $ARGUMENTS support enables direct idea matching (e.g., /director:ideas "dark mode" jumps to matching idea)
- [07.1-01]: Decisions section goes LAST in STEP.md template (after Needs First)
- [07.1-01]: Builder is the only agent that receives <decisions> context (Yes in profiles table)
- [07.1-01]: <decisions> tag positioned between <current_step> and <task> in assembly order
- [07.1-01]: Decisions are never truncated (added as rule 5 alongside task and vision)
- [07.1-02]: Decisions extraction reuses STEP.md content already loaded in Step 5b (no additional file read)
- [07.1-02]: Instructions template reinforces decision rules as dual reinforcement alongside <decisions> tag
- [07.1-02]: Context budget character count updated in both Step 5f and cost_data to include decisions
- [07.1-03]: Decision capture is passive -- extracted from natural conversation, never an interrogation step
- [07.1-03]: Cross-cutting decisions are duplicated into every relevant step (no inheritance mechanism)
- [07.1-03]: Capture happens after hierarchy approval and before file writing
- [07.1-03]: Update mode freezes completed-step decisions, merges new decisions into modified steps
- [07.1-03]: Planner does not write decisions -- notes preferences for blueprint skill to capture
- [08-01]: Pivot conversation runs inline (no interviewer agent spawning), consistent with onboard/blueprint patterns
- [08-01]: Scope detection uses signal heuristic with explicit A/B fallback to user when ambiguous
- [08-01]: Template detection patterns in pivot match build and blueprint skills exactly
- [08-01]: Pivot-positive framing in language reminders: changing direction is learning, not failure
- [08-05]: Brainstorm does not require a gameplan -- works with just a vision (differs from pivot)
- [08-05]: Template detection reuses build skill pattern (placeholder text and italic prompts)
- [08-05]: Open-ended entry is minimal: just "What are you thinking about?" with no qualifiers or examples
- [08-05]: Topic-specific entry echoes user's exact words from $ARGUMENTS rather than rephrasing
- [08-05]: Tone guidance prioritizes exploration over action: ideas are valuable even without a next step

### Pending Todos

None yet.

### Blockers/Concerns

- [Research]: Claude Code v1.0.33+ required for `context: fork` in skills -- verify version compatibility early in Phase 1
- [Research]: Context budget calculator needed to prevent context rot in fresh agent windows -- design during Phase 1, implement in Phase 4 -- RESOLVED in 04-02 (chars/4, 60K threshold)
- [Research]: Documentation sync should never auto-commit -- always present findings to user first -- RESOLVED in 04-02 (drift requires user confirmation)

## Session Continuity

Last session: 2026-02-09
Stopped at: Completed 08-05-PLAN.md (brainstorm template + opening steps)
Resume file: None
