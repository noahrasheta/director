# Phase 10: Distribution - Context

**Gathered:** 2026-02-09
**Status:** Ready for planning

<domain>
## Phase Boundary

Make Director discoverable, installable, and updatable through Claude Code's plugin marketplace. Users can find Director, install it without manual file copying, and receive versioned updates. This phase does NOT add new features to Director itself — it packages and distributes what exists.

</domain>

<decisions>
## Implementation Decisions

### Hosting & discovery
- Marketplace manifest served directly from GitHub repo (raw.githubusercontent.com) — zero infrastructure
- Single-plugin marketplace (Director-only) — no multi-plugin registry needed
- Dual install paths: one-liner command in README (primary, lowest friction) + step-by-step manual instructions (for users who want to understand the process)
- Both paths end in the same result

### Installation experience
- Post-install: welcome message confirming Director is ready + prompt to run /director:onboard
- Self-check on first command run: quietly verifies all commands register and agents load
- On uninstall: offer cleanup option — user chooses whether to keep or remove .director/ project data

### Versioning & updates
- Semantic versioning (major.minor.patch) — communicates breaking vs non-breaking changes
- Update notification on command run, once per session — not every command
- After updating: brief changelog summary (3-5 bullets) + link to full GitHub release notes
- v1.0.0 as initial release version

### Marketplace manifest content
- Vibe coder focused description — lead with audience and outcomes, not technical capabilities
- Homepage: director.cc (official) + GitHub repo (source) — both referenced
- Repo README rewritten as install-focused landing page: install instructions, quick start, what Director does

### Claude's Discretion
- Version compatibility check approach (min_claude_code_version in manifest or runtime check)
- Self-check error messaging (apply Phase 9 error patterns)
- Migration strategy for major version updates (silent migration vs notify-and-migrate)
- Rich metadata fields in manifest (author, license, keywords, etc.)
- One-liner install command format

</decisions>

<specifics>
## Specific Ideas

- Update notification pattern: show once per session, dismiss until next session or next version — similar to npm/brew update notices
- README should immediately qualify the right audience: vibe coders who want professional structure without thinking like a developer
- Uninstall keeping .director/ data means reinstalling picks up where you left off — important for user trust

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 10-distribution*
*Context gathered: 2026-02-09*
