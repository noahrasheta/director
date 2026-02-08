# Phase 4: Execution - Context

**Gathered:** 2026-02-08
**Status:** Ready for planning

<domain>
## Phase Boundary

Execute tasks one at a time with fresh AI context per task, atomic git commits, and documentation sync after each task. Users run `/director:build` and Director handles task selection, context assembly, execution, commit, and doc sync. Sub-agent spawning within tasks is included. Verification (Phase 5), progress display (Phase 6), and quick mode (Phase 7) are separate phases.

</domain>

<decisions>
## Implementation Decisions

### Doc sync scope
- Claude's Discretion: whether to check code changes only or do a broader codebase scan — pick what makes sense technically per task

### Doc sync reporting
- When sync finds out-of-date docs, show the diff in plain language and ask the user to confirm before applying changes
- Never auto-update docs silently — user always sees what changed and approves

### External change detection
- Check for outside-Director changes (manual edits, other tools) only on `/director:resume`, not after every task
- Per-task sync focuses on the task's own changes to keep it fast

### Post-task summary format
- Both: a plain-language paragraph summarizing what was built, followed by a structured bullet list of specific file changes
- Paragraph gives the narrative; bullets give the specifics

### Claude's Discretion
- Task selection algorithm (how to pick next ready task when multiple are available)
- Context assembly strategy (what gets loaded into fresh agent window, how much git history)
- Commit message formatting
- Sub-agent spawning decisions within tasks
- How to handle partial task success
- Doc sync technical approach (code-change-only vs full scan, per task)

</decisions>

<specifics>
## Specific Ideas

No specific requirements — open to standard approaches

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 04-execution*
*Context gathered: 2026-02-08*
