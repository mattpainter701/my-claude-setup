#!/usr/bin/env bash
# PreCompact hook: save working state before context compaction
# Outputs key context that should survive compaction
set -uo pipefail

cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)" 2>/dev/null || exit 0

echo "=== PRE-COMPACT STATE ==="

# Branch and recent work
branch=$(git branch --show-current 2>/dev/null || echo "unknown")
echo "Branch: $branch"

# Modified files (the most important thing to preserve)
modified=$(git diff --name-only HEAD 2>/dev/null | head -10)
if [ -n "$modified" ]; then
  echo "Modified files:"
  echo "$modified"
fi

# Staged files
staged=$(git diff --cached --name-only 2>/dev/null | head -10)
if [ -n "$staged" ]; then
  echo "Staged files:"
  echo "$staged"
fi

# Last 3 commits (what was just done)
echo ""
echo "Recent commits:"
git log --oneline -3 2>/dev/null || true

# Current task from TASKS.md
if [ -f TASKS.md ]; then
  echo ""
  echo "Active task:"
  grep -m1 'IN PROGRESS' TASKS.md 2>/dev/null || echo "(none)"
fi

exit 0
