---
phase: 01-plugin-foundation
plan: 05
subsystem: agents
tags: [interviewer, planner, researcher, mapper, agent-prompts, system-prompts]
requires:
  - phase: 01-02
    provides: "Terminology, plain-language, verification, and context management reference docs"
provides:
  - "Interviewer agent with adaptive interview, multiple choice, brownfield mode"
  - "Planner agent with goal-backward decomposition, vertical slices, delta updates"
  - "Researcher agent with option comparison, recommendations, web access"
  - "Mapper agent with codebase analysis, tech stack detection, read-only enforcement"
affects:
  - "01-06 (remaining 4 agents: builder, verifier, debugger, syncer)"
  - "02-xx (onboard workflow connects to interviewer and mapper agents)"
  - "02-xx (blueprint workflow connects to planner agent)"
  - "04-xx (builder workflow may spawn researcher as sub-agent)"
tech-stack:
  added: []
  patterns:
    - "Agent YAML frontmatter: name, description, tools, disallowedTools, model, maxTurns"
    - "Hard deny via disallowedTools for read-only agents (Write, Edit excluded)"
    - "Graceful degradation section in every agent for direct invocation without context"
    - "XML boundary tag context expectations documented in each agent prompt"
key-files:
  created:
    - agents/director-interviewer.md
    - agents/director-planner.md
    - agents/director-researcher.md
    - agents/director-mapper.md
  modified: []
key-decisions:
  - id: "AGENT-01"
    decision: "Interviewer disallows WebFetch in addition to Write/Edit"
    rationale: "Interviewer's job is conversation, not research -- web fetching is the researcher's domain"
  - id: "AGENT-02"
    decision: "Mapper disallows WebFetch in addition to Write/Edit"
    rationale: "Mapper analyzes local codebase only -- no reason to access the web"
  - id: "AGENT-03"
    decision: "All agents document their XML context expectations inline"
    rationale: "Self-documenting prompts -- each agent knows what tags it expects and what to do without them"
patterns-established:
  - "Agent prompt structure: frontmatter > role > context > process/rules > output > graceful degradation > language rules"
  - "Read-only enforcement: both disallowedTools (hard) and prompt instructions (soft) for defense-in-depth"
duration: "3m 28s"
completed: "2026-02-08"
---

# Phase 01 Plan 05: Read-Analyze Agent Definitions Summary

**Four production-ready agent prompts for interviewer (adaptive interviews with multiple choice), planner (goal-backward decomposition with vertical slices), researcher (option investigation with web access), and mapper (codebase analysis on haiku with read-only enforcement).**

## Performance

| Metric | Value |
|--------|-------|
| Duration | 3 minutes 28 seconds |
| Tasks | 2/2 |
| Deviations | 0 |
| Blockers | 0 |

## Accomplishments

### director-interviewer.md (111 lines)
- 9 interview rules: one question at a time, multiple choice, preparation gauge, proactive surfacing of unconsidered decisions, [UNCLEAR] markers, adaptive pacing
- 8 interview sections mapped to vision template structure
- Brownfield mode: adapts to existing codebase findings, asks about changes rather than builds
- Vision output with user confirmation before saving
- Graceful degradation directing to `/director:onboard`

### director-planner.md (146 lines)
- 6 planning rules: outcome-based goals, verifiable steps, single-sitting tasks, dependency ordering, ready-work filtering, vertical slices
- Complexity indicators table: small/medium/large with scope descriptions
- Dependency language guide: "needs X first" not "depends on TASK-03"
- Update mode with delta format (added/changed/removed) preserving completed work
- Gameplan output with user review before finalizing

### director-researcher.md (118 lines)
- 5-step research process: understand, identify options, recommend, note risks, provide quick start
- Structured output format with comparison table, recommendation, risks, and quick start
- Quality standards: well-maintained, good docs, simpler-is-better for vibe coders, compatibility checks
- WebFetch tool for web-based library and API research
- Graceful degradation directing to `/director:help`

### director-mapper.md (123 lines)
- 5-step mapping process: structure scan, tech stack detection, architecture assessment, capability inventory, health assessment
- Plain-language output format: "What I found", "Built with", "What it can do", "How it's organized", "Things worth noting"
- Large project handling: prioritized scanning, turn limit awareness, partial reporting
- Hard read-only enforcement via disallowedTools (Write, Edit, WebFetch all denied)
- Model: haiku for cost-efficient high-volume analysis

## Task Commits

| Task | Name | Commit | Key Files |
|------|------|--------|-----------|
| 1 | Create interviewer and planner agent definitions | 63dab58 | agents/director-interviewer.md, agents/director-planner.md |
| 2 | Create researcher and mapper agent definitions | 476fdb2 | agents/director-researcher.md, agents/director-mapper.md |

## Files Created

| File | Purpose | Lines |
|------|---------|-------|
| agents/director-interviewer.md | Adaptive project interview agent for onboarding | 111 |
| agents/director-planner.md | Goal/Step/Task decomposition agent for blueprint | 146 |
| agents/director-researcher.md | Library/API/approach investigation agent | 118 |
| agents/director-mapper.md | Codebase analysis agent for brownfield projects | 123 |

## Decisions Made

| ID | Decision | Rationale |
|----|----------|-----------|
| AGENT-01 | Interviewer disallows WebFetch along with Write/Edit | Interviewer conducts conversation, doesn't research -- that's the researcher's job |
| AGENT-02 | Mapper disallows WebFetch along with Write/Edit | Mapper analyzes local codebase only; no web access needed |
| AGENT-03 | All agents document XML context expectations inline | Self-documenting: each agent knows what tags it expects and how to handle missing context |

## Deviations from Plan

None -- plan executed exactly as written.

## Issues Encountered

None.

## User Setup Required

None -- no external service configuration required.

## Next Phase Readiness

**Ready for Plan 01-06 (remaining 4 agents: builder, verifier, debugger, syncer):**
- Agent prompt structure pattern established (frontmatter > role > context > process > output > degradation > language)
- Read-only enforcement pattern proven (disallowedTools for hard deny)
- All 4 agents reference terminology.md and plain-language-guide.md, establishing the convention for remaining agents
- Context profile expectations from context-management.md are documented in each agent's Context section

**No blockers or concerns for subsequent plans.**

## Self-Check: PASSED

---
*Phase: 01-plugin-foundation*
*Completed: 2026-02-08*
