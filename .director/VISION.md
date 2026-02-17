# Vision

## Project Name
Director

## What It Does
Director is a Claude Code plugin that helps solo builders and vibe coders turn ideas into working software. It sits on top of Claude Code and provides structure, planning, and workflow intelligence -- interviewing you about what you want to build, creating a step-by-step gameplan, executing tasks with fresh AI context, and tracking progress as you go. Think of it as a project manager built into your AI coding environment.

## Who It's For
Solo builders and vibe coders -- people who use AI to build software and think in outcomes, not syntax. They want to ship working projects without getting lost in technical complexity.

## Key Features

### Existing
- Interview-based vision capture with one question at a time
- Gameplan generation that breaks projects into goals, steps, and tasks
- Task execution with fresh AI context per task (no quality degradation)
- Goal-backward verification -- checks whether goals were achieved, not just tasks completed
- Session resume after breaks
- Undo / revert last change
- Plain-language output throughout -- no developer jargon
- Brownfield onboarding with parallel deep mapper agents
- Domain research with parallel researcher agents
- Mid-project pivot handling
- Brainstorming with full project context
- Idea capture and review
- Quick one-off task execution
- Visual progress board

### Adding
- Agent config file integration -- during onboarding, automatically add a note to the project's agent config file (CLAUDE.md, .cursorrules, etc.) so the coding agent knows deeper context lives in `.director/`
- Pre-onboard secret scanning -- check for credential files before the mapper reads source code, warn the user if anything sensitive is found
- Claude Code version check at startup -- enforce the v1.0.33+ requirement instead of failing silently

### Changing
- Syncer reliability -- add a health check after the builder commits so silent state drift doesn't happen
- Context staleness -- define concrete thresholds for when codebase analysis is too old and prompt users to refresh
- Mapper resilience -- handle large codebase timeouts gracefully with partial results instead of silent fallback
- Template detection -- make the routing logic more robust so manual edits to vision or gameplan files don't break skill routing
- Pivot memory handling -- clear stale builder patterns after a major direction change
- Context assembly -- reduce duplication between the build and quick workflows

## Tech Stack
Markdown for all workflows, agent definitions, and documentation. Bash for lifecycle scripts. JSON for configuration and manifests. Git for atomic progress saves. Claude Code v1.0.33+ as the host platform. No databases, no npm packages, no build step -- the entire plugin is text files that Claude interprets at runtime.

## Success Looks Like
All high and medium reliability concerns are resolved. The mapper can't accidentally expose secrets. The syncer reports failures instead of hiding them. Users know when their project context is stale. The agent config file gets updated automatically during onboarding so the coding agent is aware of the deeper context in `.director/`. The plugin feels solid and trustworthy for real-world use.

## Decisions Made

| Decision | Why |
|----------|-----|
| Multi-platform support deferred | Not ready yet -- want a rock-solid Claude Code experience first before expanding to Cursor, Codex, etc. |
| No new major features this round | The plugin already does what it needs to. Focus is on making it reliable, not bigger. |
| Agent config file integration included | Discovered through real usage that the coding agent performs better when it knows about `.director/` context |
| All HIGH and MEDIUM concerns addressed | Plugin is live and being used -- reliability matters now |

## Open Questions
- [UNCLEAR] Which agent config file formats need to be supported beyond CLAUDE.md? (.cursorrules, .gemini, others TBD when multi-platform work begins)
- [UNCLEAR] What are the right staleness thresholds for codebase analysis? Research suggested "7 days or 10+ completed tasks" as a starting point -- needs validation through real usage.
