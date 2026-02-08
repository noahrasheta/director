# Phase 2: Onboarding - Research

**Researched:** 2026-02-07
**Domain:** Claude Code skill orchestration, adaptive interview workflows, codebase analysis sub-agents
**Confidence:** HIGH

## Summary

Phase 2 transforms the placeholder onboard skill into Director's functional onboarding workflow. The user runs `/director:onboard`, and Director guides them through an adaptive interview (greenfield) or maps their existing codebase (brownfield), producing a completed VISION.md. The technical challenge is orchestrating the conversation and sub-agent spawning from within a SKILL.md file, since the interviewer agent cannot write files (disallowedTools: Write, Edit), meaning the skill must handle all file I/O.

The foundation from Phase 1 is extensive: the interviewer agent (`agents/director-interviewer.md`) has a complete system prompt with 9 interview rules and 8 interview sections. The mapper agent (`agents/director-mapper.md`) has a complete 5-step mapping process. The vision template exists at `skills/onboard/templates/vision-template.md`. The onboard skill (`skills/onboard/SKILL.md`) already has routing logic that detects project state. Phase 2 replaces the placeholder message ("coming in a future update") with the actual interview workflow.

The critical architectural insight is that the onboard SKILL.md acts as the orchestrator -- it is NOT a forked sub-agent but runs inline in the main conversation. Claude follows the skill instructions step by step, spawning sub-agents (interviewer, mapper) via the Task tool when needed. The interviewer runs as a conversation with the user (foreground), while the mapper can run in the background for parallel codebase analysis. After the interview completes, the SKILL.md instructions tell Claude to write VISION.md from the interview output.

**Primary recommendation:** Rewrite `skills/onboard/SKILL.md` to orchestrate the full onboarding workflow inline (no `context: fork`), using the Task tool to spawn the interviewer agent for the interview conversation and the mapper agent for brownfield codebase analysis, then writing VISION.md directly from the results.

## Standard Stack

This phase has no traditional software stack. It modifies existing plugin files (Markdown, JSON, shell scripts).

### Core

| Component | Format | Purpose | Why Standard |
|-----------|--------|---------|--------------|
| `skills/onboard/SKILL.md` | Markdown + YAML frontmatter | Orchestrates the onboarding workflow | Claude Code skill system -- the skill IS the workflow |
| `agents/director-interviewer.md` | Markdown + YAML frontmatter | Conducts the adaptive interview | Already defined in Phase 1 with complete system prompt |
| `agents/director-mapper.md` | Markdown + YAML frontmatter | Analyzes existing codebases | Already defined in Phase 1 with complete system prompt |
| `skills/onboard/templates/vision-template.md` | Markdown | Template structure for VISION.md | Already defined in Phase 1 |
| `scripts/init-director.sh` | Bash | Creates `.director/` folder structure | Already defined in Phase 1 |

### Supporting

| Component | Format | Purpose | When to Use |
|-----------|--------|---------|-------------|
| `reference/terminology.md` | Markdown | Director vocabulary rules | Always -- every user-facing message |
| `reference/plain-language-guide.md` | Markdown | Communication tone rules | Always -- every user-facing message |
| `reference/context-management.md` | Markdown | XML boundary tag standards | When assembling context for sub-agents |

### What NOT to Change

| Component | Why Not |
|-----------|---------|
| `agents/director-interviewer.md` | Already complete with all 9 rules, 8 sections, brownfield mode, output rules. Do not modify unless a bug is found during testing. |
| `agents/director-mapper.md` | Already complete with 5-step process, output format, large project handling. Do not modify. |
| `scripts/init-director.sh` | Already handles `.director/` creation, git init. No changes needed for Phase 2. |
| Other skills (build, blueprint, etc.) | Out of scope. Their routing stubs from Phase 1 remain unchanged. |

## Architecture Patterns

### Pattern 1: Inline Skill Orchestration (Not Forked)

**What:** The onboard skill runs inline in the main conversation (no `context: fork`). Claude follows the SKILL.md instructions step by step within the user's conversation, allowing back-and-forth with the user.

**When to use:** When the skill requires multi-turn conversation with the user (interview) AND file writing after completion.

**Why not `context: fork`:** A forked skill runs in isolation without access to conversation history. The onboard workflow needs to: (1) talk to the user directly during the interview, (2) write files after the interview. Forking would isolate the interview from the main conversation. The interviewer agent could be spawned as a foreground sub-agent instead, but the simpler approach is having the skill instructions guide Claude through the interview directly, referencing the interviewer agent's rules.

**Critical design decision:** There are two viable approaches to running the interview:

**Approach A: Direct Interview (Recommended)**
The SKILL.md contains the full interview instructions inline (or references the interviewer agent's rules). Claude conducts the interview directly in the main conversation. After the interview, Claude writes VISION.md. This is simpler, avoids sub-agent overhead, and keeps the conversation natural.

**Approach B: Sub-Agent Interview**
The SKILL.md spawns the interviewer as a foreground sub-agent via the Task tool. The sub-agent conducts the interview, returns the vision content, and the SKILL.md writes it. This is more architecturally clean (separation of concerns) but adds complexity: the sub-agent conversation feels different to the user (different context, possibly different model), and passing the interview output back requires careful handling.

**Recommendation: Use Approach A (direct interview).** The interviewer agent's system prompt is excellent -- load it as reference content in the skill. Claude follows those interview rules directly. This gives the most natural conversation experience and simplest file writing path. Reserve the Task tool for the mapper agent, where isolation genuinely helps (parallel codebase scanning).

However, if sub-agent spawning is preferred for architectural consistency across all Director workflows, Approach B works -- but the interviewer must be spawned in the foreground so it can interact with the user.

### Pattern 2: Brownfield Detection and Mapper Spawning

**What:** When onboarding an existing project, detect codebase files beyond `.director/` and spawn the mapper agent to analyze the project before (or in parallel with) the interview.

**When to use:** When `.director/VISION.md` is empty/template AND the project has existing source files.

**Detection logic:**
```
1. Does .director/ exist? If not, create it (init script).
2. Does VISION.md have real content? If yes -> already onboarded path.
3. Are there source files beyond .director/? If yes -> brownfield.
4. Otherwise -> greenfield.
```

**Brownfield source file detection heuristics:**
- Check for package.json, requirements.txt, go.mod, Cargo.toml, Gemfile (language indicators)
- Check for src/, app/, lib/, pages/ directories (source directories)
- Check for any files at project root beyond .director/, .git/, .gitignore, README.md
- If any of these exist, treat as brownfield

**Mapper spawning:** Use the Task tool to spawn `director-mapper` as a sub-agent (can run in background). Pass instructions via the task delegation message:

```
<instructions>
Map this codebase. Focus on: structure, tech stack, architecture, capabilities, and health.
Report findings using your standard output format.
</instructions>
```

The mapper returns its findings. The SKILL.md then uses these findings to inform the interview (brownfield mode -- acknowledge what exists, ask about changes, skip redundant questions).

### Pattern 3: VISION.md Content Quality Detection

**What:** Distinguish between an empty VISION.md template and one with real content. Phase 1 established this pattern in the existing onboard SKILL.md.

**When to use:** At the start of every onboard invocation.

**Detection approach (from Phase 1 decisions):**
- Read `.director/VISION.md`
- Check if content matches the init script template (placeholder headings with no content)
- Look for italic placeholder text like `_What are you calling this project?_` or `_This file will be populated_`
- If the content is just headings + placeholder text -> not onboarded
- If there is substantive content under headings -> already onboarded

**Note:** There are TWO vision templates to be aware of:
1. The init script's VISION.md (`scripts/init-director.sh`) -- has headings like "What are we building?", "Who is it for?"
2. The onboard skill's template (`skills/onboard/templates/vision-template.md`) -- has headings like "Project Name", "What It Does", "Who It's For", "Key Features"

These should be reconciled. The onboard skill should produce a VISION.md using its own template structure, which is more detailed and better aligned with the interview sections.

### Pattern 4: XML Context Assembly for Sub-Agents

**What:** When spawning sub-agents, wrap context in XML boundary tags as defined in `reference/context-management.md`.

**When to use:** Any Task tool invocation that passes project context.

**For the interviewer (if using Approach B):**
```xml
<vision>
[Current VISION.md content, even if empty template]
</vision>

<instructions>
Conduct the onboarding interview. [Any brownfield findings go here if mapper ran first.]
The user said: [any $ARGUMENTS the user passed to /director:onboard]
</instructions>
```

**For the mapper:**
```xml
<instructions>
Map this codebase. Provide a complete picture of what exists.
Focus on structure, tech stack, architecture, capabilities, and health.
</instructions>
```

Per the context-management.md agent profiles:
- Interviewer receives: `<vision>` and `<instructions>` (no gameplan, no step, no task)
- Mapper receives: `<instructions>` and optionally `<vision>` (primarily instructions only)

### Pattern 5: Post-Interview VISION.md Generation

**What:** After the interview completes, generate VISION.md from the interview output and write it to `.director/VISION.md`.

**When to use:** End of every successful onboard interview.

**Process:**
1. Interview completes -- Claude has gathered all answers
2. Generate VISION.md content following the template structure:
   - Project Name
   - What It Does
   - Who It's For
   - Key Features (organized by priority: must-have vs nice-to-have)
   - Tech Stack
   - Success Looks Like
   - Decisions Made (table format)
   - Open Questions (with [UNCLEAR] markers)
3. Present the vision to the user for confirmation ("Here's what I captured. Does this look right?")
4. User reviews and suggests changes
5. Once confirmed, write to `.director/VISION.md`
6. Report success conversationally

**File writing:** Claude writes VISION.md directly using the Write tool. No sub-agent needed for this step. The interviewer agent has `disallowedTools: Write, Edit` -- this is intentional. The orchestrating skill (Claude following SKILL.md) handles all file I/O.

### Pattern 6: Already-Onboarded Re-Entry

**What:** When a user runs `/director:onboard` on a project that already has a completed VISION.md, offer to update or map.

**When to use:** When VISION.md has real content (not just template).

**Behavior:**
1. Acknowledge the existing vision
2. Offer two paths:
   - "Update your vision" -> re-run interview with existing answers pre-loaded
   - "Map your code" -> run mapper to check if codebase matches vision
3. Wait for user choice before proceeding

This is already partially implemented in the Phase 1 SKILL.md. Phase 2 makes both paths functional.

### Anti-Patterns to Avoid

- **Forking the onboard skill:** Do not add `context: fork` to the onboard SKILL.md. The onboard workflow requires direct conversation with the user. Forking isolates the conversation.
- **Spawning interviewer in background:** The interview is an interactive conversation. It must run in the foreground where the user can respond. Only the mapper can run in background.
- **Writing VISION.md inside a sub-agent:** The interviewer and mapper have `disallowedTools: Write, Edit`. File writing must happen in the main skill execution context.
- **Asking all questions at once:** The interviewer rules say "ONE question at a time." Never batch questions. This is the most important UX rule.
- **Ignoring $ARGUMENTS:** If the user passed text to `/director:onboard "my task app"`, incorporate it into the interview flow. Don't restart from scratch.
- **Overwriting VISION.md without confirmation:** Always present the generated vision for review before writing. The user must confirm.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Interview conversation flow | Custom state machine or conversation tree | Agent system prompt with rules + Claude's conversation ability | Claude naturally follows interview rules. No state tracking needed -- Claude remembers the conversation. |
| Codebase analysis | Custom file-scanning logic in the skill | `director-mapper` agent via Task tool | Already built in Phase 1 with comprehensive mapping process. Mapper runs on Haiku (cost-efficient). |
| Project type detection (new vs existing) | Complex heuristic system | Simple file presence checks (package.json, src/, etc.) | A few file existence checks are sufficient. Don't over-engineer detection. |
| VISION.md template rendering | Template engine or string replacement | Claude generates the content directly following template structure | Claude is the template engine. Show it the structure, it fills it in. |
| [UNCLEAR] marker management | Tracking system for unclear items | Inline text markers in the vision document | Simple text markers that are visible in the Markdown. No separate tracking needed. |
| Tech stack suggestion | Curated database of tech stacks | Claude's knowledge of frameworks + interviewer rules | Claude knows what tech stacks work for what project types. The interviewer agent's rules guide when to suggest. |

**Key insight:** The onboarding workflow is a conversation, not a program. Claude follows interview rules naturally. The SKILL.md provides structure; Claude provides the conversational intelligence. Do not try to programmatically control the interview flow.

## Common Pitfalls

### Pitfall 1: Vision Template Mismatch Between Init Script and Onboard

**What goes wrong:** The init script (`scripts/init-director.sh`) creates a VISION.md with one set of headings ("What are we building?", "Who is it for?", "What problem does it solve?", "What does success look like?", "Technical preferences", "Constraints"). The onboard template (`skills/onboard/templates/vision-template.md`) has different headings ("Project Name", "What It Does", "Who It's For", "Key Features", "Tech Stack", "Success Looks Like", "Decisions Made", "Open Questions"). The interview generates content matching the onboard template, but the detection logic checks for the init script template.
**Why it happens:** Two templates were created independently in Phase 1.
**How to avoid:** The onboard skill should use the onboard template (`skills/onboard/templates/vision-template.md`) as the canonical structure for VISION.md output. Detection logic should check for EITHER template's placeholder text when determining if the project is not yet onboarded. When the interview writes VISION.md, it overwrites the init template with the onboard template structure.
**Warning signs:** Users who ran init but not onboard see different headings than users who completed onboarding.

### Pitfall 2: Interview Not Adapting to User's Preparation Level

**What goes wrong:** The interview asks basic questions to a user who already has detailed plans, or asks advanced questions to a user who is still exploring.
**Why it happens:** The interviewer rules say to "gauge preparation level early" but don't provide concrete signals.
**How to avoid:** The first 1-2 questions serve as gauges. If the user gives a detailed, specific answer ("I'm building a SaaS habit tracker with Next.js, Supabase, and Clerk auth, deploying on Vercel"), skip basics and jump to gaps. If the user gives a vague answer ("I want to build an app"), take it slow with more guidance and multiple-choice options. The skill instructions should explicitly include this adaptation logic.
**Warning signs:** User seems impatient (detailed answers getting basic follow-ups) or overwhelmed (vague answers getting technical questions).

### Pitfall 3: Brownfield Mapper Output Not Integrated into Interview

**What goes wrong:** The mapper runs and produces findings, but the interview proceeds as if starting from scratch, ignoring what the mapper found.
**Why it happens:** Mapper results need to be explicitly threaded into the interview context. If using Approach A (direct interview), the mapper findings need to be available when the interview starts.
**How to avoid:** For brownfield projects, run the mapper FIRST, then use its output to inform the interview. The SKILL.md should: (1) detect brownfield, (2) spawn mapper, (3) wait for mapper results, (4) present findings to user, (5) conduct interview in brownfield mode (acknowledging what exists, asking about changes, using delta format). The mapper output becomes part of the interview context.
**Warning signs:** The interview re-asks questions that the mapper already answered (tech stack, architecture, etc.).

### Pitfall 4: $ARGUMENTS Ignored or Lost

**What goes wrong:** User runs `/director:onboard "a social media app for pets"` but the interview starts from scratch with "What are you building?"
**Why it happens:** The `$ARGUMENTS` placeholder is in the SKILL.md but the interview logic doesn't thread it into the first question.
**How to avoid:** If `$ARGUMENTS` is non-empty, treat it as the answer to the first interview question ("What are you building?"). Confirm understanding, then proceed to the next question. The SKILL.md should have explicit instructions: "If the user provided arguments, treat them as initial context about their project. Start by confirming what you understood, then continue the interview from there."
**Warning signs:** User provides context upfront but is asked the same thing again.

### Pitfall 5: Interview Runs Too Long

**What goes wrong:** The interview takes 20+ turns, exhausting the user. Vibe coders want to start building quickly.
**Why it happens:** The interviewer has 8 sections and potentially many surface-level questions. Not all are relevant to every project.
**How to avoid:** The interview should be adaptive in length too. Target 8-15 questions for a typical new project. Skip entire sections that aren't relevant (don't ask about deployment for a personal CLI tool). Use the "read the room" rule -- if the user seems ready, wrap up early. The skill should instruct Claude to aim for 10-15 minutes maximum.
**Warning signs:** User starts giving shorter, more impatient answers. User says "I just want to start building."

### Pitfall 6: Conversational Tone Breaks During File Operations

**What goes wrong:** After a natural, conversational interview, Claude suddenly switches to technical language when writing files: "Writing VISION.md to .director/VISION.md..."
**Why it happens:** Default Claude behavior is to narrate file operations.
**How to avoid:** The SKILL.md should explicitly instruct Claude to keep the tone conversational even during file operations. Instead of "Writing VISION.md...", say "I've saved your vision document. You can always check it at `.director/VISION.md` if you want to review or edit it later." Never mention file paths as the primary communication -- lead with what it means, not what happened technically.
**Warning signs:** Messages about file paths, tool operations, or technical processes during what should feel like a conversation.

## Code Examples

### Example 1: Onboard SKILL.md Orchestration Structure

```yaml
# Source: Based on Claude Code skills docs and Phase 1 patterns
---
name: onboard
description: "Set up a new project or map an existing one. Creates your vision document through a guided interview."
disable-model-invocation: true
---

# Director Onboard

First, check if `.director/` exists. If not, run init silently:
!`bash "${CLAUDE_PLUGIN_ROOT}/scripts/init-director.sh" 2>/dev/null`

Say only: "Director is ready." Then continue below.

## Determine Project State

Read `.director/VISION.md` and determine if it has real content...

[Detection logic that checks for template placeholders]

## Greenfield: New Project Interview

[Interview instructions referencing interviewer agent rules]

Follow these interview rules:
1. ONE question at a time
2. Multiple choice when possible
3. Gauge preparation level early
...

Work through these sections:
1. What are you building?
2. Who is it for?
...

## Brownfield: Existing Project

[Mapper spawning via Task tool, then brownfield interview]

## After Interview: Generate Vision

[Instructions to produce VISION.md and present for confirmation]
```

### Example 2: Brownfield Detection Logic

```markdown
## Detect Project Type

After reading VISION.md, determine if this is a new or existing project:

Check for existing source files by looking at the project root. Signs of an existing project:
- `package.json`, `requirements.txt`, `go.mod`, `Cargo.toml`, or `Gemfile` exists
- `src/`, `app/`, `lib/`, or `pages/` directory exists
- More than 5 files at the project root beyond `.director/`, `.git/`, and config files

If existing source files are found, this is an **existing project**. Say something like:
> "I see you already have code here. Let me take a look at what you've built so far."

Then spawn the mapper agent to analyze the codebase before starting the interview.
```

### Example 3: Mapper Spawning via Task Tool

```markdown
## Map Existing Codebase

Use the Task tool to spawn the director-mapper agent:

<instructions>
Map this codebase completely. Report:
- What you found (1-2 sentence summary)
- Built with (tech stack in plain language)
- What it can do (feature inventory as user capabilities)
- How it's organized (project structure overview)
- Things worth noting (observations about codebase health)
</instructions>

Wait for the mapper to complete. Then present the findings to the user:

> "Here's what I see in your project:"
> [mapper findings in plain language]
>
> "Does this look right? Anything I missed or got wrong?"

Then proceed with the brownfield interview (asking about changes, not about basics).
```

### Example 4: Vision Generation and Confirmation

```markdown
## Generate Vision Document

After the interview is complete, produce a VISION.md following this structure:

# Vision

## Project Name
[Name from interview]

## What It Does
[1-2 sentence summary]

## Who It's For
[Target users]

## Key Features
### Must-Have
- [Feature 1]
- [Feature 2]

### Nice-to-Have
- [Feature 3]

## Tech Stack
[Languages, frameworks, databases, hosting]

## Success Looks Like
[Success criteria from interview]

## Decisions Made
| Decision | Why |
|----------|-----|
| [Decision] | [Reason] |

## Open Questions
- [UNCLEAR] [Question still unresolved]

---

Present this to the user for review:

> "Here's what I captured from our conversation. Take a look and let me know if anything needs changing."

Show the complete vision document. Wait for the user to confirm or request changes. Make any requested changes, then confirm again.

Once the user approves, write the content to `.director/VISION.md`.

Say something like:
> "Your vision is saved. You can always edit it directly at `.director/VISION.md` or run `/director:onboard` again to update it. Ready to create a gameplan? You can do that with `/director:blueprint`."
```

### Example 5: [UNCLEAR] Marker Handling

```markdown
## Handling Ambiguity

During the interview, if the user gives an ambiguous or contradictory answer:

1. Don't assume -- mark it with [UNCLEAR]
2. Ask a follow-up to clarify

Example:
> User: "I want it to work on mobile and desktop"
> You: "Got it -- both mobile and desktop. When you say mobile, do you mean:
>   A) A mobile-friendly website (responsive design)
>   B) A native mobile app (downloaded from app store)
>   C) Both -- a website and a separate app
> This helps me plan the right tech stack."

If the user can't decide yet, record it as [UNCLEAR]:
> "No problem -- I'll mark that as something to figure out later."

In the Vision document, this appears as:
> - [UNCLEAR] Mobile strategy -- responsive web vs native app vs both
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Placeholder onboard skill with manual template | Functional interview-based onboarding | Phase 2 (this phase) | Users go from zero to completed VISION.md through conversation |
| Single VISION.md template structure | Two templates need reconciliation | Discovered in Phase 2 research | Init script template differs from onboard template. Must align. |
| No codebase analysis for existing projects | Mapper agent scans codebase in brownfield mode | Phase 1 defined agent, Phase 2 connects it | Existing projects get analyzed before interview |

## Open Questions

1. **Direct Interview vs Sub-Agent Interview**
   - What we know: Both approaches work. Direct interview (Approach A) is simpler and more natural. Sub-agent interview (Approach B) is more architecturally clean.
   - What's unclear: The PRD workflow says `/director:onboard` -> interviewer -> mapper -> planner -> presents gameplan. This implies the interviewer IS a sub-agent. But the interviewer's `maxTurns: 40` suggests it's designed for extended conversation, and Claude cannot spawn sub-agents that have multi-turn user interaction in the typical Task tool pattern.
   - Recommendation: Use the direct interview approach (Approach A). The skill loads the interviewer's rules as reference content and Claude follows them directly. The interviewer agent definition serves as the "specification" for interview behavior even if not spawned as a literal sub-agent. This is the pragmatic choice. The mapper IS spawned as a sub-agent since it runs independently without user interaction.

2. **Vision Template Reconciliation**
   - What we know: The init script creates VISION.md with one heading structure. The onboard template has a different, more detailed structure. Both exist.
   - What's unclear: Should the init script's template be updated to match the onboard template? Or should the onboard skill simply overwrite whatever the init created?
   - Recommendation: Keep the init script's simple template as-is (it's a "this will be populated" placeholder). When onboarding completes, overwrite with the full onboard template structure. The detection logic should handle both templates' placeholder text.

3. **Mapper Timing in Brownfield Flow**
   - What we know: The mapper should run before the interview for brownfield projects so findings inform the interview.
   - What's unclear: Should the mapper run in the background while the user answers the first question? Or should it run first, then present findings, then interview?
   - Recommendation: Run mapper first, present findings to user, then start brownfield interview. The mapper is fast (Haiku model, ~30 turns max) and the user benefits from seeing findings before answering questions. Background execution adds complexity for marginal time savings.

4. **How Deep Should the Interview Go for MVP?**
   - What we know: The interviewer has 8 sections. Not all are relevant to every project.
   - What's unclear: Should the MVP interview cover all 8 sections, or should some be deferred?
   - Recommendation: Include all 8 sections in the skill instructions but make them adaptive. The "read the room" rule handles this -- Claude skips sections that aren't relevant. The skill should emphasize that a typical interview is 8-12 questions, not 30.

5. **Gameplan Creation After Onboarding**
   - What we know: The PRD workflow says onboard -> interviewer -> mapper -> planner -> presents gameplan. This implies onboarding also creates a gameplan.
   - What's unclear: Should Phase 2 include automatic gameplan creation, or should it end with VISION.md and suggest `/director:blueprint` as the next step?
   - Recommendation: Phase 2 should end with VISION.md and suggest `/director:blueprint`. The planner agent and blueprint skill are Phase 3+ work. Including gameplan generation in Phase 2 would expand scope significantly. The PRD workflow describes the eventual end-state, not what Phase 2 must deliver.

## Sources

### Primary (HIGH confidence)
- [Claude Code Skills Documentation](https://code.claude.com/docs/en/skills) -- Skill frontmatter, `$ARGUMENTS`, dynamic context injection, `context: fork`, `agent` field, supporting files. Fetched 2026-02-07.
- [Claude Code Sub-agents Documentation](https://code.claude.com/docs/en/sub-agents) -- Task tool delegation, foreground/background execution, built-in agents, agent frontmatter fields, persistent memory, permission modes. Fetched 2026-02-07.
- Phase 1 RESEARCH.md (`.planning/phases/01-plugin-foundation/01-RESEARCH.md`) -- Plugin architecture patterns, anti-patterns, directory structure verified.
- Existing codebase files (all read directly): `skills/onboard/SKILL.md`, `agents/director-interviewer.md`, `agents/director-mapper.md`, `agents/director-researcher.md`, `skills/onboard/templates/vision-template.md`, `skills/onboard/templates/config-defaults.json`, `scripts/init-director.sh`, `scripts/session-start.sh`, `reference/context-management.md`, `reference/terminology.md`, `reference/plain-language-guide.md`, `reference/verification-patterns.md`, `hooks/hooks.json`, `.claude-plugin/plugin.json`.
- PRD (`docs/design/PRD.md`) -- Requirements ONBR-01 through ONBR-11, workflow definitions, agent roster, context management strategy.

### Secondary (MEDIUM confidence)
- Claude Code release notes and community articles on skill/sub-agent patterns -- Corroborated with official docs.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH -- All components exist from Phase 1. No new libraries or tools needed.
- Architecture patterns: HIGH -- Based on official Claude Code docs (skills, sub-agents) and Phase 1 established patterns. Direct interview approach verified against skill system capabilities.
- Pitfalls: HIGH -- Derived from reading the actual codebase (template mismatch is a real issue found during research). Interview adaptation pitfalls from PRD interview rules.
- Code examples: HIGH -- Based on existing SKILL.md patterns from Phase 1, official docs patterns, and the interviewer agent's actual system prompt.

**Research date:** 2026-02-07
**Valid until:** 2026-03-07 (30 days -- Claude Code plugin system stable, existing agent definitions unlikely to change)
