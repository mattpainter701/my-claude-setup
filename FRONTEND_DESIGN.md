# Frontend Design & Repository Architecture

This document describes the design philosophy, visual architecture, and organizational approach of the **my-claude-setup** repository. It's a guide for understanding the repository structure, extending it, and adopting its patterns.

---

## Design Philosophy

### Principles

1. **Organization Over Flatness** — Use a hierarchical, scoped structure in the repository (`claude-config/skills/hardware/`, `claude-config/skills/workflow/`) that flattens on installation (`~/.claude/skills/`). This maintains clarity during development while keeping the user's environment simple.

2. **Metadata-First Skills** — Every skill, agent, and tool includes a metadata block that describes:
   - Purpose and usage context
   - Effort level (quick, medium, involved)
   - Category (hardware, workflow, auto)
   - Compatibility with Claude Code versions
   - Related tools and skills (cross-references)

3. **Explicit Over Implicit** — All capabilities are documented. No hidden or undiscovered features. Every skill includes "When to Use" and "When NOT to Use" sections.

4. **Self-Service Learning** — New users should be able to explore, discover, and understand all capabilities without external help.

5. **Version Control First** — Skills, agents, hooks, and configuration are version-controlled. The `bootstrap_global.sh` script syncs everything to `~/.claude/` on demand.

---

## Repository Structure

```
my-claude-setup/
├── README.md                          # Primary documentation
├── FRONTEND_DESIGN.md                 # This file — design philosophy & architecture
├── PLAN.md                            # Implementation plan (8-phase roadmap)
│
├── claude-config/                     # Version-controlled configuration
│   ├── CLAUDE.global.md              # Global rules, skills inventory, agents list
│   ├── CLAUDE.md                     # (per-project — not in global repo)
│   │
│   ├── skills/                       # Organized by category (not flattened in repo)
│   │   ├── workflow/                 # User-facing CLI skills (commit, review, research, etc.)
│   │   │   ├── commit/
│   │   │   ├── review/
│   │   │   ├── research/
│   │   │   ├── sprint/
│   │   │   ├── memory_sync/
│   │   │   ├── session_mine/
│   │   │   ├── verify/
│   │   │   ├── catchup/
│   │   │   ├── bootstrap/
│   │   │   ├── doctor/
│   │   │   └── verifier_hooks/
│   │   │
│   │   ├── hardware/                # Electronics & embedded systems
│   │   │   ├── bom/                # Bill of Materials management
│   │   │   ├── digikey/            # Component search (primary source)
│   │   │   ├── mouser/             # Component search (secondary)
│   │   │   ├── lcsc/               # Production sourcing (JLCPCB)
│   │   │   ├── element14/          # International component source
│   │   │   ├── jlcpcb/             # PCB fabrication & assembly
│   │   │   ├── pcbway/             # Alternative PCB service
│   │   │   ├── kicad/              # Schematic & PCB analysis
│   │   │   ├── openscad/           # 3D parametric modeling
│   │   │   └── ee/                 # Electrical engineering reference
│   │   │
│   │   └── auto/                    # Path-scoped, auto-invoked (hidden from user)
│   │       ├── skill_authoring/     # Auto-load when editing SKILL.md
│   │       ├── hook_authoring/      # Auto-load when editing hook scripts
│   │       ├── agent_authoring/     # Auto-load when editing agent files
│   │       └── memory-extraction/   # Auto-invoke after operations
│   │
│   ├── agents/                      # Specialized agents (spawn in worktree context)
│   │   ├── code-reviewer.md         # Fresh-context code review
│   │   ├── hardware-reviewer.md     # KiCad schematic & PCB review
│   │   ├── research-analyst.md      # Perplexity web search + codebase analysis
│   │   ├── bom-auditor.md           # BOM completeness & sourcing audit
│   │   ├── deployment-validator.md  # Pre-deploy safety checklist
│   │   ├── session-analyst.md       # Session log analysis for patterns
│   │   ├── sprint-planner.md        # Velocity-based sprint planning
│   │   ├── security-reviewer.md     # OWASP & security audit
│   │   └── memory-extractor.md      # Auto-extract durable learnings
│   │
│   ├── commands/                    # CLI command definitions (kilo integration)
│   │   ├── commit.md
│   │   ├── review.md
│   │   ├── research.md
│   │   ├── sprint.md
│   │   ├── verify.md
│   │   ├── catchup.md
│   │   ├── session-mine.md
│   │   └── memory-sync.md
│   │
│   ├── hooks/                       # Git & event hooks
│   │   ├── global/
│   │   │   ├── memory-auto-extract.sh   # Fire after tool operations
│   │   │   └── skill-discovery.sh       # Find & register new skills
│   │   │
│   │   └── project/                 # Project-specific hooks (in project repos)
│   │
│   ├── rules/                       # Language/tool specific rules
│   │   ├── python.md               # `py` launcher, f-strings, pathlib, type hints
│   │   ├── shell-scripts.md        # set -euo pipefail, SSH quoting, CRLF handling
│   │   └── kicad.md                # S-expression structure, grid snapping, power symbols
│   │
│   └── scripts/                     # Python utilities
│       └── memory_extract.py        # Session log → memory file parser
│
├── kilo.json                         # Command aliasing & keybinding configuration
├── bootstrap_global.sh               # Install script: flattens & deploys to ~/.claude/
│
└── memory/                           # User's local memory (not committed, auto-generated)
    ├── MEMORY.md                    # Index of memory files
    ├── user_role.md
    ├── feedback_*.md
    ├── project_*.md
    └── reference_*.md
```

---

## Category System

Skills are organized into three categories:

### 1. **Workflow** (11 skills)
User-facing CLI commands and utilities for code, documentation, and project management.

| Skill | Purpose |
|-|-|
| **commit** | Task-aware git commits with conventional format |
| **review** | Fresh-context code review (writer/reviewer pattern, worktree isolation) |
| **research** | Deep research: Perplexity web search + codebase analysis |
| **sprint** | Sprint planning: open/close lifecycle, velocity tracking |
| **verify** | Pre-commit quality gate: build, types, lint, tests, secrets |
| **catchup** | Restore context after `/clear`: git state, sprint, recent work |
| **memory_sync** | Sync session learnings to persistent memory files |
| **session_mine** | Analyze session logs for patterns and improvement opportunities |
| **bootstrap** | Install global config to ~/.claude/ (flattens organized repo structure) |
| **doctor** | Diagnose Claude Code setup issues |
| **verifier_hooks** | Run verification before commits/PRs |

### 2. **Hardware** (10 skills)
Electronics design, component sourcing, PCB fabrication, and mechanical design.

| Skill | Purpose |
|-|-|
| **kicad** | Schematic & PCB analysis: design review, DFM scoring, BOM extraction |
| **bom** | Bill of Materials: search, source, order coordination |
| **digikey** | Component search (primary prototype source); datasheet downloads via API |
| **mouser** | Component search (secondary source) |
| **lcsc** | Production sourcing (JLCPCB parts library) |
| **element14** | International sourcing (Newark, Farnell, element14) |
| **jlcpcb** | PCB fabrication & assembly ordering; LCSC integration |
| **pcbway** | Alternative PCB service (turnkey assembly) |
| **openscad** | Parametric 3D modeling; print-ready STL/3MF export |
| **ee** | Electrical engineering reference (circuits, power, RF, thermal, EMC) |

### 3. **Auto** (4 path-scoped, hidden skills)
Auto-invoked when editing specific file types. Not user-facing; internal use only.

| Skill | Trigger | Purpose |
|-|-|-|
| **skill_authoring** | Editing `SKILL.md` | Auto-load skill writing reference |
| **hook_authoring** | Editing hook scripts | Auto-load hook writing reference |
| **agent_authoring** | Editing agent files | Auto-load agent writing reference |
| **memory-extraction** | After tool operations | Auto-extract durable learnings to memory |

---

## Agent System

Nine specialized agents spawn in isolated worktree contexts for independent analysis:

### Code & Design Review
- **code-reviewer** — Fresh-context code review (finds bugs, security issues, performance problems)
- **hardware-reviewer** — KiCad schematic & PCB review (pin mapping, power routing, DFM)
- **security-reviewer** — OWASP & injection audit; secret detection

### Research & Analysis
- **research-analyst** — Web search + codebase cross-reference (structured reports)
- **session-analyst** — Session log mining (patterns, inefficiencies, skill gaps)
- **bom-auditor** — BOM completeness & sourcing audit

### Project Planning
- **sprint-planner** — Velocity-based sprint planning (task sizing, dependency chains)
- **deployment-validator** — Pre-deploy safety checklist (config, dependencies, secrets)

### Memory Management
- **memory-extractor** — Auto-invoke after significant work; extract durable learnings

---

## Memory System

Persistent memory lives in `~/.claude/projects/{project}/memory/` with 6 file types:

```
memory/MEMORY.md                  # Index (under 200 lines, loaded every session)
├── user_role.md                  # User's role, goals, preferences, expertise
├── feedback_debugging.md         # Corrections & validated approaches
├── feedback_security.md
├── project_architecture.md       # Ongoing initiatives, blockers, state
├── project_sprint_status.md
└── reference_git_workflow.md     # External system pointers (Linear, Grafana, etc.)
```

**Auto-populated by:** `memory-auto-extract.sh` hook (fires after tool operations) → `memory_extract.py` → memory files.

**Preserved across sessions:** User preferences, project context, prior research findings.

**Cleared with:** `/clear` command (session reset without losing memory).

---

## Bootstrap Workflow

Installation is a two-step process:

```bash
# Step 1: Clone the repository
git clone https://github.com/mattpainter701/my-claude-setup.git
cd my-claude-setup

# Step 2: Run bootstrap (flattens organized repo structure to ~/.claude/)
bash bootstrap_global.sh
```

**What bootstrap does:**
1. Backs up existing `~/.claude/` to timestamped backup
2. Flattens organized repo structure:
   - `claude-config/skills/workflow/*` → `~/.claude/skills/`
   - `claude-config/skills/hardware/*` → `~/.claude/skills/`
   - `claude-config/skills/auto/*` → `~/.claude/skills/`
3. Installs agents, hooks, rules, scripts, kilo.json
4. Verifies all 25 skill directories installed correctly

**Why flatten?** Organized repo structure aids development & discoverability. Flat `~/.claude/` keeps user environment simple. Bootstrap automates the transformation.

---

## Metadata Structure

Every SKILL.md includes a metadata block:

```yaml
---
name: skill-name
description: One-line hook (used to decide relevance in future conversations)
metadata:
  version: "2.0"
  effort: medium        # quick, medium, involved
  auto-invocable: false # true = can be invoked without user asking
  category: hardware    # workflow, hardware, auto
  compatible-claude-code:
    when_to_use: "When user mentions X or needs Y"
    allowed-tools: ["Bash", "Read", "Grep", "Glob"]
---
```

**Purpose:** Helps Claude understand skill scope, availability, and applicability.

---

## Extending the Setup

### Adding a New Skill

1. **Create organized structure** in `claude-config/skills/{category}/{skill-name}/SKILL.md`
2. **Add metadata block** at the top (version, effort, category, when-to-use)
3. **Write comprehensive content** with headings, examples, troubleshooting
4. **Add to CLAUDE.global.md** Skills inventory
5. **Run bootstrap** to flatten and install: `bash bootstrap_global.sh`
6. **Commit & push**

### Adding a New Agent

1. **Create `claude-config/agents/{agent-name}.md`** with:
   - Clear charter (what the agent does)
   - Constraints (tools it has access to)
   - Output format
   - When to spawn it
2. **Add to CLAUDE.global.md** Agents section
3. **Bootstrap, commit, push**

### Adding a Hook

1. **Create `claude-config/hooks/global/{hook-name}.sh`** with:
   - `set -euo pipefail` at top
   - Exit codes: 0=pass, 1=warn, 2=block
   - Clear comments on when it fires
2. **Test locally** (verify it runs and captures output)
3. **Add to CLAUDE.global.md**
4. **Bootstrap, commit, push**

---

## Key Design Decisions

### Why Organized Repo + Flat Installation?

**Repo organization** aids:
- Clear categorization during development
- Easy discovery of related skills
- Scalability (100+ skills stay organized)

**Flat ~/.claude/** aids:
- Simple CLI: `/skill` finds it in one place
- Clear mental model for users
- No nested path confusion

Bootstrap bridges both: organized development, flat deployment.

### Why Worktree Isolation for Agents?

Agents in isolated `git worktree` contexts:
- No bias from main session context
- Fresh eyes on code/design reviews
- Safe experimentation (no impact on user work)
- Automatic cleanup

### Why Metadata Blocks?

Metadata enables:
- Claude to auto-discover skill relevance
- Self-documenting capabilities
- Version tracking and deprecation
- Compatibility checking

### Why Path-Scoped Auto-Skills?

Auto-skills that trigger on file edit:
- Authoring help appears when you need it
- No user invocation required
- Transparent assistance for skill/hook/agent authors
- Keeps advanced features discoverable but out of the way

---

## Usage Patterns

### Single-File Review
```bash
/review src/main.py
# Spawns code-reviewer agent on that file
```

### Pre-Flight Check
```bash
/verify pre-pr
# Runs full test suite, security scan, type check
```

### Deep Research
```bash
/research optimal buffer sizing for real-time audio
# Returns structured report: web sources + codebase examples + recommendations
```

### Sprint Planning
```bash
/sprint open
# Analyzes velocity, proposes next sprint tasks
```

### Bootstrap New Machine
```bash
bash bootstrap_global.sh
# Syncs all skills, agents, hooks, config to ~/.claude/
```

---

## Continuous Improvement

The setup is **self-improving**:

1. **Session analysis** (`memory-auto-extract.sh` hook) captures learnings
2. **Memory extraction** (`memory_extract.py`) parses session logs
3. **Auto-memory** system stores durable findings
4. **Future sessions** begin with learned context

Over time:
- Missing documentation is found and added
- Inefficient workflows are detected and refactored
- Recurring errors become rules in CLAUDE.md
- Skills are updated with verified patterns

---

## Status & Roadmap

✅ **Implemented (Phase 1-8):**
- 25 skills (11 workflow, 10 hardware, 4 auto)
- 9 agents (specialized reviewers + planners)
- Auto-memory system with 6 memory types
- Hook system (pre-commit, post-operation)
- Bootstrap workflow with flattening
- Comprehensive documentation

🎯 **Future Directions:**
- MCP server integrations (Figma, Jira, Slack)
- Extended hardware skills (FPGA, firmware testing)
- Cloud deployment validation
- Advanced project templates

---

## Support & Contributing

- **Documentation**: Read CLAUDE.global.md for complete skills inventory
- **Issues**: File bug reports or feature requests on GitHub
- **Questions**: Consult individual SKILL.md files for deep dives

---

**Last Updated:** 2026-03-31

**Maintained by:** mattpainter701

**License:** MIT
