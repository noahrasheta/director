# Architecture Research

**Analysis Date:** [YYYY-MM-DD]
**Confidence:** [HIGH/MEDIUM/LOW]

## Recommended Architecture

_What system structure works best for this type of project?_

### System Overview

```
[ASCII diagram showing major components and their relationships]
```

### Component Responsibilities

| Component | Responsibility | Typical Implementation |
|-----------|----------------|------------------------|
| _[name]_ | _[what it owns]_ | _[how it's usually built]_ |
| _[name]_ | _[what it owns]_ | _[how it's usually built]_ |
| _[name]_ | _[what it owns]_ | _[how it's usually built]_ |

## Suggested Project Structure

_How should files and folders be organized?_

```
src/
  [folder]/           # [purpose]
    [subfolder]/      # [purpose]
    [file]            # [purpose]
  [folder]/           # [purpose]
    [subfolder]/      # [purpose]
    [file]            # [purpose]
  [folder]/           # [purpose]
  [folder]/           # [purpose]
```

## Patterns That Work

_What architectural patterns are recommended for this domain?_

### Pattern: _[Pattern Name]_

**What:** _[description]_
**When to use:** _[conditions where this pattern applies]_
**Trade-offs:** _[pros and cons]_

```
[Code example showing the pattern]
```

### Pattern: _[Pattern Name]_

**What:** _[description]_
**When to use:** _[conditions where this pattern applies]_
**Trade-offs:** _[pros and cons]_

```
[Code example showing the pattern]
```

## Patterns to Avoid

_What approaches look reasonable but cause problems?_

### Anti-Pattern: _[Name]_

**What people do:** _[the mistake]_
**Why it causes problems:** _[the consequences]_
**Do this instead:** _[the correct approach]_

### Anti-Pattern: _[Name]_

**What people do:** _[the mistake]_
**Why it causes problems:** _[the consequences]_
**Do this instead:** _[the correct approach]_

## How Data Flows

_How does information move through the system?_

### Request Flow

```
[User Action]
    |
[Component] -> [Handler] -> [Service] -> [Data Store]
    |               |            |             |
[Response] <- [Transform] <- [Query] <- [Database]
```

### State Management

_How is application state handled?_

_[Description of state management approach and why it's recommended]_

## Scaling Notes

_How does this architecture hold up as the project grows?_

| Scale | Approach |
|-------|----------|
| _Small (early users)_ | _[approach -- usually keep it simple]_ |
| _Medium (growing usage)_ | _[what to optimize first]_ |
| _Large (significant traffic)_ | _[when to consider restructuring]_ |

## Sources

- _[Architecture references]_
- _[Official documentation]_
- _[Case studies]_

## Quality Gate

Before considering this file complete, verify:
- [ ] Architecture diagram or description present
- [ ] Component responsibilities clearly defined
- [ ] At least 2 patterns to follow and 2 to avoid
- [ ] Code examples included for recommended patterns
- [ ] Scaling notes are realistic for the project's expected size
- [ ] No section left empty -- use "Not applicable" if nothing found
