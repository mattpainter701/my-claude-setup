#!/usr/bin/env bash
# SessionStart hook: inject context on resume/compact/clear
# Stdout goes into the session context
set -uo pipefail

input=$(cat)
trigger=$(echo "$input" | jq -r '.source // .matcher // "unknown"' 2>/dev/null)

# Only inject on resume, compact, or clear — not fresh startup
case "$trigger" in
  resume|compact|clear) ;;
  *) exit 0 ;;
esac

cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)" 2>/dev/null || exit 0

detect_project_type() {
  if [ -f pyproject.toml ] || [ -f setup.py ]; then
    echo "python"
    return
  fi
  if [ -f package.json ]; then
    echo "node"
    return
  fi
  if [ -f Cargo.toml ]; then
    echo "rust"
    return
  fi
  if [ -f go.mod ]; then
    echo "go"
    return
  fi
  if compgen -G "*.kicad_pro" >/dev/null; then
    echo "kicad"
    return
  fi
  echo "unknown"
}

detect_version() {
  local candidate version
  shopt -s nullglob

  for candidate in pyproject.toml setup.py package.json Cargo.toml version.py */version.py __init__.py */__init__.py; do
    [ -f "$candidate" ] || continue

    case "$candidate" in
      pyproject.toml|setup.py)
        version=$(sed -nE "s/^[[:space:]]*(version|__version__)[[:space:]]*=[[:space:]]*['\"]([^'\"]+)['\"].*/\2/p" "$candidate" | head -n 1)
        ;;
      package.json)
        version=$(sed -nE 's/^[[:space:]]*"version"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/p' "$candidate" | head -n 1)
        ;;
      Cargo.toml)
        version=$(sed -nE 's/^[[:space:]]*version[[:space:]]*=[[:space:]]*"([^"]+)".*/\1/p' "$candidate" | head -n 1)
        ;;
      *)
        version=$(sed -nE "s/^[[:space:]]*__version__[[:space:]]*=[[:space:]]*['\"]([^'\"]+)['\"].*/\1/p" "$candidate" | head -n 1)
        ;;
    esac

    if [ -n "$version" ]; then
      printf '%s\n' "$version"
      return 0
    fi
  done

  return 1
}

echo "=== SESSION CONTEXT (auto-injected on $trigger) ==="
echo "Project type: $(detect_project_type)"
echo "Version: $(detect_version || echo unknown)"

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
