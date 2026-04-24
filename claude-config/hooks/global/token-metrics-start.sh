#!/bin/sh
# Log session start for token-metrics tracking.
# Silent (no user-facing output). Appends to ~/.claude/.token-metrics.

METRICS="$HOME/.claude/.token-metrics"
TS=$(date +%Y-%m-%dT%H:%M:%S%z)
PROJECT="$(basename "$PWD")"
# Try to read model from settings
MODEL=$(grep -oE '"model"[[:space:]]*:[[:space:]]*"[^"]*"' "$HOME/.claude/settings.json" 2>/dev/null | sed 's/.*"\([^"]*\)"$/\1/')
MODEL="${MODEL:-unknown}"

# Session id = epoch-pid for uniqueness within the metrics stream
SID="$(date +%s)-$$"
echo "session_start|sid=$SID|ts=$TS|project=$PROJECT|model=$MODEL" >> "$METRICS"
# Stash sid for the end hook to reference
echo "$SID" > "$HOME/.claude/.token-metrics.current-sid"
exit 0
