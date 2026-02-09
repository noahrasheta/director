---
phase: 08-pivot-brainstorm
plan: "01"
subsystem: workflow
tags: [pivot, scope-detection, routing, conversation, skill]

# Dependency graph
requires:
  - phase: 01-plugin-foundation
    provides: "Skill file structure, routing patterns, init checks, reference docs"
  - phase: 02-onboarding
    provides: "Inline conversation pattern (not agent spawning), template detection for VISION.md"
  - phase: 03-planning
    provides: "Template detection for GAMEPLAN.md, blueprint update mode patterns"
provides:
  - "Pivot skill Steps 1-3: init routing, dual-path capture, scope detection"
  - "Entry point for pivot workflow (later plans add Steps 4-9)"
affects: [08-02, 08-03, 08-04]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Pivot scope detection heuristic with tactical/strategic signal lists and ambiguity fallback"
    - "Dual entry path pattern: inline arguments skip conversation, bare command opens dialog"

key-files:
  created: []
  modified:
    - skills/pivot/SKILL.md

key-decisions:
  - "Conversation runs inline (no interviewer agent spawning), consistent with onboard/blueprint patterns"
  - "Scope detection uses signal heuristic with explicit A/B fallback to user when ambiguous"
  - "Template detection patterns match build and blueprint skills exactly"
  - "Pivot-positive framing in language reminders: changing direction is learning, not failure"

patterns-established:
  - "Pivot scope classification: tactical (gameplan-only) vs strategic (vision + gameplan) with user disambiguation"

# Metrics
duration: 1m 14s
completed: 2026-02-09
---

# Phase 08 Plan 01: Pivot Init, Routing, and Scope Detection Summary

**Pivot skill Steps 1-3: init routing with vision/gameplan checks, dual-path capture (inline args or open conversation), and tactical vs strategic scope detection with ambiguity fallback**

## Performance

- **Duration:** 1m 14s
- **Started:** 2026-02-09T05:16:33Z
- **Completed:** 2026-02-09T05:17:47Z
- **Tasks:** 1
- **Files modified:** 1

## Accomplishments
- Replaced pivot placeholder ("will be fully functional in a future update") with Steps 1-3 of a complete pivot workflow
- Step 1: Init checks with vision/gameplan routing using template detection patterns consistent with build and blueprint skills
- Step 2: Dual entry paths -- inline arguments acknowledge and skip to scope detection; bare command opens natural conversation
- Step 3: Scope detection with tactical/strategic signal lists and explicit A/B question when ambiguous

## Task Commits

Each task was committed atomically:

1. **Task 1: Rewrite pivot SKILL.md Steps 1-3 (init, routing, capture, scope detection)** - `82b76bd` (feat)

**Plan metadata:** `73aa5b3` (docs: complete plan)

## Files Created/Modified
- `skills/pivot/SKILL.md` - Pivot skill with Steps 1-3 (init, capture, scope detection), placeholder for Steps 4-9

## Decisions Made
- Conversation runs inline (no interviewer agent spawning) -- consistent with established patterns from onboard (Phase 2) and blueprint (Phase 3)
- Scope detection is a heuristic with explicit fallback to asking the user when ambiguous -- per locked CONTEXT.md decision
- Template detection for VISION.md and GAMEPLAN.md uses same patterns as build and blueprint skills
- Added pivot-specific language reminder: "Pivots are normal -- changing direction is a sign of learning, not failure"

## Deviations from Plan

None -- plan executed exactly as written.

## Issues Encountered
None

## User Setup Required
None -- no external service configuration required.

## Next Phase Readiness
- Steps 1-3 complete with clean placeholder marker for Steps 4-9
- Plan 08-02 can add Steps 4-5 (in-progress work check, staleness-aware mapper spawning)
- Plan 08-03 can add Steps 6-7 (impact analysis, delta summary)
- Plan 08-04 can add Steps 8-9 (apply changes, wrap-up)

## Self-Check: PASSED

---
*Phase: 08-pivot-brainstorm*
*Completed: 2026-02-09*
