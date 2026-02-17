# Codebase Concerns

**Analysis Date:** 2026-02-16

## Technical Debt

**Context assembly complexity in `skills/build/SKILL.md`:**
- Issue: The context assembly procedure (Steps 5a-5e) is highly detailed with multiple conditional branches for codebase file loading, truncation logic, and cost calculation. This complexity spans lines 115-263 and includes nested decision trees that could become fragile as new context types are added.
- Files: `skills/build/SKILL.md` (lines 115-263), `reference/context-management.md` (Truncation Strategy section)
- Impact: If the truncation strategy changes or new deep context types are added (research, codebase summaries), both the build skill AND the quick skill (which duplicates this logic) must be updated in parallel. Currently there is no shared implementation.
- Fix approach: Extract context assembly logic into a reusable pattern document that both build and quick reference. Consider whether future releases will need a centralized context assembly utility.
- Priority: **MEDIUM** -- Current approach works but creates maintenance burden as context types grow. The duplication risk is real: quick skill has its own copy of the context-management rules (see `skills/quick/SKILL.md` lines 115-160).

**Documentation synchronization guarantees:**
- Issue: The syncer agent runs AFTER the builder commits, which means the .director/ files are updated asynchronously. If the syncer fails to run or crashes mid-sync, the task commit exists but documentation does not reflect the actual state.
- Files: `skills/build/SKILL.md` (Step 7 spawning, Step 9a syncer changes), `agents/director-syncer.md` (Output section)
- Impact: Users could be left with accurate code but stale .director/ documentation. This creates confusion about current progress and can cause incorrect task sequencing on the next build.
- Fix approach: Strengthen the syncer contract -- build skill should verify that syncer completed successfully and that all `.director/` files were updated before considering the task complete. Add idempotency keys to prevent duplicate state entries.
- Priority: **MEDIUM** -- The risk is low in normal operation but high if syncer times out or encounters an error. Detect and handle syncer failures explicitly.

**Model profile resolution in onboard/refresh:**
- Issue: Both onboard and refresh skills resolve model profiles from `.director/config.json` independently (onboard SKILL.md lines 199-206, refresh SKILL.md lines 68-75). The logic for "quality" profile override is duplicated.
- Files: `skills/onboard/SKILL.md` (lines 199-206), `skills/refresh/SKILL.md` (lines 68-75)
- Impact: If the model profile resolution rules change, two places must be updated. No centralizing factor prevents inconsistency.
- Fix approach: Document the model profile resolution rules once in a reference document that both skills link to. Or centralize via a shared utility pattern.
- Priority: **LOW** -- Currently straightforward logic, but DRY principle violated. Won't cause issues until the logic becomes more complex.

## Known Gaps

**Incomplete context staleness detection:**
- Issue: `reference/context-management.md` and `skills/refresh/SKILL.md` describe staleness detection as planned but not fully integrated. The refresh skill is designed to track `context_generation.generated_at` in config.json and alert users, but the criteria for "too old" are not defined.
- Files: `reference/context-management.md` (Design Notes section), `skills/onboard/SKILL.md` (Record Context Generation Metadata section), `skills/refresh/SKILL.md` (entire flow)
- Impact: Without clear staleness thresholds, users may not know when to refresh. The feature exists (metadata is recorded) but the trigger condition is not documented.
- Fix approach: Define explicit staleness thresholds in config.json (e.g., "refresh research if >30 days old" or "refresh codebase mapping if >N commits since last scan"). Build this check into the resume, status, and build skills to proactively suggest refresh.
- Priority: **MEDIUM** -- The infrastructure is in place but the rules are missing. Impacts user experience but doesn't break functionality.

**Limited error recovery for mapper/researcher failures:**
- Issue: If any of the 4 deep mapper or deep researcher agents fail (timeout, crash, out of memory), the system has a fallback (use v1.0 director-mapper as fallback in onboard; continue with partial results in refresh) but these fallbacks are not well-tested and may produce incomplete context.
- Files: `skills/onboard/SKILL.md` (line 288), `skills/refresh/SKILL.md` (line 150), `agents/director-deep-mapper.md` (entire agent -- 40 turn limit)
- Impact: If a deep mapper times out while analyzing a large codebase, the onboard experience degrades. The v1.0 fallback may miss important patterns. Users onboarding large projects may hit this failure mode.
- Fix approach: Implement graceful partial results -- if tech mapper succeeds but concerns mapper fails, still present the tech findings. Provide better timeout handling and add retry logic for critical mappers. Document which mappers are most critical (concerns mapper should never be skipped).
- Priority: **MEDIUM** -- Affects large projects more than small ones. Mitigation: add large codebase detection note to mapper instructions (already done).

## Fragile Areas

**Agent state sharing via git log and memory:**
- Issue: The builder agent uses `memory: project` to retain awareness of previous task patterns, but this memory is NOT explicitly cleared or reset between goals. If patterns established in Goal 1 are no longer valid in Goal 2 (e.g., tech stack changes), the builder's memory could cause it to follow stale patterns.
- Files: `agents/director-builder.md` (line 7: `memory: project`), `skills/build/SKILL.md` (Step 5 context assembly)
- Impact: Subtle bugs in later goals if earlier patterns are no longer applicable. The builder has no way to know when patterns have changed without explicit instructions in each task.
- Fix approach: Clarify in task context when patterns are changing. Add a "Context Changes" section to STEP.md (optional, like Decisions) that signals pattern shifts. Or disable builder memory and rely solely on codebase context files.
- Priority: **LOW** -- Memory is meant to improve consistency. The risk only manifests if patterns genuinely change between goals. Mitigated by explicit STEP.md content.

**Verification retry loop complexity:**
- Issue: The auto-fix retry loop in `skills/build/SKILL.md` (Steps 8c-8d) has three retry caps (2 for simple wiring, 3 for placeholders, 3-5 for complex) with no clear guideline for choosing the cap. The decision is marked "Claude's Discretion" which leaves room for inconsistent retry behavior.
- Files: `skills/build/SKILL.md` (lines 372-397), `agents/director-debugger.md` (referenced but not analyzed)
- Impact: Some issues may be retried too few times and given up on; others may be retried too many times wasting cost. Inconsistent user experience across different issue types.
- Fix approach: Define explicit retry caps as hard rules per issue category, not discretionary. Document in the build skill which cap applies to which issue type. Consider lowering max retries to 2 overall to control cost.
- Priority: **LOW** -- System works, but rules could be clearer. This is mainly a style concern.

**Git state assumptions in verification:**
- Issue: The verifier and build skill assume a clean git state (one new commit per task), but if the builder crashes mid-commit, staged files may exist. The cleanup check (Step 10g) should catch this, but there's no guard against git state corruption.
- Files: `skills/build/SKILL.md` (Step 6 uncommitted changes check, Step 8a commit verification), `agents/director-builder.md` (lines 45-80: git execution rules)
- Impact: If git operations fail silently or partially, the task might appear complete when it's not. Subsequent builds would then inherit corrupted state.
- Fix approach: Strengthen git operation verification. After `git commit`, check `git status` to confirm the commit succeeded. Before spawning syncer, verify that the working directory is clean.
- Priority: **LOW** -- Git operations are generally reliable. Risk is mainly in unusual environments or after system crashes.

## Security Considerations

**No explicit secret handling in codebase mapping:**
- Issue: The deep mapper agent reads source files to analyze patterns, but there's no explicit guard against accidentally including secret values (API keys, credentials, etc.) in the codebase analysis output.
- Files: `agents/director-deep-mapper.md` (Forbidden Files section, lines starting with "NEVER read or quote"), `skills/onboard/templates/codebase/*.md`
- Impact: If a developer has accidentally checked in a `.env` file or credentials file, the mapper could quote sensitive values in STACK.md or other analysis files. These files then become part of the project state tracked by Director and could be committed to git.
- Fix approach: Implement read-time filtering in the deep mapper to skip forbidden file patterns entirely and alert the user if secrets were detected. Add a pre-onboard check that scans for and warns about common secret files.
- Priority: **HIGH** -- Security risk, though mitigated by the instruction to never read `.env` files. However, the instruction is text-based and not enforced by the tool system. A developer could accidentally read a secrets file if they don't follow the rules.

**No encryption for .director/config.json:**
- Issue: `config.json` stores user settings including cost tracking and model profile preferences. If it includes sensitive config in future versions (API keys, custom settings), it has no encryption.
- Files: `skills/onboard/templates/config.json` (not analyzed but exists)
- Impact: Currently low risk since config is user-level settings. But if future versions store integration secrets here, they'd be in plaintext.
- Fix approach: Document that config.json should never contain secrets. If future versions need to store secrets, use encrypted config or environment variables.
- Priority: **LOW** -- Current risk is low. Preventive measure for future versions.

## Performance Bottlenecks

**Deep mapper token cost for large codebases:**
- Issue: The deep mapper is a Haiku model that reads source files directly. For very large codebases (1000+ files), a single mapper invocation could exhaust the context window before finishing analysis.
- Files: `agents/director-deep-mapper.md` (line 6: `model: inherit`), `skills/onboard/SKILL.md` (lines 197-198: sampling note for 500+ file codebases)
- Impact: Large codebases may not get mapped at all, or the mapping may be incomplete. Greenfield projects with existing large codebases won't benefit from codebase context.
- Fix approach: Increase the mapper's model to handle larger contexts (use Sonnet for large codebase mapping). Implement file sampling more aggressively -- read only a representative sample of large directories. Add a progress meter to show mapping completion.
- Priority: **MEDIUM** -- Not every codebase is large, but it's a known limitation for enterprise projects.

**Context budget calculation is approximate:**
- Issue: Token estimation uses character count / 4 as the approximation, but this is rough. The actual token count can vary significantly based on punctuation, whitespace, and token boundaries.
- Files: `reference/context-management.md` (Budget Threshold section, line 198: "rough estimate"), `skills/build/SKILL.md` (line 259: "estimate the total token count")
- Impact: Context may exceed the budget threshold by 10-20% without detection. If budget is tight, important context could be truncated unexpectedly.
- Fix approach: Use a more accurate token estimation method. Consider calling the API's tokenizer (if available) or using a refined estimation formula. Document the approximation error margin.
- Priority: **LOW** -- Current approximation is conservative and rarely causes problems. Refinement is a future improvement.

**Syncer updates STATE.md file for every task:**
- Issue: After every task, the syncer reads STATE.md, updates multiple sections (Current Position, Progress, Recent Activity, Decisions Log, Cost Summary), and writes it back. For long-running projects with many tasks, this file becomes large and updates become slower.
- Files: `agents/director-syncer.md` (Steps 2-7 all read/write STATE.md)
- Impact: Not a current bottleneck, but for projects with 100+ tasks, state updates could become noticeable. File grow unbounded with Recent Activity entries.
- Fix approach: Archive old STATE entries to a separate file after reaching a size threshold. Or split STATE.md into STATE-current.md and STATE-archive.md. Implement bounded Recent Activity (already capped at 10 entries, so this is mitigated).
- Priority: **LOW** -- Mitigated by the 10-entry cap on Recent Activity. Won't be an issue unless projects are very long-lived.

## Dependencies at Risk

**No explicit Python or Ruby support:**
- Issue: The deep mapper has samples for Python (`requirements.txt`, `pyproject.toml`) and Ruby (`Gemfile`) in its detection code, but there's no explicit testing noted for non-TypeScript projects.
- Files: `agents/director-deep-mapper.md` (Mapping Process section mentions `go.mod`, `Cargo.toml` but execution patterns focus on `.ts`/`.tsx`), `skills/onboard/SKILL.md` (Codebase Size Assessment uses generic file patterns)
- Impact: While the system should work for any language, Python and Ruby projects may have incomplete mapping if patterns aren't captured.
- Fix approach: Add explicit test cases for Python and Ruby projects during testing. Document any language-specific limitations in the mapper.
- Priority: **LOW** -- Not a technical debt issue, more of a test coverage gap. The system is designed to be language-agnostic.

**Claude Code version dependencies:**
- Issue: The plugin requires "Claude Code v1.0.33 or later" (from README.md line 25), but there's no version checking in the code itself. If a user has an older Claude Code version, the plugin may fail silently or with confusing errors.
- Files: `README.md` (lines 9, 25), `skills/onboard/SKILL.md` (line 11: init script reference), `.claude-plugin/plugin.json` (not analyzed)
- Impact: Older Claude Code versions would silently fail to run Director. Users would see cryptic errors about missing tools or malformed commands.
- Fix approach: Add a version check in the init script or in the first skill that runs (onboard). Display a clear error message if Claude Code is too old.
- Priority: **MEDIUM** -- User experience issue. Important for new users installing from marketplace.

## Missing Critical Features

**No offline mode:**
- Issue: The research pipeline requires WebFetch to look up documentation and best practices. Without internet access, research fails entirely (see `skills/onboard/SKILL.md` line 129 in README: "If WebFetch is unavailable").
- Files: `README.md` (lines 129-130), `skills/onboard/SKILL.md` (Research Pipeline section)
- Impact: Users without internet or in restricted networks cannot use the research features. The degradation is graceful (research is optional) but the feature is not available to them.
- Fix approach: Implement offline research mode that uses local knowledge or cached research templates. Or document how users can pre-download research and inject it.
- Priority: **LOW** -- Research is optional, and most Claude Code users have internet. Nice-to-have feature.

**No explicit rollback for partially completed goals:**
- Issue: If a user completes some steps of a goal but then wants to pivot, there's no built-in way to cleanly "revert to start of goal" across all completed steps. The `/director:undo` command only reverts the most recent task.
- Files: `skills/undo/SKILL.md` (not analyzed but exists), `skills/pivot/SKILL.md` (entire pivot flow)
- Impact: Pivoting mid-goal requires manually reviewing which tasks should be undone. For complex pivots, this is error-prone.
- Fix approach: Enhance pivot to offer "revert to goal start" option. Or implement goal-level undo.
- Priority: **LOW** -- Pivot is powerful enough for most use cases. Nice-to-have refinement.

## Quality Gate

- [x] Every finding includes at least one file path in backticks
- [x] Voice is prescriptive ("Use X", "Place files in Y") not descriptive
- [x] No section left empty -- all relevant sections populated
- [x] Fix approaches are specific enough to act on
- [x] Security section populated with appropriate concerns
- [x] Priorities assigned (HIGH, MEDIUM, LOW) based on severity and impact
