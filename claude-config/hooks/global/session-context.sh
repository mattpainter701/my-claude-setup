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

# Version — try common patterns: __version__, version = "...", "version": "..."
for vf in */__init__.py setup.py pyproject.toml package.json; do
  ver=$(grep -m1 -oP '(?:__version__|"version"|version)\s*[:=]\s*["\x27]\K[^"\x27]+' "$vf" 2>/dev/null) && break
done
echo "Version: ${ver:-unknown}"

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

# Current sprint (if TASKS.md exists)
if [ -f TASKS.md ]; then
  echo ""
  echo "Sprint:"
  head -25 TASKS.md | grep -E '(^## Sprint|^### [0-9]|Goal:)' || echo "(no sprint found)"
fi

exit 0
