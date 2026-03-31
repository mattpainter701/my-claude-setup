---
name: research
description: >
  Deep research on any topic. Parallel Perplexity web search + Claude codebase analysis.
  Returns a structured report with cited sources and actionable recommendations.
context: fork
allowed-tools:
  - Bash
  - WebSearch
  - WebFetch
  - Read
  - Grep
  - Glob
  - Agent
  - mcp__plugin_context7_context7__resolve-library-id
  - mcp__plugin_context7_context7__query-docs
---

# Research Skill

Usage: `/research <question or topic>`

You are conducting research on: `$ARGUMENTS`

## Architecture

```
User: /research <raw query>
  |
  Step 1: NORMALIZE — Claude rewrites query for Perplexity + picks domain filters
  |
  Step 2: PARALLEL SEARCH (launch both simultaneously)
  |   |
  |   +-- Perplexity (background Bash) ---- sonar-pro web search + citations
  |   |
  |   +-- Claude (inline) ---------------- codebase Grep/Glob, memory, Context7
  |
  Step 3: MERGE — Claude reads Perplexity JSON, cross-references with codebase findings
  |
  Step 4: REPORT — structured output with both source sets merged
  |
  Step 5: SAVE — durable findings to project memory if applicable
```

Perplexity is the search layer. Claude is the reasoning layer. They run in parallel.

## Process

### Step 1: Normalize the Query

Before searching, rewrite the user's raw question into:

1. **Perplexity query** — a precise, search-optimized prompt. Add specifics the user implied:
   - Expand acronyms (e.g., "DF" → "direction finding")
   - Add year range ("2024-2025" for state-of-art questions)
   - Add technical context ("for SDR-based drone detection" if that's the project domain)
   - Keep under 200 words — Perplexity works best with focused queries

2. **Domain filter** — pick 3-5 authoritative domains for the topic:
   - Hardware/RF: `ieee.org`, `analog.com`, `ti.com`, `mdpi.com`, `arxiv.org`
   - Software/libraries: the library's official docs domain
   - Components: `digikey.com`, `mouser.com`, manufacturer sites
   - General tech: omit filter (let Perplexity search broadly)

3. **Recency filter** — set if the user wants current info:
   - "latest", "2025", "recent" → `--recency month`
   - Historical/foundational → omit

4. **Codebase keywords** — extract 2-3 grep patterns for local search:
   - Function names, module names, config keys related to the topic

### Step 2: Parallel Search

Launch **both searches simultaneously** — do not wait for one before starting the other.

**Perplexity (background Bash):**
```bash
py ~/.claude/scripts/perplexity_search.py "<normalized query>" \
  --domains "domain1.com,domain2.com" \
  --recency month \
  --max-tokens 2048
```

The script loads `PERPLEXITY_API_KEY` from `~/.config/secrets.env` automatically. Returns JSON:
```json
{
  "content": "AI-synthesized answer with [1] citation markers...",
  "citations": ["https://source1.com", "https://source2.com"],
  "model": "sonar-pro",
  "tokens_in": 100,
  "tokens_out": 1500
}
```

**Claude (inline, simultaneously):**
- `Grep` codebase for related implementations, configs, prior work
- `Read` `memory/MEMORY.md` — check for prior findings on this topic
- `Grep` existing research docs in `docs/research/` for overlap
- If library/framework: resolve via Context7, query docs
- If no Perplexity key: fall back to `WebSearch` + `WebFetch`

### Step 3: Merge

Read the Perplexity JSON result. Now Claude has two datasets:

| Source | Provides |
|-|-|
| Perplexity | Current web knowledge, citations, external state-of-art |
| Claude inline | Codebase context, project history, existing implementations, memory |

Cross-reference:
- Do Perplexity's findings align with what's already in the codebase?
- Does the codebase have partial implementations that Perplexity's sources could improve?
- Are there contradictions between web sources and existing project decisions?
- Which Perplexity citations are most relevant to this specific project?

### Step 4: Produce Report

Structure the final output:

---

**Summary:** 2-3 sentences answering the question directly. Lead with the answer.

**Key Findings:**
- Bullet points with specifics (versions, numbers, dates)
- Include code snippets where relevant
- Note any caveats or limitations
- Mark provenance: `[web]` for Perplexity-sourced, `[codebase]` for local findings

**Sources:**
- [Title](URL) — 1-line description (from Perplexity citations)
- `path/to/file.py:42` — relevant codebase reference (from Claude inline)

**Project Alignment:**
- How findings relate to current project architecture/goals
- Existing files/patterns that connect to this research
- Gaps between state-of-art and current implementation

**Recommendations:**
- Actionable next steps (1-3 items)
- If this is a library choice, give a clear recommendation with reasoning

**Research Stats:** `sonar-pro`, N tokens in, M tokens out, K citations

---

### Step 5: Save Durable Findings

If the research revealed:
- A connection method or endpoint → save to project memory
- An architecture decision or library evaluation → save to project memory
- A tool/workflow preference → consider for CLAUDE.md
- A key reference document → note in memory for future sessions

Only save information that will be useful in future sessions. Don't save one-off answers.

## Fallback Chain

If Perplexity is unavailable (no API key, 401, 429, timeout):

1. **WebSearch** — Claude's built-in web search (less precise, no citations array)
2. **WebFetch** — fetch specific URLs from WebSearch results
3. **Context7** — library/framework docs (always available)
4. **Codebase only** — Grep/Glob local findings (always available)

Never fail silently. If Perplexity errors, report the error and continue with fallback sources.

## Perplexity Wrapper Script

**Location:** `~/.claude/scripts/perplexity_search.py`

```bash
# Chat Completions (default — AI synthesis + citations)
py ~/.claude/scripts/perplexity_search.py "query" --domains d1.com,d2.com --recency month

# Search API (raw ranked results — title, URL, snippet)
py ~/.claude/scripts/perplexity_search.py "query" --search-api --max-results 10

# Deep research (use sparingly — expensive)
py ~/.claude/scripts/perplexity_search.py "query" --model sonar-deep-research
```

The script:
- Loads `PERPLEXITY_API_KEY` from `~/.config/secrets.env` or environment (no manual export needed)
- Returns structured JSON to stdout
- Handles errors gracefully (returns `{"error": "..."}`)
- No dependencies beyond stdlib (`urllib`)

## Credential Setup

API key lives in `~/.config/secrets.env` (outside all git repos):
```bash
PERPLEXITY_API_KEY=pplx-xxxxxxxxxxxxxxxxxxxx
```

Get a key at [console.perplexity.ai](https://console.perplexity.ai). No free tier — sonar-pro costs ~$0.01-0.03 per query.

## Models

**Default: `sonar-pro`** for all queries. Claude handles reasoning — Perplexity is search only.

| Model | Use Case | Cost/query |
|-|-|-|
| `sonar-pro` | **Default.** All research queries | ~$0.01-0.03 |
| `sonar-deep-research` | "deep dive" / "thorough" prefix only | ~$0.03-0.05 |

`sonar-reasoning-pro` is not used — Claude is the reasoning layer.

## API Quick Reference

### Chat Completions (default)

`POST https://api.perplexity.ai/chat/completions`

| Parameter | Type | Description |
|-|-|-|
| `model` | string | `sonar-pro` (default) or `sonar-deep-research` |
| `messages` | array | OpenAI-format `[{role, content}]` |
| `search_domain_filter` | string[] | Restrict to specific domains (verified working) |
| `search_recency_filter` | string | `hour`, `day`, `week`, `month` |
| `temperature` | float | 0.0-1.0 (default 0.2) |
| `max_tokens` | int | Max output tokens (default 2048) |

Response includes `citations[]` array. Inline `[N]` markers in content map to citation indices.

### Search API (raw results)

`POST https://api.perplexity.ai/search`

| Parameter | Type | Description |
|-|-|-|
| `query` | string/array | Up to 5 queries for batch |
| `max_results` | int | 1-20 (default 10) |
| `search_domain_filter` | string[] | Max 20 domains, prefix `-` to deny |
| `search_recency_filter` | string | Same as above |
| `country` | string | ISO 3166-1 alpha-2 |

Returns `{results: [{title, url, snippet, date, last_updated}]}`. $5/1K requests flat.

## Output Rules

- Default report length: under 1500 characters
- If the user prefixed with "deep dive" or "thorough": up to 4000 characters, use `sonar-deep-research`
- Always include Sources section with clickable URLs
- Always include Project Alignment section (connects findings to codebase)
- Always include Recommendations section
- Always include Research Stats line at the end
