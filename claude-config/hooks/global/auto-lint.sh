#!/usr/bin/env bash
# PostToolUse hook: auto-lint Python files after Edit/Write
# Runs ruff fix silently — won't block Claude, just cleans up
set -uo pipefail

input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null)

# Only lint Python files
[[ "$file_path" == *.py ]] || exit 0

# Find ruff — check direct command first, then python -m
if command -v ruff &>/dev/null; then
  ruff check --fix --quiet "$file_path" 2>/dev/null || true
  ruff format --quiet "$file_path" 2>/dev/null || true
elif command -v python3 &>/dev/null && python3 -m ruff --version &>/dev/null 2>&1; then
  python3 -m ruff check --fix --quiet "$file_path" 2>/dev/null || true
  python3 -m ruff format --quiet "$file_path" 2>/dev/null || true
elif command -v python &>/dev/null && python -m ruff --version &>/dev/null 2>&1; then
  python -m ruff check --fix --quiet "$file_path" 2>/dev/null || true
  python -m ruff format --quiet "$file_path" 2>/dev/null || true
fi
# If ruff not found anywhere, silently skip

exit 0
