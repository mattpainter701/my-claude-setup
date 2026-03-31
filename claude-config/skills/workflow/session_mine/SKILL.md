---
name: session_mine
description: >
  Analyze Claude Code session logs for patterns, inefficiencies, and improvement
  opportunities. Parses JSONL session files to find hot files, error patterns, and skill gaps.
metadata:
  version: "2.0"
  effort: medium
  auto-invocable: false
  category: workflow
  compatible-claude-code:
    when_to_use: "When analyzing session patterns or finding skill improvement opportunities"
    allowed-tools: ["Agent", "Bash"]
---

# Session Mining Skill

Usage: `/session_mine [days_back]`

Analyze Claude Code session logs to find patterns, inefficiencies, and
improvement opportunities. Runs in a forked agent context.

## Process

1. **Parse arguments** from `$ARGUMENTS`:
   - `days_back`: number of days to analyze (default: 7)

2. **Spawn an analysis agent** using the Agent tool:
   - `subagent_type`: `general-purpose`
   - `model`: `sonnet`
   - Task: Run the mining script and interpret results.

   Agent prompt:
   ```
   Run: py ~/.claude/scripts/session_mine.py <days_back>

   Then analyze the output and produce a report (under 2500 chars):

   **Session Stats:**
   - Total sessions, avg duration, longest session

   **Tool Usage:**
   - Top 5 most-used tools with counts
   - Tools that are underused (e.g., Grep vs Bash grep)

   **Hot Files:**
   - Most-read files (candidates for CLAUDE.md context)
   - Most-edited files

   **Patterns:**
   - Recurring search terms → missing docs
   - Common error patterns → missing rules
   - Repeated workflows → skill candidates

   **Skill Gap Analysis:**
   Look for these patterns that indicate a skill needs updating:
   - User corrections after skill-generated output (e.g., "no, remove that shelf",
     "make the holes bigger") → skill has wrong defaults or missing options
   - Repeated manual fixes to skill output (e.g., always editing the same section
     after generation) → skill template needs updating
   - WebSearch/research done during skill use → skill is missing reference data
   - Same skill invoked 3+ times in one session with incremental fixes → skill
     workflow is incomplete or unclear
   - Tool errors during skill execution → skill has wrong commands or assumptions

   For each gap found, output:
   - Which skill file needs updating
   - What specific section/content to add or fix
   - Evidence (session count, correction count)

   **Recommendations:**
   - 3 actionable improvements for CLAUDE.md, skills, or hooks
   - Prioritize skill updates over new rules (skills compound, rules don't)
   ```

3. **Return the report** to the user.

## Rules
- Always use a subagent — session logs can be large.
- If the mining script doesn't exist or fails, report the error clearly.
- Do not modify any files. Analysis only.
