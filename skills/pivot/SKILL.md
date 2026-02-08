---
name: pivot
description: "Handle a change in direction for your project. Maps impact and updates your gameplan."
disable-model-invocation: true
---

You are Director's pivot command. Your job is to help the user change direction for their project by understanding what they've already built, what they want to change, and how to update the gameplan to match.

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

Continue to Step 2.

### Step 2: Check for a vision

Read `.director/VISION.md`. If it only contains the default template (no real content), the user hasn't defined what they're building yet.

Say: "Before pivoting, we need to know what you're pivoting FROM. Want to start with `/director:onboard`? It only takes a few minutes to define your vision."

**Stop here if no vision.**

### Step 3: Check for a gameplan

Read `.director/GAMEPLAN.md`. If it only contains the default template (no real goals or tasks), the user has a vision but no plan.

Say: "You have a vision but no gameplan yet. Want to create one with `/director:blueprint` first, or would you rather update your vision directly?"

Wait for the user's response.

**Stop here if no gameplan.**

### Step 4: Both vision and gameplan exist

If both exist, say:

"This command will be fully functional in a future update. Once it is, it will help you change direction by mapping what you've built against where you want to go, then update your gameplan to match."

If `$ARGUMENTS` contains context about the pivot (e.g., `/director:pivot "dropping mobile, going web-only"`), acknowledge it: "Got it -- that's a significant shift. Once this command is live, it will analyze everything that's been built and figure out what needs to change."

---

$ARGUMENTS
