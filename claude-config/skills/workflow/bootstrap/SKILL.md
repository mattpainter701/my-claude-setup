---
name: bootstrap
description: Bootstrap or refresh a Claude Code setup from this repo. Use when Claude needs to install or update global ~/.claude files, scaffold a project's .claude directory, wire MCP/docs plugins, or configure the built-in /statusline flow.
argument-hint: "[global|project|mcp|statusline]"
allowed-tools:
  - Bash
  - Read
  - Grep
  - Glob
  - Edit
  - Write
disable-model-invocation: true
---

# Bootstrap Skill

Usage: `/bootstrap [global|project|mcp|statusline]`

Parse `$ARGUMENTS`. Default to `project` when working inside an application repo and `global` when working inside this setup repo.

## Modes

### `global`

- Copy global rules, skills, agents, hooks, rules, and helper scripts into `~/.claude/`.
- Merge `~/.claude/settings.json` instead of overwriting unrelated user settings.
- After copying, run `/doctor quick`.

### `project`

- Create `.claude/`, `.claude/hooks/`, and `.claude/rules/` if needed.
- Copy the project stencil, selected project hooks, and a starter `.claude/settings.local.json`.
- Keep private machine notes in `CLAUDE.local.md`, not `.claude/CLAUDE.md`.
- After scaffolding, run `/doctor full`.

### `mcp`

- Prefer enabling docs/search MCP servers that improve research and security review, especially Context7-style docs tools.
- If tools are absent, explain the gap and point the user at Claude Code's `/mcp` or `/plugin` flows.
- Do not invent tool names; inspect current configuration first.

### `statusline`

- Prefer Claude Code's built-in `/statusline` command over hand-editing old prompt glue.
- Propose a short status line that emphasizes branch, dirty state, active todo count, and turn duration.
- If the user wants persistence, update the appropriate settings file rather than leaving a one-off suggestion.

## Rules

- Never overwrite secrets, local credentials, or private notes.
- When both repo-local templates and installed `~/.claude` copies exist, prefer the repo-local source you are actively editing.
- If JSON settings already contain hooks or MCP blocks, merge carefully instead of replacing arrays blindly.
