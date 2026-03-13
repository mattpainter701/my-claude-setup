#!/usr/bin/env bash
# Notification hook: Windows toast when Claude needs permission approval
# Requires BurntToast module: Install-Module -Name BurntToast
set -uo pipefail

input=$(cat)
notification_type=$(echo "$input" | jq -r '.notification_type // "unknown"' 2>/dev/null)

case "$notification_type" in
  permission_prompt)
    # Toast notification + attention tone
    powershell.exe -NoProfile -Command '
      [console]::beep(1000,100); [console]::beep(1000,100);
      if (Get-Module -ListAvailable -Name BurntToast -ErrorAction SilentlyContinue) {
        Import-Module BurntToast;
        New-BurntToastNotification -Text "Claude Code","Waiting for permission approval" -Silent
      }
    ' &>/dev/null &
    ;;
  idle_prompt)
    # Low tone for idle
    powershell.exe -NoProfile -Command '[console]::beep(400,200)' &>/dev/null &
    ;;
esac

exit 0
