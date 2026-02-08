# Verification Patterns Reference

This document defines the patterns the verifier agent uses to detect issues in the codebase after each task. These patterns power Director's Tier 1 (structural) verification -- automated checks that run without any test framework.

## Overview

Structural verification answers: "Is the code complete and properly connected?" It does not check behavior (that's Tier 2 -- user checklists) or run tests (that's Tier 3 -- optional test frameworks).

Three categories of issues are checked:
1. **Stubs** -- Placeholder code that was never finished
2. **Orphans** -- Code that exists but isn't connected to anything
3. **Wiring** -- Connections between parts of the codebase that are broken or missing

---

## Stub Detection Patterns

Stubs are incomplete code left behind during development. They indicate a task was not fully finished.

### Comment Markers

Look for comments that signal unfinished work:

- `TODO` -- Planned but not done
- `FIXME` -- Known broken, not yet fixed
- `HACK` -- Temporary workaround in place
- `XXX` -- Needs attention
- `PLACEHOLDER` -- Explicitly temporary

**Detection:** Search for these markers in all project source files. Ignore matches inside `node_modules/`, `.git/`, vendor directories, and third-party code.

### Hardcoded Return Values

Functions that return static values where dynamic behavior is expected:

- `return []` or `return {}` in data-fetching functions
- `return "placeholder"` or `return "TODO"`
- `return null` in functions that should return data
- `return true` or `return false` in validation functions (always passes/fails)

**Detection:** Identify functions whose names suggest dynamic behavior (fetch, get, load, validate, calculate, check) and inspect their return statements.

### Empty Function Bodies

- Empty function/method bodies: `function foo() {}`
- Python `pass` statements in functions that should have logic
- `// not implemented` or `# not implemented` comments
- `throw new Error("not implemented")` or `raise NotImplementedError`
- `console.log("TODO")` as a placeholder

**Detection:** Look for function declarations where the body contains only comments, pass statements, or throw/raise statements.

### Placeholder UI Content

- Components rendering only "Coming soon" or "Under construction"
- Lorem ipsum text in production components
- Hardcoded sample data in UI (e.g., "John Doe", "test@example.com")
- Image placeholders (`placeholder.png`, `via.placeholder.com`)

**Detection:** Search component render functions for common placeholder strings.

### Mock/Static API Responses

- API route handlers returning hardcoded JSON
- `setTimeout` used to simulate async behavior
- Static arrays or objects where database queries should be
- Commented-out actual implementation with mock data active

**Detection:** Check route handler files for static data returns instead of database or service calls.

### Debugging Artifacts

- `console.log` / `console.debug` / `print()` statements left as debugging output
- `debugger` statements
- Commented-out code blocks (more than 5 lines suggests abandoned code)

**Detection:** Search for common debug output statements. Distinguish intentional logging (structured, with context) from debug artifacts (bare variable dumps).

---

## Orphan Detection Patterns

Orphans are code that exists but is not connected to the rest of the application. They indicate something was created but never integrated, or was disconnected during refactoring.

### Orphaned Files

Files that exist but are never imported or required by any other file in the project.

**Detection method:**
1. For each source file, extract its export names (default export, named exports)
2. Search the rest of the codebase for imports of those names or the file path
3. If no other file imports it, the file is orphaned

**Exceptions (not orphans):**
- Entry points (`index.ts`, `main.ts`, `app.ts`, etc.)
- Configuration files (`tsconfig.json`, `tailwind.config.js`, etc.)
- Test files (they import from source, not the other way)
- Files referenced in configuration (e.g., route files listed in framework config)

### Orphaned Components

Components defined but never rendered in any parent component.

**Detection method:**
1. Identify all component definitions (React: function/class components, Vue: SFC files, etc.)
2. Search for JSX/template usage of each component name
3. If a component is never rendered, it's orphaned

### Orphaned API Routes

API routes defined but never called from client code.

**Detection method:**
1. Identify all route definitions (file-based routing paths, explicit route registrations)
2. Search client code for fetch/axios/HTTP calls matching those routes
3. If no client code calls a route, it may be orphaned

**Note:** Some routes are called externally (webhooks, third-party callbacks). Flag these as "worth checking" rather than "needs attention."

### Orphaned Utilities

Utility functions exported but never imported anywhere.

**Detection method:**
1. Find all exported functions in utility/helper files
2. Search the codebase for imports of each function name
3. If never imported, flag as orphaned

### Orphaned Styles

CSS/style files that aren't imported by any component or page.

**Detection method:**
1. Find all CSS/SCSS/style module files
2. Search for import/require statements referencing those files
3. If no component imports a style file, it's orphaned

---

## Wiring Verification Patterns

Wiring checks confirm that different parts of the codebase are properly connected -- imports resolve, URLs match, references point to real things.

### Import/Export Matching

Verify that component imports match actual file exports.

**Checks:**
- Import paths resolve to existing files
- Named imports match actual export names from the source file
- Default imports correspond to files that have default exports
- No circular dependency chains that break module resolution

### API URL Matching

Verify that API endpoint URLs in client code match actual route file paths.

**Checks:**
- Client-side fetch/axios URLs have corresponding server-side route handlers
- URL parameters match (e.g., `/api/users/:id` matches `fetch('/api/users/${id}')`)
- HTTP methods match (client sends POST, server expects POST)

### Database Reference Matching

Verify that database model references in code match schema definitions.

**Checks:**
- Model/table names used in queries exist in schema definitions
- Column/field names referenced in code exist on the model
- Relationship references (foreign keys, joins) point to valid models

### Environment Variable Matching

Verify that environment variables referenced in code exist in configuration.

**Checks:**
- Every `process.env.X` or equivalent has a corresponding entry in `.env`, `.env.example`, or environment documentation
- Required variables are not missing from example files
- No hardcoded secrets that should be environment variables

### Navigation/Routing Matching

Verify that navigation and routing references point to existing pages.

**Checks:**
- Link/anchor `href` values point to routes that exist
- Programmatic navigation calls (router.push, navigate) use valid routes
- Redirect targets exist

---

## Reporting Format

Follow the plain-language-guide.md when reporting issues. Never just list file paths.

### Severity Levels

**"Needs attention" (blocking):**
Issues that mean something is broken or incomplete. These must be addressed before the task can be considered done.

> "The payment form is built but not connected to anything. It won't work until it's wired up to the checkout page."

**"Worth checking" (informational):**
Issues that might be intentional or might indicate a problem. Flagged for awareness.

> "There's a helper function called `formatCurrency` that isn't used anywhere yet. It might be planned for later, but worth noting."

### Report Structure

For each issue found:
1. **What** the issue is (in plain language)
2. **Where** it is (file and location)
3. **Why** it matters (what breaks or what's incomplete)
4. **Suggestion** (what to do about it, if applicable)

### Example Report

> **Needs attention:**
>
> The signup page is built but has a placeholder where email validation should be. Right now it accepts any text, even things that aren't email addresses. This should be fixed before users can sign up.
> *File: src/pages/Signup.tsx, line 45*
>
> **Worth checking:**
>
> There's a file called `utils/date-helpers.ts` with some formatting functions, but nothing in the project imports it yet. It might be intended for the dashboard -- just flagging it so it doesn't get forgotten.
> *File: src/utils/date-helpers.ts*
