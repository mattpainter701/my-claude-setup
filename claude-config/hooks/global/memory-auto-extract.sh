#!/usr/bin/env bash
# memory-auto-extract.sh — Triggers memory extraction at end of session
# Hook event: Stop (end of assistant response)
# Registers in ~/.claude/settings.json under hooks.Stop

set -euo pipefail

# Only run every N turns to avoid overhead
# Check if a marker file exists and is recent (within 5 minutes)
MARKER_DIR="${HOME}/.claude/.memory-extract-marker"
mkdir -p "$MARKER_DIR"
MARKER_FILE="$MARKER_DIR/last_run"

if [[ -f "$MARKER_FILE" ]]; then
    LAST_RUN=$(cat "$MARKER_FILE" 2>/dev/null || echo "0")
    NOW=$(date +%s)
    DIFF=$((NOW - LAST_RUN))
    # Run at most once every 5 minutes (300 seconds)
    if [[ $DIFF -lt 300 ]]; then
        exit 0
    fi
fi

# Update marker
date +%s > "$MARKER_FILE"

# Run memory extraction script in background
SCRIPT_PATH="${HOME}/.claude/scripts/memory_extract.py"
if [[ -f "$SCRIPT_PATH" ]]; then
    # Run silently in background — don't block the session
    py "$SCRIPT_PATH" 7 --output-dir "memory/" > /dev/null 2>&1 &
fi

exit 0
