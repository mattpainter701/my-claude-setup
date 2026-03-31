#!/usr/bin/env bash
# PreCompact hook: inject critical project context before compaction
# Stdout is preserved in the compaction summary
set -uo pipefail

cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)"

echo "=== PROJECT CONTEXT (injected by PreCompact hook) ==="

# Version — try common patterns across languages
for vf in */__init__.py setup.py pyproject.toml package.json Cargo.toml; do
  ver=$(grep -m1 -oP '(?:__version__|"version"|version)\s*[:=]\s*["\x27]\K[^"\x27]+' "$vf" 2>/dev/null) && break
done
echo "Version: ${ver:-unknown}"

# Detect test command
if [ -f pyproject.toml ] || [ -f setup.py ]; then
  echo "Test cmd: python -m pytest --tb=short"
elif [ -f package.json ]; then
  echo "Test cmd: npm test"
elif [ -f Cargo.toml ]; then
  echo "Test cmd: cargo test"
fi

echo ""
echo "=== Recent commits ==="
git log --oneline -5 2>/dev/null || echo "(no git)"
echo ""
echo "=== Uncommitted changes ==="
git diff --stat HEAD 2>/dev/null | tail -5

if [ -f TASKS.md ]; then
  echo ""
  echo "=== Current sprint (TASKS.md top) ==="
  head -25 TASKS.md | grep -E '(^## Sprint|^### [0-9]|Goal:)' || echo "(no sprint found)"
fi
