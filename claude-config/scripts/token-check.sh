#!/bin/sh
# token-check.sh — health diagnostic for token-saving tools
# Usage: bash ~/.claude/scripts/token-check.sh [project-dir]
# Defaults to current directory.

PROJECT_DIR="${1:-$PWD}"
cd "$PROJECT_DIR" 2>/dev/null || { echo "bad project dir: $PROJECT_DIR"; exit 1; }
PROJECT="$(basename "$PROJECT_DIR")"

GREEN='\033[0;32m'; RED='\033[0;31m'; YLW='\033[0;33m'; NC='\033[0m'
ok()   { printf "  ${GREEN}✓${NC} %s\n" "$1"; }
fail() { printf "  ${RED}✗${NC} %s\n" "$1"; }
warn() { printf "  ${YLW}~${NC} %s\n" "$1"; }

echo "===================================================="
echo "  Token Optimization Health Check"
echo "  Project: $PROJECT"
echo "===================================================="
echo ""

# --- 1. code-review-graph ---
echo "[1] code-review-graph"
if ! command -v code-review-graph >/dev/null 2>&1; then
  fail "CLI not installed  (fix: pip install code-review-graph)"
else
  VER=$(code-review-graph --version 2>&1 | head -1 | awk '{print $NF}')
  ok "CLI installed: $VER"
  if [ -d .code-review-graph ]; then
    STATUS=$(code-review-graph status 2>&1)
    NODES=$(echo "$STATUS" | grep -E "^Nodes:" | awk '{print $2}')
    EDGES=$(echo "$STATUS" | grep -E "^Edges:" | awk '{print $2}')
    FILES=$(echo "$STATUS" | grep -E "^Files:" | awk '{print $2}')
    LAST=$(echo "$STATUS" | grep -E "^Last updated:" | cut -d: -f2- | xargs)
    if [ "${NODES:-0}" -gt 0 ] 2>/dev/null; then
      ok "graph populated: $NODES nodes, $EDGES edges, $FILES files"
      ok "last build: $LAST"
    else
      warn "graph directory exists but empty (fix: code-review-graph build)"
    fi
  else
    warn "no graph in this project (fix: code-review-graph build)"
  fi
  # MCP registration check
  if grep -q '"code-review-graph"' "$HOME/.claude.json" 2>/dev/null; then
    ok "MCP server registered (user scope)"
  else
    fail "MCP not registered  (fix: claude mcp add code-review-graph -s user -- uvx code-review-graph serve)"
  fi
fi
echo ""

# --- 2. mempalace ---
echo "[2] mempalace (semantic memory)"
if ! py -c "import mempalace" 2>/dev/null; then
  fail "not installed  (fix: py -m pip install mempalace)"
else
  VER=$(py -m pip show mempalace 2>/dev/null | grep ^Version | awk '{print $2}')
  ok "package installed: $VER"
  PALACE="$HOME/.mempalace/palace"
  if [ -d "$PALACE" ]; then
    SIZE=$(du -sh "$PALACE" 2>/dev/null | awk '{print $1}')
    ok "palace exists: $SIZE"
  else
    warn "palace not initialized (fix: py -m mempalace init --yes ~/.mempalace)"
  fi
  if [ -f mempalace.yaml ]; then
    ok "project initialized (wing=$(grep '^wing:' mempalace.yaml | awk '{print $2}'))"
  else
    warn "this project not initialized for mempalace"
  fi
  if grep -q '"mempalace"' "$HOME/.claude.json" 2>/dev/null; then
    ok "MCP server registered (user scope)"
  else
    fail "MCP not registered  (fix: claude mcp add mempalace -s user -e PYTHONUTF8=1 -- py -m mempalace.mcp_server)"
  fi
  if [ -f "$HOME/.mempalace/projects.list" ]; then
    N=$(wc -l < "$HOME/.mempalace/projects.list" 2>/dev/null)
    ok "weekly refresh list: $N project(s) tracked"
  fi
fi
echo ""

# --- 3. Terseness directives (CTE) ---
echo "[3] Claude Token Efficient (terseness rules)"
if grep -q "Token Optimization Strategy" "$HOME/.claude/CLAUDE.md" 2>/dev/null; then
  STRAT=$(grep -cE "^### [1-9]\." "$HOME/.claude/CLAUDE.md" 2>/dev/null | head -1)
  ok "directives present in global CLAUDE.md ($STRAT sections)"
else
  fail "missing from ~/.claude/CLAUDE.md"
fi
echo ""

# --- 4. Session hooks ---
echo "[4] Session hooks"
SETTINGS="$HOME/.claude/settings.json"
if grep -q "token-tools-auto-setup.sh" "$SETTINGS" 2>/dev/null; then
  ok "SessionStart: auto-setup registered"
else
  fail "SessionStart auto-setup not registered"
fi
if grep -q "token-metrics-start.sh" "$SETTINGS" 2>/dev/null; then
  ok "SessionStart: metrics logger registered"
else
  warn "metrics logger not registered"
fi
if grep -q "token-metrics-end.sh" "$SETTINGS" 2>/dev/null; then
  ok "SessionEnd: metrics logger registered"
else
  warn "SessionEnd metrics not registered"
fi
if grep -q "code-review-graph update" "$SETTINGS" 2>/dev/null; then
  ok "PostToolUse: CRG incremental update registered"
else
  fail "PostToolUse CRG update missing"
fi
echo ""

# --- 5. Metrics tracking ---
echo "[5] Token metrics"
METRICS="$HOME/.claude/.token-metrics"
if [ -f "$METRICS" ]; then
  SESSIONS=$(grep -c "^session_start" "$METRICS" 2>/dev/null)
  ENDED=$(grep -c "^session_end" "$METRICS" 2>/dev/null)
  ok "log exists: $SESSIONS started, $ENDED ended"
  if [ -f "$HOME/.claude/.token-savings-estimate" ]; then
    CUMULATIVE=$(cat "$HOME/.claude/.token-savings-estimate" 2>/dev/null)
    ok "cumulative estimated savings: $CUMULATIVE"
  fi
else
  warn "no metrics yet (will log on next session start/end)"
fi
echo ""

# --- 6. Weekly scheduled task ---
echo "[6] Scheduled maintenance"
if schtasks //Query //TN "MemPalace-Weekly-Refresh" //FO LIST 2>/dev/null | grep -q "TaskName"; then
  NEXT=$(schtasks //Query //TN "MemPalace-Weekly-Refresh" //FO LIST 2>/dev/null | grep "Next Run Time" | cut -d: -f2- | xargs)
  ok "weekly refresh scheduled (next: $NEXT)"
else
  fail "weekly refresh task not registered"
fi
echo ""

echo "===================================================="
echo "  Done."
echo "===================================================="
