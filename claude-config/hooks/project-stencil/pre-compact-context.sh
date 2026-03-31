#!/usr/bin/env bash
# PreCompact hook: inject critical project context before compaction
# Stdout is preserved in the compaction summary

cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)"

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

detect_test_command() {
  if [ -f pyproject.toml ] || [ -f setup.py ]; then
    echo "py -m pytest --tb=short"
    return
  fi
  if [ -f package.json ]; then
    echo "npm test"
    return
  fi
  if [ -f Cargo.toml ]; then
    echo "cargo test"
    return
  fi
  if [ -f go.mod ]; then
    echo "go test ./..."
    return
  fi
  if compgen -G "*.kicad_pro" >/dev/null; then
    echo "KiCad DRC/ERC or project-specific hardware checks"
    return
  fi
  echo "Customize per project"
}

echo "=== PROJECT CONTEXT (injected by PreCompact hook) ==="
echo "Version: $(detect_version || echo unknown)"
echo "Test cmd: $(detect_test_command)"
echo ""
echo "=== Recent commits ==="
git log --oneline -5 2>/dev/null || echo "(no git)"
echo ""
echo "=== Uncommitted changes ==="
git diff --stat HEAD 2>/dev/null | tail -5
echo ""
echo "=== Current sprint (TASKS.md top) ==="
head -25 TASKS.md 2>/dev/null | grep -E '(^## Sprint|^### [0-9]|Goal:)' || echo "(no TASKS.md)"
