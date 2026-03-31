---
name: agent_authoring
description: Guidance for editing Claude Code agents. Use when Claude touches agent markdown files so tool scopes, MCP wiring, memory scope, isolation, and agent hooks are configured safely.
user-invocable: false
paths:
  - claude-config/agents/**
  - .claude/agents/**
allowed-tools:
  - Read
  - Grep
  - Glob
  - Edit
  - Write
  - Bash
---

# Agent Authoring

When editing agents:

- Prefer explicit `tools` lists for read-only agents. Use wildcard plus `disallowedTools` only when you truly need the broad tool pool.
- Use `mcpServers` to add docs/search tooling without hardcoding MCP tool names into the agent prompt.
- Use `initialPrompt` for short steering that should apply on every spawn; keep the main prompt focused on durable review or execution behavior.
- `memory: project` is for reusable repo knowledge. `memory: local` is for machine-specific workflows that should not leak across environments.
- `background: true` is for long-running monitors or validators that do not need to block the main thread.
- Agent `hooks` are session-scoped to the agent lifetime. `Stop` hooks become `SubagentStop`, so keep them outcome-oriented and lightweight.
