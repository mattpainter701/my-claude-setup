#!/usr/bin/env bash
# PreToolUse hook: warn if code is staged but TASKS.md / CHANGELOG.md are not
set -euo pipefail
export PATH="$PATH:$HOME/AppData/Local/Microsoft/WinGet/Links"

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // empty')

# Only gate git commit commands
echo "$command" | grep -qi 'git commit' || exit 0

# Allow --allow-empty
echo "$command" | grep -qi '\-\-allow-empty' && exit 0

# Get staged files
staged=$(git diff --cached --name-only 2>/dev/null || true)
[ -z "$staged" ] && exit 0

# Check if any code files are staged (not just docs/config)
has_code=false
while IFS= read -r f; do
  case "$f" in
    *.py|*.yml|*.yaml|*.js|*.ts|*.html|*.css)
      # Exclude TASKS.md, CHANGELOG.md, and memory files themselves
      has_code=true
      break
      ;;
  esac
done <<< "$staged"

$has_code || exit 0

# Check for TASKS.md and CHANGELOG.md in staged files
missing=""
echo "$staged" | grep -qx 'TASKS.md' || missing="TASKS.md"
echo "$staged" | grep -qx 'CHANGELOG.md' || missing="${missing:+$missing + }CHANGELOG.md"

if [ -n "$missing" ]; then
  echo "WARNING: Code files staged but $missing not included. Stage them or use --allow-empty for non-task commits." >&2
  # Exit 1 = warn but allow, exit 2 = hard block
  exit 1
fi

exit 0
