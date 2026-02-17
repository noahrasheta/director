# Stack Research

**Analysis Date:** 2026-02-16
**Confidence:** HIGH

## Recommended Stack

Director is a Claude Code plugin -- a category of software defined by its host platform. This stack research reflects what Director actually uses and what the Claude Code plugin system requires, verified against official Claude Code documentation (code.claude.com/docs).

### Core Technologies

| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| Claude Code Plugin System | v1.0.33+ | Host platform; invokes all `/director:` commands | The only supported runtime for plugins; slash commands, agents, and hooks require this exact API |
| Markdown | CommonMark | All skill workflows, agent definitions, reference docs, templates | Markdown is the plugin's native format -- Claude Code reads `.md` files as instructions; no build step, no compilation |
| Bash | v3+ (v5+ preferred) | Lifecycle scripts in `scripts/` (init, session-start, session-end, self-check) | Required for hooks that run shell commands; widely available on macOS, Linux, and WSL |
| Git | v2.0+ | Atomic commits per task; all version history | Required for every Director task completion; no alternative path exists |
| JSON | -- | Plugin manifest (`.claude-plugin/plugin.json`), hooks config (`hooks/hooks.json`), project config (`.director/config.json`) | Required format for Claude Code plugin manifests and hooks configuration |

### Supporting Libraries

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| Python 3 | v3.6+ | JSON parsing in `scripts/session-start.sh` (`python3 -c`) | Present on most developer machines; used for reliable JSON parsing with fallback to `grep` if absent |
| curl | Any | Version checking in `scripts/session-start.sh`; fetches `marketplace.json` from GitHub with 2-second timeout | Available on all target platforms; no alternative needed for this simple HTTP check |
| Google Fonts API | -- | Typeface loading (Inter, JetBrains Mono) in `site/index.html` | Used only for the marketing website; requires no API key; loaded via CSS `@import` |

### Development Tools

| Tool | Purpose | Notes |
|------|---------|-------|
| GitHub Pages | Hosts director.cc from `site/` directory | Auto-deploys on push to main; no build step required; configured via `site/CNAME` |
| `--plugin-dir` flag | Local plugin testing during development | Run `claude --plugin-dir ./` to load Director as a local plugin; no installation needed for dev |
| `claude --version` | Verify Claude Code version meets v1.0.33+ minimum | Essential before contributing -- older Claude Code versions silently fail |

## Installation

Director is installed as a Claude Code plugin, not via a package manager. No `npm install` or `pip install` applies.

```bash
# Install the plugin from the Director marketplace
# (once installed in Claude Code, no further setup required)
/plugin install https://github.com/noahrasheta/director

# Verify Claude Code meets minimum version requirement
claude --version
# Requires: 1.0.33 or later

# For local development: load Director directly without installing
claude --plugin-dir /path/to/director

# Confirm Git is available (required for all Director task operations)
git --version
# Requires: 2.0 or later

# Python is optional but improves JSON parsing reliability
python3 --version
# Requires: 3.6+ (falls back to grep-based parsing if absent)
```

## Alternatives Considered

| Recommended | Alternative | When to Use Alternative |
|-------------|-------------|-------------------------|
| Markdown + Claude Code Plugin System | Traditional web framework (Express, FastAPI, etc.) | Never for this use case -- Director runs inside Claude Code, not as a web server |
| Local `.director/` file storage | Database (Postgres, SQLite, etc.) | Only if Director ever becomes a multi-user or cloud-hosted service; current single-user model doesn't need it |
| Bash for lifecycle scripts | Node.js scripts | When the project already requires Node.js AND the team prefers it; Bash has zero additional dependencies |
| Python 3 for JSON parsing | `jq` command-line tool | If `jq` is guaranteed available; `jq` is faster and more robust, but less universally installed than Python 3 |
| GitHub Pages (static) | Vercel, Netlify, Cloudflare Pages | If the marketing site needs dynamic features, forms, or edge functions; current site is fully static |
| Git for task history | No version control | Never -- git is required for Director's atomic commit model |

## What NOT to Use

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| npm / package.json | Director has no JavaScript dependencies for the plugin itself; adding npm creates unnecessary complexity and a lockfile to maintain | Markdown + Bash only; no build step |
| Traditional test frameworks (Jest, Vitest, pytest) | Director's correctness is behavioral, not unit-testable; the three-tier verification strategy (AI structural check + user behavioral confirmation + optional test frameworks) is the intended quality mechanism | Director's own verifier agent (`agents/director-verifier.md`) + Inspect loop |
| Environment variables for plugin configuration | Director requires no environment variables; secrets handled via Claude Code's MCP infrastructure | `.director/config.json` for settings (no credentials) |
| Database or external state store | All state lives in `.director/` files; a database would add infrastructure complexity and break the "just add files" install model | Local `.director/` directory structure |
| Complex templating engines (Handlebars, Jinja2, etc.) | Templates are plain Markdown with placeholder text that agents detect via `grep`; no rendering pipeline needed | Markdown with conventional placeholder markers (e.g., `_No goals defined yet_`) |
| CI/CD pipeline for plugin distribution | GitHub Pages auto-deploys; plugin distribution is via marketplace JSON; no compiled artifact exists to pipeline | Manual push to GitHub; GitHub Pages handles the rest |

## Version Compatibility

| Package A | Compatible With | Notes |
|-----------|-----------------|-------|
| Director v1.1.4 | Claude Code v1.0.33+ | Minimum version required; no upper bound documented. Older versions fail silently with confusing errors -- version check not yet enforced at runtime (see `.director/codebase/CONCERNS.md`) |
| Bash scripts (`scripts/`) | Bash v3+ | Scripts use `#!/usr/bin/env bash`; written for compatibility. macOS ships Bash v3 by default; Linux and WSL typically have Bash v5. Bash v5+ preferred for safety but not strictly required |
| Python 3 JSON parsing | Python 3.6+ | Uses `json.load()` with `open()` -- no f-strings or match statements; v3.6 minimum is correct |
| `hooks/hooks.json` | Claude Code SessionStart / SessionEnd hooks | Hooks use `${CLAUDE_PLUGIN_ROOT}` env variable injected by Claude Code at runtime; format verified against official docs |
| YAML frontmatter in agent files | Claude Code agent specification | Supported fields: `name`, `description`, `tools`, `disallowedTools`, `model` (sonnet/opus/haiku/inherit), `permissionMode`, `maxTurns`, `skills`, `mcpServers`, `hooks`, `memory` (user/project/local). All verified against code.claude.com/docs/en/sub-agents |
| `skills/*/SKILL.md` format | Claude Code Plugin System v1.0.33+ | Skills live in `skills/[name]/SKILL.md` at plugin root. YAML frontmatter supports `description` and `disable-model-invocation`. Verified against code.claude.com/docs/en/plugins |

## Sources

- `https://code.claude.com/docs/en/plugins` -- Plugin structure, manifest format, skill format, minimum version (v1.0.33+); HIGH confidence; fetched 2026-02-16
- `https://code.claude.com/docs/en/sub-agents` -- Agent YAML frontmatter fields (name, description, tools, model, maxTurns, memory, permissionMode, hooks, skills, mcpServers), built-in agent types, permission modes; HIGH confidence; fetched 2026-02-16
- `https://code.claude.com/docs/en/overview` -- Claude Code surface overview, hooks, skills, MCP overview; HIGH confidence; fetched 2026-02-16
- `.director/codebase/STACK.md` -- Existing codebase analysis confirming language inventory, versions, and configuration files; HIGH confidence; generated from live codebase 2026-02-16
- `.claude-plugin/plugin.json` -- Confirmed plugin version (1.1.4), name, and metadata format; HIGH confidence; read directly
- `hooks/hooks.json` -- Confirmed SessionStart/SessionEnd hook format and `${CLAUDE_PLUGIN_ROOT}` variable usage; HIGH confidence; read directly
- `scripts/session-start.sh` -- Confirmed Python 3.6+ usage pattern, curl version-check logic, Bash shebang; HIGH confidence; read directly
- `agents/director-builder.md` -- Confirmed YAML frontmatter format in production use (name, description, tools, model, maxTurns, memory); HIGH confidence; read directly

## Quality Gate

Before considering this file complete, verify:
- [x] Every recommendation includes a rationale
- [x] Specific version numbers included for core technologies
- [x] Alternatives mentioned for major recommendations
- [x] "What NOT to Use" section populated with at least 2 entries
- [x] Sources include links or tool references for verification
- [x] Confidence level reflects actual source quality
