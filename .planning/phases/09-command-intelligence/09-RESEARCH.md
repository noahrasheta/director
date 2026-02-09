# Phase 9: Command Intelligence - Research

**Researched:** 2026-02-09
**Domain:** Command routing, state detection, undo mechanics, inline text support, error handling, terminology enforcement
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

#### Routing behavior
- Redirect conversationally when commands are invoked out of sequence -- suggest the right command and wait for the user to confirm, never auto-route silently
- State checks only on key entry points (build, blueprint, inspect, pivot) -- lightweight commands (help, status, idea, brainstorm) skip state validation
- When `/director:onboard` is invoked on an already-onboarded project: acknowledge the existing vision and offer a choice (update it or move on to planning) -- the user may have intentionally re-run it for a pivot or vision update
- Partially complete states detected and picked up where the user left off -- detect the furthest progress point and suggest the natural next step from there

#### Undo scope & safety
- `/director:undo` reverts exactly one task commit (the most recent) -- simple and predictable
- Sequential undos supported: invoke undo multiple times to revert multiple tasks, each invocation is independent
- Always confirm before reverting: "Going back to before [task name]. This will remove those changes. Continue?"
- Undo works on everything -- regular build tasks AND quick-mode changes (both produce atomic commits)
- Full rollback on undo: revert code AND `.director/` state (STATE.md, .done.md rename, etc.) -- the task disappears as if it never happened
- Lightweight undo log: a few lines noting what was undone and when, stored quietly in `.director/` without bloating state files

#### Inline context handling
- Command-specific interpretation: each command interprets inline text in the way most natural for what it does (idea captures, quick executes, build matches tasks, blueprint focuses updates)
- Match first, then instruct: for gameplan-aware commands (build, inspect, blueprint), try to match inline text against existing tasks/steps first; if no match, treat as general instruction to the agent
- When inline text doesn't match anything and has no obvious interpretation: ask for clarification before proceeding -- never silently ignore what the user typed
- Claude audits which commands need inline support added vs. which already have it, and standardizes where needed

### Claude's Discretion
- Error message structure and exact wording (within the constraint: plain language, what went wrong, why, what to do next, never blame the user)
- Terminology enforcement implementation approach (compile-time checking vs. runtime word list vs. agent instructions)
- Which specific commands need inline text support added (some already have it from Phases 7-8)
- Help command content and organization

### Deferred Ideas (OUT OF SCOPE)
None -- discussion stayed within phase scope
</user_constraints>

## Summary

Phase 9 is an audit-and-standardize phase, not a build-from-scratch phase. The core patterns for routing, inline text, state detection, and terminology enforcement already exist across multiple skills -- they were built incrementally through Phases 1-8. The work is to: (1) audit all 12 skills for consistency against the locked decisions, (2) create a new `undo` skill with git-based rollback, (3) standardize inline text handling across commands that lack it, (4) enhance help with up-to-date command reference, and (5) ensure error messages and terminology are consistent everywhere.

The most technically novel piece is the undo command, which requires `git reset --hard HEAD~1` (appropriate for Director's single-developer, linear-history, never-pushed-yet model) combined with reversing `.director/` state changes (renaming `.done.md` back to `.md`, updating STATE.md). The undo log is a simple append-only file. Everything else in this phase is pattern standardization.

**Primary recommendation:** Treat this phase as an audit-first, fix-second workflow. Start by cataloging what each skill currently does for routing, inline text, and error handling. Then apply changes systematically rather than rewriting skills from scratch.

## Standard Stack

This phase requires no external libraries. All work is in Markdown skill files, bash scripts, and git operations.

### Core
| Tool | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Git | any | Undo mechanism via `git reset --hard HEAD~1` | Already required by Director; single-developer linear history makes reset safe |
| Bash | any | Undo script for atomic rollback | Same scripting approach as init-director.sh, session-start.sh |
| SKILL.md | Claude Code plugin | Skill definitions for undo and help updates | Standard Director pattern from Phase 1 |

### Supporting
| Tool | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `git log --oneline -1` | any | Identify most recent commit for undo | Before undo rollback |
| `git diff --stat HEAD~1` | any | Show what the undo will remove | Undo confirmation display |
| `git show --name-status HEAD` | any | Identify `.director/` files changed in commit | State rollback detection |

## Architecture Patterns

### Pattern 1: State Detection Cascade

Every key-entry-point command (build, blueprint, inspect, pivot) follows a cascade of state checks. The existing pattern in build/SKILL.md is the canonical implementation:

```
1. Check .director/ exists           -> if not, init silently
2. Check VISION.md has real content  -> if template-only, redirect to onboard
3. Check GAMEPLAN.md has real content -> if template-only, redirect to blueprint
4. Proceed with command logic
```

**What exists today:**

| Skill | Init Check | Vision Check | Gameplan Check | Notes |
|-------|-----------|-------------|----------------|-------|
| build | Yes (Step 1) | Yes (Step 2) | Yes (Step 3) | Full cascade, canonical pattern |
| blueprint | Yes | Yes | Uses for mode detection | Routes to onboard if no vision |
| onboard | Yes | Yes (for re-entry) | No | Re-entry path exists from Phase 2 |
| inspect | Yes (Step 1) | No | No (checks STATE.md) | Only checks for completed work |
| pivot | Yes (1a) | Yes (1b) | Yes (1c) | Full cascade, similar to build |
| brainstorm | Yes | Yes | No (intentionally) | Does not require gameplan |
| quick | Yes | No (intentional) | No (intentional) | Works on bare .director/ |
| status | No (uses dynamic inject) | No | No | Checks injected STATE.md |
| resume | No (uses dynamic inject) | No | No | Checks injected STATE.md |
| help | No (uses dynamic inject) | No | No | Checks injected STATE.md |
| idea | Yes | No | No | Minimal -- just captures |
| ideas | Yes | No | No | Minimal -- just displays |

**Key finding:** The routing cascade is NOT missing from most commands -- it was intentionally designed per command. The locked decision confirms this: "State checks only on key entry points (build, blueprint, inspect, pivot)." The work is to audit existing routing in these four commands for consistency with the four-step routing pattern (state, explain, suggest, wait), NOT to add routing to all commands.

### Pattern 2: Conversational Routing (Four-Step Pattern)

Established in Phase 1 (decision 01-03), routing messages follow:

1. **State** the situation
2. **Explain** why
3. **Suggest** the action conversationally
4. **Wait** for the user's response

**Example (from build skill):**
> "We're not ready to build yet -- you need to define what you're building first. Want to start with `/director:onboard`?"

**Canonical phrases (from decision 01-04):**
- "Want to..." not "Run /director:..."
- Conversational suggestions, not imperative commands

### Pattern 3: Template Detection (Shared Pattern)

Multiple skills use identical template detection logic. The pattern:

```
Template signals for VISION.md:
- Contains "This file will be populated when you run /director:onboard"
- Contains italic prompts like "_What are you calling this project?_"
- Headings with no substantive content beneath them

Template signals for GAMEPLAN.md:
- Contains "This file will be populated when you run /director:blueprint"
- Contains "_No goals defined yet_"
- No actual goal headings with substantive content
```

This pattern is duplicated identically in build, blueprint, onboard, pivot, brainstorm, and quick. Phase 9 should NOT extract it into a shared utility (skills are standalone Markdown -- there is no import mechanism). Instead, verify that all six skills use the same detection signals.

### Pattern 4: Undo via Git Reset

For Director's undo, `git reset --hard HEAD~1` is the correct approach, NOT `git revert HEAD`.

**Why reset, not revert:**
- Director uses single-developer, single-branch, linear history
- Commits are never pushed to a remote during development (git push is out of scope for v1)
- `git reset --hard HEAD~1` cleanly removes the commit as if it never happened
- `git revert HEAD` creates a NEW commit that undoes changes -- this pollutes the history with "undo" commits and breaks Director's "task disappears as if it never happened" requirement
- The locked decision says "the task disappears as if it never happened" -- reset achieves this, revert does not

**Undo sequence:**
```bash
# 1. Record what we're about to undo (for the undo log)
COMMIT_MSG=$(git log --oneline -1 --format='%s')
COMMIT_HASH=$(git log --oneline -1 --format='%h')

# 2. Identify .director/ files changed in the commit
DIRECTOR_FILES=$(git diff --name-only HEAD~1 HEAD -- .director/)

# 3. Reset to remove the commit entirely
git reset --hard HEAD~1

# 4. .director/ state is automatically restored because the reset
#    reverts ALL files, including .director/ changes
```

**Critical insight:** Because Director's build skill amend-commits `.director/` changes (STATE.md, .done.md renames) into the task commit, `git reset --hard HEAD~1` automatically rolls back ALL state changes. No separate `.director/` state restoration is needed. The single atomic commit principle means undo is also atomic.

### Pattern 5: Inline Text Handling

**Current $ARGUMENTS support by command:**

| Skill | Has $ARGUMENTS | How Used | Phase 9 Work |
|-------|---------------|----------|--------------|
| build | Yes | Match task name, or carry as extra context (Step 4e) | Already done -- audit only |
| blueprint | Yes | New mode: acknowledge; Update mode: focus for update | Already done -- audit only |
| onboard | Yes | Initial project context, skip first question | Already done -- audit only |
| inspect | Yes | Scope: "goal", "all", or topic text (Step 3) | Already done -- audit only |
| quick | Yes | Required -- the task description | Already done -- no changes |
| idea | Yes | Required -- the idea text | Already done -- no changes |
| ideas | Yes | Direct idea matching (e.g., "dark mode") | Already done -- audit only |
| brainstorm | Yes | Topic-specific entry vs open-ended | Already done -- audit only |
| pivot | Yes | Inline pivot description, skips interview | Already done -- audit only |
| status | Yes | "cost" or "detailed" for cost view | Already done -- audit only |
| resume | No `$ARGUMENTS` handling | Not used | **Needs adding** |
| help | Yes (acknowledged) | Shows full list regardless | **Needs enhancing** |

**Finding:** Nearly all commands already handle `$ARGUMENTS`. The only command with NO inline support is `resume`. For help, arguments are acknowledged but do not change behavior -- Phase 9 could add topic-specific help (e.g., `/director:help build`).

**Recommendation for resume:** `/director:resume "focus on authentication"` could carry the text as context for the suggested next action. Since resume shows current position and suggests next steps, inline text could influence which task or area gets highlighted.

### Recommended File Changes

```
skills/
  undo/
    SKILL.md        # NEW -- undo skill
  help/
    SKILL.md        # UPDATE -- enhanced help with undo, ideas command
  build/
    SKILL.md        # AUDIT -- verify routing consistency
  blueprint/
    SKILL.md        # AUDIT -- verify routing consistency
  inspect/
    SKILL.md        # AUDIT -- verify routing consistency, add routing for no-vision
  pivot/
    SKILL.md        # AUDIT -- verify routing consistency
  onboard/
    SKILL.md        # AUDIT -- verify re-entry messaging matches CMDI-03
  resume/
    SKILL.md        # UPDATE -- add $ARGUMENTS support
  status/
    SKILL.md        # AUDIT -- verify partial-state detection
  brainstorm/
    SKILL.md        # AUDIT -- verify routing consistency
  quick/
    SKILL.md        # AUDIT -- verify error messaging
  idea/
    SKILL.md        # AUDIT -- verify error messaging
  ideas/
    SKILL.md        # AUDIT -- verify error messaging
reference/
  terminology.md    # AUDIT -- verify completeness of never-use list
  plain-language-guide.md  # AUDIT -- verify routing template examples
```

### Anti-Patterns to Avoid

- **Adding routing to lightweight commands:** The locked decision says help, status, idea, brainstorm skip state validation. Do NOT add vision/gameplan checks to these commands.
- **Creating a shared routing module:** Skills are standalone Markdown files consumed by Claude. There is no import/require mechanism. Each skill must contain its own routing logic. Consistency is achieved through audit, not abstraction.
- **Using git revert for undo:** Creates revert commits that pollute history. Use `git reset --hard HEAD~1` for clean removal.
- **Complex undo state machine:** The locked decision says sequential undos are independent invocations. Each undo is stateless -- it just removes the most recent commit. No tracking of "undo depth" or "undo stack" needed.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Git undo | Custom file-by-file rollback | `git reset --hard HEAD~1` | Atomic commit means atomic undo -- git handles all file restoration |
| State rollback | Custom STATE.md parser/reverter | Let git reset restore .director/ files | Since .director/ changes are amend-committed into the task commit, git reset restores them automatically |
| Template detection | New detection framework | Reuse the exact pattern strings from build/SKILL.md | Pattern is proven across 6 skills; consistency matters more than elegance |
| Error message formatting | Custom error template system | Inline plain-language patterns in each skill | Skills are Markdown consumed by Claude; templates are just examples in the skill text |

**Key insight:** The atomic commit strategy (one commit per task, including .director/ changes) makes undo trivial. `git reset --hard HEAD~1` is the entire implementation for code rollback. The only additional work is: (a) identifying what the commit was, (b) confirming with the user, (c) updating the undo log.

## Common Pitfalls

### Pitfall 1: .done.md Rename Not Captured in Commit
**What goes wrong:** If the syncer renames a task file from `.md` to `.done.md` but the rename is not amend-committed into the task commit, `git reset --hard HEAD~1` will not undo the rename, leaving orphaned `.done.md` files.
**Why it happens:** The amend-commit step in the build skill's Step 9a could fail silently.
**How to avoid:** The undo skill should verify state consistency after reset. Check that no `.done.md` files exist for the task that was supposedly undone. If found, rename them back manually.
**Warning signs:** After undo, `git status --porcelain` shows .director/ changes.

### Pitfall 2: Undo on Non-Director Commits
**What goes wrong:** If the most recent commit was not made by Director (e.g., user committed manually), undo would revert their manual work.
**Why it happens:** Undo blindly targets HEAD~1.
**How to avoid:** Before undoing, check the commit message pattern. Director commits follow specific patterns: plain-language task descriptions, `[quick]` prefix for quick tasks. If the commit does not match a Director pattern, warn the user: "The last change wasn't made by Director. Are you sure you want to undo it?"
**Warning signs:** Commit message lacks Director's patterns.

### Pitfall 3: Undo After Pivot
**What goes wrong:** After a pivot rewrites GAMEPLAN.md and STATE.md, undoing the pivot commit leaves the project in an inconsistent state because pivot is a multi-file operation, not a standard task.
**Why it happens:** Pivot updates STATE.md directly (not through syncer amend-commit), so pivot changes may span multiple commits or be in the pivot skill's conversation context.
**How to avoid:** Check if the most recent commit is a pivot commit (look for "Pivot:" in Recent Activity entries or commit message). If it is, warn the user that undoing a pivot is more complex: "The last change was a direction change, not a regular task. Undoing it would restore the old gameplan. Are you sure?"
**Warning signs:** Commit message or STATE.md Recent Activity contains "Pivot:" marker.

### Pitfall 4: Inconsistent Routing Messages Across Skills
**What goes wrong:** Different skills use slightly different phrasing for the same routing scenario (e.g., "no vision" redirect).
**Why it happens:** Skills were written in different phases by different plan executions.
**How to avoid:** Phase 9 audit should create a routing message catalog comparing the exact text in each skill for each scenario. Standardize wording while preserving the conversational tone.
**Warning signs:** Reading two skills side-by-side reveals different phrasing for the same situation.

### Pitfall 5: Stale Help Command
**What goes wrong:** Help command was written in Phase 1 and has not been updated as new commands were added or modified.
**Why it happens:** Help content is static Markdown written during the foundation phase.
**How to avoid:** Update help to include: undo command, ideas command (plural), accurate descriptions matching current functionality, and the undo mention in build's post-task summary.
**Warning signs:** Help lists commands that do not exist or omits commands that do.

## Code Examples

### Undo Skill Core Logic

```markdown
## Step 1: Check for a project

Check if `.director/` exists.

If it does NOT exist:
> "Nothing to undo -- no project set up yet."
**Stop here.**

## Step 2: Check for commits to undo

Run `git log --oneline -1 2>/dev/null` to get the most recent commit.

If no commits exist:
> "Nothing to undo -- no progress has been saved yet."
**Stop here.**

## Step 3: Identify the commit

Parse the most recent commit message. Determine if it was made by Director:

- **Director task commits:** Plain-language descriptions (e.g., "Build the login page with form validation")
- **Quick task commits:** Start with `[quick]` prefix (e.g., "[quick] Change button color to blue")
- **Non-Director commits:** Everything else (conventional commits, WIP messages, etc.)

If the commit does not look like a Director commit, warn:
> "The last saved change wasn't made by Director -- it looks like something you did manually. Still want to undo it?"

Wait for confirmation. If they decline, stop.

## Step 4: Confirm with the user

Extract a plain-language description of what will be undone. Present the confirmation:

> "Going back to before [task description from commit message]. This will remove those changes. Continue?"

Wait for the user's response. If they decline, stop.

## Step 5: Execute undo

Record undo log entry BEFORE resetting (we need the info from the commit):

Read the current commit hash and message for the undo log entry.

Then execute:
```bash
git reset --hard HEAD~1
```

## Step 6: Update undo log

Append to `.director/undo.log`:

```
[YYYY-MM-DD HH:MM] Undid: [commit message] ([short hash])
```

Then commit the undo log update:
```bash
git add .director/undo.log
git commit -m "Log undo: [commit message]"
```

## Step 7: Confirm to user

> "Done -- went back to before [task description]. Your project is back to where it was."

Do not suggest next steps. The user knows what they want to do.
```

### Partial-State Detection Pattern

```markdown
## Detect project progress point

Read `.director/STATE.md`, `.director/VISION.md`, and `.director/GAMEPLAN.md`.

Determine the furthest progress point:

1. If `.director/` does not exist: **No project** -> suggest onboard
2. If VISION.md is template-only: **Not onboarded** -> suggest onboard
3. If GAMEPLAN.md is template-only: **Vision captured, no plan** -> suggest blueprint
4. If no completed tasks exist: **Plan exists, not started** -> suggest build
5. If some tasks complete: **In progress** -> suggest build (next ready task)
6. If all tasks complete: **Done** -> suggest inspect or blueprint for more
```

### Terminology Enforcement Approach

The existing approach in Director is the correct one: **agent instructions + reference docs**. Each skill already references `reference/terminology.md` and `reference/plain-language-guide.md`. The never-use word list has 30+ terms in 4 categories.

**Recommendation:** Do NOT add runtime word-list checking (no post-processing filter). Instead:

1. Verify every skill has the reference doc instructions
2. Verify the never-use word list in terminology.md is complete
3. Add any missing terms discovered during the audit
4. The approach is "compile-time" (instructions baked into skills) not "runtime" (filtering output)

This is the right approach because:
- Skills are consumed by Claude as instructions -- they ARE the enforcement mechanism
- Adding a runtime filter would require a hook that processes output, which Claude Code plugins do not support
- The word list has been effective through 8 phases of development

## State of the Art

| Old Approach (before Phase 9) | Current Approach (Phase 9) | Impact |
|------|------|--------|
| Routing patterns built per-phase, inconsistent | Audited and standardized routing across all key-entry commands | Consistent user experience regardless of which command they try first |
| No undo capability | `/director:undo` with `git reset --hard HEAD~1` | Users can safely experiment knowing they can go back |
| Help written in Phase 1, not updated | Help reflects all 12 commands including undo and ideas | Users always see accurate command reference |
| Inline text handled ad-hoc per skill | Standardized inline text interpretation with match-first-then-instruct pattern | Predictable behavior across all commands |

## Open Questions

1. **Undo log location and format**
   - What we know: Locked decision says "lightweight undo log, a few lines noting what was undone and when, stored quietly in `.director/`"
   - What is unclear: Whether this should be `.director/undo.log` (simple append file) or a section in STATE.md
   - Recommendation: Use `.director/undo.log` as a separate file. STATE.md is already complex and the undo log is independent of project state. A simple append-only text file keeps it minimal.

2. **Undo log commit strategy**
   - What we know: The undo removes a commit via reset. The undo log entry needs to be preserved.
   - What is unclear: Should the undo log update itself be committed? If yes, `git reset --hard` on a subsequent undo would also remove the previous undo log entry.
   - Recommendation: Commit the undo log update as a tiny separate commit after the reset. This commit itself would be the new HEAD, and subsequent undos would see it as a non-Director commit and warn appropriately. Alternatively, the undo log could be untracked (in .gitignore), but this conflicts with Director's principle that `.director/` is tracked.

3. **Resume command inline text interpretation**
   - What we know: Resume currently has no $ARGUMENTS handling. Most other commands do.
   - What is unclear: What inline text means for resume. Options: (a) focus area for context restoration, (b) skip to action ("go" jumps straight to build), (c) topic to highlight in the recap.
   - Recommendation: Keep it simple -- if $ARGUMENTS is provided, treat it as context for the "what to do next" suggestion. "Resume with authentication focus" highlights auth-related tasks in the next-action suggestion.

4. **Help command topic-specific mode**
   - What we know: Help currently acknowledges arguments but shows the full list regardless.
   - What is unclear: Whether `/director:help build` should show build-specific help or remain unchanged.
   - Recommendation: Add topic-specific help. If $ARGUMENTS matches a command name, show that command's description, examples, and common usage patterns. If no match, show the full list as before.

## Detailed Audit: Current Routing Patterns

### Commands requiring state checks (key entry points)

**build** -- Full cascade: init -> vision -> gameplan -> task selection. Already matches the locked decisions. The four-step routing pattern is used for both vision-missing and gameplan-missing cases. **Status: Good, audit only.**

**blueprint** -- Cascade: init -> vision check -> mode detection (new vs update). Routes to onboard if no vision. Uses conversational tone. **Status: Good, audit only.** Note: Does not have a "no .director/" routing message -- it just runs init silently and continues.

**inspect** -- Cascade: init -> checks for completed work (not vision/gameplan). This is appropriate because inspect verifies what was built, and if nothing was built, there is nothing to inspect. **Status: Good, but should add vision check** per CMDI-01 (every command detects project state). If VISION.md is template-only, suggest onboard.

**pivot** -- Full cascade: init (1a) -> vision (1b) -> gameplan (1c). Already matches. **Status: Good, audit only.**

### Commands that skip state validation (lightweight)

**help** -- Uses dynamic inject of STATE.md. Shows different header based on project existence. **Status: Good.**

**status** -- Uses dynamic inject. Checks for "NO_PROJECT". **Status: Good.**

**idea** -- Just checks .director/ exists (init if not), then captures. **Status: Good.**

**ideas** -- Just checks .director/ exists (init if not), then displays. **Status: Good.**

**brainstorm** -- Checks init + vision only (intentionally skips gameplan). **Status: Good.**

**resume** -- Uses dynamic inject. Checks for "NO_PROJECT". **Status: Good.**

**quick** -- Checks init only. Intentionally does not require vision or gameplan. **Status: Good.**

### Summary of Routing Audit

The routing is already well-implemented across all commands. Phase 9 work is:

1. **Inspect** needs vision check added (currently skips straight to completed-work check)
2. **All key-entry routing messages** need comparison for consistent phrasing
3. **Partial-state detection** needs to be verified -- when a user runs `/director:build` on a project that has vision + gameplan but has finished all tasks, the message should acknowledge completion rather than showing an error
4. **Onboard re-entry** already exists (Phase 2, decision 02-02) and matches CMDI-03

## Sources

### Primary (HIGH confidence)
- **Codebase audit** -- All 12 skill files read and analyzed in full
- **All 8 agent files** -- Reviewed for terminology and error patterns
- **reference/terminology.md** -- Never-use word list verified (30+ terms, 4 categories)
- **reference/plain-language-guide.md** -- Seven rules + routing template verified
- **hooks/hooks.json** -- Session lifecycle hooks reviewed
- **scripts/*.sh** -- All three scripts reviewed (init, session-start, state-save)
- **STATE.md decisions log** -- All 100+ decisions from Phases 1-8 reviewed for routing and inline text decisions

### Secondary (MEDIUM confidence)
- [Git revert documentation (Atlassian)](https://www.atlassian.com/git/tutorials/undoing-changes/git-revert) -- Confirmed revert creates new commits (not suitable for Director)
- [Git reset documentation (git-scm.com)](https://git-scm.com/docs/git-reset) -- Confirmed reset --hard removes commit from history (suitable for Director)
- [Claude Code skills documentation](https://code.claude.com/docs/en/skills) -- Confirmed skills are standalone Markdown with YAML frontmatter

### Tertiary (LOW confidence)
- None

## Metadata

**Confidence breakdown:**
- Routing patterns: HIGH -- direct codebase audit of all 12 skills
- Undo mechanism: HIGH -- git reset is well-documented, atomic commit strategy verified in build skill
- Inline text audit: HIGH -- every skill's $ARGUMENTS handling reviewed
- Error handling patterns: HIGH -- reference docs and existing skill patterns analyzed
- Terminology enforcement: HIGH -- reference/terminology.md is the existing implementation

**Research date:** 2026-02-09
**Valid until:** 2026-03-09 (stable -- all findings are internal codebase patterns)
