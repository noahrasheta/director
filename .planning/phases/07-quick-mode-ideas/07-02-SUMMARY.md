---
phase: 07-quick-mode-ideas
plan: "02"
subsystem: ui
tags: [ideas, idea-capture, skill, init-script, IDEAS.md]

# Dependency graph
requires:
  - phase: 01-plugin-foundation
    provides: idea skill placeholder, init-director.sh template, reference docs
provides:
  - "Newest-first idea capture skill with exact text preservation"
  - "Init template with matching anchor lines for idea insertion"
affects: [07-03 ideas viewer/router skill]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Newest-first insertion via anchor line detection (_Captured ideas_ pattern)"

key-files:
  created: []
  modified:
    - skills/idea/SKILL.md
    - scripts/init-director.sh

key-decisions:
  - "Idea text preserved exactly as typed -- no reformatting, summarizing, or editing"
  - "Single-line confirmation with zero follow-up questions or suggestions"
  - "Insertion anchored to _Captured ideas_ description line in IDEAS.md"

patterns-established:
  - "IDEAS.md insertion pattern: find _Captured ideas_ line, insert new idea on next line"

# Metrics
duration: 1m 26s
completed: 2026-02-08
---

# Phase 7 Plan 02: Idea Capture Summary

**Newest-first idea insertion in IDEAS.md with exact text preservation and zero-friction single-line confirmation**

## Performance

- **Duration:** 1m 26s
- **Started:** 2026-02-09T01:58:05Z
- **Completed:** 2026-02-09T01:59:31Z
- **Tasks:** 2
- **Files modified:** 2

## Accomplishments
- Rewrote idea skill to insert ideas at the TOP of IDEAS.md (newest first) instead of appending at bottom
- Defined precise insertion mechanic using `_Captured ideas` anchor line for reliable positioning
- Enforced exact text preservation -- user's words captured with no modification
- Stripped confirmation to a single line with explicit do-not rules preventing follow-up questions
- Updated init script IDEAS.md template with trailing blank line for clean first-idea insertion

## Task Commits

Each task was committed atomically:

1. **Task 1: Rewrite idea skill for newest-first insertion** - `9ac7d69` (feat)
2. **Task 2: Update init script IDEAS.md template** - `6eb4a87` (chore)

## Files Created/Modified
- `skills/idea/SKILL.md` - Rewritten idea capture skill with newest-first insertion, exact text preservation, and single-line confirmation
- `scripts/init-director.sh` - Added trailing blank line to IDEAS.md heredoc template for clean separator

## Decisions Made
None - followed plan as specified. All behaviors (newest-first ordering, as-is text capture, zero-friction confirmation) were locked decisions from CONTEXT.md.

## Deviations from Plan
None - plan executed exactly as written.

## Issues Encountered
None

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- IDEAS.md format and insertion pattern established for the ideas viewer/router skill (Plan 07-03)
- The `_Captured ideas_` anchor line is the shared contract between the idea skill, ideas skill, and init template
- Removal mechanic (for ideas viewer) will use `- **[` pattern matching as described in research

## Self-Check: PASSED

---
*Phase: 07-quick-mode-ideas*
*Completed: 2026-02-08*
