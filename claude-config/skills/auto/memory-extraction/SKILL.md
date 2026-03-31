---
name: memory-extraction
description: >
  Automatic memory extraction skill — triggered by file operations to extract durable
  learnings from session context. Runs in the background via the memory-extractor agent.
user-invocable: false
metadata:
  version: "2.0"
  effort: low
  auto-invocable: true
  category: auto
  compatible-claude-code:
    when_to_use: "Auto-triggered after significant session milestones"
    user-invocable: false
    context: fork
    allowed-tools: ["Read", "Write", "Edit", "Grep", "Glob"]
---

# Auto Memory Extraction

This skill runs automatically to extract durable memories from session context.
It is NOT user-invocable — it is triggered by the memory system.

## How It Works

1. The `@memory-extractor` subagent reviews session context
2. It extracts: decisions, corrections, preferences, connections, tools
3. It writes to `memory/` directory topic files
4. It updates `memory/MEMORY.md` index

## Manual Trigger

Use `/memory-sync` to manually trigger memory extraction from the current session.

## Files

- `memory/MEMORY.md` — topic index
- `memory/connections.md` — hosts, ports, endpoints
- `memory/decisions.md` — architecture choices
- `memory/lessons.md` — corrections and gotchas
- `memory/preferences.md` — workflow preferences
- `memory/tools.md` — discovered tools and utilities

## Rules

- Never store secrets (API keys, passwords, tokens)
- Keep entries concise — one line per memory
- Read before writing to avoid duplicates
- Delete stale info when noticed
