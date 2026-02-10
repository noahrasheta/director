# Changelog

All notable changes to Director are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/).

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
