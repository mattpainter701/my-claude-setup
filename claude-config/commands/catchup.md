---
description: Restore context after /clear — git state, branch, sprint, recent commits
agent: general
subtask: true
---

Restore project context after a /clear. Parse arguments for optional branch name.

## Process

1. Run in parallel:
   - `git log --oneline -15`
   - `git diff --stat HEAD`
   - `git status`
   - `git branch --show-current`

2. Read these files (skip missing ones):
   - `TASKS.md` — first 30 lines
   - `CHANGELOG.md` — first 25 lines
   - `memory/MEMORY.md` — skim for "Current State"

3. Output concise summary (under 500 chars):

```
Branch: <branch>
Version: <version>
Sprint: <number> — <theme>
Active tasks: <task numbers>
Uncommitted: <file count> files
Recent work: <1-2 sentence summary>
```
