#!/bin/sh
# Log session end with heuristic token-savings estimate.
# Appends to ~/.claude/.token-metrics and updates .token-savings-estimate.
# Also writes a per-project memory note if memory/ directory exists.
#
# Savings estimate methodology (transparent heuristic, NOT a measurement):
#   - 35% blended conservative estimate (matches the other-machine setup)
#   - Based on: Code Review Graph (~98% on structured code queries),
#              mempalace (~50% on cross-session recall),
#              terseness rules (~15-20% on output)
#   - We don't have per-call token counts, so this is a ballpark.

METRICS="$HOME/.claude/.token-metrics"
ESTIMATE_FILE="$HOME/.claude/.token-savings-estimate"
SID_FILE="$HOME/.claude/.token-metrics.current-sid"
TS=$(date +%Y-%m-%dT%H:%M:%S%z)
PROJECT="$(basename "$PWD")"

SID="unknown"
[ -f "$SID_FILE" ] && SID=$(cat "$SID_FILE")

# Count tool uses in the current session if transcript is available.
# Claude Code transcripts live under ~/.claude/projects/<enc-path>/
TOOL_HITS=0
if [ -d "$HOME/.claude/projects" ]; then
  LATEST_JSONL=$(find "$HOME/.claude/projects" -name "*.jsonl" -type f -newermt "-30 minutes" 2>/dev/null | head -1)
  if [ -n "$LATEST_JSONL" ] && [ -f "$LATEST_JSONL" ]; then
    TOOL_HITS=$(grep -c '"type":"tool_use"' "$LATEST_JSONL" 2>/dev/null || echo 0)
  fi
fi

# Heuristic: assume each tool hit without CRG would cost ~3000 tokens (file read + context),
# with CRG/mempalace → ~900 tokens. Diff per hit ≈ 2100. 35% blended savings.
SAVED_PER_HIT=2100
SAVED=$((TOOL_HITS * SAVED_PER_HIT * 35 / 100))

echo "session_end|sid=$SID|ts=$TS|project=$PROJECT|tool_hits=$TOOL_HITS|est_tokens_saved=$SAVED" >> "$METRICS"

# Cumulative savings counter
PREV=0
[ -f "$ESTIMATE_FILE" ] && PREV=$(cat "$ESTIMATE_FILE" 2>/dev/null | head -1 | grep -oE '[0-9]+' | head -1)
NEW=$((PREV + SAVED))
printf "%s tokens (cumulative across %s sessions)\n" "$NEW" "$(grep -c "^session_end" "$METRICS" 2>/dev/null)" > "$ESTIMATE_FILE"

# Optional: project memory note — only write if memory/ or .claude/memory/ exists
for MEMDIR in "memory" ".claude/memory"; do
  if [ -d "$MEMDIR" ]; then
    NOTE="$MEMDIR/token_metrics_session.md"
    {
      echo "# Token metrics — last session"
      echo ""
      echo "- Ended: $TS"
      echo "- Project: $PROJECT"
      echo "- Tool hits: $TOOL_HITS"
      echo "- Est. tokens saved this session: $SAVED (heuristic @ 35% blended)"
      echo "- Cumulative: $NEW tokens"
      echo ""
      echo "_Heuristic only — assumes 2100 tokens saved per tool hit when CRG/mempalace available._"
    } > "$NOTE"
    break
  fi
done

rm -f "$SID_FILE"
exit 0
