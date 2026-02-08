---
phase: 05-verification
plan: 01
subsystem: agents
tags: [verification, builder, verifier, debugger, structured-output, parsing]

# Dependency graph
requires:
  - phase: 01-plugin-foundation
    provides: "Agent definitions (builder, verifier, debugger) with output sections"
provides:
  - "Parseable verification status line in builder output (clean / N found M fixed R remaining)"
  - "Auto-fixable classification (yes/no) per issue in verifier output"
  - "Consistent Status line in debugger output with build skill context"
affects: [05-verification (plans 02 and 03 consume these output formats)]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Structured output parsing: agents produce machine-readable status lines alongside plain-language output"
    - "Auto-fixable classification: binary yes/no per issue based on category (stubs/wiring vs design decisions)"

key-files:
  created: []
  modified:
    - agents/director-builder.md
    - agents/director-verifier.md
    - agents/director-debugger.md

key-decisions:
  - "Verification status line placed in Output section (not a separate section) to keep it part of the agent's natural response flow"
  - "Auto-fixable classification uses simple yes/no with category-based rules rather than confidence scores"
  - "Debugger already had correct Status format -- only added context sentence explaining how build skill uses it"

patterns-established:
  - "Agent output contracts: agents include structured lines that downstream skills parse, separate from user-facing content"

# Metrics
duration: 1min 20s
completed: 2026-02-08
---

# Phase 05 Plan 01: Agent Structured Output Summary

**Parseable verification status lines added to builder, verifier, and debugger agents for build skill consumption**

## Performance

- **Duration:** 1 min 20s
- **Started:** 2026-02-08T21:35:49Z
- **Completed:** 2026-02-08T21:37:09Z
- **Tasks:** 2
- **Files modified:** 3

## Accomplishments
- Builder agent output now includes a verification status line with three formats (clean, all fixed, remaining with per-issue details)
- Verifier agent output classifies each "Needs attention" issue as auto-fixable or not, with clear category guidance
- Debugger agent output has consistent Status line with explanatory context for build skill parsing

## Task Commits

Each task was committed atomically:

1. **Task 1: Add structured verification status to builder agent output** - `8d66864` (feat)
2. **Task 2: Add auto-fixable classification to verifier and status consistency to debugger** - `16d3798` (feat)

## Files Created/Modified
- `agents/director-builder.md` - Added Verification Status subsection with three parseable formats; updated rule 6 to mention surfacing unresolved issues
- `agents/director-verifier.md` - Added Auto-fixable: yes/no per "Needs attention" issue; added classification guidance paragraph
- `agents/director-debugger.md` - Added one sentence explaining build skill reads the Status line for retry/move-on/report decisions

## Decisions Made
- Verification status line placed in Output section as a subsection rather than a separate top-level section, keeping it part of the agent's natural response flow
- Auto-fixable classification uses simple yes/no with category-based rules (stubs/wiring = auto-fixable; design decisions/new features = not) rather than confidence scores or probability
- Debugger already had the correct Status format (Fixed / Needs more work / Needs manual attention) -- only addition was one context sentence explaining how the build skill uses it

## Deviations from Plan

None -- plan executed exactly as written.

## Issues Encountered

None.

## User Setup Required

None -- no external service configuration required.

## Next Phase Readiness
- All three agent output formats are ready for Plan 05-02 (build skill) to parse and act on
- Builder produces `Verification:` line, verifier produces `Auto-fixable:` classification, debugger produces `Status:` line
- No blockers for Plan 05-02 or 05-03

## Self-Check: PASSED

---
*Phase: 05-verification*
*Completed: 2026-02-08*
