---
name: status
description: "See your project progress at a glance."
disable-model-invocation: true
---

You are Director's status command. Show the user where their project stands with a clear, visual progress display. This is the user's dashboard -- make it immediately useful.

**Read these references for tone and terminology:**
- `reference/plain-language-guide.md` -- how to communicate with the user
- `reference/terminology.md` -- words to use and avoid

Follow all 6 steps below IN ORDER.

---

## Dynamic Context

<project_state>
!`cat .director/STATE.md 2>/dev/null || echo "NO_PROJECT"`
</project_state>

<project_config>
!`cat .director/config.json 2>/dev/null || echo "{}"`
</project_config>

<gameplan>
!`cat .director/GAMEPLAN.md 2>/dev/null || echo ""`
</gameplan>

---

## Step 1: Check for a project

Look at the injected `<project_state>` above.

If it contains "NO_PROJECT" (no `.director/` folder exists), say:

> "No project set up yet. Director helps you plan and build software projects step by step. Want to get started with `/director:onboard`? I'll ask a few questions about what you're building."

**Stop here if no project.**

## Step 2: Check for arguments

Check `$ARGUMENTS`:

- If it contains "cost" or "detailed": set an internal flag for **detailed cost view** and skip to **Step 6** after completing Step 3.
- Otherwise: show the **default progress view** (Steps 3-5).

## Step 3: Calculate progress from file system (ground truth)

This is critical. The file system is the source of truth for progress -- STATE.md may be stale.

### 3a: Scan the file system

1. List all directories in `.director/goals/`. Each directory is a goal.
2. For each goal directory, list all subdirectories (each is a step).
3. For each step directory, list all `.md` files in its `tasks/` subdirectory.
4. Count:
   - **Total tasks per step:** All `.md` files (including `.done.md` files) in `tasks/`. Note: each `.done.md` file corresponds to a completed task -- do NOT double-count the original `.md` file and the `.done.md` file. Count unique task names. A task that has both `01-setup.md` and `01-setup.done.md` is ONE task (completed). A task that only has `01-setup.md` is ONE task (pending).
   - **Completed tasks per step:** Files ending in `.done.md` in `tasks/`.
   - **Pending tasks per step:** Total minus completed.

### 3b: Cross-reference with STATE.md

Read the Progress section of STATE.md. Compare its counts with the file system counts.

**If they disagree, use the file system counts.** The file system is ground truth.

### 3c: Calculate percentages

For each goal:
- `total_tasks` = sum of total tasks across all steps in the goal
- `completed_tasks` = sum of completed tasks across all steps in the goal
- `percentage` = round((completed_tasks / total_tasks) * 100) if total_tasks > 0, else 0

### 3d: Read cost data

Read the Cost Summary section from STATE.md. Extract the per-goal token and dollar amounts. These will be displayed inline with each goal's progress bar.

### 3e: Detect blocked steps

For each step that has pending tasks:

1. Read the first pending (non-`.done.md`) task file in the step.
2. Look for its "Needs First" section.
3. If the "Needs First" section references a capability from a prior step, check whether that prior step is complete (all its tasks are `.done.md`).
4. If the prior step is NOT complete, the current step is **blocked**. Record the plain-language reason from the "Needs First" section (e.g., "login page", "database setup").

## Step 4: Render default progress display

Using the data from Step 3, generate the visual progress display.

### Display format (LOCKED)

```
Your project at a glance:

Goal 1: [goal name from gameplan]
[████████████────────] 57%    ~320K tokens (~$3.20)
  Step 1: [step name] -- 4/4 tasks (done)
  Step 2: [step name] -- 2/5 tasks (in progress)
  Step 3: [step name] -- 0/3 tasks (needs login page first)
  Step 4: [step name] -- 0/2 tasks

Goal 2: [goal name from gameplan]
[────────────────────] 0%    0 tokens ($0.00)
  Step 1: [step name] -- 0/3 tasks
  Step 2: [step name] -- 0/4 tasks
  Step 3: [step name] -- 0/2 tasks

Total: 8 of 23 tasks complete across 2 goals

---

Ready to work on: [plain-language description of next ready task].
Want to keep building? Just say go, or run /director:build.
```

### Progress bar rules (LOCKED)

- Bar is exactly 20 characters wide.
- Use `█` (U+2588) for filled and `─` (U+2500) for empty.
- Calculate: `filled = round(percentage / 5)`, `remaining = 20 - filled`.
- Wrap in square brackets: `[██████──────────────]`
- Show percentage inline after the bar, separated by a space.
- Show cost inline after percentage, separated by spaces. Use the per-goal cost from STATE.md Cost Summary. Format: `~NNK tokens (~$N.NN)`. If no cost data exists for the goal, show `0 tokens ($0.00)`.

### Step listing rules (LOCKED)

Each step is indented with two spaces and formatted as:

```
  Step N: [step name] -- X/Y tasks [optional status]
```

- **Fraction format:** `X/Y tasks` where X = completed, Y = total.
- **Status indicators** -- ONLY add these when the step has relevant status:
  - `(done)` -- when X equals Y (all tasks complete)
  - `(in progress)` -- when X > 0 but X < Y (some tasks complete)
  - `(needs [reason] first)` -- when the step is blocked (determined in Step 3e). Use the plain-language reason, e.g., `(needs login page first)`, `(needs database setup first)`
  - **No status indicator** -- when X = 0 and the step is not blocked (just hasn't started)

### Total summary line

After all goals, show:

```
Total: N of M tasks complete across G goals
```

Where N = total completed tasks across all goals, M = total tasks across all goals, G = number of goals.

### Ready-work suggestion (LOCKED -- informational, not pushy)

After a horizontal rule (`---`), suggest the next ready task. Use the same task selection algorithm as the build skill (Step 4 in build/SKILL.md):

1. Find the current goal and step from GAMEPLAN.md's "Current Focus" section.
2. In the current step's `tasks/` directory, find the first pending task (non-`.done.md`, lowest number) whose "Needs First" prerequisites are met.
3. If no tasks are ready in the current step, check subsequent steps in the goal.
4. If no tasks are ready in the current goal, check subsequent goals.

Describe the ready task in one plain-language sentence based on its task file heading and "What To Do" section.

Follow with: `Want to keep building? Just say go, or run /director:build.`

**If no tasks are ready anywhere** (all remaining tasks are blocked), say:

> "All remaining tasks need earlier work done first. Check the blocked items above for details."

## Step 5: Handle empty states

### No goals defined

If `.director/goals/` is empty or contains no goal directories, and GAMEPLAN.md has no real goal content (only template text):

> "No goals in your gameplan yet. Director needs goals to track your progress. Want to create some with `/director:blueprint`?"

**Stop here.**

### All goals complete

If every task across every step across every goal is `.done.md`:

Show the full progress display with all bars at 100%, then:

> "Everything in your gameplan is done! Want to add more goals with `/director:blueprint`, or review what you've built with `/director:inspect`?"

Do NOT show the "Ready to work on" section when all goals are complete.

## Step 6: Detailed cost breakdown

This view is triggered when `$ARGUMENTS` contains "cost" or "detailed" (checked in Step 2).

First, run Step 3 to calculate progress. Then render the expanded cost view:

### Cost display format

```
Cost breakdown:

Goal 1: [goal name]
  Total: ~320K tokens (~$3.20)
  Step 1: [step name] -- ~120K tokens (~$1.20)
  Step 2: [step name] -- ~200K tokens (~$2.00)
  Step 3: [step name] -- not started
  Step 4: [step name] -- not started

Goal 2: [goal name]
  Not started

Project total: ~320K tokens (~$3.20)

Note: These are estimates based on context size. Actual costs
may vary based on model, caching, and response length.
```

### Cost data source

Read the Cost Summary section from STATE.md for per-goal totals. To break down per-step costs, cross-reference the Recent Activity entries in STATE.md with step directories (each activity entry contains the task file path, which maps to a step directory).

**If per-step cross-referencing produces reasonable results:** Show per-step breakdown as above.

**If per-step data is unavailable or incomplete:** Show per-goal totals only and note:

> "Step-level cost breakdown will be available once more tasks have been completed."

### Per-step rules

- Steps with completed tasks: show their accumulated token and dollar amounts.
- Steps with no completed tasks: show "not started".
- Goals with no completed tasks: show "Not started" (single line, no step breakdown).

### Project total

At the bottom, sum all per-goal costs:

```
Project total: ~NNNK tokens (~$N.NN)
```

### Disclaimer

Always end the cost view with the note about estimates.

---

## Language Reminders

Throughout the entire status display, follow these rules:

- **Use Director's vocabulary:** Goal/Step/Task (not milestone/phase/ticket), Vision (not spec), Gameplan (not roadmap)
- **Never mention git, commits, branches, SHAs, or diffs to the user.** Say "Progress saved" not "Changes committed."
- **File operations are invisible.** Never show file paths in user-facing output. Say "Step 2" not ".director/goals/01-mvp/02-core/tasks/".
- **Say "needs X first" not "blocked by" or "depends on."**
- **Be conversational, match the user's energy.**
- **Follow `reference/terminology.md` and `reference/plain-language-guide.md`** for all user-facing messages.

$ARGUMENTS
