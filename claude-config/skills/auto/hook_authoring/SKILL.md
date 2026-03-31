---
name: hook_authoring
description: Guidance for editing Claude Code hooks. Use when Claude touches hook scripts, hook JSON, or settings files that register hooks so matcher selection, shell choice, timeouts, and blocking behavior stay correct.
user-invocable: false
paths:
  - claude-config/hooks/**
  - .claude/hooks/**
  - .claude/settings.json
  - .claude/settings.local.json
allowed-tools:
  - Read
  - Grep
  - Glob
  - Edit
  - Write
  - Bash
---

# Hook Authoring

When editing Claude Code hooks:

- Prefer deterministic `command` hooks first. Use `prompt` or `agent` hooks only when shell logic cannot express the check cleanly.
- Keep matchers narrow. Add `if`, `timeout`, and `statusMessage` on expensive hooks so they do not silently become session drag.
- Bash hooks on Windows assume Git Bash. Use `jq -r` into quoted variables or `read -r` pipelines; do not use unquoted `xargs` for file paths.
- Pipe-test raw hook commands with synthetic stdin JSON before adding `|| true`, `2>/dev/null`, or async behavior.
- Use `agent` hooks only for high-signal pass/block checks. Keep prompts pass-biased and block only on concrete regressions.
- When changing settings files, merge with existing hook arrays instead of overwriting unrelated user or project hooks.
