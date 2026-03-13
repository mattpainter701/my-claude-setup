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

## Output Rules
- Default report length: under 1500 characters
- If the user prefixed with "deep dive" or "thorough": up to 4000 characters
- Always include Sources section with clickable URLs
- Always include Recommendations section
