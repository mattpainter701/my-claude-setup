---
description: Validate a circuit-weaver design YAML against the canonical IR schema. Runs structural, electrical, implementation, and presentation checks.
agent: general
subtask: true
---

# Validate Design

Validate a circuit-weaver design YAML file against the canonical design IR schema.

## Steps

1. Run `circuit-weaver validate <design.yaml>` — check structural, electrical, implementation, and presentation layers.
2. If `--enhanced` is supported, run with `--enhanced --verbose` for deep analysis.
3. Report all findings ordered by severity. Distinguish source defects from stale-artifact defects.
4. Do not accept unresolved symbols, footprints, or interfaces.

## Examples

```
circuit-weaver validate design.yaml
circuit-weaver validate design.yaml --enhanced --verbose
```
