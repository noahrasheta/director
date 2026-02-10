# Testing Patterns

**Analysis Date:** [YYYY-MM-DD]

## Test Framework

**Runner:**
- _[Framework]_ _[Version]_
- Config: `[config file path]`

**Assertion Library:**
- _[Library]_ - Used in `[example-test-path]`

**Run Commands:**
```bash
[command]              # Run all tests
[command]              # Watch mode
[command]              # Coverage
```

## Test File Organization

**Location:**
- Place test files _[pattern: co-located or separate]_ - See `[path]`

**Naming:**
- Use _[pattern]_ for test files: `[example]`

**Directory Structure:**
```
[directory pattern showing where tests live]
```

## Test Structure

**Suite Organization:**

Follow this pattern when writing new tests. See `[example-test-path]` for reference.

```
[Code example showing the actual test suite pattern from the codebase]
```

**Patterns:**
- Use _[setup pattern]_ for test setup
- Use _[teardown pattern]_ for teardown
- Use _[assertion pattern]_ for assertions

## Mocking

**Framework:** _[Tool]_ - See `[example-test-path]`

**Patterns:**

Follow this mocking pattern. See `[example-test-path]` for reference.

```
[Code example showing the actual mocking pattern from the codebase]
```

**What to Mock:**
- _[Guidelines for what should be mocked]_

**What NOT to Mock:**
- _[Guidelines for what should NOT be mocked]_

## Fixtures and Test Data

**Pattern:**

Follow this pattern for test data. See `[example-path]` for reference.

```
[Code example showing test data pattern from the codebase]
```

**Location:**
- Place test fixtures in `[path]`

## Coverage

**Requirements:** _[Target or "None enforced"]_

**View Coverage:**
```bash
[command]
```

## Test Types

**Unit Tests:**
- Scope: _[What unit tests cover]_
- Approach: _[How to write them]_ - See `[path]`

**Integration Tests:**
- Scope: _[What integration tests cover]_
- Approach: _[How to write them]_ - See `[path]`

**E2E Tests:**
- _[Framework or "Not used"]_ - See `[path]`

## Common Patterns

**Async Testing:**

Use this pattern for async tests. See `[example-test-path]` for reference.

```
[Code example showing async test pattern]
```

**Error Testing:**

Use this pattern to test error cases. See `[example-test-path]` for reference.

```
[Code example showing error test pattern]
```

## Quality Gate

Before considering this file complete, verify:
- [ ] Every finding includes at least one file path in backticks
- [ ] Voice is prescriptive ("Use X", "Place files in Y") not descriptive ("X is used")
- [ ] No section left empty -- use "Not detected" or "Not applicable"
- [ ] Run commands verified and included
- [ ] Code examples show actual patterns from the codebase
- [ ] Mocking guidelines present
- [ ] Test file location documented
