# Phase 7: Quick Mode & Ideas - Research

**Researched:** 2026-02-08
**Domain:** Claude Code skill authoring (prompt-driven skills, agent spawning, git operations, IDEAS.md management)
**Confidence:** HIGH

## Summary

Phase 7 adds two lightweight escape hatches to Director's workflow: (1) quick mode (`/director:quick`) for executing small changes without planning overhead, and (2) idea management (`/director:idea` for capture, `/director:ideas` for viewing/routing). Both commands already exist as placeholder skills from Phase 1. This phase rewrites them into fully functional implementations.

The work is well-scoped and follows established codebase patterns. Quick mode is essentially a simplified version of the build pipeline -- it reuses the same agents (builder, verifier, syncer) but skips the planning layer and operates inline. Idea capture is already partially functional (Phase 1 added basic append-to-IDEAS.md). The new `/director:ideas` (plural) command requires creating a new skill directory and SKILL.md. The routing conversation for ideas-to-action is new behavior but follows the established conversational patterns in the plain-language guide.

**Primary recommendation:** Structure as 3-4 plans: (1) quick mode execution with scope-based complexity analysis and builder spawning, (2) quick mode post-execution flow (verification, doc sync, commit, tracking), (3) idea capture rewrite (IDEAS.md format change to newest-first with removal support), and (4) ideas viewer with conversational routing. Plans 1+2 can potentially merge if they stay within a single skill file's scope.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- Complexity assessment uses **scope detection** (not file count) -- escalate if the change involves new features, architectural changes, or cross-cutting concerns
- When too complex, **explain and suggest**: "This looks bigger than a quick change because [reason]. Want to run /director:blueprint to plan it?" -- no auto-routing
- Verification after quick tasks: **Claude's discretion** -- skip for trivial changes, run Tier 1 structural check for anything substantial
- Documentation sync after quick tasks: **Claude's discretion** -- color tweaks skip sync, changes touching structure or new components get STATE.md updates
- User feedback during execution: **Claude's discretion** -- one-liner for trivial, brief play-by-play for multi-file changes
- Commit messages prefixed with `[quick]` -- e.g., `[quick] change button color to blue` -- visually distinct in git log
- Quick tasks tracked equally in STATE.md -- appear in recent activity and cost tracking alongside build tasks (no separate section)
- Never mention undo availability after quick tasks -- users who want it already know
- IDEAS.md uses a **flat chronological list** with timestamps -- newest first, zero friction
- Each idea captured **as-is** -- no reformatting, no summarizing, no follow-up questions at capture time
- Ideas can be any length: one-line thoughts or multi-paragraph musings
- When an idea is acted on, it is **removed** from IDEAS.md -- the file stays a clean inbox of pending ideas
- Acted-on ideas live in gameplan (if blueprinted) or git history (if quick-executed)
- Two separate commands: `/director:idea "..."` for capture, `/director:ideas` for viewing and acting
- `/director:ideas` shows the idea list, user picks one conversationally ("Let's work on #3")
- Three routing destinations: quick task (simple), blueprint (needs planning), brainstorm (needs exploration)
- **Conversational routing with confirmation**: Claude analyzes the idea, suggests a route with reasoning, user confirms before proceeding
- No auto-execution -- always a confirmation gate before routing
- Routing conversation should feel natural: "That's a straightforward change -- I can handle it as a quick task. Sound good?" not a menu of options

### Claude's Discretion
- Quick mode verification depth (skip vs Tier 1) based on change scope
- Quick mode doc sync depth based on change impact
- Quick mode user feedback verbosity based on change complexity

### Deferred Ideas (OUT OF SCOPE)
None -- discussion stayed within phase scope
</user_constraints>

## Standard Stack

This phase does not introduce new libraries or external dependencies. Director is a prompt-driven Claude Code plugin -- all "code" is Markdown skill files and agent definitions that instruct the AI how to behave.

### Core Components
| Component | Type | Purpose | Status |
|-----------|------|---------|--------|
| `skills/quick/SKILL.md` | Skill file | Quick mode execution flow | Exists as placeholder, needs full rewrite |
| `skills/idea/SKILL.md` | Skill file | Idea capture (`/director:idea`) | Partially functional, needs rewrite |
| `skills/ideas/SKILL.md` | Skill file | Idea viewer/router (`/director:ideas`) | **New** -- must create skill directory + file |
| `agents/director-builder.md` | Agent | Executes code changes | Exists, reused by quick mode |
| `agents/director-verifier.md` | Agent | Structural verification | Exists, optionally invoked by quick mode |
| `agents/director-syncer.md` | Agent | Documentation sync | Exists, optionally invoked by quick mode |

### Supporting Files
| File | Type | Purpose | Changes Needed |
|------|------|---------|----------------|
| `.director/IDEAS.md` | User data | Idea storage | Format change (newest-first, numbered) |
| `.director/STATE.md` | State | Progress tracking | Quick tasks added to Recent Activity |
| `scripts/init-director.sh` | Script | Project initialization | IDEAS.md template may need update |
| `reference/terminology.md` | Reference | Word choices | No changes |
| `reference/plain-language-guide.md` | Reference | Communication style | No changes |

## Architecture Patterns

### Pattern 1: Quick Mode as Simplified Build Pipeline

Quick mode follows the same flow as the build skill but skips planning layers. Here is the mapping:

| Build Skill Step | Quick Mode Equivalent |
|------------------|-----------------------|
| Step 1: Init check | Same -- check `.director/` exists |
| Step 2: Vision check | Skip -- quick mode does not require a vision |
| Step 3: Gameplan check | Skip -- quick mode does not require a gameplan |
| Step 4: Find next task | Skip -- user provides the task inline via `$ARGUMENTS` |
| Step 5: Assemble context | Simplified -- vision (if exists) + user request + git history + instructions |
| Step 6: Check uncommitted changes | Same -- stash or commit existing changes |
| Step 7: Spawn builder | Same -- spawn `director-builder` via Task tool |
| Step 8: Verify results | Conditional -- skip for trivial, Tier 1 for substantial |
| Step 9: Post-task sync | Conditional -- skip for trivial, STATE.md update for substantial |
| Step 10: Summary | Simplified -- plain summary, no boundary checks |

**Key differences from build:**
1. No task file exists -- the "task" is synthesized from `$ARGUMENTS`
2. Complexity analysis happens BEFORE execution (build has no equivalent)
3. Commit message format uses `[quick]` prefix
4. No `.done.md` rename (no task file to rename)
5. No step/goal boundary detection or Tier 2 behavioral checklists
6. Verification and doc sync are conditional (Claude's discretion)

### Pattern 2: Scope-Based Complexity Assessment

The complexity check runs before execution. It analyzes the user's natural-language request for scope indicators:

**Escalation triggers (suggests blueprint):**
- Request mentions multiple features ("add login AND a dashboard")
- Architectural terms ("redesign", "refactor", "overhaul", "restructure")
- Cross-cutting concerns ("change how all pages handle errors")
- New system-level capabilities ("add authentication", "set up payments")
- Multi-page or multi-system changes ("update the API and the frontend")

**Quick-appropriate indicators (proceed):**
- Single-file or single-component changes
- Cosmetic updates (colors, text, spacing, fonts)
- Small fixes (typo, broken link, wrong value)
- Adding a straightforward element (new button, new field, new page with simple content)
- Configuration changes

**Important:** The user ALWAYS has the final say. If they want to proceed despite the complexity warning, let them. The warning is a suggestion, not a gate.

### Pattern 3: IDEAS.md Newest-First Format

Current init template creates IDEAS.md with this format:
```markdown
# Ideas

_Captured ideas that aren't in the gameplan yet. Add with `/director:idea "..."`_
```

The existing idea skill (Phase 1) appends ideas below the header. Phase 7 changes to newest-first insertion:

```markdown
# Ideas

_Captured ideas that aren't in the gameplan yet. Add with `/director:idea "..."`_

- **[2026-02-08 14:30]** -- Add dark mode support for the entire app, including a toggle in settings and automatic detection of system preference
- **[2026-02-08 10:15]** -- Change the submit button color to match the brand
- **[2026-02-07 09:45]** -- Maybe add a search feature?
```

**Insertion mechanic:** New ideas are inserted AFTER the header line (the italic description) and BEFORE any existing ideas. This puts newest first without losing the header.

**Removal mechanic:** When an idea is acted on, the entire bullet line (including any multi-line content) is removed from IDEAS.md. The skill must handle multi-line ideas correctly -- an idea entry ends at the next `- **[` pattern or end of file.

**Numbering:** Ideas are NOT numbered in the file itself. When `/director:ideas` displays the list, it assigns display numbers dynamically (1, 2, 3...) so the user can reference them conversationally ("Let's do #3"). This avoids renumbering issues when ideas are removed.

### Pattern 4: New Skill Registration (`/director:ideas`)

To add a new command `/director:ideas`, create:
```
skills/
  ideas/           <-- new directory
    SKILL.md       <-- new skill file
```

The skill file follows the standard YAML frontmatter pattern used by all existing skills:
```yaml
---
name: ideas
description: "View and act on your saved ideas."
disable-model-invocation: true
---
```

Claude Code auto-discovers skills from the `skills/` directory. No manifest update needed -- the plugin system scans skill directories at load time. The new command will be available as `/director:ideas` based on the `name` field.

### Pattern 5: Conversational Routing for Ideas

When the user picks an idea from `/director:ideas`, the skill analyzes it and suggests a route:

**Route 1: Quick task** -- "That's a straightforward change -- I can handle it as a quick task. Sound good?"
- Trigger: idea describes a small, focused change
- If confirmed: execute inline as if they ran `/director:quick "[idea text]"`

**Route 2: Blueprint** -- "This one needs some planning -- it touches [reasons]. Want to add it to your gameplan with `/director:blueprint`?"
- Trigger: idea describes a feature, system, or cross-cutting concern
- If confirmed: route to blueprint with idea as context

**Route 3: Brainstorm** -- "This is interesting but needs some exploration first. Want to brainstorm it? We can figure out the approach together."
- Trigger: idea is vague, exploratory, or the user says "I'm not sure how to approach this"
- If confirmed: route to brainstorm with idea as context

**Execution after routing:**
- Quick route: skill handles execution directly (same flow as quick skill)
- Blueprint route: tell the user to run `/director:blueprint "[idea text]"` -- do NOT auto-execute another command
- Brainstorm route: tell the user to run `/director:brainstorm "[idea text]"` -- do NOT auto-execute another command

### Pattern 6: Quick Mode Context Assembly

Quick mode assembles a lighter context than the build skill since there is no task file:

```xml
<vision>
[Full contents of VISION.md, if it exists and has real content]
[If no vision: omit this section entirely]
</vision>

<task>
Quick task: [user's request from $ARGUMENTS]

What to do: [user's request, verbatim]
Scope: Keep changes minimal and focused on exactly what was requested.
</task>

<recent_changes>
Recent progress:
- [last 5 git commits]
</recent_changes>

<instructions>
This is a quick task -- make the smallest change that satisfies the request.
Do not expand scope beyond what was asked.
Create exactly one git commit with the prefix [quick] in the message.
Commit format: [quick] [plain-language description of what changed]
[If verification requested: After committing, spawn director-verifier to check your work.]
[If doc sync requested: After verification, spawn director-syncer with a summary of what changed.]
</instructions>
```

**Context budget:** Quick mode uses a smaller context budget since tasks are simpler. The 60K token threshold from the build skill still applies but is unlikely to be hit since quick contexts are much smaller (no step file, no full task spec).

### Pattern 7: Quick Mode STATE.md Integration

Quick tasks appear in STATE.md's Recent Activity alongside build tasks. The key difference is there is no task file path for the idempotency key.

**Recent Activity format for quick tasks:**
```
- [2026-02-08 14:30] Quick: Changed button color to blue (~8K tokens) [quick]
```

The `[quick]` marker at the end serves as the type indicator (replaces the task file path used by build tasks). Cost tracking works the same way as build tasks -- chars/4 * 2.5 for token estimate.

**Important:** Quick tasks do NOT update the Progress section of STATE.md (no goal/step/task tracking since they are outside the gameplan hierarchy). They ONLY update Recent Activity and Cost Summary.

### Anti-Patterns to Avoid

- **Don't require vision/gameplan for quick mode.** Quick mode is the escape hatch for users who want to make changes without the full workflow. Requiring onboarding defeats the purpose.
- **Don't create task files for quick tasks.** Quick tasks live outside the gameplan hierarchy. They have no step, no goal, no task file. Their record is the git commit and the STATE.md activity entry.
- **Don't number ideas in the file.** Numbers create maintenance burden when ideas are removed. Assign display numbers dynamically when showing the list.
- **Don't auto-route ideas.** Always confirm with the user before taking action on an idea. The confirmation gate is a locked decision.
- **Don't show routing as a menu.** "I see three options: A) quick task, B) blueprint, C) brainstorm" violates the conversational routing decision. Instead, suggest ONE route with reasoning and let the user agree, disagree, or choose differently.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Code execution | Custom inline execution logic | Existing `director-builder` agent via Task tool | Builder already handles code changes, commits, follows codebase patterns |
| Structural verification | Custom verification logic | Existing `director-verifier` agent via Task tool | Verifier already knows stub detection, orphan detection, wiring checks |
| Documentation sync | Custom STATE.md update logic | Existing `director-syncer` agent via Task tool | Syncer already handles STATE.md, cost tracking, activity logging |
| Complexity heuristics | ML-based or token-counting complexity analysis | Simple scope-based keyword/pattern analysis | The user decided on scope detection, not file count; keep it simple |
| Idea storage format | Database or JSON storage | Flat Markdown in IDEAS.md | Locked decision: flat chronological list with timestamps |

## Common Pitfalls

### Pitfall 1: Quick mode init-script dependency
**What goes wrong:** Quick mode tries to read `.director/VISION.md` before `.director/` exists.
**Why it happens:** Quick mode does not require onboarding, but the init script must still run to create the directory structure.
**How to avoid:** Run the init script check first (same as every other skill), but make vision/gameplan optional. If VISION.md exists and has real content, include it in context. If not, skip it silently.
**Warning signs:** Error messages about missing files when running quick on a brand new project.

### Pitfall 2: Ideas removal corrupting file
**What goes wrong:** Removing an idea from IDEAS.md breaks formatting -- partial lines left, header deleted, wrong idea removed.
**Why it happens:** Multi-line ideas make simple line-based removal unreliable. An idea might span multiple lines if the user wrote a paragraph.
**How to avoid:** Define idea entries as starting with `- **[` pattern and ending at the next occurrence of that pattern or end of file. When removing, remove everything from one `- **[` to just before the next `- **[`.
**Warning signs:** IDEAS.md with orphaned text, missing header, or broken formatting after removal.

### Pitfall 3: Quick mode creating commits when nothing changed
**What goes wrong:** User runs `/director:quick` but the change is already done, or the builder decides no changes are needed. An empty commit gets created.
**Why it happens:** The builder might read the codebase and find the requested change already exists.
**How to avoid:** After the builder completes, check `git status --porcelain` before attempting any commit. If nothing changed, tell the user "Looks like this is already done -- no changes needed."
**Warning signs:** Empty commits in git history with `[quick]` prefix.

### Pitfall 4: Uncommitted changes from quick mode conflicting with build
**What goes wrong:** Quick mode makes changes but verification/sync fails, leaving uncommitted changes. User then runs `/director:build` which also checks for uncommitted changes.
**How to avoid:** Quick mode must follow the same uncommitted-changes check as the build skill (Step 6). Also, quick mode should always complete its commit cycle -- if verification finds issues, fix and amend, don't leave partial state.
**Warning signs:** `git status` showing unexpected changes after a quick task.

### Pitfall 5: IDEAS.md newest-first insertion breaking existing ideas
**What goes wrong:** The rewritten idea skill inserts at the top, but the init template currently has the header at line 1 and the italic description at line 3. Inserting "after the header" could mean different things.
**Why it happens:** The exact insertion point is ambiguous -- "after the header" could mean after `# Ideas` or after the italic description line.
**How to avoid:** Define the insertion point precisely: after the last header/description line (the italic `_Captured ideas..._` line) and before the first idea entry (or end of file if no ideas exist). The skill should read the file, find the `_Captured ideas` line, and insert after it.
**Warning signs:** Ideas appearing above the file header, or between the header and the description.

### Pitfall 6: Quick mode and the `[quick]` commit prefix
**What goes wrong:** The builder agent creates a commit message but forgets the `[quick]` prefix because its standard behavior is plain-language commit messages.
**Why it happens:** The builder's instructions (in the agent definition) say "plain-language message describing what was built" -- the `[quick]` prefix must be explicitly specified in the instructions passed to the builder.
**How to avoid:** The quick skill's assembled context must explicitly instruct the builder: "Commit format: [quick] [description]". This overrides the builder's default commit format for quick tasks only.
**Warning signs:** Quick task commits without the `[quick]` prefix in git log.

## Code Examples

### Quick Mode Skill Structure (Skeleton)

```markdown
---
name: quick
description: "Make a fast change without full planning. Best for small, focused tasks."
disable-model-invocation: true
---

You are Director's quick command. Execute small, focused changes without the full planning workflow.

**Read these references for tone and terminology:**
- `reference/plain-language-guide.md`
- `reference/terminology.md`

Follow all N steps below IN ORDER.

---

## Step 1: Init check
[Check .director/ exists, run init if not]

## Step 2: Check for a task description
[Check $ARGUMENTS, prompt if empty]

## Step 3: Analyze complexity (scope detection)
[Read request, check for escalation triggers]
[If complex: explain and suggest blueprint, wait for response]
[If user insists: proceed anyway]

## Step 4: Check for uncommitted changes
[Same pattern as build skill Step 6]

## Step 5: Assemble context
[Build XML context: vision (optional), task from $ARGUMENTS, recent git, instructions]
[Include [quick] commit prefix instruction]
[Conditionally include verification/sync instructions based on scope]

## Step 6: Spawn builder
[Task tool spawns director-builder with assembled context]

## Step 7: Verify results
[Check for new commit, handle partial completion]
[Conditional: run Tier 1 verification for substantial changes]
[Conditional: run doc sync for structural changes]

## Step 8: Post-task tracking
[Update STATE.md Recent Activity with [quick] marker]
[Update Cost Summary]
[Amend-commit any .director/ changes]

## Step 9: Summary
[Plain-language summary of what changed]
[Brief for trivial, detailed for multi-file]
[Never mention undo]

---

## Language Reminders
[Same as build skill]

$ARGUMENTS
```

### Idea Capture Skill (Newest-First Insertion)

```markdown
## Step 3: Capture the idea

Read `.director/IDEAS.md`. Find the line containing `_Captured ideas` (the italic description).

Insert the new idea on the NEXT line after the description, pushing existing ideas down:

Format:
- **[YYYY-MM-DD HH:MM]** -- [the idea text from $ARGUMENTS, verbatim]

If the idea text spans multiple lines (the user wrote a paragraph), keep it as-is.
Do not reformat, summarize, or ask follow-up questions.

Then say: "Got it! Saved to your ideas list."
```

### Ideas Viewer/Router Skill (Conversational Routing)

```markdown
## Step 3: Display ideas

Read `.director/IDEAS.md`. Parse all idea entries (lines starting with `- **[`).

If no ideas exist, say:
"No ideas saved yet. You can capture one anytime with /director:idea followed by your thought."
Stop here.

If ideas exist, display them with numbers:

"Here are your ideas:

1. [2026-02-08] Add dark mode support for the entire app...
2. [2026-02-08] Change the submit button color to match the brand
3. [2026-02-07] Maybe add a search feature?

Which one do you want to work on? Just say the number or describe it."

Wait for the user to pick one.

## Step 4: Analyze and route

Read the selected idea. Consider:
- How complex is the change?
- Does it touch one thing or many?
- Is the idea clear enough to act on, or does it need exploration?

Suggest ONE route with reasoning:

Simple change: "That's a straightforward change -- I can handle it as a quick task. Sound good?"
Needs planning: "This one would touch [X, Y, Z] -- it needs some planning. Want to add it to your gameplan?"
Needs exploration: "This is interesting but needs some thinking first. Want to brainstorm it?"

Wait for confirmation before proceeding.

## Step 5: Execute routing

If confirmed for quick: Remove the idea from IDEAS.md, then execute as if the user ran /director:quick with the idea text.
If confirmed for blueprint: Remove the idea from IDEAS.md, then suggest running /director:blueprint "[idea text]".
If confirmed for brainstorm: Keep the idea in IDEAS.md (not acted on yet), then suggest running /director:brainstorm "[idea text]".
```

### Ideas Removal from IDEAS.md

```markdown
## Removing an idea

To remove idea #N from IDEAS.md:

1. Read the file and parse all idea entries
2. Find the Nth entry (1-indexed)
3. Determine the entry's full extent:
   - Starts at the line beginning with `- **[`
   - Ends just before the next line beginning with `- **[` (or end of file)
4. Remove those lines from the file
5. Write the updated file back
```

## State of the Art

| Old Approach (Phase 1) | Current Approach (Phase 7) | Impact |
|-------------------------|---------------------------|--------|
| Quick skill: placeholder with "future update" message | Full execution pipeline with builder, optional verification, tracking | Quick mode becomes functional |
| Idea skill: simple append to bottom of IDEAS.md | Newest-first insertion with proper format | Better UX, most recent ideas visible first |
| No ideas viewer | `/director:ideas` with conversational routing | Users can act on captured ideas |
| Ideas append-only | Ideas removed when acted on | IDEAS.md stays a clean inbox |

## Open Questions

1. **Quick mode for projects without vision/gameplan**
   - What we know: Quick mode should work without onboarding. The init script runs to create `.director/` but vision/gameplan are not required.
   - What's unclear: Should quick mode include VISION.md in the builder's context if it exists? Including it gives better context for changes; excluding it keeps the context minimal.
   - Recommendation: Include VISION.md if it has real content (same detection as onboard/build). Omit if template-only. This gives the builder better context when available without requiring onboarding.

2. **Brainstorm routing and idea removal timing**
   - What we know: Quick and blueprint routes remove the idea from IDEAS.md immediately (idea is "acted on"). Brainstorm route keeps the idea because exploration might not lead to action.
   - What's unclear: What happens if the brainstorm leads to action -- does the brainstorm skill remove the idea, or does the user need to manually clean up?
   - Recommendation: Brainstorm does NOT remove from IDEAS.md. If the brainstorm leads to a concrete outcome (task or blueprint), the user can remove it manually or the routing from brainstorm's "save as idea" / "create task" flow handles it. Keep it simple for Phase 7.

3. **Cost tracking for quick tasks without goal context**
   - What we know: Build tasks track cost per goal via the syncer. Quick tasks exist outside the gameplan hierarchy.
   - What's unclear: How should quick task costs roll up in the Cost Summary? They have no goal.
   - Recommendation: Add costs to a "Quick tasks" line item in Cost Summary, separate from goal-specific costs. Or simply add to the project total without goal attribution. The simplest approach: quick task costs appear only in Recent Activity and the project total, not attributed to any goal.

## Sources

### Primary (HIGH confidence)
- **Existing codebase analysis** -- All skill files, agent definitions, init scripts, reference docs, and planning artifacts read directly from the repository
- **CONTEXT.md decisions** -- User-locked decisions from discussion phase
- **PRD sections 8.1.9 and 8.1.11** -- Official requirements for quick mode and idea capture

### Secondary (MEDIUM confidence)
- **Build skill patterns** -- Phase 4+5+6 established the builder spawning, verification, and tracking patterns that quick mode adapts
- **Prior STATE.md decisions** -- Phase 6 established cost tracking, activity logging, and progress calculation patterns

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH -- all components are established codebase patterns
- Architecture: HIGH -- quick mode is a known simplification of the build pipeline; idea management is straightforward file manipulation
- Pitfalls: HIGH -- identified from direct analysis of existing code and format decisions
- Code examples: HIGH -- based on existing skill patterns in the codebase

**Research date:** 2026-02-08
**Valid until:** 2026-03-08 (stable -- plugin authoring patterns don't change rapidly)
