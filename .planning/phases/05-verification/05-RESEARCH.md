# Phase 5: Verification - Research

**Researched:** 2026-02-08
**Domain:** Claude Code plugin verification pipeline -- Tier 1 structural checks, Tier 2 behavioral checklists, auto-fix retry loops, on-demand inspect command
**Confidence:** HIGH

## Summary

Phase 5 builds Director's three-tier verification system. The good news: most of the raw components already exist. The verifier agent has full stub/orphan/wiring detection logic. The debugger agent has investigation and fix capabilities. The builder already spawns the verifier after committing. What is missing is the orchestration layer that ties these together into the user-facing experience described in the CONTEXT.md decisions: invisible Tier 1 that surfaces only on issues, Tier 2 behavioral checklists at step boundaries, an auto-fix retry loop with user consent, the inspect command, and celebration/progress feedback at step/goal boundaries.

The primary technical challenge is that the current build pipeline runs Tier 1 verification INSIDE the builder agent's session. The builder spawns the verifier, fixes issues, and amends its commit -- all before returning to the build skill. Phase 5 needs to make the verification results visible at the skill level so the build skill can: (a) present issues in the decided two-severity format, (b) offer auto-fix with user consent, (c) orchestrate the debugger retry loop, and (d) detect step/goal boundaries and trigger Tier 2 checklists. This means modifying the build skill's post-task flow (Steps 8-10) to incorporate verification result handling, auto-fix orchestration, and boundary detection.

The inspect command is a separate entry point that reuses the same verification agents but triggers on demand rather than automatically. It needs scope awareness (default: current step, optional: goal or all) and must assemble context appropriate for the scope being checked.

**Primary recommendation:** Modify the build skill to surface verification results and orchestrate auto-fix, update the verifier to return structured results the skill can parse, build Tier 2 checklist generation into the verifier (or a new section of the inspect skill), implement the debugger retry loop, and rewrite the inspect skill from stub to functional command.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

#### Issue reporting tone
- Confident assistant voice -- direct and efficient, not casual or dramatic
- Detail level: what + why + where ("The settings page has placeholder content in the header section -- users would see 'TODO' text")
- Group issues by severity: "Needs attention" (blocking) section and "Worth checking" (informational) section
- Only offer auto-fix for issues Director can actually handle (wiring, stubs, placeholder replacement). Report-only for things that need human judgment

#### Behavioral checklist flow
- Trigger: step boundaries only -- checklist runs when all tasks in a step are complete. Goal-level checks happen when all steps pass
- Presentation: full checklist shown upfront, user reports results in any order as they go
- No fixed checklist size -- Claude sizes based on step complexity (small steps get fewer items)

#### Auto-fix experience
- Progress updates during fix cycles: "Investigating the issue... Found the cause... Applying fix (attempt 1 of 3)..." Real-time status
- Always ask before fixing: "Found 2 issues. Want me to try fixing them?" User approves before attempts begin
- Retry cap: Claude decides per issue based on complexity -- simple wiring gets fewer retries, deeper bugs get more

#### Inspect command scope
- Smart default: `/director:inspect` checks current step
- Accepts arguments: `/director:inspect goal`, `/director:inspect all`
- On-demand -- user controls when to run broader checks

#### Celebration and progress feedback
- Combine outcome + progress: "User authentication is working! That's Step 2 done -- 3 of 5 through your first goal."
- Goal completion is a bigger moment -- summary of everything built, total progress, and what's next. Step completion gets a shorter note
- Partial passes lead with wins: "4 of 5 checks passed! One thing needs attention: [issue]."

### Claude's Discretion
- Checklist item count per step (based on step complexity)
- Retry count per issue (based on issue complexity)
- Auto-fix handoff messaging when giving up (explain what was tried, offer options -- Claude picks based on situation)
- How behavioral checklist results are reported (Claude picks whatever feels most natural for Director)

### Deferred Ideas (OUT OF SCOPE)
None -- discussion stayed within phase scope
</user_constraints>

## Standard Stack

This phase uses no external libraries. Director is a declarative Claude Code plugin -- all components are Markdown files (skills, agents, reference docs) and shell scripts. The "stack" is the Claude Code plugin system itself.

### Core

| Component | Format | Purpose | Why Standard |
|-----------|--------|---------|--------------|
| `skills/build/SKILL.md` | Markdown + YAML frontmatter | Build pipeline -- needs post-task verification flow update | Already exists; Steps 8-10 need verification integration |
| `skills/inspect/SKILL.md` | Markdown + YAML frontmatter | On-demand verification command | Currently a stub; needs full rewrite |
| `agents/director-verifier.md` | Markdown + YAML frontmatter | Structural verification (Tier 1) | Already exists with full detection logic |
| `agents/director-debugger.md` | Markdown + YAML frontmatter | Issue investigation and auto-fix | Already exists with investigation process |
| `agents/director-builder.md` | Markdown + YAML frontmatter | Task execution -- spawns verifier/debugger | Already exists; may need minor updates for verification flow |
| `reference/verification-patterns.md` | Markdown | Stub/orphan/wiring detection patterns | Already exists with complete pattern library |

### Supporting

| Component | Format | Purpose | When to Use |
|-----------|--------|---------|-------------|
| `reference/plain-language-guide.md` | Markdown | Tone and language rules for user-facing output | All user-facing verification messages |
| `reference/terminology.md` | Markdown | Word choice rules | Avoiding jargon in issue reports |
| `.director/STATE.md` | Markdown | Progress tracking -- step/goal completion status | Boundary detection for Tier 2 triggers |
| `.director/GAMEPLAN.md` | Markdown | Goals/steps/tasks hierarchy | Inspect scope resolution |
| `.director/goals/*/STEP.md` | Markdown | Step context for behavioral checklist generation | Tier 2 checklist items derived from step description |

### What NOT to Use

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| Test framework integration | Tier 3 is Phase 2 (deferred) | AI-driven code reading for Tier 1 |
| Custom retry/backoff library | Simple sequential retries sufficient | Counting attempts in skill instructions |
| Separate checklist state file | Checklist is a single conversation flow | Inline conversation in the skill |
| Complex issue tracking system | Issues are transient (fix now or report) | Verifier output consumed directly by skill |
| Background agent for verification | User needs to see results immediately | Foreground sub-agent spawning via Task tool |

## Architecture Patterns

### Overall Architecture

```
/director:build (post-task)          /director:inspect (on-demand)
        |                                     |
        v                                     v
  [Build SKILL.md]                    [Inspect SKILL.md]
  Steps 8-10 updated                  Full verification flow
        |                                     |
        +--- Tier 1 ----+--------------------+
        |               |
        v               v
  [director-verifier]   |
  Structural checks     |
        |               |
        v               v
  Issues found? -----> [director-debugger]
        |               Auto-fix with retries
        v               |
  Step complete? -----> |
        |               |
        v               v
  [Tier 2 Checklist]   [Results to user]
  Behavioral checks
```

### Pattern 1: Verification Result Surfacing in Build Pipeline

**What:** The build skill's post-task flow (currently Steps 8-10) needs to receive and act on verification results from the builder/verifier pipeline. Currently the builder handles verification internally. Phase 5 changes the flow so that verification results are visible at the skill level.

**When to use:** Every `/director:build` invocation after the builder returns.

**Current flow (Phase 4):**
1. Builder commits
2. Builder spawns verifier internally
3. Builder fixes "needs attention" issues and amends commit
4. Builder spawns syncer
5. Build skill checks for commit, handles sync, shows summary

**New flow (Phase 5):**
1. Builder commits and spawns verifier internally
2. Builder fixes clear-cut issues (broken imports, typos) and amends commit
3. Builder returns to build skill with verification summary
4. Build skill checks the builder's output for remaining issues
5. If issues remain that need user visibility: present in two-severity format
6. If issues are auto-fixable and user consents: spawn debugger for retry loop
7. Build skill detects step boundary (all tasks .done.md in current step)
8. If step complete: trigger Tier 2 behavioral checklist
9. Show celebration/progress feedback

**Key design decision:** The builder still does a first pass of verification internally (fixing obvious issues like broken imports before returning). This keeps the invisible-on-success principle. But if the verifier finds issues the builder could not resolve, those bubble up to the build skill, which presents them to the user with the decided format and offers auto-fix.

**How the builder communicates verification results to the skill:** The builder's output (returned via Task tool) already includes a summary. The builder should include verification status in its output. If verification passed cleanly, the builder says "Everything checks out" (or similar). If issues remain, the builder includes them structured in its output. The build skill reads the builder's output to determine next steps.

### Pattern 2: Auto-Fix Retry Loop

**What:** When verification finds issues that Director can handle (stubs, wiring, placeholder replacement), the build skill orchestrates a debugger-based retry loop with user consent.

**When to use:** When Tier 1 verification surfaces fixable issues after the builder's first pass.

**Flow:**
```
1. Build skill receives verification results with issues
2. Classify issues:
   - Auto-fixable: stubs, broken wiring, placeholder content, missing imports
   - Report-only: architectural decisions, missing features, design choices
3. Present to user:
   "Found 2 things that need attention:
    1. The settings page has placeholder content... (auto-fixable)
    2. The API endpoint doesn't handle errors... (needs your input)

    I can fix #1 automatically. Want me to try?"
4. If user approves:
   a. Spawn director-debugger with issue context
   b. Show progress: "Investigating the issue... Found the cause... Applying fix (attempt 1 of 3)..."
   c. After fix, spawn director-verifier again to check
   d. If fixed: amend commit, continue
   e. If not fixed: try again (up to retry cap)
   f. If all retries exhausted: explain what was tried, suggest manual fix
5. If user declines: continue with issues noted
```

**Retry cap logic (Claude's Discretion):**
- Simple wiring fixes (missing import, wrong path): 2 retries max
- Placeholder/stub replacement: 3 retries max
- Complex integration issues: 3-5 retries max
- The debugger agent already has retry awareness in its system prompt ("This is attempt 2 of 3")

**Implementation:** The build skill uses a loop with a counter. Each iteration spawns the debugger, then re-runs the verifier. The loop exits when either: all issues resolved, retry cap reached, or debugger reports "needs manual attention."

### Pattern 3: Step/Goal Boundary Detection and Tier 2 Trigger

**What:** After a task completes and Tier 1 passes, the build skill checks whether the step is now complete (all tasks are .done.md). If so, it triggers Tier 2 behavioral verification.

**When to use:** After every successful task in the build pipeline. The check itself is lightweight (file listing); Tier 2 only triggers at boundaries.

**Boundary detection algorithm:**
```
1. After task completes and verification passes:
2. List files in current step's tasks/ directory
3. Count total .md files and .done.md files
4. If all task files end in .done.md: STEP IS COMPLETE
5. If step is complete:
   a. Check if all steps in the current goal are complete
   b. If yes: GOAL IS COMPLETE (bigger celebration, broader checklist)
   c. If no: step complete only
6. If step/goal is complete: trigger Tier 2
```

**Tier 2 checklist generation:**
The build skill (or inspect skill) assembles context about the completed step/goal and uses Claude's intelligence to generate a behavioral checklist. The checklist items should be:
- Derived from the step's STEP.md description and the tasks' acceptance criteria
- Written as things the user can TRY and OBSERVE ("Open the login page. Try entering a wrong password. What happens?")
- Sized based on step complexity (Claude's Discretion -- small steps get 3-5 items, large steps get 7-10)

**Checklist context assembly:**
```xml
<step>
[Full contents of completed STEP.md]
</step>

<completed_tasks>
[List of all .done.md task descriptions in this step]
</completed_tasks>

<vision>
[Full VISION.md for overall context]
</vision>

<instructions>
Generate a behavioral checklist for this step. Each item should be something the user can try and observe.
Write items as plain-language instructions: "Try X. What happens?" or "Open Y and check that Z."
Size the checklist based on step complexity.
</instructions>
```

### Pattern 4: Inspect Command Architecture

**What:** The inspect command is a standalone entry point for on-demand verification. It runs the same verification agents but with scope awareness.

**When to use:** User runs `/director:inspect` (or with arguments).

**Scope resolution:**
```
/director:inspect           -> current step (smart default)
/director:inspect goal      -> current goal (all steps)
/director:inspect all       -> entire project (all goals)
/director:inspect "login"   -> focused check on a specific topic
```

**Flow:**
```
1. Init check (same as build)
2. Check for completed work (STATE.md)
3. Determine scope from $ARGUMENTS
4. Assemble verification context for scope:
   - Step scope: current step's STEP.md + all task files
   - Goal scope: goal's GOAL.md + all steps + all tasks
   - All scope: GAMEPLAN.md + all goals
5. Spawn director-verifier with assembled context
6. If issues found:
   a. Present in two-severity format
   b. Offer auto-fix for fixable issues
   c. Run debugger retry loop if user approves
7. If everything clean:
   a. Generate Tier 2 behavioral checklist for the scope
   b. Present checklist, collect user results
   c. Celebrate if all pass
8. Show progress: "Step 2 is complete! You're 3 of 5 through your first goal."
```

**Key difference from build pipeline:** In the build pipeline, Tier 1 runs automatically and invisibly. In inspect, the user explicitly asked for verification, so ALL results are shown (even "everything checks out"). The inspect flow also always includes Tier 2, whereas the build flow only triggers Tier 2 at step/goal boundaries.

### Pattern 5: Tier 2 Behavioral Checklist Interaction

**What:** A conversational flow where the user works through a checklist of things to try and reports results.

**When to use:** Step/goal boundaries in build pipeline, or anytime during inspect.

**Interaction pattern:**
```
Director: "Step 2 is complete! Here's a quick checklist to make sure everything works:

1. Open the login page and try signing in with a valid account
2. Try signing in with a wrong password -- you should see an error
3. Check that the dashboard loads after login
4. Try logging out -- you should be back at the login page

Try these out and let me know how they go!"

User: "1-3 work fine but 4 doesn't redirect properly"

Director: "3 of 4 checks passed! The logout redirect needs attention.

The logout function runs but doesn't send you back to the login page.
Want me to look into this?"
```

**Key design points:**
- Full checklist shown upfront (locked decision)
- User reports in any order (locked decision)
- No fixed size (Claude's Discretion -- based on step complexity)
- Results processing: the skill interprets the user's natural-language response and maps it to pass/fail for each item
- Partial passes lead with wins (locked decision): "3 of 4 checks passed!"

### Anti-Patterns to Avoid

- **Running Tier 1 twice (builder internal + skill re-run):** The builder already runs verification internally. The skill should not spawn a separate verifier for the same check. Instead, the skill should read the builder's verification output. Only spawn a NEW verifier if the debugger made changes that need re-verification.

- **Showing Tier 1 results when everything passes:** Locked decision says Tier 1 is invisible unless issues found. Don't say "Verification passed!" after every task. Just proceed to the post-task summary silently.

- **Offering auto-fix for non-automatable issues:** Only offer fixes for things Director can actually handle: stubs, wiring, placeholders. Don't offer to fix architectural decisions, missing features, or things requiring human design judgment.

- **Blocking the user on Tier 2:** The behavioral checklist is presented but not enforced. If the user wants to continue building without completing the checklist, let them. The checklist is guidance, not a gate.

- **Running Tier 2 after every task:** Tier 2 only runs at step boundaries (locked decision). Don't generate behavioral checklists after individual tasks -- that would be noisy and slow.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Stub/orphan detection | Custom code analysis rules | director-verifier agent + verification-patterns.md | Already built with full detection patterns; AI-driven reading is more flexible than rules |
| Issue investigation | Custom debugging pipeline | director-debugger agent | Already built with investigation process, fix rules, retry awareness |
| Issue classification | Custom severity classifier | Verifier's existing two-severity format | "Needs attention" and "worth checking" already defined and used |
| Checklist generation | Static checklist templates | Claude intelligence with step/task context | Dynamic generation produces better, more relevant items |
| Step boundary detection | Custom state machine | File system check (all .done.md?) | Simple directory listing is sufficient |
| Progress calculation | Custom progress tracker | Count .done.md files vs total .md files | File naming convention already handles this |
| Retry orchestration | Custom retry framework | Simple counter in skill instructions | 3-5 retries don't need sophisticated backoff |

**Key insight:** Phase 5 is primarily an orchestration and integration problem. The detection (verifier), fixing (debugger), patterns (verification-patterns.md), and language rules (plain-language-guide.md) already exist. The work is wiring them together into the user-facing flows described in the CONTEXT.md decisions.

## Common Pitfalls

### Pitfall 1: Builder Swallows Verification Results

**What goes wrong:** The builder agent runs verification internally, fixes issues, and returns a clean summary to the build skill. The skill never sees the issues that were found and fixed, making the verification flow invisible even when it shouldn't be.

**Why it happens:** The builder's current instructions (rule 6) say to fix "needs attention" issues and amend the commit. If the builder successfully fixes everything, its output to the skill just says the task is complete. But if the builder CANNOT fix an issue, it needs to communicate that back clearly.

**How to avoid:** Update the builder's instructions to always include verification status in its output. Something like:
- "Verification: clean" (no issues found)
- "Verification: 2 issues found, 2 fixed" (all issues handled internally)
- "Verification: 2 issues found, 1 fixed, 1 remaining -- [description of remaining issue]" (some issues need escalation)

The build skill reads this to determine whether to surface issues to the user.

**Warning signs:** Issues exist in the code but the user is never informed. The build flow always shows "everything is fine" even when the verifier found things.

### Pitfall 2: Auto-Fix Changes Without User Consent

**What goes wrong:** The debugger makes code changes to fix issues, but the user never approved the fix. This violates the locked decision: "Always ask before fixing."

**Why it happens:** The builder already fixes simple issues internally without asking. The Phase 5 auto-fix flow needs to be distinct from the builder's internal fix loop.

**How to avoid:** Distinguish two levels of fixing:
1. **Builder-internal fixes:** Simple issues the builder catches during its own verification (broken imports it just created, typos). These are pre-commit fixes that don't need user consent because they're part of the task implementation.
2. **Post-return auto-fix:** Issues that survive the builder's pass and are presented to the user. These ALWAYS require user consent before the debugger is spawned.

The key boundary is: builder handles its own mess silently. Anything that survives to the skill level requires user approval.

**Warning signs:** Code changes appear that the user didn't approve. The debugger runs without the "Want me to try fixing them?" prompt.

### Pitfall 3: Tier 2 Checklist Generated from Wrong Context

**What goes wrong:** The behavioral checklist asks the user to test things that haven't been built yet, or misses things that were built.

**Why it happens:** Tier 2 checklist is generated from step/task descriptions, not from what was actually built. If the implementation diverged from the plan (which it often does), the checklist won't match reality.

**How to avoid:** When generating the Tier 2 checklist, include BOTH the step/task descriptions AND the git log of what was actually built (commit messages from all tasks in the step). This gives the AI both the intent (what should have been built) and the reality (what was actually built) to generate relevant items.

**Warning signs:** Checklist items reference features that don't exist. User reports confusion about what to test.

### Pitfall 4: Inspect Scope Overload

**What goes wrong:** User runs `/director:inspect all` on a project with 50+ completed tasks. The verifier tries to check everything and hits context/turn limits.

**Why it happens:** The verifier has a maxTurns limit (30). Checking an entire codebase may exceed this.

**How to avoid:** For broad scopes, the inspect skill should:
1. Prioritize recent work (check newest tasks/steps first)
2. Focus on wiring between components (orphans across the full codebase)
3. Skip individual stub detection for long-completed tasks
4. Present results progressively rather than waiting for full completion

**Warning signs:** Verifier returns partial results. Inspect takes very long and times out.

### Pitfall 5: Celebration Timing vs Verification

**What goes wrong:** The build skill celebrates step completion before Tier 2 runs, then Tier 2 finds issues. The celebration feels premature.

**Why it happens:** The natural flow is: task complete -> detect boundary -> celebrate -> run Tier 2. But Tier 2 might reveal problems.

**How to avoid:** When a step boundary is detected:
1. Run Tier 2 checklist first
2. If all items pass: THEN celebrate ("User authentication is working! That's Step 2 done -- 3 of 5 through your first goal.")
3. If some items fail: celebrate the wins, flag the issues ("4 of 5 checks passed! One thing needs attention: [issue].")

The celebration includes the Tier 2 results, not precedes them.

### Pitfall 6: Debugger Retry Loop Never Terminates

**What goes wrong:** The debugger keeps trying different approaches but none work, and the retry loop runs indefinitely.

**Why it happens:** No hard upper limit enforced at the skill level. The debugger's instructions mention retries but the skill orchestrating the loop might not count properly.

**How to avoid:** Implement a hard cap at the skill level:
- Track attempt count in a variable
- Maximum 5 retries across all issues in a single verification pass
- After max retries: stop, explain clearly what was tried, suggest manual next steps
- The debugger's own system prompt already has retry awareness ("This is attempt 2 of 3")

**Warning signs:** Auto-fix takes very long. User sees "attempt 4 of 3" messages. The same issue is fixed and broken repeatedly.

## Code Examples

### Example 1: Builder Verification Output Format

The builder agent should include verification status in its output so the build skill can act on it.

```markdown
<!-- Builder output when verification passes cleanly -->
The login page is ready. Users can type their email and password to sign in.

Verification: clean -- all files are properly connected and contain real implementation.

<!-- Builder output when issues remain after internal fixes -->
The login page is mostly ready. Users can sign in with email and password.

Verification: 2 issues found, 1 fixed internally.
Remaining issue:
- Needs attention: The password reset link on the login page points to a page that doesn't exist yet.
  Location: src/pages/Login.tsx, line 34
  This is likely planned for a future task.
```

### Example 2: Build Skill Post-Task Verification Flow (Updated Steps 8-10)

```markdown
## Step 8: Verify builder results

Check the builder's output for verification status:

### 8a: Check for a new commit
[Same as current -- verify commit exists]

### 8b: Check verification results
Read the builder's output for verification status:

**If "Verification: clean":**
Verification passed silently. Continue to Step 9.

**If remaining issues reported:**

1. Classify each issue:
   - AUTO-FIXABLE: stubs, broken wiring, placeholder content, missing imports
   - REPORT-ONLY: missing features, architectural choices, design decisions

2. Present issues in two-severity format:

   If there are "Needs attention" issues:
   > "I found [N] things that need attention:
   >
   > 1. [Plain-language description] -- [location] -- [why it matters]
   > 2. ..."

   If there are also "Worth checking" items:
   > "Also worth checking:
   > - [description]"

3. If any auto-fixable issues exist:
   > "I can fix [N of the above] automatically. Want me to try?"

   Wait for user response.

4. If user approves auto-fix: continue to Step 8c (auto-fix loop).
5. If user declines: note the issues and continue to Step 9.

### 8c: Auto-fix retry loop

For each auto-fixable issue:
1. Spawn director-debugger with issue context and task context
2. Show progress: "Investigating the issue... Found the cause... Applying fix (attempt 1 of [max])..."
3. After debugger returns:
   a. If status is "Fixed": spawn director-verifier to re-check
   b. If re-check passes: amend commit, move to next issue
   c. If re-check fails: increment retry counter, try again
   d. If status is "Needs manual attention" or max retries reached:
      Report what was tried and suggest next steps:
      > "I tried [N] approaches to fix [issue] but couldn't resolve it. Here's what I found: [explanation]. You might want to [suggestion]."

Max retries per issue (Claude's Discretion):
- Simple wiring: 2
- Placeholder/stub: 3
- Complex integration: 3-5

After all fixable issues addressed, continue to Step 9.
```

### Example 3: Step Boundary Detection and Tier 2 Trigger

```markdown
## Step 10: Post-task summary and boundary check

### 10d: Step and goal boundary detection

After presenting the post-task summary:

1. List all files in the current step's tasks/ directory.
2. Check if ALL task files end in .done.md.

**If the step is NOT complete:**
> "Next up: [next task name]. Want to keep building?"
Stop here.

**If the step IS complete:**

Check if all steps in the current goal are complete. If yes, the goal is complete.

**Step complete (goal not complete):**
Run Tier 2 behavioral checklist for the step.

Assemble checklist context:
- Read the completed step's STEP.md
- Read all .done.md task files in the step
- Read VISION.md for overall context
- Read git log for commits in this step's tasks

Generate a behavioral checklist based on the step's purpose and the tasks that were completed. Each item should be something the user can try and observe.

Present the checklist:
> "[Step name] is done! Here's a quick checklist to make sure everything works:
>
> 1. [Testable action with expected result]
> 2. [Testable action with expected result]
> ...
>
> Try these out and let me know how they go!"

Wait for user response. Interpret their natural-language answers to determine which items passed and which failed.

If all pass:
> "Everything works! You're [X] of [Y] steps through [goal name]."

If some fail:
> "[N] of [M] checks passed! [Remaining items] need attention:
> - [Issue description with suggestion]"
Offer auto-fix if applicable.

**Goal complete:**
Run Tier 2 for the full goal (broader checklist).

> "[Goal name] is complete! Here's everything that was built:
> - [Step 1 summary]
> - [Step 2 summary]
> - ...
>
> Let's verify everything works together:
>
> 1. [Goal-level testable action]
> 2. [Goal-level testable action]
> ...
>
> Try these out and let me know!"

After checklist passes:
> "That's a big milestone -- [goal name] is done! [Total progress]. [What's next]."
```

### Example 4: Inspect Skill Structure

```markdown
---
name: inspect
description: "Check that what was built actually works. Runs verification on your project."
disable-model-invocation: true
---

## Step 1: Init check
[Check .director/ exists]

## Step 2: Check for completed work
Read STATE.md. If nothing built yet:
"Nothing to inspect yet. Once you start building, I can check that everything works."
Stop here.

## Step 3: Determine scope
Parse $ARGUMENTS to determine scope:
- No arguments or empty: scope = current step
- "goal": scope = current goal
- "all": scope = entire project
- Other text: scope = focused check on that topic

Tell the user what's being checked:
> "Checking [scope description]..."

## Step 4: Assemble verification context
Based on scope, read the relevant files:

**Step scope:**
- Current step's STEP.md
- All task files (both .md and .done.md) in the step
- VISION.md

**Goal scope:**
- Goal's GOAL.md (if exists)
- All steps' STEP.md files in the goal
- All task files across all steps
- VISION.md

**All scope:**
- GAMEPLAN.md
- All goal/step/task files
- VISION.md

**Focused scope (text argument):**
- Search for relevant tasks/steps matching the topic
- Include those files plus VISION.md

## Step 5: Run Tier 1 structural verification
Spawn director-verifier with the assembled context.

Present ALL results (even "everything checks out" -- user explicitly asked):

**If clean:**
> "Everything checks out. The code is properly built and connected."

**If issues:**
> Present in two-severity format with auto-fix offer.
> Run auto-fix loop if approved (same pattern as build).

## Step 6: Run Tier 2 behavioral verification
Generate and present a behavioral checklist for the scope.
Collect user results.

## Step 7: Celebrate and report progress
If everything passes:
> "[Scope] is verified! [Progress update]."

$ARGUMENTS
```

### Example 5: Auto-Fix Consent and Progress Updates

```markdown
<!-- User sees this after verification finds issues -->

I found 2 things that need attention:

**Needs attention:**
1. The settings page has placeholder content in the header section -- users
   would see 'TODO' text instead of their account name.
2. The notification bell icon is built but not connected to the notification
   list -- clicking it does nothing.

**Worth checking:**
- There's a helper function for formatting dates that isn't used yet. It
  might be planned for the activity feed.

I can fix #1 and #2 automatically. Want me to try?

<!-- After user says yes -->

Working on it...

**Issue 1:** Investigating the placeholder content... Found the cause -- the
header component has a hardcoded 'TODO' string where it should read the user's
name from the account data. Applying fix (attempt 1 of 2)... Fixed! The
header now shows the user's actual name.

**Issue 2:** Investigating the notification connection... Found the cause --
the bell icon triggers a function that's empty. Applying fix (attempt 1 of 3)...
The notification list now opens when you click the bell. Let me verify...
Confirmed -- the bell icon is connected and the notification list displays.

Both issues are fixed. Progress saved.
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| No verification after tasks | Builder spawns verifier sub-agent after committing | Phase 4 (04-01) | Tier 1 structural checks run but results stay internal to builder |
| Inspect as a stub | Needs full implementation | Phase 5 (this phase) | On-demand verification becomes functional |
| No behavioral testing | Tier 2 checklists at step boundaries | Phase 5 (this phase) | Users verify behavior, not just structure |
| Builder fixes all issues silently | Builder handles simple fixes; complex issues surface to user | Phase 5 (this phase) | User gets visibility into and control over fixes |

**Already exists and ready to use:**
- Verifier agent (full stub/orphan/wiring detection) -- `agents/director-verifier.md`
- Debugger agent (investigation and fix process) -- `agents/director-debugger.md`
- Verification patterns reference -- `reference/verification-patterns.md`
- Two-severity format ("Needs attention" / "Worth checking") -- already in verifier and verification-patterns.md
- Builder spawning verifier -- already in builder rule 6 and build skill Step 7 instructions
- Plain-language output rules -- `reference/plain-language-guide.md` and `reference/terminology.md`

**Needs modification:**
- Build SKILL.md Steps 8-10: add verification result surfacing, auto-fix loop, boundary detection, Tier 2
- Builder agent output format: include structured verification status
- Inspect SKILL.md: full rewrite from stub

**Completely new:**
- Tier 2 behavioral checklist generation logic
- Auto-fix consent and progress update messaging
- Step/goal boundary celebration flow
- Inspect scope resolution

## Agent Modifications Needed

### director-builder.md Changes

The builder's output section needs to include verification status. Currently the builder reports what was built in plain language. Add a requirement to also report verification results:

**Add to Output section:**
"After your plain-language description, include a verification status line:
- If verification passed with no issues: 'Verification: clean'
- If issues were found and all were fixed: 'Verification: [N] issues found, all fixed'
- If issues remain after your fixes: 'Verification: [N] issues found, [M] fixed, [R] remaining' followed by a description of each remaining issue with its severity level."

**Rationale:** This structured output lets the build skill parse verification results and decide whether to surface them to the user, offer auto-fix, or proceed silently.

### director-verifier.md Changes

Minor update needed. The verifier currently always produces a report. For the "invisible unless issues found" behavior, the verifier's output is fine -- the BUILD SKILL decides whether to show it. But the verifier should also indicate which issues it considers auto-fixable:

**Add to Output Format:**
"For each 'Needs attention' issue, indicate whether it's likely auto-fixable:
- Auto-fixable: stubs, placeholder content, broken imports, missing wiring, wrong file paths
- Needs human input: missing features, design decisions, architectural changes, unclear requirements"

### director-debugger.md Changes

The debugger already has retry awareness and fix rules. One addition needed:

**Add to Output section:**
"Include a clear status at the end of your output:
- 'Status: Fixed' -- the issue is resolved and verified
- 'Status: Needs more work' -- progress was made but the issue isn't fully resolved
- 'Status: Needs manual attention' -- this issue is beyond automated fixing"

**Note:** This status line already exists in the debugger's output format. Verify it's being used consistently.

## Open Questions

1. **Should the builder's internal verification loop change?**
   - What we know: The builder currently fixes issues and amends its commit internally. Phase 5 adds a SECOND layer of verification at the skill level with user consent.
   - What's unclear: Should the builder continue fixing issues internally, or should ALL issues be surfaced to the skill? If the builder fixes everything, the skill-level auto-fix flow is redundant.
   - Recommendation: Keep the builder's internal fix loop for simple, clear-cut issues (broken imports it just created, typos in its own code). These don't need user consent because they're implementation mistakes, not design issues. Issues that survive the builder's pass are genuinely harder and should be surfaced to the user. This maintains the "invisible unless issues found" principle while giving users control over substantive fixes.

2. **How does the inspect command assemble context for large scopes?**
   - What we know: The verifier has maxTurns: 30. A goal-scope or all-scope inspection might involve many files.
   - What's unclear: Whether a single verifier invocation can handle a broad scope within its turn limit.
   - Recommendation: For broad scopes, have the inspect skill spawn multiple verifier invocations (one per step within the goal, or one per goal for "all"). Aggregate results and present them together. This keeps each verifier invocation focused.

3. **Where does Tier 2 checklist generation happen?**
   - What we know: Tier 2 needs step/task context to generate relevant checklist items. The generation is essentially a prompt to Claude.
   - What's unclear: Does this happen inline in the build/inspect skill, or does it need a separate agent?
   - Recommendation: Inline in the skill. The build and inspect skills already have access to step/task files. They can generate the checklist directly in the conversation flow. No separate agent needed -- this is a straightforward text generation task that benefits from being in the same conversation context where the user will respond.

4. **Amend-commit during auto-fix retry loop**
   - What we know: One commit per task is a core principle. The builder creates the commit and the syncer's changes are amend-committed.
   - What's unclear: When the debugger fixes issues in the auto-fix retry loop, should each fix be a separate amend-commit, or should all fixes be batched?
   - Recommendation: Each successful debugger fix should immediately amend-commit (stage changes + amend). This keeps the working tree clean for the next verification pass. The final commit includes all fixes. This matches the pattern the builder already uses when fixing verifier issues internally.

## Sources

### Primary (HIGH confidence)
- Director codebase (existing Phase 1-4 artifacts) -- All agent definitions, skill patterns, reference docs, build pipeline. Read directly from `/Users/noahrasheta/Dev/GitHub/director/`. HIGH confidence.
- PRD Section 8.1.5 (Goal-Backward Verification) -- Requirements specification for `/director:inspect` and three-tier verification. Read from `docs/design/PRD.md` lines 359-389.
- PRD Section 8.1.8 (Error Handling) -- Requirements for debugger agent spawning and retry cycles. Read from `docs/design/PRD.md` lines 414-425.
- Phase 4 Research (`04-RESEARCH.md`) -- Established patterns for skill-driven orchestration, Task tool spawning, context assembly, sub-agent flat nesting constraint. Read from `.planning/phases/04-execution/`.
- Phase 4 Plans (`04-01-PLAN.md`, `04-02-PLAN.md`) -- How the current build pipeline was designed and implemented. Read from `.planning/phases/04-execution/`.
- CONTEXT.md (Phase 5) -- User decisions on tone, checklist flow, auto-fix, inspect scope, celebration format. Read from `.planning/phases/05-verification/05-CONTEXT.md`.

### Secondary (MEDIUM confidence)
- None -- all findings derived from existing codebase inspection and design documents.

### Tertiary (LOW confidence)
- None -- no external sources needed. Phase 5 is an integration/orchestration phase building on existing components.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH -- No external dependencies; all components are existing Markdown files in the plugin
- Architecture patterns: HIGH -- Build on established Phase 4 patterns (Task tool spawning, inline skill orchestration, sub-agent flat nesting); informed by existing agent definitions
- Pitfalls: HIGH -- Informed by thorough reading of existing builder/verifier/debugger agents and understanding of their interaction patterns
- Code examples: HIGH -- Based on existing Director patterns and locked decisions from CONTEXT.md
- Discretion recommendations: MEDIUM -- Retry counts and checklist sizing are judgment calls; recommendations are reasonable but not validated in practice

**Research date:** 2026-02-08
**Valid until:** 2026-03-08 (30 days -- Director's plugin architecture is stable; Phase 5 builds on Phase 4 which was just completed)
