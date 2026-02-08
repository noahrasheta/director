---
phase: 04-execution
plan: "02"
subsystem: execution-engine
tags: [build-skill, task-selection, context-assembly, xml-boundaries, atomic-commit, doc-sync, post-task-summary]

dependency-graph:
  requires: ["01-04", "01-06", "04-01"]
  provides: ["complete-build-execution-pipeline", "ready-task-detection", "context-budget-calculator", "builder-spawning", "sync-verification", "post-task-summary"]
  affects: ["05-*", "06-*", "09-*"]

tech-stack:
  added: []
  patterns: ["inline-skill-with-task-spawning", "xml-context-assembly", "context-budget-calculator", "amend-commit-for-sync", "ready-work-filtering"]

key-files:
  created: []
  modified:
    - skills/build/SKILL.md

decisions:
  - id: "04-02-inline-skill"
    decision: "Build skill runs inline (no context: fork) with Task tool spawning for builder agent"
    reason: "Skill needs pre-task orchestration (routing, task selection, context assembly) and post-task orchestration (commit verification, sync, reporting) around the builder spawn"
  - id: "04-02-budget-threshold"
    decision: "Context budget threshold is 30% of 200K tokens (60K tokens), estimated via chars/4"
    reason: "Matches context-management.md spec; leaves 70%+ of window for builder execution"
  - id: "04-02-truncation-order"
    decision: "Truncation order: git log first, reference docs second, STEP.md third, never task/vision"
    reason: "Git log is least critical for task completion; task and vision are essential for correct execution"
  - id: "04-02-amend-commit"
    decision: "Syncer changes are amend-committed to maintain one commit per task"
    reason: "Keeps atomic commit principle clean; undo reverts everything at once"
  - id: "04-02-drift-confirmation"
    decision: "STATE.md and .done.md renames applied automatically; VISION.md/GAMEPLAN.md drift requires user confirmation"
    reason: "Locked decision from context phase: doc sync shows findings and asks before applying"

metrics:
  duration: "2m 43s"
  completed: "2026-02-08"
---

# Phase 4 Plan 02: Build Skill Rewrite Summary

Complete rewrite of the build skill from a routing placeholder into Director's 10-step execution engine with ready-task detection, XML context assembly with budget calculator, builder spawning via Task tool, atomic commit maintenance, and post-task summary in paragraph + bullet list format.

## What Was Done

### Task 1: Rewrite build SKILL.md with complete execution pipeline

Replaced the entire content of `skills/build/SKILL.md` (was 65 lines of routing placeholder, now 353 lines of complete execution pipeline) with a 10-step orchestration flow:

1. **Init check** -- Same `.director/` existence check pattern as other skills
2. **Vision check** -- Template detection with routing to onboard if empty
3. **Gameplan check** -- Template detection with routing to blueprint if empty
4. **Find next ready task** -- Task selection algorithm scanning `.director/goals/` hierarchy, checking `.done.md` files and "Needs First" sections, with edge cases for step/goal completion and $ARGUMENTS handling
5. **Assemble context** -- XML boundary tags wrapping VISION.md, STEP.md, task file, git log, and instructions; includes context budget calculator (chars/4 estimation, 60K token threshold, 4-tier truncation strategy)
6. **Check for uncommitted changes** -- `git status --porcelain` before spawning, with stash/commit/discard options
7. **Spawn builder** -- Task tool spawning `director-builder` with assembled XML context
8. **Verify builder results** -- Checks for new commit, handles partial failure (modified files without commit) and total failure (no modifications)
9. **Post-task sync verification** -- Amend-commits syncer changes to maintain one commit per task; presents drift findings in plain language with user confirmation for VISION/GAMEPLAN changes
10. **Post-task summary** -- Paragraph + bullet list format with "Progress saved" message, step/goal completion indicators, and next task suggestion

**Commit:** `66f1fc8`

## EXEC Requirements Coverage

| Req | Description | Implementation |
|-----|-------------|----------------|
| EXEC-01 | Find next ready task | Step 4: scans gameplan hierarchy, checks .done.md and Needs First |
| EXEC-02 | Fresh context per task | Step 5: assembles VISION.md, STEP.md, task file, git history |
| EXEC-03 | XML boundary tags | Step 5: wraps content in vision, current_step, task, recent_changes, instructions tags |
| EXEC-04 | Atomic commit | Steps 7-9: builder creates commit, syncer changes amend-committed |
| EXEC-05 | Plain language | Step 10: "Progress saved" language, never git jargon |
| EXEC-06 | Doc sync after task | Step 9: syncer checks STATE.md, flags drift, user confirms changes |
| EXEC-07 | External change detection | Explicitly deferred to /director:resume per locked decision |
| EXEC-08 | Plain language reporting | Step 10: paragraph + bullet list format |
| EXEC-09 | Sub-agent spawning | Step 7: builder spawns verifier and syncer; can spawn researcher |

## Locked Decisions Honored

- **Doc sync reporting:** Shows findings in plain language, asks user to confirm before applying (Step 9b)
- **External change detection:** Only on `/director:resume`, not after every task (EXEC-07 addressed via deferral)
- **Post-task summary format:** Paragraph + bullet list + "Progress saved" (Step 10)
- **No `context: fork`:** Skill runs inline for pre/post orchestration (research recommendation)

## Deviations from Plan

None -- plan executed exactly as written.

## Task Commits

| Task | Name | Commit | Files |
|------|------|--------|-------|
| 1 | Rewrite build SKILL.md with complete execution pipeline | 66f1fc8 | skills/build/SKILL.md |

## Self-Check: PASSED
