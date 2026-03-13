#!/usr/bin/env bash
# Stop hook: differentiated completion tones
# Success (no recent errors) = ascending chirp, Error = descending tone
set -uo pipefail
export PATH="$PATH:$HOME/AppData/Local/Microsoft/WinGet/Links"

input=$(cat)

# Check if the last tool result contains error indicators
tool_result=$(echo "$input" | jq -r '.tool_result // empty' 2>/dev/null)
stop_reason=$(echo "$input" | jq -r '.stop_reason // empty' 2>/dev/null)

is_error=false
if echo "$tool_result" | grep -qiE 'FAILED|ERROR|Traceback|fatal:|BLOCKED'; then
  is_error=true
fi

if [ "$is_error" = true ]; then
  # Descending tone: error/failure
  powershell.exe -NoProfile -Command '[console]::beep(600,200); [console]::beep(400,300)' &>/dev/null &
else
  # Ascending chirp: success
  powershell.exe -NoProfile -Command '[console]::beep(600,150); [console]::beep(900,200)' &>/dev/null &
fi

exit 0
