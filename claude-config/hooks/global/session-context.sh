#!/usr/bin/env bash
# SessionStart hook: inject context on resume/compact/clear
# Stdout goes into the session context
set -uo pipefail

input=$(cat)
trigger=$(echo "$input" | jq -r '.matcher // "unknown"' 2>/dev/null)

# Only inject on resume, compact, or clear — not fresh startup
case "$trigger" in
  resume|compact|clear) ;;
  *) exit 0 ;;
esac

cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)" 2>/dev/null || exit 0

echo "=== SESSION CONTEXT (auto-injected on $trigger) ==="

# Version
ver=$(grep -m1 '__version__' varta_core/__init__.py 2>/dev/null | grep -oP '"[^"]+"' || echo '"unknown"')
echo "Version: $ver"

# Branch + recent commits
branch=$(git branch --show-current 2>/dev/null || echo "unknown")
echo "Branch: $branch"
echo ""
echo "Recent commits:"
git log --oneline -5 2>/dev/null || echo "(no git)"

# Uncommitted changes
echo ""
echo "Uncommitted:"
git diff --stat HEAD 2>/dev/null | tail -5

# Current sprint
echo ""
echo "Sprint:"
head -25 TASKS.md 2>/dev/null | grep -E '(^## Sprint|^### [0-9]|Goal:)' || echo "(no TASKS.md)"

exit 0
