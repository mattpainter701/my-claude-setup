---
description: Discover circuit-weaver projects in the current workspace. Returns a JSON list of detected designs.
agent: general
subtask: true
---

# Discover Projects

Discover circuit-weaver projects in the current workspace.

## Steps

1. Run `circuit-weaver discover --json` to list all detectable design projects.
2. Present the results with project paths and types.
3. Optionally open a specific project for validation or generation.

## Examples

```
circuit-weaver discover --json
```
