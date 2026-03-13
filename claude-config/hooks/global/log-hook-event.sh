#!/usr/bin/env bash
# Log hook events to JSONL for session-mine analysis
set -euo pipefail

LOG_DIR="$HOME/.claude/hook-logs"
mkdir -p "$LOG_DIR"

input=$(cat)
timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
event_type="${CLAUDE_HOOK_EVENT_NAME:-unknown}"
session_id="${CLAUDE_SESSION_ID:-unknown}"

echo "{\"ts\":\"$timestamp\",\"event\":\"$event_type\",\"session\":\"$session_id\"}" \
  >> "$LOG_DIR/events.jsonl"

exit 0
