---
phase: 07-quick-mode-ideas
plan: "03"
subsystem: ui
tags: [ideas, idea-routing, skill, conversational-routing, IDEAS.md]

# Dependency graph
requires:
  - phase: 01-plugin-foundation
    provides: skill directory structure, init-director.sh, reference docs
  - phase: 07-quick-mode-ideas
    provides: idea capture skill (07-02), quick mode skill (07-01), IDEAS.md format
provides:
  - "Ideas viewer skill with numbered display, conversational routing, and removal mechanic"
  - "Complete idea lifecycle: capture via /director:idea, review and act via /director:ideas"
affects: []

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Conversational routing: suggest ONE route with reasoning, not a menu of options"
    - "Scope-based idea analysis reusing quick skill's complexity heuristics"
    - "IDEAS.md removal mechanic using - **[ pattern matching for multi-line entries"

key-files:
  created:
    - skills/ideas/SKILL.md
  modified: []

key-decisions:
  - "Brainstorm route keeps idea in IDEAS.md (exploration is not action)"
  - "Quick route executes inline (same builder flow as quick skill)"
  - "Blueprint and brainstorm routes direct user to run command (no auto-execution)"
  - "$ARGUMENTS support enables direct idea matching via /director:ideas \"dark mode\""

patterns-established:
  - "Ideas removal: find entry by - **[ pattern, remove through next entry or EOF"
  - "Route suggestion pattern: analyze, suggest ONE, confirm, execute"

# Metrics
duration: 2m 01s
completed: 2026-02-08
---

# Phase 7 Plan 03: Ideas Viewer Summary

**Conversational idea viewer with scope-based routing to quick/blueprint/brainstorm and IDEAS.md removal on action**

## Performance

- **Duration:** 2m 01s
- **Started:** 2026-02-09T02:08:19Z
- **Completed:** 2026-02-09T02:10:20Z
- **Tasks:** 1
- **Files created:** 1

## Accomplishments
- Created new `/director:ideas` skill with numbered idea display, abbreviated dates, and conversational selection
- Implemented scope-based routing analysis reusing quick skill's complexity heuristics (quick/blueprint/brainstorm indicators)
- Designed conversational routing that suggests ONE route with reasoning ("That's a straightforward change -- I can handle it as a quick task. Sound good?")
- Quick route executes inline via builder with full quick mode flow (context assembly, builder spawn, verification, summary)
- Blueprint route removes idea and directs to `/director:blueprint`; brainstorm route keeps idea and directs to `/director:brainstorm`
- IDEAS.md removal mechanic handles multi-line entries using `- **[` pattern boundaries
- Added `$ARGUMENTS` support for direct idea matching (e.g., `/director:ideas "dark mode"`)

## Task Commits

Each task was committed atomically:

1. **Task 1: Create ideas viewer skill with conversational routing** - `2097ce0` (feat)

## Files Created/Modified
- `skills/ideas/SKILL.md` - New ideas viewer skill with 5-step flow: init check, read/display ideas, handle selection, analyze/suggest route, execute route

## Decisions Made
None - followed plan as specified. All behaviors (conversational routing, single suggestion, three destinations, confirmation gate, removal on action except brainstorm) were locked decisions from CONTEXT.md.

## Deviations from Plan
None - plan executed exactly as written.

## Issues Encountered
None

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Phase 7 (Quick Mode & Ideas) is now complete -- all 3 plans delivered
- Full idea lifecycle functional: `/director:idea` captures, `/director:ideas` reviews and routes
- Quick mode, idea capture, and ideas viewer all share consistent patterns with the build pipeline
- Ready to proceed to Phase 7.1 (User Decisions Context) or Phase 8 (Pivot & Brainstorm)

## Self-Check: PASSED

---
*Phase: 07-quick-mode-ideas*
*Completed: 2026-02-08*
