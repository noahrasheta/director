---
phase: 05-verification
plan: 03
subsystem: verification
tags: [inspect, verification, tier-1, tier-2, scope-awareness, auto-fix, behavioral-checklist]

# Dependency graph
requires:
  - phase: 01-plugin-foundation
    provides: "Inspect skill stub, verifier agent, debugger agent, verification patterns reference"
  - phase: 05-verification
    plan: 01
    provides: "Structured output formats for verifier (auto-fixable classification) and debugger (Status line)"
provides:
  - "Fully functional /director:inspect command with scope-aware verification"
  - "Tier 1 structural verification on demand with always-show-results behavior"
  - "Tier 2 behavioral checklist generation for any scope"
  - "Auto-fix retry loop with user consent for inspect flow"
  - "Celebration and progress feedback after verification"
affects: [06-progress-status (inspect results feed into progress tracking)]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Scope resolution from arguments: no args (current step), goal, all, free text search"
    - "Always-show-results pattern for user-initiated verification (distinct from build pipeline invisible-on-success)"
    - "Scope-based checklist sizing: 3-7 (step), 5-10 (goal), 7-12 (all)"

key-files:
  created: []
  modified:
    - skills/inspect/SKILL.md

key-decisions:
  - "Inspect always shows results (even clean) since the user explicitly asked -- differs from build pipeline behavior"
  - "Tier 2 behavioral checklist always runs for inspect regardless of scope (build only triggers at boundaries)"
  - "Focused scope searches GAMEPLAN/step/task files for matching text and stops with helpful message if no match"
  - "Large project 'all' scope spawns multiple verifier invocations per goal and aggregates results"

patterns-established:
  - "On-demand vs automatic verification: same agents, different result visibility and Tier 2 trigger rules"
  - "Scope-dependent context assembly: step reads STEP.md+tasks, goal reads all steps, all reads full hierarchy"

# Metrics
duration: 2min 22s
completed: 2026-02-08
---

# Phase 05 Plan 03: Inspect Skill Rewrite Summary

**On-demand verification command with scope-aware Tier 1 structural checks, Tier 2 behavioral checklists, consent-based auto-fix, and celebration feedback**

## Performance

- **Duration:** 2 min 22s
- **Started:** 2026-02-08T21:41:55Z
- **Completed:** 2026-02-08T21:44:16Z
- **Tasks:** 1
- **Files modified:** 1

## Accomplishments
- Replaced Phase 1 stub with a complete 7-step verification flow covering init, scope resolution, context assembly, Tier 1, Tier 2, and celebration
- Scope resolution handles four cases: current step (default), goal, all, and free-text topic search
- Auto-fix retry loop with debugger spawning, status checking, and complexity-based retry caps (2-5 retries)
- Behavioral checklists always generated with scope-based sizing (3-12 items depending on scope)

## Task Commits

Each task was committed atomically:

1. **Task 1: Rewrite inspect skill with scope-aware verification, Tier 1, Tier 2, auto-fix, and celebration** - `0dad8d4` (feat)

## Files Created/Modified
- `skills/inspect/SKILL.md` - Complete rewrite from 3-step stub to 7-step on-demand verification command with scope awareness, context assembly, verifier/debugger agent spawning, behavioral checklists, auto-fix consent flow, and progress celebration

## Decisions Made
- Inspect always shows Tier 1 results (even "everything checks out") since the user explicitly asked, unlike build pipeline which is invisible on success
- Tier 2 behavioral checklist always runs for inspect at any scope, unlike build which only triggers at step/goal boundaries
- Focused scope (free text argument) searches GAMEPLAN.md, step files, and task files for matching content, with a helpful fallback message if nothing matches
- For "all" scope on large projects, spawns multiple verifier invocations (one per goal) and aggregates results to stay within context/turn limits
- Checklist is guidance not a gate -- user can stop without completing it

## Deviations from Plan

None -- plan executed exactly as written.

## Issues Encountered

None.

## User Setup Required

None -- no external service configuration required.

## Next Phase Readiness
- All three verification plans (05-01, 05-02, 05-03) are complete
- The inspect command reuses the same verifier and debugger agents updated in 05-01
- Both build pipeline (05-02) and inspect (05-03) share the same auto-fix retry loop pattern
- Phase 5 verification system is complete: Tier 1 automatic in build, Tier 2 at boundaries, on-demand inspect for any scope

## Self-Check: PASSED

---
*Phase: 05-verification*
*Completed: 2026-02-08*
