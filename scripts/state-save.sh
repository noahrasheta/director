#!/usr/bin/env bash
# state-save.sh
# Runs on SessionEnd hook to update STATE.md timestamps.
# Lightweight -- only updates timestamps, never recalculates progress.

# No project -- exit silently
if [ ! -f ".director/STATE.md" ]; then
  exit 0
fi

TIMESTAMP=$(date '+%Y-%m-%d %H:%M')
DATE=$(date '+%Y-%m-%d')

# Update Last updated timestamp
if grep -q '^\*\*Last updated:\*\*' .director/STATE.md; then
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/^\*\*Last updated:\*\*.*/\*\*Last updated:\*\* ${TIMESTAMP}/" .director/STATE.md
  else
    sed -i "s/^\*\*Last updated:\*\*.*/\*\*Last updated:\*\* ${TIMESTAMP}/" .director/STATE.md
  fi
fi

# Update Last session timestamp
if grep -q '^\*\*Last session:\*\*' .director/STATE.md; then
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/^\*\*Last session:\*\*.*/\*\*Last session:\*\* ${DATE}/" .director/STATE.md
  else
    sed -i "s/^\*\*Last session:\*\*.*/\*\*Last session:\*\* ${DATE}/" .director/STATE.md
  fi
fi

exit 0
