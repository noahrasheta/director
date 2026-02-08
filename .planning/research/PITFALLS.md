# Pitfalls Research

**Domain:** Claude Code plugin / AI orchestration framework for vibe coders
**Researched:** 2026-02-07
**Confidence:** HIGH (multiple sources cross-referenced: official Claude Code docs, GSD issue tracker, competitive analysis, industry reports, Noah's firsthand experience)

## Critical Pitfalls

### Pitfall 1: Claude Code Platform Coupling — Breaking Changes Silently Disable Your Plugin

**What goes wrong:**
Claude Code ships frequent updates that change how plugins, commands, agents, and hooks are discovered and executed. GSD experienced this directly: after a Claude Code update, all namespaced commands (e.g., `/gsd:help`, `/gsd:new-project`) stopped working in subdirectories. Director's entire interface is namespaced commands (`/director:build`, `/director:onboard`, etc.) — a single Claude Code update could render the entire plugin non-functional with zero warning.

**Why it happens:**
Director is not a standalone application — it is a guest in Claude Code's runtime. Anthropic controls the host platform and ships breaking changes on their release cadence, not Director's. Plugin update mechanisms also have known bugs: plugin updates don't always re-download files when versions change, meaning users can be stuck on stale code even after "updating."

**How to avoid:**
- Pin Director to specific Claude Code versions in documentation and test against the latest Claude Code release before publishing updates.
- Build a lightweight self-diagnostic that runs on first invocation per session: verify that all Director commands are discoverable, that agents load, and that hooks fire. If something is broken, show a plain-language message: "Director may need an update to work with your version of Claude Code. Visit director.cc/update for instructions."
- Monitor the Claude Code changelog and GitHub issues actively. Set up alerts for changes to plugin, agent, command, and hook APIs.
- Follow the correct plugin structure religiously: only `plugin.json` goes inside `.claude-plugin/`; all other directories (`commands/`, `agents/`, `skills/`, `hooks/`) must be at the plugin root level. This is a known gotcha that causes silent failures.

**Warning signs:**
- Commands silently do nothing when invoked (no error, just no response).
- Agents fail to spawn or spawn with wrong context.
- GSD's issue tracker shows new compatibility bugs after Claude Code releases.
- Users report "Director stopped working" after running `claude update`.

**Phase to address:**
Goal 1 (MVP) — Foundation step. The plugin structure and self-diagnostic must be correct from the first buildable artifact. Every subsequent step depends on commands working reliably.

---

### Pitfall 2: Context Rot Leaking Into Fresh Agent Windows

**What goes wrong:**
Director's core architecture depends on fresh agent context per task — each task gets a new agent window with only targeted context (VISION.md + STEP.md + task file + recent git history). The pitfall is assuming that "fresh window" automatically means "clean context." In practice, several mechanisms can corrupt the fresh context: oversized VISION.md documents that eat into the effective context budget, git history that grows unbounded and pollutes the window, STEP.md files that accumulate cruft from prior tasks, and the XML boundary tags themselves taking up tokens.

Research shows that a model claiming 200,000 tokens typically becomes unreliable around 130,000 tokens — effective capacity is roughly 60-70% of the advertised maximum, with sudden performance drops rather than gradual degradation.

**Why it happens:**
The fresh-context-per-task pattern works brilliantly in theory. In practice, nobody monitors the actual token count of the assembled context payload. VISION.md grows as the project evolves. Git history gets longer. Step-level context accumulates. One day the "fresh" context is 80% full before the agent even starts working, and quality silently degrades. The user sees worse results but has no idea why — they just think "the AI got dumber."

**How to avoid:**
- Implement a context budget calculator that measures the assembled payload size before spawning each agent. If the payload exceeds 60% of the context window, compress or truncate the least critical sections (e.g., summarize older git history, condense completed-task references in STEP.md).
- Set hard limits: VISION.md should stay under a defined token count. Git history injection should be capped at the N most recent commits relevant to the current step. STEP.md should only include context for incomplete tasks.
- Add a visible (but non-alarming) indicator when context is running lean vs. full. Not for the user — for Director's own orchestration logic to make intelligent compression decisions.
- Test with large, real projects (not toy examples) during development.

**Warning signs:**
- Agent outputs become less precise or start ignoring task constraints on later tasks in a long project.
- Build agents start asking questions that are answered in the context they were given.
- Increasing rate of verification failures on tasks later in a goal.
- VISION.md exceeds 2,000 words.

**Phase to address:**
Goal 1 (MVP) — Execution engine step. The context assembly logic is the heart of Director's quality guarantee. Must be built with budget awareness from day one, not retrofitted.

---

### Pitfall 3: Documentation Sync That Creates More Problems Than It Solves

**What goes wrong:**
Director's doc-sync agent (director-syncer) runs after every task to compare codebase state against `.director/` documentation. The pitfall is two-sided: (1) the syncer makes incorrect updates that drift the documentation away from reality, or (2) the syncer misses changes made outside Director and the documentation falls silently out of date. Noah experienced both failure modes personally — he made authentication migration changes outside GSD's scope and documentation was never updated to reflect the new Clerk integration.

**Why it happens:**
AI-driven documentation sync is fundamentally a diff-and-patch operation on natural language documents — which is much harder than diffing code. The syncer agent must understand what changed in the codebase, determine which documents are affected, and make precisely the right edits. LLMs are not reliable at this. They might: update VISION.md with implementation details that don't belong there, miss a change that affects the GAMEPLAN.md dependency graph, or "fix" documentation that was already correct by rewriting it in a slightly different way, creating noise.

Additionally, changes made outside Director (the user prompting Claude directly for a "quick fix") create an adversarial gap — the syncer has to detect what changed without being told.

**How to avoid:**
- Never auto-commit syncer changes. Always present syncer findings to the user in plain language: "I noticed the database schema changed. Here's what I'd update in your project docs. Look right?"
- Use git diff as the primary detection mechanism, not AI inference. Diff the codebase against the last Director-managed commit to detect changes.
- Scope syncer responsibility narrowly: it checks VISION.md, GAMEPLAN.md, STATE.md, and the current STEP.md — nothing else. Don't let it touch files outside `.director/`.
- Build a "manual sync" command (or integrate into `/director:resume`) that explicitly handles out-of-band changes: "I see some things changed since we last worked together. Let me check if our docs are still accurate."

**Warning signs:**
- VISION.md contains implementation-level detail ("uses PostgreSQL with a users table") rather than project-level vision.
- GAMEPLAN.md shows tasks as incomplete that were actually done outside Director.
- The syncer makes changes on every single task, even when nothing relevant changed.
- User says "the AI seems confused about what we already built."

**Phase to address:**
Goal 1 (MVP) — Build this as a late-stage step within the execution engine, after the core build/verify loop is stable. The syncer depends on having reliable git history and state management already working.

---

### Pitfall 4: State File Corruption and Race Conditions in `.director/`

**What goes wrong:**
Director stores all project state in Markdown and JSON files in `.director/`. Multiple agents (builder, verifier, syncer) read and write these files, sometimes in the same task execution. If two sub-agents try to update STATE.md simultaneously, or if an agent crashes mid-write, state files can become corrupted, inconsistent, or lose data. This is especially dangerous because STATE.md is the source of truth for progress — corrupt it, and `/director:resume` can't reconstruct where the user left off.

GSD has experienced the same class of issue: the system "forgets information or burns tokens running in a non-productive loop" due to state inconsistencies.

**Why it happens:**
File-based state management has no built-in concurrency control. Markdown and JSON files don't support atomic multi-writer operations. Sub-agents running in parallel within a single task (e.g., verifier + syncer) can step on each other. Claude Code has had documented memory issues that cause crashes when running parallel subagents — a crash during a write can leave files in a half-written state.

**How to avoid:**
- Serialize all state file writes through a single agent or coordination mechanism. The lead agent should be the only writer to STATE.md and GAMEPLAN.md. Sub-agents report their findings back to the lead agent, which makes the writes.
- Write state atomically: write to a temp file first, then rename. This prevents half-written state.
- Include a state validation check at the start of every command: parse STATE.md, verify internal consistency (no duplicate tasks, no missing status fields, no orphaned references). If validation fails, show a recovery message rather than proceeding with bad state.
- Keep state files simple. Resist the urge to add rich metadata to STATE.md. The more complex the state, the more fragile it becomes.

**Warning signs:**
- `/director:status` shows contradictory information (task marked both complete and in-progress).
- `/director:resume` fails to identify the next task or shows stale progress.
- STATE.md grows very large or contains duplicate entries.
- Agent crash during build followed by "weird behavior" on next invocation.

**Phase to address:**
Goal 1 (MVP) — Foundation step. State management design must be decided before any agent writes state. Retrofitting atomic writes into an existing state system is painful.

---

### Pitfall 5: The "Translation Tax" — Plain Language Becoming Inaccurate Language

**What goes wrong:**
Director's core differentiator is translating everything into plain language for vibe coders. The pitfall: plain-language translations lose critical technical precision, and vibe coders make incorrect decisions based on oversimplified information. Example: Director reports "The login page is built and connected" when in reality the auth flow has no token refresh, no session persistence, and no password reset — technically "connected" but functionally incomplete. The user approves and moves on. The problem compounds across tasks.

**Why it happens:**
Translating technical state into plain language is an inherently lossy operation. An AI agent asked to "explain this in simple terms" will optimize for understandability at the expense of accuracy. When the structural verifier reports "files exist, contain real implementation, and are wired together," the plain-language translation might compress this to "everything looks good" — hiding the nuance that "wired together" was checked but "functionally correct" was not.

Noah experienced this: when GSD told him to `npm run dev` to test, he skipped it and said "approve" because it felt too technical. The plain language wasn't inaccurate — the process just wasn't meeting him where he was. Director must find the middle ground.

**How to avoid:**
- Define a translation rubric for each verification tier. Tier 1 (structural) maps to "exists and connected." Tier 2 (behavioral) maps to "works as expected." Never let the AI merge these tiers in its plain-language output.
- Always pair plain-language summaries with actionable verification: "The login page is built. To verify it works: (1) Open your app in a browser, (2) Try logging in with a wrong password — you should see an error, (3) Try logging in correctly — you should see your dashboard."
- Never use the words "everything looks good" or "all done" in verification output. Be specifically positive: "The login page exists, has a form, and connects to the database. Untested: what happens with wrong passwords."
- Build the behavioral checklist (Tier 2) as a required output of every step completion, not an optional inspection step.

**Warning signs:**
- User consistently approves tasks without performing behavioral verification.
- Bugs discovered much later that should have been caught by verification ("the login page never actually checks the password").
- User says "I thought that was done" when issues surface.
- Verification outputs are short and generic rather than specific.

**Phase to address:**
Goal 1 (MVP) — Verification engine step. Build the translation rubric and behavioral checklist generation as part of the core verify loop, not as a Phase 2 enhancement.

---

### Pitfall 6: Sub-Agent Overhead Killing the User Experience

**What goes wrong:**
Director spawns sub-agents extensively: research agents during blueprint, mapper agents during onboard, verifier agents after build, syncer agents after build, debugger agents when issues arise. Each sub-agent adds latency (context loading, tool access setup, reasoning startup). A single `/director:build` invocation could spawn 3-4 sub-agents sequentially: builder, then verifier, then syncer, then potentially debugger. What was supposed to be a fast task execution becomes a 5-10 minute wait with no visible progress.

Sub-agents in Claude Code start with a clean slate each time — they don't remember previous interactions, which adds context-gathering latency. Significantly higher token costs come from coordination overhead.

**Why it happens:**
The multi-agent architecture looks elegant on paper: separation of concerns, each agent does one thing well. But each agent spawn has fixed overhead costs that compound. For a simple task like "add a dark mode toggle," spawning a full verifier agent to check for stubs, then a syncer to update docs, then potentially a debugger — the overhead can exceed the actual work. The design treats every task the same regardless of complexity.

**How to avoid:**
- Implement task-proportional agent spawning. For "small" tasks (as estimated in the gameplan), skip or inline the verifier and syncer. Only spawn full sub-agents for "medium" and "large" tasks.
- Run verifier and syncer in parallel, not sequentially. They don't depend on each other's output.
- Add visible progress indicators: "Building... Checking... Updating docs... Done." Even if it takes the same time, visible progress prevents the user from feeling stuck.
- Profile actual latency during development. Set a target: simple tasks complete in under 60 seconds, medium in under 3 minutes. If sub-agent overhead pushes beyond these thresholds, cut the less critical agent (syncer is most deferrable).

**Warning signs:**
- Users start preferring `/director:quick` for everything to avoid the overhead of the full build loop.
- Simple tasks take the same time as complex tasks.
- API cost per task doesn't correlate with task complexity.
- Users close the terminal during long waits, breaking the workflow.

**Phase to address:**
Goal 1 (MVP) — Execution engine step, but should be continuously monitored. The architecture should support agent spawning from day one, but tuning spawn decisions (when to skip agents) should happen during real-world testing.

---

### Pitfall 7: Gameplan Rigidity — Plans That Can't Survive Contact With Reality

**What goes wrong:**
Director creates a detailed gameplan (Goals > Steps > Tasks) during blueprint, complete with dependency chains and complexity estimates. The plan assumes a predictable build sequence. In reality, vibe coding is inherently exploratory — users discover what they want by seeing what they don't want. When the user runs `/director:pivot`, the entire gameplan needs restructuring. If the gameplan's data structure makes it hard to insert, reorder, or remove tasks without breaking dependency chains, pivots become expensive and error-prone. Tasks that were "ready" become blocked. Completed tasks reference dependencies that no longer exist.

**Why it happens:**
The planning phase (blueprint) optimizes for a future that hasn't happened yet. Dependency graphs are particularly brittle: remove one task and everything downstream might need re-evaluation. Noah specifically described this pattern — he pivoted mid-project on authentication (Supabase to Clerk) and the downstream effects cascaded through code that still referenced the old approach. A rigid gameplan would have made this worse, not better.

**How to avoid:**
- Design the gameplan data structure for mutability from day one. Tasks should reference dependencies by capability ("needs user authentication") rather than by specific task ID ("needs task-01-03"). This way, if a different task fulfills the same capability, the dependency is still satisfied.
- Keep dependency chains shallow. Deep dependency chains (A depends on B depends on C depends on D) are fragile. If a task has more than 2 levels of dependencies, the gameplan is probably over-specified.
- When `/director:pivot` runs, don't try to surgically update the existing gameplan. Regenerate the affected sections from scratch, preserving only completed work and the user's stated new direction. This is more expensive but more reliable.
- Build the pivot workflow as a first-class operation, not an afterthought. It should feel as natural as `/director:build`.

**Warning signs:**
- Users avoid `/director:pivot` because it feels heavyweight or scary.
- After a pivot, the gameplan shows tasks in an illogical order.
- The AI struggles to determine what's "ready" after gameplan modifications.
- Dependency chains exceed 3 levels deep.

**Phase to address:**
Goal 1 (MVP) — Blueprint step. The gameplan data structure decision in the blueprint implementation determines how painful every pivot will be forever after.

---

## Technical Debt Patterns

Shortcuts that seem reasonable but create long-term problems.

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|----------------|-----------------|
| Storing all state in a single STATE.md file | Simple to implement, single source of truth | Concurrency issues, grows unwieldy for large projects, hard to parse for specific data | MVP only — split into focused state files (progress.json, context-cache.json) once project scale demands it |
| Skipping context budget measurement | Faster agent spawning, simpler code | Silent quality degradation on larger projects, impossible to diagnose | Never — even a rough token estimate is better than nothing |
| Hardcoding XML boundary tag format | Works today, fast to ship | If Anthropic changes best practices for context structuring, refactoring is painful | MVP only — abstract the context assembly layer behind a formatter interface |
| Making the syncer agent auto-commit doc changes | Feels seamless, "docs just stay updated" | Incorrect syncs accumulate silently, user loses trust in documentation accuracy | Never — always show syncer changes before committing |
| Using `git log` output as-is for agent context | Easy to implement | Git log output is verbose and wastes tokens; grows unbounded over project lifetime | MVP only — implement a git history summarizer early |
| Not testing with brownfield projects during development | Faster dev cycle, fewer edge cases | Existing-project onboarding is the hardest workflow and will be buggy at launch if untested | Never — test brownfield from the first working prototype |

## Integration Gotchas

Common mistakes when connecting to external services and platforms.

| Integration | Common Mistake | Correct Approach |
|-------------|----------------|------------------|
| Claude Code plugin API | Putting agent/command/hook directories inside `.claude-plugin/` instead of at the plugin root | Only `plugin.json` goes in `.claude-plugin/`. All other directories at plugin root level. |
| Claude Code updates | Assuming namespaced commands (`/director:build`) will continue working across Claude Code versions without testing | Pin to known-good Claude Code versions in docs. Test against new releases before recommending updates. Monitor GSD's issue tracker as an early warning system. |
| Git operations (for vibe coders) | Assuming the user has Git installed and configured with SSH keys or credentials | During onboarding, check for Git installation and basic config. If missing, provide step-by-step setup or link to director.cc/setup. Never assume `.gitconfig` exists. |
| MCP servers (Supabase, Stripe, etc.) | Building Director features that depend on specific MCP servers being available | Director must work fully without any MCP servers. MCP tools are a bonus, never a requirement. Test the entire workflow with zero MCP servers configured. |
| Claude Code plugin marketplace | Expecting automatic updates to work reliably | Known bug: plugin updates don't always re-download files when versions change. Include version-check logic in Director's self-diagnostic. |
| File system permissions | Assuming write access to project directories | Check write permissions before creating `.director/` folder. Provide a clear error if permissions are insufficient. |

## Performance Traps

Patterns that work at small scale but fail as usage grows.

| Trap | Symptoms | Prevention | When It Breaks |
|------|----------|------------|----------------|
| Unbounded git history in agent context | Agent responses slow down; quality degrades; token costs increase | Cap git history to N most recent relevant commits per step; summarize older history | Projects with 50+ commits (roughly after 2 completed goals) |
| VISION.md growing with every pivot | Fresh agents receive bloated vision that exceeds useful context; agent starts contradicting itself | Set a hard word limit on VISION.md; move historical vision changes to an archive file | After 3+ pivots on a single project |
| Full codebase mapping on every resume | `/director:resume` takes minutes on large codebases; unnecessary if nothing changed since last session | Cache the codebase map; only re-map if git diff shows significant changes since last session | Projects with 100+ files |
| Sequential sub-agent spawning | Simple tasks take as long as complex tasks; users feel stuck | Run independent sub-agents in parallel; skip optional agents for small tasks | Noticeable on every build, but worse as project grows |
| Storing completed task files alongside active ones | Directory listing becomes slow; agent context polluted with irrelevant completed-task data | Move completed task files to `.done/` subdirectory or append `.done.md` suffix and exclude from active queries | After completing 20+ tasks in a single step |

## Security Mistakes

Domain-specific security issues beyond general web security.

| Mistake | Risk | Prevention |
|---------|------|------------|
| VISION.md containing API keys or credentials mentioned during onboarding interview | Credentials committed to Git, visible in `.director/` folder, loaded into every agent context | During onboarding, detect and redact anything that looks like an API key, token, or password. Warn the user: "I noticed what looks like a credential. I'll keep this out of your project files." |
| Agent context assembly leaking user data across projects | If Director caches context between projects, sensitive information from Project A could appear in Project B's agent window | Never cache assembled context across projects. Each project's context is built fresh from its own `.director/` files. |
| Git history exposing sensitive data | Atomic commits include full diffs; if a task accidentally adds a `.env` file, it's in Git history forever | Add `.env`, `*.key`, `*.pem`, and common credential files to `.gitignore` during project initialization. Warn before committing files that match sensitive patterns. |
| MCP server credentials in Director state files | If Director logs or records MCP interactions, credentials could be persisted | Never log MCP tool inputs/outputs to `.director/` files. MCP interactions are ephemeral — they happen and are forgotten. |

## UX Pitfalls

Common user experience mistakes in this domain, specifically for vibe coders.

| Pitfall | User Impact | Better Approach |
|---------|-------------|-----------------|
| Showing agent names in output ("director-verifier found 2 issues") | Vibe coders don't know what a "verifier" is and don't care. Creates cognitive overhead. | "I checked your work and found 2 things to fix." Agent names are internal — never surface them. |
| Error messages referencing file paths without context ("Error in src/lib/auth.ts:42") | Vibe coders may not know file paths or what the file does. The error feels alien. | "There's a problem with the login system. The code that checks passwords has an issue. Want me to fix it?" |
| Asking the user to choose between technical options ("Use JWT or session-based auth?") | User doesn't know the difference. Forces a decision they can't make informedly. | Director should make the choice and explain it: "I'm going to use session-based login because it's simpler and works well for your type of app. This means users stay logged in until they close their browser." |
| Long waits with no progress indication | User thinks it's stuck. Closes terminal. Breaks workflow. | Show rolling status: "Setting things up... Building the login page... Checking everything connects... Updating your project docs... Done!" |
| Jargon in gameplan tasks ("Configure Prisma ORM with PostgreSQL adapter") | User can't evaluate if the plan makes sense. Approves blindly. | "Set up the database connection so your app can store and retrieve data." Technical details go in the task file, not the user-facing gameplan. |
| Requiring confirmation for every single action | Slows the workflow to a crawl. User develops "approve fatigue" and starts saying yes to everything without reading. | Only require confirmation for destructive actions, pivots, and final task approval. Everything else proceeds automatically with progress reporting. |

## "Looks Done But Isn't" Checklist

Things that appear complete but are missing critical pieces.

- [ ] **Plugin installation:** Plugin installs without errors, but commands might not register if directory structure is wrong — verify by running `/director:help` and confirming all 11 commands appear
- [ ] **Onboarding interview:** Interview completes and generates VISION.md, but VISION.md might miss deployment plans, auth strategy, or tech stack decisions — verify all sections are populated and no `[UNCLEAR]` markers remain unresolved
- [ ] **Gameplan creation:** Gameplan generates Goals > Steps > Tasks, but dependency chains might be circular or point to nonexistent tasks — verify by running ready-work filtering and confirming at least one task shows as ready
- [ ] **Task execution:** Task completes and commits, but the commit might include unintended file changes or miss required files — verify the git diff matches the task scope
- [ ] **Structural verification (Tier 1):** Verifier reports "no issues," but it might not have checked all new files, or might miss stubs disguised as real code (functions that return hardcoded values) — verify by spot-checking the actual implementation of at least one created file
- [ ] **Documentation sync:** Syncer reports docs are up-to-date, but GAMEPLAN.md task statuses might not reflect what was actually completed — verify STATE.md progress matches the git log
- [ ] **Session resume:** `/director:resume` shows "welcome back" message with correct status, but the assembled context for the next task might be missing recent changes — verify the agent's first action references the latest completed work
- [ ] **Pivot workflow:** Pivot updates the gameplan, but completed work that's still relevant might have been accidentally removed, or new tasks might not have proper dependencies — verify the post-pivot gameplan by scanning for orphaned or impossible dependencies
- [ ] **Quick mode:** Quick task executes successfully, but the documentation sync might not trigger for quick-mode tasks — verify `.director/` files still reflect the change

## Recovery Strategies

When pitfalls occur despite prevention, how to recover.

| Pitfall | Recovery Cost | Recovery Steps |
|---------|---------------|----------------|
| Claude Code breaking change disables commands | LOW | Update plugin structure to match new Claude Code API. Communicate fix via marketplace update. Users run `/plugin update`. |
| Context rot in assembled payload | MEDIUM | Identify which context sections are bloated. Refactor context assembly to compress/truncate. Re-run failed tasks with cleaned context. No data loss. |
| Documentation sync made incorrect updates | LOW | Git revert the syncer's commit. Fix the syncer logic. Re-run sync manually. Atomic commits make this easy. |
| STATE.md corruption | MEDIUM | Reconstruct state from git log (atomic commits are the backup). Parse completed `.done.md` files to rebuild progress. This is why atomic commits matter. |
| Plain-language translation missed critical issue | HIGH | Bug is now in production or downstream tasks built on broken foundation. Must identify the bad task, revert its commit, fix the verification logic, and re-execute. Cascading rework if downstream tasks depend on the broken one. |
| Sub-agent overhead making builds unacceptably slow | LOW | Tune agent spawning thresholds. Run agents in parallel. Skip optional agents for small tasks. No architectural change needed, just configuration. |
| Gameplan becomes inconsistent after pivot | MEDIUM | Regenerate the gameplan from scratch for the current goal, using VISION.md + completed work as input. Discard the broken gameplan rather than trying to repair it. |
| Credential accidentally committed to Git | HIGH | Rotate the credential immediately. Use `git filter-branch` or `git filter-repo` to remove from history. Add the file pattern to `.gitignore`. This is the hardest recovery — prevention is critical. |

## Pitfall-to-Phase Mapping

How roadmap phases should address these pitfalls.

| Pitfall | Prevention Phase | Verification |
|---------|------------------|--------------|
| Claude Code platform coupling / breaking changes | Goal 1 — Foundation step (plugin structure) | Self-diagnostic runs successfully on current Claude Code version. All 11 commands discoverable. |
| Context rot in fresh agent windows | Goal 1 — Execution engine step (context assembly) | Context budget calculator reports payload sizes. No agent window exceeds 60% capacity. Agent output quality doesn't degrade across 10+ sequential tasks. |
| Documentation sync creating wrong updates | Goal 1 — Execution engine step (late, after build loop is stable) | Syncer changes are presented to user before commit. Manual test: make a change outside Director, run sync, verify it detects the change correctly. |
| State file corruption and race conditions | Goal 1 — Foundation step (state management design) | Concurrent sub-agent test: run verifier + syncer simultaneously 10 times, verify STATE.md consistency after each run. |
| Translation tax — inaccurate plain language | Goal 1 — Verification engine step (translation rubric + behavioral checklists) | Every step completion generates a behavioral verification checklist with specific testable actions. No output contains "everything looks good" without specifics. |
| Sub-agent overhead degrading UX | Goal 1 — Execution engine step (agent spawning) | Simple task (small complexity) completes in under 60 seconds. Medium task under 3 minutes. Progress indicators visible during all waits over 5 seconds. |
| Gameplan rigidity breaking pivots | Goal 1 — Blueprint step (gameplan data structure) | Execute a pivot test: create a gameplan with 10+ tasks, pivot at task 5, verify post-pivot gameplan has no orphaned dependencies and at least one task is ready. |
| Credential exposure in VISION.md or Git | Goal 1 — Onboarding step (credential detection) | Run onboarding with an interview response that includes a fake API key. Verify it is redacted from VISION.md and not committed to Git. |

## Sources

- [GSD command compatibility issue after Claude Code update (GitHub Issue #218)](https://github.com/glittercowboy/get-shit-done/issues/218) — HIGH confidence, direct evidence
- [GSD CLAUDE.md injection issue (GitHub Issue #50)](https://github.com/glittercowboy/get-shit-done/issues/50) — HIGH confidence, direct evidence
- [Claude Code plugin update bug (GitHub Issue #19197)](https://github.com/anthropics/claude-code/issues/19197) — HIGH confidence, official repo
- [Claude Code plugin documentation](https://code.claude.com/docs/en/plugins) — HIGH confidence, official docs
- [Claude Code sub-agents documentation](https://code.claude.com/docs/en/sub-agents) — HIGH confidence, official docs
- [Context Rot: From Agent Loop to Agent Swarm (DEV Community)](https://dev.to/simone_callegari_1f56a902/context-rot-from-agent-loop-to-agent-swarm-solving-context-persistence-in-ai-assisted-development-3ada) — MEDIUM confidence, community analysis
- [Context Rot: Why AI Gets Worse the Longer You Chat (ProductTalk)](https://www.producttalk.org/context-rot/) — MEDIUM confidence, industry analysis
- [AI Coding Agents: Coherence Through Orchestration (Mike Mason)](https://mikemason.ca/writing/ai-coding-agents-jan-2026/) — MEDIUM confidence, industry analysis
- [Vibe coding could cause catastrophic "explosions" in 2026 (The New Stack)](https://thenewstack.io/vibe-coding-could-cause-catastrophic-explosions-in-2026/) — MEDIUM confidence, industry reporting
- [Spec-Driven Development: Unpacking 2025's Key Practice (Thoughtworks)](https://www.thoughtworks.com/en-us/insights/blog/agile-engineering-practices/spec-driven-development-unpacking-2025-new-engineering-practices) — MEDIUM confidence, authoritative source
- [What I Learned Building a Trilogy of Claude Code Plugins (Pierce Lamb)](https://pierce-lamb.medium.com/what-i-learned-while-building-a-trilogy-of-claude-code-plugins-72121823172b) — MEDIUM confidence, practitioner experience
- Noah Rasheta's firsthand experience with GSD (from `docs/design/research-followup-questions.md`) — HIGH confidence, direct user experience
- Director competitive analysis of 8 frameworks (from `docs/design/research-competitive-analysis.md`) — HIGH confidence, primary research

---
*Pitfalls research for: Claude Code plugin / AI orchestration framework for vibe coders*
*Researched: 2026-02-07*
