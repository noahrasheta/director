---
phase: 09-command-intelligence
plan: 03
subsystem: skills-and-reference
tags: [inline-text, arguments, error-messaging, terminology, plain-language, resume, audit]
requires:
  - "09-01 (help skill enhanced with $ARGUMENTS)"
  - "09-02 (undo skill with terminology compliance)"
  - "01-02 (terminology.md and plain-language-guide.md created)"
provides:
  - "All 12 commands handle $ARGUMENTS (resume was the last gap)"
  - "Error messaging audit across all lightweight commands"
  - "Updated terminology.md with undo-related terms"
  - "Updated plain-language-guide.md with Director-specific error example"
affects:
  - "Phase 10 (all skills now fully audited for consistency)"
tech-stack:
  added: []
  patterns:
    - "Focus context pattern: $ARGUMENTS stored as hint, influences behavior without changing flow"
    - "Three-part error structure enforced: what/why/what to do"
key-files:
  created: []
  modified:
    - "skills/resume/SKILL.md"
    - "skills/idea/SKILL.md"
    - "skills/status/SKILL.md"
    - "reference/terminology.md"
    - "reference/plain-language-guide.md"
key-decisions:
  - "$ARGUMENTS in resume is a focus hint, not a command -- influences recap highlighting and next-action suggestion without changing the resume flow"
  - "Audit confirmed 11/12 commands already had $ARGUMENTS support from previous phases"
  - "Idea skill was the only lightweight command missing a Language Reminders section"
  - "Status 'no goals' message was the only error message missing the 'why' part of three-part structure"
patterns-established:
  - "Focus context pattern for resume: store inline text as soft context that influences output emphasis"
duration: "2m 37s"
completed: "2026-02-09"
---

# Phase 09 Plan 03: Inline Text Audit, Resume Arguments, Error Messaging and Reference Docs Summary

**One-liner:** All 12 commands now handle $ARGUMENTS (resume was the last holdout), error messages audited for three-part structure, terminology and plain-language guides updated with undo terms.

## Performance

- **Duration:** 2m 37s
- **Tasks:** 2/2 complete
- **Deviations:** None -- plan executed as written

## Accomplishments

### Inline Text ($ARGUMENTS) Audit -- All 12 Commands

| Command | Has $ARGUMENTS | How Used | Status |
|---------|---------------|----------|--------|
| build | Yes | Match task name, or carry as extra context | Already done |
| blueprint | Yes | New mode: acknowledge; Update mode: focus for update | Already done |
| onboard | Yes | Initial project context, skip first question | Already done |
| inspect | Yes | Scope: "goal", "all", or topic text | Already done |
| quick | Yes | Required -- the task description | Already done |
| idea | Yes | Required -- the idea text | Already done |
| ideas | Yes | Direct idea matching (e.g., "dark mode") | Already done |
| brainstorm | Yes | Topic-specific entry vs open-ended | Already done |
| pivot | Yes | Inline pivot description, skips interview | Already done |
| status | Yes | "cost" or "detailed" for cost view | Already done |
| help | Yes | Topic-specific help for named command | Enhanced in 09-01 |
| resume | **Yes (NEW)** | Focus context for recap and next-action | **Added in this plan** |

**Result:** 11 of 12 commands already had $ARGUMENTS from previous phases. Resume was the only gap, now fixed.

### Resume $ARGUMENTS Implementation

Added Step 1b (Handle inline context) between project check and break length calculation:
- Stores $ARGUMENTS as focus context
- Step 3 (reconstruct last session) highlights work related to focus text
- Step 6 (suggest next action) prioritizes tasks matching focus text
- Gracefully handles non-matching focus text (acknowledges and proceeds)
- Normal resume flow completely unchanged when $ARGUMENTS is empty

### Error Messaging Audit

Audited all 5 lightweight commands (status, brainstorm, quick, idea, ideas) for:
1. Three-part error structure (what/why/what to do)
2. No developer jargon in user-facing messages
3. Director terminology compliance (Goal/Step/Task, Vision/Gameplan)
4. Language Reminders section presence

**Findings:**
- **idea/SKILL.md:** Missing Language Reminders section -- ADDED
- **status/SKILL.md:** "No goals" message missing "why" component -- FIXED (added "Director needs goals to track your progress")
- **brainstorm, quick, ideas:** All passed audit with no issues
- **No jargon found** in any user-facing messages across all audited skills
- **Director terminology used consistently** throughout

### Reference Doc Updates

**terminology.md:**
- Added "Undo" to Term Mapping table (maps to Revert, Rollback, Git reset)
- Added revert, rollback, reset to Git/version control never-use list
- Added undo, go back to OK words list
- Added undo-specific phrasing example (git revert internals vs plain language)

**plain-language-guide.md:**
- Added Director-specific three-part error example to Rule 6 ("No ready tasks found" bad vs good)

## Task Commits

| Task | Name | Commit | Key Changes |
|------|------|--------|-------------|
| 1 | Audit inline text support and add $ARGUMENTS to resume | `e2c56af` | skills/resume/SKILL.md (Step 1b + Step 6 focus context) |
| 2 | Audit error messaging, terminology, and update reference docs | `43e6999` | skills/idea/SKILL.md, skills/status/SKILL.md, reference/terminology.md, reference/plain-language-guide.md |

## Files Modified

| File | Change |
|------|--------|
| skills/resume/SKILL.md | Added Step 1b (Handle inline context) and Step 6 focus context reference |
| skills/idea/SKILL.md | Added Language Reminders section |
| skills/status/SKILL.md | Improved "no goals" message with why component |
| reference/terminology.md | Added undo terms, revert/rollback/reset to never-use, phrasing example |
| reference/plain-language-guide.md | Added Director-specific three-part error example |

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| Resume $ARGUMENTS is a soft focus hint, not a directive | Consistent with how other commands treat inline text -- influences behavior without changing core flow |
| Only fix actual issues found during audit | Plan explicitly said "make MINIMAL changes" -- avoided unnecessary rewrites |
| Added Language Reminders to idea skill only | All other lightweight skills already had the section from their original implementation |

## Deviations from Plan

None -- plan executed exactly as written.

## Issues Encountered

None.

## Locked Decisions Satisfied

- **CMDI-04:** All 12 commands audited for inline text support (documented in audit table above)
- **CMDI-05:** Error messages follow three-part structure (what/why/what to do)
- **CMDI-06:** No developer jargon in user-facing messages
- **CMDI-07:** Director terminology used consistently (Goal/Step/Task, Vision/Gameplan)

## Next Phase Readiness

Phase 09 (Command Intelligence) is now complete with all 3 plans executed:
- 09-01: Help skill topic-specific deep dives and build undo integration
- 09-02: Undo skill implementation
- 09-03: Inline text audit, resume arguments, error messaging, reference docs

All commands are now fully audited and consistent. Ready to proceed to Phase 10.

## Self-Check: PASSED
