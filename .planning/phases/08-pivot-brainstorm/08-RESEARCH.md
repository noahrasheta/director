# Phase 8: Pivot & Brainstorm - Research

**Researched:** 2026-02-08
**Domain:** Claude Code skill authoring (conversational pivot workflows, open-ended brainstorming, codebase mapping, gameplan regeneration, session persistence)
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

#### Pivot conversation flow
- Both inline and interview paths: `/director:pivot "switching to GraphQL"` skips interview; bare `/director:pivot` opens a conversation
- Claude's discretion on interview framing (what changed vs where are we going)
- Codebase re-mapping only when stale -- if significant work or time elapsed since last map, spawn mapper; otherwise trust STATE.md + doc sync
- Pivot scope detection: tactical pivots (tech stack, approach) update gameplan only; strategic pivots (product direction, target users) update VISION.md + gameplan. Director asks the user which type when it's ambiguous.

#### Change impact analysis
- Claude's discretion on delta granularity (goal-level, step-level, or task-level depending on pivot scope)
- In-progress work: complete current task first, then pivot from clean commit state. User can `/director:undo` after if they want to abandon that task.
- Completed work that's now irrelevant: Director flags it and adds cleanup tasks to the new gameplan (not removed automatically)
- Always require user approval before applying pivot changes -- show full delta summary, user confirms, then Director applies all changes

#### Brainstorm session shape
- Start guided, go free -- Director opens with a frame ("What are you thinking about?"), then follows wherever the user goes
- Adaptive context loading: start with VISION.md + STATE.md, load deeper context (GAMEPLAN.md, codebase files) on-demand when brainstorm touches code-level concerns
- Director's tone: match the user's energy with a bias toward supportive exploration. Surface feasibility concerns gently when they matter ("Love that idea. One thing to keep in mind: [concern]")
- Code-aware: user can reference specific parts of the codebase and Director reads relevant files to ground the discussion

#### Session endings & routing
- Both user and Director can end sessions -- user says "done" anytime; Director checks in periodically during natural pauses
- Brainstorm files saved as summary + highlights: structured summary at top (key ideas, decisions, open questions) with key excerpts below. Saved to `.director/brainstorms/YYYY-MM-DD-<topic>.md`
- Brainstorm exit: always save the session file, then suggest ONE best next action based on what was discussed (save as idea, quick task, blueprint update, pivot, or just "session saved")
- Pivot exit: Claude's discretion on the ending flow (delta-then-approve vs staged application)

### Claude's Discretion
- Pivot interview framing and question design
- Delta granularity presentation (goal vs step vs task level)
- Pivot ending flow (single approval vs staged)
- Brainstorm check-in timing and frequency
- When to load deeper context during brainstorm
- Exact brainstorm summary structure

### Deferred Ideas (OUT OF SCOPE)
None -- discussion stayed within phase scope
</user_constraints>

## Summary

Phase 8 adds two context-heavy conversational workflows to Director: (1) `/director:pivot` for changing project direction mid-build while preserving valid work and updating all documentation, and (2) `/director:brainstorm` for open-ended exploration with full project awareness that saves sessions and routes to next actions. Both commands exist as placeholder skills from Phase 1 and need full rewrites.

The pivot workflow is the more complex of the two. It combines interview-style conversation (capturing what changed), conditional codebase mapping (spawning the mapper agent when stale), impact analysis (comparing current state against new direction), gameplan regeneration (reusing blueprint update patterns), and multi-document updates (VISION.md for strategic pivots, GAMEPLAN.md always, STATE.md always). The blueprint update mode (Phase 3) already established the core patterns for delta summaries, frozen completed work, and holistic re-evaluation -- pivot extends these patterns with scope detection (tactical vs strategic) and staleness-aware mapper spawning.

The brainstorm workflow is conversationally simpler but introduces a new pattern: adaptive context loading. Unlike other skills that load all context upfront, brainstorm starts lightweight (VISION.md + STATE.md) and escalates to deeper context (GAMEPLAN.md, codebase files) on-demand when the conversation touches code-level concerns. This keeps costs low for casual sessions while enabling deep exploration when needed. The session save and routing logic follows patterns established in Phase 7's ideas routing.

**Primary recommendation:** Structure as 7 plans matching the roadmap outline. Plans 01-04 cover pivot (conversation, mapping, impact analysis, doc updates). Plans 05-07 cover brainstorm (context loading and exploration, codebase impact consideration, session routing and file saving). Both workflows run inline (no agent spawning for the conversation itself), consistent with the interview-inline pattern established in Phase 2 onboarding and Phase 3 blueprint.

## Standard Stack

This phase does not introduce new libraries or external dependencies. All work is Markdown skill files and agent-context updates within the existing Claude Code plugin architecture.

### Core Components
| Component | Type | Purpose | Status |
|-----------|------|---------|--------|
| `skills/pivot/SKILL.md` | Skill file | Pivot conversation, mapping, impact analysis, doc updates | Exists as placeholder, needs full rewrite |
| `skills/brainstorm/SKILL.md` | Skill file | Brainstorm context loading, exploration, routing, session save | Exists as placeholder, needs full rewrite |
| `skills/brainstorm/templates/brainstorm-session.md` | Template | Brainstorm session file format | Exists, needs update to match new summary+highlights format |
| `agents/director-mapper.md` | Agent | Codebase analysis for pivot mapping | Exists, spawned by pivot via Task tool |
| `agents/director-syncer.md` | Agent | Documentation sync after pivot | Exists, may need awareness of pivot-specific state changes |

### Supporting Files
| File | Type | Purpose | Changes Needed |
|------|------|---------|----------------|
| `.director/VISION.md` | User data | Updated by strategic pivots | Written by pivot skill (existing file, new content) |
| `.director/GAMEPLAN.md` | User data | Updated by all pivots | Written by pivot skill (existing file, new content) |
| `.director/STATE.md` | State | Pivot resets current position; brainstorm sessions logged | Updated by pivot and brainstorm skills |
| `.director/brainstorms/` | Directory | Stores brainstorm session files | Already created by init-director.sh |
| `reference/terminology.md` | Reference | Word choices | No changes |
| `reference/plain-language-guide.md` | Reference | Communication style | No changes |
| `reference/context-management.md` | Reference | XML boundary tags | No changes (pivot/brainstorm use existing tag set) |

### What NOT to Change
| Component | Why Not |
|-----------|---------|
| `agents/director-mapper.md` | Already complete with structure scan, tech stack detection, capability inventory, health assessment. Pivot spawns it as-is via Task tool. |
| `agents/director-planner.md` | Already has update mode with delta format, frozen completed work, holistic re-evaluation. Pivot uses these rules as reference (inline), not by spawning the agent. |
| `agents/director-interviewer.md` | PRD lists it as spawned by pivot/brainstorm, but the established pattern (Phases 2-3) is inline conversation. The interviewer agent's rules serve as reference, not spawn target. |
| `skills/blueprint/SKILL.md` | Pivot references blueprint's patterns but does not modify the blueprint skill itself. |
| `scripts/init-director.sh` | Already creates `.director/brainstorms/` directory. No changes needed. |

## Architecture Patterns

### Pattern 1: Pivot as Extended Blueprint Update

The pivot workflow is structurally similar to blueprint's update mode but with additional layers. Here is the mapping:

| Blueprint Update Step | Pivot Equivalent | Key Difference |
|----------------------|------------------|----------------|
| Check for existing gameplan | Check for vision AND gameplan | Pivot requires both |
| Load existing gameplan | Load existing gameplan + STATE.md + assess staleness | Pivot adds staleness check |
| (no equivalent) | Determine pivot scope (tactical vs strategic) | New: scope detection |
| (no equivalent) | Conditional mapper spawning | New: codebase re-mapping |
| Re-evaluate goals | Re-evaluate against NEW direction | Pivot has new direction context |
| Present delta summary | Present delta summary | Same pattern |
| Get approval | Get approval | Same pattern |
| Write updated files | Write updated files + VISION.md (if strategic) | Pivot may also rewrite VISION.md |
| (no equivalent) | Update STATE.md current position | Pivot resets progress tracking |

**Key insight:** Pivot reuses the blueprint update mode's delta presentation and frozen-work patterns but wraps them in a larger conversation about WHAT changed before getting to HOW the gameplan changes. The blueprint update asks "what do you want to add/change?" -- the pivot asks "what has changed about your project direction?"

### Pattern 2: Pivot Scope Detection (Tactical vs Strategic)

Pivots fall into two categories that determine what gets updated:

**Tactical pivots** -- change in approach, not direction:
- Tech stack changes ("switching from REST to GraphQL")
- Implementation approach changes ("using server components instead of client-side rendering")
- Scope adjustments ("dropping mobile for now, web-only")
- Architecture changes ("switching to a monorepo")

**Effect:** Update GAMEPLAN.md only. VISION.md's core purpose, audience, and features remain valid.

**Strategic pivots** -- change in direction:
- Product pivot ("it's not a task manager anymore, it's a habit tracker")
- Target audience change ("focusing on enterprises instead of consumers")
- Core feature overhaul ("dropping social features, going solo-focused")

**Effect:** Update VISION.md first (the source of truth has changed), then regenerate GAMEPLAN.md from the updated vision.

**Ambiguous cases:** When the scope is unclear, ask the user:
> "This could be a tweak to your approach (your vision stays the same, just the plan changes) or a bigger shift in what you're building. Which feels closer?"
>
> A) Just changing the approach -- the vision is still right
> B) Changing direction -- the vision needs updating too

### Pattern 3: Staleness-Aware Mapper Spawning

Not every pivot needs a full codebase map. The decision tree:

```
Has significant work been completed since last mapping?
  YES -> Is STATE.md + doc sync sufficient to understand current state?
    YES -> Skip mapper, trust docs
    NO  -> Spawn mapper
  NO  -> Skip mapper

Has it been a long time since the project was active?
  YES -> Spawn mapper (external changes possible)
  NO  -> (follow decision above)
```

**Staleness indicators (spawn mapper):**
- Multiple goals/steps completed since last map
- STATE.md shows many recent activity entries
- User explicitly mentions significant changes ("I've been working on this outside Director")
- Time gap is significant (weeks since last session)

**Freshness indicators (skip mapper):**
- Recent doc sync shows current state
- User just completed a task (STATE.md is current)
- Pivot is about future direction, not about what exists now
- User provides enough context in their pivot description

**When mapper IS spawned:**
```xml
<instructions>
Map this codebase with focus on what exists now vs. what's planned.
The user is considering a change in direction: [pivot context from user].
Report your findings using your standard output format.
</instructions>
```

The mapper runs in the foreground (same pattern as brownfield onboarding) so findings are available before impact analysis.

### Pattern 4: Pivot Conversation Flow

```
Step 1: Init + Vision + Gameplan checks (standard routing)
Step 2: Capture what changed
  - If $ARGUMENTS: acknowledge and skip interview
  - If no $ARGUMENTS: open conversation ("What's changed?")
  - Detect scope (tactical vs strategic, ask if ambiguous)
Step 3: In-progress work check
  - If current task is in progress: "Let's finish the current task first,
    then pivot from a clean state. Want to complete it, or undo it?"
  - Wait for clean state before proceeding
Step 4: Conditional mapper spawning
  - Assess staleness
  - If stale: spawn mapper, present findings
  - If fresh: trust STATE.md + docs, summarize current state
Step 5: Impact analysis
  - Compare current state against new direction
  - Classify each goal/step/task: still relevant, needs modification,
    no longer needed, new work required
  - For completed work that's now irrelevant: flag it, propose cleanup tasks
Step 6: Generate delta summary
  - Use blueprint update mode's delta format
  - Include "Already done" section for reassurance
  - Scale granularity to pivot scope (goal-level for strategic, task-level for tactical)
Step 7: Get approval
  - Present full delta summary
  - Wait for explicit approval
  - If feedback: adjust and re-present
Step 8: Apply changes
  - If strategic: update VISION.md first, then GAMEPLAN.md
  - If tactical: update GAMEPLAN.md only
  - Update STATE.md current position
  - Write new/modified goal/step/task files
  - Delete removed pending items (never delete completed)
Step 9: Wrap-up
  - Summarize what changed conversationally
  - Suggest next action (usually /director:build)
```

### Pattern 5: Brainstorm Adaptive Context Loading

Unlike other skills that load all context upfront, brainstorm uses a progressive loading strategy:

**Initial load (always):**
- VISION.md -- understand what the project is
- STATE.md -- understand current progress and recent activity
- These are small files, always included

**On-demand load (when conversation touches these areas):**
- GAMEPLAN.md -- when user discusses specific goals, steps, or task ordering
- Specific codebase files -- when user references specific features, pages, or code
- Goal/Step files -- when user discusses specific parts of the plan

**Trigger phrases for deeper loading:**
- "What about the [specific feature]?" -> load relevant step/task files
- "How does [component] work?" -> read codebase files
- "Could we change [goal/step]?" -> load GAMEPLAN.md + relevant goal files
- "What if we added [feature] to [page]?" -> load the page's source files
- User references file paths, component names, or specific code patterns

**Implementation:** The brainstorm skill instructs Claude to watch for these triggers in the conversation and use the Read tool to load additional context as needed. This is not a formal state machine -- it is natural tool use guided by skill instructions.

**Cost benefit:** A casual 5-minute brainstorm about a new feature idea might only load VISION.md + STATE.md (a few hundred tokens of context). A deep technical brainstorm about restructuring the database might additionally load GAMEPLAN.md, relevant STEP.md files, and actual database schema files -- but only when the conversation demands it.

### Pattern 6: Brainstorm Session Shape

The brainstorm conversation follows a loose structure:

```
Opening:
  "What are you thinking about?" (guided start)
  If $ARGUMENTS: "Let's explore [topic]. What prompted this?"
  Load initial context: VISION.md + STATE.md

Exploration (free-form):
  - Follow the user's lead
  - One question or insight at a time
  - Surface feasibility concerns gently when relevant
  - Load deeper context on-demand as topics arise
  - Read codebase files when user references specific code
  - Keep responses in 200-300 word sections (PRD guidance)
  - Validate understanding at each step

Check-in (periodic, during natural pauses):
  - "Want to keep exploring this, or are we good?"
  - "Anything else on your mind, or should we wrap up?"
  - Timing: every 4-6 exchanges, or when a natural topic boundary occurs

Ending:
  - User says "done", "that's it", "wrap up", or similar
  - OR Director check-in receives a wrap-up signal
  - Save session file (always)
  - Suggest ONE next action based on discussion content
```

### Pattern 7: Brainstorm Session File Format

The existing template needs updating to match the CONTEXT.md decision (summary + highlights format):

```markdown
# Brainstorm: [Topic]

**Date:** YYYY-MM-DD

## Summary

### Key Ideas
- [Idea 1 -- one sentence each]
- [Idea 2]
- [Idea 3]

### Decisions Made
- [Decision 1 -- if any decisions emerged]

### Open Questions
- [Question 1 -- unresolved items]

## Highlights

[Key excerpts from the conversation that capture important insights,
reasoning, or context. Not the full transcript -- just the parts
worth revisiting.]

## Suggested Next Action

[ONE action that fits best: save as idea, quick task, blueprint update,
pivot, or "session saved -- pick it back up anytime."]
```

**Filename format:** `.director/brainstorms/YYYY-MM-DD-<topic>.md`

The topic slug is derived from the conversation:
- If $ARGUMENTS provided: slug from arguments (e.g., "real-time-collab")
- If no $ARGUMENTS: slug from the first topic discussed (Claude's discretion)
- Kebab-case, 2-4 words

### Pattern 8: Brainstorm Exit Routing

At session end, suggest ONE next action based on discussion content:

| Discussion Content | Suggested Action | Example Phrasing |
|-------------------|------------------|-------------------|
| Concrete small change | Quick task | "That sounds like a quick change. Want me to handle it with `/director:quick`?" |
| New feature or capability | Blueprint update | "This would fit nicely as a new step. Want to update your gameplan?" |
| Direction change | Pivot | "This changes where the project is heading. Want to run a pivot to update everything?" |
| Half-formed idea | Save as idea | "Interesting thought. Want me to save it to your ideas list for later?" |
| Pure exploration | Session saved | "Session saved. Pick it back up anytime." |

**Important:** Brainstorm sessions are valuable even without action. "Session saved. Pick it back up anytime." is a complete and valid ending. Do not pressure the user to take action.

### Pattern 9: Pivot Documentation Update Scope

Different pivot scopes produce different documentation updates:

| Document | Tactical Pivot | Strategic Pivot |
|----------|---------------|-----------------|
| VISION.md | No change | Rewritten with new direction |
| GAMEPLAN.md | Updated (delta) | Regenerated from new vision |
| Goal/Step/Task files | Modified/added/removed as needed | Potentially all regenerated |
| STATE.md | Current position updated | Current position reset to new first task |
| IDEAS.md | No change | No change |

**VISION.md update for strategic pivots:**
- Present the updated vision to the user for review before saving (same approval pattern as onboarding)
- Use delta format (Existing/Adding/Changing/Removing) when modifying features
- Preserve the document structure from the onboard template

**GAMEPLAN.md update:**
- Follow blueprint update mode patterns exactly: freeze completed work, delta summary, explicit approval
- For strategic pivots, generate from scratch based on new vision (but still respect frozen completed work)

### Anti-Patterns to Avoid

- **Don't auto-remove completed work.** Completed work is FROZEN. If it is now irrelevant, flag it and add cleanup tasks to the new gameplan. The user decides if cleanup is needed.
- **Don't auto-trigger mapper for every pivot.** Only spawn when stale. Most pivots are about future direction, not about understanding what exists.
- **Don't load full codebase context into brainstorm.** Start light, escalate on demand. A casual brainstorm should not cost as much as a build task.
- **Don't force brainstorm endings into action.** "Session saved" is a valid ending. Brainstorm sessions are valuable for thinking, not just for producing work.
- **Don't present pivot as a menu.** Scope detection (tactical vs strategic) should be a natural conversational question when ambiguous, not a formal A/B choice (though multiple choice is acceptable per interview rules).
- **Don't spawn the interviewer agent.** Run the conversation inline, consistent with onboard (Phase 2) and blueprint (Phase 3) patterns. The interviewer agent's rules serve as reference.
- **Don't modify pivot/brainstorm to spawn a planner agent.** The planner agent cannot write files (disallowedTools: Write, Edit). Pivot handles gameplan generation inline using the planner's rules as reference, same as blueprint does.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Codebase analysis | Custom mapping logic in pivot | Existing `director-mapper` agent via Task tool | Mapper already has structure scan, tech detection, capability inventory, health assessment |
| Gameplan delta generation | Custom diff algorithm | Blueprint update mode's delta pattern (reuse inline) | Already handles frozen work, explicit reasoning for removals, "Already done" reassurance |
| Brainstorm session files | Custom session recorder | Markdown file written at session end | Director is a prompt-driven plugin -- the "recorder" is Claude writing a summary based on the conversation |
| Staleness detection | Complex timestamp-based tracking | Simple heuristic checks (STATE.md activity count, time since last session) | Staleness is a judgment call, not a precise calculation |
| Brainstorm context loading | Custom context manager | Native Claude Code Read tool + skill instructions | The model reads files on demand -- no custom infrastructure needed |
| VISION.md updates | Custom vision diff/merge | Direct rewrite with user approval | Same pattern as onboard's vision generation, just with change context |

## Common Pitfalls

### Pitfall 1: Pivot while task is in progress
**What goes wrong:** User runs `/director:pivot` while a task is partially completed. Uncommitted changes conflict with the pivot's gameplan regeneration.
**Why it happens:** The user realized they need to change direction WHILE building. This is natural and expected.
**How to avoid:** Check for uncommitted changes (same pattern as build skill Step 6). If there are in-progress changes, offer two paths: (1) complete the current task first, then pivot from clean state, or (2) stash/discard changes and pivot immediately. The CONTEXT.md decision says "complete current task first, then pivot from clean commit state" as the recommended path.
**Warning signs:** `git status --porcelain` showing changes before pivot starts.

### Pitfall 2: Strategic pivot destroying completed work
**What goes wrong:** A strategic pivot rewrites VISION.md and regenerates the gameplan, causing completed goals/steps/tasks to disappear or be marked for deletion.
**Why it happens:** The new vision may not mention features that were already built under the old vision.
**How to avoid:** Completed work is FROZEN per the established blueprint update rule ([03-02] decision). Even in a full strategic pivot, completed items stay in the gameplan. If they are irrelevant to the new direction, the pivot flags them and proposes cleanup tasks rather than deletion. The delta summary's "Already done" section provides reassurance.
**Warning signs:** Delta summary showing removal of completed items (should never happen).

### Pitfall 3: Brainstorm loading too much context
**What goes wrong:** Brainstorm loads VISION.md + GAMEPLAN.md + STATE.md + multiple codebase files upfront, creating an expensive session for what was meant to be a quick "what if?" conversation.
**How to avoid:** Start with VISION.md + STATE.md only (lightweight). Load GAMEPLAN.md and codebase files on-demand when the conversation touches code-level concerns. The skill instructions should explicitly state the initial load set and the trigger conditions for deeper loading.
**Warning signs:** High token costs for short brainstorm sessions.

### Pitfall 4: Brainstorm session file naming collisions
**What goes wrong:** Two brainstorm sessions on the same day with similar topics overwrite each other because the filename is `YYYY-MM-DD-<topic>.md`.
**Why it happens:** The topic slug is derived from conversation content -- two sessions about "dark mode" on the same day produce the same filename.
**How to avoid:** If a file with the target name already exists, append a counter: `2026-02-08-dark-mode-2.md`. Check for existence before writing. Alternatively, include a time component: `2026-02-08-1430-dark-mode.md`. The simpler counter approach is recommended.
**Warning signs:** Brainstorm sessions mysteriously changing content (overwrite).

### Pitfall 5: Pivot scope detection failing silently
**What goes wrong:** A strategic pivot is treated as tactical (only GAMEPLAN.md updated, but VISION.md is now stale), or a tactical pivot is treated as strategic (VISION.md unnecessarily rewritten).
**Why it happens:** The pivot skill auto-classifies scope without asking, and gets it wrong.
**How to avoid:** The CONTEXT.md decision says "Director asks the user which type when it's ambiguous." Implement scope detection as a heuristic with an explicit fallback to asking the user. When the pivot description strongly signals one type (e.g., "switching to GraphQL" is clearly tactical; "we're building a completely different product" is clearly strategic), classify automatically. When ambiguous, ask.
**Warning signs:** VISION.md and GAMEPLAN.md becoming out of sync (one updated but not the other).

### Pitfall 6: Brainstorm route suggesting pivot when user just wants to explore
**What goes wrong:** User explores an idea that COULD change direction, and brainstorm immediately suggests a pivot at the end, making exploration feel like a commitment.
**Why it happens:** Overeager routing logic. The brainstorm session file has a pivot as a possible route, and the skill always tries to find an actionable outcome.
**How to avoid:** The CONTEXT.md decision explicitly states "brainstorm sessions are valuable even without action." The routing should suggest the LEAST disruptive action that fits. If the user was exploring casually, "Session saved" is the right suggestion. Only suggest pivot if the user explicitly expressed intent to change direction during the session.
**Warning signs:** Users feeling pressured after brainstorming, avoiding the brainstorm command.

### Pitfall 7: Pivot not updating STATE.md current position
**What goes wrong:** After a pivot rewrites the gameplan, STATE.md still points to the old current task. The next `/director:build` tries to execute a task that no longer exists.
**Why it happens:** Pivot updates GAMEPLAN.md and goal/step/task files but forgets to update STATE.md's Current Position section.
**How to avoid:** After writing all pivot changes, scan the new gameplan structure for the first ready task and update STATE.md's current position accordingly. This is similar to what the syncer does after each task, but pivot does it directly since it is making wholesale changes.
**Warning signs:** Build command failing with "task file not found" after a pivot.

## Code Examples

### Pivot Skill Structure (Skeleton)

```markdown
---
name: pivot
description: "Handle a change in direction for your project. Maps impact and updates your gameplan."
disable-model-invocation: true
---

You are Director's pivot command. Help the user change direction by
understanding what changed, mapping the impact, and updating the gameplan.

**Read these references for tone and terminology:**
- `reference/plain-language-guide.md`
- `reference/terminology.md`

Follow all steps below IN ORDER.

---

## Step 1: Init + Vision + Gameplan checks
[Standard routing: check .director/, check VISION.md, check GAMEPLAN.md]
[Pivot requires BOTH a vision and a gameplan to pivot from]

## Step 2: Capture what changed
[If $ARGUMENTS: acknowledge inline, skip to scope detection]
[If no $ARGUMENTS: "What's changed about your project?"]
[Conversational: "Tell me what happened" not a formal interview]

## Step 3: Detect pivot scope
[Analyze user's description for tactical vs strategic signals]
[If clear: classify and state it ("This sounds like a change in approach...")]
[If ambiguous: ask the user with A/B choice]

## Step 4: In-progress work check
[git status --porcelain]
[If uncommitted changes: offer to complete current task or stash]
[Proceed only from clean commit state]

## Step 5: Assess and map current state
[Check staleness indicators in STATE.md]
[If stale: spawn director-mapper via Task tool, present findings]
[If fresh: summarize current state from STATE.md + GAMEPLAN.md]

## Step 6: Impact analysis
[Read all goal/step/task files]
[Classify each: still relevant, needs modification, no longer needed, new]
[For completed work now irrelevant: flag, propose cleanup tasks]

## Step 7: Generate and present delta summary
[Use blueprint update mode delta format]
[Scale to pivot scope: strategic = goal-level, tactical = task-level]
[Include "Already done" section]
[Present full updated gameplan outline after delta]
[Wait for explicit approval]

## Step 8: Apply changes
[If strategic: update VISION.md first (present for review)]
[Update GAMEPLAN.md]
[Write new/modified/remove pending goal/step/task files]
[Never delete completed items]
[Update STATE.md current position to first ready task]

## Step 9: Wrap-up
["Your gameplan is updated. [Brief summary of what changed.]"]
["Ready to keep building? Pick up with /director:build."]

---

## Language Reminders
[Same as build/blueprint skills]

$ARGUMENTS
```

### Brainstorm Skill Structure (Skeleton)

```markdown
---
name: brainstorm
description: "Think out loud with full project context. Explore ideas one question at a time."
disable-model-invocation: true
---

You are Director's brainstorm command. Help the user explore ideas freely
with their full project context in mind.

**Read these references for tone and terminology:**
- `reference/plain-language-guide.md`
- `reference/terminology.md`

---

## Step 1: Init + Vision check
[Check .director/ exists, run init if not]
[Read VISION.md -- if template-only, suggest onboarding first]

## Step 2: Load initial context
[Read VISION.md (full contents) -- understand the project]
[Read STATE.md -- understand current progress]
[Do NOT load GAMEPLAN.md, codebase files, or step files yet]
[These are loaded on-demand during the conversation]

## Step 3: Open the session
[If $ARGUMENTS: "Let's explore [topic]. What prompted this?"]
[If no $ARGUMENTS: "What are you thinking about?"]
[Set conversational tone: exploratory, not planning]

## Step 4: Exploration (conversational loop)
[Follow the user's lead]
[One insight or question at a time, 200-300 words per response]
[When user references specific goals/steps: read GAMEPLAN.md on demand]
[When user references specific code: read relevant files on demand]
[Surface feasibility gently: "Love that idea. One thing to keep in mind..."]
[Every 4-6 exchanges: check in -- "Want to keep exploring, or wrap up?"]

## Step 5: Session ending
[Triggered by user saying "done" or check-in receiving wrap-up signal]
[Generate session summary with key ideas, decisions, open questions]
[Write to .director/brainstorms/YYYY-MM-DD-<topic>.md]

## Step 6: Suggest next action
[Analyze discussion content for the best single action]
[Suggest ONE: save idea, quick task, blueprint update, pivot, or just saved]
[If no clear action: "Session saved. Pick it back up anytime."]
[Wait for user response before taking any action]

---

## Adaptive Context Loading Rules
[Start with VISION.md + STATE.md]
[Load GAMEPLAN.md when user discusses: goals, steps, task ordering, progress]
[Load codebase files when user discusses: specific features, code, components]
[Load step/task files when user discusses: specific planned work]
[Never pre-load everything -- let the conversation drive what's needed]

## Session File Format
[Use template at skills/brainstorm/templates/brainstorm-session.md]
[Summary section: key ideas, decisions made, open questions]
[Highlights section: important excerpts, not full transcript]
[Suggested next action: ONE actionable suggestion or "session saved"]

## Language Reminders
[Same as other skills -- conversational, plain language, match energy]

$ARGUMENTS
```

### Pivot Scope Detection Heuristics

```markdown
## Scope Detection

Analyze the user's pivot description for scope signals:

**Tactical signals (approach change, gameplan-only update):**
- Technology mentions: "switching to", "using X instead of Y"
- Implementation terms: "refactoring", "restructuring", "reorganizing"
- Scope narrowing: "dropping X for now", "simplifying", "web-only"
- Architecture changes: "monorepo", "serverless", "different hosting"

**Strategic signals (direction change, vision + gameplan update):**
- Product identity: "it's not a X anymore, it's a Y"
- Audience change: "targeting enterprises", "for teams instead of solo"
- Core feature shift: "dropping the social features entirely"
- Purpose change: "the goal is now..."

**Ambiguous (ask the user):**
- Feature additions that might change scope
- User sounds uncertain about how big the change is
- Mixed signals (some tactical, some strategic)
```

### Brainstorm Session File Example

```markdown
# Brainstorm: Real-Time Collaboration

**Date:** 2026-02-08

## Summary

### Key Ideas
- WebSocket-based real-time editing using Yjs as the CRDT library
- Presence indicators showing who is viewing each document
- Start with view-only sharing, add collaborative editing in a later goal

### Decisions Made
- Real-time editing is a Goal 2 feature, not Goal 1
- View-only sharing is simple enough to add to Goal 1

### Open Questions
- How does real-time affect the database schema?
- Should we use Supabase Realtime or a separate WebSocket server?

## Highlights

User explored adding real-time collaboration to their note-taking app.
The key insight was separating "sharing" (simple, Goal 1) from
"collaborative editing" (complex, Goal 2). Yjs emerged as the
recommended CRDT library based on its integration with the existing
editor component.

The user was initially thinking of building both at once, but agreed
that shipping view-only sharing first would let them validate the
feature before investing in the harder synchronization work.

## Suggested Next Action

This would fit nicely as a new step in Goal 1. Want to update your
gameplan with `/director:blueprint "add document sharing"`?
```

### Mapper Spawning in Pivot Context

```markdown
## Mapper spawning (when stale)

Tell the user you're going to check the current state of their project.
Then spawn the director-mapper agent using the Task tool:

<instructions>
Map this codebase with a focus on what currently exists.
The user is considering a change in direction: [pivot context].
Report your findings using your standard output format:
- What you found (1-2 sentence summary)
- Built with (tech stack in plain language)
- What it can do (feature inventory as user capabilities)
- How it's organized (project structure overview)
- Things worth noting (observations about codebase health)
</instructions>

Run the mapper in the foreground. Once it returns, present findings
to the user conversationally:

> "Here's what your project looks like right now:"
> [mapper findings, presented naturally]

Then continue to impact analysis with the mapper's findings as context.
```

## State of the Art

| Old Approach (Phase 1 Placeholder) | Current Approach (Phase 8) | Impact |
|-------------------------------------|---------------------------|--------|
| Pivot: "This command will be fully functional in a future update" | Full pivot workflow with conversation, mapping, impact analysis, delta summary, doc updates | Users can change direction confidently |
| Brainstorm: "This command will be fully functional in a future update" | Full brainstorm with adaptive context, code awareness, session save, exit routing | Users can explore ideas with project context |
| Brainstorm template: flat Discussion/Ideas/Next Steps | Summary+highlights format with key ideas, decisions, open questions | More useful session files for future reference |
| No pivot scope detection | Tactical vs strategic classification | Right documents updated for each pivot type |
| No staleness-aware mapping | Conditional mapper spawning based on staleness | Avoid unnecessary codebase scans |
| No adaptive context loading | Progressive loading in brainstorm | Keep costs low for casual sessions |

## Open Questions

1. **Brainstorm session deduplication with IDEAS.md**
   - What we know: Brainstorm can suggest "save as idea" at session end. The idea would be saved to IDEAS.md via the existing idea capture pattern.
   - What's unclear: Should the brainstorm skill write to IDEAS.md directly, or suggest the user run `/director:idea`?
   - Recommendation: Write directly to IDEAS.md using the same insertion pattern as the idea skill (insert after `_Captured ideas` line, newest-first). This keeps the interaction smooth -- the user said "save it" and it is saved immediately. Suggesting they run another command adds friction.

2. **Pivot and decisions in STEP.md**
   - What we know: Phase 7.1 added a Decisions section to STEP.md. When pivot regenerates the gameplan, existing decisions in pending steps might be invalidated by the pivot.
   - What's unclear: Should pivot preserve, update, or regenerate Decisions sections in affected steps?
   - Recommendation: For tactical pivots, preserve existing decisions in unmodified steps and regenerate decisions for modified/new steps. For strategic pivots, regenerate all decisions from the pivot conversation (since the direction has changed). Follow the blueprint update mode pattern: completed steps' decisions are FROZEN.

3. **Brainstorm codebase file access scope**
   - What we know: Brainstorm should be code-aware and let users reference specific parts of the codebase. The mapper agent is the established tool for codebase analysis.
   - What's unclear: Should brainstorm spawn a mapper for code questions, or just use the Read tool directly?
   - Recommendation: Use Read/Glob/Grep directly within the brainstorm skill for on-demand file access. The mapper is overkill for "read this file and discuss it." The mapper does a full structural analysis -- brainstorm just needs to read specific files the user references. The brainstorm skill already has access to these tools via the main conversation context.

4. **STATE.md updates after pivot**
   - What we know: Pivot changes the gameplan, which means STATE.md's progress section is stale. The syncer normally handles STATE.md updates, but pivot is not a build task -- it is a meta-operation.
   - What's unclear: Should the pivot skill update STATE.md directly, or spawn the syncer?
   - Recommendation: Pivot updates STATE.md directly. The syncer is designed for post-task documentation sync -- it expects `<task>` and `<changes>` context tags that don't apply to pivot. Pivot should: (1) recalculate progress by scanning the new file system structure, (2) update current position to the first ready task, (3) add a Recent Activity entry for the pivot itself.

## Sources

### Primary (HIGH confidence)
- **Existing codebase analysis** -- All skill files, agent definitions, init scripts, reference docs, and planning artifacts read directly from the repository
- **CONTEXT.md decisions** -- User-locked decisions from discussion phase
- **PRD sections 8.1.10 and 8.1.12** -- Official requirements for pivot and brainstorm
- **PRD section 9.9** -- Agent architecture and workflow orchestration (pivot: interviewer -> mapper -> planner -> presents; brainstorm: interviewer -> routes)

### Secondary (MEDIUM confidence)
- **Blueprint skill patterns** -- Phase 3 established delta summaries, frozen completed work, holistic re-evaluation patterns that pivot directly reuses
- **Onboard skill patterns** -- Phase 2 established inline conversation (not agent spawning), mapper spawning via Task tool, and vision generation/approval patterns
- **Build skill patterns** -- Phase 4 established context assembly, uncommitted changes handling, and STATE.md update patterns
- **Quick/Ideas patterns** -- Phase 7 established exit routing, ideas insertion/removal, and session file mechanics

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH -- all components are established codebase patterns, no new dependencies
- Architecture (pivot): HIGH -- direct reuse of blueprint update mode patterns with well-defined extensions (scope detection, mapper spawning, VISION.md updates)
- Architecture (brainstorm): HIGH -- adaptive context loading is a new pattern but uses existing tools (Read, Glob, Grep); session save and routing follow established patterns from Phase 7
- Pitfalls: HIGH -- identified from direct analysis of existing code, patterns, and the CONTEXT.md decision boundaries
- Code examples: HIGH -- based on existing skill patterns in the codebase, all derived from Phase 1-7 code

**Research date:** 2026-02-08
**Valid until:** 2026-03-08 (stable -- plugin authoring patterns don't change rapidly)
