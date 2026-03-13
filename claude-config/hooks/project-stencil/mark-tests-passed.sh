#!/usr/bin/env bash
# PostToolUse hook: create test-passed marker after successful pytest
export PATH="$PATH:$HOME/AppData/Local/Microsoft/WinGet/Links"
input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // empty')

# Only act on pytest commands
echo "$command" | grep -q 'pytest' || exit 0

# Stringify the full hook input to search for pytest summary
response=$(echo "$input" | jq -r 'tostring')

# Parse the pytest summary line format: "N passed" with no "N failed"
# Uses pattern matching on the summary line to avoid false negatives
# from test names that happen to contain the word "failed"
if echo "$response" | grep -qE '[0-9]+ passed' && ! echo "$response" | grep -qE '[0-9]+ failed'; then
  repo_root=$(git rev-parse --show-toplevel 2>/dev/null || echo "")
  if [ -n "$repo_root" ]; then
    touch "${repo_root}/.git/tests-passed"
  fi
  touch "${TEMP:-/tmp}/tests-passed"
fi

exit 0
