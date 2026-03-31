---
name: skill_authoring
description: Guidance for editing Claude Code skills. Use when Claude touches skill folders or SKILL.md files so slash-command naming, frontmatter, helper scripts, and conditional paths stay coherent.
user-invocable: false
paths:
  - claude-config/skills/**
  - .claude/skills/**
  - skills/**
allowed-tools:
  - Read
  - Grep
metadata:
  version: "2.0"
  effort: low
  auto-invocable: true
  category: auto
  compatible-claude-code:
    paths: ["claude-config/skills/**", ".claude/skills/**", "skills/**"]
    user-invocable: false
  - Grep
  - Glob
  - Edit
  - Write
  - Bash
---

# Skill Authoring

When editing skills:

- The folder name is the actual slash command. Keep it stable and only rename intentionally.
- Keep frontmatter high-signal. Use `argument-hint`, `disable-model-invocation`, `context`, `agent`, `hooks`, and `paths` only when they materially change behavior.
- Put repetitive or fragile logic in `scripts/` instead of re-describing it in Markdown.
- If a skill depends on helper scripts or external tools, update the setup docs in the same change.
- Use path-scoped skills for authoring guidance or narrow domain rules, not for broad project policy that belongs in `CLAUDE.md`.
- Keep bodies concise and procedural. Avoid long "when to use" prose in the body; that belongs in the description.
