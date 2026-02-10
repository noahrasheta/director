# Coding Conventions

**Analysis Date:** [YYYY-MM-DD]

## Naming Patterns

**Files:**
- Use _[pattern]_ for files: `[example]`
- Use _[pattern]_ for test files: `[example]`

**Functions:**
- Use _[pattern]_ for function names: `[example]`
- Use _[pattern]_ for event handlers: `[example]`

**Variables:**
- Use _[pattern]_ for variables: `[example]`
- Use _[pattern]_ for constants: `[example]`

**Types:**
- Use _[pattern]_ for type names: `[example]`
- Use _[pattern]_ for interfaces: `[example]`

## Code Style

**Formatting:**
- Use _[tool]_ for formatting - Config: `[path]`
- Key settings: _[important formatting rules]_

**Linting:**
- Use _[tool]_ for linting - Config: `[path]`
- Key rules: _[important lint rules]_

## Import Organization

Use the following import order in all files. See `[example-file-path]` for reference.

**Order:**
1. _[First group -- e.g., external packages]_
2. _[Second group -- e.g., internal modules]_
3. _[Third group -- e.g., local files]_

**Path Aliases:**
- Use `[alias]` for `[path]` - Configured in `[config-path]`

## Error Handling

Use the following error handling patterns. See `[example-file-path]` for reference.

**Patterns:**
- Use _[pattern]_ for _[situation]_
- Use _[pattern]_ for _[situation]_

## Logging

**Framework:** _[Tool or "console"]_ - Configured in `[path]`

**Patterns:**
- Use _[approach]_ when _[situation]_
- Use _[approach]_ when _[situation]_

## Comments

**When to Comment:**
- Add comments when _[guideline]_
- Avoid comments when _[guideline]_

**JSDoc/TSDoc:**
- Use _[usage pattern]_ - See `[example-file-path]`

## Function Design

**Size:** Keep functions _[guideline]_ - See `[example-file-path]`

**Parameters:** Use _[pattern]_ for parameters - See `[example-file-path]`

**Return Values:** Use _[pattern]_ for return values - See `[example-file-path]`

## Module Design

**Exports:** Use _[pattern]_ for exports - See `[example-file-path]`

**Barrel Files:** _[Usage guideline]_ - See `[example-file-path]`

## Quality Gate

Before considering this file complete, verify:
- [ ] Every finding includes at least one file path in backticks
- [ ] Voice is prescriptive ("Use X", "Place files in Y") not descriptive ("X is used")
- [ ] No section left empty -- use "Not detected" or "Not applicable"
- [ ] Naming patterns include examples
- [ ] All conventions include file path examples
- [ ] Prescriptive voice throughout -- verified no instances of "uses" or "is used"
