---
phase: 09-command-intelligence
plan: 02
subsystem: command-routing
tags: [routing, state-detection, consistency-audit, inspect, vision-check]
requires:
  - "Phase 1: Plugin foundation (routing patterns established)"
  - "Phase 2: Onboarding (re-entry path)"
  - "Phase 5: Verification (inspect skill)"
  - "Phase 8: Pivot & Brainstorm (pivot routing)"
provides:
  - "Consistent four-step routing across all key-entry commands"
  - "Vision check in inspect skill (closes CMDI-01 gap)"
  - "Verified CMDI-01, CMDI-02, CMDI-03 compliance"
affects:
  - "09-03: Inline text audit builds on same skill files"
tech-stack:
  added: []
  patterns:
    - "Four-step routing pattern verified canonical across build/blueprint/inspect/pivot"
    - "Template detection strings verified identical across all 6 skills that use them"
key-files:
  created: []
  modified:
    - "skills/inspect/SKILL.md"
key-decisions:
  - "Inspect vision check uses Step 1b numbering (between init and completed-work check) to preserve existing step numbers"
  - "No changes needed to build, blueprint, pivot, or onboard -- all already consistent"
  - "Brainstorm routing phrasing not changed (not a key-entry command per locked decision)"
patterns-established:
  - "Audit-then-fix workflow: read all skills, compare patterns, make targeted changes"
duration: "1m 12s"
completed: "2026-02-09"
---

# Phase 9 Plan 02: Routing Consistency Audit Summary

Audited and standardized routing across all key-entry commands; added the missing vision check to inspect with template detection matching build/blueprint/pivot.

## Performance

- **Duration:** 1m 12s
- **Tasks:** 1/1 complete
- **Files modified:** 1

## What Was Accomplished

### Task 1: Add vision check to inspect and verify routing consistency

Added Step 1b (vision check) to `skills/inspect/SKILL.md` between the existing init check (Step 1) and completed-work check (Step 2). The new step uses the exact same template detection logic as build Step 2, blueprint, and pivot 1b -- checking for placeholder text `> This file will be populated when you run /director:onboard`, italic prompts like `_What are you calling this project?_`, and headings with no substantive content.

The routing message follows the canonical four-step pattern: states the situation ("There's nothing to check yet"), explains why ("we need to set up your project first"), suggests conversationally ("Want to start with `/director:onboard`?"), and waits for the user's response.

**Full audit results across all key-entry commands:**

| Skill | Routing Scenario | Four-Step Pattern | Status |
|-------|-----------------|-------------------|--------|
| build | No vision (Step 2) | State/Explain/Suggest/Wait | Already consistent |
| build | No gameplan (Step 3) | State/Suggest/Wait | Already consistent |
| build | All complete (Step 4.8) | State/Suggest/Wait | Already consistent |
| blueprint | No vision | State/Explain/Suggest/Wait | Already consistent |
| inspect | No vision (Step 1b) | State/Explain/Suggest/Wait | **Added** |
| inspect | No completed work (Step 2) | State/Explain/Suggest/Wait | Already consistent |
| pivot | No vision (1b) | State/Suggest/Wait | Already consistent |
| pivot | No gameplan (1c) | State/Suggest/Wait | Already consistent |
| onboard | Already-onboarded | Acknowledge/Offer choice | Already consistent (CMDI-03) |

**Template detection consistency verified across:**
- build/SKILL.md (Step 2)
- blueprint/SKILL.md (Determine Project State)
- inspect/SKILL.md (Step 1b -- new)
- pivot/SKILL.md (Step 1b)
- onboard/SKILL.md (Determine Project State -- uses dual-template detection, correct by design)
- brainstorm/SKILL.md (Step 1)

All six skills use the same detection strings. No inconsistencies found.

## Task Commits

| Task | Commit | Description |
|------|--------|-------------|
| 1 | 363503d | feat(09-02): add vision check to inspect and verify routing consistency |

## Files

### Modified
- `skills/inspect/SKILL.md` -- Added Step 1b vision check with template detection and four-step routing

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| Step 1b numbering preserves existing step numbers | Avoids renumbering Steps 2-7 which would change the skill's structure unnecessarily |
| No changes to build/blueprint/pivot/onboard | Audit confirmed all routing messages already follow the four-step pattern consistently |
| Brainstorm routing phrasing left as-is | Not a key-entry command per locked decision; state checks only on build/blueprint/inspect/pivot |

## Deviations from Plan

None -- plan executed exactly as written.

## Issues

None.

## Next Phase Readiness

Plan 09-03 (inline text audit) can proceed immediately. The routing consistency established here provides the foundation for inline text standardization -- all routing paths are now verified and consistent.

## Self-Check: PASSED
