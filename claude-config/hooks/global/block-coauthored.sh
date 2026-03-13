#!/usr/bin/env bash
# PreToolUse hook: block git commits containing Co-Authored-By
set -euo pipefail
export PATH="$PATH:$HOME/AppData/Local/Microsoft/WinGet/Links"

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // empty')

# Only check git commit commands
echo "$command" | grep -qi 'git commit' || exit 0

# Block if Co-Authored-By appears anywhere in the command
if echo "$command" | grep -qi 'co-authored-by'; then
  echo "BLOCKED: Co-Authored-By lines are banned. Remove them and retry." >&2
  exit 2
fi

exit 0
