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
- **Commit:** @~/.claude/skills/commit/SKILL.md — task-aware commits, conventional format
- **Sprint:** @~/.claude/skills/sprint/SKILL.md — sprint open/close lifecycle (manual only)
- **Research:** @~/.claude/skills/research/SKILL.md — deep research with structured reports
- **Memory sync:** @~/.claude/skills/memory_sync/SKILL.md — auto-invoked memory updates
- **Catchup:** @~/.claude/skills/catchup/SKILL.md — restore context after /clear
- **Review:** @~/.claude/skills/review/SKILL.md — fresh-context code review (writer/reviewer pattern)
- **Session mine:** @~/.claude/skills/session_mine/SKILL.md — analyze session logs for patterns
- **KiCad:** @~/.claude/skills/kicad/SKILL.md — analyze schematics, PCB layouts, Gerbers, design review
- **BOM:** @~/.claude/skills/bom/SKILL.md — BOM lifecycle, sourcing, pricing, per-supplier order files
- **DigiKey:** @~/.claude/skills/digikey/SKILL.md — component search + datasheet downloads
- **Mouser:** @~/.claude/skills/mouser/SKILL.md — secondary prototype sourcing
- **LCSC:** @~/.claude/skills/lcsc/SKILL.md — production sourcing (JLCPCB parts library)
- **JLCPCB:** @~/.claude/skills/jlcpcb/SKILL.md — PCB fab & assembly ordering
- **PCBWay:** @~/.claude/skills/pcbway/SKILL.md — alternative PCB fab & assembly
- **OpenSCAD:** @~/.claude/skills/openscad/SKILL.md — parametric 3D models, enclosures, print-ready STL/3MF

## Session Hygiene
- `/clear` between unrelated tasks. Context pollution causes drift.
- Two-correction rule: if corrected twice on same issue, /clear and restart.
- After `/clear`, use `/catchup` to restore git context.

## Compaction Guidance
When compacting, preserve: modified file list, test commands and results,
current sprint/task numbers, the specific bug or feature being worked on.

## Agents
- **code-reviewer:** @~/.claude/agents/code-reviewer.md — fresh-context code review
- **session-analyst:** @~/.claude/agents/session-analyst.md — session log analysis

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

## Self-Maintenance
When you notice any of these during a session, update the relevant CLAUDE.md or memory file **proactively** (don't wait to be asked):
- A new connection method, host, or credential pattern was used
- A workflow rule was established or corrected by the user
- A recurring mistake suggests a missing rule
- A project convention was discovered that isn't documented
- The user says "remember this" or "always do X"

For project CLAUDE.md changes: edit in-place, keep it concise, don't bloat.
For global CLAUDE.md changes: only add rules that genuinely apply across all projects.
For memory files: prefer updating existing entries over creating new ones.
