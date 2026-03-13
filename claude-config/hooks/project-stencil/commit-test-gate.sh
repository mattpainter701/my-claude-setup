#!/usr/bin/env bash
# PreToolUse hook: block git commit unless tests passed recently
set -euo pipefail
export PATH="$PATH:$HOME/AppData/Local/Microsoft/WinGet/Links"

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // empty')

# Only gate git commit commands
echo "$command" | grep -qi 'git commit' || exit 0

# Allow --allow-empty (for non-code commits like docs)
echo "$command" | grep -qi '\-\-allow-empty' && exit 0

# Find repo root from CWD or script location
repo_root=$(git rev-parse --show-toplevel 2>/dev/null || echo "")

# Check both possible marker locations
marker=""
for candidate in \
    "${repo_root}/.git/tests-passed" \
    "${TEMP:-/tmp}/tests-passed" \
    "/tmp/tests-passed"; do
  if [ -f "$candidate" ]; then
    marker="$candidate"
    break
  fi
done

if [ -z "$marker" ]; then
  echo "BLOCKED: Run tests before committing." >&2
  echo "Re-run tests: py -m pytest" >&2
  exit 2
fi

# Check marker age (stale after 30 minutes)
marker_time=$(stat -c %Y "$marker" 2>/dev/null || echo 0)
now=$(date +%s)
age=$(( now - marker_time ))
if [ "$age" -gt 1800 ]; then
  echo "BLOCKED: test marker stale ($(( age / 60 )) minutes old)." >&2
  echo "Re-run tests: py -m pytest" >&2
  exit 2
fi

exit 0
