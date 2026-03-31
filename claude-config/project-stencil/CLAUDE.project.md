# [Project Name] — Project Rules

[One-line project description. What does it do? What domain?]

## Critical Rules

1. **Never remove functional code** without tracing all callers and confirming nothing breaks.
2. **Never hallucinate** file paths, test results, or domain-specific parameters. Read files to verify.
3. **Always read TASKS.md** before starting work. Follow priority order: P0 > P1 > P2 > Backlog.
4. **Run tests before committing** core logic changes. If tests fail, fix the code.
5. **Update TASKS.md and CHANGELOG.md** when completing a task. Check the box, add a summary, add a changelog entry.
6. **Never mark a task DONE** if the review finding has no targeted regression test.
7. **When a bug is found in post-implementation review,** label it in CHANGELOG.md as a code-review follow-up.

<!-- Add domain-specific safety rules here. Examples:
- Never weaken safety checks without explicit user approval.
- For API/router refactors, core surfaces must not swallow import failures.
- For hardware mocks, preserve connection guards and metadata exactly.
-->

## Rule Layering

- Keep the highest-signal shared project rules in this file.
- Use `.claude/rules/*.md` for topic-specific checked-in rules such as testing, deploys, hardware, or release flow.
- Use `CLAUDE.local.md` for private machine-specific notes that should not be committed.
- If a rule block becomes long or reusable, move it into a rule file and `@include` it instead of bloating this file.

## Skills

<!-- List project-specific skills here. Format: -->
<!-- - **Skill name:** @path/to/SKILL.md — one-line description -->

## Hooks (deterministic enforcement)

**Global hooks** (`~/.claude/settings.json`):
- **Co-Authored-By blocker** (PreToolUse → Bash): Hard-blocks any `git commit` containing "Co-Authored-By".
- **Completion tones** (Stop): Ascending chirp on success, descending tone on error/failure.
- **Permission toast** (Notification): Windows toast + double-beep when Claude needs permission approval.
- **Auto-lint** (PostToolUse → Edit|Write): Runs `ruff check --fix` + `ruff format` on Python files after every edit. Silent, non-blocking.
- **Session context** (SessionStart → resume|compact|clear): Auto-injects version, branch, recent commits, uncommitted changes, and current sprint.

**Project hooks** (`.claude/settings.local.json`):
- **Test gate** (PreToolUse → Bash): Blocks `git commit` unless test marker exists and is < 30 min old. Run pytest to create the marker.
- **Docs gate** (PreToolUse → Bash): Warns if code files are staged but TASKS.md or CHANGELOG.md are not. Soft warning, not hard block.
- **Test marker** (PostToolUse → Bash): Auto-creates test marker after successful pytest. Parses pytest summary line to avoid false negatives from test names containing "failed".
- **Compaction context** (PreCompact): Injects version, recent commits, and current sprint into compaction summaries.

Claude Code also supports richer hook definitions when deterministic shell hooks are not enough:
- `if`, `shell`, `timeout`, `statusMessage`, `async`, `asyncRewake`
- `prompt`, `http`, and `agent` hook types
- For high-risk paths such as auth, deploys, migrations, or hook/skill/agent edits, prefer a narrow `agent` `PostToolUse` verifier hook over a noisy broad always-on review loop.

## Proactive Behaviors

1. **Before committing core changes:** Run full test suite, not just changed tests.
2. **When external connections fail:** Diagnose first (auth? network? config?) — don't just retry.

<!-- Add project-specific proactive behaviors here. Examples:
- Before SSH: run fleet health check.
- Before deploying: use deploy scripts, not manual scp.
- PATH leak prevention: single-quote SSH commands containing $ variables.
-->

## Context Efficiency

### Subagent Discipline

**Context-aware delegation:**
 - Under ~50k context: prefer inline work for tasks under ~5 tool calls.
 - Over ~50k context: prefer subagents for self-contained tasks, even simple ones — the per-call token tax on large contexts adds up fast.

When using subagents, include output rules: "Final response under 2000 characters. List outcomes, not process."
Never call TaskOutput twice for the same subagent. If it times out, increase the timeout — don't re-read.

### File Reading
Read files with purpose. Before reading a file, know what you're looking for.
Use Grep to locate relevant sections before reading entire large files.
Never re-read a file you've already read in this session.
For files over 500 lines, use offset/limit to read only the relevant section.
