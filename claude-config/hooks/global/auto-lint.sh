#!/usr/bin/env bash
# PostToolUse hook: auto-lint Python files after Edit/Write
# Runs ruff fix silently — won't block Claude, just cleans up
set -uo pipefail
export PATH="$PATH:$HOME/AppData/Local/Microsoft/WinGet/Links"

input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null)

# Only lint Python files
[[ "$file_path" == *.py ]] || exit 0

# Skip if ruff not installed
command -v ruff &>/dev/null || py -m ruff --version &>/dev/null 2>&1 || exit 0

# Run ruff fix (auto-fix safe issues) + format
py -m ruff check --fix --quiet "$file_path" 2>/dev/null || true
py -m ruff format --quiet "$file_path" 2>/dev/null || true

exit 0
