#!/usr/bin/env bash
# PreToolUse hook: warn before git push
# Gives a chance to review changes before they go to the remote
set -euo pipefail
export PATH="$PATH:$HOME/AppData/Local/Microsoft/WinGet/Links"

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // empty')

# Only check git push commands
echo "$command" | grep -qi 'git push' || exit 0

# Hard block force-push to main/master
if echo "$command" | grep -qiE 'git push.*(\-\-force|\-f).*\b(main|master)\b'; then
  echo "BLOCKED: Force-push to main/master is not allowed." >&2
  exit 2
fi

# Soft warn on regular push
branch=$(git branch --show-current 2>/dev/null || echo "unknown")
ahead=$(git rev-list --count @{upstream}..HEAD 2>/dev/null || echo "?")
echo "Pushing branch '$branch' ($ahead commits ahead). Verify changes are ready." >&2
exit 0
