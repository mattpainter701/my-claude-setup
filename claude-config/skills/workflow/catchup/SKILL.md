---
name: catchup
description: >
  Restore context after /clear — git state, branch, sprint, recent commits.
  Lightweight context recovery without starting work.
metadata:
  version: "2.0"
  effort: low
  auto-invocable: false
  category: workflow
  compatible-claude-code:
    when_to_use: "After /clear to restore project context"
    allowed-tools: ["Bash", "Read"]
---

# Catchup Skill

Usage: `/catchup [branch]`

Restore context after `/clear`. Use `$ARGUMENTS` for optional branch name.

## Process

1. **Git state** — run in parallel:
   - `git log --oneline -15` (or on the specified branch)
   - `git diff --stat HEAD`
   - `git status`
   - `git branch --show-current`

2. **Project state** — read these files (skip missing ones):
   - `TASKS.md` — first 30 lines (current sprint)
   - `CHANGELOG.md` — first 25 lines (latest version entry)
   - `memory/MEMORY.md` — if it exists, skim for "Current State"

3. **Output format** — print a concise summary:

```
Branch: <branch>
Version: <version from CHANGELOG>
Sprint: <number> — <theme>
Active tasks: <task numbers and one-line summaries>
Uncommitted: <file count> files changed
Recent work: <1-2 sentence summary of last 5 commits>
```

## Rules
- Do NOT read full file contents — just headers and summaries.
- Do NOT start working on tasks. This is context recovery only.
- Total output under 500 characters.
