# Phase 3: Planning - Context

**Gathered:** 2026-02-08
**Status:** Ready for planning

<domain>
## Phase Boundary

Gameplan creation that breaks VISION.md into Goals, Steps, and Tasks with dependencies. Users run `/director:blueprint` to generate or update a reviewable plan. Creating and updating the gameplan is in scope. Executing tasks (Phase 4), verification (Phase 5), and progress tracking (Phase 6) are not.

</domain>

<decisions>
## Implementation Decisions

### Planning conversation flow
- Interactive breakdown: blueprint works through the vision, generating Goals first for user review before filling in Steps and Tasks
- User reviews all proposed goals together (not one at a time), then approves the set or gives conversational feedback to adjust
- After goal approval, Steps and Tasks are generated without additional pause points
- Even with inline text (`/director:blueprint "add payment processing"`), goals are still shown for review before proceeding
- Approval at goal level only — Steps and Tasks are Claude's domain once goals are locked

### Gameplan presentation & review
- Full outline view: show the complete hierarchy (Goals > Steps > Tasks) with one-line descriptions at every level
- Dependencies shown in plain language on each task: "Needs user login first"
- User adjusts the gameplan through conversational feedback ("move auth before the dashboard", "split this into two steps") — not by editing files
- Explicit approval required: blueprint asks "Does this look good?" and waits for a clear yes before writing files

### Update mode behavior
- Holistic re-evaluation: when updating (even with scoped inline text), re-evaluate the entire gameplan in light of new context — additions may affect ordering, dependencies, or grouping elsewhere
- Changes communicated via delta summary: "Added 2 tasks, removed 1 step, reordered Goal 2" — user sees exactly what changed
- Same explicit approval flow as initial creation: show delta summary, ask for confirmation before saving
- Completed work handling: Claude's discretion (safest approach for preserving done work)

### Claude's Discretion
- How completed work is handled during updates (frozen vs. reorganizable)
- Step and Task decomposition within approved goals
- Dependency graph construction and ordering logic
- Complexity indicators (small/medium/large) assignment
- Verification criteria generation per task

</decisions>

<specifics>
## Specific Ideas

- Interactive at goal level mirrors how a founder reviews a project plan — big picture first, details delegated
- Delta summary for updates aligns with Director's existing delta format pattern (ADDED/MODIFIED/REMOVED from brownfield onboarding)
- Conversational adjustment over file editing keeps the vibe coder audience from touching structured files

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 03-planning*
*Context gathered: 2026-02-08*
