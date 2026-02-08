---
name: help
description: "Show Director commands with examples. Use when the user asks what Director can do, how to use it, or needs guidance."
---

# Director Help

`!cat .director/STATE.md 2>/dev/null || echo "NO_PROJECT"`

Check the output above. If `.director/STATE.md` was found and contains project information, show a mini-status header before the command list. Parse the STATE.md content to find the project name (from the first heading or "Project" field), the current goal, current step, and current task. Format it as:

> **You're working on [project name].** Currently on [current goal] -- [current step/task summary].

If the output was "NO_PROJECT" (no `.director/` exists), show this welcome instead:

> **Welcome to Director!** Here's what you can do:

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
| `/director:help` | Show this guide | `/director:help` |

---

If no project exists (the output above was "NO_PROJECT"), end with:

> **New here?** Start with `/director:onboard` to set up your project. It only takes a few minutes.

If the user provided arguments via `$ARGUMENTS`, acknowledge them but show the full command list regardless. Detailed per-command help will be available in a future update.

$ARGUMENTS
