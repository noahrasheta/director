# Step Research: [Step Name]

**Researched:** [YYYY-MM-DD]
**Step:** [step name from STEP.md]
**Domain:** [primary technology/problem domain]
**Confidence:** [HIGH/MEDIUM/LOW]

## Reuse Metadata

_This section is used by the smart reuse check to determine if re-research is warranted. Populate all fields._

- **Step scope:** _[What this step delivers -- summarize from step context]_
- **Locked decisions:** _[List locked decisions that guided this research]_
- **Flexible decisions:** _[List flexible areas where comparative recommendations were made]_
- **Onboarding research used:** _[Yes/No -- if yes, which sections were referenced]_
- **Inputs checksum:** _[Hash of step context + decisions string for change detection]_

## User Decisions

### Locked (researched deeply)

_Each locked decision gets deep investigation findings. For every technology or approach the user committed to, research it thoroughly -- how to set it up, best practices, configuration, and integration with other locked choices._

- _[Decision]: [deep findings about this choice -- setup, best practices, configuration, integration patterns]_

### Flexible (comparative recommendations)

_For each area where the user has no preference or left it to Claude's discretion, rank 2-3 options with tradeoffs. Be opinionated -- recommend one, then explain alternatives._

- _[Area]: Recommend [option] because [reason]. Alternatives: [option 2] ([tradeoff]), [option 3] ([tradeoff])_

### Deferred (not researched)

_List items explicitly out of scope per user decisions. Do NOT investigate these._

- _[Item]: out of scope per user decision_

## Recommended Approach

_2-3 paragraphs summarizing what to build and how. The standard approach for this domain, informed by locked decisions and recommended choices for flexible areas. This section gives the planner a cohesive picture before diving into details._

_Cover: the overall pattern or architecture to follow, which libraries work together and how, and any sequencing considerations (what to build first)._

## Stack for This Step

_Libraries and tools specific to this step's work. Only include what this step actually needs -- not the full project stack._

| Library/Tool | Version | Purpose | Why |
|--------------|---------|---------|-----|
| _[name]_ | _[version]_ | _[what it does in this step]_ | _[rationale specific to this step's needs]_ |
| _[name]_ | _[version]_ | _[what it does in this step]_ | _[rationale specific to this step's needs]_ |

## Architecture Patterns

_Patterns relevant to this step's deliverables. Include one subsection per pattern._

### [Pattern Name]

**What:** _[Description of the pattern]_
**When:** _[Conditions where this pattern applies]_
**Example:**
```[language]
[code demonstrating the pattern]
```

## Don't Hand-Roll

_Problems where existing solutions should be used instead of building from scratch. This section is ALWAYS present -- populate it for each relevant locked decision, or use the fallback text if no risks apply._

| Problem | Existing Solution | Why Not Build It |
|---------|-------------------|------------------|
| _[problem that looks simple but has edge cases]_ | _[library or service that handles it]_ | _[hidden complexity, edge cases, maintenance burden]_ |

_No hand-roll risks identified for this step._

## Pitfalls

_Common mistakes and problems when building what this step delivers. Include one subsection per pitfall._

### [Pitfall Name]

**What goes wrong:** _[Description of the failure mode]_
**How to avoid:** _[Specific prevention strategy or pattern to follow]_

## Code Examples

_Include when they would genuinely help the planner or builder understand a non-obvious integration or pattern. Skip when the approach is obvious._

### [Operation]

```[language]
[code example]
```

## Conflicts with User Decisions

_If research reveals meaningful conflicts with user decisions (deprecation, security vulnerability, incompatibility, major pitfall without mitigation), document them here. Stylistic preferences and minor version differences are NOT conflicts._

| Decision | Conflict | Severity | Recommendation |
|----------|----------|----------|---------------|
| _[user decision]_ | _[what was found]_ | _[HIGH/MEDIUM]_ | _[suggested resolution]_ |

_No conflicts detected._

## Quality Gate

Before considering this file complete, verify:
- [ ] Every locked decision has deep investigation findings
- [ ] Every flexible area has 2-3 ranked options with tradeoffs
- [ ] Deferred items are listed but NOT researched
- [ ] Don't Hand-Roll section present (populated or explicitly empty)
- [ ] Conflicts section present (populated or explicitly "No conflicts")
- [ ] Reuse Metadata section has all fields populated
- [ ] Confidence level reflects actual source quality
