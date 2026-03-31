# Plan: Claude Code Source-Inspired Enhancement

## Context

Reviewed two repos:
- **Local**: `my-claude-setup` — 17 skills, 8 agents, 10 hooks, 3-tier config for Kilo/Claude Code
- **GitHub**: `mattpainter701/claude-code` — ~512K-line Anthropic source snapshot showing internal skill system, memory extraction, coordinator, MCP integration, permission hooks

**Goal**: Full restructure leveraging Claude Code source patterns, compatible with both Kilo CLI and Claude Code.

---

## Phase 1: Directory Restructure

**Eliminate duplication** — `skills/` is a subset of `claude-config/global-skills/`. Merge into canonical structure.

### New Structure
```
my-claude-setup/
├── README.md
├── AGENTS.md
├── CHANGELOG.md
├── TASKS.md
├── kilo.json                          # Kilo-native config (agents, skills paths)
├── claude-config/
│   ├── CLAUDE.global.md               # Global rules (unchanged core)
│   ├── agents/                        # Custom subagents
│   │   ├── code-reviewer.md
│   │   ├── session-analyst.md
│   │   ├── hardware-reviewer.md
│   │   ├── research-analyst.md
│   │   ├── bom-auditor.md
│   │   ├── deployment-validator.md
│   │   ├── sprint-planner.md
│   │   ├── security-reviewer.md
│   │   └── memory-extractor.md        # NEW: auto-memory subagent
│   ├── skills/                        # ALL skills (single canonical location)
│   │   ├── workflow/
│   │   │   ├── commit/SKILL.md
│   │   │   ├── sprint/SKILL.md
│   │   │   ├── research/SKILL.md
│   │   │   ├── review/SKILL.md
│   │   │   ├── verify/SKILL.md
│   │   │   ├── catchup/SKILL.md
│   │   │   ├── session_mine/SKILL.md
│   │   │   └── memory_sync/SKILL.md
│   │   ├── hardware/
│   │   │   ├── kicad/
│   │   │   │   ├── SKILL.md
│   │   │   │   ├── scripts/
│   │   │   │   └── references/
│   │   │   ├── bom/
│   │   │   │   ├── SKILL.md
│   │   │   │   ├── scripts/
│   │   │   │   └── references/
│   │   │   ├── digikey/
│   │   │   │   ├── SKILL.md
│   │   │   │   └── scripts/
│   │   │   ├── mouser/
│   │   │   │   ├── SKILL.md
│   │   │   │   └── scripts/
│   │   │   ├── lcsc/
│   │   │   │   ├── SKILL.md
│   │   │   │   └── scripts/
│   │   │   ├── element14/
│   │   │   │   ├── SKILL.md
│   │   │   │   └── scripts/
│   │   │   ├── jlcpcb/
│   │   │   │   ├── SKILL.md
│   │   │   │   └── scripts/
│   │   │   ├── pcbway/
│   │   │   │   └── SKILL.md
│   │   │   └── openscad/
│   │   │       └── SKILL.md
│   │   └── auto/
│   │       └── memory-extraction/     # NEW: conditional auto-skill
│   │           └── SKILL.md
│   ├── commands/                      # Kilo workflows (slash commands)
│   │   ├── commit.md                  # /commit workflow
│   │   ├── sprint.md                  # /sprint workflow
│   │   ├── research.md                # /research workflow
│   │   ├── review.md                  # /review workflow
│   │   ├── verify.md                  # /verify workflow
│   │   ├── catchup.md                 # /catchup workflow
│   │   ├── session-mine.md            # /session-mine workflow
│   │   └── memory-sync.md             # /memory-sync workflow
│   ├── hooks/                         # Shell hook scripts
│   │   ├── global/
│   │   │   ├── auto-lint.sh
│   │   │   ├── block-coauthored.sh
│   │   │   ├── notify-done.sh
│   │   │   ├── notify-permission.sh
│   │   │   ├── session-context.sh
│   │   │   └── log-hook-event.sh
│   │   └── project-stencil/
│   │       ├── commit-test-gate.sh
│   │       ├── commit-docs-gate.sh
│   │       ├── mark-tests-passed.sh
│   │       └── pre-compact-context.sh
│   ├── rules/                         # Glob-scoped file-type rules
│   │   ├── python.md
│   │   ├── kicad.md
│   │   └── shell-scripts.md
│   ├── project-stencil/
│   │   └── CLAUDE.project.md
│   └── scripts/
│       ├── perplexity_search.py
│       └── session_mine.py
└── memory/                            # NEW: auto-memory directory
    └── MEMORY.md                      # Topic index (auto-maintained)
```

### What Changes
- **Delete** `skills/` directory (all content is duplicated in `global-skills/`)
- **Rename** `global-skills/` → `skills/` with `workflow/` and `hardware/` sub-grouping
- **Create** `commands/` directory for Kilo workflows (`.kilo/commands/` compatible)
- **Create** `memory/` directory for auto-extracted memories
- **Create** `skills/auto/` for background automation skills
- **Move** `hooks/global/` and `hooks/project-stencil/` (already correct)
- **Add** `kilo.json` for Kilo-native agent/skill config

---

## Phase 2: Kilo-Native Agent Config

Convert agent profiles to Kilo's `.kilo/agents/*.md` format (also works as `.claude/agents/*.md`).

### `kilo.json`
```json
{
  "$schema": "https://app.kilo.ai/config.json",
  "skills": {
    "paths": ["./claude-config/skills/workflow", "./claude-config/skills/hardware", "./claude-config/skills/auto"]
  },
  "agent": {
    "code-reviewer": {
      "description": "Fresh-context code review via isolated subagent",
      "mode": "subagent",
      "model": "anthropic/claude-opus-4-20250514",
      "permission": { "edit": "deny", "bash": { "*": "deny", "git *": "allow" } }
    },
    "memory-extractor": {
      "description": "Auto-extracts durable memories from session context",
      "mode": "subagent",
      "model": "anthropic/claude-sonnet-4-20250514",
      "permission": {
        "edit": "deny",
        "write": { "*": "deny", "*/memory/*": "allow" },
        "bash": { "*": "deny", "ls *": "allow", "cat *": "allow" }
      }
    }
  }
}
```

### Agent Files (`.md` format)

Each agent gets a `.md` file in `claude-config/agents/` with YAML frontmatter matching Kilo's spec:

```yaml
---
description: Reviews code for correctness, security, edge cases, performance
mode: subagent
model: anthropic/claude-opus-4-20250514
permission:
  edit: deny
  bash:
    "*": deny
    "git diff*": allow
    "git log*": allow
---
You are a senior code reviewer...
```

---

## Phase 3: Modernize All 17 Skills

### Frontmatter Enhancements

For each SKILL.md, add a `metadata` block (Kilo-compatible) that documents the Claude Code features we'd use if available:

```yaml
---
name: commit
description: Task-aware git commits with conventional format, TASKS.md/CHANGELOG.md enforcement
metadata:
  version: "2.0"
  effort: low
  auto-invocable: false
  conditional-paths: []
  compatible-claude-code-fields:
    when_to_use: "After completing a task or feature"
    allowed-tools: ["Bash", "Read"]
    agent: null
    context: null
    shell: bash
  dependencies:
    - skill: verify
      when: "pre-commit"
---
```

This serves dual purpose:
1. Kilo reads standard `name`/`description` and ignores `metadata`
2. When Claude Code eventually supports these fields, the values are ready to migrate
3. Documents our design intent for each skill

### Specific Skill Enhancements

#### Workflow Skills (8)

| Skill | Key Changes |
|-------|-------------|
| `commit` | Add metadata block, add `scripts/` with pre-commit validation script, document `${CLAUDE_SKILL_DIR}` usage |
| `sprint` | Add metadata, document lifecycle states, add sprint metrics tracking |
| `research` | Add metadata, reference `perplexity_search.py` via `${CLAUDE_SKILL_DIR}`, document parallel search pattern |
| `review` | Add metadata, document worktree isolation pattern, reference code-reviewer agent |
| `verify` | Add metadata, auto-detect project type, document quality gate levels |
| `catchup` | Add metadata, document git state restoration |
| `session_mine` | Add metadata, reference `session_mine.py`, document JSONL parsing |
| `memory_sync` | Add metadata, document auto-trigger conditions |

#### Hardware Skills (9)

| Skill | Key Changes |
|-------|-------------|
| `kicad` | Add metadata, document analyzer scripts, add `effort: high` |
| `bom` | Add metadata, document BOM lifecycle, cross-reference other distributor skills |
| `digikey` | Add metadata, document API auth, reference scripts |
| `mouser` | Add metadata, document as secondary source |
| `lcsc` | Add metadata, document free API, JLCPCB linkage |
| `element14` | Add metadata, document multi-region support |
| `jlcpcb` | Add metadata, document assembly workflow |
| `pcbway` | Add metadata, document as alternative to JLCPCB |
| `openscad` | Add metadata, document 3D printing workflow |

---

## Phase 4: Auto-Memory System

### 4A: Memory Extractor Subagent

**File**: `claude-config/agents/memory-extractor.md`

```yaml
---
description: Extracts durable memories from session context — decisions, corrections, preferences, connection methods
mode: subagent
model: anthropic/claude-sonnet-4-20250514
permission:
  edit: deny
  write:
    "*": deny
    "*/memory/*": allow
  read: allow
  grep: allow
  glob: allow
  bash:
    "*": deny
    "ls*": allow
    "cat*": allow
    "stat*": allow
---
```

Capabilities:
- Read session context (recent messages, git state)
- Read existing memory files to avoid duplication
- Write new memory entries to `memory/` directory
- Update `MEMORY.md` topic index
- Extract: decisions, corrections, preferences, connection methods, tool discoveries

### 4B: Memory Extraction Script

**File**: `claude-config/scripts/memory_extract.py`

Inspired by Claude Code's `extractMemories.ts` pattern:
- Parse session JSONL files (like `session_mine.py` already does)
- Extract durable memories using pattern matching:
  - "remember this" / "always do X" → preferences
  - Connection strings, IPs, ports → connection methods
  - Error corrections → lessons learned
  - API keys references (not values) → credential locations
- Write to `memory/` directory organized by topic
- Update `MEMORY.md` index
- Deduplicate against existing memories

### 4C: Auto-Invocation Workflow

**File**: `claude-config/commands/memory-sync.md`

A `/memory-sync` slash command that:
1. Reads recent session context
2. Invokes `@memory-extractor` subagent
3. Reports what memories were saved

### 4D: Memory Directory Structure

```
memory/
├── MEMORY.md                    # Topic index (auto-maintained)
├── connections.md               # Hosts, IPs, ports, auth methods
├── preferences.md               # User preferences and corrections
├── decisions.md                 # Architectural decisions
├── lessons.md                   # Mistakes and corrections
└── tools.md                     # Discovered tools and utilities
```

---

## Phase 5: Kilo Workflow Commands

Create `.kilo/commands/` compatible slash commands that wire up the skills:

| Command | File | Agent | Behavior |
|---------|------|-------|----------|
| `/commit` | `commit.md` | code | Task-aware commit with pre-checks |
| `/sprint` | `sprint.md` | code | Sprint lifecycle management |
| `/research` | `research.md` | research-analyst | Deep research with Perplexity |
| `/review` | `review.md` | code-reviewer | Fresh-context code review |
| `/verify` | `verify.md` | code | Quality gate |
| `/catchup` | `catchup.md` | general | Restore context after /clear |
| `/session-mine` | `session-mine.md` | session-analyst | Analyze session patterns |
| `/memory-sync` | `memory-sync.md` | memory-extractor | Extract memories from session |

Each command file has frontmatter:
```yaml
---
description: Task-aware git commit with conventional format
agent: code
subtask: true
---
```

---

## Phase 6: Enhanced Hooks

### New Hook: `memory-auto-extract.sh`

**Event**: `Stop` (end of session/response)
**Behavior**: Triggers memory extraction script if enough turns have elapsed

### New Hook: `skill-discovery.sh`

**Event**: `SessionStart`
**Behavior**: Reports available skills and their status

### Update Existing Hooks

- `session-context.sh`: Add memory directory status
- `auto-lint.sh`: Support TypeScript files (from source, ruff + tsc)
- `notify-done.sh`: Add memory extraction notification

---

## Implementation Order

1. **Phase 1** — Restructure directories (non-breaking, can parallel with Phase 2)
2. **Phase 2** — Add `kilo.json` and agent `.md` files
3. **Phase 3** — Modernize all 17 SKILL.md files (batch by group)
4. **Phase 4** — Build auto-memory system (subagent + script + directory)
5. **Phase 5** — Create Kilo workflow commands
6. **Phase 6** — Enhance hooks
7. **Phase 7** — Update README.md and AGENTS.md
8. **Phase 8** — Test: verify skills load, agents work, memory extraction runs

## Validation

After each phase:
- Verify skills appear in `kilo agent list`
- Verify `/command` workflows trigger
- Verify `@memory-extractor` subagent can be invoked
- Verify hook scripts run on correct events
- Verify no paths break (all relative references updated)

## Files Modified/Created

### New Files (~15)
- `kilo.json`
- `claude-config/agents/memory-extractor.md`
- `claude-config/skills/auto/memory-extraction/SKILL.md`
- `claude-config/scripts/memory_extract.py`
- `claude-config/commands/*.md` (8 workflow command files)
- `memory/MEMORY.md`
- `memory/connections.md`, `preferences.md`, `decisions.md`, `lessons.md`, `tools.md`
- `hooks/global/memory-auto-extract.sh`
- `hooks/global/skill-discovery.sh`

### Modified Files (~20)
- All 17 `SKILL.md` files (frontmatter + content updates)
- All 8 agent `.md` files (Kilo frontmatter format)
- `README.md` (updated structure docs)
- `AGENTS.md` (updated conventions)
- `CLAUDE.global.md` (add memory/ directory rules, Kilo references)

### Deleted
- `skills/` top-level directory (merged into `claude-config/skills/`)
- `claude-config/global-skills/` (renamed to `claude-config/skills/`)

## Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| Kilo doesn't support all Claude Code frontmatter fields | Store in `metadata` block, document for future migration |
| Directory restructure breaks existing hooks/scripts | Update all paths, test after restructure |
| Memory extraction duplicates memory_sync skill | Memory extraction is automated; memory_sync is manual — complementary |
| Agent permissions too restrictive for memory-extractor | Start with read + limited write, test, adjust |
