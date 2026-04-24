#!/usr/bin/env bash
# PreToolUse hook: block --no-verify flag on git commands
# Prevents bypassing pre-commit, commit-msg, and pre-push hooks
set -euo pipefail
export PATH="$PATH:$HOME/AppData/Local/Microsoft/WinGet/Links"

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // empty')

# Only check git commands
echo "$command" | grep -qi 'git ' || exit 0

# Block --no-verify and -n (short form for --no-verify on commit)
if echo "$command" | grep -qiE '\-\-no-verify|\-n\s'; then
  echo "BLOCKED: --no-verify bypasses safety hooks. Remove the flag and fix the underlying issue." >&2
  exit 2
fi

exit 0
