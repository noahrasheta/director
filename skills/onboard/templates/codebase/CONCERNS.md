# Codebase Concerns

**Analysis Date:** [YYYY-MM-DD]

## Technical Debt

**_[Area/Component]_:**
- Issue: _[What's the shortcut/workaround]_
- Files: `[file paths]`
- Impact: _[What breaks or degrades]_
- Fix approach: _[How to address it]_
- Priority: _[HIGH/MEDIUM/LOW]_

**_[Area/Component]_:**
- Issue: _[What's the shortcut/workaround]_
- Files: `[file paths]`
- Impact: _[What breaks or degrades]_
- Fix approach: _[How to address it]_
- Priority: _[HIGH/MEDIUM/LOW]_

## Known Bugs

**_[Bug description]_:**
- Symptoms: _[What happens]_
- Files: `[file paths]`
- Trigger: _[How to reproduce]_
- Workaround: _[If any]_

## Security Considerations

**_[Area]_:**
- Risk: _[What could go wrong]_
- Files: `[file paths]`
- Current mitigation: _[What's in place]_
- Recommendations: _[What should be added]_

## Performance Bottlenecks

**_[Slow operation]_:**
- Problem: _[What's slow]_
- Files: `[file paths]`
- Cause: _[Why it's slow]_
- Improvement path: _[How to speed up]_

## Fragile Areas

**_[Component/Module]_:**
- Files: `[file paths]`
- Why fragile: _[What makes it break easily]_
- Safe modification approach: _[How to change safely]_
- Test coverage gaps: _[What's not tested]_

## Dependencies at Risk

**_[Package]_:**
- Risk: _[What's wrong -- e.g., deprecated, unmaintained, security vulnerability]_
- Impact: _[What breaks if this fails]_
- Migration plan: _[Alternative package or approach]_

## Missing Critical Features

**_[Feature gap]_:**
- What's missing: _[Specific functionality]_
- What it blocks: _[What can't be done without it]_

## Quality Gate

Before considering this file complete, verify:
- [ ] Every finding includes at least one file path in backticks
- [ ] Voice is prescriptive ("Use X", "Place files in Y") not descriptive ("X is used")
- [ ] No section left empty -- use "No concerns detected" or "Not applicable"
- [ ] Every concern has file paths
- [ ] Fix approaches are specific enough to act on
- [ ] Security section populated (even if "No concerns detected")
- [ ] Priorities assigned to technical debt items
