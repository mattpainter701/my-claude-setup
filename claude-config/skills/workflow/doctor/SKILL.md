---
name: doctor
description: Validate a Claude Code install and the current project setup. Use when Claude needs to audit ~/.claude wiring, helper scripts, hooks, agents, dependencies, or optional MCP/statusline setup before troubleshooting.
argument-hint: "[quick|full]"
allowed-tools:
  - Bash
  - Read
  - Grep
  - Glob
disable-model-invocation: true
metadata:
  version: "2.0"
  effort: medium
  auto-invocable: false
  category: workflow
  compatible-claude-code:
    when_to_use: "When troubleshooting a Claude Code/Kilo setup"
    allowed-tools: ["Bash", "Read", "Grep", "Glob"]
---

# Doctor Skill

Usage: `/doctor [quick|full]`

Run the Claude doctor script and summarize the results.

## Process

1. Parse `$ARGUMENTS`. Default to `quick`.
2. Prefer the installed script:

```bash
py ~/.claude/scripts/claude_doctor.py --mode "<mode>" --project-root "$PWD"
```

3. If the installed script is missing but this repo contains the source, fall back to:

```bash
py claude-config/scripts/claude_doctor.py --mode "<mode>" --project-root "$PWD"
```

4. Summarize the output in priority order:
   - blocking install failures first
   - missing hook or helper-script wiring second
   - optional MCP/statusline/setup gaps last

## Output Rules

- Quote the exact missing file, directory, or settings key when the script reports one.
- Keep the summary short; users can rerun the script for the full raw audit.
- Do not edit anything automatically unless the user explicitly asks for fixes.
