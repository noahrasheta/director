# Director

**Opinionated orchestration for vibe coders.**

Director is a Claude Code plugin that helps solo builders go from idea to working product. It gives you a guided workflow -- from capturing your vision, to planning your build, to verifying it works -- so you can focus on what to build while Director handles the how.

## Installation

Requires **Claude Code v1.0.33** or later.

Install Director as a Claude Code plugin:

```
claude plugin install --from https://github.com/noahrasheta/director
```

Or add the marketplace URL to your Claude Code plugin settings:

```
https://raw.githubusercontent.com/noahrasheta/director/main/marketplace.json
```

## Quick Start

Once installed, start with:

```
/director:onboard
```

Director will walk you through setting up your project -- what you want to build, what matters most, and how to get there. It only takes a few minutes.

## Commands

Director gives you 11 commands, organized around three stages of building.

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
| `/director:help` | Show all available commands with examples and your current project status. |

**Examples:**
```
/director:status
/director:resume
/director:brainstorm "what about real-time collaboration?"
/director:pivot
/director:idea "add dark mode"
/director:help
```

## How It Works

Director follows a three-part loop:

1. **Blueprint** -- Capture your vision and create a gameplan (goals, steps, and tasks).
2. **Build** -- Execute tasks one at a time with fresh context, so quality stays high.
3. **Inspect** -- Verify that what you built actually works the way you intended.

Each task gets a fresh AI workspace loaded with just the context it needs. This keeps things fast, accurate, and focused.

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

## License

MIT

## Links

- **Website:** [director.cc](https://director.cc)
- **Source:** [github.com/noahrasheta/director](https://github.com/noahrasheta/director)
