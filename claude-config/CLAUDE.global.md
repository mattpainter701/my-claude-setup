# Global Rules

## Platform
- Windows 11 + PowerShell. Use `py` not `python`. Paths use forward slashes in bash.
- Git Bash is the shell. Unix syntax applies inside Bash tool calls.

## Commits
- NEVER add `Co-Authored-By` lines to commits. Not for Claude, not for anyone.
- Commit messages: imperative mood, concise. Reference task numbers when applicable.

## Workflow — TASKS.md & CHANGELOG.md Are Law
- **Before any work:** Read `TASKS.md`. Work only on what's listed. Don't invent tasks.
- **Claim before starting:** Mark a task `— IN PROGRESS` in the heading before beginning work (e.g., `### 465. Expand held-out corpus (P1, MEDIUM) — IN PROGRESS`). If a task is already marked IN PROGRESS, **do not work on it** — another agent or session is handling it. Pick a different task or ask the user.
- **After completing work:** Remove the IN PROGRESS marker, update `TASKS.md` (check boxes, add summary) AND `CHANGELOG.md` (versioned entry with Added/Changed/Fixed/Tests sections).
- If either file doesn't exist in a project, ask before creating one.
- Never skip updating these files. They are the project's source of truth.

## Connection Methods → Project Memory
- When you discover or establish a connection method (SSH host, API endpoint, device address, broker URL, auth method), **always save it to project memory** (`memory/MEMORY.md` or a topic file).
- Include: host/IP, port, user, auth method, any gotchas (key setup, VPN required, etc.).
- Update existing entries rather than duplicating.

## Response Style
- Don't echo file contents back — the user can see tool output.
- Don't narrate tool calls ("Let me read..." / "Now I'll edit..."). Just do it.
- Keep explanations proportional to complexity.

## Tables — Strict
- Markdown tables: minimum separator (`|-|-|`). No padded hyphens.
- NEVER use box-drawing characters (`┌ ┬ ─ │ └ ┘ ├ ┤ ┼`). Banned everywhere.

## Skills

### Workflow (Core)
- **Commit:** @~/.claude/skills/commit/SKILL.md — task-aware commits, conventional format
- **Sprint:** @~/.claude/skills/sprint/SKILL.md — sprint open/close lifecycle (manual only)
- **Research:** @~/.claude/skills/research/SKILL.md — deep research with structured reports
- **Memory sync:** @~/.claude/skills/memory_sync/SKILL.md — auto-invoked memory updates
- **Catchup:** @~/.claude/skills/catchup/SKILL.md — restore context after /clear
- **Review:** @~/.claude/skills/review/SKILL.md — fresh-context code review (writer/reviewer pattern)
- **Session mine:** @~/.claude/skills/session_mine/SKILL.md — analyze session logs for patterns
- **Verify:** @~/.claude/skills/verify/SKILL.md — pre-commit/pre-PR quality gate
- **Doctor:** @~/.claude/skills/doctor/SKILL.md — audit ~/.claude and project wiring
- **Bootstrap:** @~/.claude/skills/bootstrap/SKILL.md — scaffold or refresh global/project/MCP/statusline setup
- **Verifier hooks:** @~/.claude/skills/verifier_hooks/SKILL.md — arm a one-shot post-edit verifier hook

### Hardware Design & Sourcing
- **KiCad:** @~/.claude/skills/kicad/SKILL.md — analyze schematics, PCB layouts, Gerbers, design review
- **BOM:** @~/.claude/skills/bom/SKILL.md — BOM lifecycle, sourcing, pricing, per-supplier order files
- **EE:** @~/.claude/skills/ee/SKILL.md — circuit analysis, power supply design, signal integrity, RF, thermal, EMC
- **DigiKey:** @~/.claude/skills/digikey/SKILL.md — component search + datasheet downloads (primary prototype source)
- **Mouser:** @~/.claude/skills/mouser/SKILL.md — secondary prototype sourcing
- **Element14:** @~/.claude/skills/element14/SKILL.md — Newark/Farnell/element14 component sourcing
- **LCSC:** @~/.claude/skills/lcsc/SKILL.md — production sourcing (JLCPCB parts library)
- **JLCPCB:** @~/.claude/skills/jlcpcb/SKILL.md — PCB fab & assembly ordering
- **PCBWay:** @~/.claude/skills/pcbway/SKILL.md — alternative PCB fab & assembly (turnkey sourcing)
- **OpenSCAD:** @~/.claude/skills/openscad/SKILL.md — parametric 3D models, enclosures, print-ready STL/3MF

### Auto/Hidden (Path-Scoped, Auto-Loaded)
- **skill_authoring:** Auto-loaded when editing `claude-config/skills/*/SKILL.md` — guidance for consistent skill metadata, documentation, and tooling
- **hook_authoring:** Auto-loaded when editing `claude-config/hooks/**` — guidance for hook scripts, matchers, blocking behavior
- **agent_authoring:** Auto-loaded when editing `claude-config/agents/**` — guidance for agent permissions, isolation, memory scope
- **memory-extraction:** Auto-loaded at session end — extracts durable learnings (decisions, preferences, connections) into project memory

### Repository Organization
The **repo** uses an organized structure:
```
claude-config/skills/
  workflow/          (commit, sprint, research, etc.)
  hardware/          (kicad, bom, digikey, mouser, etc.)
  auto/              (path-scoped authoring helpers)
```

The **`/bootstrap global`** command flattens this into `~/.claude/skills/` for local use:
```
~/.claude/skills/
  commit/
  sprint/
  kicad/
  bom/
  ee/
  (all together, no subdir organization)
```

This allows the repo to stay organized for development while keeping `~/.claude` flat for direct skill references.

## Session Hygiene
- `/clear` between unrelated tasks. Context pollution causes drift.
- Two-correction rule: if corrected twice on same issue, /clear and restart.
- After `/clear`, use `/catchup` to restore git context.
- **Manual `/compact` at ~50% context** — don't wait for auto-compact. Earlier compaction preserves more useful context than late emergency compaction.
- **`Esc Esc` or `/rewind`** to undo a bad Claude action. Better than trying to fix mistakes in degraded context — rewind and retry with a clearer prompt.

## Compaction Guidance
When compacting, preserve: modified file list, test commands and results,
current sprint/task numbers, the specific bug or feature being worked on.

## Agents
- **code-reviewer:** @~/.claude/agents/code-reviewer.md — fresh-context code review (worktree isolation, project memory)
- **session-analyst:** @~/.claude/agents/session-analyst.md — session log analysis (user memory)
- **hardware-reviewer:** @~/.claude/agents/hardware-reviewer.md — KiCad schematic + PCB review (worktree isolation, project memory)
- **research-analyst:** @~/.claude/agents/research-analyst.md — Perplexity + codebase research (project memory)
- **bom-auditor:** @~/.claude/agents/bom-auditor.md — BOM completeness & sourcing audit (project memory)
- **deployment-validator:** @~/.claude/agents/deployment-validator.md — pre-deploy safety checklist (project memory)
- **sprint-planner:** @~/.claude/agents/sprint-planner.md — velocity-based sprint planning (project memory)
- **security-reviewer:** @~/.claude/agents/security-reviewer.md — OWASP/secrets/injection audit (proactive on auth/API code)
- **memory-extractor:** @~/.claude/agents/memory-extractor.md — auto-extracts durable learnings (decisions, corrections, preferences, connection methods) at session end

## Tools
- **jq:** Installed via winget. Used by hook scripts for JSON parsing.
- **recall:** `recall` — full-text search TUI for CC sessions. Type to search, Enter to resume.

## Shipping Guardrails

1. Refactors must preserve failure semantics. Core dependencies must fail closed, not degrade silently, unless explicitly approved.
2. Deprecated entrypoints must become compatibility shims or be removed. Do not keep divergent live implementations.
3. Shared mocks/fixtures must match the production contract:
   - method signatures
   - connection/error behavior
   - state mutation side effects
   - returned metadata/schema
4. Passing existing tests is not sufficient after refactor/mock unification. Add a regression for the highest-risk new failure mode.
5. Before marking work DONE, run at least one direct probe for the contract most likely to drift.
6. When using mock data or placeholder variables, document each instance (location, what it replaces, what real values look like) so they can be refined later.

## Token Optimization Strategy

### 1. Code Review Graph (Structural Analysis)
- Use **Glob** and **Grep** as primary navigation tools, not `cat`/`head`/`tail`.
- On large monorepos, use the **Explore agent** (`subagent_type: "Explore"`) for smart codebase queries instead of whole-file reads.
- Read only the dependency subgraph relevant to a change. Before reading a large file:
  - Use Grep to locate the specific function/symbol.
  - Read only that section with `offset`/`limit` parameters.
  - Avoid dumping entire files into context.
- For code review or refactoring tasks, use the Explore agent to map dependencies first.

### 2. Claude Token Efficient (Terseness)
- **Never echo file contents** — the user can see tool output.
- **No narration** of tool calls ("Let me read...", "Now I'll edit..."). Just do it.
- **No trailing summaries** unless user explicitly requests one.
- **No explanations of obvious code** — if logic is self-evident, skip it.
- **Lead with the answer**, not reasoning. Result first, then minimal context.
- **Skip filler words** — remove preamble and unnecessary transitions.
- Prefer terse, direct sentences over long explanations.
- **One-sentence rule**: If it fits in one sentence, don't use three.

### 3. Token Savior (Symbol-Level Navigation via Memory)
- Store APIs, key functions, module structure, and architecture in **project memory** (`memory/MEMORY.md`).
- Save symbol-level findings (function signatures, class hierarchies, module boundaries) instead of inline explanations.
- When referencing codebase structure, **cite memory by symbol name** (e.g., "per memory, `AuthHandler.login()` handles JWT creation").
- Update memory when discovering new module patterns, exported APIs, or internal contracts.
- Use memory to replace repetitive codebase explanations across conversation turns.

### 4. Session Efficiency (from claude-token-efficient)
- **Do not re-read files** you have already read in the current session unless the file may have changed.
- **Skip files over 100KB** unless explicitly required for the task — grep/offset/limit read only what's needed.
- **Suggest `/cost`** when a session feels long so the user can monitor cache ratio.
- **No sycophantic openers or closing fluff** — no "Great question!", "Happy to help!", trailing recap paragraphs.

### 5. Code Review Graph MCP (installed)
- **Installed globally** as user-scope MCP server (`code-review-graph serve`).
- Per-project setup: run `code-review-graph build` in each project root to generate the Tree-sitter graph.
- MCP tools available: `detect_changes`, `get_impact_radius`, `get_affected_flows`, `query_graph`, `semantic_search_nodes`, `list_communities`, `get_architecture_overview`, etc.
- Global skills installed: `crg-debug-issue`, `crg-explore-codebase`, `crg-refactor-safely`, `crg-review-changes`.
- PostToolUse hook: `code-review-graph update --skip-flows` runs after Edit/Write to keep graph current (silent no-op on projects without a graph).
- **Prefer CRG tools over raw Grep for codebase navigation** once a graph exists — they return dependency subgraphs instead of file dumps.

## Self-Maintenance
When you notice any of these during a session, update the relevant CLAUDE.md or memory file **proactively** (don't wait to be asked):
- A new connection method, host, or credential pattern was used
- A workflow rule was established or corrected by the user
- A recurring mistake suggests a missing rule
- A project convention was discovered that isn't documented
- The user says "remember this" or "always do X"

For project CLAUDE.md changes: edit in-place, keep it concise, don't bloat.
If the project needs more structure, split topic-specific instructions into `.claude/rules/*.md` and keep the top-level file short.
Use `CLAUDE.local.md` for private machine-specific notes that should not be committed.
For global CLAUDE.md changes: only add rules that genuinely apply across all projects.
For memory files: prefer updating existing entries over creating new ones.
