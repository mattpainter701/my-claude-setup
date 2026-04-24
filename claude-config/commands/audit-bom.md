---
description: Audit a KiCad design's BOM for ordering readiness. Spawns the bom-auditor subagent to check MPN coverage, sourcing risk, and cost.
agent: bom-auditor
subtask: true
---

# Audit BOM

Audit the Bill of Materials for ordering readiness.

## Steps

1. Export the BOM from the KiCad project.
2. Pass results to the bom-auditor subagent for structured audit.
3. Report: missing MPNs, footprint-package mismatches, DNP inconsistencies, supplier coverage, cost optimization opportunities.
4. Summarize ordering readiness at the end.

## Examples

```
/kick bom-auditor "Audit the BOM for this KiCad project"
```
