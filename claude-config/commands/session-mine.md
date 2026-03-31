---
description: Analyze Claude Code session logs for patterns and improvement opportunities
agent: session-analyst
subtask: true
---

Analyze session logs to find patterns, inefficiencies, and improvement opportunities.

## Process

1. Parse arguments for days_back (default: 7)
2. Run the mining script: `py ~/.claude/scripts/session_mine.py <days_back>`
3. If the script isn't available, analyze raw JSONL files directly
4. Produce report with:
   - Session stats (count, avg duration, longest)
   - Tool usage (top 5 most-used)
   - Hot files (most-read and most-edited)
   - Patterns (recurring searches, errors, repeated workflows)
   - Skill gap analysis
   - Recommendations (3 actionable improvements)
