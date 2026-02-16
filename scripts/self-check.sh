#!/usr/bin/env bash

# self-check.sh
# Verifies all Director components are present and functional.
# Called by skills on first command invocation after install.
#
# Behavior:
#   - Success (zero issues): exit 0, no output (quiet success)
#   - Failure: structured error output following Phase 9 patterns, exit 1

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"

ISSUES=()

# --- Check 14 expected skills (each must have SKILL.md) ---

EXPECTED_SKILLS=(
  onboard
  blueprint
  build
  quick
  undo
  inspect
  status
  resume
  refresh
  brainstorm
  pivot
  idea
  ideas
  help
)

for skill in "${EXPECTED_SKILLS[@]}"; do
  if [ ! -f "${PLUGIN_ROOT}/skills/${skill}/SKILL.md" ]; then
    ISSUES+=("Missing skill: ${skill} (expected skills/${skill}/SKILL.md)")
  fi
done

# --- Check 11 expected agents (each must have .md in agents/) ---

EXPECTED_AGENTS=(
  director-interviewer
  director-planner
  director-researcher
  director-mapper
  director-deep-mapper
  director-deep-researcher
  director-synthesizer
  director-builder
  director-verifier
  director-debugger
  director-syncer
)

for agent in "${EXPECTED_AGENTS[@]}"; do
  if [ ! -f "${PLUGIN_ROOT}/agents/${agent}.md" ]; then
    ISSUES+=("Missing agent: ${agent} (expected agents/${agent}.md)")
  fi
done

# --- Check hooks configuration ---

if [ ! -f "${PLUGIN_ROOT}/hooks/hooks.json" ]; then
  ISSUES+=("Missing hooks configuration (expected hooks/hooks.json)")
fi

# --- Check plugin manifest ---

if [ ! -f "${PLUGIN_ROOT}/.claude-plugin/plugin.json" ]; then
  ISSUES+=("Missing plugin manifest (expected .claude-plugin/plugin.json)")
fi

# --- Output ---

if [ ${#ISSUES[@]} -eq 0 ]; then
  exit 0
fi

# Failure: structured output following Phase 9 error patterns
echo "DIRECTOR_SELF_CHECK_FAILED"
echo "${#ISSUES[@]} issues found"
for issue in "${ISSUES[@]}"; do
  echo "  - ${issue}"
done
echo ""
echo "Some Director components are missing. This usually means the installation didn't complete. Try reinstalling: /plugin install director@director-marketplace"
exit 1
