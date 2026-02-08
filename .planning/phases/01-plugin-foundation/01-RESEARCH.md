# Phase 1: Plugin Foundation - Research

**Researched:** 2026-02-07
**Domain:** Claude Code plugin system (skills, agents, hooks, manifest, configuration)
**Confidence:** HIGH

## Summary

Phase 1 delivers Director as a valid Claude Code plugin: the manifest, folder structure, ~11 slash commands (registered but only help is functional with intelligent routing), ~8 agent definitions (full system prompts), templates, config, reference docs, and the hybrid formatting layer. No command workflows are implemented beyond help and context-aware routing -- those come in Phases 2-8.

The Claude Code plugin system is entirely declarative. Director is not compiled code -- it is a structured collection of Markdown files (skills, agents), JSON configuration (manifest, hooks, config), and shell scripts (hook handlers). The "stack" is the Claude Code Plugin System itself. All capabilities are registered through directory conventions and YAML frontmatter. This means Phase 1 is primarily a content authoring and prompt engineering phase, not a software engineering phase.

The research confirms that every component needed for Phase 1 is well-documented in official Claude Code documentation. The plugin manifest schema, skill frontmatter fields, agent frontmatter fields, hook event lifecycle, and directory structure conventions are all authoritatively specified. The primary risk is getting the directory structure wrong (only `plugin.json` goes inside `.claude-plugin/`; everything else at the plugin root), which causes silent failures.

**Primary recommendation:** Build the plugin manifest first, verify it loads with `claude --plugin-dir`, then add components incrementally -- skills, agents, hooks, templates, reference docs -- testing registration at each step.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

#### Initialization experience
- `.director/` is created automatically the first time any `/director:` command is run -- no separate init step
- Creation is silent -- no listing of files, no setup wizard, just "Director is ready" and proceed to what the user asked for
- If `.director/` already exists when `/director:onboard` runs, an agent should inspect the codebase to determine if this is a greenfield new installation or a brownfield project that needs mapping -- not just skip/reset
- Git is auto-initialized silently if no `.git/` exists -- no mention of git to the user, no confirmation prompt

#### Config defaults
- Very opinionated defaults -- everything on by default (guided mode, tips, verification, cost tracking, doc sync). Users turn things off if they want
- `config.json` is human-readable and directly editable -- documented format, no command required to change settings
- Include a `config_version` field so Director can detect old configs and migrate them silently on update
- Retry limit for verification auto-fix cycles: Claude's discretion (decide based on task complexity during implementation)

#### Help output & command routing
- `/director:help` groups commands by workflow stage: Blueprint / Build / Inspect / Other -- matches Director's core loop
- Each command shows an inline example (e.g., `/director:quick "change button color to blue"`)
- Every command is smart about project state from day one -- no dumb "not implemented" stubs
- If a user runs `/director:build` with nothing to build, it says "We're not ready to build. You need to start with `/director:onboard` first. Ready to get started?" and routes to the appropriate workflow
- If `/director:quick` receives a complex task, it suggests `/director:blueprint` first
- This context-aware routing is the default behavior, not a Phase 9 add-on

#### Agent role boundaries
- All 8 agents get full, complete system prompts in Phase 1 -- not placeholders
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

### Deferred Ideas (OUT OF SCOPE)
None -- discussion stayed within phase scope
</user_constraints>

## Standard Stack

This phase has no traditional "stack" in the software sense. Director is a declarative plugin -- Markdown files, JSON configuration, and shell scripts.

### Core

| Component | Format | Purpose | Why Standard |
|-----------|--------|---------|--------------|
| `.claude-plugin/plugin.json` | JSON | Plugin manifest -- registers Director with Claude Code | Required by plugin system. Only file that goes inside `.claude-plugin/` |
| `skills/*/SKILL.md` | Markdown + YAML frontmatter | Slash command definitions (`/director:*`) | Official skills format. Each skill is a directory with SKILL.md as entrypoint |
| `agents/*.md` | Markdown + YAML frontmatter | Subagent definitions (8 specialized agents) | Official subagent format. YAML frontmatter for config, markdown body for system prompt |
| `hooks/hooks.json` | JSON | Event handler configuration | Official hook format. Supports command, prompt, and agent hook types |
| `reference/*.md` | Markdown | Internal guidance docs (terminology, plain-language rules, verification patterns) | Referenced from skills/agents for domain knowledge |
| Templates in `skills/*/` | Markdown | `.director/` artifact templates (VISION.md, GAMEPLAN.md, etc.) | Co-located with the skill that uses them |

### Supporting

| Component | Format | Purpose | When to Use |
|-----------|--------|---------|-------------|
| `scripts/*.sh` | Bash | Hook handler scripts | When hooks need executable logic (state validation, `.director/` initialization) |
| `CLAUDE.md` at plugin root | Markdown | Plugin-level persistent instructions | Loaded into every agent context automatically by Claude Code |
| `.director/config.json` | JSON | User project configuration | Created on first `/director:` command invocation |

### What NOT to Use

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| Node.js/TypeScript application code | No runtime to execute. Plugins are declarative content, not apps | Markdown skills, agent prompts, JSON config, shell scripts |
| Build systems (webpack, esbuild) | Nothing to compile or bundle. Plugin is a directory of text files | Direct file authoring |
| `commands/` directory | Legacy location. `skills/` is recommended for new development (supports directories with supporting files) | `skills/` directory with `SKILL.md` files |
| YAML configuration for user-facing artifacts | PRD mandates Markdown for human-readable, JSON for machine state. YAML adds a third format | Markdown for `.director/*.md`, JSON for `config.json` |
| Test frameworks (Vitest, Jest) for the plugin | Plugin components are prompts and config, not executable code. Test by running the plugin | Manual testing with `claude --plugin-dir ./director` |

## Architecture Patterns

### Recommended Plugin Structure

```
director/                                   # Plugin root
  .claude-plugin/
    plugin.json                             # Plugin manifest (name, version, description)

  skills/                                   # User-facing slash commands (~11)
    onboard/
      SKILL.md                              # /director:onboard -- context-aware routing + workflow
      templates/
        vision-template.md                  # Template for VISION.md generation
        config-defaults.json                # Default config.json content
    blueprint/
      SKILL.md                              # /director:blueprint
      templates/
        gameplan-template.md
        goal-template.md
        step-template.md
        task-template.md
    build/
      SKILL.md                              # /director:build
    inspect/
      SKILL.md                              # /director:inspect
    status/
      SKILL.md                              # /director:status
    resume/
      SKILL.md                              # /director:resume
    quick/
      SKILL.md                              # /director:quick
    pivot/
      SKILL.md                              # /director:pivot
    brainstorm/
      SKILL.md                              # /director:brainstorm
      templates/
        brainstorm-session.md
    idea/
      SKILL.md                              # /director:idea
    help/
      SKILL.md                              # /director:help -- the ONLY fully functional command in Phase 1

  agents/                                   # Specialized subagents (~8)
    director-interviewer.md
    director-planner.md
    director-researcher.md
    director-mapper.md
    director-builder.md
    director-verifier.md
    director-debugger.md
    director-syncer.md

  hooks/
    hooks.json                              # Event hook configuration

  reference/                                # Internal docs loaded by agents/skills
    terminology.md                          # Director vocabulary rules (Goal/Step/Task, etc.)
    plain-language-guide.md                 # How to communicate with vibe coders
    verification-patterns.md                # Stub/orphan/wiring detection patterns
    context-management.md                   # Fresh agent window assembly rules

  scripts/                                  # Hook scripts and utilities
    init-director.sh                        # Creates .director/ folder structure
    check-state-integrity.sh                # Validates STATE.md consistency

  CLAUDE.md                                 # Plugin-level memory/instructions
  CHANGELOG.md
  LICENSE
  README.md
```

### Pattern 1: Plugin Manifest Registration

**What:** The `.claude-plugin/plugin.json` file registers Director with Claude Code. The `name` field becomes the namespace prefix for all skills.
**When to use:** Required. Must exist before any other component loads.
**Source:** [Plugins Reference - code.claude.com](https://code.claude.com/docs/en/plugins-reference)

```json
{
  "name": "director",
  "description": "Opinionated, spec-driven orchestration framework for vibe coders. Guides the entire build process from vision to working product.",
  "version": "0.1.0",
  "author": {
    "name": "Noah Rasheta"
  },
  "homepage": "https://director.cc",
  "repository": "https://github.com/noahrasheta/director",
  "license": "MIT",
  "keywords": ["orchestration", "vibe-coding", "workflow", "planning", "ai-agents"]
}
```

The `name: "director"` causes all skills to be namespaced as `director:skill-name`, producing `/director:onboard`, `/director:build`, etc.

### Pattern 2: Skill Definition with Context-Aware Routing

**What:** Each skill's SKILL.md uses YAML frontmatter for invocation control and markdown body for instructions. For Phase 1, most skills contain routing logic that detects project state and redirects appropriately.
**When to use:** Every `/director:*` command.
**Source:** [Skills - code.claude.com](https://code.claude.com/docs/en/skills)

```yaml
---
name: build
description: Execute the next ready task in your project gameplan. Use when
  the user wants to make progress on their project.
disable-model-invocation: true
---

# Build

First, check the project state:

1. Check if `.director/` exists. If not:
   - Create it silently using the init script
   - Tell the user: "Director is ready."

2. Check if `.director/VISION.md` exists and has content. If not:
   - Say: "We're not ready to build yet. You need to start with
     `/director:onboard` first to define what you're building.
     Ready to get started?"
   - Wait for user response. If they agree, proceed as if they
     invoked /director:onboard.

3. Check if `.director/GAMEPLAN.md` exists and has tasks. If not:
   - Say: "You have a vision but no gameplan yet. Let's create one
     with `/director:blueprint` so we know what to build first.
     Want to do that now?"
   - Wait for user response.

4. Check `.director/STATE.md` for a task with status "ready". If none:
   - Say: "All tasks are either complete or waiting on something else.
     Here's where things stand:" and show current progress.

5. If a ready task exists:
   - Say: "This command will be fully functional in a future update.
     The next ready task is: [task name]. Stay tuned!"

$ARGUMENTS
```

**Key frontmatter fields for Phase 1 skills:**

| Field | Value | Rationale |
|-------|-------|-----------|
| `disable-model-invocation` | `true` for all commands except `help` | Prevents Claude from auto-triggering Director commands. User should control when workflows run. |
| `context` | NOT set in Phase 1 (no `context: fork`) | Phase 1 commands don't execute tasks -- they do routing. Forking is unnecessary overhead. Add `context: fork` in Phase 4 when build/inspect actually execute. |
| `agent` | NOT set in Phase 1 | Agent linkage added when workflows are implemented. Phase 1 skills contain routing instructions directly. |

### Pattern 3: Agent Definition with Full System Prompts

**What:** Each agent is a Markdown file with YAML frontmatter defining its configuration and markdown body containing the complete system prompt.
**When to use:** All 8 agent definitions.
**Source:** [Sub-agents - code.claude.com](https://code.claude.com/docs/en/sub-agents)

```yaml
---
name: director-builder
description: Executes individual tasks with fresh context. Writes code,
  makes changes, produces atomic commits. Use when Director needs to
  implement a specific task from the gameplan.
tools: Read, Write, Edit, Bash, Grep, Glob, Task(director-verifier, director-syncer)
model: inherit
maxTurns: 50
---

You are Director's builder agent. Your job is to implement a single task
from the project gameplan.

## Context

You receive assembled context wrapped in XML boundary tags:
- <vision> -- The project's Vision document (what is being built)
- <current_step> -- The current step context
- <task> -- Your specific task with acceptance criteria
- <recent_changes> -- Recent git history showing what was built before
- <instructions> -- Specific constraints for this task

## Rules

1. Complete ONLY the task described in <task>. Do not modify files
   outside the listed scope.
2. Write real implementation code. No stubs, no placeholders, no TODO
   comments, no hardcoded data that should be dynamic.
3. When finished, create exactly one git commit with a descriptive
   message. The user will see "Progress saved" -- never mention git,
   commits, or SHAs.
4. Before committing, verify your work against the acceptance criteria
   in <task>.
5. Use plain language in all output. Never use jargon like
   "dependencies", "artifact wiring", or "integration testing".

## Sub-Agents

You can spawn these sub-agents when needed:
- **director-verifier**: To check your work for stubs, placeholders,
  orphaned files, or wiring issues
- **director-syncer**: To verify .director/ documentation matches the
  current codebase state

## Output

When complete, report what you built in plain language:
- What was created or changed
- How it connects to what was built before
- What the user can do with it now
```

**Agent frontmatter fields reference (from official docs):**

| Field | Required | Values | Purpose |
|-------|----------|--------|---------|
| `name` | Yes | lowercase + hyphens | Unique identifier |
| `description` | Yes | text | When Claude should delegate to this agent |
| `tools` | No | tool names, `Task(agent1, agent2)` | Allowlist of tools. `Task(name)` restricts which sub-agents can be spawned. Inherits all if omitted |
| `disallowedTools` | No | tool names | Denylist -- removed from inherited or specified list |
| `model` | No | `sonnet`, `opus`, `haiku`, `inherit` | Model to use. Defaults to `inherit` |
| `permissionMode` | No | `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, `plan` | How permission prompts are handled |
| `maxTurns` | No | number | Maximum agentic turns before stopping |
| `skills` | No | skill names | Full skill content injected into context at startup |
| `memory` | No | `user`, `project`, `local` | Persistent memory scope. Creates `.claude/agent-memory/<name>/` |
| `hooks` | No | hook config | Lifecycle hooks scoped to this agent |
| `color` | No | color string | Background color in the UI |

**Platform constraint:** Subagents cannot spawn other subagents. Nesting is flat: skill -> agent -> sub-agents. No deeper nesting.

### Pattern 4: Silent `.director/` Initialization

**What:** The `.director/` folder is created automatically the first time any `/director:` command runs. No separate init step, no setup wizard, no file listing.
**When to use:** Every skill checks for `.director/` at the start. If missing, creates it silently.

The initialization creates:
```
.director/
  VISION.md           # Empty template with section headers
  GAMEPLAN.md          # Empty template with section headers
  STATE.md             # Initial state (no goals, no tasks)
  IDEAS.md             # Empty with header
  config.json          # Opinionated defaults (everything on)
  brainstorms/         # Empty directory
  goals/               # Empty directory
```

**Implementation approach:** A shell script at `scripts/init-director.sh` handles the creation. Skills call it via `!`bash ${CLAUDE_PLUGIN_ROOT}/scripts/init-director.sh`` or check for `.director/` existence directly in skill instructions and tell Claude to create it.

### Pattern 5: Hybrid Formatting (Markdown/XML/JSON)

**What:** Three-layer formatting model. Users see Markdown. Agents receive XML-wrapped Markdown. Machine state is JSON.
**When to use:** All context assembly, all state management.
**Source:** PRD Section 9.4

| Layer | Format | Who Sees It | Example |
|-------|--------|-------------|---------|
| User-facing artifacts | Markdown | Vibe coders (`.director/` files) | VISION.md, GAMEPLAN.md, STEP.md |
| Agent context assembly | XML boundaries wrapping Markdown | AI agents only (assembled at runtime) | `<vision>...</vision>`, `<task>...</task>` |
| Machine state | JSON | Neither (internal) | config.json |

```markdown
<!-- Assembled context for a builder agent (Phase 4+) -->
<vision>
[Contents of .director/VISION.md]
</vision>

<current_step>
[Contents of relevant STEP.md]
</current_step>

<task>
[Task description, acceptance criteria, relevant files]
</task>

<recent_changes>
[Recent git log summary]
</recent_changes>

<instructions>
Complete only this task. Do not modify files outside the listed scope.
Verify your work matches the acceptance criteria before committing.
</instructions>
```

### Pattern 6: Dynamic Context Injection in Skills

**What:** The `!`command`` syntax in SKILL.md runs shell commands before the skill content reaches Claude. Output replaces the placeholder.
**When to use:** Injecting live project state into skill prompts (STATE.md, config.json, etc.).
**Source:** [Skills - code.claude.com](https://code.claude.com/docs/en/skills)

```yaml
---
name: status
description: Show visual progress board for your project
disable-model-invocation: true
---

<project_state>
!`cat .director/STATE.md 2>/dev/null || echo "No project state found."`
</project_state>

<config>
!`cat .director/config.json 2>/dev/null || echo "{}"`
</config>

Show the user their project progress...
```

### Anti-Patterns to Avoid

- **Putting components inside `.claude-plugin/`:** Only `plugin.json` goes in `.claude-plugin/`. Skills, agents, hooks, scripts -- all at plugin root. Getting this wrong causes silent failures where components simply don't load.
- **Using `context: fork` prematurely:** Phase 1 skills do routing, not execution. Forking creates unnecessary overhead. Add `context: fork` only when skills actually spawn agents for task execution (Phase 4+).
- **Building a workflow engine:** The skill IS the workflow. Claude follows the markdown instructions. No separate runtime, no state machine, no orchestration layer. The "workflow engine" is Claude following SKILL.md step-by-step.
- **Letting agents write state directly:** Only the orchestrating skill (top-level SKILL.md being followed by Claude) should write to `.director/` state files. Agents return results; the skill writes state. Exception: director-syncer for doc updates as a controlled post-task operation.
- **Hard-coding file path restrictions in frontmatter:** Claude Code's `allowed-tools` works at tool level (Write, Edit, Bash), not path level. Path-level restrictions must be enforced via agent instructions ("Only modify files within `.director/`").

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Plugin registration | Custom registration system | `.claude-plugin/plugin.json` manifest | Claude Code discovers plugins automatically from manifest |
| Slash command routing | Command parser or router code | YAML frontmatter `name` field in SKILL.md | Plugin namespace auto-generates `/director:name` commands |
| Agent spawning | Custom agent launcher | `Task(agent-name)` tool + `context: fork` in skills | Claude Code handles spawning, context isolation, result collection |
| Dynamic context loading | Custom file reader in agent prompts | `!`command`` syntax in SKILL.md | Preprocessed before prompt reaches Claude -- no runtime code |
| Tool restrictions | Custom permission system | `tools` and `disallowedTools` in agent frontmatter | Claude Code enforces tool access at the platform level |
| Persistent memory | Custom file-based memory | `memory: project` in agent frontmatter | Creates `.claude/agent-memory/<name>/` with automatic loading of first 200 lines of MEMORY.md |
| Hook event handling | Custom event system | `hooks/hooks.json` with matchers | Claude Code fires hooks at lifecycle events automatically |
| Environment variables in hooks | Custom env management | `$CLAUDE_ENV_FILE` in SessionStart hooks, `${CLAUDE_PLUGIN_ROOT}` for paths | Platform-provided mechanisms for env setup and path resolution |

**Key insight:** The Claude Code plugin system already provides most infrastructure. Director's value is in the prompt content (agent system prompts, skill instructions, reference docs, templates) and the workflow design (how skills chain agents together), not in building plugin infrastructure.

## Common Pitfalls

### Pitfall 1: Directory Structure Wrong -- Silent Component Failures

**What goes wrong:** Components (skills, agents, hooks) are placed inside `.claude-plugin/` instead of at the plugin root. Claude Code silently ignores them -- no error, no warning.
**Why it happens:** Intuition suggests all plugin files belong in the plugin directory. But `.claude-plugin/` is ONLY for `plugin.json`.
**How to avoid:** Verify structure immediately. Run `claude --debug` after creating the manifest to confirm component discovery. Use `/agents` to verify agents appear. Use `/director:help` to verify skills register.
**Warning signs:** Commands silently do nothing when invoked. Agents don't appear in `/agents` list.

### Pitfall 2: Skills Too Large -- Exceeding Context Budget

**What goes wrong:** Skill descriptions (the `description` field) eat into Claude's context budget. With ~11 skills, descriptions that are too verbose can exceed the 2% context window budget for skill descriptions.
**Why it happens:** The `description` field is loaded into context at session start so Claude knows what's available. If total skill descriptions exceed the budget, some skills are excluded.
**How to avoid:** Keep `description` fields concise (1-2 sentences). Put detailed instructions in the markdown body of SKILL.md, which only loads when invoked. Run `/context` to check for warnings about excluded skills.
**Warning signs:** `/context` shows a warning about excluded skills. Some `/director:*` commands don't appear in Claude's available tools.

### Pitfall 3: Agent Prompts Assuming Future Functionality

**What goes wrong:** Phase 1 agents get full system prompts, but the workflows they describe don't exist yet (Phases 2-8). If a user invokes an agent directly (via `/agents`), the agent tries to follow its system prompt and fails because `.director/` files don't have the expected content.
**Why it happens:** The user decision is to write full agent prompts in Phase 1, but those agents won't be connected to skills until later phases.
**How to avoid:** Each agent's system prompt should include a graceful degradation section: "If the expected context is not available (no <vision> tags, no <task> tags), explain that this agent needs to be invoked through Director's workflow commands and suggest `/director:help`." This prevents confusion if users discover agents in the `/agents` list and try to invoke them directly.
**Warning signs:** Agent produces confused output when invoked without assembled context.

### Pitfall 4: Config Schema Without Migration Path

**What goes wrong:** `config.json` is created with initial defaults but no `config_version` field. Later updates add new config fields but old configs don't have them. Director fails or behaves unexpectedly with old configs.
**Why it happens:** The user explicitly decided on `config_version` for silent migration, but it's easy to forget to implement the migration logic alongside the initial schema.
**How to avoid:** Include `config_version: 1` in the initial config.json template. Every skill that reads config.json must use a function that: (1) reads the file, (2) checks `config_version`, (3) applies any missing defaults from the current version, (4) writes back if migrated. This is enforced in reference docs, not in code.
**Warning signs:** Users report unexpected behavior after updating Director. Config file has fields that don't match current documentation.

### Pitfall 5: Routing Messages Not Conversational

**What goes wrong:** Context-aware routing messages use imperative language ("Run `/director:onboard`") instead of conversational language ("Ready to get started?"). This creates a jarring experience for vibe coders.
**Why it happens:** Technical instinct is to give instructions. The user decision explicitly says routing should suggest action: "Ready to get started?" not just "Run /director:onboard".
**How to avoid:** Every routing message must: (1) explain the current state plainly, (2) suggest the next action conversationally, (3) wait for user response before proceeding. Never use imperative commands. Build a routing message template in the reference docs that all skills follow.
**Warning signs:** Messages feel like error messages instead of conversations.

### Pitfall 6: Hook Scripts Not Executable or Not Using Correct Paths

**What goes wrong:** Hook scripts fail silently because they lack executable permissions or reference paths without `${CLAUDE_PLUGIN_ROOT}`.
**Why it happens:** Shell scripts need `chmod +x`. Paths must use the `${CLAUDE_PLUGIN_ROOT}` variable because the plugin is copied to a cache directory during installation -- absolute paths to the development directory won't work in production.
**How to avoid:** Every script: (1) starts with `#!/usr/bin/env bash`, (2) is made executable with `chmod +x`, (3) references all plugin paths with `${CLAUDE_PLUGIN_ROOT}`. Test hooks with `claude --debug` which shows hook execution details.
**Warning signs:** No hook output in verbose mode (`Ctrl+O`). `claude --debug` shows "Hook command completed with status 126" (permission denied).

## Code Examples

### Example 1: Complete plugin.json Manifest

```json
// Source: https://code.claude.com/docs/en/plugins-reference
{
  "name": "director",
  "description": "Opinionated, spec-driven orchestration framework for vibe coders. Guides the entire build process from vision to working product.",
  "version": "0.1.0",
  "author": {
    "name": "Noah Rasheta"
  },
  "homepage": "https://director.cc",
  "repository": "https://github.com/noahrasheta/director",
  "license": "MIT",
  "keywords": ["orchestration", "vibe-coding", "workflow", "planning", "ai-agents"]
}
```

### Example 2: Help Skill (Fully Functional in Phase 1)

```yaml
# Source: https://code.claude.com/docs/en/skills
---
name: help
description: Show Director commands with examples. Use when the user asks
  what Director can do, how to use it, or needs guidance.
---

# Director Help

Show the user Director's available commands, grouped by workflow stage.
Include an inline example for each command.

## Blueprint (Plan Your Project)

| Command | What It Does | Example |
|---------|-------------|---------|
| `/director:onboard` | Project setup -- interview + vision + initial plan | `/director:onboard` |
| `/director:blueprint` | Create, view, or update your gameplan | `/director:blueprint "add payment processing"` |

## Build (Make Progress)

| Command | What It Does | Example |
|---------|-------------|---------|
| `/director:build` | Execute the next ready task | `/director:build` |
| `/director:quick "..."` | Fast task without full planning | `/director:quick "change the button color to blue"` |

## Inspect (Verify Your Work)

| Command | What It Does | Example |
|---------|-------------|---------|
| `/director:inspect` | Verify what was built matches the goal | `/director:inspect "does checkout actually work?"` |

## Other

| Command | What It Does | Example |
|---------|-------------|---------|
| `/director:status` | Show visual progress board | `/director:status` |
| `/director:resume` | Pick up where you left off | `/director:resume` |
| `/director:brainstorm` | Think out loud with full project context | `/director:brainstorm "what about real-time collab?"` |
| `/director:pivot` | Handle mid-project changes | `/director:pivot "dropping mobile, going web-only"` |
| `/director:idea "..."` | Capture an idea for later | `/director:idea "add dark mode support"` |
| `/director:help` | Show this help | `/director:help` |

$ARGUMENTS
```

### Example 3: Default config.json Template

```json
{
  "config_version": 1,
  "mode": "guided",
  "tips": true,
  "verification": true,
  "cost_tracking": true,
  "doc_sync": true,
  "max_retry_cycles": 3,
  "language": "en",
  "agents": {
    "interviewer": { "model": "inherit" },
    "planner": { "model": "inherit" },
    "researcher": { "model": "inherit" },
    "mapper": { "model": "haiku" },
    "builder": { "model": "inherit" },
    "verifier": { "model": "haiku" },
    "debugger": { "model": "inherit" },
    "syncer": { "model": "haiku" }
  }
}
```

### Example 4: Initialization Shell Script

```bash
#!/usr/bin/env bash
# scripts/init-director.sh
# Creates .director/ folder structure silently.
# Called by skills when .director/ doesn't exist.

set -euo pipefail

DIRECTOR_DIR=".director"

# Exit silently if already exists
if [ -d "$DIRECTOR_DIR" ]; then
  exit 0
fi

# Create directory structure
mkdir -p "$DIRECTOR_DIR/brainstorms"
mkdir -p "$DIRECTOR_DIR/goals"

# Create empty artifacts from templates
cat > "$DIRECTOR_DIR/VISION.md" << 'VISION_EOF'
# Vision

*This file will be populated when you run `/director:onboard`.*
VISION_EOF

cat > "$DIRECTOR_DIR/GAMEPLAN.md" << 'GAMEPLAN_EOF'
# Gameplan

*This file will be populated when you run `/director:blueprint`.*
GAMEPLAN_EOF

cat > "$DIRECTOR_DIR/STATE.md" << 'STATE_EOF'
# Project State

## Current Position
- **Status:** Not started
- **Active Goal:** None
- **Active Step:** None

## Progress
No goals defined yet. Run `/director:onboard` to get started.
STATE_EOF

cat > "$DIRECTOR_DIR/IDEAS.md" << 'IDEAS_EOF'
# Ideas

*Capture ideas with `/director:idea "your idea here"`*
IDEAS_EOF

# Create config with opinionated defaults
cat > "$DIRECTOR_DIR/config.json" << 'CONFIG_EOF'
{
  "config_version": 1,
  "mode": "guided",
  "tips": true,
  "verification": true,
  "cost_tracking": true,
  "doc_sync": true,
  "max_retry_cycles": 3,
  "language": "en",
  "agents": {
    "interviewer": { "model": "inherit" },
    "planner": { "model": "inherit" },
    "researcher": { "model": "inherit" },
    "mapper": { "model": "haiku" },
    "builder": { "model": "inherit" },
    "verifier": { "model": "haiku" },
    "debugger": { "model": "inherit" },
    "syncer": { "model": "haiku" }
  }
}
CONFIG_EOF

# Initialize git if needed (silently)
if [ ! -d ".git" ]; then
  git init -q
  # Add .director/ files to initial commit
  git add "$DIRECTOR_DIR"
  git commit -q -m "Initialize Director project"
fi

exit 0
```

### Example 5: Read-Only Agent Definition (Verifier)

```yaml
# Source: https://code.claude.com/docs/en/sub-agents
---
name: director-verifier
description: Verifies that built code is real implementation, not stubs or
  placeholders. Checks for orphaned files and wiring issues. Use
  proactively after any build task completes.
tools: Read, Grep, Glob, Bash
model: haiku
maxTurns: 30
---

You are Director's verification agent. Your job is to check that code
is real, connected, and complete. You CANNOT modify code -- only report
findings.

## What You Check

### Stub Detection
Look for indicators that code is placeholder rather than real:
- TODO comments or FIXME markers
- Functions that return hardcoded values that should be dynamic
- Empty function bodies or pass-through implementations
- Components that render nothing meaningful
- API routes that return static/mock data
- Console.log placeholders

### Orphan Detection
Look for files that exist but aren't connected:
- Components that are defined but never imported anywhere
- API routes that are defined but no client code calls them
- Utility functions that are never referenced
- CSS/style files that aren't imported

### Wiring Verification
Verify that things connect properly:
- Components are imported and rendered in parent components
- API endpoints are called from the frontend
- Database queries are wired to actual database connections
- Environment variables are referenced where needed

## Output Format

Report findings in plain language. NEVER use jargon like "artifact
wiring" or "dependency graph."

If issues are found:
"I checked your work and found [N] things that need attention:
1. [Plain-language description of issue]
2. [Plain-language description of issue]"

If no issues:
"Everything checks out. The [feature name] is properly built and
connected."

## If Context Is Missing

If you were invoked directly (not through a Director workflow) and
don't have assembled context with <task> tags, explain:
"I'm Director's code checker. I work best when invoked through
Director's workflow commands. Try `/director:help` to see what's
available."
```

### Example 6: hooks.json for Phase 1

```json
{
  "description": "Director plugin hooks -- Phase 1 minimal hooks",
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/session-start.sh",
            "timeout": 5,
            "statusMessage": "Loading Director..."
          }
        ]
      }
    ]
  }
}
```

The SessionStart hook checks if `.director/` exists and, if so, loads a brief status summary into context so Claude knows the project state. This supports the "every command is smart about project state" requirement without adding overhead to every tool call.

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `commands/` directory for slash commands | `skills/` directory with SKILL.md | Late 2025 | Skills support directories with supporting files, frontmatter control, auto-invocation. `commands/` still works but `skills/` is recommended for new development. |
| No agent memory | `memory: user/project/local` in agent frontmatter | Claude Code v1.0.33+ | Agents can persist learning across sessions. First 200 lines of MEMORY.md loaded at startup. |
| No plugin hooks | `hooks/hooks.json` in plugin root | Claude Code v1.0.33+ | Plugins can define lifecycle hooks that merge with user/project hooks |
| No MCP in plugins | `.mcp.json` in plugin root | Claude Code v1.0.33+ | Plugins can bundle MCP servers. Not needed for Director but good to know. |
| Manual subagent spawning | `Task(agent-name)` tool restriction + `context: fork` | Claude Code v1.0.33+ | Skills can restrict which agents a subagent can spawn, preventing uncontrolled proliferation |

## Claude's Discretion Recommendations

Based on research, here are recommendations for the areas left to Claude's discretion:

### Retry limit: Use 3 as default

**Recommendation:** Start with `max_retry_cycles: 3` in config.json. This matches the PRD default and is sufficient for most auto-fix scenarios. The config field allows users to adjust. Dynamic retry based on task complexity can be added in Phase 5 (Verification) when the verifier is actually running fix cycles.

### Help mini-status: Yes, include it

**Recommendation:** Include a mini-status in `/director:help` when `.director/` exists. Use dynamic context injection (`!`cat .director/STATE.md 2>/dev/null``) to show current position. When no project exists, show just the command list. This makes help contextually useful and demonstrates that commands are project-aware. Cost is minimal (one file read).

### Tool restrictions: Use hard deny for read-only agents

**Recommendation:** Use `disallowedTools: Write, Edit` in the verifier and mapper agent frontmatter rather than soft instructions. Claude Code enforces tool denial at the platform level, which is more reliable than instructional constraints. The agents physically cannot modify files. For the syncer, use soft instructions ("Only modify files within `.director/`") since it needs Write access but should be scope-limited.

| Agent | Approach | Tools | Rationale |
|-------|----------|-------|-----------|
| director-verifier | Hard deny | `tools: Read, Grep, Glob, Bash` (Write/Edit denied by omission + `disallowedTools: Write, Edit`) | Verification must be read-only. Hard enforcement prevents any chance of the verifier modifying code. |
| director-mapper | Hard deny | `tools: Read, Grep, Glob, Bash` (Write/Edit denied) | Codebase analysis is read-only. Hard enforcement prevents mapper from making changes. |
| director-syncer | Soft instruction | All tools available, instructions scope to `.director/` | Needs Write access to update docs, but should only touch `.director/` files. |
| director-builder | Full access | All tools + `Task(director-verifier, director-syncer)` | Needs all tools to implement tasks. Sub-agent spawning restricted to verifier and syncer only. |

### Agent memory: Defer all to Phase 2 except builder

**Recommendation:** Only give `memory: project` to the builder agent in Phase 1. The builder benefits most from persistent learning (codebase patterns, project conventions, debugging insights). Other agents can receive memory in Phase 2 when the "Learning Tips" feature is built. Rationale:

- **Builder (Phase 1):** Directly benefits from remembering codebase patterns across sessions
- **Interviewer (Phase 2):** Benefits from remembering user preferences, but only after multiple onboarding sessions validate what's worth remembering
- **Verifier (Phase 2):** Benefits from remembering false positive patterns, but only after accumulating real verification data
- **All others (Phase 2+):** Low benefit until their workflows are actively running

### Error state design: Keep it simple and conversational

**Recommendation:** No loading skeletons or fancy UI elements. Director runs in a terminal. Error states should be conversational text: "Something went wrong: [plain explanation]. Here's what to try: [action]." If a command takes more than 5 seconds, show a status message. Use the `statusMessage` field in hook configuration for hook-related waits.

## Open Questions

1. **Exact `.gitignore` entries for `.director/`**
   - What we know: `.director/` should be committed to git (it's the project state). But some files might be temporary or user-specific.
   - What's unclear: Should any `.director/` files be gitignored? The brainstorms/ directory? config.json (which might have user-specific model preferences)?
   - Recommendation: Commit everything. Config.json should be shared (it's project config). Brainstorms are project knowledge. If user-specific overrides are needed later, add a `.director/local.json` that's gitignored.

2. **Context budget for ~11 skill descriptions**
   - What we know: Skill descriptions budget is 2% of context window. With ~11 skills, this should be fine.
   - What's unclear: Exact character count threshold. Whether verbose descriptions for 11 skills approach the limit.
   - Recommendation: Keep descriptions under 150 characters each. Run `/context` after creating all skills to verify. Set `SLASH_COMMAND_TOOL_CHAR_BUDGET` env var if needed.

3. **Plugin-level CLAUDE.md content**
   - What we know: A `CLAUDE.md` at the plugin root is loaded into every agent context automatically.
   - What's unclear: Whether this should contain Director's core instructions (terminology, plain-language rules) or if reference docs serve that purpose better.
   - Recommendation: Use plugin CLAUDE.md for minimal, always-applicable rules (terminology map, "never use jargon", "users see Goal/Step/Task not Milestone/Phase/Plan"). Put detailed guidance in reference docs loaded on demand.

4. **Claude Code minimum version enforcement**
   - What we know: v1.0.33+ is needed for `context: fork`, agent memory, and hooks. The blocker in STATE.md mentions this.
   - What's unclear: How to detect Claude Code version from within a plugin. Whether a SessionStart hook can check this.
   - Recommendation: Document the minimum version requirement in README.md. Add a version note to `/director:help` output. A SessionStart hook could run `claude --version` and warn if too old, but verify this works first.

## Sources

### Primary (HIGH confidence)
- [Claude Code Skills Documentation](https://code.claude.com/docs/en/skills) -- Skill frontmatter fields, invocation control, dynamic context injection, supporting files. Fetched 2026-02-07.
- [Claude Code Sub-agents Documentation](https://code.claude.com/docs/en/sub-agents) -- Agent frontmatter fields (name, description, tools, model, permissionMode, maxTurns, skills, memory, hooks, color), built-in agents, spawning patterns, persistent memory. Fetched 2026-02-07.
- [Claude Code Hooks Reference](https://code.claude.com/docs/en/hooks) -- All hook events (SessionStart, PreToolUse, PostToolUse, Stop, SubagentStart, SubagentStop, etc.), matcher patterns, JSON input/output, exit codes, environment variables, async hooks, prompt/agent hooks. Fetched 2026-02-07.
- [Claude Code Plugins Reference](https://code.claude.com/docs/en/plugins-reference) -- Plugin manifest schema (all fields), directory structure, component paths, caching behavior, CLI commands, debugging tools. Fetched 2026-02-07.
- [Claude Code Plugin Marketplaces](https://code.claude.com/docs/en/plugin-marketplaces) -- Marketplace manifest, distribution options (relative path, GitHub, npm, pip, URL). Verified from project-level research.

### Secondary (MEDIUM confidence)
- [GSD command compatibility issue (GitHub Issue #218)](https://github.com/glittercowboy/get-shit-done/issues/218) -- Evidence of Claude Code breaking changes affecting namespaced plugin commands
- [Claude Code plugin update bug (GitHub Issue #19197)](https://github.com/anthropics/claude-code/issues/19197) -- Plugin updates not always re-downloading files
- Director project-level research: `.planning/research/STACK.md`, `ARCHITECTURE.md`, `PITFALLS.md`, `FEATURES.md` -- Cross-referenced for consistency

### Tertiary (LOW confidence)
- [What I Learned Building a Trilogy of Claude Code Plugins (Pierce Lamb)](https://pierce-lamb.medium.com/what-i-learned-while-building-a-trilogy-of-claude-code-plugins-72121823172b) -- Practitioner experience, single source

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH -- All components verified from official Claude Code documentation
- Architecture patterns: HIGH -- Plugin structure, skill/agent/hook patterns all from official docs
- Pitfalls: HIGH -- Cross-referenced with GSD issues, official docs, and project-level research
- Code examples: HIGH -- Based on official documentation examples with Director-specific adaptation

**Research date:** 2026-02-07
**Valid until:** 2026-03-07 (30 days -- Claude Code plugin system is stable but actively evolving)
