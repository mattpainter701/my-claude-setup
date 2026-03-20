# Verify Skill

Usage: `/verify [quick|full|pre-commit|pre-pr]`

Run a quality gate on the current project before committing or opening a PR.
Parse `$ARGUMENTS` for the mode. Default: `full`.

## Modes

| Mode | Checks |
|-|-|
| `quick` | Build + types only |
| `full` | All checks (default) |
| `pre-commit` | Staged files: lint, types, secrets |
| `pre-pr` | Full + security scan |

## Process

### Step 1: Detect Project Type

Look for these markers (check in parallel):
- `pyproject.toml` or `setup.py` → Python
- `package.json` → Node.js/TypeScript
- `Cargo.toml` → Rust
- `go.mod` → Go
- `platformio.ini` → Embedded C/C++
- `*.kicad_pro` → KiCad (skip code checks, run DRC if available)

### Step 2: Run Checks (sequential, halt on first failure)

**Python projects:**
1. **Build/Import** — `py -c "import <package>"` or `py -m py_compile <main>.py`
2. **Types** — `py -m mypy --ignore-missing-imports .` (if mypy installed)
3. **Lint** — `py -m ruff check .` (if ruff installed)
4. **Tests** — `py -m pytest --tb=short -q` (if tests/ exists)
5. **Secrets** — Grep for `password=`, `api_key=`, `secret=`, `token=` with literal string values in staged files
6. **Debug artifacts** — Grep for `breakpoint()`, `pdb.set_trace()`, `print(` (warn only)

**Node.js/TypeScript projects:**
1. **Build** — `npm run build` or `npx tsc --noEmit`
2. **Types** — `npx tsc --noEmit` (if tsconfig exists)
3. **Lint** — `npx eslint .` or `npx biome check .`
4. **Tests** — `npm test`
5. **Secrets** — Same grep patterns
6. **Debug artifacts** — Grep for `console.log(`, `debugger;`

**Rust projects:**
1. **Build** — `cargo check`
2. **Lint** — `cargo clippy`
3. **Tests** — `cargo test`

### Step 3: Report

Output a concise summary:

```
Verify: <mode>
Project: <type> (<root dir>)

  Build:   PASS | FAIL | SKIP
  Types:   PASS | FAIL | SKIP | N/A
  Lint:    PASS | FAIL (N warnings) | SKIP
  Tests:   PASS (N passed) | FAIL (N failed) | SKIP
  Secrets: CLEAN | WARN (N found)
  Debug:   CLEAN | WARN (N found)

Result: READY | NOT READY
```

### Step 4: Security Scan (pre-pr mode only)

Spawn the security-reviewer agent on `git diff main...HEAD` (or staged changes if no PR branch).

## Rules

- Halt on build failure — don't run downstream checks on broken code.
- For `pre-commit` mode, only check staged files (`git diff --cached --name-only`).
- For `quick` mode, only run build + types.
- If a tool isn't installed (mypy, ruff, eslint), print SKIP, don't fail.
- Never modify files. Verification only.
