# Architecture

**Analysis Date:** [YYYY-MM-DD]

## Pattern Overview

**Overall:** _[Pattern name -- e.g., "Layered MVC", "Feature-based modules", "Plugin architecture"]_

**Key Characteristics:**
- _[Characteristic]_ - See `[path]`
- _[Characteristic]_ - See `[path]`
- _[Characteristic]_ - See `[path]`

## Layers

**_[Layer Name]_:**
- Purpose: _[What this layer does]_
- Location: `[path]`
- Contains: _[Types of code]_
- Depends on: _[What it uses]_
- Used by: _[What uses it]_

**_[Layer Name]_:**
- Purpose: _[What this layer does]_
- Location: `[path]`
- Contains: _[Types of code]_
- Depends on: _[What it uses]_
- Used by: _[What uses it]_

**_[Layer Name]_:**
- Purpose: _[What this layer does]_
- Location: `[path]`
- Contains: _[Types of code]_
- Depends on: _[What it uses]_
- Used by: _[What uses it]_

## Data Flow

**_[Flow Name]_:**

1. _[Step 1]_ - `[path]`
2. _[Step 2]_ - `[path]`
3. _[Step 3]_ - `[path]`

**State Management:**
- Follow the _[approach]_ pattern in `[path]`
- Place state logic in `[path]`

## Key Abstractions

**_[Abstraction Name]_:**
- Purpose: _[What it represents]_
- Examples: `[file path]`, `[file path]`
- Pattern: _[Pattern used]_
- Follow this pattern when creating new instances

**_[Abstraction Name]_:**
- Purpose: _[What it represents]_
- Examples: `[file path]`, `[file path]`
- Pattern: _[Pattern used]_
- Follow this pattern when creating new instances

## Entry Points

**_[Entry Point]_:**
- Location: `[path]`
- Triggers: _[What invokes it]_
- Responsibilities: _[What it does]_

**_[Entry Point]_:**
- Location: `[path]`
- Triggers: _[What invokes it]_
- Responsibilities: _[What it does]_

## Error Handling

**Strategy:** _[Approach]_ - Defined in `[path]`

**Patterns:**
- Use _[pattern]_ for _[situation]_ - See `[path]`
- Use _[pattern]_ for _[situation]_ - See `[path]`

## Cross-Cutting Concerns

**Logging:** Use _[approach]_ - See `[path]`
**Validation:** Use _[approach]_ - See `[path]`
**Authentication:** Use _[approach]_ - See `[path]`

## Quality Gate

Before considering this file complete, verify:
- [ ] Every finding includes at least one file path in backticks
- [ ] Voice is prescriptive ("Use X", "Place files in Y") not descriptive ("X is used")
- [ ] No section left empty -- use "Not detected" or "Not applicable"
- [ ] Layers documented with file paths
- [ ] Data flow described with file references
- [ ] Entry points listed with paths
