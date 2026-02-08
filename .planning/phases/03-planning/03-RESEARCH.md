# Phase 3: Planning - Research

**Researched:** 2026-02-08
**Domain:** Claude Code skill orchestration, gameplan decomposition, dependency-aware planning, conversational review workflows
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

#### Planning conversation flow
- Interactive breakdown: blueprint works through the vision, generating Goals first for user review before filling in Steps and Tasks
- User reviews all proposed goals together (not one at a time), then approves the set or gives conversational feedback to adjust
- After goal approval, Steps and Tasks are generated without additional pause points
- Even with inline text (`/director:blueprint "add payment processing"`), goals are still shown for review before proceeding
- Approval at goal level only -- Steps and Tasks are Claude's domain once goals are locked

#### Gameplan presentation & review
- Full outline view: show the complete hierarchy (Goals > Steps > Tasks) with one-line descriptions at every level
- Dependencies shown in plain language on each task: "Needs user login first"
- User adjusts the gameplan through conversational feedback ("move auth before the dashboard", "split this into two steps") -- not by editing files
- Explicit approval required: blueprint asks "Does this look good?" and waits for a clear yes before writing files

#### Update mode behavior
- Holistic re-evaluation: when updating (even with scoped inline text), re-evaluate the entire gameplan in light of new context -- additions may affect ordering, dependencies, or grouping elsewhere
- Changes communicated via delta summary: "Added 2 tasks, removed 1 step, reordered Goal 2" -- user sees exactly what changed
- Same explicit approval flow as initial creation: show delta summary, ask for confirmation before saving
- Completed work handling: Claude's discretion (safest approach for preserving done work)

### Claude's Discretion
- How completed work is handled during updates (frozen vs. reorganizable)
- Step and Task decomposition within approved goals
- Dependency graph construction and ordering logic
- Complexity indicators (small/medium/large) assignment
- Verification criteria generation per task

### Deferred Ideas (OUT OF SCOPE)
None -- discussion stayed within phase scope
</user_constraints>

## Summary

Phase 3 transforms the placeholder blueprint skill into Director's functional gameplan creation and update workflow. The user runs `/director:blueprint`, and Director reads VISION.md, breaks the vision into Goals > Steps > Tasks, presents the plan for interactive review, and writes the approved gameplan to `.director/GAMEPLAN.md` and the `goals/` directory hierarchy.

The primary architectural decision is whether the blueprint skill runs the planning inline (as the onboard skill does with the interview) or spawns the planner agent as a sub-agent. The evidence strongly favors the **inline approach**: the blueprint workflow requires multi-turn conversation with the user (goal review, feedback, approval), and the user's locked decision specifies interactive goal-level review before proceeding. The planner agent's system prompt (`agents/director-planner.md`) serves as the planning rules reference -- Claude follows those rules directly within the skill, just as the onboard skill follows the interviewer agent's rules directly. File writing happens in the main skill context (the planner agent has `disallowedTools: Write, Edit`).

The conversation flow has a clear two-phase structure: (1) generate and review Goals with the user, (2) after goal approval, generate the full Steps and Tasks hierarchy without additional pause points, present the complete outline, get final approval, then write all files. Update mode follows the same pattern but adds holistic re-evaluation of the existing gameplan and a delta summary showing what changed.

**Primary recommendation:** Rewrite `skills/blueprint/SKILL.md` to orchestrate the full planning workflow inline (no `context: fork`), following the planner agent's rules as reference content. The skill generates Goals first for user review, then fills in Steps and Tasks after approval, presents the full hierarchy, gets explicit approval, and writes GAMEPLAN.md plus the `goals/` directory structure.

## Standard Stack

This phase has no traditional software stack. It modifies existing plugin files (Markdown, YAML, shell scripts).

### Core

| Component | Format | Purpose | Why Standard |
|-----------|--------|---------|--------------|
| `skills/blueprint/SKILL.md` | Markdown + YAML frontmatter | Orchestrates the planning workflow | Claude Code skill system -- the skill IS the workflow |
| `agents/director-planner.md` | Markdown + YAML frontmatter | Planning rules reference (not spawned as sub-agent) | Already defined in Phase 1 with complete rules |
| `skills/blueprint/templates/gameplan-template.md` | Markdown | Template for GAMEPLAN.md | Already defined in Phase 1 |
| `skills/blueprint/templates/goal-template.md` | Markdown | Template for GOAL.md files | Already defined in Phase 1 |
| `skills/blueprint/templates/step-template.md` | Markdown | Template for STEP.md files | Already defined in Phase 1 |
| `skills/blueprint/templates/task-template.md` | Markdown | Template for task files | Already defined in Phase 1 |

### Supporting

| Component | Format | Purpose | When to Use |
|-----------|--------|---------|-------------|
| `reference/terminology.md` | Markdown | Director vocabulary rules | Always -- every user-facing message |
| `reference/plain-language-guide.md` | Markdown | Communication tone rules | Always -- every user-facing message |
| `reference/context-management.md` | Markdown | XML boundary tag standards | When assembling context for sub-agents (if researcher is spawned) |
| `scripts/init-director.sh` | Markdown | Creates `.director/` structure including `goals/` directory | Already handles init -- no changes needed |

### What NOT to Change

| Component | Why Not |
|-----------|---------|
| `agents/director-planner.md` | Already complete with 6 planning rules, complexity indicators, dependency language, update mode, and output format. Used as reference rules, not spawned. Do not modify. |
| `agents/director-researcher.md` | Already complete. May be spawned as sub-agent during blueprint, but its definition needs no changes. |
| `skills/onboard/SKILL.md` | Phase 2 output. Not modified in Phase 3. |
| `scripts/init-director.sh` | Already creates `.director/goals/` directory. No changes needed. |
| Other skills | Out of scope. Their routing stubs from Phase 1 remain unchanged. |

## Architecture Patterns

### Recommended File Structure (What Gets Written)

```
.director/
├── GAMEPLAN.md              # Overview: all goals listed, current focus
├── goals/
│   ├── 01-[goal-name]/
│   │   ├── GOAL.md           # Goal description, success criteria, steps list
│   │   ├── 01-[step-name]/
│   │   │   ├── STEP.md       # Step description, tasks list, needs first
│   │   │   └── tasks/
│   │   │       ├── 01-[task-name].md   # Full task with all 5 fields
│   │   │       └── 02-[task-name].md
│   │   └── 02-[step-name]/
│   │       ├── STEP.md
│   │       └── tasks/
│   │           └── ...
│   └── 02-[goal-name]/
│       ├── GOAL.md
│       └── ...
```

### Pattern 1: Inline Skill Orchestration with Two-Phase Flow

**What:** The blueprint skill runs inline in the main conversation, following a two-phase process: (1) generate and review Goals with the user, (2) generate full hierarchy after goal approval.

**When to use:** This is the only approach for Phase 3. The user's locked decision requires interactive goal-level review.

**Why inline (not sub-agent):** Same reasoning as onboarding (Phase 2): the workflow requires multi-turn conversation with the user (goal review, feedback, adjustment). Spawning the planner as a sub-agent would isolate the planning from the conversation. The planner agent has `disallowedTools: Write, Edit`, so file writing must happen in the main skill context anyway.

**Flow:**
```
1. Read VISION.md
2. Determine mode (new gameplan vs. update)
3. Handle $ARGUMENTS if provided
4. Generate proposed Goals (outcomes, not activities)
5. Present goals to user for review (all at once, not one at a time)
6. User gives conversational feedback or approves
7. Iterate until user approves goal set
8. Generate Steps within each goal (ordered by dependencies)
9. Generate Tasks within each step (with all 5 required fields)
10. Present full outline: Goals > Steps > Tasks with one-line descriptions
11. Ask "Does this look good?" and wait for explicit approval
12. On approval: write GAMEPLAN.md, create goals/ directory structure
13. Suggest next step: /director:build
```

### Pattern 2: Goal Generation as Outcomes

**What:** Goals describe what the user will HAVE when complete, not what to DO. This comes directly from the planner agent's Rule 1.

**When to use:** Every time goals are generated.

**Examples from planner agent:**
- Good: "Users can sign up, log in, and manage their accounts"
- Good: "The dashboard shows real-time data with filters and search"
- Bad: "Build authentication system" (activity, not outcome)
- Bad: "Implement Stripe integration" (developer jargon)

**Application to gameplan output:**
```markdown
## Goals

1. **Users can sign up, log in, and manage their profiles** -- The foundation that everything else builds on
2. **The dashboard shows habits with streaks and progress charts** -- The core experience users come back to every day
3. **Reminders go out on schedule and users can customize them** -- Keeps users engaged without being annoying
```

### Pattern 3: Vertical Slice Ordering

**What:** Steps are ordered as vertical slices (complete features one at a time) rather than horizontal layers (all database models, then all APIs, then all UI). This comes directly from the planner agent's Rule 6.

**When to use:** When ordering Steps within a Goal.

**Good order (vertical slices):**
1. Complete login flow (database + API + UI for login)
2. Complete signup flow (database + API + UI for signup)
3. Complete profile page (database + API + UI for profiles)

**Bad order (horizontal layers):**
1. Create all database models
2. Create all API routes
3. Create all UI pages

### Pattern 4: Task Fields (Five Required)

**What:** Every task includes exactly five fields as defined in the task template and PLAN-04 requirement.

**Fields:**
1. **What To Do** -- Plain-language description
2. **Why It Matters** -- Connection to the bigger picture
3. **Size** -- Small, medium, or large (effort indicator, not time estimate)
4. **Done When** -- Specific verification criteria as checklist items
5. **Needs First** -- Prerequisites in plain language ("Needs the user database set up first")

These map exactly to the existing `skills/blueprint/templates/task-template.md`.

### Pattern 5: Capability-Based Dependencies

**What:** Dependencies are expressed as capabilities the project must have, not as task IDs or technical identifiers.

**When to use:** In both the GAMEPLAN.md overview and individual task files.

**Never say:** "Depends on TASK-03" or "Blocked by AUTH-01"
**Always say:** "Needs the user database set up first" or "Needs the login page built first"

This aligns with the planner agent's Dependency Language rules and Director's terminology standards (never-use words include "dependency", "blocker", "prerequisite").

### Pattern 6: Ready-Work Filtering

**What:** Mark tasks as "ready" when everything they need is already complete. The gameplan presentation makes it clear which tasks can be started right now.

**When to use:** In the full outline view presented to the user.

**Implementation in GAMEPLAN.md:**
- Tasks with no prerequisites or all prerequisites satisfied: marked "Ready"
- Tasks with unmet prerequisites: show what they need in plain language

Note: PLAN-05 requires ready-work filtering, but full runtime filtering (which tasks are dynamically ready based on STATE.md) is a Phase 4 concern. Phase 3 establishes the static dependency information that Phase 4's `/director:build` uses for runtime filtering.

### Pattern 7: Gameplan Update with Delta Summary

**What:** When updating an existing gameplan, perform holistic re-evaluation and present changes as a delta summary.

**When to use:** When GAMEPLAN.md already has content (not just the init template).

**Flow for updates:**
```
1. Read existing GAMEPLAN.md and goals/ directory
2. Read VISION.md for current vision
3. If $ARGUMENTS provided, use as focus area
4. Re-evaluate entire gameplan in light of new context
5. Determine what changed (added, modified, removed, reordered)
6. Present delta summary to user:
   "Here's what I'd change:
    - Added: 2 new tasks in Step 3 for payment processing
    - Removed: Step 4 (dark mode) -- moved to Goal 2 instead
    - Reordered: Auth now comes before the dashboard"
7. Get explicit approval before saving
8. Preserve completed work (see Claude's Discretion section)
9. Write updated files
```

**Delta format aligns with brownfield onboarding pattern:** The onboarding phase already uses Existing/Adding/Changing/Removing labels. Blueprint updates use a similar pattern: Added/Changed/Removed/Reordered.

### Pattern 8: Completed Work Handling (Claude's Discretion)

**What:** When updating a gameplan that has completed work, freeze completed items by default. This is the safest approach.

**Recommendation:** Treat completed goals, steps, and tasks as frozen during updates:
- Never remove or modify items marked as done
- New work integrates around completed work
- If a completed item needs to be revisited, flag it for the user: "This was already built, but the new direction might need changes to it. Want to add a task to update it?"

This aligns with the planner agent's Update Mode Rule 1: "Preserve completed work. Never remove or modify items marked as done."

### Anti-Patterns to Avoid

- **Spawning the planner as a sub-agent for interactive planning:** The planner has `disallowedTools: Write, Edit` and the workflow requires multi-turn user conversation. The skill runs inline, using the planner agent's rules as reference. Reserve the Task tool for the researcher agent (non-interactive investigation).
- **Generating the full hierarchy before showing goals:** The user's locked decision requires goal-level review FIRST. Do not generate Steps and Tasks before goals are approved -- this wastes work if the user wants to restructure goals.
- **Asking approval for each goal individually:** The user's locked decision says "reviews all proposed goals together (not one at a time)." Present the complete goal set for holistic review.
- **Generating goals as activities:** Goals must be outcomes ("Users can...") not activities ("Build..."). Follow the planner agent's Rule 1.
- **Using task IDs in dependencies:** Never "Depends on TASK-03." Always "Needs the user database set up first."
- **Writing files before explicit approval:** The user's locked decision requires "Does this look good?" and waiting for a clear yes before writing.
- **Overwriting completed work during updates:** Completed goals/steps/tasks are frozen. New work integrates around them.
- **Presenting the gameplan with developer jargon:** Follow terminology.md strictly. No "dependencies," "milestones," "epics," "blockers."

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Planning rules and heuristics | Custom planning algorithm | Planner agent's rules loaded as reference in SKILL.md | The planner agent already has 6 comprehensive rules, complexity indicators, dependency language, and update mode. Claude follows these naturally. |
| Task template rendering | Template engine or string replacement | Claude generates task content directly following template structure | Claude is the template engine. Show it the structure, it fills it in. Same pattern as VISION.md generation in Phase 2. |
| Dependency ordering | Graph algorithm or topological sort | Claude's reasoning about what needs to happen first | Claude understands logical ordering. "Login page needs database" is natural reasoning, not graph theory. The planner agent's Rule 4 handles this. |
| Ready-work detection (static) | Complex status checking system | Simple text markers in task files ("Nothing -- this can start right away" vs. "Needs X first") | Phase 3 establishes static dependency info. Dynamic runtime filtering is Phase 4. |
| Directory structure creation | Custom directory builder | Claude uses Bash mkdir and Write tool directly | The skill instructions tell Claude exactly what to create. No utility needed. |
| Delta calculation for updates | Diff algorithm | Claude reads old gameplan and new vision, reasons about what changed | This is natural language comparison, not file diffing. Claude handles this well with the planner agent's Update Mode rules. |

**Key insight:** The planning workflow is a structured conversation, not a program. Claude follows the planner agent's rules naturally. The SKILL.md provides the orchestration flow (when to ask the user, when to generate, when to write); the planner rules provide the planning intelligence (how to decompose, how to order, how to express dependencies). This is the same pattern as Phase 2's onboarding: the skill orchestrates, Claude's intelligence does the actual work.

## Common Pitfalls

### Pitfall 1: GAMEPLAN.md Template Detection Fails

**What goes wrong:** The init script creates a GAMEPLAN.md with template text (`> This file will be populated when you run /director:blueprint`). If detection logic only checks for one specific phrase, it could miss edge cases where the user partially edited the template.
**Why it happens:** Same class of problem as VISION.md detection in Phase 2.
**How to avoid:** Detection logic should check for multiple signals: the specific init template phrase, the absence of goal definitions, or the presence of placeholder text like `_No goals defined yet_`. If GAMEPLAN.md has real goal content under headings (not just template text), treat as update mode.
**Warning signs:** Blueprint creates a new gameplan on top of an existing one, losing previous goals.

### Pitfall 2: Goals Generated as Activities Instead of Outcomes

**What goes wrong:** Claude generates goals like "Build authentication system" or "Create dashboard" instead of outcome-oriented goals like "Users can sign up, log in, and manage their accounts."
**Why it happens:** Activity-oriented goals are the default for most AI planning. The planner agent rules address this, but if the skill doesn't emphasize it, Claude may revert to default behavior.
**How to avoid:** The SKILL.md must explicitly include the planner's Rule 1 (goals are outcomes, not activities) with examples. Include good and bad examples directly in the skill instructions, not just by reference.
**Warning signs:** Goals start with verbs like "Build", "Create", "Implement", "Set up" instead of describing what users can do.

### Pitfall 3: Horizontal Layer Ordering Instead of Vertical Slices

**What goes wrong:** Steps are ordered as "1. Set up database, 2. Build API routes, 3. Create UI pages" instead of feature-by-feature vertical slices.
**Why it happens:** Horizontal layering is the default for most planning approaches. Without explicit guidance, Claude will organize by technical layer.
**How to avoid:** Include the planner's Rule 6 (prefer vertical slices) with good and bad examples in the SKILL.md. Frame it as "Build complete features one at a time so users see working results sooner."
**Warning signs:** Steps like "Database setup", "API layer", "Frontend components" -- these are layers, not features.

### Pitfall 4: Full Hierarchy Generated Before Goal Approval

**What goes wrong:** Claude eagerly generates the entire Goals > Steps > Tasks hierarchy in one pass, then presents it all for review. If the user wants to change the goals, all the Step and Task work is wasted.
**Why it happens:** It's natural to want to present the complete plan. The locked decision explicitly requires goals-first review.
**How to avoid:** The SKILL.md must enforce the two-phase flow: (1) generate and present ONLY goals for review, (2) after approval, generate Steps and Tasks. This prevents wasted computation and gives the user control at the right level.
**Warning signs:** The first presentation includes Steps and Tasks before the user has approved the goals.

### Pitfall 5: $ARGUMENTS Ignored in Update Mode

**What goes wrong:** User runs `/director:blueprint "add payment processing"` but the update treats it as a full re-evaluation without focusing on payments.
**Why it happens:** The inline text needs to be threaded into the planning context. If the skill doesn't explicitly use $ARGUMENTS as a focus area, it gets lost.
**How to avoid:** In update mode, if $ARGUMENTS is non-empty, use it as the primary context for what changed. Start by acknowledging: "You want to add payment processing. Let me look at how that fits into your current gameplan." Then re-evaluate with that focus. The holistic re-evaluation still happens (locked decision), but the inline text provides the starting point.
**Warning signs:** User provides specific context but gets a generic re-evaluation with no acknowledgment of their input.

### Pitfall 6: Conversational Tone Breaks During File Operations

**What goes wrong:** After a natural planning conversation, Claude switches to technical language when writing files: "Creating directory .director/goals/01-mvp/01-foundation/tasks/..."
**Why it happens:** Default Claude behavior is to narrate file operations. Multiple directory creation and file writes amplify this.
**How to avoid:** The SKILL.md must explicitly instruct Claude to keep the tone conversational during the file writing phase. Instead of narrating each file operation, say "Your gameplan is saved. Here's a quick overview of what I created:" followed by a brief summary. Same pattern as Phase 2's "Your vision is saved."
**Warning signs:** Messages listing file paths, mkdir commands, or technical operations during what should feel like a simple "done" message.

### Pitfall 7: Update Mode Silently Removes Items

**What goes wrong:** During a gameplan update, existing goals or tasks disappear without explanation.
**Why it happens:** When re-evaluating holistically, Claude might restructure and accidentally drop items.
**How to avoid:** The planner agent's Update Mode Rule 3 says "Mark removed items explicitly. If something is being removed, say so and explain why -- don't silently delete." The delta summary (locked decision) must list every removal with reasoning. The SKILL.md should enforce: "Before writing, verify every existing item is either preserved, explicitly modified, or explicitly removed with explanation."
**Warning signs:** User approves an update and later discovers missing goals/steps they didn't agree to remove.

### Pitfall 8: Vision Has [UNCLEAR] Markers That Block Planning

**What goes wrong:** VISION.md contains [UNCLEAR] markers from onboarding. The planner tries to plan around these ambiguities without flagging them.
**Why it happens:** [UNCLEAR] markers are meant to be resolved before or during planning. If the skill doesn't check for them, planning proceeds with gaps.
**How to avoid:** Before generating goals, scan VISION.md for [UNCLEAR] markers. If found, present them to the user: "I noticed some open questions in your vision. Let's resolve these before planning." Address each one, then proceed. If the user wants to defer them, note that affected tasks may need adjustment later.
**Warning signs:** Tasks are generated for features that have [UNCLEAR] markers, leading to ambiguous task descriptions.

## Code Examples

### Example 1: Blueprint SKILL.md Two-Phase Flow

```yaml
# Source: Based on Phase 2 onboard SKILL.md pattern + planner agent rules
---
name: blueprint
description: "Create, view, or update your project gameplan. Breaks your vision into Goals, Steps, and Tasks."
---

# Director Blueprint

First, check if `.director/` exists. If not, run init silently:
!`bash "${CLAUDE_PLUGIN_ROOT}/scripts/init-director.sh" 2>/dev/null`

Say only: "Director is ready." Then continue below.

## Determine Project State

Read `.director/VISION.md` and check whether it has real content...

**If VISION.md is empty or still the default template:**
[Route to onboard conversationally -- already implemented in Phase 1]

**If VISION.md has content, read `.director/GAMEPLAN.md`:**

Check if GAMEPLAN.md has real content (actual goal definitions, not just template text).
- Template text includes: "This file will be populated when you run /director:blueprint"
  and "_No goals defined yet_"
- If template only -> NEW gameplan mode
- If real content -> UPDATE mode

## Handle Arguments

If $ARGUMENTS is non-empty, acknowledge it:
- New mode: "You want to focus on [arguments]. Let me read your vision and create a gameplan."
- Update mode: "You want to [arguments]. Let me see how that fits into your current gameplan."

## Phase 1: Generate and Review Goals

[Planning rules from planner agent loaded here as reference content]
[Generate goals as outcomes, present all together, iterate with user]

## Phase 2: Generate Full Hierarchy

[After goal approval, generate Steps and Tasks without pause points]
[Present full outline, get final approval]

## Write Gameplan

[Write GAMEPLAN.md and goals/ directory structure]
[Conversational file operation language]

## Suggest Next Step

"Ready to start building? You can do that with `/director:blueprint`."

$ARGUMENTS
```

### Example 2: Goal Presentation Format

```markdown
Based on your vision, here are the goals I'd suggest:

1. **Users can sign up, log in, and manage their profiles** -- This is the
   foundation everything else builds on. Without accounts, nothing else works.

2. **Users can create, track, and complete daily habits** -- This is the core
   of what your app does. It's what users come back for every day.

3. **The dashboard shows streaks, stats, and progress over time** -- This is
   what makes your app sticky. Users can see how they're doing at a glance.

Does this feel right? Want to add, remove, or rearrange anything?
```

### Example 3: Full Outline Presentation

```markdown
Here's the complete gameplan:

**Goal 1: Users can sign up, log in, and manage their profiles**

  Step 1: Login and signup flow
    - Set up user database (small) -- Ready
    - Build signup page with form validation (medium) -- Needs user database
    - Build login page (medium) -- Needs user database
    - Add password reset flow (small) -- Needs login page

  Step 2: User profiles
    - Build profile page showing user info (medium) -- Needs login
    - Add profile editing (small) -- Needs profile page
    - Add avatar upload (medium) -- Needs profile page

**Goal 2: Users can create, track, and complete daily habits**

  Step 1: Habit management
    - Build habit creation form (medium) -- Needs user accounts
    - Build habit list view (small) -- Needs habit creation
    - Add habit editing and deletion (small) -- Needs habit list

  ...

Does this look good? Want to change the order, add anything, or remove anything?
```

### Example 4: GAMEPLAN.md Output Format

```markdown
# Gameplan

## Overview

HabitTracker helps users build and maintain daily habits with streaks, stats,
and reminders. We're building this in 3 goals, starting with the foundation
(accounts and profiles) and working up to the full experience.

## Goals

1. **Goal 1: Users can sign up, log in, and manage their profiles** -- The
   foundation that everything else builds on
2. **Goal 2: Users can create, track, and complete daily habits** -- The core
   experience users come back to every day
3. **Goal 3: Reminders go out on schedule and users can customize them** --
   Keeps users engaged without being annoying

## Current Focus

**Current Goal:** Goal 1
**Current Step:** Step 1 (Login and signup flow)
**Next Up:** User profiles (Step 2)
```

### Example 5: Task File Output Format

```markdown
# Task: Build signup page with form validation

## What To Do

Create a signup page where users enter their email and password to create an
account. The form should validate that the email looks real and the password
meets basic requirements (at least 8 characters). Show clear error messages
when something is wrong.

## Why It Matters

This is how users get into the app. Without signup, nobody can use anything
else. A good signup experience makes a strong first impression.

## Size

**Estimate:** medium

This touches the signup page, form validation logic, and connecting to the
user database. A few files, a few decisions about validation rules.

## Done When

- [ ] Signup page loads and shows email and password fields
- [ ] Invalid email shows a clear error message
- [ ] Short password shows a clear error message
- [ ] Successful signup creates a user in the database
- [ ] User is redirected to the app after signup

## Needs First

Needs the user database set up first (Task 1 in Step 1).
```

### Example 6: Update Mode Delta Summary

```markdown
I've looked at your gameplan with the payment processing in mind. Here's
what I'd change:

**Added:**
- New Step 3 in Goal 2: "Payment processing"
  - Task: Set up Stripe checkout (medium)
  - Task: Build pricing page (small)
  - Task: Handle payment webhooks (medium)
  - Task: Add receipt emails (small)

**Changed:**
- Goal 2 renamed: was "Users can create and manage habits" →
  now "Users can create, manage, and pay for premium habits"
- Step 2 reordered: moved after the new payment step (premium
  features need payment first)

**Removed:**
- Nothing removed

**Already done (keeping as-is):**
- Goal 1: Complete -- all 7 tasks done
- Goal 2, Step 1: Complete -- habit CRUD working

Does this look right? Want to adjust anything before I save it?
```

### Example 7: Directory Creation Pattern

```markdown
## Write Gameplan

After the user approves, write the gameplan files. Create the directory
structure and files in this order:

1. Write `.director/GAMEPLAN.md` with the overview
2. For each goal:
   a. Create the goal directory: `.director/goals/NN-goal-name/`
   b. Write `GOAL.md` in the goal directory
   c. For each step in the goal:
      i. Create the step directory: `.director/goals/NN-goal/NN-step-name/`
      ii. Write `STEP.md` in the step directory
      iii. Create the tasks directory: `.director/goals/NN-goal/NN-step/tasks/`
      iv. Write each task file: `NN-task-name.md`

Use Bash to create directories and the Write tool to create files.

Keep file operations quiet -- don't narrate each one. After all files
are written, say something like:

> "Your gameplan is saved. I created [N] goals with [M] steps and [T]
> tasks total. You can browse the full plan in `.director/goals/` if
> you're curious, but Director handles everything from here."
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Placeholder blueprint skill with "coming soon" | Functional gameplan creation with interactive review | Phase 3 (this phase) | Users go from vision to complete gameplan through conversation |
| Single GAMEPLAN.md template | Full goals/ directory hierarchy with individual files | Phase 3 (this phase) | Each goal, step, and task has its own file for fresh agent context in Phase 4 |
| No update capability | Holistic re-evaluation with delta summary | Phase 3 (this phase) | Users can evolve their gameplan without starting over |

## Discretionary Decisions (Recommendations)

These are areas marked as "Claude's Discretion" in CONTEXT.md. Here are research-backed recommendations:

### Completed Work Handling During Updates

**Recommendation: Freeze completed work by default.**

Rationale: The planner agent's Update Mode Rule 1 already says "Preserve completed work. Never remove or modify items marked as done." This is the safest approach. If new context requires changes to completed work, flag it for the user rather than silently modifying: "The login page was already built, but adding OAuth might need some changes to it. Want to add a task for that?"

### Step and Task Decomposition

**Recommendation: Follow planner agent rules directly.**

- Steps are verifiable chunks of work (planner Rule 2) -- each delivers something the user can see
- Tasks are single-sitting work units (planner Rule 3) -- can be completed in one focused session
- Prefer vertical slices over horizontal layers (planner Rule 6)
- Target 2-5 steps per goal and 2-7 tasks per step (keeps scope manageable for fresh agent windows in Phase 4)

### Dependency Graph Construction

**Recommendation: Use natural language reasoning, not formal graph algorithms.**

Claude reasons about what needs to happen first naturally. The planner agent's Rule 4 handles this: "If the login page needs user accounts in the database, the database setup comes before the login page." Express as capabilities: "Needs the user database set up first."

For Phase 3, dependencies are static text in task files. Phase 4's `/director:build` will use these to determine ready tasks at runtime.

### Complexity Indicators

**Recommendation: Follow the planner agent's existing table.**

| Size | What It Means | Typical Scope |
|------|---------------|---------------|
| Small | Quick change, straightforward | Single file, clear approach |
| Medium | Some decisions involved | Multiple files, a few choices |
| Large | Significant work, may need research | Multiple files, important decisions |

These are effort indicators, not time estimates. The SKILL.md should include this table for reference.

### Verification Criteria Generation

**Recommendation: Generate specific, observable criteria as checklist items.**

Each "Done When" section should have 3-5 specific, testable criteria written as things the user can observe:
- "Signup page loads and shows email and password fields"
- "Invalid email shows a clear error message"
- NOT "Authentication middleware is configured" (developer jargon)
- NOT "Tests pass" (no test framework required in MVP)

These criteria feed into Phase 5's behavioral verification (Tier 2 checklists).

## Open Questions

1. **Researcher Agent Spawning During Blueprint**
   - What we know: The PRD workflow table shows `/director:blueprint` as "researcher (sub-agent) -> planner -> presents updated gameplan." This implies the researcher agent could be spawned for research before planning.
   - What's unclear: When should the researcher be spawned? Not every blueprint invocation needs research. Research is most relevant when the vision includes unfamiliar tech or complex architectural decisions.
   - Recommendation: For Phase 3 MVP, do NOT spawn the researcher agent by default. The blueprint skill generates the gameplan using Claude's built-in knowledge (which is substantial for planning purposes). Researcher spawning during blueprint can be added later as an enhancement. The researcher agent IS available if Claude determines research is needed, but this is not a mandatory part of the flow.

2. **GAMEPLAN.md vs. goals/ Directory as Source of Truth**
   - What we know: PLAN-07 requires the gameplan stored at `.director/GAMEPLAN.md`. The PRD folder structure also shows individual files in `goals/`.
   - What's unclear: Is GAMEPLAN.md the overview and goals/ the detail? Or is one derived from the other?
   - Recommendation: GAMEPLAN.md is the overview (goals listed with one-line descriptions, current focus). The goals/ directory contains the full detail (individual GOAL.md, STEP.md, and task files). GAMEPLAN.md is generated alongside the goals/ hierarchy -- both are written during blueprint. This matches how Phase 4 will work: `/director:build` reads GAMEPLAN.md to find the next ready task, then loads the individual task file for the fresh agent window.

3. **Naming Convention for Goal/Step Directories**
   - What we know: The PRD shows `01-mvp/` and `01-foundation/`. Templates use `Goal N:` and `Step N:`.
   - What's unclear: What naming convention for directory slugs?
   - Recommendation: Use zero-padded numbers with kebab-case slugs: `01-user-accounts/`, `02-habit-tracking/`. Derive slugs from goal/step names by lowercasing and replacing spaces with hyphens. Keep slugs short (2-4 words).

4. **How Many Goals is Too Many?**
   - What we know: The PRD says "Goals represent major deliverables (v1, v2, future features)."
   - What's unclear: Should Claude limit the number of goals?
   - Recommendation: Target 2-4 goals for most projects. If Claude generates more than 5 goals, it's probably over-decomposing. Goals should be major milestones, not individual features. If a vision naturally splits into more goals, that's fine, but the skill should guide toward fewer, bigger goals.

## Sources

### Primary (HIGH confidence)
- Existing codebase files (all read directly): `skills/blueprint/SKILL.md`, `agents/director-planner.md`, `agents/director-researcher.md`, `skills/blueprint/templates/gameplan-template.md`, `skills/blueprint/templates/goal-template.md`, `skills/blueprint/templates/step-template.md`, `skills/blueprint/templates/task-template.md`, `reference/context-management.md`, `reference/terminology.md`, `reference/plain-language-guide.md`, `scripts/init-director.sh`
- Phase 2 RESEARCH.md (`.planning/phases/02-onboarding/02-RESEARCH.md`) -- Established patterns for inline skill orchestration, sub-agent spawning, and file writing
- Phase 2 PLAN files (02-01-PLAN.md, 02-02-PLAN.md) -- Established plan format and task structure patterns
- PRD (`docs/design/PRD.md`) -- Requirements PLAN-01 through PLAN-09, workflow orchestration table, agent roster, folder structure, gameplan creation requirements
- ROADMAP.md (`.planning/ROADMAP.md`) -- Phase 3 success criteria and planned plan structure
- STATE.md (`.planning/STATE.md`) -- All accumulated decisions from phases 1 and 2

### Secondary (MEDIUM confidence)
- Phase 2 patterns applied to Phase 3 -- The inline orchestration approach used for onboarding is directly applicable to blueprint, but blueprint has different interaction requirements (goal-level review vs. question-at-a-time interview). Confidence is MEDIUM because the specific two-phase flow (goals first, then hierarchy) hasn't been tested in this codebase yet, but the underlying pattern (inline skill with multi-turn conversation) is proven.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH -- All components exist from Phase 1. Templates and agent definitions are complete. No new files to create beyond the SKILL.md rewrite and the actual gameplan output.
- Architecture patterns: HIGH -- Two-phase flow is directly prescribed by user's locked decisions. Inline orchestration proven in Phase 2. Planner agent rules provide comprehensive planning guidance. File structure defined in PRD.
- Pitfalls: HIGH -- Derived from reading the actual codebase (template detection mirrors Phase 2 issue), analyzing user decisions (goal-first review prevents wasted work), and planner agent rules (outcome goals, vertical slices, dependency language).
- Code examples: HIGH -- Based on existing template structures, planner agent rules, Phase 2 SKILL.md patterns, and user's locked decisions about presentation format.

**Research date:** 2026-02-08
**Valid until:** 2026-03-08 (30 days -- Claude Code plugin system stable, existing agent and template definitions unlikely to change)
