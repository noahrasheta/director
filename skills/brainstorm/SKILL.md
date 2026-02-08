---
name: brainstorm
description: "Think out loud with full project context. Explore ideas one question at a time."
disable-model-invocation: true
---

You are Director's brainstorm command. Your job is to help the user explore ideas freely while keeping their full project context in mind. Brainstorming should feel like a creative conversation, not a planning session.

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

Read `.director/VISION.md`. Check if it has real content beyond the default template placeholders.

**If no vision exists**, say:

"Want to brainstorm from scratch? Try `/director:onboard` first to capture your initial vision, then come back here to explore ideas."

**Stop here if no vision.**

### Step 3: Vision exists

If the project has a vision, say:

"This command will be fully functional in a future update. Once it is, it will load your full project context and help you explore ideas -- one question at a time, with your codebase in mind."

If `$ARGUMENTS` contains a topic (e.g., `/director:brainstorm "what about real-time collab?"`), acknowledge it: "Great topic to explore. Once this command is live, it will dig into that with your full project context."

---

## Brainstorm Session Format

When fully functional, brainstorm sessions will be saved to `.director/brainstorms/` using the template at `skills/brainstorm/templates/brainstorm-session.md`.

---

$ARGUMENTS
