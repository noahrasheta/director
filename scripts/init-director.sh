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
cat > .director/STATE.md << 'STATE_EOF'
# Project State

**Status:** Not started
**Current goal:** None
**Current step:** None
**Current task:** None

## Progress

No tasks completed yet. Run `/director:onboard` to begin.

## History
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
  "language": "en",
  "agents": {
    "interviewer": "inherit",
    "planner": "inherit",
    "researcher": "inherit",
    "mapper": "haiku",
    "builder": "inherit",
    "verifier": "haiku",
    "debugger": "inherit",
    "syncer": "haiku"
  }
}
CONFIG_EOF

# Initialize git silently if no .git/ exists
if [ ! -d ".git" ]; then
  git init -q
  git add .director/
  git commit -q -m "Initialize Director project"
fi
