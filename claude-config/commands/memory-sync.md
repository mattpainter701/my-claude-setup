---
description: Extract and sync durable memories from current session context
agent: memory-extractor
subtask: true
---

Extract durable memories from the current session and write them to the memory directory.

## Process

1. Review the current session context for durable learnings:
   - Decisions made (architecture, library choices, trade-offs)
   - Corrections (wrong assumptions, fixed misconceptions)
   - Preferences (workflow choices, tool preferences)
   - Connections (hosts, endpoints, auth methods — NOT secrets)
   - Tools discovered (new utilities, scripts, integrations)

2. Read existing memory files to avoid duplicates
3. Write new entries to the appropriate topic file
4. Update `memory/MEMORY.md` index

## Rules

- Never store secrets (API keys, passwords, tokens)
- Keep entries concise — one line per memory
- Read before writing to avoid duplicates
- Only extract verified information from the session
