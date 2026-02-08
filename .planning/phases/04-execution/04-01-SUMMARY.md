# Phase 4 Plan 1: Agent Updates for Execution Pipeline Summary

**One-liner:** Builder gets researcher sub-agent access; syncer gets .done.md rename and amend-commit awareness for atomic task commits.

## Frontmatter

```yaml
phase: 04-execution
plan: 01
subsystem: agents
tags: [builder, syncer, researcher, sub-agents, execution-pipeline, done-convention]
dependency-graph:
  requires: [01-06]
  provides: [builder-researcher-access, syncer-done-rename, syncer-amend-awareness]
  affects: [04-02, 04-03, 04-04, 04-05, 04-06]
tech-stack:
  added: []
  patterns: [commit-then-verify-then-amend, done-file-convention, amend-commit-for-sync]
key-files:
  created: []
  modified:
    - agents/director-builder.md
    - agents/director-syncer.md
decisions:
  - id: 04-01-01
    description: "Builder may amend its own task commit during verification fix cycles"
    rationale: "Keeps one atomic commit per task while allowing post-verification fixes"
  - id: 04-01-02
    description: "Syncer changes get amend-committed by the build skill, not by syncer itself"
    rationale: "Syncer stays documentation-only; git operations handled by orchestrating skill"
  - id: 04-01-03
    description: "Task file rename (.done.md) is the syncer's responsibility"
    rationale: "Syncer already handles STATE.md updates; rename is a natural extension of marking completion"
metrics:
  duration: 1m 26s
  completed: 2026-02-08
```

## What Was Done

### Task 1: Update builder agent for execution pipeline
**Commit:** `dae40a7`
**Files modified:** `agents/director-builder.md`

Updated the builder agent with four changes:
- Added `director-researcher` to the tools frontmatter, enabling the builder to spawn researcher sub-agents for within-task investigation
- Documented the researcher in the Sub-Agents section with usage guidance (spawn when encountering decision points)
- Updated execution rule 6 to clarify the commit-then-verify-then-amend flow: create commit first, then spawn verifier, fix and amend if issues found
- Updated Git Rules to allow self-amendment during verification cycles while still prohibiting force push and history rewriting

### Task 2: Update syncer agent for task completion and amend-commit pattern
**Commit:** `e5cf680`
**Files modified:** `agents/director-syncer.md`

Updated the syncer agent with four changes:
- Added new step 3 to Sync Process: rename completed task file from `NN-task-slug.md` to `NN-task-slug.done.md`
- Added `<changes>` to Context You Receive section so syncer can verify actual file changes against expectations
- Added rule 5 to Important Rules: syncer understands its changes get amend-committed by the build skill (no git commands needed)
- Added task file rename row to scope table with "Rename only" permission

## Task Commits

| Task | Name | Commit | Files |
|------|------|--------|-------|
| 1 | Update builder agent for execution pipeline | dae40a7 | agents/director-builder.md |
| 2 | Update syncer agent for task completion and amend-commit pattern | e5cf680 | agents/director-syncer.md |

## Decisions Made

| ID | Decision | Rationale |
|----|----------|-----------|
| 04-01-01 | Builder may amend its own task commit during verification fix cycles | Keeps one atomic commit per task while allowing post-verification fixes |
| 04-01-02 | Syncer changes get amend-committed by build skill, not by syncer itself | Syncer stays documentation-only; git operations handled by orchestrating skill |
| 04-01-03 | Task file rename (.done.md) is the syncer's responsibility | Syncer already handles STATE.md updates; rename is a natural extension of marking completion |

## Deviations from Plan

None -- plan executed exactly as written.

## Next Phase Readiness

Both agents are now ready for the execution pipeline (Plan 04-02: build skill). The builder can spawn all three sub-agents (verifier, syncer, researcher) and understands the commit-then-verify-then-amend flow. The syncer knows to rename task files, expects change context, and understands its modifications will be amend-committed. No blockers for Plan 04-02.

## Self-Check: PASSED
