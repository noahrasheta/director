# Research Summary

**Project:** _[project name]_
**Analysis Date:** [YYYY-MM-DD]
**Confidence:** [HIGH/MEDIUM/LOW]

## Executive Summary

_[2-3 paragraph overview of research findings. This section should stand alone -- someone reading only this section should understand the key conclusions.]_

_[What type of product this is and how experts build it.]_

_[The recommended approach based on research and key risks to watch for.]_

## Key Findings

### Recommended Stack

_[Summary from STACK.md -- 1-2 paragraphs highlighting the most important technology choices and their rationale.]_

**Core technologies:**
- _[Technology]_: _[purpose]_ -- _[why recommended]_
- _[Technology]_: _[purpose]_ -- _[why recommended]_
- _[Technology]_: _[purpose]_ -- _[why recommended]_

### Expected Features

_[Summary from FEATURES.md]_

**Must-haves:**
- _[Feature]_ -- _[why users expect this]_
- _[Feature]_ -- _[why users expect this]_

**Nice-to-haves:**
- _[Feature]_ -- _[competitive advantage]_
- _[Feature]_ -- _[competitive advantage]_

**Defer for later:**
- _[Feature]_ -- _[not essential for launch]_

### Architecture Approach

_[Summary from ARCHITECTURE.md -- 1 paragraph describing the recommended system structure.]_

**Major components:**
1. _[Component]_ -- _[responsibility]_
2. _[Component]_ -- _[responsibility]_
3. _[Component]_ -- _[responsibility]_

### Critical Pitfalls

_[Top 3-5 from PITFALLS.md]_

1. **_[Pitfall]_** -- _[how to avoid]_
2. **_[Pitfall]_** -- _[how to avoid]_
3. **_[Pitfall]_** -- _[how to avoid]_

## Implications for Gameplan

_Based on research, the following goal/step structure is suggested._

### Suggested Structure

**Goal 1: _[Name]_**
- **Rationale:** _[why this comes first based on research]_
- **Delivers:** _[what this goal produces]_
- **Addresses:** _[features from FEATURES.md]_
- **Avoids:** _[pitfall from PITFALLS.md]_

**Goal 2: _[Name]_**
- **Rationale:** _[why this order]_
- **Delivers:** _[what this goal produces]_

_[Continue for suggested goals...]_

### Ordering Rationale

- _[Why this order based on what needs to come first]_
- _[Why this grouping based on architecture patterns]_
- _[How this avoids pitfalls from research]_

### Research Flags

_Areas likely needing deeper investigation during step planning:_
- **_[Area]_:** _[reason -- e.g., "complex integration, needs API research"]_
- **_[Area]_:** _[reason -- e.g., "niche domain, sparse documentation"]_

_Areas with standard patterns (minimal additional research needed):_
- **_[Area]_:** _[reason -- e.g., "well-documented, established patterns"]_

## Don't Hand-Roll

_Problems with existing library solutions. Building these from scratch wastes time and introduces bugs._

| Problem | Existing Solution | Why Not Build It |
|---------|-------------------|------------------|
| _[problem]_ | _[library or service]_ | _[risk of building from scratch]_ |
| _[problem]_ | _[library or service]_ | _[risk of building from scratch]_ |
| _[problem]_ | _[library or service]_ | _[risk of building from scratch]_ |

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | _[HIGH/MEDIUM/LOW]_ | _[reason]_ |
| Features | _[HIGH/MEDIUM/LOW]_ | _[reason]_ |
| Architecture | _[HIGH/MEDIUM/LOW]_ | _[reason]_ |
| Pitfalls | _[HIGH/MEDIUM/LOW]_ | _[reason]_ |

**Overall confidence:** _[HIGH/MEDIUM/LOW]_

## Gaps to Address

_Areas where research was inconclusive or needs validation during implementation._

- _[Gap]_: _[how to handle during planning or building]_
- _[Gap]_: _[how to handle during planning or building]_

## Sources

### Primary (HIGH confidence)
- _[Source]_ -- _[what was verified]_

### Secondary (MEDIUM confidence)
- _[Source]_ -- _[finding]_

### Tertiary (LOW confidence)
- _[Source]_ -- _[finding, needs validation]_

## Quality Gate

Before considering this file complete, verify:
- [ ] Executive summary can stand alone -- someone reading only this section understands the conclusions
- [ ] Key findings summarize, not duplicate, individual research files
- [ ] Gameplan implications include specific goal/step suggestions
- [ ] Don't Hand-Roll section has at least 3 entries
- [ ] Confidence assessment is honest about uncertainties
- [ ] All sections populated -- no placeholders remaining from researcher output
