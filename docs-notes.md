# Director: User Guide Notes

**Purpose:** Raw material for the future user guide / documentation. These are conceptual explanations, workflow descriptions, and FAQ-style answers generated during the design phase. When it's time to write real documentation (after building), this file is the skeleton.

**Status:** Living document — updated as new context is generated during brainstorming sessions.

---

## How Director Works (The Big Picture)

Director is your project's structure layer. You have the vision for what you want to build. AI has the skills to build it. Director is the structure between them — it makes sure the right things get built, in the right order, and that what gets built actually matches what you wanted.

Director follows three phases:
1. **Blueprint** — Plan what you're building (interview, vision capture, gameplan creation)
2. **Build** — Execute tasks one at a time with fresh AI context
3. **Inspect** — Verify that what was built actually matches what you wanted

You don't have to think about these phases explicitly. Director's commands guide you through them naturally.

---

## Commands Overview

Director has ~11 commands. That's intentional — simplicity is a feature.

### The Core Loop

| Command | What it does | When to use it |
|---|---|---|
| `/director:blueprint` | Create, view, or update your gameplan | When you need a plan or want to change one |
| `/director:build` | Execute the next ready task | When you're ready to make progress |
| `/director:inspect` | Verify what was built matches the goal | After completing a step or goal |

### Project Management

| Command | What it does | When to use it |
|---|---|---|
| `/director:onboard` | Project setup (interview + vision + initial plan) | Once per project, when first adopting Director |
| `/director:status` | Show visual progress board | When you want to see where things stand |
| `/director:resume` | Pick up where you left off | When returning to a project after a break |

### Thinking & Flexibility

| Command | What it does | When to use it |
|---|---|---|
| `/director:brainstorm` | Think out loud with full project context | When you want to explore an idea before committing to it |
| `/director:quick "..."` | Fast task without full planning | For small, straightforward changes |
| `/director:pivot` | Handle changes in direction | When what you want to build has changed |
| `/director:idea "..."` | Capture an idea for later | When inspiration strikes during a build |
| `/director:help` | Show available commands with examples | When you need guidance |

---

## How to Add a New Feature (Four Paths)

One of the most common things you'll do is add a new feature to an existing project. There are four ways to do this, depending on how formed your idea is and how big the change is.

### Path 1: You know exactly what you want, and it's small
**Command:** `/director:quick "add a dark mode toggle"`

Quick mode analyzes the request. If it's genuinely simple (touches one or two files, no planning needed), it executes immediately — fresh agent, atomic commit, done. If the AI determines it's more complex than it sounds, it tells you: "This is more intricate than it seems. I'd recommend using `/director:blueprint` first." And offers to switch.

**This is the "I just need a quick thing" path.**

### Path 2: You have an idea but aren't ready to act
**Command:** `/director:idea "add user profiles with avatar uploads"`

This saves the idea instantly. No conversation, no planning. It's a bookmark. Later, when you want to act on it (or when Director surfaces your ideas list), it analyzes the idea and routes it: "This is a small change, want me to do it now?" or "This would need a new step in your gameplan. Want me to plan it out?"

**This is the "capture it before I forget" path.**

### Path 3: You want to think it through first
**Command:** `/director:brainstorm`

You have a vague idea — "I'm thinking about adding some kind of notification system" — and you want to explore it with full project context. You have a conversation with Director. At the end, it suggests the right next step:
- "This is a quick change" → offers to run it now
- "This needs planning" → offers to update your gameplan
- "This is a whole new goal" → offers to create a new goal
- "Interesting but not now" → saves to your ideas list
- "Just exploring, no action" → saves the conversation for reference

**This is the "let me think out loud" path.**

### Path 4: You know what you want, and it's substantial
**Command:** `/director:blueprint`

You already know you want to add payments, user profiles, or some significant feature. Blueprint updates your gameplan — it might add a new Goal, new Steps, or new Tasks. The AI researches what's needed, sequences the work, and presents the updated gameplan for your approval. Then you run `/director:build` to start executing.

**This is the "I'm ready to plan and build" path.**

### How the paths connect

```
Vague idea → /director:brainstorm → routes to idea, quick, blueprint, or nothing
Quick capture → /director:idea "..." → saved → later analyzed → routes to quick or blueprint
Small change → /director:quick "..." → executes (or escalates to blueprint)
Big feature → /director:blueprint → plan → /director:build → execute
```

The key insight: these commands aren't isolated — they're entry points into the same system. Brainstorm can lead to idea capture. An idea can become a quick task or trigger planning. Quick mode can escalate to blueprint. They all feed into the same gameplan and execution engine.

---

## How Brainstorming Works

`/director:brainstorm` is for thinking out loud with full project context. It's different from other commands:

- `/director:onboard` = structured onboarding interview (once per project)
- `/director:idea "..."` = quick capture, no conversation
- `/director:pivot` = specifically about changing direction
- `/director:brainstorm` = open-ended exploration that could lead anywhere

When you start a brainstorm:
1. Director loads your full project context — your vision, gameplan, current progress, and codebase
2. You have a conversation. Director asks one question at a time, uses multiple choice when it makes sense, and follows your lead
3. When exploring potential changes, Director considers the impact on your existing project: "Adding payments would touch your database, your user profile page, and you'd need a new step for Stripe setup."
4. At the end, Director suggests the appropriate next step (save idea, create task, trigger pivot, or just save the conversation)

Every brainstorm session is saved to a dated file for reference, so you can come back to it later.

---

## How Pivot Works

### When to use pivot

**The simple version:** If what you *want to build* has changed, that's a pivot. If you just want to *build more*, that's blueprint.

| Scenario | Command | Why |
|---|---|---|
| "I want to add dark mode" | blueprint or quick | Adding to what exists |
| "I want to add a payment system" | blueprint | New feature, same vision |
| "I was building a to-do app but now I want it to be a project management tool" | **pivot** | The vision changed |
| "I was targeting individuals but now I want to target teams" | **pivot** | The audience changed |
| "I chose Supabase but I want to switch to Firebase" | **pivot** | Major technical direction change |
| "Half the features I planned aren't needed" | **pivot** | The gameplan no longer reflects what you're building |

### Three ways a pivot gets triggered

**1. You just know.** Something happened — you showed your project to someone and realized the direction needs to change. You come back and run `/director:pivot`.

**2. Brainstorm routes to it.** During a brainstorm session, Director recognizes your idea isn't an addition — it's a direction change. It suggests: "This sounds like a change in direction, not just a new feature. Want me to run a full pivot?"

**3. Inspect surfaces it.** During verification, you realize what was built technically works but isn't what you actually want. Director recognizes this is a vision mismatch, not a bug, and suggests a pivot.

### What pivot does behind the scenes

Pivot isn't "start over." It's intelligent:
1. Director asks what changed and why (focused conversation, not full re-onboarding)
2. Scans the current codebase to understand what exists
3. Compares what exists against the new direction:
   - What existing work is still valid (keep it)
   - What needs to be modified (update it)
   - What's no longer needed (mark it as superseded)
   - What new work is needed (add to gameplan)
4. Updates your vision, gameplan, and all relevant documentation
5. Presents the updated gameplan for your approval

You see something like: "Three of your five steps are still good. Step 2 needs some rework, and I've added a new Step 6 for the notification system you described. Here's the updated gameplan — does this look right?"

### Safety net

If you run pivot but you're really just adding a feature, Director recognizes that: "This sounds like a new feature, not a change in direction. Your current vision still applies. Want me to add this to your gameplan instead?"

Same in reverse — if you run blueprint but your change conflicts with your existing vision, Director flags it: "This would change the direction of your project. Want to run a pivot instead?"

The commands are entry points, not rigid pipelines. Director understands the intent and routes appropriately.

---

## How Verification Works (Three Tiers)

Director uses three levels of verification to make sure what gets built actually works:

### Tier 1: Structural Verification (automatic)
After every task, Director reads the code and checks:
- Do the files actually exist?
- Are they real code or just placeholder/stub code (TODOs, empty returns, "coming soon" comments)?
- Are they connected to the rest of the project (imported and used, not orphaned)?

This is invisible to you unless issues are found. If Director detects a problem: "The login page was created but it's not actually connected to anything yet. Want me to fix this?"

No test framework needed — this is purely the AI reading your code.

### Tier 2: Behavioral Verification (guided)
At step and goal boundaries, Director generates a plain-language checklist:
- "Try logging in with a wrong password. What happens?"
- "Go to the homepage and click 'New Project'. Do you see a form?"

You try each thing and report back. This is where your judgment matters — does it look right, feel right, work as expected?

### Tier 3: Automated Testing (opt-in, Phase 2)
If you have a testing tool set up (or want one), Director can run automated tests and report results in plain language: "2 of your login tests passed, but the one that checks wrong passwords found an issue."

This is always optional. Tiers 1 and 2 work without any test framework.

---

## How MCP Servers Work with Director

Director runs inside Claude Code. Whatever MCP servers you have configured (Supabase, Stripe, GitHub, etc.) are automatically available to Director's agents.

**Example:** If you have Supabase MCP installed and say "set up my database," Director's build agent can inspect your existing Supabase project, check tables, and generate matching code. You don't need to configure anything in Director for this — it inherits your Claude Code setup.

Director doesn't manage, install, or configure MCP servers. That's your Claude Code environment.

---

## What Agents Are (And Why You Don't Need to Think About Them)

Behind the scenes, Director uses ~8 specialized AI agents:

| Agent | What it does |
|---|---|
| **Interviewer** | Conducts conversations — onboarding, brainstorming, pivots |
| **Planner** | Creates and updates your gameplan |
| **Researcher** | Explores how to build things, reads documentation |
| **Mapper** | Analyzes your existing codebase |
| **Builder** | Executes tasks, writes code |
| **Verifier** | Checks that code is real (not stubs) and generates checklists |
| **Debugger** | Investigates and fixes issues |
| **Syncer** | Keeps documentation up to date |

You never interact with these directly. When you run `/director:build`, you don't need to know that a builder agent executed the task, a verifier checked for stubs, and a syncer updated the docs. You just see results in plain language.

---

## Director's Vocabulary

Director uses its own terms, designed around how you think about your project:

| What other tools call it | What Director calls it | Why |
|---|---|---|
| Milestone / Version / Release | **Goal** | Everyone understands "what's the goal?" |
| Phase / Epic / Module | **Step** | Building happens one step at a time |
| Plan / Sprint / Iteration | **Task** | Something you do to make progress |
| Subtask / Story | **Action** | The smallest unit of work (invisible to you) |
| Specification / PRD | **Vision** | What you want to build |
| Roadmap / Backlog | **Gameplan** | Your plan for getting there |
| Deploy / Ship / Release | **Launch** | Everyone knows what "launch" means |
| Dependency / Blocker | **"Needs X first"** | Plain English |

Your project hierarchy: **Project > Goals > Steps > Tasks > Actions**

Actions are invisible — they're what the AI does to complete tasks. You work at the Goal, Step, and Task level.

---

## How Context and Fresh Agents Work

One of the biggest problems with using AI for long projects is that AI quality degrades as conversations get longer. Director solves this with "fresh context per task."

Every time Director executes a task, it starts a brand new AI session with only the context that task needs:
- Your vision document (what you're building)
- The relevant step context (what part of the project you're in)
- The task description (what needs to be done)
- Recent git history (what was just built)

This means the AI is always sharp, never confused by old conversation history, and your API costs stay low (80%+ cheaper than running everything in one long session).

You don't need to think about this. It just happens.

---

## Formatting: What You See vs. What the AI Sees

Your project files (`.director/VISION.md`, `.director/GAMEPLAN.md`, etc.) are all Markdown — human-readable, easy to browse. You can open them in any text editor or viewer.

Behind the scenes, when Director loads these files into an AI agent's context, it wraps them with XML tags to help the AI parse them accurately. You never see this. It's like how a web browser renders HTML — you see the pretty page, not the source code.

---

## Why the Command Is Called "Onboard" (Not "New" or "Start")

The first command you'll run is `/director:onboard`. It was originally called `/director:new`, but that name had a problem: "new" is evergreen. Three months into a project, you might think "I have a new feature idea" and reach for `/director:new` when you actually wanted `/director:blueprint` or `/director:brainstorm`.

"Onboard" describes what Director is actually doing — learning about your project and setting itself up. That's true whether it's an empty folder or an existing codebase with thousands of lines of code. And nobody 6 months into a project thinks "I need to onboard." The word is self-limiting — it naturally sounds like a one-time action.

There's no hidden alias or alternate name. Part of Director's philosophy is teaching you to think like a director — understanding the difference between onboarding, blueprinting, brainstorming, and pivoting. The commands are named so you can find the right one intuitively.

---

## There's No Wrong Door

Every command detects where your project is and redirects if you invoke something out of sequence. You can't get stuck or cause damage by picking the "wrong" command.

- Run `/director:build` before setting up? Director says "Let's get your project set up first" and walks you through onboarding.
- Run `/director:onboard` on a project that's already set up? Director shows you where you are and suggests the right next action.
- Run `/director:inspect` before anything is built? Director tells you there's nothing to inspect yet and suggests building first.

This means a brand new user can type literally any command and Director will either do the right thing or guide them to the right thing. You don't need to memorize the "correct" order.

---

## Adding Context After Any Command

Every command accepts optional text after it. If you include text, it focuses the command. If you don't, Director asks you or proceeds with defaults. Both ways work — inline text is an accelerator, never a requirement.

**With context (skips the first question):**
- `/director:idea add a dark mode toggle` — saves it immediately
- `/director:blueprint add payment processing` — focuses the gameplan update on payments
- `/director:quick fix the typo on the login page` — analyzes and executes
- `/director:brainstorm what about real-time collaboration?` — starts a directed brainstorm

**Without context (Director asks or proceeds):**
- `/director:idea` — "What's on your mind?"
- `/director:blueprint` — reads your Vision and builds the full gameplan
- `/director:quick` — "What do you need done?"
- `/director:brainstorm` — "What do you want to think through?"

You don't need quotes or brackets around the text. Just type naturally after the command.

---

## Coming Back After a Break (And External Changes)

You don't need to "save" or "pause" your work. Director saves progress automatically after every task via atomic commits and state files. You can close your terminal, shut down your computer, or walk away mid-project. When you come back, run `/director:resume`.

**What if you made changes outside Director?** This happens all the time — you switched to Cursor for a few days, or made quick edits directly. When you run `/director:resume`, Director detects that the codebase has changed since it last worked with you. It maps the differences, updates all the project documentation to reflect the current state, and shows you a summary of what changed before continuing.

You can also check for drift mid-session. If you just made changes in another tool and want Director to catch up, run `/director:status` and let it know — it will detect the changes and offer to sync everything.

**There's no pause command.** This is intentional. If a pause command existed, forgetting to pause would feel risky ("did I lose my work?"). Without one, the system is always safe — your state is always persisted, whether you walked away gracefully or your terminal crashed. You never have to worry about it.

---

## Git vs. GitHub (And Why You Don't Need GitHub)

Director uses **Git**, not GitHub. These are different things:

- **Git** is version control that runs locally on your machine. It tracks changes, lets you undo things, and keeps history. No account needed, no internet needed.
- **GitHub** is a remote platform where you can store and share your code online. It's optional.

Director uses local Git behind the scenes for three things: undo (reverting a bad task), context (helping fresh agents understand what was already built), and sync detection (knowing what changed). You never interact with Git directly — you just see "Progress saved" and "You can undo this."

**You don't need a GitHub account to use Director.** If you're building a simple static website and just want to work locally, Director works perfectly. Git runs silently on your machine and you'll never know it's there.

### If You Do Use GitHub

Director never pushes to GitHub on its own. That's always your call. Here's how the two layers work together:

1. You run `/director:build` and Director completes tasks, making local commits along the way (you see "Progress saved")
2. Those commits live only on your machine. GitHub doesn't know about them.
3. You keep building. More tasks, more local commits.
4. When **you** decide you're ready, you tell Claude Code exactly like you normally would: "Push my changes to GitHub" or "Create a pull request."
5. All your accumulated progress goes to GitHub at that point.

Your current workflow doesn't change at all:
- Director handles local commits automatically (invisible to you)
- You say "push to GitHub" whenever you're ready (exactly like today)
- You say "create a pull request" whenever you want (exactly like today)
- Director never touches GitHub on its own

Since Director makes one small commit per task, when you push, GitHub receives a clean history of what was built and when. If you'd prefer one combined commit instead, you can tell Claude Code "squash and push my changes."

---

*This document will be expanded as more design decisions and workflow explanations are generated during brainstorming sessions. After Director is built, these notes become the foundation for the official user guide, supplemented with real command outputs, screenshots, and troubleshooting guides.*
