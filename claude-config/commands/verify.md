---
description: Run quality gate — build, types, lint, tests, secrets, debug artifacts
agent: code
subtask: true
---

Run a quality gate on the current project. Parse arguments for mode: `quick`, `full`, `pre-commit`, or `pre-pr`.

## Process

1. Detect project type (Python, Node.js, Rust, Go, Embedded, KiCad)
2. Run checks sequentially, halt on first failure:
   - Build/Import check
   - Type checking (mypy, tsc)
   - Linting (ruff, eslint, clippy)
   - Tests
   - Secrets scan
   - Debug artifact scan
3. Report results in table format
4. For pre-pr: spawn security-reviewer agent on the diff

## Output Format

```
Verify: <mode>
Project: <type>

  Build:   PASS | FAIL | SKIP
  Types:   PASS | FAIL | SKIP | N/A
  Lint:    PASS | FAIL (N warnings) | SKIP
  Tests:   PASS (N passed) | FAIL (N failed) | SKIP
  Secrets: CLEAN | WARN (N found)
  Debug:   CLEAN | WARN (N found)

Result: READY | NOT READY
```
