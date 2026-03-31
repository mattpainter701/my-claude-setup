---
description: Fresh-context code review using isolated reviewer agent
agent: code-reviewer
subtask: true
---

Perform a fresh-context code review.

## Process

1. Parse arguments for file path or git range
2. If no arguments: review `git diff --cached`, or `git diff HEAD~1..HEAD` if nothing staged
3. Spawn a code-reviewer subagent with the diff/file content
4. Return the review findings

The reviewer has NOT seen the implementation process — review with completely fresh eyes.

## Output Format

**CRITICAL** (must fix before merge):
- [file:line] description

**WARNING** (should fix):
- [file:line] description

**SUGGESTION** (nice to have):
- [file:line] description

**Summary:** 1-paragraph verdict — is this safe to merge?
