# Stack Research: Claude Code Plugin Development

**Domain:** Claude Code plugin (skills + agents + hooks + commands)
**Researched:** 2026-02-07
**Confidence:** HIGH

## Executive Summary

Claude Code plugins are not traditional software packages with compiled code, runtime dependencies, or build systems. They are **structured collections of Markdown files, JSON configuration files, and optional shell scripts** that Claude Code discovers and loads at session start. There is no "programming language" choice to make -- the plugin itself is declarative content that tells Claude Code what capabilities to register.

This fundamentally shapes Director's stack: the core deliverable is a directory of `.md` and `.json` files following Claude Code's plugin conventions, distributed through a self-hosted plugin marketplace. The "code" in Director is primarily prompt engineering (agent system prompts, skill instructions, hook scripts) rather than application code.

## Recommended Stack

### Core Technologies

| Technology | Version | Purpose | Why Recommended | Confidence |
|------------|---------|---------|-----------------|------------|
| Claude Code Plugin System | Current (v1.0.33+) | Plugin framework | This IS the platform. Director is a Claude Code plugin by definition. All capabilities (skills, agents, hooks, commands) are registered through the plugin manifest and directory conventions. | HIGH |
| Markdown (YAML frontmatter) | N/A | Skill and agent definitions | Claude Code's native format for defining skills (`SKILL.md`) and agents (`.md` files with YAML frontmatter). Every skill and agent is a Markdown file. Not optional. | HIGH |
| JSON | N/A | Configuration and manifests | Plugin manifest (`plugin.json`), hook definitions (`hooks.json`), MCP server config (`.mcp.json`), and project state (`.director/config.json`, `.director/STATE.md`). Native format for Claude Code configuration. | HIGH |
| Bash/Shell Scripts | N/A | Hook handlers and automation | Claude Code hooks execute shell commands. Director's hooks (pre-tool validation, post-tool doc sync, session lifecycle) must be implemented as executable shell scripts. | HIGH |
| Git | 2.x | State management and checkpointing | Claude Code's own infrastructure. Director uses git for atomic task commits, revertability, and context for fresh agent windows. Already required by Claude Code itself. | HIGH |

### Plugin Component Inventory (Director-specific)

Based on the PRD and official plugin documentation, Director will contain these components:

| Component Type | Count | Location in Plugin | Purpose |
|---------------|-------|--------------------|----|
| Skills (slash commands) | ~11 | `skills/` directory | User-facing `/director:*` commands |
| Agents (subagents) | ~8 | `agents/` directory | Specialized AI agents (interviewer, planner, builder, etc.) |
| Hook configurations | ~5-8 | `hooks/hooks.json` | Event handlers for PostToolUse, Stop, SubagentStop, etc. |
| Hook scripts | ~5-8 | `scripts/` directory | Shell scripts that hooks invoke |
| Templates | ~8-10 | `skills/*/` supporting files | Markdown templates for `.director/` artifacts |
| Reference docs | ~5 | `skills/*/` supporting files | Internal guidance loaded into agent context |

### File Structure (Director Plugin)

```
director/
  .claude-plugin/
    plugin.json                         # Plugin manifest (name, version, description)
  skills/
    onboard/
      SKILL.md                          # /director:onboard skill definition
      templates/                        # VISION.md template, config.json defaults
      reference/                        # Onboarding interview guidance
    blueprint/
      SKILL.md                          # /director:blueprint
    build/
      SKILL.md                          # /director:build
    inspect/
      SKILL.md                          # /director:inspect
    status/
      SKILL.md                          # /director:status
    resume/
      SKILL.md                          # /director:resume
    quick/
      SKILL.md                          # /director:quick
    pivot/
      SKILL.md                          # /director:pivot
    brainstorm/
      SKILL.md                          # /director:brainstorm
    idea/
      SKILL.md                          # /director:idea
    help/
      SKILL.md                          # /director:help
  agents/
    director-interviewer.md             # Conducts conversations, one Q at a time
    director-planner.md                 # Creates/updates gameplans
    director-researcher.md              # Explores implementation approaches
    director-mapper.md                  # Analyzes existing codebases
    director-builder.md                 # Executes tasks with fresh context
    director-verifier.md                # Structural verification (stub/wiring checks)
    director-debugger.md                # Investigates issues found by verifier
    director-syncer.md                  # Documentation sync after tasks
  hooks/
    hooks.json                          # Hook event configuration
  scripts/
    post-task-verify.sh                 # PostToolUse: trigger verification
    stop-check.sh                       # Stop: ensure docs are synced
    session-restore.sh                  # SessionStart: load .director/ state
  CLAUDE.md                             # Plugin-level memory/instructions
```

### Supporting Tools

| Tool | Purpose | When to Use | Confidence |
|------|---------|-------------|------------|
| `jq` | JSON parsing in hook scripts | Hook scripts receive JSON on stdin; `jq` extracts fields like `tool_input.command` or `tool_input.file_path` | HIGH |
| Python 3.x | Complex hook scripts | When shell scripts are insufficient for hook logic (e.g., parsing gameplan state, validating task dependencies). Optional -- shell scripts work for most cases. | MEDIUM |
| `gh` CLI | GitHub operations | If Director needs to interact with GitHub (issues, PRs) during build tasks. Already commonly available in developer environments. | LOW |

### Development Tools

| Tool | Purpose | Notes |
|------|---------|-------|
| `claude --plugin-dir ./director` | Local plugin testing | Load Director plugin from local directory during development. Restart Claude Code to pick up changes. |
| `claude --debug` | Debug plugin loading | Shows which plugins are loaded, hook registration, agent discovery, and errors. |
| `/plugin validate .` | Validate plugin structure | Checks plugin.json syntax, directory structure, and component registration. |
| `/agents` | Verify agent registration | Interactive UI to see all registered agents, including plugin agents. |
| `/context` | Check context loading | See if skill descriptions are loaded and whether budget limits are hit. |

## How Plugin Components Work

### Skills (Slash Commands)

Skills are the user-facing entry points. Each skill is a directory under `skills/` containing a `SKILL.md` file with YAML frontmatter and markdown instructions.

**Key configuration options for Director's skills:**

```yaml
---
name: director-build
description: Execute the next ready task in your project gameplan
disable-model-invocation: true    # User-invoked only (not auto-triggered)
context: fork                      # Run in isolated subagent context
agent: director-builder            # Use the builder agent
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, Task
---
```

**Critical design decisions:**

- `disable-model-invocation: true` -- Most Director commands should be user-invoked only. Claude should not auto-trigger `/director:build` or `/director:pivot` on its own. Exceptions: `/director:help` could allow model invocation.
- `context: fork` -- Commands like `/director:build` MUST run in a forked context to achieve "fresh agent windows per task". This is how Director implements its core architecture of isolated agent context.
- `agent: <name>` -- Links a skill to a specific agent definition, providing the system prompt and tool restrictions. This is how Director assigns specialized behavior to each command.
- `$ARGUMENTS` -- Enables inline context (e.g., `/director:idea "dark mode toggle"` passes "dark mode toggle" as the argument).
- Dynamic context injection with `!`command`` -- Skills can inject live data (e.g., `!`cat .director/STATE.md`` to load current project state into the skill prompt).

**Skill content is the prompt.** The markdown body of SKILL.md becomes the instructions that drive the agent. This is where Director's workflow logic lives -- not in code, but in carefully crafted prompts that orchestrate the agent's behavior.

**Confidence:** HIGH -- Verified from official Claude Code documentation at code.claude.com/docs/en/skills

### Agents (Subagents)

Agents are Markdown files with YAML frontmatter stored in `agents/`. Each defines a specialized AI persona with specific tools and behavior.

**Key frontmatter fields:**

```yaml
---
name: director-builder
description: Executes individual tasks with fresh context. Writes code, makes changes, produces atomic commits. Use when Director needs to implement a specific task from the gameplan.
tools: Read, Write, Edit, Bash, Grep, Glob, Task(director-verifier, director-syncer)
model: inherit
permissionMode: default
maxTurns: 50
skills:
  - api-conventions     # Preload relevant skills into agent context
memory: project          # Enable persistent memory scoped to project
---

You are Director's builder agent. Your job is to implement a single task...
[Full system prompt in markdown]
```

**Critical design decisions:**

- `tools` field with `Task(agent1, agent2)` -- This is how Director implements sub-agent spawning. The builder agent can spawn verifier and syncer agents but nothing else. This prevents uncontrolled agent proliferation.
- `model: inherit` for most agents, but `model: haiku` for lightweight agents (verifier, syncer) to control costs.
- `permissionMode` -- For automated workflows, `acceptEdits` or `bypassPermissions` may be needed. However, `bypassPermissions` skips ALL permission checks and should be used with extreme caution.
- `maxTurns` -- Caps agent execution to prevent runaway costs. Set per-agent based on task complexity.
- `skills` -- Preloads skill content into agent context at startup. Use this to inject Director's templates and reference docs into agents without requiring them to discover files.
- `memory: project` -- Enables persistent learning. The builder agent can save patterns and insights to `.claude/agent-memory/director-builder/` that persist across sessions.

**Agents cannot spawn other agents (sub-agents cannot nest).** This is a platform constraint. Director's workflows must be designed as flat chains: skill invokes agent, agent spawns sub-agents, sub-agents return results. No deeper nesting.

**Confidence:** HIGH -- Verified from official Claude Code documentation at code.claude.com/docs/en/sub-agents

### Hooks (Event Handlers)

Hooks are JSON configurations that trigger shell commands, LLM prompts, or agent verifiers at lifecycle events.

**Director's hook strategy:**

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/post-edit-check.sh",
            "statusMessage": "Checking documentation sync..."
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "agent",
            "prompt": "Check if all verification steps passed and documentation is synced. Context: $ARGUMENTS",
            "timeout": 60
          }
        ]
      }
    ],
    "SubagentStop": [
      {
        "matcher": "director-builder",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/post-task-verify.sh"
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "matcher": "startup|resume",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/session-restore.sh"
          }
        ]
      }
    ]
  }
}
```

**Three hook types available:**

1. **Command hooks** (`type: "command"`) -- Run shell scripts. Receive JSON on stdin, control behavior via exit codes (0 = allow, 2 = block) and stdout JSON. Most flexible.
2. **Prompt hooks** (`type: "prompt"`) -- Single LLM call for yes/no evaluation. Good for quick verification checks.
3. **Agent hooks** (`type: "agent"`) -- Multi-turn agent with tool access. Good for complex verification (e.g., Director's structural verification that reads code to find stubs/placeholders).

**Key environment variables in hooks:**
- `${CLAUDE_PLUGIN_ROOT}` -- Absolute path to the plugin directory. MUST be used for all script references.
- `$CLAUDE_PROJECT_DIR` -- Project root directory.
- `$CLAUDE_ENV_FILE` -- (SessionStart only) File path for persisting environment variables.

**Hook scripts receive JSON on stdin** with these common fields: `session_id`, `transcript_path`, `cwd`, `permission_mode`, `hook_event_name`, plus event-specific fields.

**Confidence:** HIGH -- Verified from official Claude Code documentation at code.claude.com/docs/en/hooks

### Plugin Manifest

The `.claude-plugin/plugin.json` file defines the plugin identity:

```json
{
  "name": "director",
  "description": "Opinionated, spec-driven orchestration framework for vibe coders. Guides the entire build process from vision to working product.",
  "version": "1.0.0",
  "author": {
    "name": "Noah Rasheta"
  },
  "homepage": "https://director.cc",
  "repository": "https://github.com/noahrasheta/director",
  "license": "MIT",
  "keywords": ["orchestration", "vibe-coding", "workflow", "planning", "ai-agents"]
}
```

**The `name` field becomes the namespace prefix.** All Director skills will be invoked as `/director:onboard`, `/director:build`, etc. The colon separator is the plugin namespace convention.

**Confidence:** HIGH -- Verified from official Claude Code documentation at code.claude.com/docs/en/plugins-reference

## Distribution Strategy

### Plugin Marketplace

Director will be distributed via a self-hosted plugin marketplace. This is a Git repository containing a `.claude-plugin/marketplace.json` file.

**Marketplace structure:**

```
director-marketplace/
  .claude-plugin/
    marketplace.json
  plugins/
    director/
      [entire director plugin directory]
```

**marketplace.json:**

```json
{
  "name": "director-marketplace",
  "owner": {
    "name": "Noah Rasheta",
    "email": "noah@director.cc"
  },
  "metadata": {
    "description": "Official Director plugin marketplace"
  },
  "plugins": [
    {
      "name": "director",
      "source": "./plugins/director",
      "description": "Opinionated, spec-driven orchestration framework for vibe coders",
      "version": "1.0.0",
      "author": {
        "name": "Noah Rasheta"
      },
      "homepage": "https://director.cc",
      "repository": "https://github.com/noahrasheta/director",
      "license": "MIT",
      "keywords": ["orchestration", "vibe-coding", "workflow"],
      "category": "productivity"
    }
  ]
}
```

**Installation flow for users:**

```bash
# Step 1: Add the marketplace (one-time)
/plugin marketplace add noahrasheta/director-marketplace

# Step 2: Install Director
/plugin install director@director-marketplace
```

**Alternative source types for marketplace entries:**

| Source Type | When to Use | Example |
|-------------|-------------|---------|
| Relative path | Plugins bundled with marketplace repo | `"source": "./plugins/director"` |
| GitHub | Plugin in separate repo | `"source": {"source": "github", "repo": "noahrasheta/director"}` |
| Git URL | Non-GitHub hosting | `"source": {"source": "url", "url": "https://gitlab.com/..."}` |
| npm | npm distribution | `"source": {"source": "npm", "package": "director-cc"}` |

**Recommended approach for Director:** Start with a GitHub source pointing to the main Director repo. This allows the plugin to live in the same repository as the development codebase during early development, then separate into its own marketplace repo later.

**For team/enterprise distribution,** projects can add Director to `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "director-marketplace": {
      "source": {
        "source": "github",
        "repo": "noahrasheta/director-marketplace"
      }
    }
  },
  "enabledPlugins": {
    "director@director-marketplace": true
  }
}
```

**Confidence:** HIGH -- Verified from official Claude Code documentation at code.claude.com/docs/en/plugin-marketplaces

### Official Plugin Directory (Future)

Anthropic maintains an official plugin directory at `github.com/anthropics/claude-plugins-official`. External plugins can be submitted via a form at `clau.de/plugin-directory-submission` and must meet quality/security standards. This is a future distribution target once Director is stable.

**Confidence:** HIGH -- Verified from the GitHub repository

## Alternatives Considered

| Recommended | Alternative | When to Use Alternative |
|-------------|-------------|-------------------------|
| Plugin system (skills + agents + hooks) | Standalone CLAUDE.md + commands in `.claude/` | Quick personal workflow customization. NOT suitable for distribution, versioning, or team sharing. Convert to plugin when ready to share. |
| Self-hosted marketplace (GitHub repo) | Official Anthropic Plugin Directory | After Director reaches stability and quality standards. Good secondary distribution channel. |
| Self-hosted marketplace (GitHub repo) | npm package distribution | If multi-platform support (Cursor, OpenCode, Gemini CLI) becomes priority in Phase 3. GSD uses npm (`get-shit-done-cc`). Adds complexity. |
| Shell scripts for hooks | Python scripts for hooks | When hook logic requires complex JSON processing, state management, or multi-step validation beyond what `jq` + bash can handle. |
| `context: fork` in skills | Running everything in main context | Only for very lightweight skills like `/director:help` or `/director:idea` that don't need isolation. Core workflow commands MUST fork. |
| Agent hooks (`type: "agent"`) for verification | Command hooks for verification | Agent hooks for Director's structural verification (Tier 1) because they need to read code, analyze files, and make judgments. Command hooks for simple checks (file exists, config valid). |

## What NOT to Use

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| MCP server for Director itself | Director is a Claude Code plugin, not an MCP server. MCP is for exposing external tools/data (databases, APIs). Director orchestrates Claude Code's own capabilities. The PRD explicitly states this. | Plugin system (skills + agents + hooks) |
| Node.js/TypeScript application code | There is no runtime to execute. Claude Code plugins are declarative Markdown/JSON that Claude Code interprets directly. Writing TypeScript code that "runs" the plugin is a category error. | Markdown skills, agent prompts, JSON config, shell scripts |
| Complex build systems (webpack, esbuild, etc.) | Nothing to compile or bundle. Plugin is a directory of text files. | Direct file editing. `cp -r` for distribution. |
| YAML configuration files for user-facing state | The PRD mandates Markdown for user-facing artifacts and JSON for machine state. YAML adds a third format with no benefit. | Markdown (`.director/VISION.md`, etc.) for human-readable state; JSON (`.director/config.json`) for machine state |
| Docker or containers | Plugin runs inside Claude Code's process. No isolated runtime needed. | Direct file execution |
| Test frameworks (Vitest, Jest, pytest) for the plugin itself | Plugin components are Markdown prompts and JSON config, not executable code. Traditional unit testing doesn't apply. Test by running the plugin. | Manual testing with `claude --plugin-dir ./director`, integration testing via Claude Code's own agent execution |
| `commands/` directory for new skills | Legacy location. Claude Code supports both `commands/` and `skills/` but recommends `skills/` for new development because it supports directories with supporting files, not just single `.md` files. | `skills/` directory with `SKILL.md` files |

## Key Patterns for Director

### Pattern 1: Fresh Agent Windows via `context: fork`

Director's core architecture requires fresh context per task. This is achieved by setting `context: fork` and specifying the agent type in skill frontmatter:

```yaml
---
name: director-build
context: fork
agent: director-builder
---
```

When invoked, Claude Code creates a new isolated context with only:
- The agent's system prompt (from the agent `.md` file)
- The skill content (SKILL.md body becomes the task prompt)
- CLAUDE.md files from the project
- Any preloaded skills specified in the agent's `skills` field

This naturally implements Director's "fresh context per task" strategy without any custom code.

### Pattern 2: Sub-Agent Spawning for Research/Verification

Director's agents need to spawn sub-agents. This is achieved through the `Task` tool and the `tools` field in agent frontmatter:

```yaml
---
name: director-builder
tools: Read, Write, Edit, Bash, Grep, Glob, Task(director-verifier, director-syncer)
---
```

The builder agent can then delegate to verifier and syncer agents. Claude Code handles the spawning, context isolation, and result collection automatically.

### Pattern 3: Dynamic Context Injection in Skills

Director needs to inject project state (VISION.md, GAMEPLAN.md, STATE.md) into agent context. Use the `!`command`` syntax in skill content:

```markdown
---
name: director-build
context: fork
agent: director-builder
---

<vision>
!`cat .director/VISION.md`
</vision>

<current_step>
!`cat "$(cat .director/STATE.md | grep 'current_step_path' | cut -d: -f2 | tr -d ' ')"`
</current_step>

<task>
!`cat "$(cat .director/STATE.md | grep 'current_task_path' | cut -d: -f2 | tr -d ' ')"`
</task>

<recent_changes>
!`git log --oneline -10`
</recent_changes>

Execute this task. Follow the verification criteria. Produce one atomic commit.
```

The shell commands execute before the prompt reaches the agent, injecting live project state wrapped in XML boundary tags (matching the PRD's hybrid formatting strategy).

### Pattern 4: State Management via Files

Director manages state through files in `.director/`, not through any database or in-memory store:

- `.director/STATE.md` -- Current position, progress tracking (machine-readable Markdown)
- `.director/config.json` -- Settings (JSON)
- `.director/VISION.md` -- Source of truth (Markdown)
- `.director/GAMEPLAN.md` -- Goals/steps/tasks structure (Markdown)

Hook scripts read and write these files. Agent prompts reference them. No database or external storage needed.

### Pattern 5: Agent Memory for Learning

Director agents can maintain persistent memory across sessions using the `memory` frontmatter field:

```yaml
---
name: director-builder
memory: project
---
```

This creates a `.claude/agent-memory/director-builder/` directory where the agent stores patterns, debugging insights, and project-specific knowledge. The first 200 lines of `MEMORY.md` in this directory are loaded into the agent's context at every session start.

This enables Director's "learning tips" feature (Phase 2) -- the builder agent can record common patterns and surface them in future sessions.

## Version Compatibility

| Component | Compatible With | Notes |
|-----------|-----------------|-------|
| Claude Code Plugin System | Claude Code v1.0.33+ | Minimum version for `/plugin` command support |
| Skills with `context: fork` | Claude Code v1.0.33+ | Required for Director's fresh-context architecture |
| Agent `memory` field | Claude Code v1.0.33+ | Required for persistent agent memory |
| Agent teams (experimental) | Claude Code with `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` | Phase 3 feature. Currently experimental, disabled by default. |
| `type: "agent"` hooks | Claude Code v1.0.33+ | Required for Director's structural verification hooks |
| LSP server support | Claude Code v1.0.33+ | Not needed for Director itself, but good to know for user projects |

## Risks and Uncertainties

| Risk | Severity | Mitigation | Confidence |
|------|----------|------------|------------|
| Plugin API changes | MEDIUM | Claude Code plugin system is relatively new (2025-2026). API could change. Pin to specific Claude Code version in docs. Follow Anthropic changelog. | MEDIUM |
| Agent teams still experimental | LOW (Phase 3 only) | Only needed for Phase 3 coordinated agent teams. Monitor `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` status. Design Phase 1-2 without agent teams. | HIGH |
| Context window limits for skill descriptions | LOW | Claude Code budgets 2% of context for skill descriptions. With ~11 skills, unlikely to hit limits. Monitor with `/context`. Set `SLASH_COMMAND_TOOL_CHAR_BUDGET` env var if needed. | HIGH |
| Sub-agents cannot nest | LOW | Platform constraint. Director's workflow chains are designed as flat: skill -> agent -> sub-agents. No deeper nesting needed based on PRD workflows. | HIGH |
| Hook script portability (macOS vs Linux vs Windows) | MEDIUM | Shell scripts may need platform-specific handling. Use `#!/usr/bin/env bash` for portability. Consider Python for complex hooks. Test on multiple platforms. | MEDIUM |

## Sources

- [Claude Code Skills Documentation](https://code.claude.com/docs/en/skills) -- Official docs, verified 2026-02-07 (HIGH confidence)
- [Claude Code Sub-agents Documentation](https://code.claude.com/docs/en/sub-agents) -- Official docs, verified 2026-02-07 (HIGH confidence)
- [Claude Code Hooks Reference](https://code.claude.com/docs/en/hooks) -- Official docs, verified 2026-02-07 (HIGH confidence)
- [Claude Code Plugins Documentation](https://code.claude.com/docs/en/plugins) -- Official docs, verified 2026-02-07 (HIGH confidence)
- [Claude Code Plugins Reference](https://code.claude.com/docs/en/plugins-reference) -- Official docs, verified 2026-02-07 (HIGH confidence)
- [Claude Code Plugin Marketplaces](https://code.claude.com/docs/en/plugin-marketplaces) -- Official docs, verified 2026-02-07 (HIGH confidence)
- [Claude Code Memory Documentation](https://code.claude.com/docs/en/memory) -- Official docs, verified 2026-02-07 (HIGH confidence)
- [Claude Code Agent Teams](https://code.claude.com/docs/en/agent-teams) -- Official docs, verified 2026-02-07 (HIGH confidence)
- [Anthropic Official Plugin Directory](https://github.com/anthropics/claude-plugins-official) -- GitHub, verified 2026-02-07 (HIGH confidence)
- [GSD (Get Shit Done)](https://github.com/glittercowboy/get-shit-done) -- Competitor reference, verified 2026-02-07 (MEDIUM confidence)

---
*Stack research for: Claude Code plugin development (Director)*
*Researched: 2026-02-07*
