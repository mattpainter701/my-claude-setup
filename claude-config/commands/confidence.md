---
description: Generate a confidence report for a circuit-weaver design, including simulation results and scoring.
agent: general
subtask: true
---

# Confidence Report

Generate a confidence report for a circuit-weaver design, including simulation results and scoring.

## Steps

1. Run `circuit-weaver confidence <design.yaml> --run-sims -o report.html` to generate the report.
2. Review the report for scoring breakdown and simulation results.
3. Summarize the confidence score and any flagged risks.

## Examples

```
circuit-weaver confidence design.yaml --run-sims -o report.html
```
