#!/bin/sh
# Auto-setup token-saving tools for a project on first session entry.
# Runs in background, non-blocking, idempotent.
#
# Tools handled:
#   1. code-review-graph — Tree-sitter code graph (+ git refresh hooks)
#   2. mempalace        — semantic memory (capped initial mine)
#
# Also maintains ~/.mempalace/projects.list so the weekly scheduled
# mine knows which projects to refresh.

[ ! -d .git ] && exit 0

PROJECT="$(basename "$PWD")"
PROJECT_LIST="$HOME/.mempalace/projects.list"

# --- code-review-graph ---
if command -v code-review-graph >/dev/null 2>&1; then
  NEED_BUILD=1
  if [ -d .code-review-graph ]; then
    if code-review-graph status 2>/dev/null | grep -qE "^Nodes: [1-9]"; then
      NEED_BUILD=0
    fi
  fi
  if [ "$NEED_BUILD" = "1" ]; then
    LOG="/tmp/crg-build-${PROJECT}.log"
    (code-review-graph build > "$LOG" 2>&1 &)
    echo "[CRG] building graph for ${PROJECT} (log: $LOG)"
  fi

  # Install git post-merge/post-checkout hooks for external-change refresh.
  for HOOK in post-merge post-checkout; do
    HOOK_PATH=".git/hooks/${HOOK}"
    if [ ! -f "$HOOK_PATH" ] || ! grep -q "crg-refresh-marker" "$HOOK_PATH" 2>/dev/null; then
      [ ! -f "$HOOK_PATH" ] && echo '#!/bin/sh' > "$HOOK_PATH"
      cat >> "$HOOK_PATH" <<'EOF'
# crg-refresh-marker: refresh code graph after external changes
if command -v code-review-graph >/dev/null 2>&1 && [ -d .code-review-graph ]; then
  (code-review-graph build > /tmp/crg-refresh.log 2>&1 &)
fi
EOF
      chmod +x "$HOOK_PATH"
    fi
  done
fi

# --- mempalace ---
if command -v py >/dev/null 2>&1 && py -c "import mempalace" 2>/dev/null; then
  if [ ! -f mempalace.yaml ]; then
    LOG="/tmp/mempalace-setup-${PROJECT}.log"
    (
      PYTHONUTF8=1 py -m mempalace init --yes "$PWD" > "$LOG" 2>&1 \
        && PYTHONUTF8=1 py -m mempalace mine "$PWD" \
             --mode projects --wing "${PROJECT}" --limit 500 >> "$LOG" 2>&1 &
    )
    echo "[mempalace] init + capped mine (500 files) for ${PROJECT} (log: $LOG)"
  fi

  # Track this project in the weekly mine list (dedup)
  mkdir -p "$(dirname "$PROJECT_LIST")"
  ABS_PATH="$(pwd -W 2>/dev/null || pwd)"
  touch "$PROJECT_LIST"
  if ! grep -Fxq "$ABS_PATH" "$PROJECT_LIST" 2>/dev/null; then
    echo "$ABS_PATH" >> "$PROJECT_LIST"
  fi
fi

exit 0
