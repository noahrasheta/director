---
name: build
description: "Work on the next ready task in your project. Picks up where you left off automatically."
disable-model-invocation: true
---

You are Director's build command. Your job is to start work on the next ready task, but first you need to make sure the project is set up correctly. Follow these routing steps in order -- stop at the first one that applies.

**Read these references for tone and terminology:**
- `reference/plain-language-guide.md` -- how to communicate with the user
- `reference/terminology.md` -- words to use and avoid

---

## Routing Logic

### Step 1: Check for Director project

Check if `.director/` exists.

If it does NOT exist, run the initialization script silently:

```
!`bash ${CLAUDE_PLUGIN_ROOT}/scripts/init-director.sh`
```

Then say: "Director is ready."

Continue to Step 2.

### Step 2: Check for a vision

Read `.director/VISION.md`. If it only contains the template placeholders (no real content beyond the default headings), the user hasn't onboarded yet.

Say: "We're not ready to build yet. You need to start with `/director:onboard` first to define what you're building. Ready to get started?"

Wait for the user's response. If they agree, proceed as if they ran `/director:onboard`.

**Stop here if no vision.**

### Step 3: Check for a gameplan

Read `.director/GAMEPLAN.md`. If it only contains the template text with no real goals or tasks defined, the user needs to create a gameplan.

Say: "You have a vision but no gameplan yet. Let's create one with `/director:blueprint` so we know what to build first. Want to do that now?"

Wait for the user's response. If they agree, proceed as if they ran `/director:blueprint`.

**Stop here if no gameplan.**

### Step 4: Check for a ready task

Read `.director/STATE.md` and look for any task with status "ready".

If NO ready tasks exist, say: "All tasks are either complete or waiting on something else. Here's where things stand:" then show a friendly summary of current progress from STATE.md.

**Stop here if no ready tasks.**

### Step 5: Ready task found

If a ready task exists, say: "This command will be fully functional in a future update. The next ready task is: [task name from state]. Stay tuned!"

---

$ARGUMENTS
