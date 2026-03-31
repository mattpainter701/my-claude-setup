---
name: verifier_hooks
description: Arm a one-shot hook-driven verifier for the next risky edit. Use when Claude should automatically run a lightweight post-edit agent check after the next Edit or Write and stop the turn if the change likely introduced a concrete regression.
allowed-tools:
  - Bash
  - Read
  - Grep
  - Glob
disable-model-invocation: true
hooks:
  PostToolUse:
    - matcher: Edit|Write
      hooks:
        - type: agent
          prompt: |
            You are a lightweight post-edit verifier. The hook input JSON is:
            $ARGUMENTS

            Inspect the touched file and nearby code using read-only tools only.
            Return ok=true unless there is a concrete reason to stop the workflow immediately.

            Fail with a short reason only when one of these is true:
            1. the edit likely broke syntax, imports, or obvious runtime behavior
            2. the edit changed auth, security, migrations, deployment, or persistence logic without a targeted verification path
            3. the edit removed or contradicted an existing nearby invariant or targeted test
            4. the edit changed hooks, skills, agents, or frontmatter in a way that is internally inconsistent

            Ignore style-only issues and speculative concerns. Prefer passing if unsure.
          timeout: 45
          statusMessage: Running edit verifier
          once: true
---

# Verifier Hooks Skill

Usage: `/verifier_hooks`

This skill arms a one-shot `PostToolUse` agent hook for the next `Edit` or `Write` in the current session.

## After Arming

1. Tell the user the next risky edit is now protected by a lightweight verifier.
2. Recommend it for auth changes, deploy logic, migrations, broad refactors, or hook/skill/agent edits.
3. If the user wants the verifier on every risky edit, move the same pattern into `.claude/settings.local.json` instead of repeatedly invoking this skill.

## Rules

- Do not try to remove hooks manually; this one self-removes because `once: true`.
- Do not run extra verification immediately inside this skill invocation; the hook is the verification mechanism.
