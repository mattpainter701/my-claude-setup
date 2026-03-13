---
name: memory-sync
description: >
  Proactively sync session learnings to persistent memory files.
  Auto-invoked after significant work milestones. Keeps memory current
  without user prompting.
user-invocable: false
context: fork
allowed-tools:
  - Read
  - Edit
  - Write
  - Grep
  - Glob
---

# Memory Sync Skill

You are syncing session learnings to persistent memory. This runs in a forked context to avoid bloating the main conversation.

## When to Trigger

Auto-invoke this skill when ANY of these occur during a session:
- A new SSH host, API endpoint, device address, or connection method was used
- A workflow rule was established or corrected by the user
- A recurring mistake was made that suggests a missing rule
- A project convention was discovered that isn't documented
- The user explicitly said "remember this" or "always do X"
- A sprint was opened or closed (version state changed)
- A significant debugging session revealed non-obvious gotchas

## What to Update

### Project Memory (`memory/MEMORY.md`)
- **Current State:** version, sprint status, test counts
- **Connection methods:** host, port, user, auth, gotchas
- **Architecture patterns:** new modules, data flows, integration points
- **Test patterns:** new fixture patterns, failure modes, workarounds
- **Sprint summaries:** what was done, key decisions
- **Gotchas:** non-obvious issues that wasted time

### Global CLAUDE.md (`~/.claude/CLAUDE.md`)
- Only add rules that genuinely apply across ALL projects
- Workflow corrections the user gave (e.g., "never do X")
- Tool preferences (e.g., "always use py not python")

### Project CLAUDE.md (`.claude/CLAUDE.md`)
- New safety rules or conventions specific to this project
- Proactive behavior additions (e.g., "before doing X, always check Y")

### Skill Files (`~/.claude/skills/*/SKILL.md` or `.claude/skills/*/SKILL.md`)
Skills are living documents. When a skill was used in the session AND any of these occurred, update the skill file directly:

**Triggers for skill updates:**
- A pitfall/gotcha was discovered during skill use (e.g., "OLED shelf creates split-body in slicer")
- A pattern or technique worked well and should be reusable (e.g., a new enclosure pattern)
- The user corrected the skill's output (wrong default, missing step, bad assumption)
- A new tool integration was discovered (e.g., "Bambu Studio auto-splits disconnected bodies")
- Component dimensions were verified against real hardware (update dimension tables)
- A workflow step was missing or in the wrong order

**Where to add in the skill file:**
- **Pitfalls/gotchas** → add to a `## Pitfalls` or `## Common Pitfalls` section
- **New patterns** → add to the relevant patterns section
- **Corrections** → fix the wrong content in-place
- **New dimensions/specs** → update reference tables
- **Workflow changes** → update the workflow/process section
- **Session learning** → append to `## Changelog` at bottom of skill file

**Format for changelog entries:**
```markdown
## Changelog
- 2026-03-12: Added split-body pitfall for slicer import (OLED shelf was disconnected geometry)
- 2026-03-12: Increased antenna hole to 12mm for rubber duck pass-through
```

**Rules:**
- Only update skills that were actually used in the session
- Only add verified learnings (things that were tested and confirmed)
- Keep entries concise — one line per learning
- Don't duplicate content already in the skill body (move it to the right section instead)

## Rules

1. **Read before writing.** Always read the target file first to avoid duplicates.
2. **Merge, don't append.** Update existing sections rather than adding new ones when the topic already exists.
3. **Keep MEMORY.md under 200 lines.** It's loaded into every conversation context. Be ruthless about conciseness.
4. **Never store secrets.** No API keys, passwords, or tokens in memory files. Store the pattern (e.g., "uses env var FREESOUND_API_KEY") not the value.
5. **Verify before writing.** Don't write speculative or unverified information. If you saw it work, write it. If you read it in one file, cross-check first.
6. **Delete stale info.** If you notice outdated entries (old versions, removed files, changed patterns), remove them.
