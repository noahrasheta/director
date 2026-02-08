---
phase: 01-plugin-foundation
plan: 06
subsystem: agents
tags: [builder, verifier, debugger, syncer, sub-agents, system-prompts, agent-definitions]
requires:
  - "01-02: Reference documents (terminology, plain-language, verification-patterns, context-management)"
provides:
  - "Builder agent with full system prompt, sub-agent spawning, and persistent memory"
  - "Verifier agent with full system prompt, stub/orphan/wiring detection, hard read-only enforcement"
  - "Debugger agent with full system prompt, investigation process, and fix capabilities"
  - "Syncer agent with full system prompt, .director/-only scope, no auto-commit rule"
affects:
  - "01-05 (peer agents -- interviewer, planner, researcher, mapper)"
  - "01-07 (config and hooks may reference agent models)"
  - "Phase 4 (execution engine will wire skills to these agents)"
tech-stack:
  added: []
  patterns:
    - "Agent YAML frontmatter with tools, model, maxTurns, memory, disallowedTools"
    - "Hard deny (disallowedTools) for read-only agents; soft instruction for scope-limited agents"
    - "Graceful degradation pattern for direct agent invocation without assembled context"
    - "Sub-agent spawning via Task(agent-name) in tools field"
key-files:
  created:
    - agents/director-builder.md
    - agents/director-verifier.md
    - agents/director-debugger.md
    - agents/director-syncer.md
  modified: []
key-decisions:
  - id: "AGENT-01"
    decision: "Builder is the only agent with memory: project in Phase 1"
    rationale: "Builder benefits most from persistent learning (codebase patterns, conventions). Other agents deferred to Phase 2."
  - id: "AGENT-02"
    decision: "Verifier uses disallowedTools hard deny; syncer uses soft instruction for scope restriction"
    rationale: "Verifier must never modify code (platform enforcement). Syncer needs Write access but is instructionally scoped to .director/ only."
  - id: "AGENT-03"
    decision: "Debugger has full write access (Write, Edit) to apply fixes directly"
    rationale: "Debugger needs to fix issues found by verifier without round-tripping back to builder for simple fixes."
patterns-established:
  - "Agent graceful degradation: every agent has an 'If Context Is Missing' section directing users to /director:help"
  - "Sub-agent chain: builder spawns verifier (post-task check) then syncer (doc sync), with debugger available for fix cycles"
  - "Model tier assignment: inherit for reasoning-heavy agents (builder, debugger), haiku for pattern-matching agents (verifier, syncer)"
duration: "3 minutes"
completed: "2026-02-08"
---

# Phase 01 Plan 06: Write-and-Verify Agent Definitions Summary

**Four agents with complete system prompts: builder (task execution with sub-agent spawning and persistent memory), verifier (read-only structural checks with hard deny), debugger (issue investigation and direct fixing), syncer (.director/-only documentation drift detection with no auto-commit)**

## Performance

- **Duration:** 3 minutes
- **Started:** 2026-02-08T04:15:07Z
- **Completed:** 2026-02-08T04:18:31Z
- **Tasks:** 2/2
- **Files created:** 4

## Accomplishments

### director-builder.md (109 lines)
- Full execution rules: single-task focus, real implementation only (no stubs/placeholders), codebase-first approach
- Sub-agent spawning via Task(director-verifier, director-syncer) for post-task verification and doc sync
- Persistent memory (memory: project) for learning codebase patterns across sessions
- Git rules: one commit per task, plain-language commit messages, never expose git to users
- Output rules with "never say / instead say" examples for plain-language reporting
- XML context tags documented: vision, current_step, task, recent_changes, instructions

### director-verifier.md (136 lines)
- Three check categories: stub detection (6 sub-patterns), orphan detection (5 types with exceptions), wiring verification (5 connection types)
- Hard read-only enforcement: disallowedTools: Write, Edit, WebFetch
- Two severity levels: "needs attention" (blocking) and "worth checking" (informational)
- Output format with specific location references (file + line, not vague descriptions)
- References verification-patterns.md for detailed detection patterns

### director-debugger.md (133 lines)
- Five-step investigation process: understand problem, read source, check common causes, form diagnosis, determine fix approach
- Four categories of common causes: missing connections, type/data issues, configuration problems, integration problems
- Fix rules: fix only what's broken, verify fix works, preserve original intent, don't create new commits
- Retry context awareness with rules for successive attempts (don't repeat failed approaches, escalate if stuck)
- Structured output: what I found, why it happened, what I did, status

### director-syncer.md (111 lines)
- File-by-file scope table: what can be modified vs flagged vs never touched
- Three-step sync process: understand changes, check STATE.md, check GAMEPLAN.md, check VISION.md
- Explicit no auto-commit rule referencing project-level requirement
- Vision drift reporting without modification (vision changes are always user decisions)
- Concise output format: changes made + issues found, nothing more

## Task Commits

| Task | Name | Commit | Key Files |
|------|------|--------|-----------|
| 1 | Create builder and verifier agent definitions | 7cde272 | agents/director-builder.md, agents/director-verifier.md |
| 2 | Create debugger and syncer agent definitions | 476fdb2 | agents/director-debugger.md, agents/director-syncer.md |

## Files Created

| File | Purpose | Lines |
|------|---------|-------|
| agents/director-builder.md | Task execution agent with sub-agent spawning and persistent memory | 109 |
| agents/director-verifier.md | Structural verification agent (read-only, hard deny) | 136 |
| agents/director-debugger.md | Issue investigation and fix planning agent | 133 |
| agents/director-syncer.md | Documentation sync agent (.director/ only, no auto-commit) | 111 |

## Decisions Made

| ID | Decision | Rationale |
|----|----------|-----------|
| AGENT-01 | Builder is the only agent with memory: project in Phase 1 | Builder benefits most from persistent learning; other agents deferred to Phase 2 |
| AGENT-02 | Verifier uses hard deny; syncer uses soft instruction for scope | Verifier must never modify code (platform-enforced). Syncer needs Write but is instructionally scoped. |
| AGENT-03 | Debugger has full write access to apply fixes directly | Simple fixes (typos, missing imports) shouldn't require round-tripping back to builder |

## Deviations from Plan

None -- plan executed exactly as written.

## Issues Encountered

None.

## User Setup Required

None -- no external service configuration required.

## Next Phase Readiness

**Ready for Plan 01-05 (peer agents -- interviewer, planner, researcher, mapper):**
- Agent definition pattern established with four complete examples
- YAML frontmatter conventions proven (tools, model, maxTurns, memory, disallowedTools)
- Graceful degradation pattern ready for reuse across remaining agents
- Sub-agent chain (builder -> verifier -> syncer) documented for reference

**No blockers or concerns for subsequent plans.**

## Self-Check: PASSED
