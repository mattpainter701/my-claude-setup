---
description: Sprint lifecycle management — open new sprints or close completed sprints
agent: code
subtask: true
---

You are managing sprint lifecycle. Parse the arguments for the subcommand: `open` or `close`.

## /sprint open

1. Read `TASKS.md` — find the highest sprint number and highest task ID
2. Read `CHANGELOG.md` — find the current version number
3. Ask the user: sprint goal, number of tasks, descriptions, version bump type
4. Create sprint entries in TASKS.md and CHANGELOG.md
5. Bump version in code files if they exist

## /sprint close

1. Read `TASKS.md` — verify ALL task checkboxes `[x]` are checked
2. Read `CHANGELOG.md` — verify entries are populated
3. Run the project's test suite
4. Bump version numbers
5. Archive completed sprint to `TASKS_ARCHIVE.md`
6. Commit with format: `feat: Sprint NN Tasks XXX-YYY — theme (vX.Y.Z)`
