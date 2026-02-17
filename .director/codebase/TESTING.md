# Testing Patterns

**Analysis Date:** 2026-02-16

## Test Framework

**Framework:** Not detected

**Note:** Director is a Claude Code plugin built entirely in Markdown. It does not contain compiled source code, unit tests, or traditional test frameworks. Testing follows Director's own three-tier verification strategy described in `CLAUDE.md`.

---

## Testing Philosophy: Three-Tier Verification

Director's verification approach is defined in `CLAUDE.md` and `reference/verification-patterns.md`. Rather than traditional test frameworks, Director uses three tiers:

### Tier 1: Structural Verification (Automated, AI-based)

**When it runs:** After every task completion

**Who runs it:** The `director:director-verifier` sub-agent (see `agents/director-verifier.md`)

**What it checks:**
- **Stub detection** -- Code is complete, not placeholder
- **Orphan detection** -- All created files are connected to the codebase
- **Wiring verification** -- All imports, references, and connections are valid

**Detection patterns:** See `reference/verification-patterns.md`

**Stub markers to flag:**
- `TODO`, `FIXME`, `HACK`, `XXX`, `PLACEHOLDER` comments
- Functions returning static values where dynamic behavior is expected
- Empty function bodies (`function foo() {}`)
- Functions with only `pass` statements or `throw new Error("not implemented")`
- Placeholder text ("Coming soon", "Under construction", Lorem ipsum)
- Hardcoded test data in production code
- Mock API responses instead of real data
- `console.log` / `console.debug` / `debugger` statements used for debugging
- Commented-out code blocks longer than 5 lines

See `agents/director-verifier.md` for complete Stub Detection section.

**Orphan detection:**
- Components defined but never imported or rendered
- API routes defined but never called by client code
- Utility functions exported but never imported
- Style files not imported by any component
- Files referenced in framework configuration are exceptions (entry points, test files, configured routes)

See `agents/director-verifier.md` for complete Orphan Detection section.

**Wiring checks:**
- All imports reference existing files with correct paths
- All framework hooks are properly registered
- Configuration files reference correct paths
- Environment variables are documented (if used)

See `agents/director-verifier.md` for complete Wiring Verification section.

**Run Process:**
1. Builder completes task and commits code
2. Builder spawns `director:director-verifier` sub-agent
3. Verifier reads task description and checks scope files
4. Verifier reports issues as "needs attention" or "worth checking"
5. Builder fixes issues and re-runs verification
6. Builder reports verification status to build skill

See `agents/director-builder.md` for builder's verification workflow.

### Tier 2: Behavioral Verification (Manual, User-Confirmed)

**When it runs:** At step/goal boundaries (when user is asked "Is this step complete?")

**Who runs it:** The user, guided by the `director:director-verifier` agent

**What it checks:**
- Does the feature actually work as described in the vision?
- Can a real user do what the goal promised?
- Are there edge cases or error scenarios not handled?

**Format:** Plain-language checklist for the user to confirm. Example from `reference/verification-patterns.md`:
- "Can users log in with valid credentials?"
- "Does login show an error for invalid passwords?"
- "Are user sessions preserved across page reloads?"

See `reference/verification-patterns.md` for Tier 2 patterns.

### Tier 3: Automated Test Frameworks (Optional)

**Status:** Optional, Phase 2

**What it means:** If the project has Jest, Vitest, pytest, or another test framework set up, Director will integrate with it. Director never requires a test framework but will use one if you have it.

**Integration approach:**
- Builder agent can run test commands if framework is detected
- Test results flow into verification reports
- Coverage reports are available if configured

**Not currently used in Director itself.**

---

## Verification Sub-Agent

**Agent File:** `agents/director-verifier.md`

**Tools Available:**
- Read -- examine code files
- Grep -- search for patterns
- Glob -- find files by pattern
- Bash -- run shell commands
- No write/edit capability (read-only)

**Spawned By:** Builder agent after task completion

**Input Context:**
- `<task>` -- The task description (what was supposed to be built)
- `<instructions>` -- Specific things to check or constraints

**Output Format:**

Verification status line followed by issue details:

**Clean verification:**
```
Verification: clean
```

**With issues found and fixed:**
```
Verification: 3 issues found, all fixed
```

**With remaining issues:**
```
Verification: 4 issues found, 2 fixed, 2 remaining
- Needs attention: [plain-language description], location: [file:line]
- Worth checking: [plain-language description], location: [file:line]
```

See `agents/director-verifier.md` for complete output format.

---

## Code Quality Checks

Since Director is a Markdown-based plugin, "code quality" refers to:

### Markdown Quality

**In Agent Files** (`agents/director-*.md`):
- Valid YAML frontmatter at the top
- Proper heading hierarchy (`#` > `##` > `###`)
- Consistent formatting with backticks for paths and commands
- Code examples are properly formatted in triple-backtick blocks
- No broken links to referenced documents

See `agents/director-builder.md`, `agents/director-deep-mapper.md` for examples.

### Documentation Quality

**In Reference Documents** (`reference/*.md`):
- Clear, prescriptive guidance (not descriptive)
- Every convention example includes file paths
- Plain language suitable for vibe coders
- Proper attribution to `reference/terminology.md` and `reference/plain-language-guide.md`

See `reference/terminology.md`, `reference/plain-language-guide.md`, `reference/verification-patterns.md`.

### Configuration Quality

**In JSON Files** (`.claude-plugin/plugin.json`, `hooks/hooks.json`):
- Valid JSON syntax
- All required fields present
- Consistent key naming (camelCase)
- Correct file path references

See `.claude-plugin/plugin.json`, `hooks/hooks.json`.

---

## Verification Patterns Reference

**Primary Reference:** `reference/verification-patterns.md`

This document defines all verification patterns the verifier agent uses:

1. **Stub Detection Patterns** -- Comment markers, hardcoded returns, empty bodies, placeholder UI, mock responses, debugging artifacts
2. **Orphan Detection Patterns** -- Unconnected components, routes, utilities, styles
3. **Wiring Verification** -- Import validation, configuration accuracy, environment variable documentation

Every builder task completion is checked against these patterns.

---

## Verification Workflow

**In Build Process:**

1. Builder reads task requirements and writes implementation
2. Builder creates git commit with task changes
3. Builder spawns `director:director-verifier` sub-agent
4. Verifier checks for stubs, orphans, wiring issues
5. If issues marked "needs attention" are found:
   - Builder fixes issues in code
   - Builder updates git commit (`git add -A && git commit --amend --no-edit`)
   - Builder re-spawns verifier
   - Repeat until all "needs attention" issues are resolved
6. Verifier confirms clean or reports remaining "worth checking" issues
7. Builder reports verification status to build skill
8. Build skill displays status to user

See `agents/director-builder.md` for complete builder workflow.

**In Verification Task:**

When user runs `/director:inspect` (goal-backward verification):

1. `director:director-verifier` agent is invoked with the goal description
2. Verifier examines all files created in that goal
3. Verifier checks against the goal's acceptance criteria (not just task completion)
4. Verifier provides a checklist for the user to confirm behavior
5. User confirms whether goal is actually achieved

See `skills/inspect/SKILL.md` for inspect command workflow.

---

## Key Verification Files

| File | Purpose |
|---|---|
| `agents/director-verifier.md` | Verifier agent logic, Tier 1 verification patterns |
| `reference/verification-patterns.md` | Detailed stub, orphan, and wiring detection patterns |
| `CLAUDE.md` | Three-tier verification strategy overview |
| `agents/director-builder.md` | Builder's use of verifier sub-agent |
| `skills/inspect/SKILL.md` | Goal-level verification workflow |

See these files for complete verification documentation.

---

## No Traditional Tests

**Note on Testing:** This codebase contains no Jest, Vitest, pytest, or similar test frameworks. Director uses structural verification (Tier 1) and behavioral verification (Tier 2) instead.

**Why:** Director is a prompt-based orchestration framework. Its core logic lives in:
- Agent behavior (specified in `agents/` .md files)
- Skill workflows (specified in `skills/*/SKILL.md` files)
- Hooks and configuration (specified in `hooks/` and `.claude-plugin/`)

Testing these components requires:
- Actually running the commands in Claude Code (Tier 2 behavioral verification)
- Inspecting the resulting documentation and codebase changes (Tier 1 structural verification)

Traditional unit tests would not add value because the system's correctness depends on:
1. Whether the Vision and Gameplan documents are accurate and complete
2. Whether the generated code compiles and connects properly
3. Whether users can actually use what was built

These are verified through the three-tier strategy, not unit tests.

---

## Quality Gate

Verify before considering testing complete:
- [x] Every verification pattern includes file references
- [x] Voice is prescriptive ("Use pattern X", "Check for Y") not descriptive
- [x] Three-tier strategy fully documented with references
- [x] Verifier agent documented with input/output format
- [x] Verification workflow documented for both build and inspect processes
- [x] No empty sections
- [x] All key files referenced with paths in backticks
