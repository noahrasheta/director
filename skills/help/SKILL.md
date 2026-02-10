---
name: director:help
description: "Show Director commands with examples. Use when the user asks what Director can do, how to use it, or needs guidance."
---

# Director Help

`!cat .director/STATE.md 2>/dev/null || echo "NO_PROJECT"`

Check the output above. If `.director/STATE.md` was found and contains project information, show a mini-status header before the command list. Parse the STATE.md content to find the project name (from the first heading or "Project" field), the current goal, current step, and current task. Format it as:

> **You're working on [project name].** Currently on [current goal] -- [current step/task summary].

If the output was "NO_PROJECT" (no `.director/` exists), show this welcome instead:

> **Welcome to Director!** Here's what you can do:

---

## Check for topic-specific help

Look at `$ARGUMENTS`. If the user provided an argument, check whether it matches one of the command names below (case-insensitive, with or without the `/director:` prefix):

**Recognized command names:** onboard, blueprint, build, quick, undo, inspect, status, resume, brainstorm, pivot, idea, ideas, help

- **If `$ARGUMENTS` matches a command name:** Show the topic-specific help for that command (see the Topic-Specific Help section below). Do NOT show the full command list.
- **If `$ARGUMENTS` does not match a command name:** Show the full command list below.
- **If `$ARGUMENTS` is empty:** Show the full command list below.

---

## Commands

### Blueprint (Plan Your Project)

| Command | What it does | Example |
|---------|-------------|---------|
| `/director:onboard` | Set up a new project or map an existing one | `/director:onboard` |
| `/director:blueprint` | Create, view, or update your gameplan | `/director:blueprint "add payment processing"` |

### Build (Make Progress)

| Command | What it does | Example |
|---------|-------------|---------|
| `/director:build` | Work on the next ready task | `/director:build` |
| `/director:quick "..."` | Fast change without full planning | `/director:quick "change the button color to blue"` |
| `/director:undo` | Go back to before the last task | `/director:undo` |

### Inspect (Check Your Work)

| Command | What it does | Example |
|---------|-------------|---------|
| `/director:inspect` | Verify what was built matches the goal | `/director:inspect` |

### Other

| Command | What it does | Example |
|---------|-------------|---------|
| `/director:status` | See your progress | `/director:status` |
| `/director:resume` | Pick up where you left off | `/director:resume` |
| `/director:brainstorm` | Think out loud with full project context | `/director:brainstorm "what about real-time collab?"` |
| `/director:pivot` | Handle a change in direction | `/director:pivot` |
| `/director:idea "..."` | Capture an idea for later | `/director:idea "add dark mode"` |
| `/director:ideas` | Review your saved ideas | `/director:ideas` |
| `/director:help` | Show this guide (or help for a specific command) | `/director:help build` |

---

If no project exists (the output above was "NO_PROJECT"), end with:

> **New here?** Start with `/director:onboard` to set up your project. It only takes a few minutes.

---

## Topic-Specific Help

When `$ARGUMENTS` matches a command name, show the detailed help below for that command instead of the full command list. Use this format:

> **`/director:[command]`** -- [one-line description]
>
> [What it does paragraph]
>
> **Examples:**
> - [example 1]
> - [example 2]
>
> **Tip:** [practical tip]

### onboard

**`/director:onboard`** -- Set up a new project or map an existing one

Director will ask you a few questions about what you want to build -- your project's name, what it does, who it's for, and how you imagine it working. For existing projects, Director will also look at what's already there and ask about your plans for it.

**Examples:**
- `/director:onboard` -- Start setting up a new project
- `/director:onboard "it's a recipe sharing app"` -- Start with some initial context already provided

**Tip:** You can re-run onboard on an existing project to update your vision or re-map the codebase.

### blueprint

**`/director:blueprint`** -- Create, view, or update your gameplan

Breaks your vision down into goals, steps, and tasks. If you already have a gameplan, you can update it with new features or adjust priorities. You can also focus on a specific area by adding a description.

**Examples:**
- `/director:blueprint` -- Create a new gameplan or view your existing one
- `/director:blueprint "add payment processing"` -- Focus updates on adding payments
- `/director:blueprint "simplify goal 2"` -- Rework a specific part of your plan

**Tip:** Your gameplan is a living document. Come back to blueprint whenever your priorities change.

### build

**`/director:build`** -- Work on the next ready task

Finds the next task that's ready to go (all its prerequisites are done) and works on it. Director handles the coding, verifies the work, and saves your progress. You can also point it at a specific task.

**Examples:**
- `/director:build` -- Work on the next ready task
- `/director:build "login page"` -- Work on a specific task that matches "login page"
- `/director:build "focus on the UI polish"` -- Carry extra context into the task

**Tip:** Each task is saved independently, so you can undo any single task without affecting others.

### quick

**`/director:quick "..."`** -- Fast change without full planning

For small, focused changes that don't need the full planning workflow. Describe what you want and Director handles it. If the request looks too big for a quick change, Director will suggest planning it out instead.

**Examples:**
- `/director:quick "change the button color to blue"` -- Simple style change
- `/director:quick "fix the typo on the About page"` -- Small fix
- `/director:quick "add a loading spinner to the dashboard"` -- Small feature addition

**Tip:** Quick mode works even if you haven't set up a full gameplan yet. It's great for small tweaks at any point.

### undo

**`/director:undo`** -- Go back to before the last task

Removes the most recent change Director made, restoring your project to how it was before that task. Director will ask you to confirm before going back. If the last change wasn't made by Director, you'll get a heads-up before proceeding.

**Examples:**
- `/director:undo` -- Go back to before the last task
- Run `/director:undo` twice -- Go back two tasks (each undo is independent)

**Tip:** Undo is a safety net. Feel free to experiment -- you can always go back if something isn't right.

### inspect

**`/director:inspect`** -- Verify what was built matches the goal

Reviews your completed work to make sure everything is solid. Director checks for loose ends, missing pieces, and whether what was built actually does what the goal described. You can inspect a specific area or the whole project.

**Examples:**
- `/director:inspect` -- Check the current goal
- `/director:inspect "authentication"` -- Focus on a specific area
- `/director:inspect "all"` -- Check everything

**Tip:** Run inspect after finishing a goal or step to catch issues early, before building on top of them.

### status

**`/director:status`** -- See your progress

Shows where you are in your project -- which goal you're working on, how many steps and tasks are done, and what's coming up next. You can also see cost estimates for your project.

**Examples:**
- `/director:status` -- See your current progress
- `/director:status "cost"` -- See cost tracking details
- `/director:status "detailed"` -- Get a more detailed breakdown

**Tip:** Status is a quick snapshot. For a deeper look at what's been built, use inspect.

### resume

**`/director:resume`** -- Pick up where you left off

When you come back after a break, resume catches you up on where you were, what's changed, and what to do next. It's the best way to restart a session.

**Examples:**
- `/director:resume` -- Get a summary of where you left off and what to do next

**Tip:** Director tracks how long you've been away and adjusts the recap accordingly -- quick refresher for short breaks, full context for longer ones.

### brainstorm

**`/director:brainstorm`** -- Think out loud with full project context

An open-ended conversation about your project with Director's full understanding of your vision, gameplan, and progress. Great for exploring ideas, working through decisions, or thinking about what to build next. Nothing gets changed unless you decide to act on it.

**Examples:**
- `/director:brainstorm` -- Open-ended exploration
- `/director:brainstorm "what about real-time collab?"` -- Start with a specific topic
- `/director:brainstorm "should I use a database or local storage?"` -- Talk through a decision

**Tip:** Brainstorm is for thinking, not doing. Your project stays exactly as it is until you decide to make changes.

### pivot

**`/director:pivot`** -- Handle a change in direction

When your project needs to go in a different direction -- maybe you've learned something new, priorities shifted, or the original plan isn't working -- pivot helps you update your vision and gameplan while preserving what's already been built.

**Examples:**
- `/director:pivot` -- Start a conversation about changing direction
- `/director:pivot "switch from mobile app to web app"` -- Start with the change in mind
- `/director:pivot "drop the social features and focus on core"` -- Narrow scope

**Tip:** Changing direction is learning, not failure. Pivot protects your completed work while reshaping what's ahead.

### idea

**`/director:idea "..."`** -- Capture an idea for later

Saves an idea to your ideas list without interrupting your flow. The idea is stored exactly as you typed it -- no reformatting or editing. You can review and act on saved ideas later.

**Examples:**
- `/director:idea "add dark mode"` -- Save a quick idea
- `/director:idea "what if users could share their dashboards?"` -- Save a bigger thought
- `/director:idea "the settings page needs a reset button"` -- Save a specific improvement

**Tip:** Ideas are free. Capture everything that comes to mind -- you can sort through them later with `/director:ideas`.

### ideas

**`/director:ideas`** -- Review your saved ideas

Shows all the ideas you've captured and helps you decide what to do with each one. You can turn an idea into a quick task, add it to your gameplan, explore it in a brainstorm, or just leave it for later.

**Examples:**
- `/director:ideas` -- Review all your saved ideas
- `/director:ideas "dark mode"` -- Jump to a specific idea that matches

**Tip:** Ideas don't expire. Review them whenever you're looking for what to work on next.

### help

**`/director:help`** -- Show this guide (or help for a specific command)

Shows all available Director commands with descriptions and examples. You can also get detailed help for a specific command by adding its name.

**Examples:**
- `/director:help` -- Show all commands
- `/director:help build` -- Get detailed help for the build command
- `/director:help quick` -- Get detailed help for quick mode

**Tip:** You can use just the command name -- no need to type the full `/director:` prefix when asking for help.

$ARGUMENTS
