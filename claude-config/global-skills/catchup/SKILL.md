---
name: catchup
description: >
  Restore project context after /clear. Summarizes git state, project state,
  and active tasks in under 500 characters. Context recovery only — no work.
allowed-tools:
  - Bash
  - Read
  - Grep
  - Glob
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
   - `.claude/CLAUDE.md` — first 10 lines (project identity)

3. **Output format** — print a concise summary:

```
Project: <name from CLAUDE.md or repo dir name>
Branch: <branch>
Version: <version from CHANGELOG or version file>
Sprint: <number> — <theme> (if TASKS.md exists)
Active tasks: <task numbers and one-line summaries>
Uncommitted: <file count> files changed
Recent work: <1-2 sentence summary of last 5 commits>
```

## Rules
- Do NOT read full file contents — just headers and summaries.
- Do NOT start working on tasks. This is context recovery only.
- Total output under 500 characters.
