# Phase 6: Progress & Continuity - Context

**Gathered:** 2026-02-08
**Status:** Ready for planning

<domain>
## Phase Boundary

Users always know where they are, what happened, and what's next — even after closing their terminal and coming back days later. This phase delivers status display, state persistence, session resume, and cost tracking. It does NOT add new workflow commands or change how build/inspect/blueprint work.

</domain>

<decisions>
## Implementation Decisions

### Status display
- Default view: goal-level with step breakdown underneath (tasks summarized as counts, not listed individually)
- Progress bars for goals ("Goal 1: [████████────] 67%"), fraction counts for steps/tasks ("Step 2: 3/7 tasks")
- "Ready to work on" suggestion at the bottom — informational, not pushy
- Blocked items: Claude's discretion on inline vs separate section — whichever reads cleanest

### Resume experience
- Shows summary of last session PLUS analysis of what changed since then
- Detects and analyzes external changes (manual edits, other tools): "Login.tsx was modified — this might affect the signup task you're about to start"
- Ends with a suggested next action: "Ready to start the user profile page? Just say go."
- Tone: Claude's discretion — adapt based on project context and break length

### State persistence
- STATE.md updates after every task AND on command exit — never stale
- Tracks progress (task statuses, current position, completion counts) AND a decisions log (key decisions made during building)
- STATE.md format: Claude's discretion — optimize for both human readability and machine parsing
- STATE.md changes committed to git as part of task commits — state is versioned with the code

### Cost tracking
- Granularity: per goal (not per task or per step)
- Visibility: summary in /director:status, detailed breakdown available on request
- Format: token counts + dollar amounts ("Goal 1: 450K tokens ($4.50)")
- No pre-task cost warnings — track after the fact, don't add friction before building

### Claude's Discretion
- Blocked items visual treatment (inline vs separate section)
- Resume tone (warm vs efficient, based on context)
- STATE.md format (Markdown structure, YAML frontmatter, etc.)
- How to surface the detailed cost breakdown (sub-command, argument, or inline expansion)

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

*Phase: 06-progress-continuity*
*Context gathered: 2026-02-08*
