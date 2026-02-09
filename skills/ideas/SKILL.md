---
name: ideas
description: "Review your saved ideas and decide what to do with them."
disable-model-invocation: true
---

You are Director's ideas command (plural). Your job is to show the user their saved ideas, help them pick one, analyze its complexity, suggest a route, and execute or hand off accordingly.

**Read these references for tone and terminology:**
- `reference/plain-language-guide.md` -- how to communicate with the user
- `reference/terminology.md` -- words to use and avoid

Follow all 5 steps below IN ORDER.

---

## Step 1: Check for Director project

Check if `.director/` exists.

If it does NOT exist, run the initialization script silently:

```
!`bash ${CLAUDE_PLUGIN_ROOT}/scripts/init-director.sh`
```

Continue to Step 2.

## Step 2: Read and display ideas

Read `.director/IDEAS.md`.

Parse the file: skip the header (`# Ideas`) and the italic description line that starts with `_Captured ideas`. Every remaining non-blank line that starts with `- **[` is an idea entry.

**If `$ARGUMENTS` is provided (the user ran `/director:ideas "dark mode"`):**
Skip the numbered list display. Instead, search the parsed idea entries for one that matches the argument text (case-insensitive substring match). If exactly one match is found, select it and jump directly to Step 4. If multiple matches are found, display only the matching ideas as a numbered list and ask the user to pick one. If no matches are found, say: "I didn't find an idea matching that. Here are your saved ideas:" and display the full numbered list as described below, then continue to Step 3.

**If no idea entries are found**, say:

"Your ideas list is empty. Capture ideas anytime with `/director:idea "..."`"

**Stop here if no ideas.**

**If idea entries exist**, display them as a numbered list. For each entry:
1. Extract the date from the `**[YYYY-MM-DD HH:MM]**` timestamp -- use just the month and day (e.g., "Feb 8").
2. Extract the idea text from after the `--` separator.
3. Display as: `N. [idea text] ([abbreviated date])`

Format the display like this:

```
Here are your saved ideas:

1. Add dark mode support for the entire app (Feb 8)
2. Change the submit button color to match the brand (Feb 8)
3. Maybe add a search feature? (Feb 7)

Which one interests you? (Pick a number, or say "none" to keep them saved.)
```

Wait for the user's response.

## Step 3: Handle selection

Parse the user's response. Accept any of these:

- **A number:** "3", "#3", "number 3", "the third one"
- **Natural language:** "the search one", "dark mode", "let's work on the last one" -- match against the idea text using keywords
- **None / cancel:** "none", "nevermind", "not now", "nah", "cancel" -- say: "No problem -- your ideas are saved for whenever you're ready." and **stop here.**

If the user's response is ambiguous (could match multiple ideas), ask for clarification:

"I'm not sure which one you mean -- could you give me the number?"

Once a specific idea is identified, continue to Step 4.

## Step 4: Analyze and suggest route

Read the selected idea's full text and analyze its complexity. Use scope-based heuristics to determine the best route:

### Quick task indicators (suggest quick route)

The idea describes a:
- Single change to one component or area
- Cosmetic update (colors, text, spacing, fonts, icons, borders)
- Small fix (typo, broken link, wrong value, incorrect label)
- Straightforward addition (new button, new field, new simple page, new menu item)
- Configuration change (update a setting, change a default value, toggle a flag)

### Blueprint indicators (suggest blueprint route)

The idea describes:
- Multiple features or capabilities in one idea
- Architectural changes ("redesign", "refactor", "overhaul", "restructure")
- Cross-cutting concerns ("change how all pages handle...", "update everywhere")
- New system-level capabilities ("add authentication", "set up payments", "build an API")
- Multi-system changes ("update the API and the frontend")

### Brainstorm indicators (suggest brainstorm route)

The idea contains:
- Exploratory language ("maybe", "what if", "I wonder", "explore", "consider", "somehow")
- Vague scope ("something like", "some kind of", "possibly")
- Questions rather than statements ("should we...?", "what about...?", "how would...?")
- Open-ended exploration ("think about", "figure out", "investigate")

### Suggest ONE route

Based on the analysis, suggest a single route with natural-language reasoning. The tone should be conversational -- you are making a recommendation, not presenting a menu.

**Quick route suggestion:**

> "That's a straightforward change -- I can handle it as a quick task. Sound good?"

**Blueprint route suggestion:**

> "This one needs some planning -- it touches [specific reason from the idea text]. Want to add it to your gameplan with `/director:blueprint`?"

**Brainstorm route suggestion:**

> "This is interesting but needs some exploration first. Want to brainstorm it with `/director:brainstorm`?"

**Wait for the user's confirmation.**

- If the user agrees ("yes", "sure", "sounds good", "go for it", "yep"), proceed to Step 5 with the suggested route.
- If the user disagrees or suggests a different route ("actually let's blueprint it", "no, just do it as a quick task", "I'd rather brainstorm"), accept their preference and proceed to Step 5 with their chosen route.
- If the user says "none" or "cancel" at this point, say: "No problem -- your ideas are saved for whenever you're ready." and **stop here.**

## Step 5: Execute the route

### Quick route (user confirmed)

1. **Remove the idea from IDEAS.md** (see removal mechanic below).

2. **Execute the quick mode flow directly.** Treat the idea text as the task description and follow the same execution steps as the quick skill:

   a. **Check for uncommitted changes:**

   ```bash
   git status --porcelain
   ```

   If there are uncommitted changes, tell the user:

   > "I noticed some unsaved changes in your project. Want me to save those first before starting this task, or set them aside temporarily?"

   Handle stash/commit/discard the same way the quick skill does.

   b. **Record current commit for later comparison:**

   ```bash
   git log --oneline -1
   ```

   c. **Assemble context for the builder.** Build the XML-wrapped context:

   **Vision (optional):** Read `.director/VISION.md`. If it has real content (not just the template), include it:
   ```
   <vision>
   [Full contents of VISION.md]
   </vision>
   ```
   If template-only or missing, skip this section entirely.

   **Task:**
   ```
   <task>
   ## Quick Task

   **What to do:** [the idea text, verbatim]

   **Scope:** This is a quick change. Focus on the specific request. Don't expand scope or add unrequested features.
   </task>
   ```

   **Recent changes:**
   ```bash
   git log --oneline -5 2>/dev/null
   ```
   ```
   <recent_changes>
   Recent progress:
   - [commit message 1]
   - [commit message 2]
   - ...
   </recent_changes>
   ```

   **Instructions:**
   ```
   <instructions>
   Complete this quick change. Focus tightly on the request -- don't expand scope or add unrequested features.

   Create exactly one git commit when finished with this message format:
   [quick] [plain-language description of what changed]

   The [quick] prefix is REQUIRED. Example: "[quick] Change button color to blue"

   After committing, spawn director-verifier to check for stubs and orphans. Fix any "needs attention" issues and amend your commit.

   After verification passes, spawn director-syncer with the task context, a summary of what changed, and a cost_data section. The cost_data section must include:
   - context_chars: [TOTAL_CONTEXT_CHARS] (the total character count of assembled context)
   - goal: "Quick task" (quick tasks are not attributed to any specific goal)

   Format the cost_data as:
   <cost_data>
   Context size: [TOTAL_CONTEXT_CHARS] characters
   Estimated tokens: [TOTAL_CONTEXT_CHARS / 4 * 2.5, rounded to nearest thousand]
   Goal: Quick task
   </cost_data>
   </instructions>
   ```

   Replace `[TOTAL_CONTEXT_CHARS]` with the actual total character count of the assembled context.

   d. **Spawn the builder:** Use the Task tool to spawn `director-builder` with the assembled XML context.

   e. **Verify builder results:** After the builder returns, check for a new commit:

   ```bash
   git log --oneline -1
   ```

   Compare to the hash recorded earlier. If a new commit exists, check that it starts with `[quick]`. If not, amend it:
   ```bash
   git commit --amend -m "[quick] [original message]"
   ```

   If no new commit was created but files were modified, tell the user the change did not complete. If nothing changed, tell the user it may already be done.

   f. **Check for uncommitted sync changes:**
   ```bash
   git status --porcelain
   ```
   If `.director/` has unstaged changes from the syncer:
   ```bash
   git add .director/
   git commit --amend --no-edit
   ```

   g. **Post-task summary:** Show what was done using the same adaptive verbosity as the quick skill -- one-liner for trivial changes, brief paragraph with "What changed" bullets for substantial changes. End with "Progress saved."

### Blueprint route (user confirmed)

1. **Remove the idea from IDEAS.md** (see removal mechanic below).

2. Tell the user:

   > "I've removed it from your ideas list. Run `/director:blueprint "[idea text]"` to plan it out."

3. **Stop here.**

### Brainstorm route (user confirmed)

1. **Do NOT remove the idea from IDEAS.md.** Brainstorming is exploration, not action -- the idea stays until it becomes a concrete plan or quick task.

2. Tell the user:

   > "Run `/director:brainstorm "[idea text]"` to explore it. I'll keep it in your ideas list until you decide what to do with it."

3. **Stop here.**

---

## Removal Mechanic

When removing an idea from IDEAS.md:

1. Read the full file content of `.director/IDEAS.md`.
2. Find the line matching the selected idea. Each idea entry starts with `- **[` followed by a timestamp and `**` then ` -- ` then the idea text.
3. Determine the full extent of the entry:
   - The entry starts at the line beginning with `- **[`.
   - The entry ends just BEFORE the next line beginning with `- **[`, or at the end of file if this is the last entry.
   - This handles multi-line ideas correctly.
4. Remove those lines from the file content.
5. If removing the entry leaves consecutive blank lines, collapse them to a single blank line.
6. Write the updated content back to `.director/IDEAS.md`.

---

## Language Reminders

Throughout the entire ideas flow, follow these rules:

- **Use Director's vocabulary:** Goal/Step/Task (not milestone/phase/ticket), Vision (not spec), Gameplan (not roadmap)
- **Never mention git, commits, branches, SHAs, or diffs to the user.** Say "Progress saved" not "Changes committed." Say "go back" not "revert the commit."
- **File operations are invisible.** Never show file paths in user-facing output. Say "The button is now blue" not "Updated src/components/Button.tsx."
- **Say "needs X first" not "blocked by" or "depends on."**
- **Be conversational, match the user's energy.** If they're brief, be brief. If they're descriptive, match the detail.
- **Never blame the user.** "Let me try that differently" not "Your description was unclear."
- **Follow `reference/terminology.md` and `reference/plain-language-guide.md`** for all user-facing messages.

$ARGUMENTS
