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

You are syncing session learnings to persistent files that the built-in auto-memory system **cannot** update: CLAUDE.md files, skill files, and project-local `memory/MEMORY.md`. This runs in a forked context to avoid bloating the main conversation.

## Scope — What This Skill Owns vs Auto-Memory

| Target | Owner | Examples |
|-|-|-|
| `~/.claude/projects/*/memory/*.md` | **Auto-memory** (built-in) | User prefs, feedback, project context, references |
| `~/.claude/CLAUDE.md` | **This skill** | Global workflow rules, tool prefs |
| `.claude/CLAUDE.md` | **This skill** | Project-specific safety rules, conventions |
| `memory/MEMORY.md` (project-local) | **This skill** | Connection methods, architecture, sprint state |
| `~/.claude/skills/*/SKILL.md` | **This skill** | Pitfalls, patterns, dimensions, changelog |

**Do NOT save here** (auto-memory handles these):
- User role, preferences, or knowledge level → auto-memory `user` type
- Feedback on Claude's approach ("don't do X", "yes, keep doing that") → auto-memory `feedback` type
- Pointers to external systems (Linear projects, Grafana boards) → auto-memory `reference` type
- One-off project context that doesn't affect file conventions → auto-memory `project` type

## When to Trigger

Auto-invoke when ANY of these occur during a session:
- A new SSH host, API endpoint, device address, or connection method was used
- A workflow rule was established that should be enforced via CLAUDE.md (not just remembered)
- A project convention was discovered that isn't documented in CLAUDE.md
- A sprint was opened or closed (version state changed)
- A skill was used and a pitfall, correction, or new pattern was confirmed
- A significant debugging session revealed non-obvious gotchas worth codifying

**Do NOT trigger for:**
- Code patterns, architecture, or file paths derivable from reading the codebase
- Git history or who-changed-what (use `git log`/`git blame`)
- Debugging solutions (the fix is in the code; the commit message has context)
- Ephemeral task state or current conversation context
- Anything the user said to "remember" that fits auto-memory types above

## What to Update (priority order)

### 1. Skill Files (`~/.claude/skills/*/SKILL.md` or `.claude/skills/*/SKILL.md`)

Highest value — skills compound. Only update skills that were actually used in the session AND any of these occurred:

- A pitfall/gotcha was discovered (e.g., "OLED shelf creates split-body in slicer")
- A pattern or technique worked well and should be reusable
- The user corrected the skill's output (wrong default, missing step, bad assumption)
- A new tool integration was discovered
- Component dimensions were verified against real hardware
- A workflow step was missing or in the wrong order

**Where to add:**
- **Pitfalls/gotchas** → `## Pitfalls` or `## Common Pitfalls` section
- **New patterns** → relevant patterns section
- **Corrections** → fix wrong content in-place
- **New dimensions/specs** → reference tables
- **Workflow changes** → process section
- **Session learning** → `## Changelog` at bottom

**Changelog format:**
```markdown
## Changelog
- 2026-03-12: Added split-body pitfall for slicer import (OLED shelf was disconnected geometry)
```

**Rules:**
- Only add verified learnings (tested and confirmed)
- Keep entries concise — one line per learning
- Don't duplicate content already in the skill body (move it to the right section instead)

### 2. CLAUDE.md Files

**Global (`~/.claude/CLAUDE.md`)** — only rules that apply across ALL projects:
- Workflow corrections the user gave (e.g., "never do X")
- Tool preferences (e.g., "always use py not python")

**Project (`.claude/CLAUDE.md`)** — project-specific:
- Safety rules or conventions specific to this project
- Proactive behavior rules (e.g., "before doing X, always check Y")

### 3. Project Memory (`memory/MEMORY.md`)

Lowest priority — only for structured project state that doesn't fit CLAUDE.md:
- **Connection methods:** host, port, user, auth, gotchas
- **Current state:** version, sprint status
- **Architecture patterns:** new modules, data flows, integration points
- **Gotchas:** non-obvious issues that wasted debugging time

## Rules

1. **Read before writing.** Always read the target file first to avoid duplicates.
2. **Merge, don't append.** Update existing sections rather than adding new ones when the topic already exists.
3. **Keep MEMORY.md under 200 lines.** It's loaded into every conversation context. Be ruthless about conciseness.
4. **Never store secrets.** No API keys, passwords, or tokens. Store the pattern (e.g., "uses env var FREESOUND_API_KEY") not the value.
5. **Verify before writing.** Don't write speculative or unverified information. If you saw it work, write it.
6. **Delete stale info.** If you notice outdated entries (old versions, removed files, changed patterns), remove them.
7. **Check auto-memory first.** If the learning fits a `user`, `feedback`, `project`, or `reference` memory type, let auto-memory handle it. Only use this skill for CLAUDE.md, skill files, and project-local MEMORY.md.
