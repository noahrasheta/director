# Codebase Structure

**Analysis Date:** 2026-02-16

## Directory Layout

```
director/
  .claude-plugin/          # Claude Code plugin configuration
    plugin.json            # Plugin metadata and version
    marketplace.json       # Marketplace listing configuration

  .director/               # Project state (created at runtime)
    VISION.md              # Source of truth for what is being built
    GAMEPLAN.md            # Goals > Steps > Tasks structure
    STATE.md               # Progress tracking and current position
    IDEAS.md               # Captured future ideas
    config.json            # Project configuration
    codebase/              # Codebase analysis documents (written by deep mapper)
      STACK.md
      ARCHITECTURE.md
      STRUCTURE.md
      CONVENTIONS.md
      TESTING.md
      INTEGRATIONS.md
      CONCERNS.md
      SUMMARY.md
    goals/                 # Goal/step/task directory tree
      01-goal-slug/
        GOAL.md
        01-step-slug/
          STEP.md
          tasks/
            01-task-slug.md
            02-task-slug.md
            01-task-slug.done.md    # Completed tasks renamed here
        02-step-slug/
          STEP.md
          tasks/
      02-goal-slug/
    brainstorms/           # Brainstorm session transcripts

  agents/                  # Agent definitions (sub-agents spawned by skills)
    director-builder.md             # Implements individual tasks
    director-verifier.md            # Checks code quality and wiring
    director-syncer.md              # Updates documentation
    director-deep-mapper.md         # Analyzes codebase for arch/tech/quality/concerns
    director-mapper.md              # Quick codebase scan for refresh
    director-interviewer.md         # Conducts vision interviews
    director-planner.md             # Generates gameplan from vision
    director-deep-researcher.md     # Domain/ecosystem research
    director-researcher.md          # Targeted research for implementation
    director-synthesizer.md         # Summarizes research findings
    director-debugger.md            # Diagnoses failures

  skills/                  # User-facing commands (14 slash commands)
    onboard/
      SKILL.md             # /director:onboard workflow
      templates/
        vision-template.md
        codebase/          # Templates for analysis documents
          ARCHITECTURE.md
          STACK.md
          STRUCTURE.md
          CONVENTIONS.md
          TESTING.md
          INTEGRATIONS.md
          CONCERNS.md
          SUMMARY.md
        research/          # Templates for research documents
        config-defaults.json

    blueprint/
      SKILL.md             # /director:blueprint workflow
      templates/
        goal-template.md
        step-template.md
        step-research.md
        task-template.md
        gameplan-template.md

    build/
      SKILL.md             # /director:build workflow

    inspect/
      SKILL.md             # /director:inspect workflow

    quick/
      SKILL.md             # /director:quick workflow

    status/
      SKILL.md             # /director:status workflow

    resume/
      SKILL.md             # /director:resume workflow

    pivot/
      SKILL.md             # /director:pivot workflow

    brainstorm/
      SKILL.md             # /director:brainstorm workflow
      templates/

    idea/
      SKILL.md             # /director:idea workflow

    ideas/
      SKILL.md             # /director:ideas workflow

    refresh/
      SKILL.md             # /director:refresh workflow

    undo/
      SKILL.md             # /director:undo workflow

    help/
      SKILL.md             # /director:help workflow

  hooks/
    hooks.json             # Lifecycle hooks (SessionStart, SessionEnd)

  scripts/
    init-director.sh       # Initialize .director/ on first run
    session-start.sh       # Run at Claude Code session start
    state-save.sh          # Run at Claude Code session end
    self-check.sh          # Validate plugin integrity

  reference/               # Documentation for developers/agents
    terminology.md         # Director-specific vocabulary
    plain-language-guide.md # How to communicate with users
    context-management.md  # Context assembly patterns
    verification-patterns.md # Quality gate strategies

  docs/
    design/
      DIRECTOR.md          # Project README/manifesto
      PRD.md               # Full product requirements document
      docs-notes.md        # Living document for future user guide
      research-*.md        # Research and analysis documents
    resources/             # External documentation and references
    logos/                 # Brand assets

  site/                    # Landing page / documentation website
    css/
    js/
    assets/

  .github/
    workflows/             # GitHub Actions CI/CD

  CLAUDE.md                # Instructions for Claude Code
  README.md                # Public project documentation
  CHANGELOG.md             # Version history
  LICENSE                  # MIT license
```

## Directory Purposes

**`.claude-plugin/`:**
- Purpose: Claude Code plugin manifest and configuration
- Contains: plugin.json (metadata, version, author), marketplace.json (listing info)
- Key files: `plugin.json` (defines name, version, homepage, repository)

**`.director/`:**
- Purpose: Project state and project-specific analysis (created at runtime)
- Contains: Vision, gameplan, progress tracking, goal/step/task hierarchy, codebase analysis docs
- Key files: `VISION.md` (source of truth), `GAMEPLAN.md` (plan), `STATE.md` (progress), `config.json` (settings)
- Note: This directory is created by `scripts/init-director.sh` if it doesn't exist

**`agents/`:**
- Purpose: Agent role definitions that orchestrate specific work
- Contains: One `.md` file per agent type; each defines role, context requirements, tools, execution rules, and sub-agent spawning
- Key files: `director-builder.md` (code writing), `director-verifier.md` (quality checks), `director-syncer.md` (doc updates)

**`skills/`:**
- Purpose: User-facing commands and their workflows
- Contains: 14 subdirectories (one per slash command), each with a SKILL.md file defining the workflow
- Key files: Each skill is a complete workflow (checking state, routing decisions, spawning agents, assembling context)
- Note: Users invoke these indirectly by typing `/director:command`

**`hooks/`:**
- Purpose: Lifecycle hooks that integrate with Claude Code runtime
- Contains: hooks.json registering SessionStart and SessionEnd hooks
- Key files: `hooks.json` (defines which scripts run at session boundaries)

**`scripts/`:**
- Purpose: Bash utilities and hooks
- Contains: Initialization script, session lifecycle scripts, validation script
- Key files: `init-director.sh` (first-time setup), `session-start.sh` (resume after break), `state-save.sh` (persist progress)

**`reference/`:**
- Purpose: Documentation for builder agents and developers
- Contains: Terminology guide, plain language guide, context management patterns, verification strategies
- Key files: `terminology.md` (vocabulary), `plain-language-guide.md` (user-facing style), `context-management.md` (AI context patterns)

**`docs/design/`:**
- Purpose: Product design and strategy documentation
- Contains: PRD (full requirements), manifesto, research, brainstorms
- Key files: `PRD.md` (primary reference), `DIRECTOR.md` (manifesto), `docs-notes.md` (living material for user guide)

**`site/`:**
- Purpose: Landing page and marketing website
- Contains: HTML, CSS, JavaScript, brand assets
- Key files: Static web assets for director.cc

## Key File Locations

**Entry Points:**
- `skills/onboard/SKILL.md` -- Invoked by `/director:onboard` command
- `skills/build/SKILL.md` -- Invoked by `/director:build` command
- `scripts/init-director.sh` -- Initialization entry point (run if `.director/` missing)
- `hooks/hooks.json` -- Lifecycle hooks (SessionStart, SessionEnd)

**Configuration:**
- `.claude-plugin/plugin.json` -- Plugin metadata (version, author, homepage)
- `.director/config.json` -- Project settings (model, cost limits, feature flags)
- `skills/onboard/templates/config-defaults.json` -- Default config template

**Core Logic:**
- `agents/director-builder.md` -- Task execution logic (writing code, creating commits)
- `agents/director-verifier.md` -- Quality checking logic (stubs, wiring, acceptance criteria)
- `agents/director-syncer.md` -- Documentation sync logic (STATE.md updates, task completion)
- `agents/director-planner.md` -- Gameplan generation logic (Vision → Goals > Steps > Tasks)
- `agents/director-deep-mapper.md` -- Codebase analysis logic (produces ARCHITECTURE.md, CONVENTIONS.md, etc.)

**Templates:**
- `skills/onboard/templates/vision-template.md` -- Vision document template
- `skills/blueprint/templates/goal-template.md`, `step-template.md`, `task-template.md` -- Gameplan templates
- `skills/onboard/templates/codebase/ARCHITECTURE.md`, `STACK.md`, etc. -- Codebase analysis document templates

**Testing:**
- Not applicable -- Director itself is a plugin with no automated test suite (uses behavioral verification via `/director:inspect`)

## Naming Conventions

**Files:**
- Skill files: `skills/[command-name]/SKILL.md` (e.g., `skills/build/SKILL.md`)
- Agent files: `agents/director-[role].md` (e.g., `agents/director-builder.md`)
- Template files: `[type]-template.md` (e.g., `goal-template.md`, `task-template.md`)
- Project state: `UPPERCASE.md` (e.g., VISION.md, GAMEPLAN.md, STATE.md)
- Configuration: `config.json`, `config-defaults.json`
- Analysis documents: `ARCHITECTURE.md`, `STACK.md`, `CONVENTIONS.md`, `TESTING.md`, etc.

**Directories:**
- Skill folders: lowercase with hyphens (e.g., `skills/onboard`, `skills/deep-mapper`)
- Goal folders: numbered with slug (e.g., `01-mvp`, `02-phase-2`)
- Step folders: numbered with slug (e.g., `01-setup-database`, `02-auth-system`)
- Task files: numbered with slug (e.g., `01-create-tables.md`, `02-seed-data.md`)

## Where to Add New Code

Use the following locations when adding new code to this project.

**New user-facing command (new slash command):**
- Create directory: `skills/[command-name]/`
- Add workflow file: `skills/[command-name]/SKILL.md` with numbered steps and routing logic
- Add templates if needed: `skills/[command-name]/templates/` (if command generates artifacts)
- Example: See `skills/build/SKILL.md` for a complete command workflow
- Pattern: Check prerequisites, route on conditions, spawn agents, assemble context, present results

**New agent type (new sub-agent for internal use):**
- Create file: `agents/director-[role].md` (e.g., `agents/director-optimizer.md`)
- Define role, context assumptions, tools, execution rules, and spawnable sub-agents
- Follow naming pattern: `director-` prefix, followed by role name in lowercase with hyphens
- Example: See `agents/director-builder.md` (125 lines) and `agents/director-verifier.md` (141 lines) for examples
- Pattern: YAML header with name/description/tools/model/maxTurns, then step-by-step instructions

**New skill template (for artifact generation):**
- Place in: `skills/[command-name]/templates/`
- Example: `skills/blueprint/templates/goal-template.md`
- Pattern: Use placeholder text like `[Goal Name]`, `_[Description]_` that skills will interpolate
- For codebase analysis templates: place in `skills/onboard/templates/codebase/` (e.g., `INTEGRATION.md` if adding new analysis type)

**New reference documentation (for agents/developers):**
- Place in: `reference/` (e.g., `reference/git-patterns.md`)
- Pattern: Document patterns that multiple agents should follow, or guidance agents need
- Example: `reference/terminology.md` (vocabulary), `reference/plain-language-guide.md` (user-facing style)

**New design/research documentation:**
- Place in: `docs/design/` for strategy/requirements/analysis (e.g., `docs/design/research-*.md`)
- Place in: `docs/resources/` for external materials or archived research
- Example: `docs/design/PRD.md` (primary requirements reference)

**Project state files (at runtime):**
- User-facing goals/steps/tasks: `.director/goals/NN-goal-slug/NN-step-slug/tasks/NN-task-slug.md`
- Analysis documents written by mapper: `.director/codebase/ARCHITECTURE.md`, etc.
- Brainstorm sessions: `.director/brainstorms/YYYY-MM-DD-HH-MM-brainstorm.md`
- Don't commit these manually; they're generated by agent runs

**Landing page / documentation:**
- Place in: `site/` (e.g., `site/css/style.css`, `site/js/main.js`)
- Note: `site/index.html` is gitignored (generated at build time)

## Special Directories

**`.director/` (project state):**
- Purpose: Stores all project-specific state, vision, gameplan, and codebase analysis
- Generated: Yes (created by `scripts/init-director.sh` on first run)
- Committed: Yes (users commit `.director/` to track project evolution)
- Note: This is the source of truth for what the project is building and what's been completed

**`.director/codebase/` (codebase analysis):**
- Purpose: Stores technical analysis documents produced by deep mapper agents
- Generated: Yes (written by `director-deep-mapper.md` during onboard and refresh)
- Committed: Yes (committed to preserve understanding of architecture/conventions/concerns)
- Files: STACK.md, ARCHITECTURE.md, STRUCTURE.md, CONVENTIONS.md, TESTING.md, INTEGRATIONS.md, CONCERNS.md, SUMMARY.md

**`.claude-plugin/` (plugin metadata):**
- Purpose: Claude Code plugin configuration
- Generated: No (static configuration)
- Committed: Yes (required for plugin to work)
- Contains: `plugin.json` (version, author, metadata), `marketplace.json` (marketplace listing)

**`node_modules/`, `.git/`, etc.:**
- Not in scope -- Director is a Claude Code plugin, not a Node.js project
- Director has no dependencies or build process
- It's a collection of Markdown files with embedded workflows and agent definitions

## Quality Gate

Before considering this file complete, verify:
- [x] Every finding includes at least one file path in backticks
- [x] Voice is prescriptive ("Use X", "Place files in Y") not descriptive ("X is used")
- [x] No section left empty -- use "Not detected" or "Not applicable"
- [x] Directory tree present and annotated
- [x] "Where to Add New Code" has at least 3 entries (new command, new agent, new template, new reference, new state files, new design doc)
- [x] All paths use backtick formatting
