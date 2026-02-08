---
phase: 01-plugin-foundation
plan: 02
subsystem: reference-docs
tags: [terminology, plain-language, verification, context-management, reference]
requires: []
provides:
  - "Shared terminology reference for all skills and agents"
  - "Plain-language communication guidelines"
  - "Structural verification patterns for verifier agent"
  - "Context assembly rules for builder agent and skill definitions"
affects:
  - "01-03 (folder structure and templates)"
  - "01-04 (skill definitions reference terminology and plain-language docs)"
  - "01-05 (agent prompts reference all four docs)"
  - "01-06 (config and hooks may reference context management)"
tech-stack:
  added: []
  patterns:
    - "Three-layer formatting model (Markdown/XML/JSON)"
    - "XML boundary tags for agent context assembly"
    - "30% context budget rule"
    - "Stub/orphan/wiring structural verification"
key-files:
  created:
    - reference/terminology.md
    - reference/plain-language-guide.md
    - reference/verification-patterns.md
    - reference/context-management.md
  modified: []
key-decisions:
  - id: "TERM-01"
    decision: "Never-use word list includes 30+ developer jargon terms across 4 categories"
    rationale: "Comprehensive deny-list prevents jargon leaking into user output"
  - id: "TERM-02"
    decision: "OK-to-use word list organized by general tech, features, and concepts"
    rationale: "Agents need to know what IS acceptable, not just what isn't"
  - id: "VERIFY-01"
    decision: "Two severity levels: 'needs attention' (blocking) and 'worth checking' (informational)"
    rationale: "Matches plain-language approach; avoids developer-style severity ratings"
  - id: "CTX-01"
    decision: "Agent-specific context profiles defined as a table showing which sections each agent receives"
    rationale: "Prevents over-loading agents with irrelevant context; easy to reference during skill/agent authoring"
  - id: "CTX-02"
    decision: "Context budget calculator deferred to Phase 4 with design notes captured now"
    rationale: "Aligns with existing roadmap; design is documented so Phase 4 can implement directly"
duration: "4 minutes"
completed: "2026-02-08"
---

# Phase 01 Plan 02: Reference Documents Summary

Four reference documents created as the shared knowledge base for all Director skills and agents -- vocabulary rules, communication guidelines, verification patterns, and context assembly conventions.

## Performance

| Metric | Value |
|--------|-------|
| Duration | 4 minutes |
| Tasks | 2/2 |
| Deviations | 0 |
| Blockers | 0 |

## Accomplishments

### terminology.md (130 lines)
- Complete project hierarchy with visibility rules (Goal/Step/Task visible, Actions hidden, Git abstracted)
- Term mapping table with 15 Director-to-developer translations
- Never-use word list: 30+ terms across 4 categories (workflow, git, backend, infrastructure)
- OK-to-use word list: 30+ terms across 3 categories (general tech, features, concepts)
- Good/bad phrasing examples covering status reports, error messages, and git abstractions

### plain-language-guide.md (145 lines)
- 7 communication rules with bad/good examples for each
- Routing message template (4-step pattern: state, explain, suggest, wait)
- 3 routing examples (no gameplan, complex quick task, no project)
- Tone calibration table for 6 common situations
- Usage notes for agents including guidance on technical users

### verification-patterns.md (194 lines)
- Stub detection: 6 pattern categories (comment markers, hardcoded returns, empty bodies, placeholder UI, mock APIs, debug artifacts)
- Orphan detection: 5 pattern categories (files, components, API routes, utilities, styles) with detection methods and exception rules
- Wiring verification: 5 pattern categories (imports, API URLs, database refs, env vars, navigation) with specific checks
- Reporting format with two severity levels and a full example report

### context-management.md (274 lines)
- Three-layer formatting model with clear audience/format/examples for each layer
- XML boundary tag reference table with 7 standard tags and when to include each
- Tag nesting and ordering rules
- Full assembly example showing all tags with realistic content
- Fresh context assembly rules (include list, exclude list, rationale)
- Context budget guidelines with 30% rule, per-section allocation table, and truncation priority
- Context budget calculator design notes for Phase 4
- Dynamic context injection via `!command` syntax
- Agent-specific context profiles table for all 8 agents

## Task Commits

| Task | Name | Commit | Key Files |
|------|------|--------|-----------|
| 1 | Create terminology and plain-language reference docs | 6920185 | reference/terminology.md, reference/plain-language-guide.md |
| 2 | Create verification patterns and context management reference docs | da5ea6f | reference/verification-patterns.md, reference/context-management.md |

## Files Created

| File | Purpose | Lines |
|------|---------|-------|
| reference/terminology.md | Director vocabulary rules, term mappings, word lists | 130 |
| reference/plain-language-guide.md | Communication rules for vibe coders | 145 |
| reference/verification-patterns.md | Stub, orphan, and wiring detection patterns | 194 |
| reference/context-management.md | Fresh agent context assembly rules and XML conventions | 274 |

## Decisions Made

| ID | Decision | Rationale |
|----|----------|-----------|
| TERM-01 | Never-use word list has 30+ terms in 4 categories | Comprehensive deny-list prevents jargon leaking into user output |
| TERM-02 | OK-to-use words organized by general tech, features, concepts | Agents need positive guidance too, not just restrictions |
| VERIFY-01 | Two severity levels: "needs attention" and "worth checking" | Plain-language alternatives to developer-style severity ratings |
| CTX-01 | Agent-specific context profiles defined as reference table | Prevents over-loading agents; easy to consult during skill/agent authoring |
| CTX-02 | Context budget calculator deferred to Phase 4 with design notes now | Aligns with roadmap; design captured so Phase 4 can implement directly |

## Deviations from Plan

None -- plan executed exactly as written.

## Issues Encountered

None.

## Next Phase Readiness

**Ready for Plan 01-03 (folder structure and templates):**
- All four reference documents are in place and can be referenced by skills and agents
- Terminology and plain-language rules are ready for skill instruction authoring (Plan 01-04)
- Verification patterns are ready for verifier agent prompt (Plan 01-05)
- Context management rules are ready for builder agent and context assembly logic (Plan 01-05)

**No blockers or concerns for subsequent plans.**

## Self-Check: PASSED
