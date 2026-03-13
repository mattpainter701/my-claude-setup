---
name: sprint
description: >
  Sprint lifecycle management. Open new sprints (create TASKS.md entries, version placeholder)
  or close sprints (verify completion, bump versions, archive, commit).
disable-model-invocation: true
allowed-tools:
  - Bash
  - Read
  - Edit
  - Grep
  - Glob
  - AskUserQuestion
---

# Sprint Skill

Usage: `/sprint open` or `/sprint close`

Parse `$ARGUMENTS` for the subcommand. If missing, ask the user.

---

## `/sprint open`

### Step 1: Read Current State
- Read `TASKS.md` — find the highest sprint number and highest task ID
- Read `CHANGELOG.md` — find the current version number
- Next sprint = highest + 1. Next task ID = highest + 1.

### Step 2: Gather Sprint Details
Ask the user (use AskUserQuestion):
- Sprint goal / theme (1-line summary)
- Number of tasks (typically 3-4)
- Brief description of each task
- Version bump: minor (X.Y+1.0) or patch (X.Y.Z+1)

### Step 3: Create Sprint Entries

**TASKS.md** — Add at the top (below the header/process note):
```markdown
## Sprint NN — Theme Title (vX.Y.Z)

**Goal:** One-line goal description.

### XXX. Task title (COMPLEXITY)

- [ ] Subtask description
- [ ] Subtask description

Files: `relevant/file/paths.py`
```

**CHANGELOG.md** — Add new version at the top:
```markdown
## [X.Y.Z] - YYYY-MM-DD

### Sprint NN — Theme Title

### Added
- (to be filled during sprint)

### Changed

### Fixed

### Tests
```

### Step 4: Bump Version (if version files exist)
Search for `__version__` in `*/__init__.py` and `version` in `pyproject.toml`. Update all to the new version.

---

## `/sprint close`

### Step 1: Verify Completion
- Read `TASKS.md` — find the current sprint section
- Check that ALL task checkboxes `[x]` are checked
- If any are unchecked, warn the user and list the incomplete items. Do NOT proceed unless user confirms.

### Step 2: Verify CHANGELOG.md
- Read `CHANGELOG.md` — find the current version entry
- Verify it has content in Added/Changed/Fixed/Tests sections (not just placeholders)
- If empty, warn the user.

### Step 3: Run Full Test Suite
```bash
py -m pytest tests/ varta_core/tests/ varta_max/testing/ tests/e2e/ --tb=short
```
If tests fail, stop and report. Do NOT proceed with closing.

### Step 4: Bump Version (if not already done in open)
Grep for `__version__` and `version =` across the project. Update all to the sprint version.

### Step 5: Archive Sprint
- Move the completed sprint section from `TASKS.md` to `TASKS_ARCHIVE.md` (append at top, below header)
- Keep the TASKS.md header and process note intact

### Step 6: Commit
Use the commit skill format:
```
feat: Sprint NN Tasks XXX-YYY — theme title (vX.Y.Z)
```

### Step 7: Report
Print summary: version, task count, test count, files changed.
