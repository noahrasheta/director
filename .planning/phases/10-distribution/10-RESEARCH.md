# Phase 10: Distribution - Research

**Researched:** 2026-02-09
**Domain:** Claude Code plugin marketplace system -- distribution, installation, versioning
**Confidence:** HIGH

## Summary

Phase 10 packages Director for distribution through Claude Code's plugin marketplace system. The research reveals that Director already has most of the infrastructure in place (plugin.json, README, CHANGELOG, marketplace.json) but the existing marketplace.json uses an incorrect schema and is in the wrong location. The official marketplace schema requires `name`, `owner`, and `plugins` fields at `.claude-plugin/marketplace.json` -- not `schema_version` at the repo root. This is the single most important fix in this phase.

The Claude Code plugin system provides a complete distribution pipeline: users add a marketplace via `/plugin marketplace add owner/repo`, browse plugins in the Discover tab, and install with `/plugin install plugin-name@marketplace-name`. Updates are handled via `/plugin update` or automatic background updates. Director's case is a single-plugin marketplace where the marketplace and plugin live in the same repository -- this is a common pattern (the official Anthropic marketplace does this).

The research confirms that all DIST requirements (DIST-01, DIST-02, DIST-03) are achievable with the current Claude Code plugin system without any custom infrastructure. GitHub hosting is sufficient. The primary work is: fix the marketplace manifest, create a proper one-liner install flow, add version bump and update notification logic, and rewrite the README as an install-focused landing page.

**Primary recommendation:** Fix the marketplace.json to match the official schema at `.claude-plugin/marketplace.json`, use GitHub source type for the plugin entry, bump version to 1.0.0, and write a self-check script that verifies all components load on first run.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

#### Hosting & discovery
- Marketplace manifest served directly from GitHub repo (raw.githubusercontent.com) -- zero infrastructure
- Single-plugin marketplace (Director-only) -- no multi-plugin registry needed
- Dual install paths: one-liner command in README (primary, lowest friction) + step-by-step manual instructions (for users who want to understand the process)
- Both paths end in the same result

#### Installation experience
- Post-install: welcome message confirming Director is ready + prompt to run /director:onboard
- Self-check on first command run: quietly verifies all commands register and agents load
- On uninstall: offer cleanup option -- user chooses whether to keep or remove .director/ project data

#### Versioning & updates
- Semantic versioning (major.minor.patch) -- communicates breaking vs non-breaking changes
- Update notification on command run, once per session -- not every command
- After updating: brief changelog summary (3-5 bullets) + link to full GitHub release notes
- v1.0.0 as initial release version

#### Marketplace manifest content
- Vibe coder focused description -- lead with audience and outcomes, not technical capabilities
- Homepage: director.cc (official) + GitHub repo (source) -- both referenced
- Repo README rewritten as install-focused landing page: install instructions, quick start, what Director does

### Claude's Discretion
- Version compatibility check approach (min_claude_code_version in manifest or runtime check)
- Self-check error messaging (apply Phase 9 error patterns)
- Migration strategy for major version updates (silent migration vs notify-and-migrate)
- Rich metadata fields in manifest (author, license, keywords, etc.)
- One-liner install command format

### Deferred Ideas (OUT OF SCOPE)
None -- discussion stayed within phase scope
</user_constraints>

## Standard Stack

This phase involves no new libraries or tools. The "stack" is the Claude Code plugin marketplace system itself -- all declarative JSON, Markdown, and shell scripts.

### Core

| Component | Format | Purpose | Why Standard |
|-----------|--------|---------|--------------|
| `.claude-plugin/marketplace.json` | JSON | Marketplace catalog listing Director as an installable plugin | Official marketplace format. Must be at this path for Claude Code discovery |
| `.claude-plugin/plugin.json` | JSON | Plugin manifest defining Director's identity and version | Already exists from Phase 1. Version field is authoritative |
| `README.md` | Markdown | Install-focused landing page for GitHub | Primary discovery path. Users decide to install based on README |
| `CHANGELOG.md` | Markdown | Version history with user-readable release notes | Users see this after updates. Follows Keep a Changelog format |
| `scripts/self-check.sh` | Bash | Verifies all components load correctly on first run | Silently catches installation issues before user encounters them |

### Supporting

| Component | Format | Purpose | When to Use |
|-----------|--------|---------|-------------|
| `hooks/hooks.json` | JSON | SessionStart hook for update notification + self-check | Already exists. Extend with version check logic |
| `scripts/session-start.sh` | Bash | Extended to include version check and update notification | Already exists. Add version-checking capability |

### What NOT to Use

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| External hosting (Vercel, Netlify) | User decision: zero infrastructure, GitHub only | raw.githubusercontent.com or GitHub repo source |
| npm/pip distribution | Adds complexity for no benefit. Plugin system handles distribution | Claude Code's marketplace system |
| Custom update checker service | Over-engineered for a single-plugin marketplace | Version field in plugin.json + Claude Code's built-in update mechanism |
| Install scripts that modify user's Claude settings | Claude Code handles this via `/plugin install` | Standard marketplace installation flow |

## Architecture Patterns

### Pattern 1: Single-Plugin Self-Hosted Marketplace

**What:** Director's GitHub repo serves as both the marketplace and the plugin. The `.claude-plugin/marketplace.json` lists Director itself as the only plugin, using the GitHub source type to point back to the same repo.

**When to use:** Single-plugin distribution where the author controls the entire marketplace.

**Why GitHub source (not relative path):** Since the marketplace and plugin are the same repo, using `"source": "./"` would work when users add the marketplace via git clone. But using GitHub source type (`"source": {"source": "github", "repo": "noahrasheta/director"}`) is more reliable because: (a) it works regardless of how the marketplace is added, (b) it makes the plugin independently installable, (c) Claude Code's update mechanism knows how to fetch updates from GitHub repos.

```json
// .claude-plugin/marketplace.json
{
  "name": "director-marketplace",
  "description": "Plugin marketplace for Director -- orchestration for vibe coders",
  "owner": {
    "name": "Noah Rasheta"
  },
  "plugins": [
    {
      "name": "director",
      "description": "Opinionated orchestration for vibe coders. Guides the entire build process from idea to working product.",
      "version": "1.0.0",
      "author": {
        "name": "Noah Rasheta"
      },
      "source": {
        "source": "github",
        "repo": "noahrasheta/director"
      },
      "homepage": "https://director.cc",
      "repository": "https://github.com/noahrasheta/director",
      "license": "MIT",
      "keywords": ["orchestration", "vibe-coding", "workflow", "planning", "ai-agents"],
      "category": "productivity"
    }
  ]
}
```

**Source:** [Claude Code Plugin Marketplaces Documentation](https://code.claude.com/docs/en/plugin-marketplaces)

### Pattern 2: Dual Install Path

**What:** Two ways to install Director that produce the same result.

**Path 1 -- One-liner (primary, lowest friction):**
```
/plugin marketplace add noahrasheta/director && /plugin install director@director-marketplace
```

Or as a single command if marketplace is already added:
```
/plugin install director@director-marketplace
```

**Path 2 -- Step-by-step manual:**
1. Open Claude Code
2. Run `/plugin marketplace add noahrasheta/director`
3. Run `/plugin` and go to Discover tab
4. Find Director and install it
5. Run `/director:onboard` to get started

**Why both paths:** The user decision specifies dual install. The one-liner is for README copy-paste. The manual path is for users who want to understand the process.

**Source:** [Claude Code Discover Plugins Documentation](https://code.claude.com/docs/en/discover-plugins)

### Pattern 3: Version Bump at Release

**What:** Version must be updated in exactly one place before distribution.

Per official docs: "If also set in the marketplace entry, `plugin.json` takes priority. You only need to set it in one place."

**Recommendation:** Update version in `plugin.json` (the authoritative source). The marketplace entry can reference it or have its own copy -- but `plugin.json` wins in conflicts. For Director, update BOTH to avoid confusion during review.

**Files to update for a version bump:**
1. `.claude-plugin/plugin.json` -- `version` field (authoritative)
2. `.claude-plugin/marketplace.json` -- `version` field in plugin entry (for marketplace browsing)
3. `CHANGELOG.md` -- new version section with release notes

### Pattern 4: Update Notification via SessionStart Hook

**What:** Check the installed plugin version against the latest available version on SessionStart, once per session.

**How it works:**
1. The SessionStart hook already runs `scripts/session-start.sh`
2. Extend the script to check if a newer version is available
3. If newer version found, set an environment variable or write to a temp file
4. The first `/director:` command that runs checks this flag and shows a notification once
5. After showing, mark as "notified this session" so it does not repeat

**Implementation approach for version check:**
The session-start script can compare the installed version from `.claude-plugin/plugin.json` (local) against the latest version from the GitHub repo (fetched via `curl` to raw.githubusercontent.com). This is lightweight, non-blocking, and uses zero infrastructure.

```bash
# In scripts/session-start.sh (addition)
CURRENT_VERSION=$(python3 -c "import json; print(json.load(open('${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json')).get('version', '0.0.0'))" 2>/dev/null || echo "0.0.0")
LATEST_VERSION=$(curl -sf "https://raw.githubusercontent.com/noahrasheta/director/main/.claude-plugin/plugin.json" 2>/dev/null | python3 -c "import json,sys; print(json.load(sys.stdin).get('version', '0.0.0'))" 2>/dev/null || echo "")

# Only notify if we got a valid response and versions differ
if [ -n "$LATEST_VERSION" ] && [ "$CURRENT_VERSION" != "$LATEST_VERSION" ]; then
  # Write update notification for skills to detect
  echo "UPDATE_AVAILABLE=$LATEST_VERSION" > /tmp/director-update-$$
fi
```

**Note:** This pattern is a recommendation. The exact mechanism (temp file, environment variable, or embedded in session-start JSON output) is an implementation detail for the planner.

### Pattern 5: Self-Check on First Run

**What:** On the first command invocation after install, quietly verify all components loaded.

**What to check:**
- All 12 skill files exist and are readable
- All 8 agent files exist and are readable
- hooks.json exists and is valid JSON
- scripts are executable
- CLAUDE.md exists at plugin root

**When to run:** First command invocation of a new install (detect by checking if `.director/` does not exist yet or a first-run marker).

**Error messaging (per Phase 9 patterns -- three-part structure):**
1. What went wrong: "Director installed but some components didn't load properly."
2. Why: "The [component type] file is missing or unreadable."
3. What to do: "Try reinstalling with `/plugin uninstall director@director-marketplace` then `/plugin install director@director-marketplace`. If that doesn't help, visit [GitHub issues link]."

### Anti-Patterns to Avoid

- **Putting marketplace.json at repo root:** Must be at `.claude-plugin/marketplace.json`. The current `marketplace.json` at repo root will NOT be discovered by Claude Code's marketplace system.
- **Using `schema_version` field:** Not part of the official schema. The current marketplace.json has this and it is wrong.
- **Hard-coding absolute paths in marketplace entries:** All paths must be relative or use source type objects.
- **Building a custom update server:** Claude Code has built-in update mechanisms (`/plugin update`, auto-updates). Use them.
- **Showing update notifications on every command:** User decision says once per session, not every command.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Plugin installation | Custom install script that copies files | `/plugin marketplace add` + `/plugin install` | Claude Code handles copying, caching, enabling |
| Plugin discovery | Custom search/browse interface | `/plugin` Discover tab | Built into Claude Code |
| Plugin updates | Custom update checker daemon | `/plugin update` + auto-update feature | Built into Claude Code with background support |
| Plugin uninstall | Custom cleanup script | `/plugin uninstall` | Claude Code handles cache cleanup |
| Version comparison | Custom semver comparison logic | Compare version strings in session-start | For notification only; actual update handling is Claude Code's job |

**Key insight:** Claude Code's plugin system handles the entire distribution lifecycle. Director needs to provide the right metadata (marketplace.json, plugin.json, CHANGELOG.md) and let the platform do the rest. The only custom logic needed is the update notification (once-per-session) and the self-check (first-run verification).

## Common Pitfalls

### Pitfall 1: Wrong marketplace.json Location and Schema

**What goes wrong:** The marketplace file is at the repo root with a non-standard schema. Claude Code cannot discover it.
**Why it happens:** The Phase 1 marketplace.json was created before the official marketplace documentation was fully understood. It uses `schema_version` (not a real field) and lacks required `name` and `owner` fields.
**How to avoid:** Move marketplace.json to `.claude-plugin/marketplace.json` and use the official schema with `name`, `owner`, and `plugins` fields. Delete the old `marketplace.json` from repo root.
**Warning signs:** `/plugin marketplace add noahrasheta/director` fails or shows no plugins in Discover tab.
**Current state:** The existing `marketplace.json` at repo root MUST be replaced.

### Pitfall 2: Version Mismatch Between plugin.json and marketplace.json

**What goes wrong:** plugin.json says version 1.0.0 but marketplace.json says 0.1.0 (or vice versa). Users see inconsistent versions.
**Why it happens:** Two files both contain version fields. Easy to update one and forget the other.
**How to avoid:** Always update both files in the same commit. Document the version bump process clearly. Per official docs, plugin.json takes priority, but keeping them in sync avoids confusion.
**Warning signs:** `/plugin` shows a different version than what plugin.json contains.

### Pitfall 3: Self-Check Blocks User on Failure

**What goes wrong:** The self-check script reports errors loudly and prevents the user from using Director.
**Why it happens:** Over-engineering the self-check to be a hard gate.
**How to avoid:** Self-check should be quiet on success and conversational on failure. It reports findings but does NOT block command execution. The user can still use Director even if a component is missing (degraded experience, not broken).
**Warning signs:** Users can't run any Director command after install because the self-check failed.

### Pitfall 4: Update Notification Shown on Every Command

**What goes wrong:** Users see "Update available" on every `/director:` command, which is annoying.
**Why it happens:** The notification logic doesn't track whether it has already been shown this session.
**How to avoid:** Use a per-session flag (temp file with PID or session marker) to show the notification exactly once. The session-start script sets the flag; the first skill that reads it shows the notification and clears it.
**Warning signs:** User complains about repeated update prompts.

### Pitfall 5: Plugin Cache Stale After Update

**What goes wrong:** User runs `/plugin update` but still sees old behavior because the cached plugin files weren't refreshed.
**Why it happens:** Claude Code copies plugins to a cache directory. Updates need to invalidate the cache.
**How to avoid:** This is handled by Claude Code's `/plugin update` command. Document in README that users should restart Claude Code after updating if they see stale behavior. The official docs note: "If any plugins were updated, you'll see a notification suggesting you restart Claude Code."
**Warning signs:** Updated version number but old skill behavior persists.

### Pitfall 6: Relative Source Path Doesn't Resolve for URL-Based Marketplace Addition

**What goes wrong:** If marketplace.json uses `"source": "./"` and a user adds the marketplace via a raw URL (`https://raw.githubusercontent.com/.../marketplace.json`), the relative path doesn't resolve.
**Why it happens:** URL-based marketplace addition only downloads the marketplace.json file, not the entire repo. Relative paths reference files on the server that weren't downloaded.
**How to avoid:** Use GitHub source type (`"source": {"source": "github", "repo": "noahrasheta/director"}`) in the marketplace entry. This explicitly tells Claude Code where to fetch the plugin from, regardless of how the marketplace was added.
**Warning signs:** Plugin installation fails with "path not found" error when marketplace was added via URL.

## Code Examples

### Example 1: Correct marketplace.json (Official Schema)

```json
// Source: https://code.claude.com/docs/en/plugin-marketplaces
// Location: .claude-plugin/marketplace.json
{
  "name": "director-marketplace",
  "description": "Plugin marketplace for Director -- orchestration for vibe coders",
  "owner": {
    "name": "Noah Rasheta"
  },
  "plugins": [
    {
      "name": "director",
      "description": "Opinionated orchestration for vibe coders. Guides the entire build process from idea to working product.",
      "version": "1.0.0",
      "author": {
        "name": "Noah Rasheta"
      },
      "source": {
        "source": "github",
        "repo": "noahrasheta/director"
      },
      "homepage": "https://director.cc",
      "repository": "https://github.com/noahrasheta/director",
      "license": "MIT",
      "keywords": ["orchestration", "vibe-coding", "workflow", "planning", "ai-agents"],
      "category": "productivity"
    }
  ]
}
```

### Example 2: Updated plugin.json (v1.0.0)

```json
// Source: https://code.claude.com/docs/en/plugins-reference
// Location: .claude-plugin/plugin.json
{
  "name": "director",
  "description": "Opinionated orchestration for vibe coders. Guides the entire build process from idea to working product.",
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

### Example 3: Self-Check Script Pattern

```bash
#!/usr/bin/env bash
# scripts/self-check.sh
# Verifies all Director components are properly installed.
# Exits 0 on success, outputs issue descriptions on failure.

set -euo pipefail

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-.}"
ISSUES=()

# Check skills (12 total)
EXPECTED_SKILLS=(onboard blueprint build quick undo inspect status resume brainstorm pivot idea ideas help)
for skill in "${EXPECTED_SKILLS[@]}"; do
  if [ ! -f "$PLUGIN_ROOT/skills/$skill/SKILL.md" ]; then
    ISSUES+=("Missing skill: $skill")
  fi
done

# Check agents (8 total)
EXPECTED_AGENTS=(director-interviewer director-planner director-researcher director-mapper director-builder director-verifier director-debugger director-syncer)
for agent in "${EXPECTED_AGENTS[@]}"; do
  if [ ! -f "$PLUGIN_ROOT/agents/$agent.md" ]; then
    ISSUES+=("Missing agent: $agent")
  fi
done

# Check hooks
if [ ! -f "$PLUGIN_ROOT/hooks/hooks.json" ]; then
  ISSUES+=("Missing hooks configuration")
fi

# Check scripts are executable
for script in init-director.sh session-start.sh state-save.sh self-check.sh; do
  if [ -f "$PLUGIN_ROOT/scripts/$script" ] && [ ! -x "$PLUGIN_ROOT/scripts/$script" ]; then
    ISSUES+=("Script not executable: $script")
  fi
done

# Report results
if [ ${#ISSUES[@]} -eq 0 ]; then
  exit 0
else
  echo "DIRECTOR_SELF_CHECK_ISSUES=${#ISSUES[@]}"
  for issue in "${ISSUES[@]}"; do
    echo "  - $issue"
  done
  exit 1
fi
```

### Example 4: README as Install-Focused Landing Page (Structure)

```markdown
# Director

**Opinionated orchestration for vibe coders.**

Director is a Claude Code plugin for solo builders who want to go from
idea to working product without thinking like a developer. It handles
the structure, planning, and verification so you can focus on what to
build.

## Install

Requires Claude Code v1.0.33 or later.

### Quick Install

In Claude Code, run:
[one-liner command here]

### Step by Step

1. Open Claude Code
2. Run `/plugin marketplace add noahrasheta/director`
3. Run `/plugin install director@director-marketplace`
4. Run `/director:onboard` to get started

## What Director Does

[3-4 sentence description of the three-part loop]

## Commands

[Grouped command table -- same as current README]

## Links

- Website: director.cc
- Source: github.com/noahrasheta/director
- License: MIT
```

### Example 5: CHANGELOG v1.0.0 Format

```markdown
# Changelog

All notable changes to Director will be documented in this file.

## [1.0.0] - 2026-02-XX

### Added
- Complete Blueprint / Build / Inspect workflow
- 12 slash commands for the full project lifecycle
- 8 specialized AI agents (interviewer, planner, researcher, mapper,
  builder, verifier, debugger, syncer)
- Interview-based onboarding for new and existing projects
- Gameplan creation with Goals, Steps, and Tasks
- Fresh-context task execution with atomic progress saving
- Three-tier verification (structural, behavioral, auto-fix)
- Progress tracking with visual status display
- Session continuity with context restoration
- Quick mode for fast changes without planning
- Idea capture and management
- Brainstorming with full project context
- Pivot support for mid-project direction changes
- Undo capability for safe experimentation
- Context-aware routing across all commands
- Plain-language communication throughout
- Self-hosted plugin marketplace for installation

### Links
- GitHub: https://github.com/noahrasheta/director
- Website: https://director.cc
```

## State of the Art

| Old Approach (Phase 1) | Current Approach (Phase 10) | What Changed | Impact |
|------------------------|---------------------------|--------------|--------|
| marketplace.json at repo root with `schema_version` field | `.claude-plugin/marketplace.json` with `name`, `owner`, `plugins` | Official schema clarified since Phase 1 research | Existing marketplace.json must be replaced |
| Version 0.1.0 (pre-release) | Version 1.0.0 (initial release) | All phases complete, plugin is fully functional | Communicates readiness to users |
| README as general project description | README as install-focused landing page | Phase 10 user decision | Primary discovery surface rewired for installation |
| No update notification mechanism | SessionStart check with once-per-session notification | User decision for Phase 10 | Users know when updates are available |
| No self-check | First-run component verification | User decision for Phase 10 | Catches installation issues silently |

## Claude's Discretion Recommendations

### Version compatibility: Use min_claude_code_version in plugin.json

**Recommendation:** The existing `plugin.json` does not have a `min_claude_code_version` field, but the Phase 1 marketplace.json had one set to `1.0.33`. The official plugin.json schema does NOT include a `min_claude_code_version` field -- this field existed in the old marketplace format. Instead, add a runtime check in the session-start script that reads `claude --version` and warns if below the minimum. The self-check script can also verify this.

However, the marketplace plugin entry CAN include any field from the plugin manifest schema, and the marketplace docs show no explicit `min_claude_code_version` field. This field was used in the Phase 1 approach but is not part of the official schema.

**Recommended approach:** Document the minimum version (v1.0.33) in the README and self-check script. Do not rely on a manifest field that may not be recognized.

### Self-check error messaging: Apply Phase 9 three-part structure

**Recommendation:** When the self-check finds issues, report using the established pattern:
- What went wrong: "Director is missing some components."
- Why: "[X] skill(s) and [Y] agent(s) couldn't be found."
- What to do: "Try reinstalling -- run `/plugin uninstall director@director-marketplace` then `/plugin install director@director-marketplace`."

Keep it conversational, not alarming. The self-check should feel like a helpful assistant, not an error dialog.

### Migration strategy: Notify-and-migrate for major versions

**Recommendation:** For major version updates (2.0.0+), use a notify-and-migrate approach:
1. After update, the first command run detects a version jump (config_version in .director/config.json)
2. Show a brief message: "Director just updated to version X. Here's what changed: [3-5 bullets]. Your project files have been updated automatically."
3. Run silent migration on config.json (the `config_version` field already supports this from Phase 1)
4. If migration fails, explain what happened and suggest running `/director:help` for guidance

This is consistent with the existing `config_version` migration pattern established in Phase 1.

### Rich metadata fields: Include all available

**Recommendation:** Use all metadata fields supported by the official schema:

For marketplace.json plugin entry:
- `name`, `description`, `version`, `author` (name), `source` (github), `homepage`, `repository`, `license`, `keywords`, `category`

For plugin.json:
- `name`, `version`, `description`, `author` (name), `homepage`, `repository`, `license`, `keywords`

These are already mostly in place from Phase 1. The main additions are `category: "productivity"` in the marketplace entry.

### One-liner install command format

**Recommendation:** The simplest one-liner that works from within Claude Code:

```
/plugin marketplace add noahrasheta/director && /plugin install director@director-marketplace
```

For the README, present this as two sequential commands (easier to read and copy):

```
/plugin marketplace add noahrasheta/director
/plugin install director@director-marketplace
```

There is no single-command install that adds a marketplace AND installs a plugin atomically. These are always two steps. Present them as a quick sequence.

## Open Questions

1. **Marketplace name uniqueness**
   - What we know: The marketplace name must be kebab-case and unique. Reserved names include `claude-code-marketplace`, `anthropic-marketplace`, etc.
   - What's unclear: Whether `director-marketplace` could conflict with a future marketplace. Very unlikely given it's namespaced.
   - Recommendation: Use `director-marketplace` as the name. It's clear, descriptive, and not reserved.

2. **Auto-update default for third-party marketplaces**
   - What we know: Official Anthropic marketplaces have auto-update enabled by default. Third-party marketplaces have auto-update disabled by default.
   - What's unclear: Whether Director should encourage users to enable auto-update, or let Claude Code's default (disabled) stand.
   - Recommendation: Document in the README how to enable auto-update for Director's marketplace, but don't force it. Users can toggle via `/plugin` > Marketplaces > Enable auto-update.

3. **Uninstall cleanup for .director/ data**
   - What we know: The user decision says "offer cleanup option -- user chooses whether to keep or remove .director/ project data."
   - What's unclear: Claude Code's `/plugin uninstall` does not provide a hook to prompt the user. Uninstall removes the plugin cache, not project data.
   - Recommendation: Add a note to the README about uninstalling. Since `.director/` lives in the user's project (not the plugin cache), it survives plugin uninstall automatically. If the user wants to remove it, they can delete `.director/` manually. Add a note in `/director:help` about this. No custom uninstall hook is needed -- the user decision's intent (preserving project data by default) is satisfied by the platform's behavior.

4. **Session-start update check network latency**
   - What we know: The session-start hook has a 5-second timeout. A `curl` to raw.githubusercontent.com should complete well within that.
   - What's unclear: What happens on slow connections or when GitHub is down.
   - Recommendation: Make the version check non-blocking with a short timeout (2 seconds). If it fails, skip the notification silently. Never delay Claude Code startup for an update check.

## Sources

### Primary (HIGH confidence)
- [Claude Code Plugin Marketplaces Documentation](https://code.claude.com/docs/en/plugin-marketplaces) -- Complete marketplace schema, hosting options, distribution workflow. Fetched 2026-02-09.
- [Claude Code Plugins Reference](https://code.claude.com/docs/en/plugins-reference) -- Plugin manifest schema, CLI commands, caching behavior, version management. Fetched 2026-02-09.
- [Claude Code Discover Plugins Documentation](https://code.claude.com/docs/en/discover-plugins) -- User-side installation flow, marketplace management, auto-updates. Fetched 2026-02-09.
- [Anthropic Official Marketplace (GitHub)](https://github.com/anthropics/claude-plugins-official) -- Reference implementation of marketplace.json schema. Fetched 2026-02-09.
- [Anthropic Demo Marketplace (GitHub)](https://github.com/anthropics/claude-code/blob/main/.claude-plugin/marketplace.json) -- Reference implementation with relative source paths. Fetched 2026-02-09.

### Secondary (MEDIUM confidence)
- Existing Director codebase: plugin.json, marketplace.json, README.md, CHANGELOG.md, hooks.json, session-start.sh -- current state analysis from direct file reading
- Phase 1 Research (`.planning/phases/01-plugin-foundation/01-RESEARCH.md`) -- original plugin system research, cross-referenced with current official docs

### Tertiary (LOW confidence)
- [Community marketplace examples](https://github.com/ananddtyagi/cc-marketplace) -- community patterns for marketplace structure

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH -- All components verified from official Claude Code documentation (fetched 2026-02-09)
- Architecture patterns: HIGH -- Marketplace schema, install flow, and update mechanism all verified from official docs and Anthropic's own marketplace implementation
- Pitfalls: HIGH -- The primary pitfall (wrong marketplace schema) is confirmed by comparing the existing file against official docs
- Code examples: HIGH -- Based on official documentation with Director-specific adaptation

**Research date:** 2026-02-09
**Valid until:** 2026-03-09 (30 days -- Claude Code plugin system is stable)
