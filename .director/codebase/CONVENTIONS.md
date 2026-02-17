# Coding Conventions

**Analysis Date:** 2026-02-16

## Document Format

**Primary Format:** Markdown with YAML frontmatter
- All agent, skill, and reference documents use `.md` files
- Use YAML frontmatter in agent files (wrapped in `---`) to define metadata
- Headers use standard Markdown heading syntax (`#`, `##`, `###`)

**Example Format:** See `agents/director-builder.md`, `agents/director-deep-mapper.md`

## File Naming Patterns

**Agent Files:**
- Use `director-[agent-name].md` format in `agents/` directory
- Names are descriptive and match the agent's role: `director-builder.md`, `director-verifier.md`, `director-deep-mapper.md`
- See `agents/` directory for reference

**Skill Files:**
- Use `SKILL.md` as the primary skill documentation file
- Place in skill-specific directories under `skills/[skill-name]/`
- Example: `skills/onboard/SKILL.md`, `skills/build/SKILL.md`
- See `skills/onboard/SKILL.md`

**Template Files:**
- Use descriptive names matching their purpose
- Example: `vision-template.md`, `brainstorm-session.md`
- Store in `skills/[skill-name]/templates/`
- See `skills/onboard/templates/`

**Documentation Files:**
- Use SCREAMING_SNAKE_CASE for key documents: `VISION.md`, `GAMEPLAN.md`, `STATE.md`, `IDEAS.md`
- Use descriptive kebab-case for research and design documents: `research-competitive-analysis.md`, `research-opus-46-strategy.md`
- Store in appropriate directories: `.director/` for project state, `docs/design/` for design documents, `reference/` for reference material
- See `docs/design/` and `reference/` directories

**Configuration Files:**
- Use `.json` extension for JSON configuration
- Example: `hooks.json`, `config.json`, `plugin.json`, `marketplace.json`
- See `hooks/hooks.json`, `.claude-plugin/plugin.json`

## Naming Conventions

**Agent/Skill Names:**
- Use kebab-case with descriptive names
- Follow the pattern: `director-[function-name]`
- Examples: `director-builder`, `director-verifier`, `director-syncer`, `director-deep-mapper`
- See `agents/` directory

**Section Headers:**
- Use title case with clear hierarchy
- Top-level: `# Title`
- Section: `## Section Name`
- Subsection: `### Subsection Name`
- Use descriptive headers that indicate content
- Examples from `agents/director-builder.md`: "Context You Receive", "Execution Rules", "Sub-Agents"

**Configuration Keys:**
- Use camelCase in JSON files for JavaScript-like consistency
- Example from `hooks/hooks.json`: `SessionStart`, `SessionEnd`, `type`, `command`, `timeout`
- Example from `.claude-plugin/plugin.json`: `name`, `description`, `version`, `author`, `homepage`, `repository`, `license`, `keywords`

## Code Style

**Formatting:**
- Use standard Markdown for all prose
- Wrap commands and file paths in backticks: `` `filename.md` ``, `` `/director:command` ``
- Use code blocks for examples with triple backticks:
  ```
  /director:onboard
  /director:build
  ```
- See examples in `skills/build/SKILL.md`, `CLAUDE.md`

**Indentation:**
- Use 2-space indentation for nested YAML in agent frontmatter
- Use 4-space indentation for code blocks and examples
- Use 2-space indentation for nested Markdown lists
- See `agents/director-builder.md` for YAML examples

**Line Length:**
- No strict enforcement, but keep lines readable (roughly 80-100 characters)
- Table cells may exceed this when necessary
- See `CLAUDE.md` and `docs/design/PRD.md` for examples

## Content Organization

**Agent File Structure:**
Follow this pattern from `agents/director-builder.md`:

1. YAML frontmatter block (name, description, tools, model, maxTurns, optional: memory)
2. Main heading and intro paragraph
3. "Context You Receive" section explaining input parameters
4. Core sections explaining agent responsibilities
5. Sub-agents section (if applicable)
6. Git Rules section (if agent modifies code)
7. Output section describing what the agent returns

See `agents/director-builder.md` for complete example.

**Skill File Structure:**
Follow the pattern from `skills/build/SKILL.md` and `skills/onboard/SKILL.md`:

1. YAML frontmatter with name and description
2. Introduction and any setup instructions
3. Numbered or bulleted workflow steps
4. Detailed explanations for key concepts
5. Output and confirmation format

**Reference Document Structure:**
Follow patterns from `reference/terminology.md` and `reference/plain-language-guide.md`:

1. Document title with purpose
2. Core principles or rules at the top
3. Organized sections with clear headers
4. Examples and counter-examples where applicable
5. Reference tables for quick lookup

See `reference/terminology.md`, `reference/plain-language-guide.md`

## Terminology and Language

**Director Vocabulary:**
Use the canonical Director terms from `reference/terminology.md`:
- **Project** (not repository, codebase, repo)
- **Goal** (not milestone, epic, version, release)
- **Step** (not phase, sprint, module)
- **Task** (not ticket, issue, story)
- **Action** (not sub-task, workflow step - used internally, hidden from users)
- **Vision** (not spec, PRD, requirements)
- **Gameplan** (not roadmap, backlog, workflow)
- **Launch** (not deploy, release, ship)
- **New project** (not greenfield)
- **Existing project** (not brownfield)
- **"Needs X first"** (not "has dependency on", "blocked by")
- **"Progress saved"** (not committed, pushed)
- **"Going back"** (not reverted, rolled back)

See `reference/terminology.md` for complete reference.

**Plain Language Rules:**
Follow all rules from `reference/plain-language-guide.md`:
- Explain outcomes, not mechanisms
- Use conversational tone
- When routing to another command, explain WHY then suggest
- Never blame the user
- Celebrate progress naturally
- Frame errors as collaborative next steps

See `reference/plain-language-guide.md` for complete style guide.

**Forbidden Jargon in User-Facing Output:**
Never use these terms in messages users will see:
- `dependency`, `artifact`, `integration`, `prerequisite`, `blocker`, `worktree`, `CI/CD`, `pipeline`, `deployment pipeline`, `build step`, `compile`, `transpile`, `lint`, `minify`
- `repository`, `branch`, `merge`, `commit`, `SHA`, `hash`, `diff`, `rebase`, `revert`, `rollback`, `reset`, `pull request`, `staging area`, `working tree`, `HEAD`, `checkout`
- `schema`, `migration`, `endpoint`, `route`, `middleware`, `ORM`, `query`, `mutation`, `resolver`, `microservice`, `monolith`, `payload`, `serialization`, `runtime`, `stack trace`, `exception`
- `container`, `orchestration` (in DevOps sense), `load balancer`, `reverse proxy`, `CDN`, `SSL certificate`, `DNS record`

See `reference/terminology.md` for full list and explanation.

## XML Boundary Tags

Use XML-style boundary tags to wrap context sections when passing data between agents:
- `<vision>` for Vision document content
- `<task>` for task descriptions
- `<instructions>` for agent-specific instructions
- `<current_step>` for current step context
- `<recent_changes>` for git history
- `<decisions>` for user decision records
- `<project_state>` for STATE.md content
- `<changes>` for git diff summaries
- `<cost_data>` for token cost information

See `agents/director-builder.md`, `agents/director-deep-mapper.md` for usage examples.

## Comments and Documentation

**When to Comment:**
- Add comments when explaining why a decision was made (not just what the code does)
- Add comments when documenting context that's not obvious from the text
- Use comments to explain complex logic or unexpected behavior
- Example from `reference/verification-patterns.md`: Comments explaining verification categories

**JSDoc/TSDoc:**
Not applicable - this project does not contain TypeScript/JavaScript source code. The codebase is entirely Markdown-based documentation and configuration.

**Metadata in Headers:**
Use YAML frontmatter in agent files to document:
- `name` -- Agent identifier
- `description` -- What the agent does
- `tools` -- Available tools (Read, Write, Edit, Bash, Grep, Glob, Task)
- `disallowedTools` -- Tools the agent cannot use
- `model` -- Claude model version (`inherit`, `haiku`, or specific model)
- `maxTurns` -- Maximum conversation turns
- `memory` -- Optional memory type (`project` for project-level memory)

See `agents/director-builder.md` for complete example.

## Examples and Code Blocks

**Shell Commands:**
Wrap in triple backticks with `bash` language specifier:
```bash
/director:onboard
/director:build
```

**Directory Trees:**
Show with indentation and ASCII formatting:
```
.director/
  VISION.md
  GAMEPLAN.md
  goals/
    01-mvp/
      GOAL.md
      01-foundation/
        STEP.md
```

**Tables:**
Use standard Markdown table format with alignment:
```
| Column 1 | Column 2 | Column 3 |
|---|---|---|
| Data | Data | Data |
```

See `CLAUDE.md`, `docs/design/PRD.md` for examples.

## File Paths in Output

**CRITICAL: Every finding must reference actual file paths in backticks.**

Use backticks to wrap file paths:
- Relative from project root: `` `agents/director-builder.md` ``
- Within directories: `` `skills/onboard/SKILL.md` ``
- Configuration files: `` `hooks/hooks.json` ``
- Template files: `` `skills/onboard/templates/vision-template.md` ``

Never reference files without paths. Provide exact locations for downstream agents.

See all agent files for consistent examples.

## Import/Reference Organization

**Link Format:**
- Use relative Markdown links: `[text](path/to/file.md)`
- Reference specific sections with anchors when applicable
- Keep links to actual project files, not external resources
- Examples from `agents/director-builder.md`: References to `reference/verification-patterns.md`, `reference/context-management.md`

**Internal Cross-References:**
- Reference documentation that explains a concept, then provide the guidance
- Example: Reference `reference/terminology.md` when using Director vocabulary, then explicitly state the terms to use
- See how `agents/director-verifier.md` references `reference/verification-patterns.md`

## Quality Gate

Verify before considering conventions complete:
- [x] Every convention includes at least one file path in backticks
- [x] Voice is prescriptive ("Use X pattern", "Place files in Y") not descriptive ("X pattern is used")
- [x] No section left empty
- [x] All conventions include file examples
- [x] File naming patterns documented with examples
- [x] Content organization patterns documented with references
- [x] Prescriptive voice throughout - no instances of "uses" or "is used"
