---
phase: 02-onboarding
plan: 02
subsystem: onboarding
tags: [skill, interview, vision, brownfield, mapper, delta-format]

# Dependency graph
requires:
  - phase: 01-plugin-foundation
    provides: "Mapper agent definition, interviewer agent brownfield mode, vision template, reference docs"
  - phase: 02-onboarding
    plan: 01
    provides: "Greenfield onboarding workflow, brownfield detection placeholder"
provides:
  - "Complete brownfield onboarding workflow in skills/onboard/SKILL.md"
  - "Mapper spawning via Task tool with XML boundary context"
  - "Brownfield interview with 7 adapted sections focused on changes"
  - "Delta-format vision generation (Existing/Adding/Changing/Removing)"
  - "Functional already-onboarded re-entry path (update + map)"
affects: [03-planning, 09-command-intelligence]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Brownfield mapper spawning: Task tool with XML-tagged instructions in foreground mode"
    - "Delta-format vision: Existing/Adding/Changing/Removing sections in Key Features"
    - "Brownfield interview adaptation: 7 sections, skip mapper-answered questions, focus on changes"

key-files:
  created: []
  modified:
    - skills/onboard/SKILL.md

key-decisions:
  - "Mapper runs in foreground (not background) so user sees findings before interview"
  - "Brownfield interview has 7 sections adapted from 8 greenfield sections"
  - "Delta format uses Existing/Adding/Changing/Removing labels in VISION.md"
  - "Already-onboarded path now fully functional with update and map options"

patterns-established:
  - "Brownfield mapper spawning: director-mapper via Task tool with XML context assembly"
  - "Delta-format vision: separates existing state from planned changes in Key Features"
  - "Adapted interview: skip mapper-answered questions, shorter flow (5-10 questions)"

# Metrics
duration: 2m 55s
completed: 2026-02-08
---

# Phase 2 Plan 2: Brownfield Onboarding Summary

**Full brownfield onboarding workflow with mapper spawning, findings presentation, adapted 7-section interview, and delta-format VISION.md generation in onboard SKILL.md**

## Performance

- **Duration:** 2m 55s
- **Started:** 2026-02-08T07:14:42Z
- **Completed:** 2026-02-08T07:17:37Z
- **Tasks:** 1
- **Files modified:** 1

## Accomplishments

- Replaced brownfield placeholder ("coming soon") with full brownfield workflow (173 new lines, file now 417 lines total)
- Mapper spawning uses Task tool with XML boundary tags per reference/context-management.md
- Findings are presented conversationally with user confirmation before interview begins
- Brownfield interview has 7 adapted sections: skips "what are you building?", tech stack (unless changing), and architecture (all answered by mapper)
- Brownfield interview targets 5-10 questions (shorter than greenfield's 8-15)
- Brownfield vision generation uses delta format with Existing/Adding/Changing/Removing sections under Key Features
- Already-onboarded re-entry path now fully functional: "update vision" runs adapted interview, "map code" spawns mapper then offers to update
- Added mapper-specific language reminder for collaborative observations

## Task Commits

Each task was committed atomically:

1. **Task 1: Replace brownfield placeholder with mapper spawning and findings presentation** - `cea320b` (feat)

## Files Created/Modified

- `skills/onboard/SKILL.md` - Complete onboarding workflow with both greenfield (preserved from Plan 01) and brownfield paths, including mapper spawning, findings presentation, adapted interview, and delta-format vision generation

## Decisions Made

- **Mapper runs in foreground:** The mapper must complete before the interview begins because the user needs to see and confirm findings first. Background execution would add complexity for marginal time savings.
- **7 brownfield interview sections:** Adapted from the 8 greenfield sections by merging/skipping questions the mapper already answered. "What are you building?" becomes "What do you want to change or add?" -- the project already exists.
- **Delta format uses natural labels:** Existing/Adding/Changing/Removing in the VISION.md document itself, but conversation stays natural ("You have X, and you want to add Y").
- **Already-onboarded path fully functional:** Both "update vision" and "map code" options now have complete instructions, not just the offer to choose.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Onboarding is complete: both greenfield and brownfield paths are fully functional in skills/onboard/SKILL.md
- All ONBR requirements (01-11) are covered across Plans 01 and 02
- The mapper agent (agents/director-mapper.md) is now connected to the onboarding flow via Task tool spawning
- Vision template (skills/onboard/templates/vision-template.md) is referenced for both greenfield and brownfield generation
- Phase 3 (Planning/Blueprint) can build on the VISION.md output from either path

## Self-Check: PASSED

---
*Phase: 02-onboarding*
*Completed: 2026-02-08*
