# Director

**Opinionated orchestration for vibe coders.**

Director is a Claude Code plugin for solo builders who use AI to build software. It guides the entire process -- from capturing your vision, to planning your build, to verifying it works. You think about what to build; Director handles the how.

## Install

Requires [Claude Code](https://claude.ai/code) v1.0.33 or later.

### Quick Install

In Claude Code, run these two commands:

```
/plugin marketplace add https://github.com/noahrasheta/director.git
/plugin install director@director-marketplace
```

Then run `/director:onboard` to get started.

## What Director Does

Director follows a three-part loop:

- **Blueprint** -- Capture your vision and create a gameplan (goals, steps, and tasks).
- **Build** -- Execute tasks one at a time with fresh AI context, so quality stays high.
- **Inspect** -- Verify that what you built actually works the way you intended.

Each task gets a fresh AI workspace loaded with just the context it needs. This keeps things fast, accurate, and focused.

## Commands

Director gives you 12 commands, organized around three stages of building.

### Blueprint -- Plan Your Project

| Command | What it does |
|---------|-------------|
| `/director:onboard` | Set up a new project or map an existing one. Director asks you a few questions to understand what you want to build, then creates a plan. |
| `/director:blueprint` | Create, view, or update your gameplan. Use this to add new goals, rearrange steps, or see the big picture. |

**Examples:**
```
/director:onboard
/director:blueprint "add payment processing"
```

### Build -- Make Progress

| Command | What it does |
|---------|-------------|
| `/director:build` | Work on the next ready task. Director picks what to do next, sets up a fresh workspace, and gets to work. |
| `/director:quick "..."` | Make a fast change without full planning. Good for small tweaks that don't need a whole task. |

**Examples:**
```
/director:build
/director:quick "change the button color to blue"
```

### Inspect -- Check Your Work

| Command | What it does |
|---------|-------------|
| `/director:inspect` | Verify that what was built actually matches the goal. Director checks outcomes, not just task completion. |

**Example:**
```
/director:inspect
```

### Other

| Command | What it does |
|---------|-------------|
| `/director:status` | See where you are -- current goal, progress, and what's next. |
| `/director:resume` | Pick up where you left off after a break. Director restores your context. |
| `/director:brainstorm` | Think out loud with full project context. Good for exploring ideas before committing to a direction. |
| `/director:pivot` | Handle a change in direction. When requirements shift, Director helps you adjust the plan without starting over. |
| `/director:idea "..."` | Capture an idea for later. It gets saved so nothing is lost, even if now is not the right time. |
| `/director:undo` | Go back to before the last task. Reverts the most recent change Director made. |
| `/director:help` | Show all available commands with examples and your current project status. |

**Examples:**
```
/director:status
/director:resume
/director:brainstorm "what about real-time collaboration?"
/director:pivot
/director:idea "add dark mode"
/director:undo
/director:help
```

## What Director Creates

When you first run a Director command, it creates a `.director/` folder in your project with:

- **VISION.md** -- What you want to build (captured during onboard)
- **GAMEPLAN.md** -- Your goals, steps, and tasks
- **STATE.md** -- Where you are in the build
- **IDEAS.md** -- Ideas you have captured for later
- **config.json** -- Settings (sensible defaults, no editing needed)

You never need to edit these files directly. Director manages them for you.

## Requirements

- Claude Code v1.0.33 or later
- A project you want to build (new or existing)

## Links

- **Website:** [director.cc](https://director.cc)
- **Source:** [github.com/noahrasheta/director](https://github.com/noahrasheta/director)
- **License:** MIT

## License

MIT
