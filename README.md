# my-claude-setup

A complete Claude Code configuration — global rules, workflow skills, hardware design skills, hook scripts, agent profiles, and project stencils. Everything needed to set up a productive Claude Code environment from scratch.

## What's In Here

```
my-claude-setup/
  claude-config/               # Global Claude Code configuration
    CLAUDE.global.md           # Global rules (all projects)
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
      claude_doctor.py         # Install/project wiring audit
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

The `memory_sync` skill auto-invokes when session learnings should be persisted.

Path-scoped authoring skills also auto-activate on matching files:

- `hook_authoring` for `claude-config/hooks/**`, `.claude/hooks/**`, and hook settings files
- `skill_authoring` for skill folders such as `claude-config/skills/**` and `.claude/skills/**`
- `agent_authoring` for `claude-config/agents/**` and `.claude/agents/**`

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

| Agent | Use Case |
|-|-|
| `code-reviewer` | Fresh-context code review (writer/reviewer pattern) |
| `session-analyst` | Session log analysis for usage patterns |
| `hardware-reviewer` | Independent KiCad schematic + PCB design review |
| `research-analyst` | MCP-aware structured technical research |
| `bom-auditor` | BOM completeness, sourcing risk, cost optimization |
| `deployment-validator` | Pre-deploy safety checklist (secrets, deps, embedded constraints) |
| `sprint-planner` | Velocity-based sprint planning from task history |
| `security-reviewer` | Focused security audit with docs-aware framework/library checking |

This repo now uses richer agent frontmatter in selected agents, including `mcpServers`, `initialPrompt`, `effort`, and read-only tool scoping. Claude Code also supports `permissionMode`, `hooks`, `skills`, `memory: local`, `background`, and `disallowedTools` when you need them.

## How It All Fits Together

```
~/.claude/
  CLAUDE.md              ← from CLAUDE.global.md
  settings.json          ← hook wiring (manual setup)
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
    hook_authoring/      ← auto-activates on hook files
    skill_authoring/     ← auto-activates on skill files
    agent_authoring/     ← auto-activates on agent files
    memory-extraction/   ← hidden auto memory helper
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
