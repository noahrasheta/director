# Director: Opus 4.6 Capabilities & Integration Strategy

**Date:** February 6, 2026
**Source:** Anthropic announcement + Claude Code documentation
**Purpose:** How Director leverages the latest Claude model capabilities

---

## Opus 4.6 Key Capabilities

### 1. Sub-Agents & Agent Teams in Claude Code

**Sub-agents (available now — MVP):**
- **What it is:** A lead agent can spawn sub-agents for specific work. Multiple sub-agents can run in parallel within a single task.
- **Why it matters:** Director can use parallel sub-agents from day one for codebase exploration, research, verification, and debugging.
- **Director integration (MVP):**
  - Onboarding: parallel sub-agents map architecture, tech stack, file structure, and concerns simultaneously
  - Build: sub-agents handle verification and documentation sync
  - Inspect: sub-agents investigate issues and create fix plans
  - Blueprint: sub-agents research implementation approaches

**Coordinated Agent Teams (Opus 4.6 — Phase 3):**
- **What it is:** Multiple independent tasks executed simultaneously by coordinated agent teams with specialized roles
- **Why it matters:** Director can work on multiple tasks at once, dramatically reducing build time
- **Director integration (Phase 3):**
  - Orchestrate researcher + builder + reviewer teams across independent tasks concurrently
  - User sees: "Director is working on 3 tasks at once. Each one is independent."
  - Coordinate via Director's dependency graph to ensure only independent tasks run in parallel

### 2. Adaptive Thinking
- **What it is:** Claude autonomously decides when to use extended reasoning (no explicit "think hard" needed)
- **Why it matters:** Planning and verification naturally get deeper thinking; simple tasks stay fast
- **Director integration:**
  - Invisible to user
  - Planning phases benefit from deeper reasoning
  - Goal-backward verification uses extended thinking
  - Quick tasks use minimal reasoning

### 3. Effort Controls (Low/Medium/High/Max)
- **What it is:** Configure thinking effort per invocation
- **Why it matters:** Cost optimization - don't pay for deep thinking on trivial operations
- **Director integration:**
  - Map to task complexity: Actions = low, Tasks = medium, Steps = high, Gameplan = max
  - Automatically selected by Director, not user-configured
  - Cost savings: 60-80% on routine operations vs using max effort everywhere

### 4. Context Compaction (Beta)
- **What it is:** Automatically compress prior conversation when approaching context limits
- **Why it matters:** Longer uninterrupted work sessions
- **Director integration:**
  - Director already uses fresh agent windows per task (primary strategy)
  - Context compaction is a safety net for long planning sessions
  - Invisible to user

### 5. 1M Token Context Window
- **What it is:** First Opus model with 1 million token context
- **Why it matters:** Can read larger codebases in a single pass
- **Director integration:**
  - Enables map-codebase to analyze larger projects
  - Research agents can process more documentation
  - Planning agents can consider more project context
  - Still use fresh windows per task (quality > quantity)

### 6. 128K Output Tokens
- **What it is:** 4x more output than previous models
- **Why it matters:** Can generate comprehensive plans, detailed research, and longer code blocks
- **Director integration:**
  - More detailed Vision documents
  - More comprehensive Gameplan generation
  - Fewer "continuation" breaks in long outputs

---

## Integration Roadmap

### Phase 1 (MVP): Sub-Agents + Invisible Benefits
- Sub-agents for codebase exploration, research, verification, and debugging (parallel where possible)
- Use Opus 4.6's adaptive thinking for better planning quality
- Use effort controls to optimize costs per operation type
- Use 1M context for initial codebase analysis
- Use context compaction as safety net during long sessions
- **User experience:** Everything just works — Director uses multiple agents behind the scenes when it helps

### Phase 3: Coordinated Agent Teams
- Multiple independent tasks executed simultaneously by coordinated agent teams
- Specialized agent roles (researcher, builder, reviewer, verifier) per team
- Dynamic agent team sizing based on task complexity
- Cost-optimized model selection per agent role (Opus for planning, Sonnet for execution, Haiku for routine checks)
- **User experience:** "Director is working on 3 tasks at once" + transparent cost tracking

---

## Cost Optimization Strategy

| Operation | Effort Level | Estimated Cost Reduction |
|---|---|---|
| Reading files | Low | 80% vs max |
| Simple edits | Low | 80% vs max |
| Task execution | Medium | 50% vs max |
| Step planning | High | 20% vs max |
| Gameplan creation | Max | Baseline |
| Goal verification | High | 20% vs max |
| Research | Medium | 50% vs max |
| Quick tasks | Medium | 50% vs max |

**Combined with fresh context per task (from Autospec research):** Expected 80%+ cost reduction compared to naive single-session approaches.
