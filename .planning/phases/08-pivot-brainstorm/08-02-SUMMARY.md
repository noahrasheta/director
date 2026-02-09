---
phase: 08-pivot-brainstorm
plan: "02"
subsystem: workflow
tags: [pivot, mapper, staleness, clean-state, git-status, skill]

# Dependency graph
requires:
  - phase: 08-pivot-brainstorm
    provides: "Pivot skill Steps 1-3 (init routing, capture, scope detection)"
  - phase: 04-execution
    provides: "Build skill Step 6 uncommitted changes pattern (git status --porcelain + stash/commit)"
  - phase: 02-onboarding
    provides: "Brownfield mapper spawning pattern (Task tool, foreground, conversational presentation)"
provides:
  - "Pivot skill Steps 4-5: in-progress work check and conditional staleness-aware mapper spawning"
  - "Staleness heuristics for deciding when mapper scan is needed vs trusting existing docs"
affects: [08-03, 08-04]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Staleness heuristic with spawn/skip indicator lists for conditional mapper spawning"
    - "Clean state enforcement before meta-operations (pivot checks git status same as build)"

key-files:
  created: []
  modified:
    - skills/pivot/SKILL.md

key-decisions:
  - "Pivot checks for uncommitted changes before proceeding and offers to complete current task or stash"
  - "Mapper spawning is conditional based on staleness heuristics, not triggered on every pivot"
  - "When staleness indicators conflict, lean toward skipping mapper (trust docs, correct later)"
  - "Mapper findings presented conversationally before impact analysis begins"

patterns-established:
  - "Staleness-aware agent spawning: heuristic checklist of spawn/skip indicators with judgment call guidance"

# Metrics
duration: 1m 34s
completed: 2026-02-09
---

# Phase 08 Plan 02: Pivot In-Progress Work Check and Conditional Mapper Spawning Summary

**Pivot Steps 4-5: clean state enforcement via git status check with commit/stash options, and staleness-aware mapper spawning with spawn/skip heuristic indicators for conditional codebase scanning**

## Performance

- **Duration:** 1m 34s
- **Started:** 2026-02-09T05:21:40Z
- **Completed:** 2026-02-09T05:23:14Z
- **Tasks:** 1
- **Files modified:** 1

## Accomplishments
- Step 4 enforces clean working tree before pivot proceeds -- checks `git status --porcelain`, offers commit or stash for in-progress work, blocks until clean
- Step 5 reads STATE.md and GAMEPLAN.md to assess whether mapper scan is needed, with documented spawn/skip heuristic lists
- When stale: spawns director-mapper via Task tool in foreground and presents findings conversationally
- When fresh: summarizes current state from existing docs without unnecessary codebase scan
- Both paths store state summary internally for use in Step 6 (impact analysis)

## Task Commits

Each task was committed atomically:

1. **Task 1: Add pivot Steps 4-5 (in-progress work check and conditional mapper spawning)** - `8c00551` (feat)

**Plan metadata:** (pending)

## Files Created/Modified
- `skills/pivot/SKILL.md` - Added Steps 4-5 (in-progress work check, conditional mapper spawning) after existing Steps 1-3, updated placeholder to Steps 6-9

## Decisions Made
- Pivot checks for uncommitted changes before proceeding, consistent with build skill Step 6 pattern
- Mapper spawning is conditional -- not triggered on every pivot, per locked decision from CONTEXT.md
- When staleness indicators conflict, lean toward skipping mapper (trust docs, correct course later) -- per research recommendation that staleness is a judgment call
- Mapper findings are presented conversationally ("Here's what your project looks like right now:") before impact analysis begins

## Deviations from Plan

None -- plan executed exactly as written.

## Issues Encountered
None

## User Setup Required
None -- no external service configuration required.

## Next Phase Readiness
- Steps 1-5 complete with clean placeholder marker for Steps 6-9
- Plan 08-03 can add Steps 6-7 (impact analysis, delta summary)
- Plan 08-04 can add Steps 8-9 (apply changes, wrap-up)
- Step 5's stored state summary provides input for Step 6's impact analysis

## Self-Check: PASSED

---
*Phase: 08-pivot-brainstorm*
*Completed: 2026-02-09*
