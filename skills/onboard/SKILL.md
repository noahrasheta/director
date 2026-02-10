---
name: director:onboard
description: "Set up a new project or map an existing one. Creates your vision document through a guided interview."
---

# Director Onboard

First, check if `.director/` exists. If it does not, run the init script silently:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/init-director.sh"
```

Say only: "Director is ready." Then continue with the steps below.

---

## Determine Project State

Read `.director/VISION.md` and determine the project state.

The init script creates a VISION.md with placeholder text like:

- `> This file will be populated when you run /director:onboard`
- Headings like `## What are we building?` with no content beneath them

The onboard template uses a different format with placeholder text like:

- `_What are you calling this project?_`
- `_One or two sentences about what this project does, in plain language._`

**Detection rule:** If VISION.md contains either type of placeholder text -- or if headings have no substantive content beneath them (just blank lines, italic prompts, or template markers) -- the project has NOT been onboarded yet. Proceed to Detect Project Type.

**If VISION.md has real content** (substantive text under headings -- actual project descriptions, feature lists, tech choices, not just placeholders):

The user has already onboarded. Check whether there are existing codebase files beyond `.director/` by looking at the project root. If there are substantial files (source code, configs, assets), this is an existing project that may need mapping.

Say something like:

> "You already have a vision document. Want to update it, or would you like me to look through your existing code to make sure everything is captured?"

Wait for the user's response before proceeding.

**If they want to update their vision:**

Go to the Greenfield Interview section with their existing vision as context. Follow interviewer rule 7: adapt to what's already known -- skip questions that are already answered in the existing vision and focus on gaps, changes, and new information. This is an update conversation, not a redo.

**If they want to map their code:**

Run the deep mapping pipeline (see the Mapper Spawning section below for the exact process) to produce a comprehensive codebase analysis. Once the mapping is complete and findings are presented, ask the user if anything in the findings changes what they want to build or suggests updates to their vision. If yes, walk them through updating the relevant parts of their vision document. If the vision looks accurate, confirm and move on.

---

## Detect Project Type

After confirming the project is not yet onboarded, determine if this is a new project or an existing one.

Check for existing source files beyond `.director/` by looking at the project root. Signs of an existing project:

- `package.json`, `requirements.txt`, `go.mod`, `Cargo.toml`, or `Gemfile` exists
- `src/`, `app/`, `lib/`, or `pages/` directory exists

If any of these exist, this is an **existing project** (brownfield). Say something like:

> "I see you already have code here. Let me take a look at what you've built so far."

Then proceed to the Brownfield section below.

If none of these exist, this is a **new project** (greenfield). Say something like:

> "Let's figure out what you're building. I'll ask you some questions one at a time -- just answer naturally, and I'll put together a vision document from our conversation."

Then proceed to Handle Initial Context from Arguments.

---

## Handle Initial Context from Arguments

Check if the user provided arguments via `$ARGUMENTS`.

**If arguments were provided** (the text after `/director:onboard` is not empty):

Treat the arguments as initial context about their project. The user has already told you something about what they want to build. Confirm your understanding of what they described, then continue the interview from there -- skip the "What are you building?" question since they already answered it.

For example, if they said `/director:onboard "a task management app for teams"`, you might respond:

> "A task management app for teams -- got it. Let me ask a few more questions so I can capture the full picture."

Then proceed to the interview starting from section 2 (Who is it for?).

**If no arguments were provided:**

Start the interview from the beginning with section 1 (What are you building?).

---

## Greenfield Interview

Conduct the interview directly in this conversation. Follow these rules carefully:

### Interview Rules

1. **Ask ONE question at a time.** Never dump multiple questions in a single message. Let the user answer, confirm you understood, then move on.

2. **Use multiple choice when possible.** Provide A, B, C options to make decisions easy. The user can always type a custom answer instead of picking an option.

3. **Gauge preparation level early.** The user's first 1-2 answers tell you how to pace the rest of the interview:
   - **Detailed, specific answer** (e.g., "I'm building a SaaS habit tracker with Next.js, Supabase, and Clerk auth, deploying on Vercel") -- this user has done their homework. Move faster, skip basics, jump to gaps and decisions they may not have considered.
   - **Vague answer** (e.g., "I want to build an app" or "Something with AI") -- this user is still exploring. Slow down, offer more guidance, provide more multiple-choice options, and explain the implications of each choice.

4. **Surface decisions the user hasn't considered.** Proactively ask about things they may not have thought of yet:
   - How users will log in (authentication)
   - Where data will be stored (database)
   - What tech stack fits their needs and why
   - Whether they need real-time features (live updates, chat, notifications)
   - File uploads or media handling
   - Payments or billing
   - Third-party services (email, analytics, maps, etc.)
   - Where the project will be hosted
   Only bring up topics that are relevant to THIS project. Don't ask about payments for a personal CLI tool or load balancing for a blog.

5. **Confirm understanding before moving on.** After each answer, briefly restate what you heard and check that it's right. Keep confirmations short -- a sentence, not a paragraph.

6. **Flag ambiguity with [UNCLEAR] markers.** If an answer is vague or contradictory, don't assume -- mark it and ask a follow-up to clarify. For example:
   > "When you say 'mobile,' do you mean:
   >   A) A mobile-friendly website (responsive design)
   >   B) A native mobile app (downloaded from an app store)
   >   C) Both -- a website and a separate app
   > This helps me suggest the right tech approach."
   If the user can't decide yet, that's fine -- record it as an open question with an [UNCLEAR] marker.

7. **Adapt to what's already known.** If the user provided arguments, or if you're updating an existing vision, skip questions that are already answered. Focus on gaps and new information.

8. **Don't ask about things that don't matter yet.** If the user is building a simple personal tool, don't ask about multi-region hosting or team permissions. Match the complexity of your questions to the complexity of their project.

9. **Read the room.** If the user seems impatient or gives short answers, pick up the pace -- combine related topics, skip less important sections, and wrap up sooner. If they seem unsure or are enjoying the conversation, take more time and offer more context for each decision.

### Interview Sections

Work through these areas in order. Skip sections that aren't relevant to this project, and adapt based on the user's preparation level. A typical interview is 8-15 questions.

**1. What are you building?**
Get a 1-2 sentence summary of the project. This becomes the elevator pitch. Ask something like: "What do you want to build? Just a sentence or two about the idea."

**2. Who is it for?**
Identify the target users. Is it for the builder themselves, a team, customers, the public? This shapes almost every decision that follows.

**3. Key features**
Start by asking for the top 3 most important things the project should do. Then ask if there are more. Group features naturally -- must-haves vs nice-to-haves. Don't force a rigid structure; let the user describe it their way.

**4. Tech stack**
Based on the features described, suggest a tech stack that fits. Explain WHY each choice makes sense for THIS project, not just what's popular. Let the user override any suggestion -- if they have preferences ("I want to use Next.js"), respect those. If the user has no preference, make a clear recommendation and explain the reasoning.

**5. Where will it live?**
Ask about hosting. Offer simple options: Vercel, Netlify, Railway, or "I'll figure that out later." This is about understanding the user's comfort level, not making a final decision.

**6. What does "done" look like?**
Help the user define success criteria. What would make them say "v1 is complete"? These become the goals later. Push for specifics -- "users can sign up and track their habits" is better than "it works."

**7. Decisions already made**
Ask if they've already committed to any choices -- tech stack, design style, specific libraries, hosting provider, color scheme, anything. Don't redo decisions they've already made. Record these as-is.

**8. Anything you're unsure about?**
Give the user space to voice concerns, unknowns, or areas where they want guidance. These become open questions in the vision. Mark unresolved items with [UNCLEAR].

### Interview Wrap-Up

When you've covered all relevant sections (or the user signals they're ready to move on), let them know you have what you need:

> "I think I have a good picture. Let me put together your vision document."

Then proceed to Generate Vision Document.

---

## Brownfield

This section handles projects that already have code. The flow is: map the codebase with multiple focused agents, synthesize the findings, present a summary to the user, then run an adapted interview focused on what the user wants to change.

### Greenfield Detection

Before mapping, verify this is actually a brownfield project. If the project has no meaningful source files -- only `.director/` and maybe a README -- skip the entire mapping pipeline and redirect to the Greenfield Interview section. Say something like:

> "I don't see much code here yet. Let's start fresh -- I'll ask you some questions about what you want to build."

Then proceed directly to Handle Initial Context from Arguments and the Greenfield Interview. Do NOT create `.director/codebase/` or spawn any mapper agents for greenfield projects.

### Codebase Size Assessment

Before spawning mappers, do a quick size check:

```bash
# Count source files (excluding common non-source directories)
find . -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" -o -name "*.py" -o -name "*.rb" -o -name "*.go" -o -name "*.rs" -o -name "*.java" -o -name "*.swift" -o -name "*.vue" -o -name "*.svelte" \) -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/.director/*" -not -path "*/vendor/*" -not -path "*/dist/*" -not -path "*/build/*" | wc -l
```

If the codebase has more than 500 source files, add a sampling note to each mapper's instructions: "This is a large codebase. Focus on the main source directories first. Sample representative files rather than reading everything. Note what you skipped."

### Model Profile Resolution

Read `.director/config.json` and resolve the model for each agent:

1. Read the `model_profile` field (defaults to "balanced")
2. Look up the profile in `model_profiles` to get base model assignments for `deep-mapper` and `synthesizer`
3. For the `quality` profile, override the arch and concerns mappers to use the most capable model available (since these are the highest-complexity analyses)

The resolution produces a model assignment for each mapper and the synthesizer. If config.json is missing the `model_profile` or `model_profiles` fields, fall back to "balanced" defaults (deep-mapper gets haiku, synthesizer gets sonnet).

### Mapper Spawning

Ensure `.director/codebase/` directory exists before spawning mappers. Create it if it doesn't exist:

```bash
mkdir -p .director/codebase
```

Tell the user you're mapping their codebase. Show a single message:

> "Mapping your codebase..."

Then spawn 4 director-deep-mapper agents IN PARALLEL using 4 simultaneous Task tool calls. Each agent gets different instructions specifying its focus area. The instructions are wrapped in XML boundary tags. All 4 Task tool calls go in a SINGLE message so they run in parallel. Do NOT wait for one mapper to finish before spawning the next.

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

If any mapper fails or times out, note the failure but continue with whatever mappers succeeded. The synthesizer can work with partial input. If ALL mappers fail, fall back to the v1.0 director-mapper agent for a basic overview instead.

### Synthesizer Spawning

After ALL 4 mappers have completed (or failed), spawn the director-synthesizer agent. This runs SEQUENTIALLY after the mappers (not in parallel with them).

```
<instructions>
Mode: codebase

Read all codebase analysis files from .director/codebase/ (STACK.md, INTEGRATIONS.md, ARCHITECTURE.md, STRUCTURE.md, CONVENTIONS.md, TESTING.md, CONCERNS.md). Synthesize them into a unified summary.

Write your output to .director/codebase/SUMMARY.md using the template at skills/onboard/templates/codebase/SUMMARY.md.

Cross-reference findings across all files. If different mappers found related information about the same files or patterns, connect them. Resolve any contradictions.

Return only a brief confirmation when done. Do NOT return document contents.
</instructions>
```

### Summary Presentation

After the synthesizer completes, read `.director/codebase/SUMMARY.md` yourself (the main session agent). Format a structured ~20-30 line user-facing overview from the SUMMARY.md content.

The overview should be organized into sections with 2-3 bullets each, roughly following this structure:

> "Here's what I found in your project:"
>
> **What this project is**
> [1-2 sentence plain-language summary from SUMMARY.md "What This Project Is" section]
>
> **Built with**
> - [Main language/framework]
> - [Database/storage]
> - [Key libraries or services]
>
> **What it can do**
> - [User capability 1]
> - [User capability 2]
> - [User capability 3]
>
> **How it's organized**
> - [Brief structure description -- "The code is split into X main areas: ..."]
>
> **Things worth noting**
> - [Top concern or observation]
> - [Another notable finding]
> - [Testing status if relevant]

Keep references HIGH-LEVEL. Say "Looks like a React project with a database" not "I found 3 API routes in /src/api/v2." Present findings as collaborative observations, not judgments.

This is a SUMMARY ONLY interaction. Do NOT offer drill-down or ask if they want more detail. The detailed files exist in `.director/codebase/` for agents only.

After presenting the overview, ask the user to confirm or correct:

> "Does this look right? Anything I missed or got wrong?"

Wait for the user to respond. Incorporate corrections into your understanding before moving on to the interview.

### Research Opt-in (Brownfield)

After the user confirms the mapping summary, offer domain research.

You already have the codebase SUMMARY.md in memory from the Summary Presentation step. This provides the project context that researchers need (what the project is, what technologies it uses, its architecture).

Proceed to the Research Pipeline section below. When the pipeline asks for project context, use the codebase SUMMARY.md contents (NOT VISION.md, which does not exist yet for brownfield projects).

After the research pipeline completes (or is declined), proceed to the Brownfield Interview.

### Brownfield Interview

After the user confirms the mapping summary, conduct an interview that builds on what the mapping discovered. You already know a lot about this project from the mapping -- use that knowledge. The interview should feel like talking to someone who's been looking through the project, not someone asking basic questions from a script.

This follows the same core rules as the greenfield interview (one question at a time, multiple choice when possible, confirm understanding, flag ambiguity with [UNCLEAR]), but the content is fundamentally different because the mapping gives you a head start.

### Using Mapping Context

1. **You already have the SUMMARY.md in memory** from reading it in the Summary Presentation step. Use its contents to inform every question. You do NOT need to read the individual codebase files -- the summary has everything you need for interview purposes.

2. **If research was completed, you also have research findings in memory** from the Research Pipeline. Use research findings to enhance your questions:
   - If research recommended specific technologies or approaches, ask confirmation questions about whether the user wants to adopt them
   - If research flagged expected features the user has not built, ask gap-filling questions about those features
   - If research identified pitfalls relevant to the user's plans, weave awareness of them into your questions
   - Research context ADDS to mapping context -- it does not replace it. Use both.

3. **Three question types to use:**

   **Confirmation questions** -- Validate something the mapping detected. These are quick yes/no checks that build trust and catch misdetections.
   - "I see you're using [detected tech] -- keeping that, or thinking of switching?"
   - "Looks like [feature] is already working -- is that right?"
   - "The project seems to be for [detected audience] -- is that who you have in mind?"

   **Gap-filling questions** -- Probe things the mapping did NOT find or flagged as concerns. These surface intentional gaps vs. forgotten pieces.
   - "I didn't find any tests -- is that intentional, or something you want to add?"
   - "There's no authentication set up -- will users need to log in?"
   - "I noticed [concern in plain language] -- is that something you want to address?"

   **Forward-looking questions** -- Ask about the user's plans for the project, which the mapping can't detect.
   - "What do you want to change or add next?"
   - "What would make this round of work feel complete?"
   - "Are there any decisions you've already made about the changes?"

4. **Auto-skip rules.** Do NOT ask questions the mapping already definitively answered:
   - Do NOT ask "What are you building?" -- the mapping summary already describes the project
   - Do NOT ask "What tech stack are you using?" -- the mapping detected it (ask a confirmation question instead if you want to verify)
   - Do NOT ask about project architecture -- the mapping analyzed it
   - Do NOT ask about existing features -- the mapping inventoried them
   - Do NOT ask "Who is it for?" IF the answer is obvious from the codebase (user auth patterns, public-facing UI, etc.)

5. **High-level references only.** When referencing mapping discoveries in questions, use plain language:
   - GOOD: "I see you're using React with a database"
   - BAD: "I found React 18.2.0 in package.json and Prisma ORM connecting to PostgreSQL via `src/lib/db.ts`"
   - GOOD: "There are some areas of the code that look like they could use attention"
   - BAD: "CONCERNS.md lists 4 high-priority items in `src/services/auth.ts`"

### Brownfield Interview Sections

**1. Confirm the picture**
Start by referencing 1-2 key things the mapping found, framed as observations. The mapping gives you context to lead with instead of jumping straight to questions.

Say something like: "So from what I can see, you've got [high-level project description]. [One notable thing -- e.g., 'The testing is pretty thin' or 'The architecture looks clean']. Sound right?"

This is a warm-up -- the user already confirmed the summary, but this sets the conversational tone.

**2. What's next?**
Now ask what they want to change or add. This is the core question. The mapping gives you context to respond intelligently to their answer (e.g., if they say "add auth" and the mapping showed no auth exists, you can acknowledge that).

**3. Gap-filling round**
Based on what the mapping found (or didn't find), ask 2-3 gap-filling questions. These are things the user might not have thought about:
- Missing tests -> "Want to add tests as part of this?"
- No error handling patterns -> "How should the app handle errors?"
- Outdated dependencies -> "Some of your libraries are older versions -- want to update them?"
- No deployment config -> "Where will this run when it's ready?"

Only ask about gaps that are RELEVANT to what the user just said they want to do. If they want to add a dashboard and the mapping showed no tests, don't ask about tests unless it's relevant to the dashboard work.

**4. Decisions already made**
Ask if they've already committed to any approaches for the planned changes. Keep this brief.

**5. Concerns check**
If the mapping flagged notable concerns (surfaced via SUMMARY.md), briefly mention the top 1-2:
"I noticed [concern in plain language] -- is that something you want to tackle in this round?"

Only surface concerns that are relevant to the user's stated goals. Don't dump all concerns.

**6. Anything you're unsure about?**
Same as greenfield -- give space for unknowns. Mark unresolved items with [UNCLEAR].

Target 5-8 questions total for brownfield (shorter than greenfield since the mapping provides so much context). Adapt based on the user's preparation level, just like the greenfield interview.

### Brownfield Interview Wrap-Up

When you've covered the relevant sections:

> "Got it. Let me put together a vision document that captures where your project is and where you want to take it."

Then proceed to Generate Brownfield Vision.

---

## Research Pipeline

This section is referenced from both the Brownfield and Greenfield flows. Do not execute this section independently -- it is always triggered by an opt-in prompt from one of those flows.

### Opt-in Pitch

Offer research to the user. Adapt the phrasing to the conversation tone:

> "Want me to research best practices for this kind of project? Takes about a minute."

If the user declines, say something like:

> "No problem. You can always explore this later."

Then return to the calling flow and continue with the next step. Do NOT ask twice or make the user feel like they are missing out.

If the user accepts, continue with the pipeline below.

### Directory Setup

Ensure `.director/research/` directory exists before spawning researchers:

```bash
mkdir -p .director/research
```

### Model Profile Resolution

Read `.director/config.json` and resolve the model for each agent:

1. Read the `model_profile` field (defaults to "balanced")
2. Look up the profile in `model_profiles` to get model for `deep-researcher` and `synthesizer`

If config.json is missing the `model_profile` or `model_profiles` fields, fall back to "balanced" defaults.

### Researcher Spawning

Show a single progress message:

> "Researching your project's ecosystem..."

Then spawn 4 director-deep-researcher agents IN PARALLEL using 4 simultaneous Task tool calls. Each agent gets different instructions specifying its domain. All 4 Task tool calls go in a SINGLE message so they run in parallel. Do NOT wait for one researcher to finish before spawning the next.

The project context passed to researchers depends on how this pipeline was triggered:
- **From Brownfield flow:** Pass the contents of `.director/codebase/SUMMARY.md`
- **From Greenfield flow:** Pass the contents of `.director/VISION.md`

**Agent 1 (stack domain):**
```
<instructions>
Domain: stack

<project_context>
[Contents of VISION.md for greenfield, or codebase SUMMARY.md for brownfield]
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
[Contents of VISION.md for greenfield, or codebase SUMMARY.md for brownfield]
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
[Contents of VISION.md for greenfield, or codebase SUMMARY.md for brownfield]
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
[Contents of VISION.md for greenfield, or codebase SUMMARY.md for brownfield]
</project_context>

Research common mistakes and pitfalls for this type of project. Investigate stack-specific pitfalls AND broader domain pitfalls -- things that are harder than they look, common causes of rewrites, and what trips up builders working on this type of project.

Write your findings to .director/research/PITFALLS.md using the template at skills/onboard/templates/research/PITFALLS.md.

Use WebFetch to check current documentation for known issues and common mistakes. Verify findings against authoritative sources.

Return only a brief confirmation when done. Do NOT include file contents in your response.
</instructions>
```

### Synthesizer Spawning

After ALL 4 researchers have completed (or failed), spawn the director-synthesizer agent. This runs SEQUENTIALLY after the researchers (not in parallel with them).

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

### Research Summary Presentation

After the synthesizer returns, read `.director/research/SUMMARY.md` yourself (the main session agent). Format a structured ~20-30 line user-facing overview from the SUMMARY.md Executive Summary and Key Findings sections.

The overview should follow this structure:

> "Here's what the research suggests:"
>
> **Recommended approach**
> - [Core technology recommendation with brief rationale]
> - [Architecture pattern recommendation]
>
> **Features to consider**
> - [Must-have feature 1 -- why users expect it]
> - [Must-have feature 2]
> - [Nice-to-have if particularly relevant]
>
> **Things to watch out for**
> - [Top pitfall with prevention note]
> - [Second pitfall if relevant]

Keep it concise and plain-language. Do NOT show:
- The "Don't Hand-Roll" warnings (agents-only content)
- The full gameplan implications (agents-only content)
- Confidence levels or source attributions

After the summary, add a brief gameplan link:

> "Research suggests a good build order -- I'll use that for your gameplan."
> [1-2 lines explaining why, e.g., "Setting up user accounts first makes sense because most of your other features need to know who's logged in."]

This is a SUMMARY ONLY interaction. Do NOT offer drill-down.

### Researcher Failure Handling

If any researcher agent fails or times out:

1. Check which domains completed by looking for files in `.director/research/`
2. If 3 of 4 researchers succeeded: proceed with partial results. Tell the synthesizer which files are available. Note the gap in the user-facing summary.
3. If 2 or fewer researchers succeeded: tell the user research had limited results but share what was found.
4. If ALL researchers failed: tell the user research could not complete and move on gracefully. Research is opt-in, so this is graceful degradation, not a failure.

---

## Generate Vision Document

This section handles vision generation for **greenfield** projects.

After the interview completes, generate a vision document following the canonical structure from `skills/onboard/templates/vision-template.md`. Fill in every section with what you learned from the interview:

```
# Vision

## Project Name
[Name from interview]

## What It Does
[1-2 sentence summary -- the elevator pitch]

## Who It's For
[Target users and their context]

## Key Features

### Must-Have
- [Feature 1]
- [Feature 2]
- [Feature 3]

### Nice-to-Have
- [Feature 4]
- [Feature 5]

## Tech Stack
[Languages, frameworks, databases, hosting -- with brief reasoning for each choice]

## Success Looks Like
[What "done" means for v1 -- specific, measurable criteria]

## Decisions Made

| Decision | Why |
|----------|-----|
| [Choice the user made] | [Their reasoning or the reasoning discussed] |

## Open Questions
- [UNCLEAR] [Question still unresolved -- these will be addressed during planning]
```

Present the complete vision to the user:

> "Here's what I captured from our conversation. Take a look and let me know if anything needs changing."

Show the full document content. Wait for the user to review it.

If the user requests changes, make them and present the updated version. Keep iterating until the user confirms it looks right.

Then proceed to Save Vision.

---

## Generate Brownfield Vision

This section handles vision generation for **existing project** (brownfield) onboarding.

After the brownfield interview completes, generate a vision document following the same canonical template structure but with brownfield-specific content that captures both the current state and desired changes.

```
# Vision

## Project Name
[Name from existing project -- confirm with user during interview]

## What It Does
[Summary combining what the mapper found with the user's vision for changes. Describe the project as it will be after the planned work, not just as it is now.]

## Who It's For
[Target users -- from interview, or from mapper findings if obvious]

## Key Features

### Existing
- [Feature the mapper found that is staying as-is]
- [Another existing feature that works and isn't changing]

### Adding
- [New feature the user wants to build]
- [Another new capability from the interview]

### Changing
- [Existing feature that needs modification -- describe the change]
- [Another feature being updated]

### Removing
- [Feature being removed, if any -- include why]

## Tech Stack
[Current tech from mapper findings + any changes from interview. Note what's staying and what's changing.]

## Success Looks Like
[What "done" means for this round of changes -- from the interview]

## Decisions Made

| Decision | Why |
|----------|-----|
| [Existing decision from codebase] | [Why it was originally made, if apparent] |
| [New decision from interview] | [User's reasoning] |

## Open Questions
- [UNCLEAR] [Question still unresolved -- these will be addressed during planning]
```

The Key Features section uses a delta format to clearly separate what exists from what's being added, changed, or removed. This makes it easy to see at a glance what work needs to happen.

**Language note:** Use the section labels (Existing, Adding, Changing, Removing) in the vision document itself, but keep the conversation natural. Say things like "You have user accounts already, and you want to add a dashboard" -- not "EXISTING: user accounts, ADDING: dashboard."

Present the complete brownfield vision to the user:

> "Here's what I captured. It shows what you have now and what you want to change. Take a look and let me know if anything needs adjusting."

Show the full document content. Wait for the user to review it.

If the user requests changes, make them and present the updated version. Keep iterating until the user confirms it looks right.

Then proceed to Save Vision.

---

## Save Vision

Once the user approves the vision document (from either Generate Vision Document or Generate Brownfield Vision), write it to `.director/VISION.md` using the Write tool.

**Keep the tone conversational during file operations.** Do not narrate the technical details of what you're doing. Do not mention file paths as the primary communication.

Say something like:

> "Your vision is saved. You can always come back and update it by running `/director:onboard` again."

**For greenfield projects:** After saving, proceed to Research Opt-in (Greenfield) below.
**For brownfield projects:** After saving, proceed to Next Steps below.

---

## Research Opt-in (Greenfield)

After the vision is saved, offer domain research to greenfield users.

The VISION.md has been written to disk and captures the full project definition. This provides the context researchers need to investigate the project's ecosystem.

Proceed to the Research Pipeline section. When the pipeline asks for project context, use the VISION.md contents.

After the research pipeline completes (or is declined), proceed to Next Steps.

---

## Next Steps

Suggest the next step:

> "Ready to create a gameplan? That's where we break this down into goals and steps. You can do that with `/director:blueprint`."

Wait for the user to respond. Do not auto-execute the next command.

---

## Language Reminders

Throughout the entire onboarding flow, follow these rules:

- **Use Director's vocabulary:** Vision (not spec), Gameplan (not roadmap), Goal/Step/Task (not milestone/phase/ticket)
- **Explain outcomes, not mechanisms:** "Your vision is saved" not "Writing VISION.md to .director/VISION.md"
- **Be conversational, not imperative:** "Want to create a gameplan?" not "Run /director:blueprint"
- **Never blame the user:** "We need to figure out X" not "You forgot to specify X"
- **Celebrate naturally:** "Nice choice" or "That's a solid stack" -- not forced enthusiasm
- **Match the user's energy:** If they're excited, be excited. If they're focused, be focused.
- **Never use developer jargon in output:** No dependencies, artifacts, integration, repositories, branches, commits, schemas, endpoints, middleware. Use plain language equivalents.
- **Present mapper findings as collaborative observations, not judgments:** "I see that the project uses React" not "The codebase is built with React." Observations, not assessments.

$ARGUMENTS
