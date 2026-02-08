# Director: Comprehensive Brainstorm Document

**Date:** February 6, 2026
**Purpose:** Foundation document for Director PRD creation
**Status:** Research synthesis complete, ready for discussion

---

## 1. What Is Director?

Director is an **agentic orchestration framework** built for vibe coders — solo builders who use AI coding agents to bring their ideas to life. It is a curated, opinionated plugin that layers on top of existing AI coding agents (starting with Claude Code) to provide the structure, guardrails, and workflow intelligence that turns ad-hoc AI prompting into disciplined, spec-driven development.

**The metaphor:** You're the film director. AI is the crew. Director is the shooting script, the production schedule, and the assistant director rolled into one.

**The tagline:** *You have the vision. AI has the skills. Director is the structure between them.*

**Website:** director.cc
**Command prefix:** `/d` an alternate could be `/director`
**License:** Open Source

---

## 2. Why Does Director Exist?

### The Problem
AI coding agents are extraordinarily capable but structureless. Without a framework, vibe coders:
- Start building before defining what they're building
- Lose context and coherence across long, complex projects
- Produce inconsistent results with no enforced standards
- Have no clear milestones, so projects drift indefinitely
- Can't tell if what was built actually matches what they asked for
- Don't know what to work on next or what's blocking progress
- Waste money on API costs because agents re-process accumulated context

### Why Existing Tools Don't Solve This
Every tool in the ecosystem (GSD, Autospec, Beads, OpenSpec, Spec-Kit, Superpowers, Claude Task Master, Vibe-Kanban) was built for traditional developers. They use developer terminology, require Git fluency, assume tech stack knowledge, and provide little or no visual feedback.

Director fills the gap between "I have a vision" and "I have a working product" by bringing professional development structure to the vibe coding workflow.

### The Thesis
The most valuable skill in the AI era is not coding, but *directing*. Knowing how to think strategically about what to build, how to structure the work, and how to orchestrate AI agents to execute on that vision. Director is both the tool and the proof of that thesis.

---

## 3. Who Is Director For?

### Primary Audience
**Vibe coders** — solo builders who use AI coding agents to build real products.

These people:
- Have a vision for what they want to build and use AI to make it real
- Are comfortable in a terminal and actively learning the craft of AI-assisted development
- Have discovered AI coding agents and recognize their potential but know they could get more from them with better structure
- Want a repeatable, structured process rather than figuring it out from scratch every time
- Are building SaaS products, personal tools, portfolio pieces, or automation systems
- Value shipping over perfection

### How Vibe Coders Work
Vibe coders represent a new approach to building software. They:
- **Think in outcomes** — focus on what the product should do, not how the code should look
- **Learn by building** — pick up technical concepts through hands-on experience
- **Need clear language** — "artifact wiring verification" should be "checking everything connects properly"
- **Need visual feedback** — text-based status updates don't create the same confidence as visual progress
- **Need effort indication** — not time estimates, but a sense of scope ("small tweak" vs "major feature")

### Secondary Audiences
- Marketers building automation systems
- Students working on complex projects
- Anyone using AI agents for structured, multi-phase work

---

## 4. Core Principles

1. **Spec first, build second.** Every project begins with understanding. No code gets written until the AI understands exactly what it's building, why, and how success is measured.

2. **Structure enables speed.** A good framework eliminates the decisions that slow you down so you can focus on the decisions that matter.

3. **You direct, AI executes.** The human provides vision, priorities, and judgment. The AI provides implementation, iteration, and technical execution. Director is the protocol between them.

4. **Plain language, always.** Technical jargon is translated to human language. Error messages explain what went wrong AND what to do about it. Research findings are summarized in words anyone can understand.

5. **Solo doesn't mean sloppy.** Solo builders deserve the same rigor that engineering teams enforce through process. Director provides that rigor without the overhead.

6. **Show, don't tell.** Visual progress indicators, Kanban boards, and status dashboards replace text-only status files. You should be able to glance at your project and know exactly where things stand.

7. **Fresh context, always.** AI quality degrades as context accumulates. Director uses fresh agent windows for every major task, keeping quality consistently high while reducing costs.

8. **Open by default.** Director is open source because the best tools are built by communities, not gatekeepers.

---

## 5. Proposed Terminology (Director's Own Vocabulary)

One of the biggest problems with existing tools is terminology designed for traditional developers. Director uses its own vocabulary, designed around how vibe coders think about their projects:

| What Other Tools Call It            | What Director Calls It | Why                                     |
| ----------------------------------- | ---------------------- | --------------------------------------- |
| Milestone / Version / Release       | **Goal**               | Everyone understands "what's the goal?" |
| Phase / Epic / Module               | **Step**               | Building happens one step at a time     |
| Plan / Sprint / Iteration           | **Task**               | Something you do to make progress       |
| Task / Subtask / Story              | **Action**             | The smallest unit of work               |
| Specification / PRD / Requirements  | **Vision**             | What you want to build                  |
| Roadmap / Backlog / Workflow        | **Gameplan**           | Your plan for getting there             |
| Repository / Codebase / Project     | **Project**            | Self-explanatory                        |
| Branch / Worktree / Commit          | (Hidden)               | Git operations abstracted away          |
| Context / Token / Window            | (Hidden)               | AI resource management abstracted away  |
| Dependency / Blocker / Prerequisite | **"Needs X first"**    | Plain English dependency                |
| Deploy / Ship / Release             | **Launch**             | Everyone knows what "launch" means      |

### Proposed Hierarchy
	Project
	  -> Goals (v1, v2, v3...)
	    -> Steps (1. Foundation, 2. Core Features, 3. Polish...)
	      -> Tasks (Set up database, Build login page, Add dark mode...)
	        -> Actions (Create file, Modify component, Run tests...)

**Note:** Actions are invisible to the user. They're what the AI does to complete tasks. The user works at the Goal/Step/Task level.

---

## 6. Proposed Feature Set

### Phase 1: Foundation (MVP)

#### Vision Capture
- **Guided brainstorming** - Director asks one question at a time, multiple choice when possible, to extract what you want to build (adapted from Superpowers' brainstorming skill)
- **Vision document** - Auto-generated summary of what you're building, who it's for, and what success looks like
- **[UNCLEAR] markers** - When something is ambiguous, Director flags it for clarification before proceeding (adapted from Spec-Kit)
- **Open-ended brainstorming** - `/director:brainstorm` allows thinking out loud with full project context at any time. Routes to idea capture, task creation, pivot, or just understanding. Sessions saved to dated files for reference.

#### Gameplan Creation
- **Goal breakdown** - Director helps you decompose your vision into achievable goals
- **Step sequencing** - Within each goal, steps are ordered based on what needs to happen first
- **Task generation** - AI generates specific tasks for each step, with plain-language descriptions
- **Ready-work filtering** - "Here's what you can work on right now" (adapted from Beads)

#### Execution Engine
- **Fresh context per task** - Each task gets a fresh AI window, preventing quality degradation (from GSD + Autospec)
- **Three-tier verification** - Tier 1: Structural verification — AI reads code for stubs, placeholders, orphaned files (automated, no test framework, runs after every task). Tier 2: Behavioral verification — plain-language checklists the user confirms (runs at step/goal boundaries). Tier 3: Automated test frameworks — opt-in Phase 2 feature (Vitest/Jest/pytest integration, never required). Inspired by GSD's verifier agent.
- **Atomic commits** - Each task produces one clean git commit (from GSD)
- **Auto-resume** - If you close your terminal, Director remembers exactly where you left off

#### Progress Tracking
- **Simple status board** - Visual representation of what's done, what's in progress, what's next (inspired by Vibe-Kanban's 4-column board)
- **Step progress** - "Step 2: 3 of 7 tasks complete"
- **Goal progress** - "Goal 1: 4 of 6 steps complete"

#### Error Handling
- **Plain-language errors** - "The login page isn't connecting to the database. This is because the database setup step hasn't been completed yet. Run `/d next` to see what to do."
- **Suggested fixes** - Every error comes with a recommended action
- **Auto-diagnosis** - When verification finds issues, Director spawns debugger agents to investigate (from GSD)

### Phase 2: Intelligence

#### Smart Assistance
- **Complexity estimation** - "This is a small task" / "This is a major feature that will take multiple steps" (adapted from Claude Task Master)
- **Research summaries** - When AI researches how to build something, the findings are presented in plain language with a "what this means for your project" section
- **Delta specs** - For changes to existing projects, describe only what's changing (ADDED/MODIFIED/REMOVED) rather than re-specifying everything (from OpenSpec)

#### Quality Gates
- **Template-driven outputs** - AI generates code and specs using templates that ensure consistent quality (from Spec-Kit)
- **Two-stage review** - First: does it match what you asked for? Second: is it well-built? (from Superpowers)
- **Smart testing integration** - Auto-detects existing test setups and integrates with them. Can suggest setting up Vitest/Jest/pytest with plain-language explanation. Always optional, never scary.

#### Enhanced Workflow
- **Quick mode** - Skip the full planning cycle for small changes; just describe what you want and go (from GSD's quick mode)
- **Existing project support** - Analyze an existing codebase before making changes (from GSD's map-codebase)
- **Session handoff** - Create a summary document when pausing work, so the next session picks up seamlessly

### Phase 3: Power Features

#### Coordinated Agent Teams (Opus 4.6)

Note: Sub-agents (parallel research, exploration, verification within a single task) are part of MVP. Phase 3 adds coordinated multi-task parallelism:

- **Multi-task parallel execution** - Multiple independent tasks worked on simultaneously by coordinated teams
- **Specialized team roles** - Researcher, planner, builder, reviewer, verifier per team (from GSD's 15-agent architecture)
- **Effort controls** - Low/Medium/High/Max thinking effort per task type

#### Integrations
- **Multi-model support** - Start with Claude, add GPT/Gemini/others later (from Claude Task Master)
- **GitHub integration** - PR creation, issue tracking (from Vibe-Kanban)
- **Agent-agnostic design** - Skills work across Claude Code, Codex, Gemini CLI (from OpenSpec)

#### Visual Layer
- **Full dashboard** - Web-based project overview with Kanban board, progress charts, and milestone tracking
- **Code diff viewer** - See what AI changed with syntax highlighting (from Vibe-Kanban)
- **Live monitoring** - Watch AI work in real-time with expandable action logs

---

## 7. Director vs The Competition

### Why Director Wins

| Dimension        | Existing Tools                           | Director                                                                   |
| ---------------- | ---------------------------------------- | -------------------------------------------------------------------------- |
| **Target User**  | Developers                               | Vibe coders                                                                |
| **Language**     | Technical jargon                         | Plain English                                                              |
| **Onboarding**   | "Run `git init` and configure your YAML" | "What do you want to build?"                                               |
| **Progress**     | Text files and CLI output                | Visual Kanban board                                                        |
| **Errors**       | "Artifact wiring verification failed"    | "The login page isn't connected to the database yet"                       |
| **Planning**     | User writes specifications               | Director asks questions, builds spec from answers                          |
| **Verification** | "All tasks complete"                     | "Does this actually do what you wanted?"                                   |
| **Effort**       | No indication                            | "Small tweak" / "Major feature"                                            |
| **Research**     | Technical report                         | "Here's what we learned, in plain language"                                |
| **Resume**       | Manual pause/resume commands             | Automatic - close terminal, come back tomorrow, pick up where you left off |

### Strategic Positioning
- **GSD** = The power tool for AI-assisted developers (complex, comprehensive, technical)
- **Autospec** = The spec-to-code pipeline for professionals (Go CLI, YAML-heavy)
- **Beads** = The distributed issue tracker for AI agent teams (graph-based, multi-repo)
- **OpenSpec** = The lightweight spec layer for developers (fluid, customizable)
- **Director** = **The framework built for vibe coders** — professional development structure for the AI-first workflow (guided, visual, plain-language)

No one else occupies this position.

---

## 8. Opus 4.6 Integration Strategy

Director should leverage these Opus 4.6 capabilities:

### Sub-Agents & Agent Teams in Claude Code

**Sub-agents (MVP):**
- Director's lead agent spawns sub-agents for research, exploration, verification, and debugging from day one
- Multiple sub-agents can run in parallel within a single task (e.g., exploring architecture + tech stack + concerns simultaneously)
- This is standard Claude Code functionality — no special infrastructure needed

**Coordinated Agent Teams (Phase 3):**
- Multiple independent tasks executed simultaneously by coordinated teams
- Pattern: Researcher + Builder + Reviewer teams working on separate tasks concurrently
- User experience: "Director is working on 3 tasks at once. Here's what each is doing..."
- Implementation: Use Claude Code's agent teams feature, coordinated by Director's dependency graph

### Adaptive Thinking
- **Use for planning**: Let Opus think deeply when creating gameplans
- **Use for verification**: Extended reasoning for goal-backward verification
- **User experience**: Invisible - Director handles when to use deep thinking vs quick responses

### Effort Controls (Low/Medium/High/Max)
- **Map to task complexity**: Small actions = low effort, major tasks = high effort
- **Cost optimization**: Don't waste expensive deep thinking on simple file changes
- **User experience**: Invisible - Director auto-selects appropriate effort level

### Context Compaction (Beta)
- **Use for long sessions**: When context approaches limits, compact automatically
- **Benefit**: Longer uninterrupted work sessions before needing fresh context
- **User experience**: Invisible - Director manages context lifecycle

### 1M Token Context + 128K Output
- **Use for large codebases**: Read more of the project at once
- **Use for comprehensive planning**: Generate longer, more detailed plans
- **Benefit**: Fewer context switches, better coherence

---

## 9. Technical Architecture (High-Level)

### What Director IS
- A Claude Code plugin (skills + slash commands + hooks)
- Installed via Claude Code's plugin system
- Invoked with `/d` prefix commands
- Stores project state in `.director/` folder (like GSD's `.planning/`)

### What Director IS NOT
- A standalone application (it runs within Claude Code)
- A web app (the visual dashboard is a future phase)
- A replacement for Claude Code (it enhances it)

### Folder Structure (Proposed)
	.director/
	  PROJECT.md          # Vision document (always loaded)
	  GAMEPLAN.md         # Goals, steps, and task structure
	  STATE.md            # Current position and progress
	  config.json         # Settings (with sensible defaults)
	  goals/
	    01-mvp/
	      01-foundation/
	        CONTEXT.md    # User's input for this step
	        RESEARCH.md   # AI's findings (plain-language summary included)
	        TASKS/
	          01-TASK.md   # Task description + verification criteria
	          01-DONE.md   # What was built + commit reference
	      02-core-features/
	        ...
	    02-v2/
	      ...

### Command Structure (Proposed)
	/d new              # Start a new project (guided brainstorming)
	/d plan             # Create or update the gameplan
	/d next             # What should I work on next?
	/d go               # Execute the next task
	/d status           # Show progress (visual board)
	/d check            # Verify what was built matches the goal
	/d resume           # Pick up where you left off
	/d brainstorm       # Think out loud with full project context
	/d quick "..."      # Quick task without full planning cycle
	/d help             # Show available commands

**Note:** This is intentionally ~11 commands. GSD has 30+. Director's simplicity IS a feature.

### Key Technical Decisions
1. **Fresh agent per task** (not accumulated context) - Quality + cost optimization
2. **Hybrid formatting** - Markdown for user-facing artifacts (human-readable), XML boundary tags when assembling agent context (AI parsing accuracy), JSON for machine state. Users never see XML.
3. **Git-backed state** (atomic commits) - Every task is independently revertable
4. **Sensible defaults** (no configuration required) - Works out of the box
5. **Progressive disclosure** - Simple commands surface, power features available but not required
6. **MCP-compatible, not MCP-dependent** - Director runs inside Claude Code and inherits whatever MCP servers the user has configured (Supabase, Stripe, etc.). Director's agents use these tools automatically. Director itself is not an MCP server — exposing Director via MCP is a future consideration for multi-editor support.

---

## 10. What Success Looks Like

### For the User
- "I described what I wanted to build, and Director helped me build it, step by step"
- "I always knew where I was in the project and what was next"
- "When something went wrong, Director explained what happened and how to fix it"
- "I never felt lost or overwhelmed"
- "My project actually got finished"

### For the Ecosystem
- Director becomes the default first install for vibe coders
- Active open-source community contributing skills and templates
- "I use Director" becomes as natural as "I use VS Code"

### Metrics
- Projects completed (not just started)
- Time from vision to first working feature
- User retention (do they come back for project #2?)
- Community contributions (skills, templates, translations)

---

## 11. Open Questions and Decisions

These are documented for PRD discussion:

1. **Terminology finalization** - The Goal/Step/Task/Action hierarchy is proposed but needs validation with real vibe coders
2. **Visual dashboard timing** - Should Phase 1 include even a basic web dashboard, or is CLI-only acceptable for MVP?
3. **Agent support scope** - Start Claude Code only, or also support Codex/Gemini from day one?
4. **Template system** - Should Director include pre-built templates for common project types (web app, API, landing page)?
5. **Pricing/distribution** - Free open-source core? Premium features? How does this work as a business?
6. **Collaboration features** - Solo-first, but when/how do multi-user features arrive?
7. **Offline capability** - Should Director work without internet (using local LLMs)?
8. **Mobile/tablet** - Is there a use case for non-desktop Director usage?

---

*This document synthesizes research from 8 competitive analyses and is designed to serve as the foundation for Director's PRD.*
