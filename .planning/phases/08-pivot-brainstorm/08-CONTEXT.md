# Phase 8: Pivot & Brainstorm - Context

**Gathered:** 2026-02-08
**Status:** Ready for planning

<domain>
## Phase Boundary

Two context-heavy workflows: (1) Pivot — change project direction mid-build while preserving valid completed work and updating all documentation, and (2) Brainstorm — open-ended exploration with full project awareness that saves sessions and routes to appropriate next actions. Creating new capabilities (like undo or command intelligence) belongs in other phases.

</domain>

<decisions>
## Implementation Decisions

### Pivot conversation flow
- Both inline and interview paths: `/director:pivot "switching to GraphQL"` skips interview; bare `/director:pivot` opens a conversation
- Claude's discretion on interview framing (what changed vs where are we going)
- Codebase re-mapping only when stale — if significant work or time elapsed since last map, spawn mapper; otherwise trust STATE.md + doc sync
- Pivot scope detection: tactical pivots (tech stack, approach) update gameplan only; strategic pivots (product direction, target users) update VISION.md + gameplan. Director asks the user which type when it's ambiguous.

### Change impact analysis
- Claude's discretion on delta granularity (goal-level, step-level, or task-level depending on pivot scope)
- In-progress work: complete current task first, then pivot from clean commit state. User can `/director:undo` after if they want to abandon that task.
- Completed work that's now irrelevant: Director flags it and adds cleanup tasks to the new gameplan (not removed automatically)
- Always require user approval before applying pivot changes — show full delta summary, user confirms, then Director applies all changes

### Brainstorm session shape
- Start guided, go free — Director opens with a frame ("What are you thinking about?"), then follows wherever the user goes
- Adaptive context loading: start with VISION.md + STATE.md, load deeper context (GAMEPLAN.md, codebase files) on-demand when brainstorm touches code-level concerns
- Director's tone: match the user's energy with a bias toward supportive exploration. Surface feasibility concerns gently when they matter ("Love that idea. One thing to keep in mind: [concern]")
- Code-aware: user can reference specific parts of the codebase and Director reads relevant files to ground the discussion

### Session endings & routing
- Both user and Director can end sessions — user says "done" anytime; Director checks in periodically during natural pauses
- Brainstorm files saved as summary + highlights: structured summary at top (key ideas, decisions, open questions) with key excerpts below. Saved to `.director/brainstorms/YYYY-MM-DD-<topic>.md`
- Brainstorm exit: always save the session file, then suggest ONE best next action based on what was discussed (save as idea, quick task, blueprint update, pivot, or just "session saved")
- Pivot exit: Claude's discretion on the ending flow (delta-then-approve vs staged application)

### Claude's Discretion
- Pivot interview framing and question design
- Delta granularity presentation (goal vs step vs task level)
- Pivot ending flow (single approval vs staged)
- Brainstorm check-in timing and frequency
- When to load deeper context during brainstorm
- Exact brainstorm summary structure

</decisions>

<specifics>
## Specific Ideas

- Pivot feasibility concern surfacing should be gentle, not blocking: "Love that idea. One thing to keep in mind: [concern]. Want to explore how to handle that, or keep going?"
- Brainstorm sessions are valuable even without action — "Session saved. Pick it back up anytime." is a valid ending
- Adaptive context loading keeps brainstorm costs low for casual sessions, goes deep only when needed

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 08-pivot-brainstorm*
*Context gathered: 2026-02-08*
