#!/usr/bin/env bash
# PreCompact hook: inject critical Varta context before compaction
# Stdout is preserved in the compaction summary

cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)"

echo "=== PROJECT CONTEXT (injected by PreCompact hook) ==="
# Try common version file patterns — customize for your project
for vf in */__init__.py setup.py pyproject.toml; do
  ver=$(grep -m1 -oP '(?:__version__|version)\s*=\s*["\x27]\K[^"\x27]+' "$vf" 2>/dev/null) && break
done
echo "Version: ${ver:-unknown}"
echo "Test cmd: py -m pytest --tb=short"
echo ""
echo "=== Recent commits ==="
git log --oneline -5 2>/dev/null || echo "(no git)"
echo ""
echo "=== Uncommitted changes ==="
git diff --stat HEAD 2>/dev/null | tail -5
echo ""
echo "=== Current sprint (TASKS.md top) ==="
head -25 TASKS.md 2>/dev/null | grep -E '(^## Sprint|^### [0-9]|Goal:)' || echo "(no TASKS.md)"
