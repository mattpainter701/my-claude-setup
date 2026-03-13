# my-claude-setup

A complete Claude Code configuration — global rules, workflow skills, hardware design skills, hook scripts, agent profiles, and project stencils. Everything needed to set up a productive Claude Code environment from scratch.

## What's In Here

```
my-claude-setup/
  claude-config/               # Global Claude Code configuration
    CLAUDE.global.md           # Global rules (all projects)
    project-stencil/
      CLAUDE.project.md        # Project-level rules template
    global-skills/             # Workflow skills (project-agnostic)
      commit/                  # Task-aware conventional commits
      sprint/                  # Sprint open/close lifecycle
      catchup/                 # Context recovery after /clear
      research/                # Parallel Perplexity + codebase research
      review/                  # Fresh-context code review (writer/reviewer pattern)
      session_mine/            # Session log analysis for patterns
      memory_sync/             # Auto-sync learnings to persistent memory
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
      research-analyst.md      # Perplexity-powered structured research
      bom-auditor.md           # BOM completeness & sourcing risk audit
      deployment-validator.md  # Pre-deploy safety checklist
      sprint-planner.md        # Velocity-based sprint planning
    rules/                     # Glob-scoped rules (file-type-specific)
      python.md                # Python conventions (scoped to **/*.py)
      kicad.md                 # KiCad file rules (scoped to **/*.kicad_*)
      shell-scripts.md         # Shell script rules (scoped to **/*.sh)
    scripts/
      perplexity_search.py     # Perplexity Sonar API wrapper (stdlib only)
  skills/                      # Hardware design skills (9 skills, 20 scripts)
    kicad/                     # Schematic, PCB, Gerber analysis
    bom/                       # BOM lifecycle management
    digikey/                   # DigiKey API search + datasheet sync
    mouser/                    # Mouser API search + datasheet sync
    lcsc/                      # LCSC/jlcsearch (no API key needed)
    element14/                 # Newark/Farnell/element14 API
    jlcpcb/                    # PCB fab + assembly ordering
    pcbway/                    # Alternative PCB fab (turnkey assembly)
    openscad/                  # Parametric 3D modeling for enclosures
```

## Setup Guide

### 1. Global Configuration (`~/.claude/`)

These files go in your Claude Code home directory and apply to **all projects**.

```bash
# Clone the repo
git clone https://github.com/mattpainter701/my-claude-setup.git

# Global rules
cp my-claude-setup/claude-config/CLAUDE.global.md ~/.claude/CLAUDE.md

# Workflow skills
cp -r my-claude-setup/claude-config/global-skills/* ~/.claude/skills/

# Hardware skills
cp -r my-claude-setup/skills/* ~/.claude/skills/

# Hook scripts
cp my-claude-setup/claude-config/hooks/global/* ~/.claude/hooks/

# Agent profiles
cp my-claude-setup/claude-config/agents/* ~/.claude/agents/

# Glob-scoped rules (file-type-specific)
cp -r my-claude-setup/claude-config/rules/* ~/.claude/rules/

# Perplexity wrapper script
mkdir -p ~/.claude/scripts
cp my-claude-setup/claude-config/scripts/perplexity_search.py ~/.claude/scripts/
```

### 2. Register Hooks in `~/.claude/settings.json`

Hooks need to be wired up in your global settings. Add the `hooks` block:

```json
{
  "attribution": "",
  "cleanupPeriodDays": 30,
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
# Project CLAUDE.md
cp my-claude-setup/claude-config/project-stencil/CLAUDE.project.md .claude/CLAUDE.md

# Project hooks (optional — copy the ones you want)
cp my-claude-setup/claude-config/hooks/project-stencil/commit-test-gate.sh .claude/hooks/
cp my-claude-setup/claude-config/hooks/project-stencil/commit-docs-gate.sh .claude/hooks/
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
```

**LCSC requires no credentials** — it uses the free jlcsearch community API.

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

| Skill | Trigger | What It Does |
|-|-|-|
| `/commit` | After code changes | Inspects diff, checks TASKS/CHANGELOG, conventional commit |
| `/sprint open/close` | Sprint lifecycle | Creates sprint entries, bumps versions, archives completed sprints |
| `/catchup` | After `/clear` | Restores git + project context in <500 chars |
| `/research <topic>` | Any research query | Parallel Perplexity web search + codebase analysis, structured report |
| `/review [file\|range]` | Before merge | Spawns isolated reviewer agent with fresh eyes |
| `/session-mine [days]` | Periodic | Analyzes session logs for patterns, skill gaps, improvements |

The `memory_sync` skill auto-invokes when session learnings should be persisted.

### Hardware Skills

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

### Hook Scripts

**Global hooks** (always active):

| Hook | Event | Behavior |
|-|-|-|
| `auto-lint.sh` | PostToolUse (Edit/Write) | Runs `ruff check --fix` + `ruff format` on .py files |
| `block-coauthored.sh` | PreToolUse (Bash) | Hard-blocks `git commit` containing Co-Authored-By |
| `notify-done.sh` | Stop | Ascending chirp on success, descending tone on error |
| `notify-permission.sh` | Notification | Windows toast + beep when permission needed |
| `session-context.sh` | SessionStart | Injects version, branch, commits, sprint on resume/compact/clear |

**Project hook stencils** (copy and customize):

| Hook | Event | Behavior |
|-|-|-|
| `commit-test-gate.sh` | PreToolUse (Bash) | Blocks `git commit` unless tests passed in last 30 min |
| `commit-docs-gate.sh` | PreToolUse (Bash) | Warns if code staged without TASKS.md/CHANGELOG.md |
| `mark-tests-passed.sh` | PostToolUse (Bash) | Creates test marker after successful pytest |
| `pre-compact-context.sh` | PreCompact | Injects project context into compaction summaries |

### Agent Profiles

| Agent | Use Case |
|-|-|
| `code-reviewer` | Fresh-context code review (writer/reviewer pattern) |
| `session-analyst` | Session log analysis for usage patterns |
| `hardware-reviewer` | Independent KiCad schematic + PCB design review |
| `research-analyst` | Perplexity-powered structured technical research |
| `bom-auditor` | BOM completeness, sourcing risk, cost optimization |
| `deployment-validator` | Pre-deploy safety checklist (secrets, deps, embedded constraints) |
| `sprint-planner` | Velocity-based sprint planning from task history |

## How It All Fits Together

```
~/.claude/
  CLAUDE.md              ← from CLAUDE.global.md
  settings.json          ← hook wiring (manual setup)
  hooks/                 ← from hooks/global/
  agents/                ← from agents/
  scripts/               ← perplexity_search.py
  skills/
    commit/              ← from global-skills/
    sprint/
    catchup/
    research/
    review/
    session_mine/
    memory_sync/
    kicad/               ← from skills/
    bom/
    digikey/
    mouser/
    lcsc/
    element14/
    jlcpcb/
    pcbway/
    openscad/

your-project/
  .claude/
    CLAUDE.md            ← from project-stencil/ (customized)
    settings.local.json  ← project hook wiring
    hooks/               ← from hooks/project-stencil/ (selected)
  TASKS.md               ← sprint task tracking
  CHANGELOG.md           ← version changelog
  memory/MEMORY.md       ← persistent project memory
```

## Typical Workflows

### Design Review
```
"Review my KiCad project at hardware/myboard/"
```
Claude runs schematic + PCB analyzers, syncs datasheets, cross-references pins against datasheets, produces a prioritized issue report.

### BOM Management
```
"Search DigiKey for all parts in my schematic, update the BOM"
```
Claude extracts components, searches distributor APIs, validates matches, writes part numbers back into KiCad properties, exports tracking CSV.

### Research
```
/research TDOA direction finding for drone detection using SDR
```
Claude normalizes the query, runs Perplexity web search + codebase analysis in parallel, merges both datasets, produces a cited report with project alignment.

### Enclosure Design
```
"Design a snap-fit enclosure for my 60x40mm PCB with USB-C and 2 SMA ports"
```
Claude generates parametric OpenSCAD with proper tolerances, screw bosses, port cutouts, FDM-friendly geometry. Renders to STL.

## License

MIT
