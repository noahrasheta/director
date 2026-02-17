# Codebase Summary

**Project:** Director
**Analysis Date:** 2026-02-16

## What This Project Is

Director is a Claude Code plugin that helps solo builders and vibe coders turn ideas into working software. It sits on top of Claude Code and provides structure, planning, and workflow guidance -- interview you about what you want to build, create a step-by-step gameplan, execute tasks one at a time with AI, and track progress as you go. Think of it as a project manager built into your AI coding environment.

The plugin is entirely made of Markdown files and Bash scripts -- no traditional programming language, no build step, no database. All the "logic" lives in instructions that Claude reads and follows. This makes it unusually lightweight: installing Director is just adding files to a project.

## Built With

Director is built with Markdown (for all workflows, agent definitions, and documentation), Bash (for lifecycle scripts), and plain HTML/CSS/JavaScript (for the marketing website at director.cc). It requires Claude Code v1.0.33+ and Git. There are no npm packages, no Python dependencies for the plugin itself, and no database. The entire plugin is a collection of text files that Claude Code interprets at runtime.

## What It Can Do

- Users can run `/director:onboard` to start a new project or connect an existing codebase to Director's planning system
- Users can run `/director:blueprint` to create or update a step-by-step gameplan from their vision
- Users can run `/director:build` to execute the next task in the plan with fresh AI context
- Users can run `/director:inspect` to verify whether goals were actually achieved, not just completed
- Users can run `/director:status` to see a visual progress board of all goals, steps, and tasks
- Users can run `/director:resume` to restore context after stepping away from a project
- Users can run `/director:pivot` to handle changes in direction mid-project
- Users can run `/director:brainstorm` to think through ideas with full project context
- Users can run `/director:quick "..."` to execute a fast one-off task without full planning
- Users can capture ideas with `/director:idea`, review them with `/director:ideas`, and undo changes with `/director:undo`

## How It's Organized

The project is split into four main areas. The `skills/` directory holds 14 command workflows -- one per `/director:` command. The `agents/` directory holds 11 specialized AI workers that the commands spawn to do specific jobs (writing code, checking quality, updating documentation, analyzing a codebase, conducting interviews, etc.). The `scripts/` and `hooks/` directories hold the Bash scripts that run at session start and end. And `.director/` (created at runtime in each user's project) is where all project state lives -- the vision, gameplan, progress tracking, and task files.

---

## Key Findings

### Technology

Director uses no traditional programming framework. Its core runtime is Claude Code's plugin system, invoked through slash commands. Key technologies:

- **Markdown** -- All agent definitions, skill workflows, and reference docs live as `.md` files in `agents/`, `skills/`, and `reference/`
- **Bash** -- Lifecycle scripts in `scripts/` (init, session-start, session-end, self-check); requires Bash v3+
- **JSON** -- Configuration in `.claude-plugin/plugin.json`, `hooks/hooks.json`, `.director/config.json`
- **Claude Code v1.0.33+** -- Required platform; plugin fails without it (no version check currently enforced -- see Concerns)
- **Git 2.0+** -- Required for all atomic commit operations; tasks are not completable without it
- **Python 3.6+** -- Optional; used in `scripts/session-start.sh` for JSON parsing; falls back to grep if absent
- **GitHub Pages** -- Hosts director.cc from the `site/` directory; no build step required

See `.director/codebase/STACK.md` for full details.

### Integrations

Director has minimal external dependencies by design:

- **Claude Code Plugin System** -- Core integration point; all commands are slash commands defined in `skills/*/SKILL.md` and registered with the plugin runtime
- **GitHub API** -- Version checking only; `scripts/session-start.sh` fetches `marketplace.json` from `https://raw.githubusercontent.com/noahrasheta/director/main/.claude-plugin/marketplace.json` with a 2-second timeout to compare installed vs. latest version
- **WebFetch (optional)** -- Used by `agents/director-deep-researcher.md` for domain research during onboard; degrades gracefully if unavailable
- **MCP servers (inherited)** -- Director is MCP-compatible but not MCP-dependent; it inherits whatever MCP servers the user has configured in Claude Code (Supabase, Stripe, etc.)
- **No database, no auth provider, no analytics** -- All state lives in local `.director/` files; no environment variables required

See `.director/codebase/INTEGRATIONS.md` for full details.

### Architecture

Director is a multi-agent orchestration framework built around three core loops: Blueprint (plan), Build (execute), Inspect (verify). Its architecture has five distinct layers:

- **Command/Skill Layer** -- 14 user-facing commands, each a self-contained workflow in `skills/[command]/SKILL.md`
- **Agent Layer** -- 11 specialized sub-agents in `agents/director-*.md` (builder, verifier, syncer, mapper, researcher, planner, interviewer, etc.)
- **Project State Layer** -- Source of truth in `.director/` (VISION.md, GAMEPLAN.md, STATE.md, goals tree, codebase analysis)
- **Document Assembly System** -- Skills assemble XML-wrapped context packages before spawning agents; users never see the XML
- **Scripting and Hooks Layer** -- Bash scripts in `scripts/` and `hooks/hooks.json` for session lifecycle integration

The key data flow: user runs a command → skill reads state → skill spawns agents with fresh XML-wrapped context → agents do work → syncer updates `.director/` → skill reports to user. State is never accumulated across invocations.

See `.director/codebase/ARCHITECTURE.md` for full data flows and entry points.

### Conventions

- **Agent files** use YAML frontmatter (name, description, tools, model, maxTurns) followed by numbered instructions. See `agents/director-builder.md` for the canonical pattern.
- **Skill files** are named `SKILL.md` and placed in `skills/[command-name]/`. Each follows: check prerequisites → route on conditions → spawn agents → assemble context → present results.
- **State documents** use SCREAMING_SNAKE_CASE (`VISION.md`, `GAMEPLAN.md`, `STATE.md`). Design docs use kebab-case (`research-competitive-analysis.md`).
- **XML boundary tags** (`<vision>`, `<task>`, `<current_step>`, `<instructions>`, etc.) are used to wrap context passed between agents. This is internal wiring -- never shown to users.
- **Director vocabulary is mandatory** in all user-facing output: Goal/Step/Task (never phase/sprint/ticket), Vision/Gameplan/Launch (never spec/roadmap/deploy), "Progress saved" (never commit/SHA).
- **Forbidden jargon** in user-facing text: `dependency`, `repository`, `branch`, `merge`, `commit`, `schema`, `endpoint`, `middleware`, `runtime`, and dozens more -- see `reference/terminology.md` and `reference/plain-language-guide.md`.
- **File paths in backticks** are required in all agent-facing documentation.

See `.director/codebase/CONVENTIONS.md` for complete conventions.

### Concerns

Prioritized from most to least critical:

1. **HIGH -- Secret exposure risk in deep mapper** (`agents/director-deep-mapper.md`): The mapper reads source files to produce analysis. If a user has accidentally committed a secrets file (`.env`, credentials), the mapper could quote those values into `.director/codebase/STACK.md` or other analysis files, which are then committed to git. The protection is text-only instructions ("never read `.env`"), not enforced by tooling.

2. **MEDIUM -- Syncer failure leaves stale state** (`skills/build/SKILL.md`, `agents/director-syncer.md`): The syncer runs after the builder commits. If the syncer crashes, the code commit exists but `.director/` docs are not updated. This creates silent state drift that can break task sequencing on the next build.

3. **MEDIUM -- Context staleness thresholds undefined** (`reference/context-management.md`, `skills/refresh/SKILL.md`): Infrastructure exists to track when codebase analysis was generated, but no rules define when it's "too old." Users don't know when to run `/director:refresh`.

4. **MEDIUM -- Deep mapper failure degrades onboard** (`skills/onboard/SKILL.md`, `agents/director-deep-mapper.md`): If any of the 4 parallel mapper agents fails or times out (40-turn limit), the fallback to v1.0 director-mapper may produce incomplete context. Large codebases are most at risk.

5. **MEDIUM -- Claude Code version not checked at runtime** (`README.md`, `skills/onboard/SKILL.md`): The plugin requires Claude Code v1.0.33+ but no version check exists in the code. Older versions fail silently with confusing errors.

6. **MEDIUM -- Duplicated context assembly logic** (`skills/build/SKILL.md`, `skills/quick/SKILL.md`): The complex context assembly procedure is duplicated in both build and quick skills. Changes must be made in two places.

See `.director/codebase/CONCERNS.md` for complete concerns with fix approaches.

---

## Things Worth Noting

- **No automated tests exist** -- Director uses its own three-tier verification strategy (AI structural checking + user behavioral confirmation + optional test frameworks) rather than Jest/Vitest/pytest. This is intentional: the system's correctness depends on whether the generated documentation is accurate and whether users can do what was built, not on unit test coverage.

- **The `.director/` directory is both generated and committed** -- It is created at runtime by `scripts/init-director.sh` but users are expected to commit it to track project evolution. The codebase analysis files you're reading right now are examples of this pattern in action.

- **The plugin has no CI/CD pipeline** -- `.github/workflows/` exists but contains no workflow files. Changes are pushed manually; GitHub Pages auto-deploys `site/` for the marketing website. There is no automated deployment or validation gate.

- **Parallel agent execution is a core performance pattern** -- During `/director:onboard`, 4 deep mapper agents run in parallel (one each for tech, architecture, quality, and concerns) and 4 researcher agents run in parallel afterward. This reduces onboard time substantially but creates the failure-mode risk noted in Concerns.

- **The marketing site (`site/`) is gitignored** -- `site/index.html` is not tracked in git (confirmed by recent commit history). Only the assets (`css/`, `js/`, `assets/`) are tracked. This is a known gap.

- **`docs/design/docs-notes.md` is a living document** -- During any brainstorming or explanation session, useful content for the future user guide should be appended here. This is an explicit project convention per `CLAUDE.md`.

---

## For Builder Agents

Use the following guidance when working in this codebase.

**File structure:**
- Place new slash commands in `skills/[command-name]/SKILL.md`
- Place new agent types in `agents/director-[role].md`
- Place new templates in `skills/[command-name]/templates/` or `skills/onboard/templates/codebase/` for analysis doc templates
- Place new reference documentation (patterns agents should follow) in `reference/`
- Place new design/strategy docs in `docs/design/`
- Place landing page assets in `site/css/`, `site/js/`, `site/assets/`
- Do not manually create `.director/` files -- they are generated by agent runs at runtime

**Naming conventions:**
- Agent files: `director-[role].md` in `agents/` (e.g., `director-optimizer.md`)
- Skill directories: lowercase with hyphens (e.g., `skills/my-command/`)
- State documents: SCREAMING_SNAKE_CASE (e.g., `VISION.md`, `GAMEPLAN.md`)
- Design/research docs: kebab-case (e.g., `research-my-topic.md`)
- Goal/step/task directories: numbered with slug (e.g., `01-mvp/`, `01-setup-auth/`)
- Task files: numbered with slug (e.g., `01-create-tables.md`); completed tasks become `01-create-tables.done.md`
- Follow naming examples in `agents/` and `skills/` directories

**Key patterns to follow:**
- Use YAML frontmatter in all agent files -- include `name`, `description`, `tools`, `model`, `maxTurns`. See `agents/director-builder.md` for the canonical format.
- Use XML boundary tags (`<vision>`, `<task>`, `<instructions>`, `<current_step>`, `<recent_changes>`) when assembling context for agent invocations -- see `agents/director-builder.md` and `reference/context-management.md`
- Use Director vocabulary in all user-facing text -- see `reference/terminology.md` and `reference/plain-language-guide.md` before writing any user-facing content
- Use the skill pattern for all new commands: check prerequisites → route on conditions → spawn agents with fresh context → present results. See `skills/build/SKILL.md` for a complete example.
- Wrap every file path reference in backticks in agent-facing documentation -- this is a hard convention enforced across all mapper and agent files

**Things to avoid:**
- Do not use git/tech jargon in user-facing output -- no commits, branches, SHAs, dependencies, endpoints, schemas, middleware. See `reference/terminology.md` for the full forbidden list. See `.director/codebase/CONCERNS.md`
- Do not let the deep mapper agent read `.env` files or any file that could contain credentials -- the protection is instruction-based, not tool-enforced. See `.director/codebase/CONCERNS.md`
- Do not duplicate context assembly logic between skills -- the current duplication between `skills/build/SKILL.md` and `skills/quick/SKILL.md` is a known technical debt item. See `.director/codebase/CONCERNS.md`
- Do not store secrets in `.director/config.json` -- configuration is for settings only, not credentials. See `.director/codebase/CONCERNS.md`
- Do not accumulate conversation history across agent invocations -- each agent receives a fresh context package assembled by the skill. See `reference/context-management.md`

---

## Cross-Reference Findings

The following connections across mapper outputs are worth noting for builders:

**STACK + CONCERNS: No version enforcement despite stated requirement.** STACK.md documents that Claude Code v1.0.33+ is required and CONCERNS.md flags that no version check exists in the code. If adding a new skill, the onboard skill (`skills/onboard/SKILL.md`) is the best place to add this check.

**ARCHITECTURE + CONCERNS: Syncer failure creates state drift.** ARCHITECTURE.md describes the syncer agent as the sole writer to STATE.md for conflict avoidance. CONCERNS.md flags that if syncer fails after a builder commit, state drifts silently. These two patterns interact: the deliberate single-writer design means there is no fallback writer, making syncer failure more impactful.

**ARCHITECTURE + TESTING: The verification system is the testing system.** TESTING.md documents that no traditional test frameworks exist and that Director uses its own three-tier verification. ARCHITECTURE.md shows this is by design -- the verifier agent (`agents/director-verifier.md`) is structurally integrated into the build loop, not bolted on. These are consistent and intentional.

**INTEGRATIONS + CONCERNS: No CI/CD means no automated safety gate.** INTEGRATIONS.md confirms `.github/workflows/` has no workflow files. Combined with CONCERNS.md's security finding (mapper could expose secrets), there is no automated pre-commit or pre-push check catching dangerous patterns. This gap increases the importance of following the deep mapper's forbidden-files instructions.

**CONVENTIONS + STRUCTURE: Template-based detection depends on specific placeholder text.** CONVENTIONS.md documents that skills detect whether documents are still templates by scanning for placeholder markers. STRUCTURE.md shows the template files that produce these markers are in `skills/onboard/templates/` and `skills/blueprint/templates/`. Builders adding new templates must include detectable placeholder text (e.g., `_No goals defined yet_`) or the routing logic in skills will fail.

**STACK + ARCHITECTURE: Python is optional but relied upon implicitly.** STACK.md notes that Python 3 is used in `scripts/session-start.sh` for JSON parsing with a fallback to grep. ARCHITECTURE.md describes the session-start hook as a critical lifecycle entry point that loads context summaries. The fallback path is documented but not confirmed to produce equivalent results -- a potential degradation vector for users without Python.

---

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| STACK.md | HIGH | Complete inventory with versions and file paths; no gaps detected |
| INTEGRATIONS.md | HIGH | Minimal integrations accurately documented; confirmed no env vars required |
| ARCHITECTURE.md | HIGH | Thorough layer-by-layer analysis with data flows and entry points; all 5 layers documented |
| STRUCTURE.md | HIGH | Accurate directory tree with purposes; "Where to Add New Code" section is actionable |
| CONVENTIONS.md | HIGH | Prescriptive conventions with examples; covers all file types and naming patterns |
| TESTING.md | HIGH | Accurately documents the intentional absence of traditional tests; three-tier strategy well-explained |
| CONCERNS.md | HIGH | Specific findings with file locations, priorities, and fix approaches; one HIGH-priority security issue identified |
