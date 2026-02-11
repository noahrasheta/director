---
name: director:blueprint
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

If GAMEPLAN.md has real content (actual goal names with descriptions, steps listed, etc.), this is **UPDATE mode**. Skip to the Update Mode section below.

---

## Handle Arguments (New Gameplan Mode)

This section applies only in **new gameplan mode**. Update mode has its own argument handling.

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

## Check Context Freshness

Before loading research context, check whether the project's research and codebase analysis files are still current.

1. Read `.director/config.json` and extract `context_generation.completed_goals_at_generation`. If the `context_generation` field does not exist (backward compatibility with pre-Phase 16 projects), default to 0.
2. Count the current number of completed goals by scanning `.director/goals/` directories. A goal is "completed" if its GOAL.md Status section shows "Complete" or all its steps' tasks are `.done.md` files.
3. Calculate the delta: `current_completed_goals - completed_goals_at_generation`.
4. If delta >= 2: show a brief, non-blocking alert to the user before proceeding. Something like:

   > "Your project research and codebase analysis were done a while ago -- you've finished [N] goals since then. You might want to run `/director:onboard` to refresh that context. Continuing with what we have for now."

5. If delta < 2: proceed silently.

This alert is NON-BLOCKING. After showing it (or skipping it), continue to Load Research Context below. The user can choose to act on the suggestion or ignore it.

---

## Load Research Context

Before generating goals, check if domain research exists from onboarding:

Read `.director/research/SUMMARY.md` silently using `cat .director/research/SUMMARY.md 2>/dev/null`.

If the file exists and has content, store its contents internally wrapped in a `<research_summary>` tag:

```
<research_summary>
[Contents of SUMMARY.md]
</research_summary>
```

This research context informs goal generation and step planning -- use it to:
- Suggest goals that align with research-recommended architecture patterns
- Prefer technologies and approaches recommended by the research
- Incorporate "Don't Hand-Roll" warnings when relevant to goal/step sizing
- Reference research findings when explaining goal rationale to the user

If the file does not exist or is empty, proceed silently. Do NOT mention missing research to the user or agent. Do NOT include an empty `<research_summary>` tag.

This context is a bonus -- it makes planning smarter when available but changes nothing when absent.

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

## Capture Step-Level Decisions

After the user approves the full hierarchy outline and before writing files, extract decisions from the conversation.

### What counts as a decision

A decision is a statement the user made about HOW something should be built. Look for:

- **Technology choices:** "use Supabase", "stick with REST", "use Tailwind"
- **Design direction:** "keep the UI simple", "no animations", "single-page layout"
- **Implementation approach:** "server-side rendering", "use existing auth library"
- **Scope boundaries:** "skip dark mode for now", "don't worry about mobile yet"

What is NOT a decision (these belong in vision or task descriptions):
- General project descriptions ("it's a task management app")
- Feature requests ("I want users to be able to share lists")
- Goal definitions ("users can manage their accounts")

### How to capture decisions

1. Review the entire conversation (both Phase 1 goal discussion and Phase 2 hierarchy discussion) for statements matching the categories above.

2. For each decision found, determine which step it most affects. If a decision is cross-cutting (e.g., "use PostgreSQL for everything"), assign it to EVERY step where it is relevant. Duplicate the decision into each affected step rather than creating an inheritance mechanism.

3. Categorize each decision:
   - **Locked:** User said "use X" or "I want Y" or "make sure Z" -- an explicit directive about how to build something.
   - **Flexible:** User said "I don't care about X" or "whatever works" or simply did not express a preference on a choice point that the planner surfaced. Include brief context when available (e.g., "Styling approach -- user has no preference").
   - **Deferred:** User said "not now" or "save for later" or "skip X for now" -- explicit scope boundary.

4. Associate each decision with the step(s) it affects.

### Important rules

- Do NOT ask the user to enumerate their decisions. Extract them passively from the natural conversation. This should be invisible to the user -- they see their gameplan written, and the decisions they expressed are captured without any additional interaction.
- Do NOT create Flexible items for every conceivable choice. Only include Flexible items where the conversation specifically surfaced a choice point and the user expressed no preference. Silence on a topic is not a Flexible decision -- it just means the builder has normal discretion.
- If a step has no relevant decisions from the conversation, OMIT the Decisions section entirely from that step's STEP.md. Do not write empty categories.

---

## Step-Level Research

After capturing step-level decisions and before writing gameplan files, run step-level research for steps that need it. This investigates the technical domain of each qualifying step and produces a RESEARCH.md in the step directory for the planner to use when writing task files.

### Skip Conditions

Skip this entire section if ANY of the following are true:

- `workflow.step_research` is `false` in `.director/config.json` (read with fallback: default to `true` if the field doesn't exist -- backward compatibility for projects initialized before this feature)
- `$ARGUMENTS` includes `--skip-research`
- This is update mode and no pending/new steps have changed (all steps are either frozen/completed or unchanged)

Force fresh research for all pending steps if `$ARGUMENTS` includes `--research` (delete existing RESEARCH.md files for pending steps and re-research).

### Assess Step Complexity

For each step in the approved outline, determine whether it needs research. This is a judgment call -- not every step warrants investigation.

**Research likely NEEDED when:**
- Step involves technology the project hasn't used before
- Step includes Large-sized tasks
- Step involves third-party integrations or APIs
- Onboarding research flagged this domain for deeper investigation
- All technology choices are Flexible (no locked decisions guiding approach)

**Research likely NOT needed when:**
- Step is pure UI work with the project's established framework
- Step extends patterns already in use
- All tasks are Small with clear approaches
- Onboarding research thoroughly covered this domain
- Step is configuration/setup with known tools

Note which steps need research. If none do, skip directly to Write Gameplan.

### Brief User Message

If any steps need research, show ONE brief message:

> "Let me look into the technical details for a couple of these steps..."

Do NOT list which steps are being researched or explain the research process. This runs silently.

### Create Step Directories

Before spawning researchers, create directories for steps that need research:

```bash
mkdir -p .director/goals/NN-goal/NN-step/
```

This ensures researchers have a target directory for writing RESEARCH.md.

### Model Profile Resolution

Read `.director/config.json` and resolve the model for `deep-researcher`:

1. Read the `model_profile` field (defaults to "balanced")
2. Look up the profile in `model_profiles` to get the model for `deep-researcher`
3. Fall back to "balanced" defaults if config is missing these fields

### Smart Reuse Check

Before spawning a researcher for a step, check if `RESEARCH.md` already exists in the step directory:

- **If exists AND `--research` flag is NOT set:** Read the Reuse Metadata section of the existing RESEARCH.md. Compare current step scope (name, deliverables, planned tasks) and current decisions (Locked, Flexible, Deferred) against what's recorded in the metadata.
  - If substantively the same: skip research for this step. "Substantively the same" means: step name and deliverables match, locked decisions haven't changed, no new flexible areas that were previously absent.
  - If changed significantly: delete old RESEARCH.md, mark for re-research.
- **If exists AND `--research` flag IS set:** Delete old RESEARCH.md, mark for re-research.
- **If does not exist:** Mark for research.

### Research Spawning

For each goal, spawn a `director-deep-researcher` agent for ALL steps that need research within that goal IN PARALLEL using the Task tool. All researcher Task tool calls for steps within the same goal go in a SINGLE message so they execute in parallel.

Each `director-deep-researcher` spawn uses these instructions:

```
<instructions>
Scope: step-level

<vision>
[Full VISION.md contents]
</vision>

<step_context>
Step name: [step name from approved outline]
What this delivers: [from step description]
Tasks planned: [brief task list from outline]
</step_context>

<decisions>
Locked:
- [locked decisions for this step, from Capture Step-Level Decisions]

Flexible:
- [flexible areas for this step]

Deferred:
- [deferred items for this step -- DO NOT research these]
</decisions>

<onboarding_research>
[If .director/research/SUMMARY.md exists and is relevant to this step's domain, include relevant sections here. If it doesn't exist or isn't relevant, omit this tag entirely.]
</onboarding_research>

Research the technical domain for this step. Focus on:
- Libraries and tools needed for the specific work in this step
- Architecture patterns for this step's deliverables
- Common pitfalls when building what this step delivers
- Problems with existing solutions (don't hand-roll)

For Locked decisions: investigate the chosen approach deeply.
For Flexible areas: rank 2-3 options with tradeoffs.
Do NOT research Deferred items.

Write your findings to [step directory path]/RESEARCH.md using the
step research template at skills/blueprint/templates/step-research.md.

Return only a brief confirmation when done. Do NOT include file
contents in your response.
</instructions>
```

The step context is passed INLINE via instructions, NOT read from disk. This is because STEP.md files haven't been written to disk yet during initial blueprint -- they're written during Write Gameplan. The researcher receives all step information via the `<step_context>` and `<decisions>` tags in instructions.

### Failure Handling

If a researcher fails or returns an error:
- Log the failure silently
- Continue with remaining steps -- one step's research failure should not block the entire blueprint
- Note in the Write Gameplan phase that this step has no RESEARCH.md (the planner proceeds without it)

### Conflict Detection

After ALL researchers for a goal complete, read each newly-written RESEARCH.md and check the "Conflicts with User Decisions" section.

If any HIGH-severity conflicts are found, present them ONE AT A TIME to the user:

> "While looking into [step name], I noticed something about your choice of [decision]: [conflict in plain language]. Want to keep your original choice, or would you like to change it?"

Wait for user response:
- If they keep the decision: note "User confirmed despite conflict" in the RESEARCH.md Metadata section and proceed.
- If they update the decision: note the change, update the decision context, and re-research the step if the changed decision significantly affects the research domain.

If no HIGH-severity conflicts: proceed silently to Write Gameplan.

Conflict criteria (strict -- avoid being too aggressive):
- A conflict is ONLY: deprecation, security vulnerability, incompatibility between locked choices, or a major pitfall with no reasonable mitigation
- A concern is NOT a conflict: alternative approaches exist, newer versions available, stylistic preferences differ from recommendation

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

  ## Decisions

  ### Locked
  - [Decision from conversation]

  ### Flexible
  - [Area where builder can choose -- with context]

  ### Deferred
  - [Item explicitly set aside]
  ```

  **Note:** Only include the Decisions section if the "Capture Step-Level Decisions" step identified relevant decisions for this step. Omit the entire section (including the ## Decisions heading) if there are no decisions. Only include categories (Locked, Flexible, Deferred) that have items -- omit empty categories.

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

**Research-informed task writing:**

When writing task files for a step, check if a `RESEARCH.md` exists in the step directory (produced by Step-Level Research above). If it exists, read it and use the research findings to:
- Improve task descriptions with specific library/tool mentions from the Stack section
- Add relevant pitfalls to the "Done When" criteria
- Adjust task sizing based on research complexity findings
- Include "Don't Hand-Roll" items as constraints in relevant tasks
- Prefer the recommended approach for Flexible decision areas

The planner reads RESEARCH.md on demand -- it is NOT force-injected into context. This keeps context manageable and lets the planner decide which sections are relevant for each task.

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

## Update Mode

This section applies when the project already has a gameplan with real content (UPDATE mode detected above). The update flow re-evaluates the entire gameplan holistically, presents what changed, gets explicit approval, and writes updated files -- all while keeping completed work safe.

### Handle Arguments (Update Mode)

If `$ARGUMENTS` is non-empty, acknowledge it as the focus for this update:

> "You want to [arguments]. Let me look at your current gameplan and see how that fits in."

Use the inline text as the primary context for what changed, but still re-evaluate the gameplan holistically. Even a focused request like "add payment processing" may affect ordering, grouping, or other parts of the plan.

If `$ARGUMENTS` is empty, ask what prompted the update:

> "What's changed? New features to add, something to reorganize, or just want to review the plan?"

Wait for the user's response before continuing.

### Load Existing Gameplan

Read the current state of the gameplan:

1. **Read `.director/GAMEPLAN.md`** for the overview -- goals listed, current focus, general structure.
2. **Scan the `.director/goals/` directory** to understand the full structure: read each GOAL.md, STEP.md, and task files to build a picture of what exists.
3. **Identify completed work** -- any goals, steps, or tasks that are marked as done or complete in their Status sections. These are FROZEN and will not be touched.
4. **Identify pending work** -- goals, steps, and tasks that are still in progress or not started. These may be modified, reordered, or removed during the update.

### Check Context Freshness (Update Mode)

Before loading research context, check whether the project's research and codebase analysis files are still current. Follow the same logic as the "Check Context Freshness" section in the new gameplan flow:

1. Read `.director/config.json` and extract `context_generation.completed_goals_at_generation` (default to 0 if the field does not exist).
2. Count current completed goals from `.director/goals/`.
3. If delta >= 2: show the non-blocking staleness alert.
4. If delta < 2: proceed silently.

After the check (or skip), continue to Load Research Context below.

### Load Research Context (Update Mode)

Read `.director/research/SUMMARY.md` silently using `cat .director/research/SUMMARY.md 2>/dev/null`.

If the file exists and has content, store its contents internally wrapped in a `<research_summary>` tag:

```
<research_summary>
[Contents of SUMMARY.md]
</research_summary>
```

Use research findings to inform re-evaluation of goals -- the same way research informs initial planning:
- Check whether existing goals align with research-recommended patterns
- Consider research insights when proposing goal modifications or additions
- Reference "Don't Hand-Roll" warnings when adjusting task sizing

If the file does not exist or is empty, proceed silently. Do NOT mention missing research to the user or agent. Do NOT include an empty `<research_summary>` tag.

### Freeze Completed Work

Goals, steps, or tasks that are already done are FROZEN during updates. They are never removed, reordered, or modified.

If new context from the user would logically require changes to completed work, flag it conversationally:

> "[Completed item] was already finished, but [new requirement] might need some adjustments to it. Want to add a task for that?"

Do NOT silently remove or modify completed items. The user must explicitly agree to any work that revisits something already done.

### Check for Open Questions

Before re-evaluating, scan VISION.md for `[UNCLEAR]` markers, just as in new gameplan mode. Present any found and offer to resolve or defer them.

### Re-evaluate and Generate Updated Goals

Read the full content of VISION.md to understand the current vision state. Compare the existing goals against the vision plus any new context from the user (via `$ARGUMENTS` or the conversation).

Generate an updated goal set following the same Planning Rules from the new gameplan flow (Rule 1 through Rule 6 still apply).

Present updated goals together, highlighting what changed:

> Here's how I'd update your goals:
>
> 1. **[Existing goal -- unchanged]** -- [Same description]
> 2. **[Modified goal]** -- [Updated description] *(was: [old description])*
> 3. **[New goal]** -- [Why this was added]
>
> [If any goals are being removed:]
> I'd suggest removing **[goal name]** because [reason].
>
> [If completed goals exist:]
> Already done: **[completed goal]** -- keeping as-is.
>
> What do you think?

Wait for the user's response. If they give feedback (add, remove, rename, reorder), adjust the goal set and re-present. Iterate until the user approves.

**Important:** Do NOT generate the updated Steps and Tasks yet. Goal changes must be approved first -- same two-phase flow as new gameplan mode.

### Generate Updated Hierarchy

After the user approves the updated goals, generate the full updated Steps and Tasks.

For each goal in the approved set:

- **Completed goals:** Keep all steps and tasks exactly as they are. Do not modify, reorder, or remove anything inside a completed goal.
- **Pending/modified goals:** Generate updated Steps and Tasks following the Planning Rules. Existing pending items may be reordered, modified, or removed. New items are added where they fit.
- **New goals:** Generate Steps and Tasks from scratch, same as new gameplan mode.

Order everything following vertical slices (Rule 6) and what's needed first (Rule 4). Re-evaluate which tasks are "Ready" based on the updated structure -- new work may change what's ready and what's blocked.

### Present Delta Summary

Before showing the full updated outline, present a delta summary so the user can see exactly what changed:

> Here's what I'd change:
>
> **Added:**
> - [New item with explanation of why]
>
> **Changed:**
> - [Modified item: was X, now Y, because Z]
>
> **Removed:**
> - [Removed item with reasoning]
>
> **Reordered:**
> - [Item moved: was in Step X, now in Step Y, because Z]
>
> **Already done (keeping as-is):**
> - [Completed items preserved]

Every removal must be explicitly stated with reasoning. No silent deletions.

The "Already done" section reassures the user that completed work is safe. Always include it, even if just to say "Nothing completed yet."

After the delta summary, present the full updated outline (same format as new gameplan mode -- goals, steps, tasks with one-line descriptions and size indicators):

> Here's the complete updated gameplan:
>
> **Goal 1: [Goal Name]** [done]
>
>   Step 1: [Step name] [done]
>     - [Task name] (size) -- Done
>
> **Goal 2: [Goal Name]** [updated]
>
>   Step 1: [Step name]
>     - [Task name] (size) -- Ready
>     - [New task name] (size) -- Needs [capability]
>
>   Step 2: [New step name]
>     - [Task name] (size) -- Needs [capability]
>
> **Goal 3: [Goal Name]** [new]
>
>   Step 1: [Step name]
>     - [Task name] (size) -- Needs [capability from Goal 2]
>
> Does this look good?

Wait for explicit approval. If the user gives feedback, adjust and re-present. Iterate until they approve.

**Important:** Do NOT write any files until the user explicitly approves this outline.

### Write Updated Files

After the user approves the full updated outline, write the updated gameplan files.

**Rewrite `.director/GAMEPLAN.md`** with the updated overview, goals list, and current focus (same format as new gameplan mode).

**For each goal, step, and task in the approved outline:**

- **Completed items:** Do not touch their files. Leave them exactly as they are.
- **Modified items:** Overwrite the existing GOAL.md, STEP.md, or task file with updated content.
- **New items:** Create new directories and files following the same naming conventions (zero-padded numbers, kebab-case slugs).
- **Removed items:** Delete the files and directories. But NEVER delete files for completed items -- if something is marked done, it stays regardless of what the updated plan says.

**Step-Level Research in Update Mode:**

Before writing updated files, step-level research runs for pending/new steps following the same logic as initial blueprint (see Step-Level Research section above). The following rules apply:
- **Completed steps:** FROZEN -- their RESEARCH.md files are not touched, no re-research.
- **Unchanged pending steps:** Smart reuse applies -- if RESEARCH.md exists and inputs match, skip research.
- **Modified pending steps:** Re-research if inputs (step scope or decisions) changed significantly.
- **New steps:** Research from scratch if complexity warrants it.
- `--research` flag forces fresh research for all pending/new steps (not completed steps).
- `--skip-research` flag skips all step-level research during this update.

Use the same file templates and directory structure as new gameplan mode. Use Bash for `mkdir -p` to create directories and the Write tool for file content. Do NOT narrate each file path or operation to the user.

### Update Decisions in Modified Steps

When running in update mode:

1. **Completed steps:** Their Decisions sections are FROZEN. Do not modify, add, or remove decisions in completed steps, just as completed steps' tasks and content are frozen.

2. **Modified/pending steps:** Review the update conversation for new decisions. Merge new decisions with any existing decisions in the step's current STEP.md:
   - Add new Locked/Flexible/Deferred items from the update conversation.
   - If the user contradicted a previous decision (e.g., was "use SQLite", now says "switch to PostgreSQL"), update the Locked decision to reflect the new choice.
   - If the user deferred something that was previously Locked, move it to Deferred.

3. **New steps:** Capture decisions from the update conversation the same way as new gameplan mode.

Apply the same passive extraction approach -- do NOT ask the user to enumerate decisions for the update. Extract from the natural conversation.

### Update Mode Wrap-Up

After all files are written, tell the user conversationally:

> "Your gameplan is updated. [Brief summary of what changed -- e.g., 'Added 2 new steps for payment processing and moved the settings page after the dashboard.']"

Do NOT list file paths, directory structures, or technical details.

### Suggest Next Step (Update Mode)

After the wrap-up, suggest the next action:

> "Ready to keep building? You can pick up where you left off with `/director:build`."

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
