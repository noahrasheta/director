# Phase 1: Plugin Foundation - Context

**Gathered:** 2026-02-07
**Status:** Ready for planning

<domain>
## Phase Boundary

Director exists as a valid Claude Code plugin that creates project structure and registers all commands and agents. This phase delivers the manifest, folder structure, ~11 slash commands (registered but only help is functional), ~8 agent definitions (full prompts), templates, config, reference docs, and the hybrid formatting layer. No command workflows are implemented beyond help and intelligent routing — those come in Phases 2-8.

</domain>

<decisions>
## Implementation Decisions

### Initialization experience
- `.director/` is created automatically the first time any `/director:` command is run — no separate init step
- Creation is silent — no listing of files, no setup wizard, just "Director is ready" and proceed to what the user asked for
- If `.director/` already exists when `/director:onboard` runs, an agent should inspect the codebase to determine if this is a greenfield new installation or a brownfield project that needs mapping — not just skip/reset
- Git is auto-initialized silently if no `.git/` exists — no mention of git to the user, no confirmation prompt

### Config defaults
- Very opinionated defaults — everything on by default (guided mode, tips, verification, cost tracking, doc sync). Users turn things off if they want
- `config.json` is human-readable and directly editable — documented format, no command required to change settings
- Include a `config_version` field so Director can detect old configs and migrate them silently on update
- Retry limit for verification auto-fix cycles: Claude's discretion (decide based on task complexity during implementation)

### Help output & command routing
- `/director:help` groups commands by workflow stage: Blueprint / Build / Inspect / Other — matches Director's core loop
- Each command shows an inline example (e.g., `/director:quick "change button color to blue"`)
- Every command is smart about project state from day one — no dumb "not implemented" stubs
- If a user runs `/director:build` with nothing to build, it says "We're not ready to build. You need to start with `/director:onboard` first. Ready to get started?" and routes to the appropriate workflow
- If `/director:quick` receives a complex task, it suggests `/director:blueprint` first
- This context-aware routing is the default behavior, not a Phase 9 add-on

### Agent role boundaries
- All 8 agents get full, complete system prompts in Phase 1 — not placeholders
- Default model tiers by complexity: Builder + Planner + Interviewer on Opus/Sonnet, Verifier + Syncer + Mapper on Haiku
- Users can override model assignment per-agent in `config.json`
- Tool restriction enforcement: Claude's discretion (hard deny vs soft instruction per agent)
- Agent memory (persistent learning): Claude's discretion on which agents get `memory: project` now vs later

### Claude's Discretion
- Retry limit for verification auto-fix cycles (3 vs 5 vs dynamic)
- Whether `/director:help` includes a mini-status showing current project state
- Hard vs soft tool restrictions for read-only agents (verifier, mapper)
- Which agents get persistent memory in Phase 1 vs deferred
- Loading skeleton and error state design for any UI elements

</decisions>

<specifics>
## Specific Ideas

- "Each command should be capable of detecting if it needs to route to a different workflow" — the user wants commands to be intelligent about project state, not just check if they're implemented
- The routing messages should be conversational and suggest action: "Ready to get started?" not just "Run /director:onboard"
- Config should feel like something you can open and understand — not a wall of obscure settings

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 01-plugin-foundation*
*Context gathered: 2026-02-07*
