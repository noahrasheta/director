#!/usr/bin/env bash
set -euo pipefail

# init-director.sh
# Creates the .director/ project folder structure silently.
# Called automatically when any /director: command runs and .director/ doesn't exist.
#
# Plugin path reference: ${CLAUDE_PLUGIN_ROOT} points to the plugin root directory.
# This script runs from the user's project root, not the plugin root.

# Idempotent: exit silently if .director/ already exists
if [ -d ".director" ]; then
  exit 0
fi

# Create directory structure
mkdir -p .director/brainstorms
mkdir -p .director/goals

# Create VISION.md template
cat > .director/VISION.md << 'VISION_EOF'
# Vision

> This file will be populated when you run /director:onboard

## What are we building?

## Who is it for?

## What problem does it solve?

## What does success look like?

## Technical preferences

## Constraints
VISION_EOF

# Create GAMEPLAN.md template
cat > .director/GAMEPLAN.md << 'GAMEPLAN_EOF'
# Gameplan

> This file will be populated when you run /director:blueprint

## Goals

_No goals defined yet. Run `/director:onboard` to get started._
GAMEPLAN_EOF

# Create STATE.md with initial state
# NOTE: Uses unquoted heredoc so date commands get evaluated at init time
cat > .director/STATE.md << STATE_EOF
# Project State

**Status:** Not started
**Last updated:** $(date '+%Y-%m-%d %H:%M')
**Last session:** $(date '+%Y-%m-%d')

## Current Position

**Current goal:** None
**Current step:** None
**Current task:** None
**Position:** Not started

## Progress

No goals defined yet. Run \`/director:onboard\` to begin.

## Recent Activity

No activity yet.

## Decisions Log

No decisions recorded yet.

## Cost Summary

**Total:** 0 tokens (\$0.00)
STATE_EOF

# Create IDEAS.md
cat > .director/IDEAS.md << 'IDEAS_EOF'
# Ideas

_Captured ideas that aren't in the gameplan yet. Add with `/director:idea "..."`_

IDEAS_EOF

# Create config.json with opinionated defaults
cat > .director/config.json << 'CONFIG_EOF'
{
  "config_version": 1,
  "mode": "guided",
  "tips": true,
  "verification": true,
  "cost_tracking": true,
  "doc_sync": true,
  "max_retry_cycles": 3,
  "cost_rate": 10.00,
  "language": "en",
  "model_profile": "balanced",
  "workflow": {
    "step_research": true
  },
  "context_generation": {
    "completed_goals_at_generation": 0,
    "generated_at": null
  },
  "agents": {
    "interviewer": { "model": "inherit" },
    "planner": { "model": "inherit" },
    "researcher": { "model": "inherit" },
    "mapper": { "model": "haiku" },
    "builder": { "model": "inherit" },
    "verifier": { "model": "haiku" },
    "debugger": { "model": "inherit" },
    "syncer": { "model": "haiku" },
    "deep-researcher": { "model": "inherit" },
    "deep-mapper": { "model": "inherit" },
    "synthesizer": { "model": "inherit" }
  },
  "model_profiles": {
    "quality": {
      "deep-researcher": "opus",
      "deep-mapper": "sonnet",
      "synthesizer": "sonnet"
    },
    "balanced": {
      "deep-researcher": "sonnet",
      "deep-mapper": "haiku",
      "synthesizer": "sonnet"
    },
    "budget": {
      "deep-researcher": "haiku",
      "deep-mapper": "haiku",
      "synthesizer": "haiku"
    }
  }
}
CONFIG_EOF

# Initialize git silently if no .git/ exists
if [ ! -d ".git" ]; then
  git init -q
  git add .director/
  git commit -q -m "Initialize Director project"
fi
