---
name: blueprint
description: "Create, view, or update your project gameplan. Breaks your vision into Goals, Steps, and Tasks."
---

# Director Blueprint

First, check if `.director/` exists. If it does not, run the init script silently:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/init-director.sh"
```

Say only: "Director is ready." Then continue with the steps below.

---

## Determine Project State

Read `.director/VISION.md` and check whether it has real content beyond the default template.

**Template detection for VISION.md:** If the file contains placeholder text like `> This file will be populated when you run /director:onboard`, or italic prompts like `_What are you calling this project?_`, or headings with no substantive content beneath them (just blank lines, template markers, or italic instructions), the project has NOT been onboarded yet.

**If VISION.md is empty or still the default template:**

Say something like:

> "Before creating a gameplan, we need to understand what you're building. Want to start with `/director:onboard`? It's a quick interview to capture your vision."

Wait for the user's response. If they agree, proceed as if they invoked `/director:onboard` -- run through the onboard flow to capture their vision first.

**If VISION.md has real content**, read `.director/GAMEPLAN.md` and check whether it has real content.

**Template detection for GAMEPLAN.md:** Check for ALL of these signals:
- The init template phrase: `This file will be populated when you run /director:blueprint`
- The placeholder text: `_No goals defined yet_`
- Whether there are actual goal headings with substantive content beneath them (real goal names, descriptions, steps -- not just template markers)

If GAMEPLAN.md contains only template/placeholder text and no actual goal definitions, this is **NEW gameplan mode**. Continue to Handle Arguments below.

If GAMEPLAN.md has real content (actual goal names with descriptions, steps listed, etc.), this is **UPDATE mode**.

**For update mode:** Say something conversational like:

> "I can see you already have a gameplan. Updating an existing gameplan will be available in a future update."

If `$ARGUMENTS` is non-empty, acknowledge it:

> "Noted -- you want to [arguments]. Once gameplan updates are ready, I'll be able to work that into your existing plan."

Wait for the user's response. Do not continue further.

---

## Handle Arguments

If `$ARGUMENTS` is non-empty, acknowledge it before proceeding:

> "You want to focus on [arguments]. Let me read your vision and create a gameplan."

If `$ARGUMENTS` is empty, say something like:

> "Let me read your vision and put together a gameplan."

---

## Check for Open Questions

Before generating goals, scan the VISION.md content for `[UNCLEAR]` markers.

**If [UNCLEAR] markers are found**, present them to the user:

> "Before we plan, I noticed some open questions in your vision:"
>
> 1. [First UNCLEAR item]
> 2. [Second UNCLEAR item]
>
> "Want to resolve these now, or should I plan around them? If we skip them, some tasks might need adjustment later."

Wait for the user's response. If they want to resolve the questions, work through each one conversationally. Update your understanding of the vision accordingly (but do NOT rewrite VISION.md here -- that happens via `/director:onboard`).

If the user wants to defer, note the unresolved items and proceed. Keep them in mind when generating tasks -- tasks affected by unclear items should note this in their "Needs First" section.

**If no [UNCLEAR] markers are found**, proceed directly to goal generation.

---

## Phase 1: Generate and Review Goals

Read the full content of VISION.md to understand the project. Then generate goals following the planning rules below.

### Planning Rules

These rules govern how the gameplan is structured. Follow them throughout the entire planning process.

#### Rule 1: Goals are outcomes, not activities

A goal describes what the user will HAVE when it's complete, not what you'll DO to get there.

**Good goals (outcomes -- what users can do):**
- "Users can sign up, log in, and manage their accounts"
- "The dashboard shows real-time data with filters and search"
- "Payments work end-to-end: checkout, receipts, and refunds"

**Bad goals (activities -- what you'll build):**
- "Build authentication system"
- "Create dashboard components"
- "Implement Stripe integration"

If you catch yourself writing a goal that starts with "Build", "Create", "Implement", "Set up", or "Configure", rewrite it as what users can do when it's complete.

#### Rule 2: Steps are verifiable chunks of work

Each step delivers something the user can see or interact with. A step is complete when you can point to what it produced.

**Good steps:**
- "Login page with form validation and error messages"
- "Product listing page with search and filtering"
- "Email notifications for order confirmations"

**Bad steps:**
- "Set up database models"
- "Configure API routes"
- "Write utility functions"

#### Rule 3: Tasks are single-sitting work units

A task is something that can be completed in one focused session. It should be clear enough that someone could start working immediately.

Each task includes five fields:
- **What To Do** -- Plain-language description
- **Why It Matters** -- How this connects to the bigger picture
- **Size** -- Small, medium, or large (see Complexity Indicators below)
- **Done When** -- 3-5 specific, observable checklist items
- **Needs First** -- What capabilities the project must have before this task can start, in plain language

#### Rule 4: Order by what's needed first

If the login page needs user accounts in the database, the database setup comes before the login page. Express this as "Needs the user database set up first" not "Depends on TASK-03."

Never use task IDs, technical identifiers, or jargon for prerequisites. Users think in capabilities, not identifiers.

**Never say:** "Depends on TASK-03" or "Blocked by AUTH-01" or "Prerequisite: database migration"
**Always say:** "Needs the user database set up first" or "Needs the login page built first"

#### Rule 5: Use ready-work filtering

Mark tasks as "ready" only when everything they need is already complete. When presenting the gameplan, make it clear which tasks can be started right now.

- Tasks with no prerequisites: marked "Ready"
- Tasks with unmet prerequisites: show what they need in plain language

#### Rule 6: Prefer vertical slices over horizontal layers

Build complete features one at a time, not all database models first, then all API routes, then all UI.

**Good order (vertical slices -- users see working features sooner):**
1. Complete login flow (database + API + UI for login)
2. Complete signup flow (database + API + UI for signup)
3. Complete profile page (database + API + UI for profiles)

**Bad order (horizontal layers -- nothing works until everything is done):**
1. Create all database models
2. Create all API routes
3. Create all UI pages

### Complexity Indicators

Help users understand the scope of each task:

| Size | What It Means | Typical Scope |
|------|--------------|---------------|
| **Small** | Quick change, straightforward | Single file, clear approach, under 30 minutes |
| **Medium** | Some decisions involved | Multiple files, a few choices to make, 30-90 minutes |
| **Large** | Significant work, may need research | Multiple files, important decisions, possibly new tools or libraries, 90+ minutes |

These are effort indicators, not time estimates. "Small" means "simple and clear," not "exactly 15 minutes."

### Generate Goals

Using the vision content and the rules above, generate 2-4 goals as outcomes. Each goal should have a name (what users can do) and a 1-2 sentence explanation of why it matters.

Present ALL goals together (not one at a time) in numbered format:

> Based on your vision, here are the goals I'd suggest:
>
> 1. **[Goal as outcome]** -- [Why this matters for the project]
> 2. **[Goal as outcome]** -- [Why this matters for the project]
> 3. **[Goal as outcome]** -- [Why this matters for the project]
>
> Does this feel right? Want to add, remove, or rearrange anything?

Wait for the user's response. If they give feedback (add a goal, remove one, rename one, reorder them), adjust the goal set and re-present. Iterate until the user approves.

**Important:** Do NOT generate Steps or Tasks yet. Goals must be approved before proceeding.

---

## Phase 2: Generate Full Hierarchy

After the user approves the goals, generate Steps and Tasks for each goal.

For each approved goal:
- Generate Steps as verifiable chunks of work (Rule 2). Each step delivers something visible.
- For each step, generate Tasks with all five required fields (Rule 3): What To Do, Why It Matters, Size, Done When, Needs First.
- Order steps and tasks following vertical slices (Rule 6) and dependency ordering (Rule 4).
- Mark tasks with no unmet prerequisites as "Ready".
- Target 2-5 steps per goal and 2-7 tasks per step.

Present the full outline with one-line descriptions and size indicators:

> Here's the complete gameplan:
>
> **Goal 1: [Goal Name]**
>
>   Step 1: [Step name]
>     - [Task name] (size) -- Ready
>     - [Task name] (size) -- Needs [capability]
>
>   Step 2: [Step name]
>     - [Task name] (size) -- Needs [capability]
>     - [Task name] (size) -- Needs [capability]
>
> **Goal 2: [Goal Name]**
>
>   Step 1: [Step name]
>     - [Task name] (size) -- Needs [capability from Goal 1]
>     - [Task name] (size) -- Needs [capability]
>
> Does this look good? Want to change the order, add anything, or remove anything?

Wait for explicit approval. If the user gives feedback, adjust and re-present. Iterate until they approve.

**Important:** Do NOT write any files until the user explicitly approves this outline.

---

## Write Gameplan

After the user approves the full outline, write all gameplan files.

### 1. Write GAMEPLAN.md

Write `.director/GAMEPLAN.md` following this structure:

```markdown
# Gameplan

## Overview

[A brief summary of what this project is building and how we're approaching it. 2-3 sentences drawn from the vision.]

## Goals

1. **Goal 1: [Goal Name]** -- [One-line description]
2. **Goal 2: [Goal Name]** -- [One-line description]
3. **Goal 3: [Goal Name]** -- [One-line description]

## Current Focus

**Current Goal:** Goal 1
**Current Step:** Step 1 ([Step name])
**Next Up:** [What comes after the current step]
```

### 2. Write Goal, Step, and Task Files

For each goal, step, and task in the approved outline:

**Goal directories and files:**
- Create directory: `.director/goals/NN-goal-slug/` (e.g., `01-user-accounts/`)
- Write `GOAL.md` in each goal directory:
  ```markdown
  # Goal N: [Goal Name]

  ## What Success Looks Like

  [Describe what "done" means for this goal -- what will the project be able to do?]

  ## Steps

  1. **Step 1: [Step Name]** -- [What this delivers]
  2. **Step 2: [Step Name]** -- [What this delivers]

  ## Status

  **Progress:** Not started
  **Steps complete:** 0 of [total steps]
  ```

**Step directories and files:**
- Create directory: `.director/goals/NN-goal/NN-step-slug/` (e.g., `01-user-accounts/01-login-flow/`)
- Write `STEP.md` in each step directory:
  ```markdown
  # Step N: [Step Name]

  ## What This Delivers

  [What will be working or available when this step is done?]

  ## Tasks

  - [ ] Task 1: [Task Name]
  - [ ] Task 2: [Task Name]

  ## Needs First

  [What needs to be done before this step can start? Plain language.]
  [If nothing: "Nothing -- this step can start right away."]
  ```

**Task directories and files:**
- Create directory: `.director/goals/NN-goal/NN-step/tasks/`
- Write each task as `NN-task-slug.md` in the tasks directory:
  ```markdown
  # Task: [Task Name]

  ## What To Do

  [Clear description of what this task accomplishes.]

  ## Why It Matters

  [How does this task contribute to the current step and goal?]

  ## Size

  **Estimate:** [small | medium | large]

  [Brief explanation of scope.]

  ## Done When

  - [ ] [First observable criteria]
  - [ ] [Second observable criteria]
  - [ ] [Third observable criteria]

  ## Needs First

  [What needs to be done before this task can start?]
  [If nothing: "Nothing -- this can start right away."]
  ```

**Directory naming conventions:**
- Use zero-padded numbers with kebab-case slugs: `01-user-accounts/`, `02-habit-tracking/`
- Keep slugs short: 2-4 words derived from the goal/step/task name
- Lowercase, hyphens instead of spaces

**How to create the files:**
- Use Bash for `mkdir -p` to create directories
- Use the Write tool for file content
- Do NOT narrate each file path or mkdir command to the user

---

## Conversational Wrap-Up

After all files are written, tell the user conversationally:

> "Your gameplan is saved. I created [N] goals with [M] steps and [T] tasks total. You can browse the full plan in `.director/goals/` if you're curious, but Director handles everything from here."

Do NOT list file paths, directory structures, or technical details. The user just needs to know it's done and how big the plan is.

---

## Suggest Next Step

After the wrap-up, suggest the next action:

> "Ready to start building? You can do that with `/director:build`."

Wait for the user's response. Do not auto-execute the next command.

---

## Language Reminders

Throughout the entire blueprint flow, follow these rules:

- **Use Director's vocabulary:** Vision (not spec), Gameplan (not roadmap), Goal/Step/Task (not milestone/phase/ticket)
- **Explain outcomes, not mechanisms:** "Your gameplan is saved" not "Writing GAMEPLAN.md to .director/GAMEPLAN.md"
- **Be conversational, not imperative:** "Want to start building?" not "Run /director:build"
- **Never blame the user:** "We need to figure out X" not "You forgot to specify X"
- **Celebrate naturally:** "Nice -- that's a solid plan" not forced enthusiasm
- **Match the user's energy:** If they're excited, be excited. If they're focused, be focused.
- **Never use developer jargon in output:** No dependencies, artifacts, integration, repositories, branches, commits, schemas, endpoints, middleware, migration, blocker, prerequisite. Use plain language equivalents.
- **Goals start with outcomes:** "Users can..." not "Build..." or "Implement..."
- **Prerequisites in plain language:** "Needs the login page built first" not "Depends on TASK-03"
- **File operations are invisible:** Say "Your gameplan is saved" not "Created 15 files in .director/goals/"

$ARGUMENTS
