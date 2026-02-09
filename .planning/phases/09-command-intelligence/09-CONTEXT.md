# Phase 9: Command Intelligence - Context

**Gathered:** 2026-02-09
**Status:** Ready for planning

<domain>
## Phase Boundary

Every `/director:` command becomes state-aware: it detects where the user is in the project lifecycle and redirects gracefully when invoked out of sequence. Commands speak plain English, accept optional inline text to focus interactions, enforce Director's terminology, and support undo for reverting task commits.

</domain>

<decisions>
## Implementation Decisions

### Routing behavior
- Redirect conversationally when commands are invoked out of sequence -- suggest the right command and wait for the user to confirm, never auto-route silently
- State checks only on key entry points (build, blueprint, inspect, pivot) -- lightweight commands (help, status, idea, brainstorm) skip state validation
- When `/director:onboard` is invoked on an already-onboarded project: acknowledge the existing vision and offer a choice (update it or move on to planning) -- the user may have intentionally re-run it for a pivot or vision update
- Partially complete states detected and picked up where the user left off -- detect the furthest progress point and suggest the natural next step from there

### Undo scope & safety
- `/director:undo` reverts exactly one task commit (the most recent) -- simple and predictable
- Sequential undos supported: invoke undo multiple times to revert multiple tasks, each invocation is independent
- Always confirm before reverting: "Going back to before [task name]. This will remove those changes. Continue?"
- Undo works on everything -- regular build tasks AND quick-mode changes (both produce atomic commits)
- Full rollback on undo: revert code AND `.director/` state (STATE.md, .done.md rename, etc.) -- the task disappears as if it never happened
- Lightweight undo log: a few lines noting what was undone and when, stored quietly in `.director/` without bloating state files

### Inline context handling
- Command-specific interpretation: each command interprets inline text in the way most natural for what it does (idea captures, quick executes, build matches tasks, blueprint focuses updates)
- Match first, then instruct: for gameplan-aware commands (build, inspect, blueprint), try to match inline text against existing tasks/steps first; if no match, treat as general instruction to the agent
- When inline text doesn't match anything and has no obvious interpretation: ask for clarification before proceeding -- never silently ignore what the user typed
- Claude audits which commands need inline support added vs. which already have it, and standardizes where needed

### Claude's Discretion
- Error message structure and exact wording (within the constraint: plain language, what went wrong, why, what to do next, never blame the user)
- Terminology enforcement implementation approach (compile-time checking vs. runtime word list vs. agent instructions)
- Which specific commands need inline text support added (some already have it from Phases 7-8)
- Help command content and organization

</decisions>

<specifics>
## Specific Ideas

- Entry points for new work on a running project are: `/director:quick` for small changes, `/director:idea` + `/director:ideas` for capture and review, `/director:brainstorm` for exploration, and `/director:blueprint "..."` for planning new features into the gameplan
- The routing pattern already exists in several skills (build, blueprint, onboard) -- Phase 9 should audit and standardize these patterns across all commands rather than building from scratch
- Undo log should be minimal -- just a breadcrumb trail, not a full audit system

</specifics>

<deferred>
## Deferred Ideas

None -- discussion stayed within phase scope

</deferred>

---

*Phase: 09-command-intelligence*
*Context gathered: 2026-02-09*
