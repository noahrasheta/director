# Phase 6: Progress & Continuity - Research

**Researched:** 2026-02-08
**Domain:** State persistence, progress display, session resume, cost tracking -- all within the Claude Code plugin system (Markdown skills, shell hooks, no runtime code)
**Confidence:** HIGH

## Summary

Phase 6 transforms the status and resume skills from routing placeholders into fully functional commands, redesigns STATE.md into a rich state tracking format, adds cost tracking per goal, and implements external change detection for resume. The phase spans four interconnected concerns: (1) status display with progress bars and ready-work suggestions, (2) state persistence that updates after every task and on command exit, (3) session resume with last-session summary and external change detection, and (4) cost tracking with token counts and dollar amounts per goal.

The research confirms all required capabilities are achievable with existing Claude Code plugin primitives. Status and resume already use dynamic context injection (`!`command``) to load STATE.md at invocation time. The SessionEnd hook provides a reliable point to ensure STATE.md is never stale. The SubagentStop hook could theoretically intercept builder completions for cost tracking, but the transcript files it provides do not expose token counts in a reliably parseable format. Cost tracking is better implemented by having the syncer or build skill log estimated costs directly during the post-task flow.

The biggest design challenge is STATE.md format. It must serve three audiences simultaneously: (1) human readers who open it in an editor, (2) skills that parse it via shell commands in dynamic context injection, and (3) the syncer agent that updates it after every task. The recommended approach is structured Markdown with consistent key-value patterns that can be parsed with simple `grep`/`sed` while remaining readable as a document.

**Primary recommendation:** Rewrite status and resume skills with full logic, redesign STATE.md with a structured format that includes progress tracking + decisions log + cost tracking, add a SessionEnd hook for staleness prevention, and implement cost tracking as estimated per-goal token accumulation managed by the syncer.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

#### Status display
- Default view: goal-level with step breakdown underneath (tasks summarized as counts, not listed individually)
- Progress bars for goals ("Goal 1: [████████────] 67%"), fraction counts for steps/tasks ("Step 2: 3/7 tasks")
- "Ready to work on" suggestion at the bottom -- informational, not pushy
- Blocked items: Claude's discretion on inline vs separate section -- whichever reads cleanest

#### Resume experience
- Shows summary of last session PLUS analysis of what changed since then
- Detects and analyzes external changes (manual edits, other tools): "Login.tsx was modified -- this might affect the signup task you're about to start"
- Ends with a suggested next action: "Ready to start the user profile page? Just say go."
- Tone: Claude's discretion -- adapt based on project context and break length

#### State persistence
- STATE.md updates after every task AND on command exit -- never stale
- Tracks progress (task statuses, current position, completion counts) AND a decisions log (key decisions made during building)
- STATE.md format: Claude's discretion -- optimize for both human readability and machine parsing
- STATE.md changes committed to git as part of task commits -- state is versioned with the code

#### Cost tracking
- Granularity: per goal (not per task or per step)
- Visibility: summary in /director:status, detailed breakdown available on request
- Format: token counts + dollar amounts ("Goal 1: 450K tokens ($4.50)")
- No pre-task cost warnings -- track after the fact, don't add friction before building

### Claude's Discretion
- Blocked items visual treatment (inline vs separate section)
- Resume tone (warm vs efficient, based on context)
- STATE.md format (Markdown structure, YAML frontmatter, etc.)
- How to surface the detailed cost breakdown (sub-command, argument, or inline expansion)

### Deferred Ideas (OUT OF SCOPE)
None -- discussion stayed within phase scope
</user_constraints>

## Standard Stack

This phase uses no external libraries. Director is a declarative Claude Code plugin -- all components are Markdown files, JSON configuration, and shell scripts. The "stack" is the Claude Code plugin system itself.

### Core

| Component | Format | Purpose | Why Standard |
|-----------|--------|---------|--------------|
| `skills/status/SKILL.md` | Markdown + YAML frontmatter | Status display command -- full rewrite from placeholder | Official skills format; uses dynamic context injection for STATE.md |
| `skills/resume/SKILL.md` | Markdown + YAML frontmatter | Resume command -- full rewrite from placeholder | Official skills format; uses dynamic context injection + git history |
| `.director/STATE.md` | Structured Markdown | State persistence document -- redesigned format | Human-readable + machine-parseable state tracking |
| `hooks/hooks.json` | JSON | Plugin hooks including SessionEnd for state persistence | Official plugin hooks format |
| `scripts/session-start.sh` | Bash | Updated to extract richer state for session context | Already exists; needs expansion |
| `scripts/state-save.sh` | Bash | New script for SessionEnd hook to ensure state freshness | Simple shell script, runs on session exit |
| `agents/director-syncer.md` | Markdown + YAML frontmatter | Updated to handle cost tracking and decisions log in STATE.md | Already exists; needs expansion |

### Supporting

| Component | Format | Purpose | When to Use |
|-----------|--------|---------|-------------|
| `skills/build/SKILL.md` | Markdown | Minor updates to pass cost data to syncer | After each task completion |
| `reference/terminology.md` | Markdown | Already complete -- no changes needed for this phase | All user-facing messages |
| `reference/plain-language-guide.md` | Markdown | Already complete -- no changes needed | All user-facing messages |

### What NOT to Use

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| YAML frontmatter in STATE.md | Adds parsing complexity for shell scripts; not as readable for humans | Structured Markdown with consistent key-value patterns |
| JSON state file | Not human-readable; violates "user-facing = Markdown" rule | Markdown with grep-parseable patterns |
| External token counting APIs | No API access from within plugin; cost is an estimate anyway | Character count / 4 approximation (same as context budget) |
| Database or SQLite for state | Overkill; state is small and file-based | Direct STATE.md updates |
| Custom diff engine for external change detection | Complex and fragile | `git diff --stat` and `git log` for change detection |

## Architecture Patterns

### Recommended STATE.md Format

The STATE.md redesign must balance human readability, machine parsing, and syncer updateability. Here is the recommended format (Claude's Discretion area -- this is the recommendation):

```markdown
# Project State

**Status:** Building
**Last updated:** 2026-02-08 14:32
**Last session:** 2026-02-08

## Current Position

**Current goal:** Goal 1: Users can sign up, log in, and manage their accounts
**Current step:** Step 2: Login page with form validation
**Current task:** Task 3: Connect login form to authentication
**Position:** Goal 1 > Step 2 > Task 3

## Progress

### Goal 1: Users can sign up, log in, and manage their accounts
**Steps:** 2 of 4 complete
**Tasks:** 8 of 14 complete
**Status:** In progress
**Cost:** 320K tokens ($3.20)

- Step 1: Database setup [complete] -- 4/4 tasks
- Step 2: Login page [in progress] -- 2/5 tasks
- Step 3: Signup flow [not started] -- 0/3 tasks
- Step 4: Profile page [not started] -- 0/2 tasks

### Goal 2: Dashboard shows real-time data
**Steps:** 0 of 3 complete
**Tasks:** 0 of 9 complete
**Status:** Not started
**Cost:** 0 tokens ($0.00)

## Recent Activity

- [2026-02-08 14:32] Completed: Add form validation to login page
- [2026-02-08 14:15] Completed: Create login page layout
- [2026-02-08 13:50] Completed: Set up authentication API routes
- [2026-02-07 16:20] Completed: Create users table and seed data

## Decisions Log

- [2026-02-08] Using bcrypt for password hashing (industry standard, built into the auth library)
- [2026-02-07] Chose PostgreSQL over SQLite (need concurrent access for the API)
- [2026-02-07] Using Tailwind CSS for styling (user preference from vision)

## Cost Summary

**Total:** 320K tokens ($3.20)

| Goal | Tokens | Cost |
|------|--------|------|
| Goal 1 | 320K | $3.20 |
| Goal 2 | 0 | $0.00 |
```

**Why this format:**
- **Human-readable:** Section headers, natural language, indented lists
- **Machine-parseable:** Consistent `**Key:** Value` patterns that `grep` and `sed` can extract reliably (same pattern already used by `session-start.sh`)
- **Syncer-friendly:** Clear sections the syncer can locate and update by pattern matching
- **Cost tracking inline:** Per-goal cost appears in both the Progress section (quick glance) and the Cost Summary section (detailed view)

### Pattern 1: Status Display -- Hierarchical Progress with Visual Indicators

**What:** The status skill reads STATE.md, GAMEPLAN.md, and the goals directory to produce a visual progress display at goal level with step breakdowns.

**When to use:** Every `/director:status` invocation.

**Display format (locked decision):**

```
Your project at a glance:

Goal 1: Users can sign up and log in
[████████████────────] 57%
  Step 1: Database setup -- 4/4 tasks (done)
  Step 2: Login page -- 2/5 tasks (in progress)
  Step 3: Signup flow -- 0/3 tasks
  Step 4: Profile page -- 0/2 tasks

Goal 2: Dashboard shows real-time data
[────────────────────] 0%
  Step 1: Data models -- 0/3 tasks
  Step 2: Dashboard layout -- 0/4 tasks
  Step 3: Live updates -- 0/2 tasks

Total: 8 of 23 tasks complete across 2 goals

---

Ready to work on: Connect the login form to the authentication system.
Want to keep building? Just say go, or run /director:build.
```

**Key design decisions:**
- Progress bars use block characters: `█` for filled, `─` for empty (20 chars wide)
- Percentage shown inline with the progress bar
- Steps listed underneath each goal with fraction counts
- Tasks NOT listed individually (locked decision -- only shown as counts)
- "Ready to work on" suggestion at the bottom (locked -- informational, not pushy)
- Total project summary between the goals and the suggestion

**Blocked items treatment (Claude's Discretion -- recommendation: inline):**
When tasks are blocked, show the reason inline with the step:

```
  Step 3: Signup flow -- 0/3 tasks (needs login page first)
```

This reads more naturally than a separate "Blocked" section and keeps the display compact. A separate section would fragment the visual flow and make the user scan two places.

### Pattern 2: Resume -- Context Reconstruction with External Change Detection

**What:** The resume skill reads STATE.md, git history, and file modification times to reconstruct what happened in the last session and what changed since then.

**When to use:** Every `/director:resume` invocation.

**Resume flow:**
1. Read STATE.md to get last session date, recent activity, current position
2. Run `git log --since="[last_session_date]" --oneline` to find any commits since then
3. Run `git diff --stat HEAD` to detect uncommitted changes
4. Check file modification times of key project files for external changes
5. Assemble a plain-language summary combining last session recap + what changed + suggested next action

**Resume output format:**

```
Welcome back! Here's where things stand:

Last time (2 days ago), you finished building the login page --
users can now type their email and password to sign in.

Since then:
- Login.tsx was modified -- this might affect the signup task
  you're about to start.
- No other changes detected.

You're 2 of 4 steps through Goal 1 (user accounts).

Ready to start the signup flow? Just say go.
```

**External change detection approach:**
- Compare `git diff --stat` against tracked files to find uncommitted modifications
- For each modified file, check if it's in the scope of upcoming tasks (by reading the next ready task's file list)
- If a modified file overlaps with an upcoming task, flag it explicitly
- Use `git log --after="[last_session_timestamp]"` to find commits made outside Director (manual commits, other tools)

**Tone adaptation (Claude's Discretion -- recommendation: context-sensitive):**
- Short break (hours): efficient, pick up where you left off -- "Welcome back. Last time you finished the login page. Next up: signup."
- Long break (days): warmer, more context -- "Welcome back! It's been a few days. Here's where things stand..."
- First resume ever: oriented, helpful -- "Welcome back! Here's what you've accomplished so far and what's next."

The status skill should assess break length by comparing `last_session` date in STATE.md to current date.

### Pattern 3: State Persistence -- Dual-Trigger Updates

**What:** STATE.md is updated at two points: (1) after every task completion via the syncer, and (2) on session exit via a SessionEnd hook.

**When to use:** Automatically -- no user action required.

**After-task updates (via syncer):**
The syncer already updates STATE.md after every task. This phase expands what it tracks:
- Task completion status and timestamp
- Progress counts (tasks done / total in step, steps done / total in goal)
- Current position update (next ready task)
- Recent activity entry (what was just completed)
- Cost tracking update (accumulate tokens for the current goal)
- Decisions log entry (if the builder made notable decisions during the task)

**On-exit updates (via SessionEnd hook):**
A new SessionEnd hook ensures STATE.md captures session end time even if the user closes the terminal without completing a task. This prevents staleness.

```json
{
  "hooks": [
    {
      "event": "SessionStart",
      "matcher": "startup",
      "command": "${CLAUDE_PLUGIN_ROOT}/scripts/session-start.sh",
      "timeout": 5,
      "statusMessage": "Loading Director..."
    },
    {
      "event": "SessionEnd",
      "hooks": [
        {
          "type": "command",
          "command": "${CLAUDE_PLUGIN_ROOT}/scripts/state-save.sh",
          "timeout": 5
        }
      ]
    }
  ]
}
```

**Note on hooks.json format:** The existing `hooks.json` uses a flat array format. The official Claude Code hooks format uses a nested event-keyed object. The existing format appears to be a simplified/legacy format that Director established in Phase 1. The implementation should use whichever format Claude Code currently supports for plugins -- verify against the official plugin hooks reference. Based on official documentation, the correct format is:

```json
{
  "description": "Director lifecycle hooks",
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/session-start.sh",
            "timeout": 5,
            "statusMessage": "Loading Director..."
          }
        ]
      }
    ],
    "SessionEnd": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/state-save.sh",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

**IMPORTANT:** The existing `hooks.json` format does NOT match the official documentation format. The current file uses `"event"` and `"matcher"` at the top level, but the official format uses event names as keys in a `"hooks"` object, with nested matcher groups. This needs to be corrected in Phase 6. The existing hook may have been working because Claude Code was lenient with the format, but the canonical format from official docs should be used.

### Pattern 4: Cost Tracking -- Estimated Token Accumulation Per Goal

**What:** Track estimated token usage per goal by logging approximate costs after each task.

**When to use:** After every task completion, during the syncer's STATE.md update.

**Implementation approach:**
Claude Code does not expose per-task token counts programmatically within the plugin system. The `/cost` command shows session-level costs, but this data is not accessible from hooks or scripts. The transcript `.jsonl` files contain compaction metadata with `preTokens` values, but these reflect context window usage at compaction time, not per-task costs.

**Recommended approach -- estimated cost tracking:**
1. After each task, estimate the token cost based on the assembled context size (already calculated as part of the context budget) plus a multiplier for output tokens
2. Use the formula: `estimated_tokens = (context_chars / 4) * 2.5` (input tokens + estimated output and reasoning tokens)
3. The syncer accumulates this estimate in STATE.md under the current goal's cost entry
4. Dollar conversion uses a configurable rate (default: $10 per 1M tokens for Opus, adjustable in config.json)

**Why estimation, not exact tracking:**
- Claude Code's `/cost` command shows session costs but is not programmatically accessible
- Transcript files have compaction data but not clean per-task token counts
- The user decision explicitly says per-goal granularity (not per-task), so exact per-task precision is not needed
- Estimates are transparent: show "~320K tokens (~$3.20)" to indicate approximation

**How the syncer handles cost:**
The build skill passes the assembled context size (in characters) to the syncer as part of the task context. The syncer converts this to an estimated token count and accumulates it in STATE.md.

**Detailed cost breakdown (Claude's Discretion -- recommendation: argument-based):**
- Default `/director:status` shows cost summary inline with goals: "Goal 1: 320K tokens ($3.20)"
- `/director:status cost` (or `/director:status detailed`) shows expanded breakdown:

```
Cost breakdown:

Goal 1: Users can sign up and log in
  Total: ~320K tokens (~$3.20)
  Step 1: Database setup -- ~120K tokens (~$1.20)
  Step 2: Login page -- ~200K tokens (~$2.00)
  Step 3: Signup flow -- not started
  Step 4: Profile page -- not started

Goal 2: Dashboard
  Not started

Project total: ~320K tokens (~$3.20)

Note: These are estimates based on context size. Actual costs
may vary based on model, caching, and response length.
```

Using `$ARGUMENTS` to trigger detailed view is consistent with how inspect handles scope (`/director:inspect goal`, `/director:inspect all`). The status skill already accepts `$ARGUMENTS`.

### Pattern 5: Session-Start Hook Enhancement

**What:** Expand the session-start script to provide richer context for Claude's initial state awareness.

**Current behavior:** Outputs a compact JSON with status, goal, step, task, and mode.

**Enhanced behavior:** Add last session date and a "context hint" for resume awareness:

```bash
# Output includes session info for resume detection
cat << EOF
{"director":{"status":"${STATUS}","goal":"${CURRENT_GOAL}","step":"${CURRENT_STEP}","task":"${CURRENT_TASK}","mode":"${MODE}","last_session":"${LAST_SESSION}"}}
EOF
```

This lets Claude know during any interaction that a project exists and when it was last worked on, enabling natural prompts like "use /director:resume to see what changed."

### Anti-Patterns to Avoid

- **Storing state in config.json:** Config is for user preferences, not progress tracking. State belongs in STATE.md.
- **Parsing STATE.md with complex regex:** Keep patterns simple. `grep -m1 '^\*\*Current goal:\*\*'` is reliable. Don't attempt multi-line parsing in shell scripts.
- **Making cost tracking a gate:** Per the locked decision, no pre-task cost warnings. Cost is informational and after-the-fact only.
- **Auto-committing STATE.md separately from tasks:** STATE.md changes are part of the task commit (amend-committed by the build skill after syncer runs). The SessionEnd hook only updates the last-session timestamp, which is a lightweight non-committed change.
- **Showing raw STATE.md to users:** The status skill transforms state data into a visual display. Users never see the raw Markdown format of STATE.md.
- **Using git timestamps for "last session":** Git timestamps reflect commit times, not session times. Use an explicit `**Last session:**` field in STATE.md updated by the SessionEnd hook.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Progress bar rendering | Custom character-counting library | Simple string multiplication in skill instructions | `█` * (percent/5) + `─` * (20 - filled) -- arithmetic Claude can do inline |
| State parsing from shell | jq-based JSON state file | grep/sed on structured Markdown patterns | Shell scripts already use this pattern (session-start.sh); consistent with existing approach |
| External change detection | Custom file watcher or fsevents | `git diff --stat` + `git log --after` | Git already tracks all changes; no daemon needed |
| Token counting | tiktoken or API-based counter | Character count / 4 estimation | Same approximation used for context budget; consistent and no dependencies |
| Session persistence | Custom daemon or background process | SessionEnd hook in hooks.json | Claude Code provides the hook; it fires reliably on session exit |
| Cost rate lookup | API call to pricing endpoint | Hardcoded rate in config.json with sensible default | Pricing changes infrequently; user can update config.json if needed |

**Key insight:** The entire phase is about restructuring data flow and display formatting within existing plugin primitives. No new tools, no new agent types, no new scripts beyond the SessionEnd state-save script.

## Common Pitfalls

### Pitfall 1: STATE.md Format Divergence Between Init and Syncer

**What goes wrong:** The init script creates STATE.md with one format, and the syncer updates it with a different structure, leading to parsing failures in the status and resume skills.

**Why it happens:** Three components write to STATE.md (init script, syncer, SessionEnd hook) and two read from it (session-start.sh, status/resume skills). Without a single source of truth for the format, they drift.

**How to avoid:** Define the STATE.md format once in the research doc (above) and use it consistently across all components. The init script creates the initial structure. The syncer updates values within that structure. The SessionEnd hook only touches the `**Last session:**` and `**Last updated:**` fields. The status and resume skills read the structure using the same grep patterns.

**Warning signs:** Status skill shows "unknown" for progress. Resume skill can't identify last completed task.

### Pitfall 2: SessionEnd Hook Timeout on Large Projects

**What goes wrong:** The state-save script tries to do too much (full state recalculation) during SessionEnd, exceeds the timeout, and STATE.md ends up stale.

**Why it happens:** SessionEnd hooks have a 600-second default timeout, but should be kept fast. If the script tries to scan the entire goals directory to recalculate progress counts, it may be slow on large projects.

**How to avoid:** The SessionEnd hook should ONLY update the `**Last session:**` and `**Last updated:**` timestamps. All progress tracking updates happen during the post-task syncer flow, which has plenty of time. The SessionEnd hook is a lightweight timestamp update, not a full recalculation.

**Warning signs:** STATE.md's `Last session` field not updating. Resume skill shows wrong break duration.

### Pitfall 3: External Change Detection False Positives

**What goes wrong:** Resume flags every uncommitted file as an "external change," overwhelming the user with noise about files that were just temporarily modified (e.g., node_modules rebuild, IDE config changes).

**Why it happens:** `git diff --stat` shows ALL uncommitted changes, not just meaningful ones.

**How to avoid:** Filter the diff output to focus on source files relevant to the project. Ignore changes in:
- `node_modules/`, `.next/`, `dist/`, `build/` (build artifacts)
- `.director/` (managed by Director itself)
- Common IDE/editor files (`.idea/`, `.vscode/settings.json`, `.DS_Store`)

Additionally, only flag changes that overlap with upcoming task scope. If a modified file isn't mentioned in the next ready task, it's informational but not urgent.

**Warning signs:** Resume output is cluttered with irrelevant file changes. User ignores the resume summary because it's too noisy.

### Pitfall 4: Cost Tracking Accumulation Errors

**What goes wrong:** Token estimates accumulate incorrectly across tasks -- either double-counting or missing tasks, leading to wildly inaccurate cost totals.

**Why it happens:** The syncer adds estimated tokens to the goal's running total. If the syncer runs twice (e.g., on a retry), or if the build skill passes wrong context size data, the accumulation goes wrong.

**How to avoid:** The syncer should track cost per task in Recent Activity entries (with the estimate visible), making the accumulation auditable. The per-goal total is the sum of all task-level entries. If a discrepancy appears, the individual entries can be reviewed.

Additionally, mark cost updates as idempotent -- include a task identifier so the syncer doesn't add the same task's cost twice even if re-invoked.

**Warning signs:** Cost totals seem unreasonably high or low. Individual task cost entries don't sum to the goal total.

### Pitfall 5: Progress Bar Calculation Off-By-One

**What goes wrong:** Progress bar shows 100% but tasks remain, or shows 0% when tasks are complete. Step/task counts are wrong.

**Why it happens:** The status skill calculates progress from STATE.md data, but the actual `.done.md` file count in the goals directory may differ from what STATE.md reports (if the syncer failed to update STATE.md after a task).

**How to avoid:** The status skill should calculate progress from BOTH STATE.md (fast, usually correct) AND the actual file system (ground truth). If they disagree, use the file system count (scanning for `.done.md` files) and log a note that STATE.md may need updating.

**Warning signs:** Progress bar shows incorrect percentage. Step says "3/5 tasks" but only 2 `.done.md` files exist.

### Pitfall 6: Resume Tone Mismatch

**What goes wrong:** Resume uses an enthusiastic "Welcome back!" tone for a user who was gone 5 minutes, or a terse "Last: login page. Next: signup" for someone returning after a week.

**Why it happens:** No calibration between break length and tone.

**How to avoid:** Calculate break length from `**Last session:**` timestamp. Apply tone rules:
- < 2 hours: efficient, no "welcome back" -- "Picking up where you left off. Next: [task]."
- 2-24 hours: balanced -- "Welcome back. Last time you finished [task]. Next up: [task]."
- 1-7 days: warm, more context -- "Welcome back! It's been [N] days. Here's where things stand: [summary]."
- 7+ days: full recap -- "Welcome back! It's been a while. Let me bring you up to speed: [full project status]."

**Warning signs:** Users feel the resume message is oddly formal or oddly casual for the situation.

## Code Examples

### Example 1: STATE.md Init Template (Updated)

```markdown
# Project State

**Status:** Not started
**Last updated:** [timestamp]
**Last session:** [timestamp]

## Current Position

**Current goal:** None
**Current step:** None
**Current task:** None
**Position:** Not started

## Progress

No goals defined yet. Run `/director:onboard` to begin.

## Recent Activity

No activity yet.

## Decisions Log

No decisions recorded yet.

## Cost Summary

**Total:** 0 tokens ($0.00)
```

### Example 2: Status Skill Structure (Full Rewrite)

```yaml
---
name: status
description: "See your project progress at a glance."
disable-model-invocation: true
---
```

The status skill structure:

```
## Dynamic Context

<project_state>
!`cat .director/STATE.md 2>/dev/null || echo "NO_PROJECT"`
</project_state>

<project_config>
!`cat .director/config.json 2>/dev/null || echo "{}"`
</project_config>

<gameplan>
!`cat .director/GAMEPLAN.md 2>/dev/null || echo "NO_GAMEPLAN"`
</gameplan>

## Step 1: Check for a project
[If NO_PROJECT, route to onboard]

## Step 2: Check for arguments
[If $ARGUMENTS contains "cost" or "detailed", show detailed cost breakdown]
[Otherwise, show default view]

## Step 3: Calculate progress from file system (ground truth)
[Scan .director/goals/ for .done.md counts]
[Compare with STATE.md counts; use file system if they disagree]

## Step 4: Render progress display
[Build visual output: goal bars, step counts, suggestions]

## Step 5: Find ready task
[Scan for next ready task using build skill's task selection algorithm]
[Show suggestion at bottom]
```

### Example 3: Resume Skill Structure (Full Rewrite)

```yaml
---
name: resume
description: "Pick up where you left off after a break. Restores your context automatically."
disable-model-invocation: true
---
```

The resume skill structure:

```
## Dynamic Context

<project_state>
!`cat .director/STATE.md 2>/dev/null || echo "NO_PROJECT"`
</project_state>

<recent_git>
!`git log --oneline -20 2>/dev/null || echo "NO_GIT"`
</recent_git>

<external_changes>
!`git diff --stat 2>/dev/null || echo "NO_CHANGES"`
</external_changes>

## Step 1: Check for a project
[If NO_PROJECT, route to onboard]

## Step 2: Calculate break length
[Parse Last session from STATE.md]
[Calculate time since then]
[Select appropriate tone]

## Step 3: Reconstruct last session
[Read Recent Activity from STATE.md for last session entries]
[Summarize what was accomplished]

## Step 4: Detect external changes
[Parse external_changes for meaningful modifications]
[Filter out build artifacts, IDE files, .director/]
[Cross-reference with next ready task's scope]

## Step 5: Find next action
[Same task selection as build/status]
[Frame as suggestion]

## Step 6: Present resume summary
[Combine: last session recap + external changes + next suggestion]
[Apply tone based on break length]
```

### Example 4: SessionEnd State Save Script

```bash
#!/usr/bin/env bash
# state-save.sh
# Runs on SessionEnd hook to update STATE.md timestamps.
# Lightweight -- only updates timestamps, never recalculates progress.

# No project -- exit silently
if [ ! -f ".director/STATE.md" ]; then
  exit 0
fi

TIMESTAMP=$(date '+%Y-%m-%d %H:%M')
DATE=$(date '+%Y-%m-%d')

# Update Last updated timestamp
if grep -q '^\*\*Last updated:\*\*' .director/STATE.md; then
  sed -i '' "s/^\*\*Last updated:\*\*.*/\*\*Last updated:\*\* ${TIMESTAMP}/" .director/STATE.md
fi

# Update Last session timestamp
if grep -q '^\*\*Last session:\*\*' .director/STATE.md; then
  sed -i '' "s/^\*\*Last session:\*\*.*/\*\*Last session:\*\* ${DATE}/" .director/STATE.md
fi

exit 0
```

**Platform note:** The `sed -i ''` syntax is macOS-specific. For cross-platform compatibility, use:
```bash
if [[ "$OSTYPE" == "darwin"* ]]; then
  sed -i '' "s/pattern/replacement/" file
else
  sed -i "s/pattern/replacement/" file
fi
```

### Example 5: Progress Bar Generation Logic

The status skill instructs Claude to generate progress bars using this pattern:

```
For each goal:
1. Count completed tasks / total tasks across all steps
2. Calculate percentage: (completed / total) * 100
3. Calculate filled blocks: round(percentage / 5)  [20 total blocks]
4. Render: [█ * filled_blocks + ─ * (20 - filled_blocks)] percentage%

Example: 8 of 14 tasks = 57%
  filled = round(57/5) = 11
  bar = [███████████─────────] 57%
```

### Example 6: Syncer Cost Tracking Update

When the build skill passes context to the syncer, it includes cost data:

```xml
<task>[Original task file content]</task>
<changes>[git diff summary]</changes>
<cost_data>
Context size: 24000 characters
Estimated tokens: 15000
Goal: Goal 1
</cost_data>
<instructions>
Update STATE.md with task completion, progress counts, and cost tracking.
Add the estimated token cost to Goal 1's running total.
Log the task in Recent Activity with the cost estimate.
</instructions>
```

The syncer adds to STATE.md:

```markdown
## Recent Activity

- [2026-02-08 14:32] Completed: Connect login form to authentication (~15K tokens)
```

And updates the goal's cost line:

```markdown
**Cost:** 335K tokens ($3.35)
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Placeholder status/resume skills | Full implementation with progress bars and external change detection | Phase 6 | Users see real progress and context on resume |
| Minimal STATE.md (status, position only) | Rich STATE.md with progress, activity, decisions, and cost | Phase 6 | STATE.md becomes the single source of truth for project state |
| No SessionEnd hook | SessionEnd hook for timestamp persistence | Phase 6 | STATE.md never stale -- last session date always accurate |
| No cost tracking | Estimated per-goal token tracking | Phase 6 | Users can see how much each goal costs in tokens and dollars |
| SessionStart hook only (existing) | SessionStart + SessionEnd hooks | Phase 6 | Full session lifecycle coverage for state management |

**Important: Hooks.json format correction**
The existing `hooks.json` uses a non-standard flat array format:
```json
{
  "hooks": [
    {"event": "SessionStart", "matcher": "startup", "command": "...", "timeout": 5, "statusMessage": "..."}
  ]
}
```

The official format (from Claude Code docs fetched 2026-02-08) uses event-keyed nested objects:
```json
{
  "hooks": {
    "SessionStart": [
      {"matcher": "startup", "hooks": [{"type": "command", "command": "...", "timeout": 5, "statusMessage": "..."}]}
    ]
  }
}
```

Phase 6 should correct this format when adding the SessionEnd hook. If the existing format is working due to backwards compatibility, test the new format before switching.

## Claude's Discretion Recommendations

### Blocked items visual treatment: Inline

**Recommendation:** Show blocked items inline with the step listing rather than in a separate section.

```
  Step 3: Signup flow -- 0/3 tasks (needs login page first)
```

**Reasoning:** A separate "Blocked" section would require the user to cross-reference between two parts of the display. Inline keeps all information about a step in one place. The blocked reason is short enough (plain language, per terminology rules) to fit naturally after the task count.

### Resume tone: Context-sensitive based on break length

**Recommendation:** Calculate break length from STATE.md's `**Last session:**` field and adapt:
- Under 2 hours: efficient pickup
- 2-24 hours: balanced welcome back
- 1-7 days: warm with more context
- Over 7 days: full project recap

See Pitfall 6 above for specific phrasing examples.

### STATE.md format: Structured Markdown with consistent key-value patterns

**Recommendation:** Use the format shown in the Architecture Patterns section above. Key principles:
- `**Key:** Value` pattern for all parseable fields (matches existing session-start.sh parsing)
- Section headers for logical grouping (Progress, Recent Activity, Decisions Log, Cost Summary)
- Per-goal subsections under Progress with step listings
- Recent Activity as a timestamped log (most recent first)
- Decisions Log as a timestamped list of key decisions

### Detailed cost breakdown: Argument-based (`/director:status cost`)

**Recommendation:** Use `$ARGUMENTS` to control detail level, consistent with how inspect handles scope:
- `/director:status` -- default view with inline cost per goal
- `/director:status cost` -- expanded cost breakdown with per-step detail
- `/director:status detailed` -- alias for `cost` (either works)

## Open Questions

1. **hooks.json format compatibility**
   - What we know: The existing hooks.json uses a flat array format. The official docs show a nested event-keyed format.
   - What's unclear: Whether the flat format works because of backwards compatibility, or was it always the correct format and the docs changed since Phase 1.
   - Recommendation: Test the official format. If it works, migrate. If not, keep the existing format and add the SessionEnd hook in the same style.

2. **Cost tracking rate configuration**
   - What we know: Token-to-dollar conversion needs a rate. Default should be ~$10/1M tokens for Opus-class models.
   - What's unclear: Whether to hardcode the rate, put it in config.json, or derive it from the agent model setting.
   - Recommendation: Add a `cost_rate` field to config.json with a sensible default. The syncer reads it when calculating costs. This lets users adjust if they use different models or pricing changes.

3. **STATE.md and git -- SessionEnd writes vs uncommitted changes**
   - What we know: STATE.md changes from the syncer are amend-committed as part of task commits. The SessionEnd hook updates timestamps outside of any task.
   - What's unclear: Whether the SessionEnd timestamp update should be committed separately, left uncommitted, or handled differently.
   - Recommendation: Leave the SessionEnd timestamp update uncommitted. It's a lightweight change that will be picked up by the next task's commit. If the user never returns, the uncommitted timestamp doesn't matter. If they do return, the resume skill reads the file (committed or not) and the next task commit picks it up.

4. **Decisions log -- what qualifies as a "key decision"**
   - What we know: STATE.md should track key decisions made during building.
   - What's unclear: How the syncer determines what's a "key decision" vs routine implementation detail.
   - Recommendation: The builder agent surfaces decisions in its output when it makes a significant choice (library selection, architecture pattern, approach change). The syncer extracts these from the builder's output and logs them. The builder's existing plain-language output format naturally describes these decisions. Start simple: if the builder mentions choosing between alternatives, log it.

## Sources

### Primary (HIGH confidence)
- [Claude Code Hooks Reference](https://code.claude.com/docs/en/hooks) -- Complete hooks documentation including SessionStart, SessionEnd, all events, input/output schemas, and plugin hooks format. Fetched 2026-02-08.
- [Claude Code Cost Management](https://code.claude.com/docs/en/costs) -- Cost tracking, /cost command, token usage optimization. Fetched 2026-02-08.
- [Claude Code Sub-agents](https://code.claude.com/docs/en/sub-agents) -- Sub-agent configuration, transcript paths, persistent memory, SubagentStop hooks. Fetched 2026-02-08.
- Director codebase (existing Phases 1-5 artifacts) -- All skill definitions, agent definitions, templates, reference docs, hooks, scripts. Read directly from `/Users/noahrasheta/Dev/GitHub/director/`. HIGH confidence.
- Phase 4 Research (`04-RESEARCH.md`) -- Execution engine patterns, context assembly, syncer flow, post-task orchestration. Read directly from `.planning/phases/04-execution/`.
- GSD STATE.md (`.planning/STATE.md`) -- Prior decisions affecting Phase 6, including state persistence and celebration timing decisions.

### Secondary (MEDIUM confidence)
- [GitHub Issue #7881](https://github.com/anthropics/claude-code/issues/7881) -- SubagentStop hook limitation: shared session IDs make it hard to identify which subagent finished. Confirms that SubagentStop is not ideal for per-task cost tracking.
- Claude Code `/cost` command behavior -- Confirmed via official docs that it shows session-level costs and is not programmatically accessible from hooks/scripts.

### Tertiary (LOW confidence)
- Token cost estimation formula (chars/4 * 2.5 multiplier) -- Based on general industry knowledge about input/output token ratios. The 2.5x multiplier is an approximation; actual ratios vary by task complexity and model.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH -- All components verified from official Claude Code documentation and existing codebase
- Architecture patterns: HIGH -- STATUS.md format, display patterns, and hook usage verified from official docs and established project patterns
- Cost tracking: MEDIUM -- Estimation approach is sound but the exact multiplier and rate are approximations; cost accuracy is explicitly labeled as estimates
- Pitfalls: HIGH -- Informed by 16 completed plans across 5 phases and official documentation on hook behavior
- Code examples: HIGH -- Based on existing Director patterns (session-start.sh, syncer, build skill) adapted for Phase 6 requirements

**Research date:** 2026-02-08
**Valid until:** 2026-03-08 (30 days -- Claude Code plugin system is stable)
