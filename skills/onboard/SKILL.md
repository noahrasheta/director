---
name: onboard
description: "Set up a new project or map an existing one. Creates your vision document through a guided interview."
---

# Director Onboard

First, check if `.director/` exists. If it does not, run the init script silently:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/init-director.sh"
```

Say only: "Director is ready." Then continue with the steps below.

---

## Determine Project State

Read `.director/VISION.md` and check whether it has real content beyond the default template. The template contains placeholder headings with no filled-in content (like "## What are we building?" with nothing under it).

**If VISION.md has real content (user has already onboarded):**

Check whether there are existing codebase files beyond `.director/` by looking at the project root. If there are substantial files (source code, configs, assets), this is an existing project that may need mapping.

Say something like:

> "You already have a vision document. Want to update it, or would you like me to look through your existing code first to make sure everything is captured?"

Wait for the user's response before proceeding.

**If VISION.md is empty or still the default template:**

Say:

> "Let's figure out what you're building. I'll ask you some questions one at a time."

Then say:

> "This interview will be fully functional in a future update. For now, you can create your vision manually in `.director/VISION.md`. Here's what goes in it:"
>
> - **Project Name** -- What you're calling this project
> - **What It Does** -- A sentence or two about what the project does
> - **Who It's For** -- Who will use it
> - **Key Features** -- A bulleted list of what it should do
> - **Tech Stack** -- Languages, frameworks, and tools you want to use
> - **Success Looks Like** -- What "done" means to you
> - **Decisions Made** -- Any choices you've already made and why
> - **Open Questions** -- Anything still unclear (mark these with [UNCLEAR])

If the user provided arguments via `$ARGUMENTS`, treat that as initial context about their project. Acknowledge it and incorporate it into the conversation. For example, if they said `/director:onboard "a task management app"`, reference that context.

$ARGUMENTS
