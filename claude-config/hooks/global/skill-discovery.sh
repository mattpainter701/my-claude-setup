#!/usr/bin/env bash
# skill-discovery.sh — Reports available skills at session start
# Hook event: SessionStart
# Registers in ~/.claude/settings.json under hooks.SessionStart

set -euo pipefail

SKILL_DIRS=(
    "${HOME}/.claude/skills"
    "${HOME}/.config/kilo/skills"
    ".claude/skills"
    ".kilo/skills"
)

count=0
for dir in "${SKILL_DIRS[@]}"; do
    if [[ -d "$dir" ]]; then
        for skill_dir in "$dir"/*/; do
            if [[ -f "${skill_dir}SKILL.md" ]]; then
                count=$((count + 1))
            fi
        done
    fi
done

if [[ $count -gt 0 ]]; then
    echo "Skills: $count skills loaded"
fi

exit 0
