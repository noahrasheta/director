# Phase 5: Verification - Context

**Gathered:** 2026-02-08
**Status:** Ready for planning

<domain>
## Phase Boundary

Three-tier verification system that lets users trust what was built actually works. Tier 1 runs structural checks automatically after every task (invisible unless issues found). Tier 2 generates behavioral checklists at step boundaries. Auto-fix spawns debugger agents for issues found. On-demand `/director:inspect` triggers full verification. Progress tracking and status display are Phase 6 — this phase focuses on the verification mechanics themselves.

</domain>

<decisions>
## Implementation Decisions

### Issue reporting tone
- Confident assistant voice — direct and efficient, not casual or dramatic
- Detail level: what + why + where ("The settings page has placeholder content in the header section — users would see 'TODO' text")
- Group issues by severity: "Needs attention" (blocking) section and "Worth checking" (informational) section
- Only offer auto-fix for issues Director can actually handle (wiring, stubs, placeholder replacement). Report-only for things that need human judgment

### Behavioral checklist flow
- Trigger: step boundaries only — checklist runs when all tasks in a step are complete. Goal-level checks happen when all steps pass
- Presentation: full checklist shown upfront, user reports results in any order as they go
- No fixed checklist size — Claude sizes based on step complexity (small steps get fewer items)

### Auto-fix experience
- Progress updates during fix cycles: "Investigating the issue... Found the cause... Applying fix (attempt 1 of 3)..." Real-time status
- Always ask before fixing: "Found 2 issues. Want me to try fixing them?" User approves before attempts begin
- Retry cap: Claude decides per issue based on complexity — simple wiring gets fewer retries, deeper bugs get more

### Inspect command scope
- Smart default: `/director:inspect` checks current step
- Accepts arguments: `/director:inspect goal`, `/director:inspect all`
- On-demand — user controls when to run broader checks

### Celebration and progress feedback
- Combine outcome + progress: "User authentication is working! That's Step 2 done — 3 of 5 through your first goal."
- Goal completion is a bigger moment — summary of everything built, total progress, and what's next. Step completion gets a shorter note
- Partial passes lead with wins: "4 of 5 checks passed! One thing needs attention: [issue]."

### Claude's Discretion
- Checklist item count per step (based on step complexity)
- Retry count per issue (based on issue complexity)
- Auto-fix handoff messaging when giving up (explain what was tried, offer options — Claude picks based on situation)
- How behavioral checklist results are reported (Claude picks whatever feels most natural for Director)

</decisions>

<specifics>
## Specific Ideas

- Tier 1 should feel invisible when everything passes — zero noise on success, only surfaces when there's something worth mentioning
- The two-severity model ("Needs attention" / "Worth checking") already exists in the reference docs from Phase 1 (01-02) — verification should use the same language
- Fix offers should be scoped to what Director can handle — never offer to fix something and then fail because it was beyond scope

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 05-verification*
*Context gathered: 2026-02-08*
