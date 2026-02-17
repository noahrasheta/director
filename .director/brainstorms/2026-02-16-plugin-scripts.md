# Brainstorm: Plugin Scripts

**Date:** 2026-02-16

## Summary

### Key Ideas
- Director has four bash scripts that handle lifecycle tasks Markdown skills can't do alone: folder setup, session context loading, timestamp saving, and install verification
- Three of four scripts (init-director.sh, session-start.sh, state-save.sh) are actively wired up and working; self-check.sh exists but nothing calls it
- session-start.sh runs on every session via the SessionStart hook but only provides a minimal JSON state summary -- it does NOT load full project context (vision, gameplan, codebase analysis), which validates the plan to add a CLAUDE.md snippet for persistent context awareness
- self-check.sh verifies plugin installation integrity (skills, agents, hooks, manifest) but does NOT cover project data integrity (.director/ contents like vision, goals, brainstorms)
- Plugin integrity (what self-check covers) is low-stakes because reinstalling fixes it; project data integrity is higher-stakes because that's the user's actual work
- Wiring self-check.sh into init-director.sh makes sense since init-director already runs as the first step of almost every Director command

### Decisions Made
- Wire self-check.sh into init-director.sh so plugin integrity is verified before any Director command runs
- Save project data integrity as a separate idea for future exploration

### Open Questions
- Should self-check.sh skip re-running if it already passed recently (marker file), or is it fast enough to just run every time?

## Highlights

The session started with a practical question -- what do the four scripts in the scripts folder actually do? Walking through each one revealed that three are actively connected (init-director via skill references, session-start and state-save via hooks.json) while self-check.sh is orphaned code that was built but never wired in.

The conversation surfaced an important distinction between plugin integrity and project data integrity. self-check.sh only covers the plugin side -- verifying that skills, agents, and config files exist in the plugin cache. But the scarier scenario for a user is losing project data from `.director/` (vision, goals, brainstorms). That's a different problem entirely, and one where git history could enable recovery if a health check knew to look.

The session-start.sh discussion validated an existing plan: the SessionStart hook gives Claude a tiny JSON breadcrumb every session, but full project context only loads when a `/director:` command runs. This confirms that a CLAUDE.md snippet is the right approach for making any Claude session aware of the deeper context in `.director/`.

## Suggested Next Action

That sounds like a quick change. Run `/director:quick "Wire self-check.sh into init-director.sh so plugin integrity is verified before any Director command runs"` to get it done.
