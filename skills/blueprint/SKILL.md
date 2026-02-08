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

**If VISION.md is empty or still the default template:**

Say something like:

> "Before creating a gameplan, we need to understand what you're building. Want to start with `/director:onboard`? It's a quick interview to capture your vision."

Wait for the user's response. If they agree, proceed as if they invoked `/director:onboard` -- run through the onboard flow to capture their vision first.

**If VISION.md has content, check `.director/GAMEPLAN.md`:**

**If GAMEPLAN.md is empty or still the default template:**

Say:

> "This command will be fully functional in a future update. Once it is, it will read your vision and break it down into a gameplan with Goals, Steps, and Tasks -- everything Director needs to guide the build process."

**If GAMEPLAN.md has real content:**

Say:

> "This command will be fully functional in a future update. Once it is, you'll be able to view your gameplan, add new goals, rearrange steps, and update tasks right from here."

If the user provided arguments via `$ARGUMENTS`, acknowledge them. For example, if they said `/director:blueprint "add payment processing"`, say something like:

> "Noted -- you want to add payment processing. Once the blueprint command is fully functional, it will add that to your gameplan automatically."

$ARGUMENTS
