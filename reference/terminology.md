# Director Terminology Reference

This document is the single source of truth for Director's vocabulary. Every skill, agent, and command references this file to ensure consistent terminology across the entire plugin.

## Core Principle

Director uses plain-language terms designed around how vibe coders think about their projects. These are not simplified developer terms -- they are the right words for this workflow.

---

## Project Hierarchy

```
Project
  > Goals (v1, v2, v3...)
    > Steps (1. Foundation, 2. Core Features, 3. Polish...)
      > Tasks (Set up database, Build login page, Add dark mode...)
        > Actions (invisible to user -- what AI does internally)
```

**Visibility rules:**
- Users work at the **Goal / Step / Task** level. They see these, name these, and make decisions about these.
- **Actions are invisible.** Users never see action-level detail. They see "Build login page is complete," not the individual file operations.
- **Git operations are abstracted.** Users see "Progress saved" and "You can undo this," not commit hashes or branch names.

---

## Term Mapping

| What Director says | What developers call it | Why Director uses this |
|----|----|----|
| **Project** | Repository, Codebase | Self-explanatory |
| **Goal** | Milestone, Epic, Version, Release | Everyone understands "what's the goal?" |
| **Step** | Phase, Sprint, Module | Building happens one step at a time |
| **Task** | Ticket, Issue, Story, Plan | Something you do to make progress |
| **Action** | Sub-task, Story (invisible to user) | The smallest unit of work -- hidden from users |
| **Vision** | Spec, PRD, Requirements | What you want to build |
| **Gameplan** | Roadmap, Backlog, Workflow | Your plan for getting there |
| **Launch** | Deploy, Release, Ship | Everyone knows what "launch" means |
| **New project** | Greenfield | Plain English |
| **Existing project** | Brownfield | Plain English |
| **"Needs X first"** | Has dependency on X, Blocked by X | Plain English |
| **"Progress saved"** | Committed, Pushed | Abstracts git entirely |
| **"Going back"** | Reverted, Rolled back | Plain English |
| **"Undo"** | Revert, Rollback, Git reset | "Going back to before that task" |
| **"Needs attention"** | Has issues, Failing, Error state | Plain English |
| **"Ready"** | No blockers, Can start, Unblocked | Plain English |

---

## Words to NEVER Use in User-Facing Output

These terms are developer jargon. If you find yourself writing any of these in output the user will see, rewrite using plain language.

**Developer workflow terms:**
dependency, artifact, integration, prerequisite, blocker (use "needs X first"), worktree, CI/CD, pipeline, deployment pipeline, build step, compile, transpile, lint, minify

**Git/version control terms:**
repository, branch, merge, commit, SHA, hash, diff, rebase, revert, rollback, reset, pull request, staging area, working tree, HEAD, checkout

**Backend/architecture terms:**
schema, migration, endpoint, route, middleware, ORM, query, mutation, resolver, microservice, monolith, payload, serialization, runtime, stack trace, exception

**Infrastructure terms:**
container, orchestration (in the DevOps sense), load balancer, reverse proxy, CDN, SSL certificate, DNS record

---

## Words That Are OK in User-Facing Output

These are common enough that vibe coders understand them, especially when explaining what was built.

**General tech terms:**
file, page, button, form, link, menu, sidebar, header, footer, modal, popup, notification, list, table, card, search

**Features:**
login, signup, dashboard, settings, profile, admin, payment, checkout, cart, upload, download

**Concepts:**
database, API, server, website, app, plugin, update, error, warning, loading, saving, undo, go back

---

## Phrasing Examples

### Bad (developer-speak)
> Task EXEC-03 has an unresolved dependency on ONBR-05.

### Good (plain language)
> This needs user authentication first. Want to set that up?

---

### Bad (exposing git internals)
> Committed 3 files to the repository on branch feature/auth.

### Good (abstracted)
> Progress saved. The login page is ready.

---

### Bad (jargon-heavy error)
> Error: Schema migration failed. Run `db:migrate` to resolve.

### Good (plain explanation)
> Something went wrong updating the database structure. Here's what happened and what we can do about it.

---

### Bad (status report as developer log)
> Step 2 status: COMPLETE. Tasks 4/6 passed verification. 2 tasks deferred.

### Good (natural progress update)
> Step 2 is complete! Four tasks are done, and two are saved for later. You're 3 of 5 steps through your first goal.

---

### Bad (imperative command reference)
> Run /director:onboard to initialize project.

### Good (conversational suggestion)
> Ready to get started? I can help you set up your project and figure out what to build first.

---

### Bad (exposing git internals)
> Commit abc123 has been reverted. HEAD now points to def456.

### Good (abstracted)
> Done -- went back to before the login page task. Your project is back to where it was.

---

## Usage Notes for Agents and Skills

1. **Always check this file** when composing user-facing messages.
2. **Internal logs and state files** can use developer terms freely -- users don't see them.
3. **When in doubt**, read the message out loud. If it sounds like a developer tool, rewrite it.
4. **The test:** Could someone who has never written code understand this message? If not, simplify.
