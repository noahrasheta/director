# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Director is an opinionated, spec-driven orchestration framework for vibe coders — solo builders who use AI coding agents to bring their ideas to life. It is a **Claude Code plugin** (skills + slash commands + agents + hooks) that provides structure, guardrails, and workflow intelligence on top of Claude Code, bringing professional development practices to the vibe coding workflow.

- **Website:** director.cc
- **Command prefix:** `/director`
- **License:** MIT
- **Status:** Pre-alpha — design/research phase, no source code yet
- **Platform:** Claude Code plugin (v1 is Claude Code only; portable architecture planned for future)

## Key Design Decisions

- **Target audience is vibe coders.** Director serves solo builders who use AI to build software — people who think in outcomes, not syntax. All user-facing language must be plain English. Never use jargon like "dependencies", "artifact wiring", "worktrees", or "integration testing" in user-facing output.
- **Director's own terminology hierarchy:** Project > Goals > Steps > Tasks > Actions (Actions are invisible to users). Director uses its own vocabulary designed around how vibe coders think about projects. See `docs/design/PRD.md` §5 for the full term mapping.
- **Fresh AI context per task** — each task gets a new agent window with targeted context (VISION.md + relevant STEP.md + task file + recent git history). Never accumulate full conversation history.
- **Sub-agents from day one** — Director's lead agent spawns sub-agents for codebase exploration, research, verification, and debugging. These can run in parallel within a single task. This is distinct from Agent Teams (Phase 3), which coordinate multiple specialized teams across tasks simultaneously.
- **Atomic git commits** — one commit per task, enabling independent revertability.
- **~11 slash commands total** — simplicity is a feature. Resist adding more.
- **Hybrid formatting strategy** — All user-facing artifacts are Markdown (human-readable, no config file editing). When assembling context for AI agent windows, Director wraps each Markdown section with XML boundary tags (e.g., `<vision>`, `<task>`, `<instructions>`) to improve AI parsing accuracy. Machine state uses JSON. Users never see XML.
- **Git operations are abstracted** — users see "Progress saved" not commit SHAs.
- **Three-tier verification strategy** — Tier 1: Structural verification (automated, AI reads code for stubs/placeholders/orphans — no test framework needed, runs after every task). Tier 2: Behavioral verification (plain-language checklists the user confirms — runs at step/goal boundaries). Tier 3: Automated test frameworks (opt-in, Phase 2 — if the user has or wants Vitest/Jest/pytest, Director integrates with it but never requires it).
- **MCP-compatible, not MCP-dependent** — Director runs inside Claude Code and inherits whatever MCP servers the user has configured (Supabase, Stripe, etc.). Director's agents can use these tools automatically. Director itself is not an MCP server — it's a plugin invoked via `/director:` commands. Exposing Director as an MCP server is a future consideration for multi-editor support.

## Architecture

Director is a Claude Code plugin structured around three core loops:

1. **Blueprint** — Interview user, capture vision, create gameplan (Goals > Steps > Tasks)
2. **Build** — Execute tasks with fresh agent context, sub-agents for research/verification, atomic commits, doc sync
3. **Inspect** — Goal-backward verification (did we achieve the goal, not just complete tasks?)

### Project State Storage

All state lives in `.director/` (similar to GSD's `.planning/`):

```
.director/
  VISION.md           # Source of truth — loaded into every agent context
  GAMEPLAN.md          # Goals > Steps > Tasks structure
  STATE.md             # Progress tracking (machine-readable)
  IDEAS.md             # Captured ideas not yet in gameplan
  config.json          # Settings with sensible defaults
  brainstorms/         # Saved brainstorm sessions (dated markdown files)
  goals/
    01-mvp/
      GOAL.md
      01-foundation/
        STEP.md
        RESEARCH.md
        tasks/
          01-setup-database.md
          01-setup-database.done.md
```

### Core Commands

| Command | Purpose |
|---|---|
| `/director:onboard` | Project setup (interview + vision + initial plan) |
| `/director:blueprint` | Create/update gameplan |
| `/director:build` | Execute next ready task |
| `/director:inspect` | Goal-backward verification |
| `/director:status` | Visual progress board |
| `/director:resume` | Restore context after break |
| `/director:quick "..."` | Fast task without full planning |
| `/director:pivot` | Handle mid-project requirement changes |
| `/director:brainstorm` | Think out loud with full project context |
| `/director:idea "..."` | Capture idea for later |
| `/director:help` | Show commands with examples |

### Key Patterns Adopted from Competitors

- **Fresh agent windows per task** (GSD + Autospec) — prevents quality degradation, 80%+ cost savings
- **Goal-backward verification** (GSD) — verify outcomes, not task completion
- **Delta specs** (OpenSpec) — ADDED/MODIFIED/REMOVED for changes
- **Ready-work filtering** (Beads) — only show tasks with all dependencies satisfied
- **Interview-based vision capture** (Superpowers) — one question at a time, multiple choice when possible
- **[UNCLEAR] markers** (Spec-Kit) — flag ambiguity before proceeding
- **Documentation auto-sync** — after every task, verify `.director/` docs match codebase state

## Repository Contents

Design documents live in `docs/design/`:

| File | Purpose |
|---|---|
| `docs/design/DIRECTOR.md` | Project README/manifesto |
| `docs/design/PRD.md` | Full product requirements document (the primary reference) |
| `docs/design/research-competitive-analysis.md` | Analysis of 8 competing frameworks |
| `docs/design/research-director-brainstorm.md` | Foundation brainstorm document |
| `docs/design/research-followup-questions.md` | Deep-dive Q&A on design decisions |
| `docs/design/research-opus-46-strategy.md` | Opus 4.6 capability integration plan |
| `docs/design/docs-notes.md` | Raw material for future user guide (living document) |

Reference material lives in `docs/resources/`.

## Living Documents

- **`docs/design/docs-notes.md`** is a living document for future user guide material. During brainstorming sessions, whenever a workflow explanation, command usage example, FAQ-style answer, or conceptual insight is generated that would help new users understand Director, append it to `docs/design/docs-notes.md` under the appropriate section. Don't wait for the user to ask — if the conversation produces user-guide-worthy content, capture it.

## Build Strategy

Director will be built using GSD (Get Shit Done) as the development framework, then dogfood itself once MVP is functional. Development phases:

1. **Goal 1 (MVP):** Core workflow — onboarding, vision, gameplan, execution, verification, progress, resume, errors, quick mode, pivot, brainstorm, ideas
2. **Goal 2:** Intelligence — learning tips, research summaries, two-stage review, complexity estimation, enhanced acceptance testing
3. **Goal 3:** Power features — coordinated agent teams (multi-task parallelism), effort controls, visual dashboard, multi-platform support
