# Pitfalls Research

**Analysis Date:** 2026-02-16
**Confidence:** HIGH

## Critical Pitfalls

_What mistakes in this domain cause the most rework?_

### Pitfall: Secret Exposure via Codebase Analysis

**What goes wrong:**
The deep mapper agent reads source files to produce analysis documents that are committed to `.director/codebase/`. If a user has accidentally checked in a `.env` file or credentials file, the mapper can quote sensitive values directly into `STACK.md`, `ARCHITECTURE.md`, or `CONCERNS.md`. Those files then become part of the git history permanently. This is the only HIGH-priority security issue in the codebase -- confirmed in `agents/director-deep-mapper.md` and `.director/codebase/CONCERNS.md`.

**Why it happens:**
The protection against reading secret files is instruction-based only. The agent is told "NEVER read `.env` files" but there is no tooling enforcement -- no `disallowedTools` restriction, no pre-read file path filter, no pre-onboard scan. Any drift in the agent's instruction-following (model variation, long context, prompt injection) breaks the protection.

**How to avoid:**
- Add a pre-onboard Bash scan for common secret file patterns before spawning mapper agents: `find . -name ".env*" -o -name "*credentials*" -o -name "*secret*" | head -20`
- Present findings to the user with a warning before proceeding with mapping
- Consider adding `disallowedTools` for specific file path patterns, or a `PreToolUse` hook that blocks reads of forbidden file patterns
- Document in `README.md` that `.env` files must not be committed before running `/director:onboard`

**Warning signs:**
- User has a `.env` file that is not in `.gitignore`
- Codebase analysis files contain strings that look like API keys (long alphanumeric strings, strings starting with `sk-`, `pk_`, `AKIA`, etc.)
- Running `git log --all --full-history -- .director/codebase/*.md` shows unexpected changes after onboarding a project with committed secrets

---

### Pitfall: Silent State Drift from Syncer Failure

**What goes wrong:**
The syncer agent runs AFTER the builder commits code. If the syncer crashes, times out, or encounters an error mid-sync, the code commit exists in git but `.director/STATE.md`, `GAMEPLAN.md`, and task files are not updated. The next `/director:build` run reads stale state and may re-run a completed task, skip a task, or sequence tasks incorrectly. Confirmed in `skills/build/SKILL.md` Steps 7-9 and `.director/codebase/CONCERNS.md`.

**Why it happens:**
The build skill treats syncer completion as advisory, not required. There is no idempotency key or completion verification step. The single-writer design (only the syncer writes STATE.md) means there is no fallback writer -- if syncer fails, nothing updates the docs. Syncer timeouts are possible on slow machines or with large codebases.

**How to avoid:**
- The build skill should verify syncer completed before reporting "task done" to the user
- Add a syncer health check: after spawning the syncer, verify `.director/STATE.md` shows the expected task as complete
- If syncer fails, surface an explicit error: "Task was built successfully but progress tracking needs to be updated. Run `/director:refresh` to resync."
- Consider making the syncer write an idempotency marker before updating docs so partial syncs can be detected and retried

**Warning signs:**
- Task files that should be `.done.md` are still `.md` after a build
- `STATE.md` shows an earlier task as "Current Position" than what was last built
- Running `/director:status` shows different progress than what you remember building

---

### Pitfall: Context Accumulation Across Agent Invocations

**What goes wrong:**
Director's core design principle -- fresh agent context per task -- can be violated by the `memory: project` setting in `agents/director-builder.md`. If patterns from Goal 1 are retained in builder memory when Goal 2 begins (e.g., the tech stack changed, the architecture was refactored), the builder applies stale patterns to new code. This is confirmed as a fragile area in `.director/codebase/CONCERNS.md`. The problem is subtle: the builder does not know which memories are stale without explicit signals.

**Why it happens:**
`memory: project` is meant to improve consistency across tasks. But project memory is not cleared between goals, and the memory files are not invalidated when `/director:pivot` or `/director:refresh` runs. The builder has no mechanism to know when a previously-learned pattern is no longer valid.

**How to avoid:**
- After a pivot or major architecture change, explicitly clear or annotate the builder's memory directory (`.claude/agent-memory/director-builder/`)
- Add a "Pattern Changes" section to `STEP.md` files that signals to the builder when patterns from earlier goals no longer apply
- Consider adding a note in `skills/pivot/SKILL.md` that builder memory may need to be cleared after large pivots
- Alternatively, disable `memory: project` in the builder and rely entirely on explicit codebase context files

**Warning signs:**
- Builder is using import patterns, file organization, or naming conventions from earlier goals that were superseded
- New tasks introduce inconsistencies that match old patterns rather than the current codebase state
- The builder references patterns not present in the current codebase files

---

### Pitfall: Deep Mapper Timeout on Large Codebases

**What goes wrong:**
The deep mapper agent is capped at 40 turns (`maxTurns: 40`). For large codebases (500+ files), a single mapper invocation can exhaust its turn limit before completing analysis. The fallback in `skills/onboard/SKILL.md` is to use the v1.0 `director-mapper` agent, which produces less detailed output. Users onboarding enterprise-scale projects may silently receive incomplete codebase context, causing downstream builder agents to work without key patterns and conventions.

**Why it happens:**
The mapper reads files sequentially, so large codebases require proportionally more turns. The 40-turn limit is a safety cap, not a functional threshold. The failure mode is non-obvious: the fallback runs and completes, so the user sees no error, but the quality of codebase analysis is degraded.

**How to avoid:**
- Add a codebase size check before spawning mappers: count files, estimate scope, warn if over 500 files
- For large codebases, tell users explicitly: "This is a large project. Analysis may be partial -- use `/director:refresh` to map specific areas in detail."
- Increase mapper `maxTurns` for the initial onboard of large projects, or instruct mappers to focus on the 10 most important directories and document what was skipped
- Implement graceful partial results: if tech mapper succeeds but concerns mapper times out, still use the tech mapper's output rather than falling back entirely

**Warning signs:**
- Onboarding a project with 500+ source files
- Codebase analysis files that say "Not detected" for patterns that clearly exist (the mapper didn't reach those files)
- Builder agent consistently makes choices inconsistent with the codebase (suggests the codebase context is missing)

---

### Pitfall: Template Detection Failures in Skill Routing

**What goes wrong:**
Skills route based on whether VISION.md and GAMEPLAN.md contain real content or just template placeholders. The detection looks for specific strings like `_No goals defined yet_` and `This file will be populated when you run /director:blueprint`. If a user edits these files and inadvertently removes or changes the placeholder text -- or if the template content changes -- routing breaks silently. The build skill may skip its vision check and attempt to execute tasks against a hollow vision.

**Why it happens:**
Template detection is string-matching, not schema validation. Users can edit `.director/` files directly (this is intentional and expected), which means the detection markers can be inadvertently modified. There is no structural validation of whether VISION.md contains the required sections with real content.

**How to avoid:**
- Make placeholder markers harder to accidentally remove (use comment-style markers that users would not naturally edit)
- Add a secondary content check: even if markers are absent, check whether key sections have more than N characters of real content
- Document in `reference/` which strings are routing-critical and should not be modified
- Consider a `/director:check` or init-time validation that verifies key file structures before any skill runs

**Warning signs:**
- Running `/director:build` when the project has not been fully onboarded produces no warning
- VISION.md was manually edited and now the vision check in Step 2 of the build skill passes even though content is minimal

---

## Common Shortcuts That Backfire

_What time-savers create long-term problems?_

| Shortcut | Short-term Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|----------------|-----------------|
| Skipping `/director:onboard` for existing projects and going straight to `/director:blueprint` | Faster to start planning | Builder agents have no codebase context; they write code inconsistent with existing patterns and conventions | Only for brand-new greenfield projects with no existing code |
| Manually editing task files to mark them as `.done.md` instead of running `/director:build` | Skip tasks that seem trivial | `STATE.md` doesn't reflect the completion; `GAMEPLAN.md` progress isn't updated; the syncer never runs; state drifts | Never -- always complete tasks through the build workflow |
| Running `/director:build` repeatedly without checking `/director:inspect` at goal boundaries | Faster shipping | Goals may appear complete but not actually achieve their stated purpose; defects accumulate across goals | Never for production projects; only acceptable for throwaway prototypes |
| Skipping `/director:refresh` after large codebase changes | Saves the time of a refresh run | Builder agents continue to reference stale codebase patterns; new files are invisible to context assembly | Acceptable if changes were minor (1-2 files) and not architectural |
| Using `/director:quick` for all tasks instead of the full build workflow | No planning overhead | Quick tasks bypass the verification and documentation sync steps; STATE.md is not updated; progress tracking breaks | Acceptable for one-off utility tasks that are not part of the main gameplan |
| Putting API keys in `.director/config.json` for convenience | Easy access during development | Config file is committed to git; keys are permanently exposed in git history | Never |

## Things That Look Done But Aren't

_What features commonly appear complete but are missing critical pieces?_

- [ ] **Onboarding complete:** Often missing the research phase -- verify that `.director/research/` contains `STACK.md`, `FEATURES.md`, `ARCHITECTURE.md`, and `PITFALLS.md`. Onboard can succeed without research if WebFetch is unavailable or times out.
- [ ] **Task marked done:** Often missing STATE.md update -- verify `STATE.md` shows the task as complete and the commit sha is present. If syncer failed, the code commit exists but progress tracking does not reflect it.
- [ ] **Goal complete:** Often missing goal-backward verification -- verify `/director:inspect` has been run, not just that all task files are `.done.md`. Task completion does not imply goal achievement.
- [ ] **Pivot executed:** Often missing builder memory reset -- verify that builder memory files in `.claude/agent-memory/` still reflect current patterns, not the pre-pivot architecture.
- [ ] **Codebase mapped:** Often incomplete for large projects -- verify that `CONCERNS.md` and `CONVENTIONS.md` contain specific patterns from the actual source, not just "Not detected" placeholders throughout.
- [ ] **Research complete:** Often missing step-level research -- verify each step directory that requires technical decisions contains a `RESEARCH.md` file, not just the goal-level `/research/` summary.
- [ ] **Plugin installed:** Often missing version check -- verify Claude Code is v1.0.33 or later (`claude --version`) before assuming Director features will work. Silent failures occur on older versions.

## Security Mistakes

_What domain-specific security issues go beyond general web security?_

| Mistake | Risk | Prevention |
|---------|------|------------|
| Committing `.env` or credential files to git before running `/director:onboard` | Mapper reads and quotes sensitive values into `.director/codebase/` analysis files, which are then committed. Credentials are permanently in git history | Add a pre-onboard check that scans for and warns about common secret files. Enforce `.gitignore` rules before running mapper agents. |
| Storing API keys or auth tokens in `.director/config.json` | Config file is committed to git and shared with any collaborators who clone the project | Document explicitly that `config.json` is for settings only. If integration credentials are needed, use environment variables or a secrets manager. |
| Using `bypassPermissions` in agent configurations without audit | Agents can execute any operation without approval, including destructive git operations, file deletions, and arbitrary Bash commands | Never set `bypassPermissions` in Director agent files. All builder agents should use default permission mode with explicit user approval for destructive operations. |
| Codebase analysis files that quote code snippets containing secrets | Even if the original secrets file is gitignored, quoted values in STACK.md or ARCHITECTURE.md are committed | Review all `.director/codebase/` files before first commit. Implement a pre-commit hook that scans these files for common secret patterns. |
| Agent memory files containing sensitive context | Builder memory (`memory: project`) may accumulate context about database schemas, API structures, or internal architecture that should not be shared | Audit `.claude/agent-memory/director-builder/` before committing or sharing the project. Consider adding this directory to `.gitignore` if the project contains sensitive internal details. |

## Performance Traps

_What patterns work at small scale but fail as usage grows?_

| Trap | Symptoms | Prevention | When It Breaks |
|------|----------|------------|----------------|
| Running all 4 deep mapper agents in parallel on a large codebase | One or more mappers time out at 40 turns; fallback to v1.0 mapper produces incomplete context; builder agents receive degraded codebase analysis | Add codebase size detection; reduce parallel agents to 2 for large projects; increase maxTurns for large codebases | Projects with 500+ source files or deeply nested directory structures |
| Context assembly including full STEP.md and full codebase files simultaneously | Assembled context exceeds 60K token budget; truncation silently drops codebase files that the builder needs; builder makes choices inconsistent with existing patterns | Follow the 30% budget rule from `reference/context-management.md`; use summaries over full files; prefer one or two specific codebase files over the full suite | Steps with very long descriptions combined with large codebase analysis files |
| Running `/director:build` in rapid succession without session breaks | Conversation context accumulates between builds if run in the same session; agent quality degrades as context grows; cost increases with each turn | Each build should start fresh -- this is by design. If build quality degrades, start a new session and run `/director:resume` to restore context. | After 10+ builds in a single session without clearing context |
| STATE.md growing unbounded on long-running projects | State file reads and writes become slower; context assembly includes larger state; syncer updates take longer | Recent Activity is already capped at 10 entries, which mitigates this. Archive old entries after 100+ tasks if file becomes unwieldy. | Projects with 100+ completed tasks and verbose activity entries |
| Using `inherit` model (Opus) for all 4 parallel mapper agents | Parallel Opus calls during onboard generate significant token cost; onboarding a large project can cost $5-15 in a single run | Use Haiku or Sonnet for mapper agents. Configure model profiles in `.director/config.json`. Use the "balanced" profile for most projects. | Projects with large codebases onboarded with the "quality" model profile |

## Sources

- Claude Code plugin documentation: https://code.claude.com/docs/en/plugins (verified 2026-02-16)
- Claude Code sub-agents documentation: https://code.claude.com/docs/en/sub-agents (verified 2026-02-16)
- Claude Code hooks reference: https://code.claude.com/docs/en/hooks (verified 2026-02-16)
- `.director/codebase/CONCERNS.md` -- Director's own self-analysis identifying HIGH and MEDIUM priority issues (2026-02-16)
- `agents/director-deep-mapper.md` -- Mapper agent definition with Forbidden Files section and 40-turn limit
- `skills/build/SKILL.md` -- Build skill showing syncer failure modes and verification retry logic
- `reference/context-management.md` -- Context budget rules and truncation strategy
- `.director/codebase/SUMMARY.md` -- Cross-reference findings connecting architecture and concerns

## Quality Gate

Before considering this file complete, verify:
- [x] At least 3 critical pitfalls documented with prevention strategies
- [x] Warning signs included for each critical pitfall
- [x] "Things That Look Done But Aren't" has at least 3 items
- [x] Prevention strategies are specific and actionable
- [x] No section left empty -- use "Not detected" if nothing found
