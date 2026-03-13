---
name: research
description: >
  Deep research on any topic. Searches the web, documentation, and codebase.
  Returns a structured report with sources and actionable recommendations.
context: fork
allowed-tools:
  - WebSearch
  - WebFetch
  - Read
  - Grep
  - Glob
  - mcp__plugin_context7_context7__resolve-library-id
  - mcp__plugin_context7_context7__query-docs
---

# Research Skill

Usage: `/research <question or topic>`

You are conducting research on: `$ARGUMENTS`

## Process

### 1. Understand the Question
Parse the research topic. Identify:
- Is this about a library/framework? (use Context7)
- Is this about a technique/pattern? (use WebSearch)
- Is this about something in the current codebase? (use Grep/Glob)
- Is this a comparison? (research both sides)

### 2. Check Existing Knowledge
- Read `memory/MEMORY.md` if it exists — check for prior findings on this topic
- Search the codebase for related implementations (`Grep` for keywords)

### 3. Research

**For libraries/frameworks:**
1. Resolve the library ID via Context7
2. Query Context7 docs for the specific question
3. WebSearch for recent updates, known issues, alternatives

**For techniques/patterns:**
1. WebSearch with specific, current-year queries
2. WebFetch key results for detailed reading
3. Search codebase for existing implementations of similar patterns

**For comparisons:**
1. Research each option independently
2. Find benchmarks, adoption data, maintenance status
3. Check compatibility with existing project stack

### 4. Produce Report

Structure your response exactly like this:

**Summary:** 2-3 sentences answering the question directly.

**Key Findings:**
- Bullet points with specifics (versions, numbers, dates)
- Include code snippets where relevant
- Note any caveats or limitations

**Sources:**
- [Title](URL) — 1-line description of what this source covers

**Codebase Relevance:**
- Existing files/patterns that relate to this research
- Whether the codebase already has a partial implementation

**Recommendations:**
- Actionable next steps (1-3 items)
- If this is a library choice, give a clear recommendation with reasoning

### 5. Save Durable Findings
If the research revealed:
- A connection method or endpoint → save to project memory
- An architecture decision or library evaluation → save to project memory
- A tool/workflow preference → consider for CLAUDE.md

Only save information that will be useful in future sessions. Don't save one-off answers.

## Perplexity Integration (Enhanced Research)

When `PERPLEXITY_API_KEY` is set, use Perplexity's Sonar API as the **primary research backend** before falling back to WebSearch. Perplexity returns grounded, cited answers from live web search — eliminating the WebSearch → WebFetch → parse chain.

### Setup

1. Get an API key at [console.perplexity.ai](https://console.perplexity.ai)
2. Set the environment variable:
   ```bash
   export PERPLEXITY_API_KEY=pplx-xxxxxxxxxxxxxxxxxxxx
   ```

### API Reference

**Endpoint:** `POST https://api.perplexity.ai/chat/completions`

**Auth:** `Authorization: Bearer $PERPLEXITY_API_KEY`

**OpenAI-compatible** — use the OpenAI SDK with `base_url` override:
```python
from openai import OpenAI

client = OpenAI(
    api_key=os.environ["PERPLEXITY_API_KEY"],
    base_url="https://api.perplexity.ai",
)

response = client.chat.completions.create(
    model="sonar-pro",
    messages=[
        {"role": "system", "content": "Be precise and cite sources."},
        {"role": "user", "content": "What are the ADRV9002 vs AD9361 key differences?"},
    ],
)
# response.citations contains source URLs
```

### Models

| Model | Use Case | Input/1M | Output/1M | Request/1K |
|-|-|-|-|-|
| `sonar` | Quick factual lookups, simple queries | $1 | $1 | $5-12 |
| `sonar-pro` | Complex queries, follow-ups, multi-step | $3 | $15 | $6-14 |
| `sonar-reasoning-pro` | Chain-of-thought, logical analysis | $2 | $8 | $6-14 |
| `sonar-deep-research` | Exhaustive multi-source research reports | $2 | $8 | — |

Request fees vary by search context depth (low/medium/high). No free tier.

### Request Parameters

```json
{
  "model": "sonar-pro",
  "messages": [{"role": "user", "content": "..."}],
  "search_domain_filter": ["arxiv.org", "ti.com"],
  "search_recency_filter": "month",
  "return_related_questions": true,
  "temperature": 0.2,
  "max_tokens": 2048,
  "stream": false
}
```

| Parameter | Type | Description |
|-|-|-|
| `model` | string | Required. One of the sonar models above. |
| `messages` | array | Required. OpenAI-format message array. |
| `search_domain_filter` | string[] | Restrict search to specific domains (e.g., `["ti.com", "analog.com"]`). |
| `search_recency_filter` | string | `"hour"`, `"day"`, `"week"`, `"month"`. Limits to recent results. |
| `return_related_questions` | bool | Include follow-up question suggestions. |
| `temperature` | float | 0.0-1.0. Lower = more factual. Default 0.2. |
| `max_tokens` | int | Max output tokens. |
| `stream` | bool | SSE streaming. |

### Response — Citations

The response extends OpenAI's format with a `citations` array:
```json
{
  "choices": [{"message": {"role": "assistant", "content": "The ADRV9002 [1]..."}}],
  "citations": [
    "https://www.analog.com/en/products/adrv9002.html",
    "https://www.ti.com/..."
  ]
}
```

Inline `[1]`, `[2]` markers in the content map to the `citations` array indices. Extract these for the Sources section of the research report.

### When to Use Which Model

| Research Type | Model | Why |
|-|-|-|
| Quick fact check | `sonar` | Cheapest, fast, good enough for simple lookups |
| Library comparison | `sonar-pro` | Handles nuance, follow-ups, multi-faceted queries |
| Architecture decision | `sonar-reasoning-pro` | Chain-of-thought for trade-off analysis |
| Deep dive / thorough | `sonar-deep-research` | Exhaustive multi-source synthesis |

### Research Process with Perplexity

When `PERPLEXITY_API_KEY` is available, modify Step 3:

**For libraries/frameworks:**
1. Resolve via Context7 first (authoritative docs)
2. Use `sonar-pro` with `search_domain_filter` targeting the library's domain for recent updates, known issues, migration guides
3. Fall back to WebSearch only if Perplexity returns no citations

**For techniques/patterns:**
1. Use `sonar-reasoning-pro` for architectural trade-off questions
2. Use `sonar` for quick factual lookups (e.g., "what's the default I2C pull-up resistance")
3. Domain-filter to authoritative sources when applicable (e.g., `["ipc.org", "ti.com"]` for hardware)

**For comparisons:**
1. Single `sonar-pro` call with both options in the prompt — Perplexity synthesizes across sources
2. Verify key claims with a targeted `sonar` follow-up if numbers seem off

**For "deep dive" or "thorough" requests:**
1. Use `sonar-deep-research` — it runs multi-step searches internally and returns comprehensive reports
2. Extract citations from the response for the Sources section
3. Cross-reference critical findings against codebase (Grep/Glob)

### Cost Control

- Default to `sonar` (~$0.005-0.012/query) for simple lookups
- Escalate to `sonar-pro` only for complex or multi-faceted questions
- Reserve `sonar-deep-research` for explicit "deep dive" requests
- A typical `/research` call costs $0.01-0.05 depending on model and output length

### Search API (Alternative)

For raw ranked results without AI synthesis — useful when you need URLs to WebFetch yourself:

```
POST https://api.perplexity.ai/search
{"query": ["ADRV9002 evaluation board schematic"]}
```

Returns `{title, url}` pairs. $5/1K requests. Use when you need to fetch and parse pages yourself rather than trust the AI summary.

### Implementation Checklist

To fully integrate Perplexity into this skill:

- [ ] **MCP server or script:** Create a Perplexity MCP tool or wrapper script that Claude can call via Bash. Options:
  - MCP server (preferred): Register as `mcp__perplexity__search` and `mcp__perplexity__research` tools
  - Bash script: `~/.claude/scripts/perplexity_search.py` called via Bash tool
  - Direct curl: Inline curl calls (works but verbose)
- [ ] **Credential handling:** Load `PERPLEXITY_API_KEY` from `~/.config/secrets.env` or environment
- [ ] **Model routing logic:** Auto-select model based on query complexity and user prefix ("deep dive" → deep-research, default → sonar)
- [ ] **Citation extraction:** Parse `[N]` markers from response content, map to `citations[]` URLs, format for Sources section
- [ ] **Fallback chain:** Perplexity → WebSearch → Context7 (graceful degradation if API key missing or quota exceeded)
- [ ] **Add to allowed-tools:** Update skill frontmatter to include the Perplexity tool once implemented
- [ ] **Rate limit handling:** Catch 429 responses, fall back to WebSearch

## Output Rules
- Default report length: under 1500 characters
- If the user prefixed with "deep dive" or "thorough": up to 4000 characters
- Always include Sources section with clickable URLs
- Always include Recommendations section
