---
name: director:refresh
description: "Re-scan your codebase and optionally re-run research. Keeps your project context current."
---

# Director Refresh

First, check if `.director/` exists. If it does not, say:

> "No project set up yet. Run `/director:onboard` to get started."

Stop here if no `.director/` exists.

---

## Check Project State

Verify source files exist beyond `.director/`. Check for: `package.json`, `requirements.txt`, `go.mod`, `Cargo.toml`, `Gemfile`, `src/`, `app/`, `lib/`, `pages/`, or common source files (`.ts`, `.tsx`, `.js`, `.jsx`, `.py`, `.rb`, `.go`, `.rs`, `.java`, `.swift`, `.vue`, `.svelte`).

If no source files exist:

> "I don't see any code to analyze. If you've added code since setting up, make sure it's in the project root."

Stop here.

---

## Determine Refresh Scope

Check `$ARGUMENTS` for research-related terms. If arguments contain "research", "everything", "all", or "full": scope = **FULL** (codebase + research). Otherwise: scope = **CODEBASE_ONLY**.

---

## Soft Guard for Research Without Vision

If scope is FULL, read `.director/VISION.md`. Check if it has only placeholder text (`> This file will be populated when you run /director:onboard`, headings with no substantive content, or `_What are you calling this project?_` style markers).

If VISION.md has only placeholder text:

> "Your vision isn't set up yet, so research results may be generic. Want to continue anyway?"

Wait for response. If they decline, switch scope to CODEBASE_ONLY and continue.

---

## Save Current State for Comparison

BEFORE running any pipelines, read the existing summary files so you can compare later:

1. Read `.director/codebase/SUMMARY.md` if it exists. Store contents as baseline. If file does not exist, this is a first-time scan (present findings instead of a diff).
2. If scope is FULL: also read `.director/research/SUMMARY.md` if it exists. Store as baseline.

---

## Codebase Mapping Pipeline

> "Scanning your codebase..."

### Codebase Size Assessment

```bash
find . -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" -o -name "*.py" -o -name "*.rb" -o -name "*.go" -o -name "*.rs" -o -name "*.java" -o -name "*.swift" -o -name "*.vue" -o -name "*.svelte" \) -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/.director/*" -not -path "*/vendor/*" -not -path "*/dist/*" -not -path "*/build/*" | wc -l
```

If more than 500 source files, add a sampling note to each mapper's instructions: "This is a large codebase. Focus on the main source directories first. Sample representative files rather than reading everything. Note what you skipped."

### Model Profile Resolution

Read `.director/config.json` and resolve the model for each agent:

1. Read the `model_profile` field (defaults to "balanced")
2. Look up the profile in `model_profiles` to get base model assignments for `deep-mapper` and `synthesizer`
3. For the `quality` profile, override the arch and concerns mappers to use the most capable model available

If config.json is missing the `model_profile` or `model_profiles` fields, fall back to "balanced" defaults (deep-mapper gets haiku, synthesizer gets sonnet).

### Mapper Spawning

```bash
mkdir -p .director/codebase
```

Spawn 4 director:director-deep-mapper agents IN PARALLEL using 4 simultaneous Task tool calls. All 4 go in a SINGLE message so they run in parallel.

**Agent 1 (tech focus):**
```
<instructions>
Focus area: tech

Analyze the technology stack and external integrations of this codebase. Write your findings to:
- .director/codebase/STACK.md (using the template at skills/onboard/templates/codebase/STACK.md)
- .director/codebase/INTEGRATIONS.md (using the template at skills/onboard/templates/codebase/INTEGRATIONS.md)

Follow your standard mapping process for the tech focus area. Include file paths in backticks for every finding.

Return only a brief confirmation when done. Do NOT return document contents.
</instructions>
```

**Agent 2 (arch focus):**
```
<instructions>
Focus area: arch

Analyze the architecture patterns and file structure of this codebase. Write your findings to:
- .director/codebase/ARCHITECTURE.md (using the template at skills/onboard/templates/codebase/ARCHITECTURE.md)
- .director/codebase/STRUCTURE.md (using the template at skills/onboard/templates/codebase/STRUCTURE.md)

STRUCTURE.md must include a prescriptive "Where to Add New Code" section telling agents exactly where to place new files for each type of addition (new feature, new API route, new component, new test, etc.).

Follow your standard mapping process for the arch focus area. Include file paths in backticks for every finding.

Return only a brief confirmation when done. Do NOT return document contents.
</instructions>
```

**Agent 3 (quality focus):**
```
<instructions>
Focus area: quality

Analyze the coding conventions and testing patterns of this codebase. Write your findings to:
- .director/codebase/CONVENTIONS.md (using the template at skills/onboard/templates/codebase/CONVENTIONS.md)
- .director/codebase/TESTING.md (using the template at skills/onboard/templates/codebase/TESTING.md)

CONVENTIONS.md must use prescriptive voice throughout. Say "Use camelCase for functions" not "Some functions use camelCase." Every convention must be a clear instruction for builder agents.

Follow your standard mapping process for the quality focus area. Include file paths in backticks for every finding.

Return only a brief confirmation when done. Do NOT return document contents.
</instructions>
```

**Agent 4 (concerns focus):**
```
<instructions>
Focus area: concerns

Analyze technical debt, known issues, and fragile areas of this codebase. Write your findings to:
- .director/codebase/CONCERNS.md (using the template at skills/onboard/templates/codebase/CONCERNS.md)

Be specific about the impact of each concern and suggest a fix approach. Prioritize concerns by severity.

Follow your standard mapping process for the concerns focus area. Include file paths in backticks for every finding.

Return only a brief confirmation when done. Do NOT return document contents.
</instructions>
```

If any mapper fails or times out, continue with whatever mappers succeeded. The synthesizer can work with partial input. If ALL mappers fail, fall back to the v1.0 director:director-mapper agent for a basic overview instead.

### Synthesizer Spawning

After ALL 4 mappers complete (or fail), spawn the director:director-synthesizer agent SEQUENTIALLY (not in parallel with mappers).

```
<instructions>
Mode: codebase

Read all codebase analysis files from .director/codebase/ (STACK.md, INTEGRATIONS.md, ARCHITECTURE.md, STRUCTURE.md, CONVENTIONS.md, TESTING.md, CONCERNS.md). Synthesize them into a unified summary.

Write your output to .director/codebase/SUMMARY.md using the template at skills/onboard/templates/codebase/SUMMARY.md.

Cross-reference findings across all files. If different mappers found related information about the same files or patterns, connect them. Resolve any contradictions.

Return only a brief confirmation when done. Do NOT return document contents.
</instructions>
```

---

## Research Pipeline

**Only execute this section if scope is FULL.** If scope is CODEBASE_ONLY, skip to Present Changes.

> "Researching your project's ecosystem..."

```bash
mkdir -p .director/research
```

### Model Profile Resolution

Read `.director/config.json` and resolve models for `deep-researcher` and `synthesizer` using the same profile lookup as above. Fall back to "balanced" defaults if fields are missing.

### Researcher Spawning

Spawn 4 director:director-deep-researcher agents IN PARALLEL using 4 simultaneous Task tool calls. All 4 go in a SINGLE message.

Context for researchers: use `.director/VISION.md` contents as primary context. If VISION.md has only placeholder text, also pass the NEW `.director/codebase/SUMMARY.md` (just produced by the mapping pipeline) so researchers have something substantive.

**Agent 1 (stack domain):**
```
<instructions>
Domain: stack

<project_context>
[Contents of VISION.md. If VISION.md is placeholder-only, also include the new codebase SUMMARY.md here.]
</project_context>

Research the recommended technology stack for this project. Investigate libraries, frameworks, databases, hosting options, and key supporting tools that would work well for this type of project.

Write your findings to .director/research/STACK.md using the template at skills/onboard/templates/research/STACK.md.

Use WebFetch to check official documentation for current versions and best practices. Verify recommendations against authoritative sources.

Return only a brief confirmation when done. Do NOT include file contents in your response.
</instructions>
```

**Agent 2 (features domain):**
```
<instructions>
Domain: features

<project_context>
[Contents of VISION.md. If VISION.md is placeholder-only, also include the new codebase SUMMARY.md here.]
</project_context>

Research features for this type of product. Investigate table stakes (what users expect), differentiators (what sets this product apart), and anti-features (what to avoid). Flag expected features the user may not have mentioned.

Write your findings to .director/research/FEATURES.md using the template at skills/onboard/templates/research/FEATURES.md.

Use WebFetch to check current product landscapes and feature expectations. Verify recommendations against authoritative sources.

Return only a brief confirmation when done. Do NOT include file contents in your response.
</instructions>
```

**Agent 3 (architecture domain):**
```
<instructions>
Domain: architecture

<project_context>
[Contents of VISION.md. If VISION.md is placeholder-only, also include the new codebase SUMMARY.md here.]
</project_context>

Research architecture patterns for this type of project. Investigate system structure, component boundaries, data flow patterns, and how similar projects are typically organized.

Write your findings to .director/research/ARCHITECTURE.md using the template at skills/onboard/templates/research/ARCHITECTURE.md.

Use WebFetch to check current architecture guides and best practices. Verify recommendations against authoritative sources.

Return only a brief confirmation when done. Do NOT include file contents in your response.
</instructions>
```

**Agent 4 (pitfalls domain):**
```
<instructions>
Domain: pitfalls

<project_context>
[Contents of VISION.md. If VISION.md is placeholder-only, also include the new codebase SUMMARY.md here.]
</project_context>

Research common mistakes and pitfalls for this type of project. Investigate stack-specific pitfalls AND broader domain pitfalls -- things that are harder than they look, common causes of rewrites, and what trips up builders working on this type of project.

Write your findings to .director/research/PITFALLS.md using the template at skills/onboard/templates/research/PITFALLS.md.

Use WebFetch to check current documentation for known issues and common mistakes. Verify findings against authoritative sources.

Return only a brief confirmation when done. Do NOT include file contents in your response.
</instructions>
```

### Researcher Failure Handling

If any researcher fails or times out: check which domains completed by looking for files in `.director/research/`. If 3 of 4 succeeded, proceed with partial results and note the gap. If 2 or fewer succeeded, tell the user research had limited results. If ALL failed, tell the user research could not complete and move on gracefully.

### Synthesizer Spawning (Research)

After ALL 4 researchers complete (or fail), spawn the director:director-synthesizer agent SEQUENTIALLY.

```
<instructions>
Mode: research

Read all 4 research files from .director/research/:
- STACK.md
- FEATURES.md
- ARCHITECTURE.md
- PITFALLS.md

Synthesize them into a unified summary.

Write your output to .director/research/SUMMARY.md using the template at skills/onboard/templates/research/SUMMARY.md.

The "Implications for Gameplan" section is critical -- recommend how to structure goals and steps based on the combined research. The "Don't Hand-Roll" section must identify problems with existing library solutions.

Cross-reference findings across all files. If STACK.md recommends a technology and PITFALLS.md warns about it, connect them. If FEATURES.md lists a capability and ARCHITECTURE.md shows how to structure it, link them.

Return only a brief confirmation when done. Do NOT return document contents.
</instructions>
```

---

## Present Changes

Read the newly produced `.director/codebase/SUMMARY.md`. If scope is FULL, also read `.director/research/SUMMARY.md`.

### If baseline existed (re-scan)

Compare the old and new SUMMARY.md files. Identify the 3-5 most significant changes: technology stack changes, architecture pattern changes, testing status changes, new or resolved concerns, new capabilities detected, structural reorganization. Skip minor changes.

> "Your project context is updated. Here's what changed since the last scan:"
>
> **Codebase**
> - [Change 1]
> - [Change 2]
> - [Change 3]
>
> [If research was refreshed:]
> **Research**
> - [Change 1]
> - [Change 2]

If nothing meaningful changed: "Your project context is updated. Everything looks the same as the last scan -- no significant changes detected."

### If no baseline existed (first-time scan)

> "This is the first time I've scanned your codebase. Here's what I found:"
>
> **What this project is** -- [1-2 sentence summary]
>
> **Built with** -- [Main framework], [database], [key libraries]
>
> **What it can do** -- [2-3 user capabilities]
>
> **How it's organized** -- [Brief structure]
>
> **Things worth noting** -- [Top concerns, testing status]

Keep references HIGH-LEVEL. Present findings as collaborative observations, not judgments.

---

## Update Metadata

Read `.director/config.json`. Count completed goals from `.director/goals/`. Set `context_generation.completed_goals_at_generation` to the count. Set `context_generation.generated_at` to today's date (YYYY-MM-DD). Write updated config.json. This is silent -- no user-facing output.

---

## Save Progress

After all files are written (codebase mapping, research, config.json), save progress by committing all `.director/` changes:

```bash
git add .director/
git commit -m "refresh: update project context"
```

This is a SILENT operation -- the user does not see git commands or commit details. If the commit fails (e.g., nothing to commit, git not initialized), proceed silently. The important thing is that the files were written; the commit prevents "unsaved changes" warnings in later commands.

---

## Wrap Up

> "All done. Your downstream commands will automatically use the updated context."

---

## Language Reminders

- **Use Director's vocabulary:** Vision (not spec), Gameplan (not roadmap), Goal/Step/Task (not milestone/phase/ticket)
- **Explain outcomes, not mechanisms:** "Your project context is updated" not "Writing SUMMARY.md to .director/codebase/SUMMARY.md"
- **Be conversational, not imperative:** "Want to continue anyway?" not "Confirm to proceed"
- **Never blame the user:** "Your vision isn't set up yet" not "You forgot to create a vision"
- **Never use developer jargon in output:** No dependencies, artifacts, integration, repositories, branches, commits, schemas, endpoints, middleware
- **Present findings as collaborative observations, not judgments:** "I see that the project uses React" not "The codebase is built with React"

$ARGUMENTS
