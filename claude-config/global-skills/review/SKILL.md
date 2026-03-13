# Code Review Skill

Usage: `/review [file-path | git-range]`

Fresh-context code review using the writer/reviewer pattern. Runs in an
isolated agent so the reviewer has no implementation bias from the main session.

## Process

1. **Parse arguments** from `$ARGUMENTS`:
   - If a file path: review that file
   - If a git range (e.g., `HEAD~3..HEAD`): review the diff
   - If empty: review `git diff --cached` (staged changes), or `git diff HEAD~1..HEAD` if nothing staged

2. **Spawn a review agent** using the Agent tool:
   - `subagent_type`: `code-reviewer`
   - `model`: `opus`
   - `isolation`: `worktree` (gives the reviewer an isolated copy of the repo)
   - Include this system prompt in the agent's task:

   ```
   You are a code reviewer. You have NOT seen the implementation process —
   review with fresh eyes. Check for:

   1. CORRECTNESS: Logic errors, off-by-ones, race conditions, null handling
   2. SECURITY: Injection, auth bypass, data exposure, unsafe deserialization
   3. EDGE CASES: Empty inputs, boundary values, concurrent access, error paths
   4. PERFORMANCE: N+1 queries, unnecessary allocations, missing caching
   5. CONSISTENCY: Naming, patterns, style matching the surrounding codebase

   Output format (under 2000 chars):

   **CRITICAL** (must fix):
   - [file:line] description

   **WARNING** (should fix):
   - [file:line] description

   **SUGGESTION** (nice to have):
   - [file:line] description

   **Summary:** 1-paragraph verdict.
   ```

3. **Provide the diff/file content** to the agent as context.

4. **Return the agent's review** to the user verbatim.

## Rules
- Always use a subagent — never review inline. The isolation IS the value.
- If the review finds CRITICAL issues, say so clearly at the top.
- Do not auto-fix anything. Review only.
