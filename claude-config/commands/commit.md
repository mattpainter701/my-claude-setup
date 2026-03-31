---
description: Task-aware git commit with conventional format, TASKS.md/CHANGELOG.md enforcement
agent: code
subtask: true
---

You are creating a git commit. Follow these rules exactly.

## Step 1: Inspect Changes

Run these in parallel:
- `git status` (never use `-uall`)
- `git diff --cached --stat` (what's staged)
- `git diff --stat` (what's unstaged)
- `git log --oneline -5` (recent commit style)

If nothing is staged, stage the relevant files. Never use `git add -A` or `git add .` — add specific files by name. Never stage `.env`, credentials, or large binaries.

## Step 2: Check TASKS.md

If `TASKS.md` exists in the repo root:
- Read it. Check if any task checkboxes were touched in the staged diff.
- If work was done on a task but the checkbox isn't checked, ask the user before proceeding.
- Note the task number(s) for the commit message.

## Step 3: Check CHANGELOG.md

If `CHANGELOG.md` exists in the repo root:
- Read the top section. Check if there's an entry for the current version/sprint.
- If staged changes include feature/fix work but CHANGELOG.md wasn't updated, warn the user and offer to add an entry before committing.

## Step 4: Write Commit Message

Format: `type: description (Task NNN)`

Types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `perf`, `ci`

Rules:
- **NEVER** add `Co-Authored-By` lines. Not for Kilo, not for anyone.
- Imperative mood ("Add X", not "Added X" or "Adds X")
- First line under 72 characters
- Reference task numbers when applicable
- Use a HEREDOC for multi-line messages

## Step 5: Commit and Verify

```bash
git commit -m "$(cat <<'EOF'
type: description (Task NNN)

Optional body with details.
EOF
)"
```

Run `git status` after to verify the commit succeeded.
