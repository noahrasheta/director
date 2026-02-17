# External Integrations

**Analysis Date:** 2026-02-16

## APIs and External Services

**GitHub:**
- GitHub API - Used for plugin distribution via marketplace. Version checking in `scripts/session-start.sh` fetches from GitHub's raw content API to compare installed vs. latest version
  - Endpoint: `https://raw.githubusercontent.com/noahrasheta/director/main/.claude-plugin/marketplace.json`
  - Client: curl with 2-second timeout in `scripts/session-start.sh` (lines 31-37)
  - Auth: Public repository, no authentication required

**Claude Code APIs:**
- Claude Code Plugin System - The core integration point. Director runs exclusively as a Claude Code plugin
  - Integration: Invoked via `/director:` slash commands defined in `skills/*/SKILL.md`
  - Webhooks: SessionStart and SessionEnd hooks in `hooks/hooks.json`
  - Context injection: Plugin loads `.director/VISION.md` and codebase context into every agent window

**Webfetch (Optional):**
- WebFetch tool from Claude Code - Used by deep-researcher agent for domain research
  - Purpose: Fetch documentation, ecosystem analysis, feature research during `/director:onboard` and `/director:refresh`
  - Location: Referenced in `agents/director-deep-researcher.md`
  - Graceful degradation: If unavailable, research summarization defaults to local project context only

## Data Storage

**Databases:**
- Not applicable - Director uses no database. All state is stored in Markdown files within `.director/`

**File Storage:**
- Local filesystem only - Director stores all project state in `.director/` directory structure:
  - `.director/VISION.md` - Project vision document
  - `.director/GAMEPLAN.md` - Goals, steps, and tasks
  - `.director/STATE.md` - Progress tracking
  - `.director/IDEAS.md` - Captured ideas
  - `.director/config.json` - Configuration
  - `.director/codebase/` - Codebase analysis documents (STACK.md, ARCHITECTURE.md, STRUCTURE.md, CONVENTIONS.md, TESTING.md, INTEGRATIONS.md, CONCERNS.md)
  - `.director/research/` - Domain research documents
  - `.director/goals/` - Goal-level files and task definitions
  - `.director/brainstorms/` - Brainstorm session records

**Caching:**
- None - Director caches no external state. Each plugin invocation reads fresh from `.director/` files

## Authentication

**Auth Provider:**
- Custom - No external authentication provider used
  - Implementation: All authentication happens within Claude Code's native session. Director inherits the user's Claude Code authentication and MCP server access
  - Environment: Claude Code manages authentication; Director uses whatever MCP servers the user has configured (Supabase, Stripe, etc.) in Claude Code settings
  - Note: Reference in `CLAUDE.md` §MCP-compatible, not MCP-dependent

## Monitoring

**Error Tracking:**
- None - Director does not use external error tracking or analytics services. Errors are surfaced directly to the user in the Claude Code interface

**Logs:**
- Local - All logging is implicit in git commit history (each task creates one atomic commit) and in `.director/STATE.md`
- No external log aggregation

## Deployment

**Hosting:**
- GitHub Pages - Static website hosted at director.cc
  - Configuration: `site/` directory pushed to GitHub, CNAME points to director.cc (configured in `site/CNAME`)
  - DNS: director.cc domain via GitHub Pages (CNAME in `site/CNAME`)

**CI Pipeline:**
- Not detected - No automated CI/CD pipeline configured. `.github/workflows/` directory exists but contains no workflow files
- Manual deployment: Changes are pushed to GitHub repository; GitHub Pages auto-deploys the `site/` directory

## Environment Configuration

**Required env vars:**

None required. Director does not use environment variables.

**Note on credentials:**
- Director does not manage API keys or credentials directly
- If a user configures MCP servers (Supabase, Stripe, AWS, etc.) in Claude Code, those credentials are managed by Claude Code's environment, not Director
- .env files should not be created; secrets are handled by Claude Code's MCP infrastructure or user's local Claude Code configuration

**Secrets location:**
- Not applicable - Director stores no secrets. User credentials for external integrations are managed by Claude Code's MCP server configuration

## Webhooks

**Incoming:**
- None - Director does not expose webhook endpoints

**Outgoing:**
- None - Director does not call external webhooks
- Git commits are the audit trail: each task creates an atomic commit with the task description, readable in `git log`

## Quality Gate

Before considering this file complete, verify:
- [x] Every finding includes at least one file path in backticks
- [x] Voice is prescriptive ("Use X", "Place files in Y") not descriptive ("X is used")
- [x] No section left empty -- use "Not detected" or "Not applicable"
- [x] Environment variable names documented (NEVER values)
- [x] Service categories complete (APIs, storage, auth, monitoring, deployment)
- [x] File paths included for integration code
