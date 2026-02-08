# Director: Competitive Analysis Summary

**Date:** February 6, 2026
**Analyzed by:** Opus 4.6 research agents (8 parallel analyses)
**Purpose:** Inform Director's PRD and architecture decisions

---

## Overview

Eight open-source projects were analyzed against GSD (the baseline favorite) and Director's vision. Each was scored for relevance to Director's specific goal: a spec-driven framework for **vibe coders** — solo builders using AI coding agents.

| Repository | Score | Core Contribution to Director |
|---|---|---|
| **GSD** | Baseline | Context engineering, goal-backward verification, phase lifecycle, 15+ specialized agents |
| **OpenSpec** | 8.5/10 | Delta specs (ADDED/MODIFIED/REMOVED), fluid workflows, 20+ agent support, schema system |
| **Beads** | 8.5/10 | Dependency graphs, ready-work filtering, workflow templates (Molecules/Formulas), hash-based IDs |
| **Vibe-Kanban** | 8.5/10 | Visual Kanban board, real-time agent monitoring, setup automation, status indicators |
| **Autospec** | 8/10 | Phase-based execution with 80%+ cost savings, YAML artifacts, validation framework |
| **Spec-Kit** | 8/10 | Template-driven quality, user story prioritization (P1/P2/P3), [NEEDS CLARIFICATION] markers |
| **Superpowers** | 8/10 | Brainstorming workflow, 2-stage review (spec then quality), bite-sized tasks, TDD for skills |
| **Claude Task Master** | 7.5/10 | Complexity analysis (1-10 scoring), subtask generation, multi-model provider abstraction |

---

## GSD (Baseline) - Deep Analysis

GSD is the most comprehensive and architecturally sophisticated of all analyzed projects. It's the primary reference for Director's design.

### What GSD Gets Right
1. **Context engineering as first-class concern** - Acknowledges Claude's quality degradation curve; designs entire system around keeping context <50%
2. **Fresh agent windows per task** - Prevents accumulated context rot via subagent isolation
3. **Goal-backward verification** - Verifies goals achieved, not just tasks completed (plan-checker and verifier both use this)
4. **Phase-level user involvement** - `/gsd:discuss-phase` captures user vision BEFORE technical planning begins
5. **Atomic git commits per task** - Git log becomes queryable history and primary context source for future sessions
6. **Wave-based parallelization** - Dependency-grouped parallel execution across plans
7. **Brownfield support** - `/gsd:map-codebase` analyzes existing projects first
8. **Multiple workflow depths** - Quick (1-3 plans), Standard (3-5), Comprehensive (5-10)

### Where GSD Fails Vibe Coders (Director's Opportunity)
1. **Confusing terminology** - "Milestone vs Phase vs Plan" not intuitive; decimal phases (2.1) feel like system artifacts
2. **Plans are XML and unreadable** - Non-coders see `<task type="auto"><files>src/middleware/auth.ts</files>` and have no idea what it means
3. **No visual dashboard** - STATE.md tracks metrics but it's text-only; no progress visualization
4. **Configuration hidden in JSON** - config.json controls critical settings but vibe coders won't find or edit it
5. **Error messages assume technical context** - Plan-checker feedback uses jargon like "artifact wiring" and "requirement coverage"
6. **Research findings not translated** - RESEARCH.md contains buzzwords like "virtualization" and "state management" with no plain-language summary
7. **No effort indication** - Bans time estimates (good for accuracy) but gives no sense of scope
8. **Resume workflow is manual** - Requires explicit `/gsd:pause-work`; if user just closes terminal, context is lost

### GSD Architecture (What Director Should Preserve)
- **4-level hierarchy**: Project -> Milestone -> Phase -> Plan (with tasks inside plans)
- **15+ specialized agents**: researchers, planners, executors, verifiers, debuggers
- **7 workflow loops**: phase lifecycle, plan-checker iteration, verification-driven fix, wave-based execution, research parallelization, session continuity, milestone boundary
- **.planning/ folder structure**: PROJECT.md, REQUIREMENTS.md, ROADMAP.md, STATE.md
- **6-layer context management**: STATE.md, @-loading, agent-history.json, continue-here.md, per-agent allocation, git history

---

## Key Patterns Extracted from All 8 Projects

### 1. Delta Specs (from OpenSpec) - CRITICAL
Instead of writing complete specifications, describe only what's changing:
- **ADDED**: New requirements
- **MODIFIED**: Changed requirements
- **REMOVED**: Deprecated requirements

This is brilliant for brownfield projects (most of what solo builders work on). Non-coders can describe modifications without understanding the full system.

### 2. Ready-Work Filtering (from Beads) - CRITICAL
`bd ready` shows ONLY tasks with all dependencies satisfied. This eliminates decision paralysis for agents and users alike. Director should implement this concept: "Here's what you can work on right now."

### 3. Phase-Based Execution with Cost Isolation (from Autospec) - CRITICAL
Each phase gets a fresh AI context window. This reduces API costs by 80%+ and prevents quality degradation. Autospec proved this model works at scale.

### 4. Visual Kanban Board (from Vibe-Kanban) - HIGH VALUE
4-column workflow (To Do -> In Progress -> In Review -> Done) with status indicators (Running/Idle/Needs Attention). This is the visual progress tracking that GSD completely lacks and that vibe coders need.

### 5. Template-Driven Quality (from Spec-Kit) - HIGH VALUE
Templates aren't just document scaffolds - they're sophisticated prompts that constrain LLM behavior toward higher quality outputs. The template IS the quality gate.

### 6. Brainstorming Workflow (from Superpowers) - HIGH VALUE
One question at a time, multiple choice when possible, present design in 200-300 word sections with validation at each step. Design saved to dated markdown file. Perfect for vibe coders who think in outcomes rather than specifications.

### 7. Complexity-Aware Subtask Generation (from Claude Task Master) - HIGH VALUE
AI scores task difficulty (1-10) and recommends appropriate subtask counts. Vibe coders need this guidance for developing intuition about scope.

### 8. Two-Stage Review (from Superpowers) - MEDIUM VALUE
First: Does it match the spec? Second: Is it well-written? Order matters - can't do quality review if spec doesn't match. Prevents wasted polish time.

### 9. Discovered-From Relationships (from Beads) - MEDIUM VALUE
Track issues found during implementation of other issues. Allows agents to surface unexpected work while context is fresh.

### 10. [NEEDS CLARIFICATION] Markers (from Spec-Kit) - MEDIUM VALUE
Force explicit uncertainty marking (max 3 per spec). Prevents wasted AI agent effort on ambiguous specifications.

### 11. Workflow Templates / Molecules (from Beads) - MEDIUM VALUE
Declarative workflow templates (TOML/JSON) with steps, variables, and composition points. Define a template once, instantiate as needed.

### 12. Multi-Model AI Provider Abstraction (from Claude Task Master) - MEDIUM VALUE
Unified interface across Claude, GPT, Gemini, etc. with automatic fallback. Director should be AI-provider agnostic from the start.

---

## What Every Project Gets Wrong for Vibe Coders

Every single analyzed project was built for traditional developers. They all:

1. **Require terminal fluency** - No web UI, no guided wizards
2. **Use developer jargon** - "dependencies", "worktrees", "integration testing", "API contracts"
3. **Expect Git knowledge** - Branch management, merge conflicts, commit messages
4. **Assume tech stack awareness** - Users must know what language/framework they're using
5. **Lack progress visualization** - Text-based status updates instead of visual dashboards
6. **Don't translate AI findings** - Research outputs are technical documents, not plain-language summaries
7. **Don't provide effort indication** - No sense of "is this a morning feature or a week-long feature?"

**This is Director's strategic gap.** No existing tool is built for the vibe coder workflow. They all serve traditional developers who use AI agents.

---

## Features Director Should Adopt (Ranked)

### Must-Have (Core Architecture)
1. Context engineering with fresh agent windows (GSD)
2. Phase-based execution with cost isolation (Autospec/GSD)
3. Goal-backward verification with structural checks (GSD) — stub detection, orphan detection, wiring verification
4. Spec-driven workflow with delta specs (OpenSpec)
5. Ready-work filtering / dependency-aware execution (Beads)
6. Atomic git commits per unit of work (GSD)
7. Session continuity across terminal closes (GSD)
8. Template-driven quality for AI outputs (Spec-Kit)

### Should-Have (Differentiation)
9. Visual Kanban progress board (Vibe-Kanban)
10. Brainstorming/Socratic dialogue for vision capture (Superpowers)
11. Complexity-aware task breakdown (Claude Task Master)
12. Two-stage review (spec compliance then quality) (Superpowers)
13. Setup/cleanup automation (Vibe-Kanban)
14. [NEEDS CLARIFICATION] uncertainty markers (Spec-Kit)
15. User-friendly error translation (Director-original)
16. Plain-language AI research summaries (Director-original)

### Nice-to-Have (Phase 2+)
17. Multi-model provider abstraction (Claude Task Master)
18. Workflow templates / molecules (Beads)
19. Coordinated agent teams for multi-task parallelism with Opus 4.6 (note: sub-agents within tasks are MVP)
20. Archive/versioning system (OpenSpec)
21. Multi-repo workspace support (Vibe-Kanban)
22. Agent-agnostic design for 20+ tools (OpenSpec)

### Skip Entirely
- Git worktree management (too technical)
- Constitutional governance system (enterprise overhead)
- Role-based handoffs (solo builders ARE all roles)
- TDD dogmatism (Director uses three-tier verification instead: structural checks, behavioral checklists, opt-in test frameworks)
- Full DAG-based parallel task execution (overkill for MVP — sub-agents within tasks are sufficient)
- Dolt/distributed databases (infrastructure complexity)
- Exposing Director as an MCP server (Director is a plugin, not a server — but it works with any MCP servers the user has configured)
- Risk assessment in plans (enterprise feature)

---

## Architecture Comparison Matrix

| Dimension | GSD | OpenSpec | Beads | Autospec | Spec-Kit | Superpowers | Task Master | Vibe-Kanban | **Director** |
|---|---|---|---|---|---|---|---|---|---|
| Target User | Solo devs | Small teams | AI agents | Pro devs | Teams | Solo devs | AI devs | Developers | **Vibe coders** |
| Interface | CLI | CLI | CLI | CLI | CLI | CLI | CLI/MCP | Desktop/Web | **CLI + Web** |
| Hierarchy | 4-level | Flat changes | Graph | 4-stage | 6-step | Skills | Tasks/subtasks | Kanban | **3-level simplified** |
| Specs | Markdown | Delta specs | Issues | YAML | Templates | Designs | PRD-parsed | Manual | **Guided delta specs** |
| Context Mgmt | 6-layer | Minimal | Compaction | Phase isolation | None | Fresh subagents | File-based | Per-task | **Fresh agents + state** |
| Verification | Goal-backward | Archive/merge | Ready work | Validation | Gates | 2-stage review | Dependency check | Code review | **Goal-backward + visual** |
| Visual Progress | None | Terminal | None | Status cmd | None | None | CLI tables | Kanban board | **Kanban + dashboard** |
| Agents | 15+ | 20+ tools | Multi-agent | 6 agents | 17 agents | 3 agents | 10+ models | 10+ agents | **Lead + sub-agents (MVP), teams (Phase 3)** |
| Maturity | Production | v0.7+ | v0.49+ | v0.10+ | v0.6+ | v4.2 | v0.43+ | Active dev | **Pre-alpha** |
