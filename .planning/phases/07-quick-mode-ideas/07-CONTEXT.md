# Phase 7: Quick Mode & Ideas - Context

**Gathered:** 2026-02-08
**Status:** Ready for planning

<domain>
## Phase Boundary

Lightweight escape hatches for the Director workflow: (1) quick mode executes small changes immediately with atomic commits and no planning overhead, and (2) idea capture saves thoughts instantly for later analysis and routing. This phase does NOT add new planning workflows, verification tiers, or documentation formats.

Two commands added: `/director:idea` (capture) and `/director:ideas` (view + act on). Quick mode uses existing `/director:quick`.

</domain>

<decisions>
## Implementation Decisions

### Quick mode guardrails
- Complexity assessment uses **scope detection** (not file count) -- escalate if the change involves new features, architectural changes, or cross-cutting concerns
- When too complex, **explain and suggest**: "This looks bigger than a quick change because [reason]. Want to run /director:blueprint to plan it?" -- no auto-routing
- Verification after quick tasks: **Claude's discretion** -- skip for trivial changes, run Tier 1 structural check for anything substantial
- Documentation sync after quick tasks: **Claude's discretion** -- color tweaks skip sync, changes touching structure or new components get STATE.md updates

### Quick mode execution feel
- User feedback during execution: **Claude's discretion** -- one-liner for trivial, brief play-by-play for multi-file changes
- Commit messages prefixed with `[quick]` -- e.g., `[quick] change button color to blue` -- visually distinct in git log
- Quick tasks tracked equally in STATE.md -- appear in recent activity and cost tracking alongside build tasks (no separate section)
- Never mention undo availability after quick tasks -- users who want it already know

### Idea organization
- IDEAS.md uses a **flat chronological list** with timestamps -- newest first, zero friction
- Each idea captured **as-is** -- no reformatting, no summarizing, no follow-up questions at capture time
- Ideas can be any length: one-line thoughts or multi-paragraph musings
- When an idea is acted on, it is **removed** from IDEAS.md -- the file stays a clean inbox of pending ideas
- Acted-on ideas live in gameplan (if blueprinted) or git history (if quick-executed)

### Idea-to-action routing
- Two separate commands: `/director:idea "..."` for capture, `/director:ideas` for viewing and acting
- `/director:ideas` shows the idea list, user picks one conversationally ("Let's work on #3")
- Three routing destinations: quick task (simple), blueprint (needs planning), brainstorm (needs exploration)
- **Conversational routing with confirmation**: Claude analyzes the idea, suggests a route with reasoning, user confirms before proceeding
- No auto-execution -- always a confirmation gate before routing

### Claude's Discretion
- Quick mode verification depth (skip vs Tier 1) based on change scope
- Quick mode doc sync depth based on change impact
- Quick mode user feedback verbosity based on change complexity

</decisions>

<specifics>
## Specific Ideas

- User envisions `/director:idea` (singular) as the natural capture command -- "idea" followed by thoughts
- `/director:ideas` (plural) feels like "show me my ideas" -- the collection view
- Routing conversation should feel natural: "That's a straightforward change -- I can handle it as a quick task. Sound good?" not a menu of options

</specifics>

<deferred>
## Deferred Ideas

None -- discussion stayed within phase scope

</deferred>

---

*Phase: 07-quick-mode-ideas*
*Context gathered: 2026-02-08*
