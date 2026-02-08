# Director: Product Requirements Document

**Version:** 1.0
**Date:** February 6, 2026
**Author:** Noah Rasheta (with AI-assisted research synthesis)
**Status:** Draft - Ready for review

---

## 1. Executive Summary

Director is an opinionated, spec-driven orchestration framework for vibe coders — solo builders who use AI coding agents to bring their ideas to life. It is a Claude Code plugin that provides the structure, guardrails, and workflow intelligence that turns ad-hoc AI prompting into disciplined, repeatable development.

**The core insight:** AI coding agents are extraordinarily capable but structureless. Vibe coders need more than powerful AI — they need a system that guides the entire build process from initial idea through finished product. Existing frameworks assume the user is a traditional developer. Director brings professional development practices to the vibe coding workflow.

**The metaphor:** You're the architect. AI is the construction crew. Director is the blueprint, the project schedule, and the site foreman rolled into one.

**The tagline:** *You have the vision. AI has the skills. Director is the structure between them.*

- **Website:** director.cc
- **Command prefix:** `/director`
- **License:** Open Source (solo-maintained, public GitHub repository)
- **Platform:** Claude Code plugin (Claude Code only for v1; portable architecture for future platform support)
- **Installation:** Claude Code Plugin Marketplace (native `/plugin` system)

---

## 2. Problem Statement

### The Gap

AI coding agents have unlocked a new way to build software — vibe coding. But "can build" and "builds well" are different things. Without a framework, vibe coders:

- Start building before defining what they're building
- Lose context and coherence as projects grow
- Produce inconsistent results with no enforced standards
- Have no milestones, so projects drift indefinitely
- Can't tell if what was built actually matches what they asked for
- Don't know what to work on next or what's blocking progress
- Waste money on API costs because agents re-process accumulated context
- Make changes that break existing features because documentation wasn't updated
- Don't think about deployment, authentication, or tech stack decisions until it's too late

### Why Existing Tools Don't Solve This

Eight competing open-source projects were analyzed (GSD, OpenSpec, Beads, Autospec, Spec-Kit, Superpowers, Claude Task Master, Vibe-Kanban). Every one of them was built for traditional developers, not vibe coders.

They all:
- Use developer jargon ("dependencies", "worktrees", "artifact wiring", "integration testing")
- Require Git fluency and tech stack awareness
- Present plans in XML, YAML, or code-heavy formats
- Provide text-only status updates with no visual progress
- Don't translate AI research findings into plain language
- Give no sense of effort or scope for tasks
- Assume the user can evaluate technical plans

**Director fills the gap** between "I have a vision" and "I have a working product" by bringing the structure of professional software development to the vibe coding workflow.

### The Thesis

The most valuable skill in the AI era is not coding, but *directing* - knowing how to think strategically about what to build, how to structure the work, and how to orchestrate AI agents to execute on that vision. Director is both the tool and the proof of that thesis.

---

## 3. Target User

### Primary Persona: The Vibe Coder

A person who:
- Has a vision for what they want to build and uses AI to make it real
- Is comfortable in a terminal and actively learning the craft of AI-assisted development
- Has discovered AI coding agents and recognizes their potential but knows they could get more from them with better structure
- Wants a repeatable, structured process rather than figuring it out from scratch every time
- Is building SaaS products, personal tools, portfolio pieces, or automation systems
- Values shipping over perfection

### How Vibe Coders Work

Vibe coders represent a new approach to building software — they think in outcomes, features, and user experiences rather than syntax and algorithms. They direct AI to implement their vision. This is a legitimate and powerful skill set, and Director is built specifically for it.

- **Thinks in outcomes** — focuses on what the product should do, not how the code should look
- **Learns by building** — picks up technical concepts through hands-on experience, not textbooks
- **Needs clear language** — "artifact wiring verification" should be "checking everything connects properly"
- **Needs visual feedback** — text-based status updates don't create the same confidence as visual progress
- **Needs effort indication** — not time estimates, but a sense of scope ("small tweak" vs "major feature")
- **Needs documentation handled automatically** — when making changes, keeping specs and architecture docs in sync isn't yet second nature
- **Benefits from guided decisions** — may not have considered authentication strategy, hosting implications, or tech stack trade-offs yet

### Real Example (Noah's Experience)

> "As my codebase got bigger, I realized I was no longer capable of adding to it without accidentally affecting other parts. That's when I realized building without a map was detrimental. I discovered spec-driven development and retroactively created documentation. When I used GSD to map my codebase, it gave me insight into how my code worked that I wasn't aware of. It made me feel confident."

> "I moved authentication from Supabase to Clerk mid-project, and forgot that some code still referenced Supabase. I wasn't using a thorough plan, and it caused issues later."

> "When GSD told me to `npm run dev` to test, I usually just skipped it and said approve because it felt too technical. I needed something that met me where I was."

---

## 4. Core Principles

1. **Spec first, build second.** Every project begins with understanding. No code gets written until the AI understands exactly what it's building, why, and how success is measured.

2. **Structure enables speed.** A good framework eliminates the decisions that slow you down so you can focus on the decisions that matter. The guided workflow takes longer at the start but prevents bugs, feature conflicts, and rework later.

3. **You direct, AI executes.** The human provides vision, priorities, and judgment. The AI provides implementation, iteration, and technical execution. Director is the protocol between them.

4. **Plain language, always.** Technical jargon is translated to human language. Error messages explain what went wrong AND what to do about it. Research findings are summarized in words anyone can understand.

5. **Solo doesn't mean sloppy.** Solo builders deserve the same rigor that engineering teams enforce through process. Director provides that rigor without the overhead.

6. **Show, don't tell.** Visual progress indicators and status boards replace text-only status files. You should be able to glance at your project and know exactly where things stand.

7. **Fresh context, always.** AI quality degrades as context accumulates. Director uses fresh agent windows for every major task, keeping quality consistently high while reducing API costs.

8. **Interview before assumptions.** Director never assumes the user has thought through everything. It asks questions to surface decisions that need to be made before building begins.

9. **Open by default.** Director is open source because the best tools are built in the open.

---

## 5. Terminology

Director uses its own vocabulary, designed around how vibe coders think about their projects. These aren't simplified versions of developer terms — they're the right words for how this workflow actually works.

### Hierarchy

```
Project
  -> Goals (v1, v2, v3...)
    -> Steps (1. Foundation, 2. Core Features, 3. Polish...)
      -> Tasks (Set up database, Build login page, Add dark mode...)
        -> Actions (invisible to user - what the AI does internally)
```

### Term Mapping

| What developers call it             | What Director calls it | Why                                          |
| ----------------------------------- | ---------------------- | -------------------------------------------- |
| Milestone / Version / Release       | **Goal**               | Everyone understands "what's the goal?"      |
| Phase / Epic / Module               | **Step**               | Building happens one step at a time          |
| Plan / Sprint / Iteration           | **Task**               | Something you do to make progress            |
| Subtask / Story / Ticket            | **Action**             | The smallest unit of work (hidden from user) |
| Specification / PRD / Requirements  | **Vision**             | What you want to build                       |
| Roadmap / Backlog / Workflow        | **Gameplan**           | Your plan for getting there                  |
| Repository / Codebase / Project     | **Project**            | Self-explanatory                             |
| Deploy / Ship / Release             | **Launch**             | Everyone knows what "launch" means           |
| Greenfield                          | **New project**        | Plain English                                |
| Brownfield                          | **Existing project**   | Plain English                                |
| Dependency / Blocker / Prerequisite | **"Needs X first"**    | Plain English                                |
| Branch / Commit / Worktree          | (Hidden)               | Git operations abstracted away               |
| Context / Token / Window            | (Hidden)               | AI resource management abstracted away       |

### Visibility Rules

- **Users work at the Goal / Step / Task level.** They see these, name these, and make decisions about these.
- **Actions are invisible.** They're what the AI does internally to complete tasks. The user doesn't need to know that "Create file src/components/Login.tsx" happened - they need to know that "Build login page" is complete.
- **Git operations are transparent but abstracted.** The user sees "Progress saved" and "You can undo this," not "Committed to branch feature/auth with SHA a3f2b1c."

---

## 6. Core Workflow: Blueprint / Build / Inspect

Director's core loop follows an architect metaphor:

1. **Blueprint** - Plan what you're building (interview, vision capture, gameplan creation)
2. **Build** - Execute the plan one task at a time (with fresh AI context per task)
3. **Inspect** - Verify that what was built matches what you wanted (goal-backward verification)

This cycle repeats at every level: for the overall project, for each goal, and for each step.

### Detailed Workflow

#### Phase A: Onboarding (First time only)

When a user runs `/director:onboard`, Director:

1. **Detects project state** - Is this a new folder or an existing codebase?
2. **For new projects:**
   3. Starts an interview to understand what the user wants to build
   4. Asks about deployment plans, target users, and key features
   5. Gauges how much the user has already thought through
   6. Surfaces decisions they may not have considered (auth, hosting, tech stack)
   7. Generates a Vision document summarizing everything
3. **For existing projects:**
   - Spawns parallel sub-agents to map the existing codebase (architecture, tech stack, file structure, concerns)
   - Presents findings in plain language with visual architecture diagrams
   - Asks the user what they want to change or add
   - Generates a Vision document that includes the current state + desired changes
4. **Initializes project structure** - Creates `.director/` folder, Git repo (if none exists), and initial configuration with sensible defaults

#### Phase B: Blueprint

When a user runs `/director:blueprint`, Director:

1. **Reads the Vision document**
2. **Breaks the vision into Goals** (major milestones like v1, v2)
3. **Breaks each Goal into Steps** (ordered by what needs to happen first)
4. **Generates Tasks for each Step** (specific, actionable items)
5. **Identifies dependencies** ("Login page needs the database set up first")
6. **Estimates complexity** for each task (small / medium / large)
7. **Presents the Gameplan** in plain language for user review
8. **Asks for confirmation** before proceeding

The user can modify the gameplan at any point through conversation.

#### Phase C: Build

When a user runs `/director:build`, Director:

1. **Identifies the next ready task** (all dependencies satisfied)
2. **Spawns a fresh AI agent** for that task (prevents context degradation)
3. **Provides the agent with targeted context** (Vision, relevant Step info, task description, recent git history)
4. **Executes the task** with atomic git commits — the lead agent may spawn sub-agents for research, exploration, or parallel subtask work as needed
5. **Runs structural verification** via a sub-agent: checks that files exist, contain real implementation (not stubs or placeholders), and are wired into the rest of the project. If issues are found, the agent flags them before moving on.
6. **Updates progress** and documentation
7. **Reports results** in plain language ("Login page is built. Here's what it does: ...")
8. **Identifies the next ready task** or reports step/goal completion

#### Phase D: Inspect

When a user runs `/director:inspect`, Director:

1. **Runs structural verification**: Sub-agent scans the codebase for stubs, placeholder code, and orphaned files (Tier 1 — automated, no test framework needed)
2. **Checks goal-backward**: "Does what we built actually achieve the goal?" (not just "did we complete all tasks?")
3. **Generates acceptance criteria** in plain language ("Try logging in with a wrong password. What happens?")
4. **Presents a checklist** the user can verify (Tier 2 — behavioral)
5. **Runs automated tests** if available and opted-in (Tier 3 — Phase 2 only)
6. **If issues found**: Spawns debugger agents to investigate and create fix plans (max 3-5 retry cycles)
7. **If all good**: Marks the step/goal as complete, celebrates progress, shows what's next

---

## 7. Command Structure

Director uses ~11 commands. This simplicity is a design choice. GSD has 30+; Director keeps things focused so vibe coders can stay in flow.

### Core Loop

| Command               | What it does                           | When to use it                             |
| --------------------- | -------------------------------------- | ------------------------------------------ |
| `/director:blueprint` | Create, view, or update your gameplan  | When you need a plan or want to change one |
| `/director:build`     | Execute the next ready task            | When you're ready to make progress         |
| `/director:inspect`   | Verify what was built matches the goal | After completing a step or goal            |

### Project Management

| Command            | What it does                            | When to use it                            |
| ------------------ | --------------------------------------- | ----------------------------------------- |
| `/director:onboard` | Project setup (interview + vision + initial plan) | Once per project, when first adopting Director |
| `/director:status` | Show visual progress board              | When you want to see where things stand   |
| `/director:resume` | Pick up where you left off              | When returning to a project after a break |

### Thinking & Flexibility

| Command                      | What it does                          | When to use it                          |
| ---------------------------- | ------------------------------------- | --------------------------------------- |
| `/director:brainstorm`       | Think out loud with full project context | When you want to explore an idea before committing to it |
| `/director:quick "..."`      | Fast task without full planning       | For small, straightforward changes      |
| `/director:pivot`            | "I changed my mind" workflow          | When requirements change mid-project    |
| `/director:idea "..."`       | Capture an idea for later             | When inspiration strikes during a build |
| `/director:help`             | Show available commands with examples | When you need guidance                  |

### Command Intelligence

**Context-aware routing — there's no wrong door.** Every command detects the current project state and redirects if invoked out of sequence. Users should never get stuck or cause damage by picking the "wrong" command. Examples:

- `/director:build` with no `.director/` folder → "Let's get your project set up first." → routes to onboard
- `/director:blueprint` with no vision document → same redirect to onboard
- `/director:onboard` on an already-onboarded project → "This project is already set up. Here's where you are:" → shows current status and suggests the appropriate next action (blueprint, build, resume, etc.)
- `/director:inspect` with nothing built yet → "There's nothing to inspect yet." → suggests running build

**Inline context — every command accepts optional text.** When a user adds text after any command, that text focuses or accelerates the command. When they invoke the command with no text, Director asks or proceeds with defaults. Inline context is never required — it's an accelerator that skips the first conversational turn. Examples:

| Command | With inline context | Without inline context |
|---|---|---|
| `/director:idea "dark mode toggle"` | Saves the idea immediately | "What's on your mind?" → captures after conversation |
| `/director:blueprint "add payment processing"` | Focuses the gameplan update on payments | Reads Vision, builds/updates the full gameplan |
| `/director:brainstorm "what about real-time collab?"` | Starts a directed brainstorm on that topic | "What do you want to think through?" → open-ended |
| `/director:quick "fix the typo on the login page"` | Analyzes and executes immediately | "What do you need done?" → then proceeds |
| `/director:pivot "dropping mobile, going web-only"` | Starts pivot with that context pre-loaded | Begins the pivot interview from scratch |
| `/director:inspect "does checkout actually work?"` | Runs focused verification on checkout | Runs full verification across the project |

**Additional command smarts:**

- `/director:quick` includes smart analysis: if the AI determines the request is too complex for quick mode, it recommends switching to the full workflow. ("This is more intricate than it seems. I'd recommend using `/director:blueprint` first to plan this out. Want me to switch to guided mode?")
- `/director:build` automatically selects the next ready task based on dependency resolution. The user doesn't choose what to work on — Director tells them what's ready.
- `/director:resume` reads project state and restores full context. Closing the terminal doesn't lose progress.

---

## 8. Feature Requirements

### 8.1 MVP (Goal 1): Core Workflow

Everything a vibe coder needs to go from idea to working software using the Blueprint / Build / Inspect loop.

#### 8.1.1 Interview-Based Onboarding (`/director:onboard`)

**What it does:** Guides the user through a structured conversation to capture their project vision, surface decisions they haven't made yet, and create the foundational documents.

**Requirements:**
- One question at a time, multiple choice when possible (inspired by Superpowers' brainstorming skill)
- Adapts questions based on answers (doesn't ask about deployment framework if user already chose one)
- Gauges how much preparation the user has done ("Do you already have a plan for how users will log in?")
- Surfaces decisions the user may not have considered:
  - Authentication approach (if applicable)
  - Deployment target (Vercel, Railway, Netlify, etc.)
  - Tech stack recommendations based on project type
  - Data storage needs
- For existing projects: maps the codebase first, presents findings in plain language with architecture diagrams, then asks what the user wants to change
- Outputs: Vision document (`.director/VISION.md`) and initial project configuration
- Uses `[UNCLEAR]` markers for anything ambiguous, flags for clarification before proceeding (inspired by Spec-Kit)

**Plain-language example:**
> "Before we start building, I want to make sure we've thought through a few things. When this is finished, how will people access it? Will it be a website, a mobile app, or something else?"

#### 8.1.2 Vision Document Generation

**What it does:** Auto-generates a comprehensive, plain-language summary of what the user is building, who it's for, and what success looks like.

**Requirements:**
- Written in clear, plain language
- Includes: project purpose, target users, key features, tech stack decisions, deployment plan, success criteria
- For existing projects: includes current state assessment + desired changes using delta format (ADDED / MODIFIED / REMOVED, inspired by OpenSpec)
- Stored at `.director/VISION.md`
- Loaded into every agent context as the source of truth
- Updated automatically when the user runs `/director:pivot`

#### 8.1.3 Gameplan Creation (`/director:blueprint`)

**What it does:** Breaks the vision into an executable plan organized as Goals \> Steps \> Tasks.

**Requirements:**
- Goals represent major deliverables (v1, v2, future features)
- Steps within each goal are ordered by dependencies ("Needs database before login page")
- Tasks within each step are specific and actionable
- Each task has:
  - Plain-language description of what will be built
  - Why it matters (connection to the goal)
  - Complexity indicator: small / medium / large
  - Verification criteria: how to confirm it worked
  - Dependencies: what needs to be done first (shown as "Needs X first")
- Ready-work filtering: `/director:build` only shows tasks where all dependencies are satisfied (inspired by Beads)
- Gameplan is presented for user review before execution begins
- Stored at `.director/GAMEPLAN.md`

#### 8.1.4 Execution Engine (`/director:build`)

**What it does:** Executes tasks with fresh AI context, atomic commits, and automatic progress tracking. Each task's lead agent can spawn sub-agents for research, exploration, and verification as needed.

**Requirements:**
- **Fresh context per task:** Each task gets a new AI agent window. The agent receives only: Vision document, relevant step context, task description, and recent git history — each wrapped with XML boundary tags for precise AI parsing (see §9.4). This prevents quality degradation and reduces API costs by 80%+ vs accumulated context (proven by Autospec research).
- **Atomic git commits:** Each task produces exactly one clean commit. This makes every task independently revertable and creates a queryable history for future AI sessions.
- **Dependency-aware execution:** Only presents tasks where all prerequisites are satisfied.
- **Progress reporting:** After each task, reports what was built in plain language.
- **Documentation sync:** After every task, an agent verifies that all relevant documentation (`.director/` files, CLAUDE.md, architecture docs) still reflects the current state of the codebase. If changes are needed, it makes them automatically. This addresses the critical problem of documentation drift — keeping docs in sync isn't yet second nature for most vibe coders, so Director handles it.
- **Checkpoint language:** Instead of "committed SHA a3f2b1c", show "Progress saved. You can type `/director:undo` to go back to before this task."

#### 8.1.5 Goal-Backward Verification (`/director:inspect`)

**What it does:** Verifies that what was built actually achieves the stated goal, not just that all tasks were marked complete. Uses a three-tier verification strategy.

**Requirements:**

**Tier 1 — Structural verification (automated, runs after every task):**
- A sub-agent reads the codebase and checks that files exist, contain real implementation, and are wired together
- Detects stubs and placeholders: TODO comments, empty returns, placeholder text, components that render nothing, API routes that return hardcoded data
- Detects orphaned code: files that exist but aren't imported or used anywhere
- No test framework needed — this is purely AI-driven code reading
- Invisible to the user unless issues are found
- If issues found: "The login page was created but it's not actually connected to anything yet. Want me to fix this?"
- Inspired by GSD's verifier agent (existence + substantiveness + wiring checks)

**Tier 2 — Behavioral verification (guided, runs at step/goal boundaries):**
- Checks the actual outcome against the original goal (inspired by GSD's goal-backward verification)
- Generates plain-language acceptance criteria: "Here are 5 things you should be able to do now. Try each one and tell me if it works."
- Checklist format — the user tries things and reports back
- This is where the user's judgment matters: does it look right, feel right, work as expected?

**Tier 3 — Automated testing (opt-in, Phase 2):**
- See §8.2.5 for details
- Only available if the user opts in during onboarding or later
- Never required, always explained in plain language

**Common requirements across all tiers:**
- If issues found: explains what went wrong in plain language, never blames the user, suggests a clear next action
- Auto-fix capability: spawns debugger agents to investigate and create fix plans
- Maximum 3-5 retry cycles before stopping and explaining what needs manual attention
- Celebrates completion when verification passes ("Step 2 is complete! You're 3 of 5 steps through your first goal.")

#### 8.1.6 Progress Tracking (`/director:status`)

**What it does:** Visual representation of project progress at every level.

**Requirements:**
- Goal progress: "Goal 1: 4 of 6 steps complete"
- Step progress: "Step 2: 3 of 7 tasks complete"
- Status indicators per task: Ready / In Progress / Complete / Needs Attention
- Shows what's ready to work on next
- Shows what's blocked and why (in plain language)
- Stored in `.director/STATE.md` (machine-readable) with human-friendly CLI display
- API cost tracking per goal / step / task

#### 8.1.7 Session Continuity (`/director:resume`)

**What it does:** Allows the user to close their terminal, come back hours or days later, and pick up exactly where they left off.

**Requirements:**
- Automatic state persistence (no explicit "pause" command needed)
- `/director:resume` reads project state, shows what was last completed, and identifies what's next
- Works by reading `.director/STATE.md` + git history to reconstruct full context
- Plain-language status on resume: "Welcome back. Last time, you finished building the login page. Next up: the user profile page. Ready to continue?"

#### 8.1.8 Error Handling

**What it does:** When something goes wrong, Director explains it clearly and suggests what to do.

**Requirements:**
- All error messages in plain language
- Every error includes: what went wrong, why it likely happened, and a recommended action
- Never uses jargon like "artifact wiring verification failed"
- Example: "The login page can't connect to the database. This is likely because the database setup task hasn't been completed yet. Run `/director:build` to set up the database first."
- Debugger agent spawning for complex issues (inspired by GSD's verification loop)
- Cap automatic retry cycles at 3-5 iterations
- If auto-fix fails: "I tried to fix this automatically but couldn't resolve it. Here's what's happening in simple terms: [explanation]. Here's what I'd suggest trying: [action]."

#### 8.1.9 Quick Mode (`/director:quick "..."`)

**What it does:** Allows small, straightforward changes without the full planning workflow.

**Requirements:**
- User describes the change in natural language
- AI analyzes complexity before executing
- If the change is simple: executes immediately with an atomic commit
- If the change is complex: recommends switching to guided mode with explanation ("This touches several parts of your project. I'd recommend using `/director:blueprint` to plan this out first, so we don't accidentally break anything. Want to switch?")
- Still follows documentation sync (updates docs if the change warrants it)
- Still uses atomic commits

#### 8.1.10 Pivot Support (`/director:pivot`)

**What it does:** Handles mid-project requirement changes gracefully.

**Requirements:**
- Starts a focused brainstorming session about what changed
- AI maps current codebase state against new direction
- Generates an updated gameplan that supersedes the old one
- Updates all relevant documentation (Vision, Gameplan, CLAUDE.md, architecture docs)
- Preserves completed work that's still relevant
- Uses delta format for changes (ADDED / MODIFIED / REMOVED)
- Plain-language summary of impact: "Here's what changes. These 3 tasks are no longer needed. These 2 new tasks are required. Everything else stays the same."

#### 8.1.11 Idea Capture (`/director:idea "..."`)

**What it does:** Captures half-formed ideas without requiring immediate action.

**Requirements:**
- Quick capture: `/director:idea "Add a dark mode toggle"` saves the idea instantly
- Ideas are stored separately from the active gameplan
- When the user wants to act on an idea, Director analyzes it:
  - Is this a quick task? ("This is a small change. Want me to do it now?")
  - Does this need planning? ("This would affect several parts of your project. Let me research what it would take.")
  - Is this too complex for now? ("Adding this would require restructuring the database. I'd recommend saving this for Goal 2.")
- Ideas can be promoted to tasks, added to the gameplan, or dismissed
- Stored in `.director/IDEAS.md`

#### 8.1.12 Brainstorming (`/director:brainstorm`)

**What it does:** Open-ended thinking with full project context. The user explores an idea, asks questions, or thinks through changes — with the AI fully aware of the project's vision, current state, and codebase.

**How it's different from other commands:**
- `/director:onboard` = structured onboarding interview (once per project)
- `/director:idea "..."` = quick capture, no conversation
- `/director:pivot` = specifically about changing requirements
- `/director:brainstorm` = open-ended exploration that could lead anywhere

**Requirements:**
- Loads full project context before the conversation starts: VISION.md, GAMEPLAN.md, STATE.md, and codebase awareness (via a sub-agent mapping the relevant parts of the project)
- Conversation style: one question at a time, multiple choice when possible, but flexible — follows the user's lead rather than a rigid structure (inspired by Superpowers' brainstorming skill)
- Explores ideas in 200-300 word sections with validation at each step ("Does this match what you're thinking?")
- When exploring potential changes, the AI considers impact on the existing codebase and gameplan: "Adding payments would touch your database, your user profile page, and you'd need a new step for Stripe setup."
- At the end, Director suggests the appropriate next action:
  - **Save as idea**: "This is interesting but not urgent. Want me to save it to your ideas list?" → appends to IDEAS.md
  - **Create a task or step**: "This is ready to build. Want me to add it to your gameplan?" → updates GAMEPLAN.md
  - **Trigger a pivot**: "This changes the direction of your project. Want to run a full pivot?" → routes to `/director:pivot`
  - **Just understanding**: "Got it — no changes needed. This conversation is saved if you want to come back to it."
- Saves every brainstorm session to `.director/brainstorms/YYYY-MM-DD-<topic>.md` for reference
- Can be invoked at any point during a project — not tied to any specific phase

### 8.2 Phase 2: Intelligence

Features that make Director smarter and more helpful, built after the core workflow is proven.

#### 8.2.1 Learning Tips (Toggleable)

- Short, contextual explanations of why Director makes certain decisions
- Example: "I'm building the database before the login page because the login page needs somewhere to store user data."
- On by default for new users
- Toggled off in settings for experienced users
- Never long-winded; one sentence max per tip

#### 8.2.2 Research Summaries

- When AI researches how to build something, findings are presented with a "What this means for your project" section in plain language
- Technical details available but collapsed/secondary
- Stored in step-level context files

#### 8.2.3 Two-Stage Review

- Stage 1: Does it match what you asked for? (spec compliance)
- Stage 2: Is it well-built? (code quality)
- Order matters - no point polishing code that doesn't meet the spec (inspired by Superpowers)

#### 8.2.4 Complexity-Aware Task Breakdown

- AI scores task difficulty and recommends appropriate breakdown
- Users see: "This is a small change" / "This is a medium feature" / "This is a major addition that needs several steps"
- Helps vibe coders develop intuition about scope (inspired by Claude Task Master)

#### 8.2.5 Smart Testing Integration

Phase 2 adds optional automated testing on top of the MVP's structural and behavioral verification:

- **Auto-detection:** If Director detects an existing test setup in the project (Vitest config, Jest config, pytest, etc.), it integrates with it — running relevant tests after tasks and reporting results in plain language
- **Opt-in setup:** If no test setup exists, Director can suggest one: "Adding a testing tool means Director can automatically verify your code works, not just that it exists. Want me to set up Vitest? It takes about 30 seconds."
- **Plain-language results:** Test output is translated — "2 of your login tests passed, but the one that checks wrong passwords found an issue: it's letting people in instead of showing an error."
- **Never required:** Testing tools are always optional. Structural verification (Tier 1) and behavioral checklists (Tier 2) work without any test framework.
- **Never scary:** No jargon like "assertion failed" or "expected 200 got 500" — everything is translated

### 8.3 Phase 3: Power Features

Features that leverage advanced capabilities and expand Director's reach.

#### 8.3.1 Coordinated Agent Teams (Opus 4.6)

Note: Director uses sub-agents from day one (MVP) — the lead agent spawns sub-agents for research, codebase exploration, verification, and debugging, and these can run in parallel within a single task. What's new in Phase 3 is **coordinated teams working across multiple tasks simultaneously**:

- Multiple independent tasks executed in parallel by separate agent teams
- Each team has specialized roles: researcher, builder, reviewer, verifier
- Visual indicator: "Director is working on 3 tasks at once"
- Coordinated by Director's dependency graph (only independent tasks run in parallel)
- Cost-optimized model selection per agent role (Opus for planning, Sonnet for execution, Haiku for routine checks)

#### 8.3.2 Effort Controls

- Map thinking effort to task complexity: Actions = low, Tasks = medium, Steps = high, Gameplan = max
- Automatically selected by Director (invisible to user)
- Expected 60-80% cost reduction on routine operations vs using max effort everywhere

#### 8.3.3 Visual Dashboard

- Web-based project overview with Kanban board (inspired by Vibe-Kanban)
- 4-column workflow: Ready / In Progress / Reviewing / Done
- Progress charts per goal and step
- Architecture diagrams (Mermaid-based)
- Expandable action logs for transparency

#### 8.3.4 Multi-Platform Support

- Architect the skills layer to be portable from the start (inspired by OpenSpec)
- Phase 3 implementation: support for Cursor, OpenCode, Codex, Gemini CLI
- Core logic separated from Claude Code-specific integration

---

## 9. Technical Architecture

### 9.1 What Director Is

- A Claude Code plugin (skills + slash commands + agents + hooks)
- Installed via Claude Code Plugin Marketplace (`/plugin install director`)
- Invoked with `/director` prefix commands
- Stores project state in `.director/` folder

### 9.2 What Director Is Not

- A standalone application (it runs within Claude Code)
- A web app (the visual dashboard is Phase 3)
- A replacement for Claude Code (it enhances it)
- A fork of GSD or any other project (built independently, inspired by the best patterns across the ecosystem)

### 9.3 Folder Structure

```
.director/
  VISION.md           # What you're building (always loaded into agent context)
  GAMEPLAN.md          # Goals, steps, and tasks structure
  STATE.md             # Current position, progress, and metrics
  IDEAS.md             # Captured ideas not yet in the gameplan
  config.json          # Settings (with sensible defaults)
  brainstorms/         # Saved brainstorm sessions
    2026-02-07-dark-mode.md
    2026-02-10-payment-integration.md
  goals/
    01-mvp/
      GOAL.md          # Goal description and success criteria
      01-foundation/
        STEP.md        # Step context and status
        RESEARCH.md    # AI findings (with plain-language summary)
        tasks/
          01-setup-database.md      # Task description + verification criteria
          01-setup-database.done.md # What was built + commit reference
      02-core-features/
        STEP.md
        tasks/
          ...
    02-v2/
      GOAL.md
      ...
```

### 9.4 Context Management Strategy

Director's context management is designed to keep AI quality high and costs low.

1. **Fresh agent windows per task** (primary strategy): Each task gets a new AI agent with only the context it needs. This prevents the quality degradation that happens when conversations get long.

2. **Targeted context loading**: Each agent receives:
   - `VISION.md` (always — the source of truth)
   - The relevant `STEP.md` (current step context)
   - The specific task file
   - Recent git history (what was built recently)
   - NOT the entire codebase or full conversation history

3. **Hybrid formatting — XML boundaries around Markdown content**: When assembling the context payload for a fresh agent window, Director wraps each section with XML boundary tags. This follows Anthropic's recommended best practice for preventing AI models from confusing one section with another (e.g., mixing up instructions with data). The artifacts themselves remain Markdown; the XML tags are only added at the agent context assembly layer.

   Example of assembled agent context:
   ```
   <vision>
   [Contents of VISION.md]
   </vision>

   <current_step>
   [Contents of the relevant STEP.md]
   </current_step>

   <task>
   [Task description, acceptance criteria, relevant files]
   </task>

   <recent_changes>
   [Recent git history summary]
   </recent_changes>

   <instructions>
   Complete only this task. Do not modify files outside the listed scope.
   Verify your work matches the acceptance criteria before committing.
   </instructions>
   ```

4. **Three-layer formatting model**:

   | Layer | Format | Who sees it |
   |---|---|---|
   | User-facing artifacts | Markdown | Vibe coders (`.director/` files they can read) |
   | Agent context assembly | XML boundaries wrapping Markdown content | AI agents only (assembled at runtime) |
   | Machine state | JSON | Neither (internal config, progress tracking) |

5. **Git history as context source**: Atomic commits with descriptive messages become a queryable history. Fresh agents can understand what was built by reading git log.

6. **State persistence via files**: `.director/STATE.md` tracks everything needed to resume work. No conversation history dependency.

7. **Context compaction as safety net**: For long planning sessions, Opus 4.6's context compaction prevents quality loss. But Director's architecture doesn't depend on it.

### 9.5 Sub-Agents vs. Agent Teams

Director uses two levels of parallelism, introduced at different stages:

**Sub-agents (MVP — available from day one):**
- Director's lead agent spawns sub-agents for specific work within a single task or workflow step
- Used for: codebase exploration, research, verification, debugging, documentation sync
- Multiple sub-agents can run in parallel (e.g., exploring architecture, tech stack, and concerns simultaneously during onboarding)
- This is standard Claude Code functionality — no special infrastructure needed
- Examples in Director's workflow:
  - `/director:onboard` on an existing project: parallel sub-agents map architecture, tech stack, file structure, and concerns
  - `/director:build`: a sub-agent verifies the task completed successfully; another syncs documentation
  - `/director:inspect`: sub-agents investigate issues and create fix plans
  - `/director:blueprint`: a sub-agent researches how to implement a step before planning it

**Coordinated Agent Teams (Phase 3 — future):**
- Multiple independent *tasks* executed simultaneously by separate agent teams
- Each team has specialized roles (researcher, builder, reviewer, verifier)
- Requires Director's dependency graph to identify which tasks can safely run in parallel
- This is the Opus 4.6 agent teams capability — coordinated multi-task parallelism
- Example: Task "Build login page" and Task "Set up email templates" run simultaneously because they're independent

### 9.6 Git Integration

**Git is required.** Director initializes a Git repo if one doesn't exist.

Git provides:
- **Checkpoints**: Every task = one atomic commit. Presented as "Progress saved."
- **Revertability**: `/director:undo` reverts the last task's commit. Presented as "Going back to before that task."
- **Context for fresh agents**: Git log is how new agents understand what was already built.
- **Documentation sync verification**: Diffing against last commit reveals what changed.

Git is transparent to the user:
- No branch management commands
- No merge conflict resolution
- No commit message writing
- All Git operations happen behind the scenes with plain-language status updates

### 9.7 Configuration

Configuration lives in `.director/config.json` with sensible defaults. The user should never need to edit this file manually. Settings are adjustable through conversation or the `/director:help` command.

**Default settings:**
```json
{
  "mode": "guided",
  "tips": true,
  "max_retry_cycles": 3,
  "language": "en",
  "cost_tracking": true
}
```

- `mode`: "guided" (full workflow) or "quick" (describe and go). Default: guided.
- `tips`: Show learning tips during workflow. Default: true.
- `max_retry_cycles`: Maximum auto-fix attempts before stopping. Default: 3. Range: 3-5.
- `language`: UI language. Default: "en". (English only for v1.)
- `cost_tracking`: Track and display API costs. Default: true.

### 9.8 MCP Compatibility

Director is a Claude Code plugin, not an MCP server. But it fully supports MCP in an important way:

**Director inherits user-configured MCP servers automatically.** Because Director runs inside Claude Code, any MCP servers the user has configured (Supabase, Stripe, GitHub, etc.) are available to Director's agents. When a build agent needs to query a database schema, check payment configuration, or look up external documentation, it can use whatever MCP tools are already in the user's environment. Director doesn't need to know about these in advance — they're part of the Claude Code runtime.

**What this means in practice:**
- A vibe coder with Supabase MCP configured can say "set up my database" and Director's build agent can inspect their existing Supabase project, check tables, and generate matching code
- A vibe coder with Stripe MCP can say "add payments" and the agent can look up their Stripe configuration
- Director doesn't manage, configure, or install MCP servers — that's the user's Claude Code setup

**What Director is NOT:**
- Director is not an MCP server itself. You interact with Director via `/director:` slash commands within Claude Code, not via MCP protocol.
- Exposing Director as an MCP server (so tools like Cursor or VS Code could call Director commands) is a future consideration tied to multi-platform support (Phase 3).

### 9.9 Agent Architecture

Director is a Claude Code plugin. When installed, it registers **agents**, **skills (slash commands)**, and **workflows** with Claude Code. Here's how these components work together.

#### Plugin Components

| Component | What it is | Count (MVP) |
|---|---|---|
| **Skills (slash commands)** | User-facing commands invoked via `/director:` | ~11 |
| **Agents** | Specialized AI agents spawned by Director for specific roles | ~8 |
| **Workflows** | Orchestration flows that chain agents together for each command | ~7 |
| **Templates** | File templates for `.director/` artifacts (VISION.md, STEP.md, etc.) | ~8-10 |
| **Reference docs** | Internal guidance loaded into agent context (verification patterns, terminology, etc.) | ~5 |

#### Agent Roster (MVP)

These agents show up as `director-*` entries in Claude Code's agents list. Each is a specialized AI agent with a focused prompt, specific tool permissions, and targeted context.

| Agent | Role | Spawned by |
|---|---|---|
| **director-interviewer** | Conducts conversations with the user — onboarding interviews, brainstorming sessions, pivot discussions. One question at a time, multiple choice when possible. | `/director:onboard`, `/director:brainstorm`, `/director:pivot` |
| **director-planner** | Creates and updates gameplans. Breaks goals into steps, steps into tasks. Sequences work based on dependencies. | `/director:blueprint` |
| **director-researcher** | Explores implementation approaches, reads documentation, investigates tech options. Reports findings in plain language. | Sub-agent during blueprint and build |
| **director-mapper** | Analyzes existing codebases — maps architecture, tech stack, file structure, patterns, and concerns. | Sub-agent during `/director:onboard` (existing projects) and `/director:pivot` |
| **director-builder** | Executes individual tasks with fresh context. Writes code, makes changes, produces atomic commits. | `/director:build`, `/director:quick` |
| **director-verifier** | Structural verification (stub detection, wiring checks, orphan detection) and behavioral checklist generation. | Sub-agent after builds; primary agent for `/director:inspect` |
| **director-debugger** | Investigates issues found by the verifier. Diagnoses root causes, creates fix plans. | Sub-agent when verification finds problems |
| **director-syncer** | Compares codebase state against `.director/` documentation. Updates any files that are out of date. | Sub-agent after every task |

**Important:** These agents are invisible to the vibe coder during normal use. The user runs `/director:build` — they don't need to know that a builder agent executed the task, a verifier checked for stubs, and a syncer updated the docs. They just see results in plain language.

#### Workflow Orchestration

Each slash command triggers a workflow that chains agents together:

| Command | Workflow |
|---|---|
| `/director:onboard` | interviewer → mapper (if existing project) → planner → presents gameplan |
| `/director:blueprint` | researcher (sub-agent) → planner → presents updated gameplan |
| `/director:build` | builder (fresh context) → verifier (sub-agent) → syncer (sub-agent) → reports results |
| `/director:inspect` | verifier → debugger (if issues found) → presents checklist to user |
| `/director:brainstorm` | interviewer (with full project context) → routes to idea/task/pivot/nothing |
| `/director:pivot` | interviewer → mapper → planner → presents updated gameplan |
| `/director:quick` | builder (simplified) → verifier (sub-agent) → syncer (sub-agent) → reports results |

#### Comparison to GSD

GSD registers 11 agents and 24+ slash commands. Director aims for ~8 agents and ~11 commands. The difference reflects Director's design philosophy: fewer, more focused components with orchestration handled by workflows rather than exposing every agent role as a separate command.

| Aspect | GSD | Director |
|---|---|---|
| Agents | 11 (gsd-planner, gsd-executor, gsd-verifier, gsd-debugger, gsd-codebase-mapper, gsd-phase-researcher, gsd-project-researcher, gsd-research-synthesizer, gsd-roadmapper, gsd-plan-checker, gsd-integration-checker) | ~8 (director-interviewer, director-planner, director-researcher, director-mapper, director-builder, director-verifier, director-debugger, director-syncer) |
| Slash commands | 24+ | ~11 |
| Workflows | 24 workflow files | ~7 orchestration flows |
| User-visible complexity | High — users choose which command invokes which workflow | Low — users run one command, Director orchestrates the rest |

---

## 10. Documentation Sync

This is a critical differentiator. Keeping documentation in sync with code changes isn't yet second nature in the vibe coding workflow. Director handles this automatically.

### How It Works

After every task execution:
1. An agent compares the current codebase state against `.director/` documentation
2. If discrepancies are found, the agent updates the relevant files
3. Changes to VISION.md, GAMEPLAN.md, architecture docs, and CLAUDE.md are all checked
4. This also catches changes made outside of Director (e.g., the user prompted Claude directly to make a "quick fix")

### Manual Sync Command

For changes made entirely outside Director's workflow, users can run a documentation sync that:
1. Maps the current codebase
2. Compares against all documentation
3. Updates everything that's out of date
4. Reports what changed in plain language

This could be a subcommand or a dedicated skill invoked within the `/director` workflow.

---

## 11. Non-Functional Requirements

### Performance
- `/director:build` should start executing within 5 seconds of invocation
- `/director:status` should display within 2 seconds
- `/director:resume` should restore context within 10 seconds

### Cost
- Fresh context per task reduces API costs by 80%+ vs single-session approaches
- Effort controls (Phase 3) add another 60-80% reduction on routine operations
- Cost tracking visible to user (API cost per goal / step / task)

### Reliability
- State persisted to files, not memory. Closing the terminal loses nothing.
- Git-backed state means every change is recoverable
- Maximum 3-5 automatic retry cycles before escalating to user

### Simplicity
- ~11 commands total (compared to GSD's 30+)
- Zero required configuration (sensible defaults for everything)
- No YAML, XML, or config file editing required from the user
- All user-facing artifacts in Markdown (human-readable); XML used only at the agent context assembly layer (invisible to users)

---

## 12. Success Criteria

### For Noah (Primary User)
- "I described what I wanted, and Director helped me build it step by step"
- "I always knew where I was in the project and what was next"
- "When something went wrong, Director explained it and fixed it"
- "I never felt lost or overwhelmed"
- "My project actually got finished"
- "I used Director on my second project without hesitation"

### For Launch
- The plugin is installable via Claude Code Plugin Marketplace
- The core workflow (Blueprint / Build / Inspect) works end-to-end
- Noah has successfully used Director to build at least one complete project
- Documentation exists on director.cc

### Measurable Indicators
- Projects completed (not just started)
- API cost per goal / step / task (trending down over time)
- Number of `/director:pivot` invocations per project (indicates how well the initial interview surfaces requirements)
- Number of auto-fix cycles per task (indicates AI execution quality)

---

## 13. Out of Scope (v1)

These are explicitly NOT part of the MVP:

- **Multi-platform support** (Cursor, Codex, etc.) - Claude Code only for v1
- **Visual web dashboard** - CLI only for v1; Phase 3 feature
- **Coordinated agent teams across tasks** - Phase 3 feature (note: sub-agents within a single task ARE part of MVP — e.g., parallel codebase exploration, research, verification)
- **Multi-language support** - English only for v1
- **Pre-built project templates** - Dynamic brainstorming replaces static templates
- **Collaboration / multi-user features** - Solo vibe coder only
- **Automated test framework execution** — MVP uses structural verification (AI reads code for stubs/orphans) and behavioral checklists (user confirms features work). Automated test framework integration (Vitest, Jest, pytest) is Phase 2 and always opt-in. See §8.1.5 and §8.2.5.
- **Git branch management** - Single branch, linear history for v1
- **Deployment automation** - Director guides deployment thinking in onboarding but doesn't execute deployment
- **Constitutional governance / role-based access** - Enterprise features, not relevant for solo vibe coders
- **Git worktree management** - Not part of the vibe coding workflow
- **Exposing Director as an MCP server** — Director is a Claude Code plugin, not an MCP server. Exposing Director's commands via MCP (for Cursor, VS Code, etc.) is a future consideration for multi-platform support. Note: Director fully supports *using* MCP servers the user has configured — see §9.8.
- **Local/private LLM support** - Claude API only for v1

---

## 14. Competitive Positioning

| Dimension         | GSD                                   | Director                                                |
| ----------------- | ------------------------------------- | ------------------------------------------------------- |
| **Target User**   | Solo developers                       | Vibe coders                                             |
| **Language**      | Technical jargon                      | Plain English                                           |
| **Onboarding**    | "What do you want to build?"          | "Let's think through your project together" (interview) |
| **Planning**      | XML plans with file paths             | Plain-language gameplan                                 |
| **Commands**      | 30+ slash commands                    | \~10 slash commands                                     |
| **Progress**      | Text-based STATE.md                   | Visual status board                                     |
| **Errors**        | "Artifact wiring verification failed" | "The login page can't connect to the database yet"      |
| **Verification**  | "All tasks complete"                  | "Does this actually do what you wanted?"                |
| **Documentation** | Manual updates                        | Auto-sync after every task                              |
| **Effort**        | No indication                         | Small / Medium / Large per task                         |
| **Research**      | Technical RESEARCH.md                 | Plain-language "What this means for your project"       |
| **Resume**        | Manual `/gsd:pause-work`              | Automatic - just close terminal and come back           |
| **Terminology**   | Milestone / Phase / Plan              | Goal / Step / Task                                      |

**Strategic position:** GSD is the power tool for AI-assisted developers. Director is the framework built for vibe coders — it brings professional development structure to the AI-first workflow. No other tool occupies this position.

---

## 15. Build Strategy

### How Director Will Be Built

1. **Framework:** Use GSD to build Director (provides structure, atomic commits, goal-backward verification)
2. **Repository:** Private GitHub repo during development; flip to public at launch
3. **Platform:** Claude Code plugin (skills + slash commands + hooks)
4. **Dogfooding:** Once MVP is functional, switch to using Director for Director's own continued development
5. **Installation:** Claude Code Plugin Marketplace for v1 (NPX/npm distribution may be added in future versions for multi-platform support)

### Development Phases

**Goal 1: Core Workflow (MVP)**
- Interview-based onboarding
- Vision document generation
- Gameplan creation
- Execution engine with fresh context per task
- Goal-backward verification
- Progress tracking
- Session continuity
- Error handling
- Quick mode
- Pivot support
- Idea capture
- Brainstorming with project context

**Goal 2: Intelligence**
- Learning tips (toggleable)
- Research summaries in plain language
- Two-stage review
- Complexity-aware task breakdown
- Smart testing integration (opt-in automated test frameworks)

**Goal 3: Power Features**
- Coordinated agent teams for multi-task parallelism (Opus 4.6)
- Effort controls
- Visual dashboard
- Multi-platform support

---

## 16. Open Decisions

These need resolution during development, not before:

1. **Exact tip content and triggers** - What tips show, when, and how they're dismissed
2. **Documentation sync trigger** - After every task, or on a schedule, or on-demand only?
3. **Undo depth** - Can you undo multiple tasks, or just the last one?
4. **Update notification mechanism** - Email list? GitHub release notifications? In-CLI check?
5. **Architecture diagram format** - Mermaid charts (like GSD) or something simpler?
6. **Cost tracking granularity** - Per-task? Per-step? Per-session?
7. **Quick mode complexity threshold** - What triggers the "this is too complex for quick mode" warning?

---

*This PRD synthesizes research from 8 competitive analyses, Opus 4.6 capability assessment, and extensive brainstorming with the project creator. It is designed to serve as the primary reference document for building Director using GSD.*
