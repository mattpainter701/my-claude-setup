#!/bin/sh
# Weekly mempalace refresh — re-mines all projects in projects.list.
# Respects ChromaDB stable IDs (#716) so re-mining is idempotent (only new/changed files re-indexed).
# Lock file prevents overlap with other mine processes.

PROJECT_LIST="$HOME/.mempalace/projects.list"
LOCK="$HOME/.mempalace/.weekly-lock"
LOG="$HOME/.mempalace/weekly-refresh.log"

[ ! -f "$PROJECT_LIST" ] && exit 0

# Single-flight lock
if [ -f "$LOCK" ]; then
  LOCK_AGE=$(($(date +%s) - $(stat -c %Y "$LOCK" 2>/dev/null || echo 0)))
  # Stale lock (>2 hours old) — remove
  if [ "$LOCK_AGE" -gt 7200 ]; then
    rm -f "$LOCK"
  else
    echo "$(date): weekly refresh skipped — lock held (age ${LOCK_AGE}s)" >> "$LOG"
    exit 0
  fi
fi
echo $$ > "$LOCK"
trap 'rm -f "$LOCK"' EXIT INT TERM

echo "=== $(date): weekly refresh start ===" >> "$LOG"
while IFS= read -r PROJECT_DIR; do
  [ -z "$PROJECT_DIR" ] && continue
  [ ! -d "$PROJECT_DIR" ] && echo "skip: $PROJECT_DIR (missing)" >> "$LOG" && continue
  WING="$(basename "$PROJECT_DIR")"
  echo "--- mining $PROJECT_DIR (wing=$WING) ---" >> "$LOG"
  PYTHONUTF8=1 py -m mempalace mine "$PROJECT_DIR" \
    --mode projects --wing "$WING" >> "$LOG" 2>&1
done < "$PROJECT_LIST"
echo "=== $(date): weekly refresh done ===" >> "$LOG"
