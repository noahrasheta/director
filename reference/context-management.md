# Context Management Reference

This document defines how Director assembles context for fresh agent windows. Every agent spawn, skill execution, and task delegation follows these rules.

## Core Principle

Each task gets a NEW agent context with only what it needs. No accumulated conversation history. This keeps AI quality high and costs low.

---

## Three-Layer Formatting Model

Director uses three distinct layers for information storage and transmission. Each layer has a specific audience and format.

### Layer 1: User-Facing (Markdown)

**Format:** Markdown files in `.director/`
**Audience:** Vibe coders -- they read and edit these directly
**Examples:** VISION.md, GAMEPLAN.md, STEP.md, task files

These files use standard Markdown with no special syntax. Users can open them in any text editor or IDE preview. They are the source of truth for project intent.

### Layer 2: Agent Context (XML Boundaries Wrapping Markdown)

**Format:** XML boundary tags containing Markdown content
**Audience:** AI agents only -- assembled at runtime, invisible to users
**Purpose:** Prevents AI models from confusing one section with another

XML boundaries are added when assembling agent context. The Markdown content inside each tag is unchanged -- the tags just delineate sections clearly for the AI.

Users never see this layer. It exists only in the assembled prompt sent to a fresh agent.

### Layer 3: Machine State (JSON)

**Format:** JSON files
**Audience:** Neither users nor agents edit these directly
**Examples:** config.json, machine-readable sections of STATE.md

Machine state tracks internal configuration, metrics, and progress data. It is read programmatically, not by humans or AI for decision-making.

---

## XML Boundary Tags

These are the standard tags used when assembling agent context. Each tag wraps a specific piece of project information.

### Standard Tags

| Tag | Content | When Included |
|----|----|----|
| `<vision>` | Contents of `.director/VISION.md` | Always -- every agent context |
| `<gameplan>` | Contents of `.director/GAMEPLAN.md` | When agent needs project-wide view (planner, inspector) |
| `<current_step>` | Contents of relevant `STEP.md` | Always during build -- scopes agent to current step |
| `<decisions>` | User decisions from STEP.md Decisions section | During build, if STEP.md has a Decisions section |
| `<task>` | Task description, acceptance criteria, file scope | Always during build -- the specific work to do |
| `<recent_changes>` | Recent git log summary (plain language) | Always -- provides continuity between fresh contexts |
| `<instructions>` | Task-specific constraints and rules | Always -- guardrails for the agent |
| `<project_state>` | Contents of `.director/STATE.md` | When agent needs progress awareness (status, resume) |

### Deep Context Tags (v1.1)

These tags were added in v1.1 for the deep context system. They carry research and codebase analysis produced by deep researcher and deep mapper agents.

| Tag | Content | When Included |
|----|----|----|
| `<research>` | Contents of a specific `.director/research/` file | When agent needs domain knowledge for current task |
| `<codebase>` | Contents of a specific `.director/codebase/` file | When agent needs codebase awareness for current task |
| `<research_summary>` | Contents of `.director/research/SUMMARY.md` | When agent needs broad research overview |
| `<codebase_summary>` | Contents of `.director/codebase/SUMMARY.md` | When agent needs broad codebase overview |
| `<step_research>` | Contents of a step's RESEARCH.md file (from step-level research) | When planner needs step-specific technical research during task planning |

**Usage notes:**
- `<research>` and `<codebase>` carry individual files (e.g., STACK.md, ARCHITECTURE.md) when the task relates to a specific domain
- `<research_summary>` and `<codebase_summary>` carry synthesized overviews when the agent needs broad awareness without full detail
- A single agent context may include both a summary tag AND a specific file tag if the task spans domains
- Deep context tags follow the same nesting rules as standard tags (no nesting, top-level only)

### Tag Nesting Rules

- Tags are **not nested** -- they sit side by side at the top level of the assembled context
- Order matters: vision first, then scoping (step/task), then context (changes/state), then instructions last
- Each tag appears at most once per assembled context

### Assembly Example

```xml
<vision>
# My Social Media App
Build a platform where creators can share short-form content...
[Full contents of VISION.md]
</vision>

<current_step>
# Step 2: Core Features
Build the main user-facing features: feed, posting, profiles...
[Full contents of relevant STEP.md]
</current_step>

<decisions>
These are the user's decisions for this step. Follow them exactly:

### Locked
- Use Supabase for the database
- Keep the API RESTful, no GraphQL

### Flexible
- Styling approach -- user has no preference

### Deferred
- Dark mode support -- saving for later

RULES:
- Locked items are non-negotiable -- follow them exactly as stated.
- Flexible items are your choice -- use your best judgment.
- Deferred items are out of scope -- do NOT implement them, even partially.
</decisions>

<task>
## Build the user profile page
Show user's name, bio, avatar, and their recent posts.
**Files:** src/pages/Profile.tsx, src/components/UserCard.tsx
**Acceptance:** Profile page loads and displays user data from the database.
</task>

<recent_changes>
Recent progress:
- Login and signup pages are working
- Database has users table with authentication
- Navigation bar links to all main pages
</recent_changes>

<instructions>
Complete only this task. Do not modify files outside the listed scope.
Verify your work matches the acceptance criteria before finishing.
Follow terminology.md and plain-language-guide.md for any user-facing output.
</instructions>
```

---

## Fresh Context Assembly Rules

### What Gets Included

Every fresh agent context includes:

1. **VISION.md** (always) -- The source of truth for what the project is
2. **Relevant STEP.md** (always during build) -- Scopes the agent to the current step
3. **Task file** (always during build) -- The specific work to complete
4. **Recent git log** (always) -- What was built recently, providing continuity
5. **Reference docs** (as needed) -- terminology.md, plain-language-guide.md, verification-patterns.md

### What Gets Excluded

Fresh contexts deliberately exclude:

- **Other tasks** -- Agent should focus on its task only
- **Other steps** -- Agent doesn't need the full project scope
- **Full conversation history** -- The entire point of fresh context
- **Other agents' output** -- Unless specifically relevant (e.g., research findings)
- **Full codebase** -- Agent reads files on demand, not in context

### Why Fresh Context

1. **Quality** -- Long conversations degrade AI output quality
2. **Cost** -- Smaller contexts use fewer tokens
3. **Focus** -- Agent works on one task without distraction
4. **Reproducibility** -- Same context produces similar results

---

## Context Budget

### The 30% Rule

Assembled context (all XML-wrapped sections combined) should stay under 30% of the estimated context window. This leaves room for:

- The agent's system prompt and tool definitions
- Code the agent reads during execution
- The agent's own reasoning and output
- Conversation turns if the agent asks for clarification

### Budget Allocation Guidelines

| Section | Target Budget | Notes |
|----|----|----|
| Vision | 5-10% | Usually concise; trim if very long |
| Current step | 3-5% | Step description and context |
| Task | 2-5% | Task details and acceptance criteria |
| Recent changes | 3-5% | Most recent N commits; truncate if needed |
| Instructions | 1-2% | Short, specific constraints |
| Reference docs | 5-10% | Only include docs the agent needs |
| Deep context (research + codebase) | 3-8% | Only when agent needs research or codebase awareness; prefer summaries over full files |
| **Total** | **~20-30%** | Leave 70%+ for execution |

### Truncation Strategy

When context exceeds the budget:

1. **Git log first** -- Reduce to most recent N commits (least critical for task completion)
2. **Reference docs second** -- Include only the reference doc sections relevant to the task
3. **Step context third** -- Summarize rather than include full STEP.md
4. **Never truncate task or vision** -- These are essential for correct execution
5. **Never truncate decisions** -- User decisions are essential for correct execution. The `<decisions>` section is small (typically under 100 tokens) and must always be included in full.

### Deep Context Truncation

When deep context tags (`<research>`, `<codebase>`, `<research_summary>`, `<codebase_summary>`) push context over budget, apply these rules in order:

1. **Summaries over specifics** -- Replace individual `<research>` or `<codebase>` files with the corresponding summary tag. Summaries are smaller and usually sufficient.
2. **Research before codebase** -- Research provides ecosystem knowledge that is less actionable than codebase awareness during execution. Drop research files before codebase files.
3. **Drop unrelated domains** -- If the task is about UI, drop `STACK.md` from codebase context. If the task is about architecture, drop `TESTING.md`. Only include files relevant to the task domain.
4. **Never drop research during planning** -- When the planner is creating a gameplan, research context is essential. Truncate other sections (git log, step context) before removing research.
5. **Never drop codebase during build** -- When the builder is implementing a task in an existing project, codebase context helps maintain consistency. Truncate other sections first.

---

## Context Budget Calculator (Design Notes)

The context budget calculator is planned for Phase 4 implementation. These are the design requirements.

### Requirements

1. **Token estimation** -- Approximate token count of each assembled section (use character count / 4 as rough estimate)
2. **Window awareness** -- Know the estimated context window size for the current model
3. **Budget tracking** -- Calculate percentage of window used by assembled context
4. **Warning threshold** -- Warn if assembled context exceeds 30% of estimated window
5. **Auto-truncation** -- Apply truncation strategy automatically when budget is exceeded

### Interface (Conceptual)

```
Context Budget Report:
  Vision:          1,200 tokens (3%)
  Current Step:      800 tokens (2%)
  Task:              400 tokens (1%)
  Recent Changes:  2,000 tokens (5%)
  Instructions:      200 tokens (0.5%)
  Reference Docs:  3,000 tokens (7.5%)
  ─────────────────────────────
  Total:           7,600 tokens (19%)
  Budget:          12,000 tokens (30%)
  Status:          Within budget
```

### Implementation Notes

- Token counting does not need to be exact -- approximate is fine for budget management
- The calculator runs before agent spawn, not during
- If budget is exceeded, log a warning and apply truncation before spawning
- Store budget reports for debugging context-related quality issues

---

## Dynamic Context Injection

Skills can dynamically inject context using the `!command` syntax in SKILL.md files. This allows skills to load fresh data at execution time rather than having static context.

### How It Works

In a SKILL.md instruction field, backtick-wrapped commands prefixed with `!` are executed at skill load time, and their output is injected into the context:

```
Load project vision: !cat .director/VISION.md
Load current state: !cat .director/STATE.md
```

### Guidelines

- Use dynamic injection for data that changes between executions (state, git log, task files)
- Use static text for instructions and rules that don't change
- Keep injected content within the context budget
- Prefer reading specific files over running complex commands

---

## Agent-Specific Context Profiles

Different agents need different context combinations. These profiles define what each agent type receives.

| Agent | Vision | Gameplan | Step | Task | Recent Changes | Instructions | State | Decisions | Research | Codebase |
|----|----|----|----|----|----|----|---|---|---|---|
| Builder | Yes | No | Yes | Yes | Yes | Yes | No | Yes | As needed | As needed |
| Planner | Yes | Yes | No | No | Yes | Yes | Yes | No | Summary | Summary |
| Verifier | Yes | No | Yes | Yes | Yes | Yes | No | No | No | No |
| Interviewer | Yes | No | No | No | No | Yes | No | No | No | No |
| Inspector | Yes | Yes | No | No | Yes | Yes | Yes | No | Summary | Summary |
| Syncer | Yes | No | Yes | No | Yes | Yes | No | No | No | No |
| Mapper | No | No | No | No | No | Yes | No | No | No | No |
| Researcher | Yes | No | Yes | Yes | No | Yes | No | No | No | No |
| Deep Researcher | Yes | No | No | No | No | Yes | No | No | No | No |
| Deep Mapper | Optional | No | No | No | No | Yes | No | No | No | No |
| Synthesizer | No | No | No | No | No | Yes | No | No | Reads directly | No |

**Research and Codebase column values:**
- **Yes / As needed** -- Include the specific file(s) relevant to the task domain (e.g., `<research>` with STACK.md for a setup task, `<codebase>` with CONVENTIONS.md for a build task)
- **Summary** -- Include only the summary file (`<research_summary>` or `<codebase_summary>`) for broad awareness
- **Reads directly** -- Agent reads files from disk using tools rather than receiving them in assembled context
- **No** -- Never include this context type for this agent

**Note on Deep Researcher:** Deep Researcher can also be spawned by the blueprint skill for step-level research. When spawned for step-level research, it receives step context and user decisions via `<instructions>` rather than assembled context tags. Output goes to the step directory (e.g., `.director/goals/NN-goal/NN-step/RESEARCH.md`) instead of `.director/research/`.

These profiles are guidelines. Specific tasks may require additional or fewer context sections.

### Skill-Level Context Profiles

Different skills pre-load different combinations of research and codebase files. This table documents what each downstream skill loads into its context before execution.

| Skill | Research Files | Codebase Files | Loading Pattern |
|-------|---------------|----------------|-----------------|
| Blueprint | SUMMARY.md | None | Loads before goal generation; informs planning |
| Build | None (baked into task by planner) | 1-2 task-type-specific files | Task-type detection: UI gets CONVENTIONS+STRUCTURE, API gets ARCHITECTURE+CONVENTIONS, testing gets TESTING+CONVENTIONS, general gets CONVENTIONS only |
| Brainstorm | SUMMARY.md, FEATURES.md | ARCHITECTURE.md, STACK.md | Richest context; loaded in Step 2 alongside VISION.md and STATE.md |
| Pivot | SUMMARY.md, FEATURES.md | ARCHITECTURE.md, STACK.md | Same as Brainstorm; loaded in Step 5a before impact analysis |
| Inspect | None | CONVENTIONS.md, TESTING.md | Loaded before spawning verifier; informs verification standards |

**Build task-type file selection:**

| Task Type | Keywords Detected | Files Loaded |
|-----------|------------------|--------------|
| UI | page, component, form, layout, button, modal, style, CSS, Tailwind, responsive, visual, screen, view, template, render | CONVENTIONS.md + STRUCTURE.md |
| API | endpoint, route, API, request, response, database, query, schema, model, migration, REST, GraphQL, server, middleware | ARCHITECTURE.md + CONVENTIONS.md |
| Testing | test, spec, coverage, assert, expect, mock, fixture, e2e, unit test, integration test | TESTING.md + CONVENTIONS.md |
| General | No keyword match | CONVENTIONS.md only |

All loading uses `cat ... 2>/dev/null` for graceful fallback. If a file does not exist, it is silently skipped -- no empty XML tags, no warnings to agent or user. Skills work identically whether files exist or not.

Context budget: File selections are designed to stay under the 30% budget naturally (~15-20KB for the heaviest skill, Brainstorm/Pivot). No runtime token counting is needed. If individual files are unusually large, the skill may truncate with a note or skip entirely (Claude's discretion).
