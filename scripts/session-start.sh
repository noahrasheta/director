#!/usr/bin/env bash

# session-start.sh
# Runs on SessionStart hook to load project state into Claude's context.
# Outputs a brief JSON summary if a Director project exists, nothing otherwise.

# No project yet — output nothing
if [ ! -f ".director/STATE.md" ]; then
  exit 0
fi

# Extract key state information from STATE.md
STATUS=$(grep -m1 '^\*\*Status:\*\*' .director/STATE.md 2>/dev/null | sed 's/\*\*Status:\*\* //' || echo "unknown")
CURRENT_GOAL=$(grep -m1 '^\*\*Current goal:\*\*' .director/STATE.md 2>/dev/null | sed 's/\*\*Current goal:\*\* //' || echo "None")
CURRENT_STEP=$(grep -m1 '^\*\*Current step:\*\*' .director/STATE.md 2>/dev/null | sed 's/\*\*Current step:\*\* //' || echo "None")
CURRENT_TASK=$(grep -m1 '^\*\*Current task:\*\*' .director/STATE.md 2>/dev/null | sed 's/\*\*Current task:\*\* //' || echo "None")
LAST_SESSION=$(grep -m1 '^\*\*Last session:\*\*' .director/STATE.md 2>/dev/null | sed 's/\*\*Last session:\*\* //' || echo "unknown")

# Check if config exists and read mode
MODE="guided"
if [ -f ".director/config.json" ]; then
  MODE=$(python3 -c "import json; print(json.load(open('.director/config.json')).get('mode', 'guided'))" 2>/dev/null || echo "guided")
fi

# Output compact JSON for Claude context
cat << EOF
{"director":{"status":"${STATUS}","goal":"${CURRENT_GOAL}","step":"${CURRENT_STEP}","task":"${CURRENT_TASK}","mode":"${MODE}","last_session":"${LAST_SESSION}"}}
EOF
