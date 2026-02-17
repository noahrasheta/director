# Technology Stack

**Analysis Date:** 2026-02-16

## Languages

**Primary:**
- Markdown - Used throughout for all user-facing documentation and agent definitions in `agents/*.md`, `skills/*/SKILL.md`, `.director/`, reference materials
- Bash - Shell scripts for initialization and lifecycle hooks in `scripts/*.sh`
- JavaScript - Frontend landing page interactivity in `site/js/main.js`

**Secondary:**
- HTML - Landing page markup in `site/index.html`
- CSS - Styling for landing page in `site/css/styles.css`
- JSON - Configuration files (plugin manifests, hooks configuration, template defaults)
- Python - Lightweight scripting in session-start.sh for JSON parsing (used with `python3 -c`)

## Runtime

**Environment:**
- Bash/Shell - v3+ for script execution in `scripts/`
- Python 3 - Optional, used for JSON parsing in `scripts/session-start.sh`
- Node.js/npm - Not required for the plugin itself; the site uses vanilla JavaScript without a build process

**Package Manager:**
- Not applicable - Director is a Markdown-based Claude Code plugin with no npm/pip dependencies for the plugin itself
- Lockfile: Not present - no package manager used

## Frameworks

**Core:**
- Claude Code Plugin Framework - The plugin system that Director extends. Invoked via `/director:` commands. Entry points defined in `skills/*/SKILL.md`
- No traditional framework (Express, Django, React, etc.) - Director is architecture-independent and runs entirely through Claude Code's plugin system

**Testing:**
- Not detected - No automated test framework configured. Verification happens through the Inspect loop (behavioral verification via user-facing checklists, structural verification via AI analysis of code patterns)

**Build/Dev:**
- GitHub Pages - Used for hosting the landing page at director.cc. Static site generation from `site/` directory
- No build tool (webpack, Vite, Esbuild, etc.) - The site uses plain HTML, CSS, and JavaScript without bundling

## Key Dependencies

**Critical:**
- Claude Code v1.0.33+ - Required platform. Director is a Claude Code plugin and depends entirely on Claude Code's plugin system, workspace, and context capabilities
- Git - Used for atomic commits (one per task) and version control. All state is tracked in `.git` history

**Infrastructure:**
- Bash shell utilities - Basic shell scripting for `scripts/` directory (init-director.sh, session-start.sh, state-save.sh, self-check.sh)
- Google Fonts API - External CSS import for typefaces (Inter and JetBrains Mono) in `site/index.html`

## Configuration

**Environment:**
- .claude-plugin/plugin.json - Defines plugin metadata: name, version (1.1.4), author, homepage, repository, license, keywords in `/.claude-plugin/plugin.json`
- .claude-plugin/marketplace.json - Plugin marketplace configuration for distribution
- hooks/hooks.json - Lifecycle hooks for SessionStart and SessionEnd, configured to run scripts/session-start.sh and scripts/state-save.sh
- .director/config.json - Per-project settings (created during onboard, includes mode setting - "guided" or other)

**Build:**
- No build configuration - Director is Markdown + Bash + vanilla JS with no build step
- GitHub Pages deployment via repository structure (site/ directory)

## Platform Requirements

**Development:**
- macOS, Linux, or Windows with Bash/zsh shell - For running scripts in `scripts/` directory
- Git 2.0+ - For version control and commit operations
- Python 3.6+ - Optional, used in scripts/session-start.sh for JSON parsing (fallback to grep-based parsing if not available)

**Production:**
- Claude Code v1.0.33 or later - The plugin runs exclusively within Claude Code's environment
- WebFetch capability - Optional but recommended for domain research features (used by deep-researcher agent). Degrades gracefully if unavailable
- git binary - Required for all Director operations (commits, history, branch tracking)

## Quality Gate

Before considering this file complete, verify:
- [x] Every finding includes at least one file path in backticks
- [x] Voice is prescriptive ("Use X", "Place files in Y") not descriptive ("X is used")
- [x] No section left empty -- use "Not detected" or "Not applicable"
- [x] Specific version numbers included for all technologies
- [x] Lockfile status documented
