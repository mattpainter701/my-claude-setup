---
description: Deep research combining Perplexity web search with codebase analysis
agent: research-analyst
subtask: true
---

Conduct deep research on the topic provided in the arguments.

## Process

1. Normalize the query for Perplexity search (expand acronyms, add context)
2. Launch parallel search:
   - Perplexity: `py ~/.claude/scripts/perplexity_search.py "<query>" --domains d1,d2`
   - Codebase: Grep/Glob for related implementations
3. Merge findings and cross-reference sources
4. Produce structured report with Summary, Key Findings, Sources, Project Alignment, Recommendations
5. Save durable findings to project memory if applicable

If Perplexity is unavailable, fall back to WebSearch + WebFetch.
