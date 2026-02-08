---
phase: 01-plugin-foundation
plan: 03
subsystem: skills-blueprint
tags: [skills, help, onboard, blueprint, templates, routing, dynamic-context]

requires:
  - phase: 01-01
    provides: Plugin manifest, init script, hooks infrastructure
  - phase: 01-02
    provides: Terminology, plain-language guide, verification patterns, context management references
provides:
  - Fully functional help command with dynamic mini-status
  - Onboard skill with context-aware routing and brownfield detection logic
  - Blueprint skill with routing that redirects to onboard when vision is missing
  - Six artifact templates defining .director/ document structure
affects:
  - 01-04 (Build-group skill definitions depend on established routing patterns)
  - 01-05 (Inspect/Other-group skills follow same routing pattern)
  - 01-06 (Agent definitions reference skills and templates)
  - Phase 2 (Onboard interview implementation fills vision-template)
  - Phase 3 (Blueprint planning implementation fills gameplan/goal/step/task templates)

tech-stack:
  added: []
  patterns:
    - SKILL.md with YAML frontmatter (name, description) and Markdown body for instructions
    - Dynamic context injection via backtick-bang shell commands in SKILL.md
    - Context-aware routing that checks project state before acting
    - Template files in skills/*/templates/ for .director/ artifact generation
    - Conversational routing messages following plain-language-guide.md patterns

key-files:
  created:
    - skills/help/SKILL.md
    - skills/onboard/SKILL.md
    - skills/onboard/templates/vision-template.md
    - skills/onboard/templates/config-defaults.json
    - skills/blueprint/SKILL.md
    - skills/blueprint/templates/gameplan-template.md
    - skills/blueprint/templates/goal-template.md
    - skills/blueprint/templates/step-template.md
    - skills/blueprint/templates/task-template.md
  modified: []

key-decisions:
  - "Help skill uses dynamic context injection (cat STATE.md) for mini-status rather than static content"
  - "Help groups commands into Blueprint/Build/Inspect/Other matching Director's core loop"
  - "Onboard routing checks VISION.md content quality (not just existence) to detect empty templates"
  - "Blueprint routing redirects to onboard conversationally when vision is missing"
  - "Config defaults template uses nested object format for agent models (matching plan spec exactly)"
  - "All routing messages follow four-step pattern: state situation, explain why, suggest action, wait for response"

patterns-established:
  - "Skill routing pattern: check .director/ exists, check relevant file state, route conversationally"
  - "Template convention: templates live in skills/*/templates/ named after the .director/ artifact they generate"
  - "$ARGUMENTS support: every skill includes $ARGUMENTS at the end for inline context"

duration: 2m 31s
completed: 2026-02-08
---

# Phase 01 Plan 03: Blueprint-Group Skills (Help, Onboard, Blueprint) Summary

**Fully functional help command with dynamic mini-status, onboard and blueprint skills with context-aware routing, and 6 artifact templates using Director's plain-language terminology**

## Performance

- **Duration:** 2m 31s
- **Started:** 2026-02-08T04:14:52Z
- **Completed:** 2026-02-08T04:17:23Z
- **Tasks:** 2/2 completed
- **Files created:** 9

## Accomplishments

1. Created `skills/help/SKILL.md` -- the only fully functional command in Phase 1, with dynamic context injection that reads STATE.md for mini-status when a project exists, and shows a welcome message with onboard suggestion for new users
2. Created `skills/onboard/SKILL.md` -- context-aware routing that silently initializes .director/ via init-director.sh, checks VISION.md content quality (not just existence), and handles both greenfield and brownfield detection scenarios conversationally
3. Created `skills/blueprint/SKILL.md` -- routing that checks VISION.md before allowing gameplan creation, redirecting conversationally to onboard when vision is missing
4. Created 6 artifact templates: vision-template.md (8 sections), config-defaults.json (canonical defaults), gameplan-template.md, goal-template.md, step-template.md, task-template.md -- all using Director's Goal/Step/Task terminology with zero developer jargon

## Task Commits

Each task was committed atomically:

1. **Task 1: Create fully functional help skill with dynamic mini-status** - `5907a10` (feat)
2. **Task 2: Create onboard and blueprint skills with routing logic and templates** - `4822333` (feat)

## Files Created

| File | Purpose |
|------|---------|
| `skills/help/SKILL.md` | Fully functional help command with 11 commands in 4 groups and dynamic mini-status |
| `skills/onboard/SKILL.md` | Context-aware onboard skill with routing and brownfield detection |
| `skills/onboard/templates/vision-template.md` | Template for .director/VISION.md with 8 sections |
| `skills/onboard/templates/config-defaults.json` | Canonical config.json defaults with agent model tiers |
| `skills/blueprint/SKILL.md` | Context-aware blueprint skill with VISION.md routing |
| `skills/blueprint/templates/gameplan-template.md` | Template for .director/GAMEPLAN.md |
| `skills/blueprint/templates/goal-template.md` | Template for .director/goals/*/GOAL.md |
| `skills/blueprint/templates/step-template.md` | Template for .director/goals/*/steps/*/STEP.md |
| `skills/blueprint/templates/task-template.md` | Template for task files in .director/ |

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| Help uses dynamic context injection via `cat STATE.md` | Provides live project awareness without static content that would go stale |
| Help groups commands as Blueprint/Build/Inspect/Other | Matches Director's core loop (Blueprint/Build/Inspect) for consistent mental model |
| Onboard checks VISION.md content quality, not just existence | Empty template should trigger interview flow; mere file existence is insufficient |
| Blueprint redirects to onboard conversationally | Follows plain-language-guide.md four-step routing pattern (state/explain/suggest/wait) |
| Config defaults template uses nested object format for agents | `{ "model": "inherit" }` format from plan spec allows future agent config expansion |
| All routing messages are conversational | Per CONTEXT.md decision: "routing messages should be conversational and suggest action" |

## Deviations from Plan

None -- plan executed exactly as written.

## Issues Encountered

None.

## User Setup Required

None -- no external service configuration required.

## Next Phase Readiness

**Ready for 01-04 (Build-Group Skills):** The routing pattern established here (check .director/, check relevant file state, route conversationally) provides the template for Build-group skills (build, quick).

**Ready for 01-05 (Inspect/Other Skills):** Same routing pattern applies to inspect, status, resume, brainstorm, pivot, idea commands.

**Ready for 01-06 (Agent Definitions):** Skills reference agents but agent definitions are a separate plan.

**Blockers:** None.

**Notes:**
- The config-defaults.json template uses `{ "model": "inherit" }` nested object format while init-director.sh uses flat string format (`"inherit"`). These should be reconciled when the config system is implemented in Phase 2-3. The template version (nested objects) is the canonical format per the plan spec.

## Self-Check: PASSED

---
*Phase: 01-plugin-foundation*
*Completed: 2026-02-08*
