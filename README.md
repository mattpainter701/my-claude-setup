# my-claude-setup

A production-grade Claude Code configuration with 25 skills, 9 specialized agents, automated memory extraction, and comprehensive hook system. Everything you need to set up a bulletproof local development environment.

```
  ╔════════════════════════════════════════════════════════════════════╗
  ║                                                                    ║
  ║   Claude Code Configuration • 30 Skills • 9 Agents • Auto-Memory  ║
  ║                                                                    ║
  ║   Workflow  |  Hardware  |  Auto-Invoke  |  Agents  |  Hooks     ║
  ║   ========     =========     ============     =======     =====   ║
  ║     12          10              8              9           18    ║
  ║                                                                    ║
  ╚════════════════════════════════════════════════════════════════════╝
```

---

## Skill Landscape

```
                              ┌─────────────────────────────────────┐
                              │      Global Configuration          │
                              │    (CLAUDE.global.md)              │
                              └────────────────┬────────────────────┘
                                               │
                 ┌─────────────────────────────┼─────────────────────────────┐
                 │                             │                             │
        ┌────────▼──────────┐       ┌──────────▼──────────┐       ┌─────────▼──────────┐
        │    WORKFLOW       │       │    HARDWARE        │       │   AUTO-INVOKE      │
        │   (12 Skills)     │       │  (10 Skills)       │       │  (8 Skills)        │
        ├──────────────────┤       ├────────────────────┤       ├────────────────────┤
        │ • commit         │       │ • kicad            │       │ • skill_authoring  │
        │ • review         │       │ • bom              │       │ • hook_authoring   │
        │ • research       │       │ • digikey          │       │ • agent_authoring  │
        │ • sprint         │       │ • mouser           │       │ • memory-extract   │
        │ • verify         │       │ • lcsc             │       │ • crg-debug-issue  │
        │ • catchup        │       │ • element14        │       │ • crg-explore-     │
        │ • memory_sync    │       │ • jlcpcb           │       │   codebase         │
        │ • session_mine   │       │ • pcbway           │       │ • crg-refactor-    │
        │ • doctor         │       │ • openscad         │       │   safely           │
        │ • bootstrap      │       │ • ee               │       │ • crg-review-      │
        │ • verifier_hooks │       │ • (4 analysis      │       │   changes          │
        │ • circuit-weaver │       │    scripts)        │       │ [path-scoped]      │
        └──────────────────┘       └────────────────────┘       └────────────────────┘
```

---

## Data Flow: From Repo to Your Machine

```
  my-claude-setup/
        │
        ├─ claude-config/    (organized, hierarchical)
        │   ├─ skills/
        │   │   ├─ workflow/  ──┐
        │   │   ├─ hardware/  ──┼─ bootstrap_global.sh ──→ ~/.claude/skills/
        │   │   └─ auto/      ──┘    (flattened, flat)
        │   ├─ agents/         ──────────────────────────→ ~/.claude/agents/
        │   ├─ hooks/          ──────────────────────────→ ~/.claude/hooks/
        │   └─ rules/          ──────────────────────────→ ~/.claude/rules/
        │
        └─ kilo.json          ──────────────────────────→ ~/.config/kilo/
                                                          or ~/.claude/
```

---

## Agent Architecture

```
  Your Session
        │
        ├─ code-reviewer ─────────────┐
        │                              │
        ├─ hardware-reviewer ──────────┤ Isolated Worktree
        │                              │ (Fresh Eyes)
        ├─ security-reviewer ──────────┤
        │                              │
        ├─ research-analyst ───────────┤
        │                              │
        ├─ bom-auditor ────────────────┤
        │                              │
        ├─ deployment-validator ───────┤
        │                              │
        ├─ sprint-planner ─────────────┤
        │                              │
        ├─ session-analyst ────────────┤
        │                              │
        └─ memory-extractor ───────────┘ (background auto-invoke)
```

---

## Memory Extraction System

```
  Session Context (JSONL)
           │
           ▼
  memory-auto-extract.sh  ◄─── fires at session end
           │
           ▼
  memory_extract.py       ◄─── pattern matching
           │
      ┌────┼────┬─────┬────────┐
      │    │    │     │        │
      ▼    ▼    ▼     ▼        ▼
   decisions  lessons  preferences  connections  tools
   ────────  ────────  ───────────  ───────────  ─────
   • choices • fixes   • workflows  • hosts      • cli
   • archs   • gotchas • prefs      • ports      • libs
   • lib     • errors  • patterns   • endpoints  • found
   • stack              • habits

        ┌──────────────────────────────┐
        │    memory/MEMORY.md          │
        │  (maintained, indexed, live) │
        └──────────────────────────────┘
```

---

## Hook Execution Timeline

```
  Session Start
      │
      ├─ SessionStart ─────┬─ session-context.sh ────→ inject git state
      │                    └─ skill-discovery.sh ────→ report skills count
      │
      ├─ PreToolUse ───────┬─ block-coauthored.sh ───→ enforce conventions
      │  (before Bash)      └─ [project hooks]
      │
      ├─ PostToolUse ──────┬─ auto-lint.sh ──────────→ ruff format/check
      │  (after Edit/Write) └─ [project hooks]
      │
      ├─ Notification ─────┬─ notify-permission.sh ──→ beep + toast
      │  (perm requests)    └─
      │
      └─ SessionEnd ───────┬─ memory-auto-extract.sh→ extract memories
                           └─ log-hook-event.sh ────→ JSONL log
```

---

## What's In Here

```
my-claude-setup/
  claude-config/               # Global Claude Code configuration
    CLAUDE.global.md           # Global rules (all projects)
    settings.json              # Global settings (hooks, permissions, env)
    project-stencil/
      CLAUDE.project.md        # Project-level rules template
    skills/
      workflow/                # User-invocable workflow skills
        commit/                # Task-aware conventional commits
        sprint/                # Sprint open/close lifecycle
        catchup/               # Context recovery after /clear
        research/              # Parallel Perplexity + codebase research
        review/                # Fresh-context code review (writer/reviewer pattern)
        session_mine/          # Session log analysis for patterns
        memory_sync/           # Auto-sync learnings to persistent memory
        doctor/                # Global/project install health check
        bootstrap/             # Global/project/MCP/statusline bootstrap
        verifier_hooks/        # One-shot post-edit verifier hook
      auto/                    # Hidden/path-scoped support skills
        memory-extraction/     # Auto memory extraction helpers
        hook_authoring/        # Hidden path-scoped guidance for hook work
        skill_authoring/       # Hidden path-scoped guidance for skill work
        agent_authoring/       # Hidden path-scoped guidance for agent work
        crg-debug-issue/       # CRG: debug issues via dependency graph
        crg-explore-codebase/  # CRG: explore codebase structure
        crg-refactor-safely/   # CRG: refactor with impact-radius analysis
        crg-review-changes/    # CRG: review changes with affected-flows context
      hardware/                # Hardware design and sourcing skills
        kicad/                 # Schematic, PCB, Gerber analysis
        bom/                   # BOM lifecycle management
        digikey/               # DigiKey API search + datasheet sync
        mouser/                # Mouser API search + datasheet sync
        lcsc/                  # LCSC/jlcsearch (no API key needed)
        element14/             # Newark/Farnell/element14 API
        jlcpcb/                # PCB fab + assembly ordering
        pcbway/                # Alternative PCB fab (turnkey assembly)
        openscad/              # Parametric 3D modeling for enclosures
    hooks/
      global/                  # Global hook scripts (all projects)
        auto-lint.sh           # Ruff check+format on Python after Edit/Write
        block-coauthored.sh    # Hard-block Co-Authored-By in commits
        notify-done.sh         # Audio feedback on task completion
        notify-permission.sh   # Toast + beep on permission prompts
        session-context.sh     # Inject git/sprint context on session resume
        log-hook-event.sh      # JSONL event logging for session analysis
      project-stencil/         # Project hook templates (customize per project)
        commit-test-gate.sh    # Block commits unless tests passed recently
        commit-docs-gate.sh    # Warn if code staged without TASKS/CHANGELOG
        mark-tests-passed.sh   # Create test marker after successful pytest
        pre-compact-context.sh # Inject project context before compaction
    agents/                    # Agent profiles for subagent delegation
      code-reviewer.md         # Fresh-context code review
      session-analyst.md       # Session log pattern analysis
      hardware-reviewer.md     # KiCad schematic + PCB design review
      research-analyst.md      # MCP-aware structured research
      bom-auditor.md           # BOM completeness & sourcing risk audit
      deployment-validator.md  # Pre-deploy safety checklist
      sprint-planner.md        # Velocity-based sprint planning
      security-reviewer.md     # OWASP/secrets/injection audit
    rules/                     # Glob-scoped rules (file-type-specific)
      python.md                # Python conventions (scoped to **/*.py)
      kicad.md                 # KiCad file rules (scoped to **/*.kicad_*)
      shell-scripts.md         # Shell script rules (scoped to **/*.sh)
    scripts/
      perplexity_search.py     # Perplexity Sonar API wrapper (stdlib only)
      session_mine.py          # Session log mining for workflow analysis
      memory_extract.py        # Auto memory extraction from session JSONL
      mempalace-weekly-refresh.sh  # Weekly MemPalace index refresh
      token-check.sh           # Token budget headroom check
    commands/                  # Kilo/Claude Code slash commands
      commit.md                # /commit workflow
      sprint.md                # /sprint workflow
      research.md              # /research workflow
      review.md                # /review workflow
      verify.md                # /verify workflow
      catchup.md               # /catchup workflow
      session-mine.md          # /session-mine workflow
      memory-sync.md           # /memory-sync workflow
  memory/                      # Auto-extracted durable memories
    MEMORY.md                  # Topic index (auto-maintained)
    connections.md             # Hosts, IPs, ports, endpoints
    decisions.md               # Architecture choices
    lessons.md                 # Corrections and gotchas
    preferences.md             # Workflow preferences
    tools.md                   # Discovered tools and utilities
```

## Quick Start

```bash
# 1. Clone
git clone https://github.com/mattpainter701/my-claude-setup.git
cd my-claude-setup

# 2. Bootstrap (one command, flattens and installs everything)
bash bootstrap_global.sh

# 3. Verify
claude /doctor --full

# 4. Start using
/commit         # Task-aware commits
/review         # Code review
/research       # Deep research
/sprint open    # Sprint planning
```

---

## Setup Guide

### 1. Global Configuration (`~/.claude/` or `~/.config/kilo/`)

These files work with both Claude Code and Kilo CLI.

```bash
# Clone the repo
git clone https://github.com/mattpainter701/my-claude-setup.git

# Global rules
cp my-claude-setup/claude-config/CLAUDE.global.md ~/.claude/CLAUDE.md

# Workflow skills
cp -r my-claude-setup/claude-config/skills/workflow/* ~/.claude/skills/

# Hidden/path-scoped support skills
cp -r my-claude-setup/claude-config/skills/auto/* ~/.claude/skills/

# Hardware skills
cp -r my-claude-setup/claude-config/skills/hardware/* ~/.claude/skills/

# Hook scripts
cp my-claude-setup/claude-config/hooks/global/* ~/.claude/hooks/

# Agent profiles
cp my-claude-setup/claude-config/agents/* ~/.claude/agents/

# Glob-scoped rules (file-type-specific)
cp -r my-claude-setup/claude-config/rules/* ~/.claude/rules/

# Helper scripts
mkdir -p ~/.claude/scripts
cp my-claude-setup/claude-config/scripts/*.py ~/.claude/scripts/

# Kilo config (optional — for Kilo CLI users)
cp my-claude-setup/kilo.json ~/.config/kilo/kilo.json
```

### 2. Register Hooks in `~/.claude/settings.json`

Hooks need to be wired up in your global settings. Add the `hooks` block:

```json
{
  "attribution": "",
  "cleanupPeriodDays": 30,
  "autoCompactEnabled": true,
  "autoMemoryEnabled": true,
  "autoDreamEnabled": true,
  "fileCheckpointingEnabled": true,
  "showTurnDuration": true,
  "terminalProgressBarEnabled": true,
  "todoFeatureEnabled": true,
  "teammateMode": "auto",
  "permissions": {
    "defaultMode": "default"
  },
  "env": {
    "CLAUDE_AUTOCOMPACT_PCT_OVERRIDE": "80"
  },
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [{"type": "command", "command": "bash ~/.claude/hooks/block-coauthored.sh"}]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [{"type": "command", "command": "bash ~/.claude/hooks/auto-lint.sh"}]
      }
    ],
    "Notification": [
      {
        "hooks": [{"type": "command", "command": "bash ~/.claude/hooks/notify-permission.sh"}]
      }
    ],
    "SessionStart": [
      {
        "matcher": "resume|compact|clear",
        "hooks": [{"type": "command", "command": "bash ~/.claude/hooks/session-context.sh", "once": true}]
      }
    ],
    "Stop": [
      {
        "hooks": [{"type": "command", "command": "bash ~/.claude/hooks/notify-done.sh"}]
      }
    ],
    "SubagentStop": [
      {
        "hooks": [{"type": "command", "command": "bash ~/.claude/hooks/log-hook-event.sh", "async": true}]
      }
    ],
    "SessionEnd": [
      {
        "hooks": [{"type": "command", "command": "bash ~/.claude/hooks/log-hook-event.sh", "once": true}]
      }
    ]
  }
}
```

### 3. Project-Level Setup (per project)

For each new project, copy the stencils and customize:

```bash
mkdir -p .claude/hooks .claude/rules

# Project CLAUDE.md
cp my-claude-setup/claude-config/project-stencil/CLAUDE.project.md .claude/CLAUDE.md

# Project hooks (optional — copy the ones you want)
cp my-claude-setup/claude-config/hooks/project-stencil/commit-test-gate.sh .claude/hooks/
cp my-claude-setup/claude-config/hooks/project-stencil/commit-docs-gate.sh .claude/hooks/
cp my-claude-setup/claude-config/hooks/project-stencil/mark-tests-passed.sh .claude/hooks/
cp my-claude-setup/claude-config/hooks/project-stencil/pre-compact-context.sh .claude/hooks/
```

Then wire up project hooks in `.claude/settings.local.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [{"type": "command", "command": "bash .claude/hooks/commit-test-gate.sh"}]
      },
      {
        "matcher": "Bash",
        "hooks": [{"type": "command", "command": "bash .claude/hooks/commit-docs-gate.sh"}]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [{"type": "command", "command": "bash .claude/hooks/mark-tests-passed.sh"}]
      }
    ],
    "PreCompact": [
      {
        "hooks": [{"type": "command", "command": "bash .claude/hooks/pre-compact-context.sh"}]
      }
    ]
  }
}
```

Optional rule layers for larger projects:

```text
your-project/
  CLAUDE.local.md        # Private repo-local notes, never commit secrets
  .claude/
    CLAUDE.md            # Shared project rules
    rules/
      testing.md         # Topic-specific checked-in rules
      deploy.md
```

- Put durable, shared project rules in `.claude/CLAUDE.md`.
- Split larger topics into `.claude/rules/*.md` so the main file stays short.
- Use `CLAUDE.local.md` for private machine-specific notes that should not be committed.
- Use `@relative/path.md` inside `CLAUDE.md` or rule files to include shared snippets instead of duplicating content.

### 4. API Credentials

Store API keys in `~/.config/secrets.env` (outside all git repos):

```env
# Perplexity Sonar API (research skill)
PERPLEXITY_API_KEY=pplx-xxxxxxxxxxxxxxxxxxxx

# DigiKey Product Information v4 (OAuth 2.0 client credentials)
DIGIKEY_CLIENT_ID=your_client_id
DIGIKEY_CLIENT_SECRET=your_client_secret

# Mouser Search API
MOUSER_SEARCH_API_KEY=your-uuid-key

# element14/Newark/Farnell
ELEMENT14_API_KEY=your_key
```

Load before use: `export $(grep -v '^#' ~/.config/secrets.env | grep -v '^$' | xargs)`

The research skill and datasheet sync scripts auto-load from this file.

### 5. Dependencies

```bash
pip install requests          # HTTP client (strongly recommended)
pip install playwright        # Optional: headless browser for stubborn datasheet sites
pip install ruff              # Python linter (used by auto-lint hook)
winget install jqlang.jq      # Required by the shell hooks for JSON parsing
```

Optional PowerShell dependency for Windows toast notifications:

```powershell
Install-Module BurntToast -Scope CurrentUser
```

The hook scripts assume **Git Bash** for `bash` hooks and `jq` for parsing the hook JSON payload.

**LCSC requires no credentials** — it uses the free jlcsearch community API.

### 6. Recommended Claude Code Settings

These settings are worth enabling in a modern Claude Code install:

- `autoMemoryEnabled`: turn on built-in memory extraction for user/project/reference memories.
- `autoDreamEnabled`: enable background memory consolidation when you want Claude to compress accumulated memories.
- `fileCheckpointingEnabled`: makes rewind/recovery safer after bad edits.
- `showTurnDuration`: adds latency feedback after each response.
- `terminalProgressBarEnabled`: enables OSC progress in terminals that support it.
- `todoFeatureEnabled`: enables built-in task tracking.
- `teammateMode: "auto"`: lets Claude choose the best teammate spawning mode.
- `permissions.defaultMode`: set deliberately per your tolerance (`default`, `acceptEdits`, `dontAsk`, etc.).

Claude Code also ships a built-in `/statusline` command now, so you can configure your terminal status line without hand-editing the full prompt stack.

### 7. MCP / Plugin Setup (Optional but Recommended)

The research skill and the research/security agents can use external docs tools when they are available. In particular, they are ready to use Context7-style MCP tools:

- `mcp__plugin_context7_context7__resolve-library-id`
- `mcp__plugin_context7_context7__query-docs`

Use Claude Code's `/mcp` or `/plugin` flows to enable the docs/search plugins you want. If those tools are not installed, the research skill still falls back to `WebSearch`, `WebFetch`, and local codebase analysis.

## What Each Layer Does

### Global Rules (`CLAUDE.global.md`)

Project-agnostic rules that apply everywhere:
- Commit conventions (imperative mood, no Co-Authored-By, conventional format)
- TASKS.md + CHANGELOG.md workflow enforcement
- Response style (no echoing, no narration, concise)
- Shipping guardrails (failure semantics, mock contracts, regression tests)
- Self-maintenance (auto-update rules when corrections happen)
- Session hygiene (`/clear` between tasks, two-correction rule)

### Workflow Skills (global)

```
  ┌──────────────────────────────────────────────────────────────────┐
  │                    12 WORKFLOW SKILLS                            │
  ├──────────────────────────────────────────────────────────────────┤
  │                                                                   │
  │ • /commit ─────────→ Task-aware conventional commits             │
  │ • /review ─────────→ Fresh-context code review (agent)           │
  │ • /research ───────→ Perplexity + codebase analysis              │
  │ • /sprint ─────────→ Sprint open/close + velocity tracking       │
  │ • /verify ─────────→ Pre-commit quality gate                     │
  │ • /catchup ────────→ Restore context after /clear                │
  │ • /session_mine ───→ Analyze session logs for patterns           │
  │ • /memory_sync ────→ Extract durable memories                    │
  │ • /doctor ─────────→ Validate setup health                       │
  │ • /bootstrap ──────→ Install/refresh global or project config    │
  │ • /verifier_hooks ─→ Arm post-edit agent verifier                │
  │ • /circuit-weaver ─→ IC selection + schematic generation wizard  │
  │                                                                   │
  │ + 8 Hidden Auto-Skills (trigger on file type / CRG context)      │
  │   → skill_authoring, hook_authoring, agent_authoring,            │
  │     memory-extraction, crg-debug-issue, crg-explore-codebase,    │
  │     crg-refactor-safely, crg-review-changes                      │
  │                                                                   │
  └──────────────────────────────────────────────────────────────────┘
```

| Skill | Trigger | What It Does |
|-|-|-|
| `/commit` | After code changes | Inspects diff, checks TASKS/CHANGELOG, conventional commit |
| `/sprint open/close` | Sprint lifecycle | Creates sprint entries, bumps versions, archives completed sprints |
| `/catchup` | After `/clear` | Restores git + project context in <500 chars |
| `/research <topic>` | Any research query | Parallel Perplexity web search + codebase analysis, structured report |
| `/review [file\|range]` | Before merge | Spawns isolated reviewer agent with fresh eyes |
| `/session_mine [days]` | Periodic | Analyzes session logs for patterns, skill gaps, improvements |
| `/doctor [quick\|full]` | Setup audit | Validates ~/.claude wiring, helper scripts, hooks, and optional project setup |
| `/bootstrap [global\|project\|mcp\|statusline]` | Setup / refresh | Installs or refreshes global/project stencils, MCP wiring, and statusline setup |
| `/verifier_hooks` | Risky next edit | Arms a one-shot post-edit agent verifier for the next `Edit` or `Write` |
| `/circuit-weaver` | New circuit design | IC selection wizard + research-driven passive generation + schematic output |

### Hardware Skills

```
  ┌─────────────────────────────────────────────────────────────────┐
  │               10 HARDWARE DESIGN & SOURCING SKILLS              │
  ├─────────────────────────────────────────────────────────────────┤
  │                                                                  │
  │  Analysis & Design                                              │
  │  ═══════════════════════════════════════════════════════════    │
  │    • kicad ───────→ Schematic + PCB + Gerber analysis           │
  │    • openscad ────→ Parametric 3D modeling (STL/3MF export)     │
  │    • ee ──────────→ Circuit design reference (RF, power, EMC)   │
  │                                                                  │
  │  Component Sourcing (API + Datasheet Sync)                      │
  │  ════════════════════════════════════════════════════════════   │
  │    • digikey ─────→ Primary prototype source + direct PDFs      │
  │    • mouser ──────→ Secondary prototype source                  │
  │    • lcsc ────────→ Production sourcing (JLCPCB library)        │
  │    • element14 ───→ International sourcing (Newark/Farnell)     │
  │                                                                  │
  │  BOM & Manufacturing                                            │
  │  ═══════════════════════════════════════════════════════════    │
  │    • bom ─────────→ Full BOM lifecycle (extract→validate→order) │
  │    • jlcpcb ──────→ PCB fabrication & assembly (LCSC parts)     │
  │    • pcbway ──────→ Alternative fab (turnkey by MPN)            │
  │                                                                  │
  └─────────────────────────────────────────────────────────────────┘

  Component Search Pipeline:
  ─────────────────────────
    KiCad Schematic (MPN)
        ↓
    [digikey | mouser | lcsc | element14] API
        ↓
    Match validation (package, specs, lifecycle)
        ↓
    Datasheet sync (PDF to datasheets/ directory)
        ↓
    BOM export (CSV for distributors or JLCPCB/PCBWay)
        ↓
    Order files (per-distributor, with price breaks)
```

| Skill | Purpose | Scripts |
|-|-|-|
| **kicad** | Analyze schematics, PCBs, Gerbers, PDF reference designs | 4 analyzers + S-expr parser |
| **bom** | BOM lifecycle — extract, enrich, validate, export, order | 4 scripts |
| **digikey** | DigiKey API search + datasheet sync (primary prototype source) | 2 scripts |
| **mouser** | Mouser API search + datasheet sync (secondary prototype source) | 2 scripts |
| **lcsc** | LCSC/jlcsearch — production sourcing for JLCPCB (free, no key) | 2 scripts |
| **element14** | Newark/Farnell/element14 — international sourcing | 2 scripts |
| **jlcpcb** | PCB fab + assembly — design rules, BOM format, ordering | Instruction-only |
| **pcbway** | Alternative PCB fab — turnkey assembly by MPN | Instruction-only |
| **openscad** | Parametric 3D models — enclosures, mounts, brackets | Instruction-only |
| **ee** | Electrical engineering reference (circuits, power, RF, thermal) | Instruction-only |

### Hook Scripts

**Global hooks** (always active):

| Hook | Event | Behavior |
|-|-|-|
| `auto-lint.sh` | PostToolUse (Edit/Write) | Runs `ruff check --fix` + `ruff format` on .py files |
| `block-coauthored.sh` | PreToolUse (Bash) | Hard-blocks `git commit` containing Co-Authored-By |
| `block-no-verify.sh` | PreToolUse (Bash) | Hard-blocks `git commit --no-verify` flag |
| `warn-git-push.sh` | PreToolUse (Bash) | Warns before `git push` to remote |
| `notify-done.sh` | Stop | Ascending chirp on success, descending tone on error |
| `notify-permission.sh` | Notification | Windows toast + beep when permission needed |
| `session-context.sh` | SessionStart | Injects version, branch, commits, sprint on resume/compact/clear |
| `pre-compact-save.sh` | PreCompact | Saves context snapshot before compaction |
| `log-hook-event.sh` | SubagentStop/SessionEnd | JSONL event logging for session analysis |
| `memory-auto-extract.sh` | Stop | Background memory extraction at session end |
| `skill-discovery.sh` | SessionStart | Reports available skills count at session start |
| `token-metrics-start.sh` | PreToolUse | Records token baseline at turn start |
| `token-metrics-end.sh` | PostToolUse | Logs token delta per turn for metrics |

**Project hook stencils** (copy and customize):

| Hook | Event | Behavior |
|-|-|-|
| `commit-test-gate.sh` | PreToolUse (Bash) | Blocks `git commit` unless tests passed in last 30 min |
| `commit-docs-gate.sh` | PreToolUse (Bash) | Warns if code staged without TASKS.md/CHANGELOG.md |
| `mark-tests-passed.sh` | PostToolUse (Bash) | Creates test marker after successful pytest |
| `pre-compact-context.sh` | PreCompact | Injects project context into compaction summaries |

Claude Code's hook system now supports more than plain shell commands. You can also use:

- command hook fields such as `if`, `shell`, `timeout`, `statusMessage`, `async`, and `asyncRewake`
- `prompt` hooks for lightweight LLM checks
- `http` hooks for sending hook payloads to an internal service
- `agent` hooks for verifier-style background review

This repo now includes two verifier-hook patterns:

- `/verifier_hooks` arms a one-shot `PostToolUse` agent verifier for the next risky edit.
- For a persistent project-level verifier, add a narrow `agent` hook like this to `.claude/settings.local.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "agent",
            "prompt": "Review the just-written change described by $ARGUMENTS. Block only for likely regressions, risky auth/migration/deploy changes without targeted verification, or broken hook/skill/agent frontmatter.",
            "timeout": 45,
            "statusMessage": "Running edit verifier"
          }
        ]
      }
    ]
  }
}
```

### Agent Profiles

```
  ┌──────────────────────────────────────────────────────────────────┐
  │            9 SPECIALIZED AGENTS (Worktree-Isolated)              │
  ├──────────────────────────────────────────────────────────────────┤
  │                                                                   │
  │  Code Review                                                      │
  │  ───────────                                                      │
  │    code-reviewer ────→ Fresh eyes on logic, security, perf       │
  │    security-reviewer → OWASP + injection + secrets audit         │
  │                                                                   │
  │  Hardware & Design                                                │
  │  ─────────────────                                                │
  │    hardware-reviewer → KiCad schematic + PCB pin mapping         │
  │    bom-auditor ──────→ Component sourcing & cost optimization    │
  │                                                                   │
  │  Research & Analysis                                              │
  │  ───────────────────                                              │
  │    research-analyst ─→ Perplexity web + codebase cross-ref      │
  │    session-analyst ──→ Log mining for patterns & inefficiencies │
  │                                                                   │
  │  Project Planning & Deploy                                        │
  │  ───────────────────────────                                      │
  │    sprint-planner ────→ Velocity-based task sizing + roadmap    │
  │    deployment-validator→ Pre-deploy safety checklist            │
  │                                                                   │
  │  Memory Management                                                │
  │  ────────────────                                                 │
  │    memory-extractor ──→ Auto-invoke: extract durable learnings   │
  │                                                                   │
  └──────────────────────────────────────────────────────────────────┘
```

| Agent | Use Case | Mode |
|-|-|-|
| `code-reviewer` | Fresh-context code review (writer/reviewer pattern) | Worktree |
| `session-analyst` | Session log analysis for usage patterns | Worktree |
| `hardware-reviewer` | Independent KiCad schematic + PCB design review | Worktree |
| `research-analyst` | MCP-aware structured technical research | Worktree |
| `bom-auditor` | BOM completeness, sourcing risk, cost optimization | Worktree |
| `deployment-validator` | Pre-deploy safety checklist (secrets, deps, embedded constraints) | Worktree |
| `sprint-planner` | Velocity-based sprint planning from task history | Worktree |
| `security-reviewer` | Focused security audit with docs-aware framework/library checking | Worktree |
| `memory-extractor` | Auto-extracts durable memories from session context | Background |

This repo now uses richer agent frontmatter in selected agents, including `mcpServers`, `initialPrompt`, `effort`, read-only tool scoping, and Kilo-compatible `permission` blocks. Claude Code also supports `permissionMode`, `hooks`, `skills`, `memory: local`, `background`, and `disallowedTools` when you need them.

## Kilo CLI Compatibility

This setup is compatible with both Claude Code and Kilo CLI. A `kilo.json` file is included for Kilo-native features:

```json
{
  "$schema": "https://app.kilo.ai/config.json",
  "skills": {
    "paths": ["./claude-config/skills/workflow", "./claude-config/skills/hardware", "./claude-config/skills/auto"]
  },
  "agent": {
    "code-reviewer": { "mode": "subagent", "model": "anthropic/claude-opus-4-20250514" },
    "memory-extractor": { "mode": "subagent", "hidden": true }
  }
}
```

Kilo also loads skills from `.claude/skills/` and `.kilo/skills/`, and supports custom subagents via `.kilo/agents/*.md` or `.claude/agents/*.md`.

### Kilo Workflow Commands

Slash commands are available in `claude-config/commands/` — copy to `.kilo/commands/` or `.claude/commands/`:

| Command | Description | Agent |
|-|-|-|
| `/commit` | Task-aware git commit | code |
| `/sprint` | Sprint open/close lifecycle | code |
| `/research` | Deep research with Perplexity | research-analyst |
| `/review` | Fresh-context code review | code-reviewer |
| `/verify` | Quality gate (build, lint, test, secrets) | code |
| `/catchup` | Restore context after /clear | general |
| `/session-mine` | Analyze session patterns | session-analyst |
| `/memory-sync` | Extract memories from session | memory-extractor |

## Auto-Memory System

This setup includes an automated memory extraction system inspired by Claude Code's internal `extractMemories.ts` pattern:

### How It Works

1. **`@memory-extractor` subagent** — reviews session context and writes durable memories to `memory/` directory
2. **`memory_extract.py` script** — parses session JSONL files using pattern matching for decisions, corrections, preferences, connections, and tools
3. **`/memory-sync` workflow** — manually trigger memory extraction from the current session
4. **`memory-auto-extract.sh` hook** — background memory extraction at session end (optional)

### Memory Directory

```
memory/
  MEMORY.md           # Topic index (auto-maintained)
  connections.md      # Hosts, IPs, ports, endpoints
  decisions.md        # Architecture choices, library selections
  lessons.md          # Corrections, wrong assumptions
  preferences.md      # Workflow preferences, tool choices
  tools.md            # Discovered tools and utilities
```

### What Gets Extracted

| Category | Examples | Target File |
|-|-|-|
| Decisions | "We're using MQTT instead of HTTP for telemetry" | `decisions.md` |
| Corrections | "Actually, the pull-up should be 4.7k not 10k" | `lessons.md` |
| Preferences | "Always use `py` not `python` on Windows" | `preferences.md` |
| Connections | "The MQTT broker is at 192.168.1.50:1883" | `connections.md` |
| Tools | "Found `ruff` for Python linting" | `tools.md` |

### What Does NOT Get Extracted

- Secrets (API keys, passwords, tokens) — never stored
- Code patterns derivable from reading the codebase
- Git history or debugging solutions
- Ephemeral task state

## MemPalace Integration

[MemPalace](https://github.com/MemPalace/mempalace) is a semantic memory MCP server that provides a structured knowledge graph alongside Claude's built-in auto-memory. It stores entities and relationships in a per-project `mempalace.yaml` and `entities.json`.

These per-project files are **excluded from this repo** via `.gitignore` (issue #185) — they contain project-specific memory that varies per machine and should not be committed to the config backup repo.

**Key files:**

| File | Purpose | In Repo? |
|-|-|-|
| `mempalace.yaml` | Per-project MemPalace config | No — gitignored |
| `entities.json` | Per-project entity graph | No — gitignored |
| `scripts/mempalace-weekly-refresh.sh` | Weekly MemPalace index refresh automation | Yes |

**MCP tools available** (when MemPalace server is running):
- `mempalace_search` — semantic search across stored memories
- `mempalace_add_drawer` / `mempalace_update_drawer` — store new memories
- `mempalace_kg_add` / `mempalace_kg_query` — knowledge graph operations

## Token Optimization Infrastructure

This setup includes tooling to minimize token spend and navigate large codebases efficiently.

**Code Review Graph (CRG)** — installed globally via `code-review-graph` MCP server. Builds a Tree-sitter dependency graph per project, then provides impact-radius analysis, affected-flow queries, and semantic search. Four CRG skills are included:

| Skill | Use Case |
|-|-|
| `crg-debug-issue` | Navigate to the root cause via dependency subgraph |
| `crg-explore-codebase` | Map architecture without reading full files |
| `crg-refactor-safely` | Find all callers/callees before a refactor |
| `crg-review-changes` | Review a diff with full affected-flows context |

**Token metrics hooks** — `token-metrics-start.sh` (PreToolUse) and `token-metrics-end.sh` (PostToolUse) track per-turn token deltas. Use `scripts/token-check.sh` to check budget headroom in long sessions.

**Setup:** Run `code-review-graph build` in each project root to generate the graph. The `PostToolUse` hook `code-review-graph update --skip-flows` keeps the graph current after every edit (silent no-op on projects without a graph).

## How It All Fits Together

```
~/.claude/
  CLAUDE.md              ← from CLAUDE.global.md
  settings.json          ← from claude-config/settings.json (hooks, permissions, env)
  hooks/                 ← from hooks/global/
  agents/                ← from agents/
  scripts/               ← perplexity_search.py + session_mine.py + claude_doctor.py
  skills/
    commit/              ← from skills/workflow/
    sprint/
    catchup/
    research/
    review/
    session_mine/
    memory_sync/
    doctor/
    bootstrap/
    verifier_hooks/
    circuit-weaver/      ← IC selection + schematic generation wizard
    hook_authoring/      ← auto-activates on hook files
    skill_authoring/     ← auto-activates on skill files
    agent_authoring/     ← auto-activates on agent files
    memory-extraction/   ← hidden auto memory helper
    crg-debug-issue/     ← CRG: debug issues via dependency graph
    crg-explore-codebase/ ← CRG: explore codebase structure
    crg-refactor-safely/ ← CRG: refactor with impact-radius analysis
    crg-review-changes/  ← CRG: review changes with affected-flows context
    kicad/               ← from skills/hardware/
    bom/
    digikey/
    mouser/
    lcsc/
    element14/
    jlcpcb/
    pcbway/
    openscad/

your-project/
  CLAUDE.local.md        ← private repo-local instructions (optional)
  .claude/
    CLAUDE.md            ← from project-stencil/ (customized)
    rules/               ← topic-specific checked-in rules (optional)
    settings.local.json  ← project hook wiring
    hooks/               ← from hooks/project-stencil/ (selected)
  TASKS.md               ← sprint task tracking
  CHANGELOG.md           ← version changelog
  memory/MEMORY.md       ← persistent project memory
```

## Typical Workflows

```
  ╔═════════════════════════════════════════════════════════════════╗
  ║                      WORKFLOW PATTERNS                         ║
  ╚═════════════════════════════════════════════════════════════════╝
```

### 🔍 Design Review
```
User: "Review my KiCad project at hardware/myboard/"

  ┌─────────────────────────────────────┐
  │ hardware-reviewer agent spawns      │
  ├─────────────────────────────────────┤
  │ ✓ Analyze schematic (pin-to-net)    │
  │ ✓ Analyze PCB (routing, thermal)    │
  │ ✓ Sync datasheets                   │
  │ ✓ Cross-reference pins vs datasheet │
  │ ✓ Check design rules (DFM)          │
  └─────────────────────────────────────┘
           ↓
  CRITICAL → WARNINGS → SUGGESTIONS
  (prioritized issue report)
```

### 🧬 BOM Management
```
User: "Search DigiKey for all parts in my schematic, update the BOM"

  Schematic
    ↓
  Extract components (MPN, footprint, value)
    ↓
  [digikey | mouser | lcsc] API search
    ↓
  Validate matches (package, specs, lifecycle)
    ↓
  Sync datasheets (PDFs to datasheets/ dir)
    ↓
  Write properties back to schematic
    ↓
  Export BOM.csv (with stock, prices, chosen distributor)
```

### 🔬 Research
```
/research TDOA direction finding for drone detection using SDR

  ┌──────────────────────────────────────────┐
  │  Perplexity (web search, citations)     │  Parallel
  │  + Claude (codebase grep, memory)       │  Search
  ├──────────────────────────────────────────┤
  │ Merge results + cross-references        │
  ├──────────────────────────────────────────┤
  │ ✓ Summary (lead with answer)             │
  │ ✓ Key Findings (with [web] / [codebase] │
  │   provenance markers)                    │
  │ ✓ Sources (clickable URLs)               │
  │ ✓ Project Alignment                      │
  │ ✓ Recommendations                        │
  └──────────────────────────────────────────┘
  → Structured report (save to memory)
```

### 📦 Enclosure Design
```
User: "Design a snap-fit enclosure for my 60x40mm PCB with USB-C and 2 SMA ports"

  ┌──────────────────────────────────────┐
  │ Generate parametric OpenSCAD:        │
  ├──────────────────────────────────────┤
  │ • Hull-based rounded box             │
  │ • Screw bosses (M3 heat-set inserts) │
  │ • Port cutouts (USB: 10×4, SMA: 9mm)│
  │ • Snap-fit lid (inset lip)           │
  │ • FDM-friendly geometry              │
  │ • 0.3mm wall thickness               │
  │ • Parametric (tune sizes in code)    │
  └──────────────────────────────────────┘
        ↓
  Render to STL (binary) or 3MF
        ↓
  Import to slicer (Bambu/Prusa)
        ↓
  Print on FDM 3D printer
```

### 🚀 Pre-Commit Quality Gate
```
/verify pre-commit

  ┌──────────────────────────────────────┐
  │ Python project auto-detection:       │
  ├──────────────────────────────────────┤
  │ [✓] Build/Import check               │
  │ [✓] Type check (mypy)                │
  │ [✓] Lint (ruff)                      │
  │ [✓] Tests pass (pytest)              │
  │ [✓] No secrets (API key grep)        │
  │ [✓] No debug artifacts               │
  │ [⚠] Security scan (agent)            │
  └──────────────────────────────────────┘
  → READY ✓  or  NOT READY ✗
```

### 📋 Sprint Planning
```
/sprint open

  ┌──────────────────────────────────────┐
  │ Analyze project state:               │
  ├──────────────────────────────────────┤
  │ • Last 3 sprints velocity            │
  │ • P0/P1 tasks in backlog             │
  │ • Technical debt risk                │
  │ • Blocker analysis                   │
  └──────────────────────────────────────┘
        ↓
  Propose N tasks matched to velocity
  (with priority, complexity, dependencies)

## License

MIT
