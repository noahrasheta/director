# Changelog

All notable changes to Director are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/).

## 1.1.3 (2026-02-12)

### Fixed

- SessionEnd hook now commits STATE.md timestamp updates instead of leaving them as unsaved changes
- Build workflow commits user-confirmed drift changes to VISION.md/GAMEPLAN.md after sync
- Tier 2 auto-fixes at step/goal boundaries are now amend-committed into the task commit
- Orphaned syncer changes are reverted when builder fails to create a commit
- Added final cleanup check (Step 10g) as safety net to catch any uncommitted changes
- Quick skill now handles drift detection after syncer runs

## 1.1.2 (2026-02-12)

### Fixed

- Onboard and blueprint now auto-save progress so `/director:build` starts clean without "unsaved changes" warnings
- Blueprint writes preliminary GAMEPLAN.md as soon as goals are approved (no longer trapped in chat)
- Onboard recommends clearing context before blueprint; blueprint recommends clearing before build
- Greenfield projects no longer see alarming "No codebase context yet" message during build

## 1.1.1 (2026-02-11)

### Fixed

- Pass file paths to researcher agents instead of inline content
- Namespace agent references with `director:` plugin prefix
- Use owner/repo format for marketplace install command

## 1.1.0 (2026-02-11)

### Added

- Deep Context: codebase mapping pipeline during onboarding for brownfield projects
- Domain research pipeline with parallel researcher agents
- Enhanced vision document with research integration

## 1.0.2 (2026-02-09)

### Fixed

- Added `director:` prefix to all skill command names for marketplace compatibility

## 1.0.1 (2026-02-09)

### Fixed

- Fixed hooks.json format to match Claude Code expected schema
- Cleared install cache for fresh plugin resolution

## 1.0.0 (2026-02-09)

First release of Director -- opinionated orchestration for vibe coders.

### Added

**Core Workflow**
- Interview-based onboarding for new and existing projects (greenfield and brownfield)
- Vision document generation from guided conversation
- Gameplan creation with goals, steps, and tasks
- Fresh-context task execution with automatic progress saving
- Three-tier verification: structural checks, behavioral checklists, and auto-fix
- Progress tracking with visual status display
- Session resume with context restoration after breaks
- Cost tracking per goal, step, and task

**Flexibility**
- Quick mode for fast changes without full planning
- Idea capture and management
- Mid-project pivot with impact analysis and delta updates
- Open-ended brainstorming with full project context

**Intelligence**
- Context-aware command routing (every command redirects when invoked out of sequence)
- Inline text support for all commands (focus or accelerate any interaction)
- Plain-language error messages (what went wrong, why, what to do)
- Undo capability for reverting the last task
- 13 slash commands and 8 specialized agents

**Distribution**
- Self-hosted plugin marketplace
- One-command installation via Claude Code
