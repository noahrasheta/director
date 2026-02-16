# Director

**Spec-driven orchestration for vibe coders and solo entrepreneurs.**

Director is a Claude Code plugin for solo builders who use AI to build software. It guides the entire process -- from capturing your vision, to researching your domain, to planning your build, to verifying it works. You think about what to build; Director handles the how.

## Install

Requires [Claude Code](https://claude.ai/code) v1.0.33 or later.

### Quick Install

In Claude Code, run these two commands:

```
/plugin marketplace add noahrasheta/director
/plugin install director@director-marketplace
```

Then run `/director:onboard` to get started.

## What Director Does

Director follows a three-part loop:

- **Blueprint** -- Capture your vision and create a gameplan (goals, steps, and tasks). Director researches your domain and analyzes your codebase to make informed plans.
- **Build** -- Execute tasks one at a time with fresh AI context loaded with relevant research and codebase knowledge, so quality stays high.
- **Inspect** -- Verify that what you built actually works the way you intended.

Each task gets a fresh AI workspace loaded with just the context it needs -- including codebase conventions, architecture patterns, and domain research. This keeps things fast, accurate, and focused.

## Deep Context

Director doesn't just plan blindly. During onboarding, it builds deep understanding of your project:

- **Codebase mapping** -- 4 parallel agents analyze your existing code, producing detailed files covering your stack, architecture, conventions, structure, testing patterns, integrations, and concerns. These files guide every downstream agent so they follow your project's patterns.
- **Domain research** -- 4 parallel researchers investigate your project's ecosystem (stack choices, feature patterns, architecture approaches, common pitfalls) and produce actionable recommendations with a "Don't Hand-Roll" list of problems with existing library solutions.
- **Step-level research** -- Before planning tasks within each step, a researcher investigates the specific technical domain so task plans are informed by current ecosystem knowledge.
- **Staleness detection** -- Director alerts you when your codebase or research context is outdated and suggests running `/director:refresh` to update it.

All of this context flows into Blueprint, Build, Brainstorm, Pivot, and Inspect -- so every agent makes context-informed decisions.

## Commands

### Blueprint -- Plan Your Project

| Command | What it does |
|---------|-------------|
| `/director:onboard` | Set up a new project or map an existing one. Director maps your codebase, asks you a few questions, optionally researches your domain, then creates a plan. |
| `/director:blueprint` | Create, view, or update your gameplan. Use this to add new goals, rearrange steps, or see the big picture. |

**Examples:**
```
/director:onboard
/director:blueprint "add payment processing"
```

### Build -- Make Progress

| Command | What it does |
|---------|-------------|
| `/director:build` | Work on the next ready task. Director picks what to do next, loads relevant codebase context, and gets to work. |
| `/director:quick "..."` | Make a fast change without full planning. Good for small tweaks that don't need a whole task. |

**Examples:**
```
/director:build
/director:quick "change the button color to blue"
```

### Inspect -- Check Your Work

| Command | What it does |
|---------|-------------|
| `/director:inspect` | Verify that what was built actually matches the goal. Director checks outcomes, not just task completion, using your project's conventions. |

**Example:**
```
/director:inspect
```

### Other

| Command | What it does |
|---------|-------------|
| `/director:status` | See where you are -- current goal, progress, and what's next. |
| `/director:resume` | Pick up where you left off after a break. Director restores your context. |
| `/director:refresh` | Re-scan your codebase and optionally re-run domain research without full re-onboarding. Shows what changed since the last scan. |
| `/director:brainstorm` | Think out loud with full project context, including research and codebase knowledge. |
| `/director:pivot` | Handle a change in direction. When requirements shift, Director helps you adjust the plan without starting over. |
| `/director:idea "..."` | Capture an idea for later. It gets saved so nothing is lost, even if now is not the right time. |
| `/director:ideas` | Review your saved ideas. Pick one to build, add to the gameplan, or discard. |
| `/director:undo` | Go back to before the last task. Reverts the most recent change Director made. |
| `/director:help` | Show all available commands with examples and your current project status. |

**Examples:**
```
/director:status
/director:resume
/director:refresh
/director:refresh research
/director:brainstorm "what about real-time collaboration?"
/director:pivot
/director:idea "add dark mode"
/director:ideas
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
- **codebase/** -- Technical analysis of your existing code (stack, architecture, conventions, structure, testing, integrations, concerns)
- **research/** -- Domain research for your project (stack choices, features, architecture, pitfalls, summary)

You never need to edit these files directly. Director manages them for you.

## Requirements

- Claude Code v1.0.33 or later
- A project you want to build (new or existing)

**Note:** Director's research features (domain analysis during `/director:onboard` and `/director:refresh`) use Claude Code's built-in WebFetch tool to look up documentation and best practices. If WebFetch is unavailable in your environment, research will degrade gracefully -- Director will still work, but research summaries may be less detailed.

## Links

- **Website:** [director.cc](https://director.cc)
- **Source:** [github.com/noahrasheta/director](https://github.com/noahrasheta/director)
- **License:** MIT

## License

MIT
