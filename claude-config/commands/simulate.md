---
description: Run SPICE simulation on a circuit-weaver design. Supports transient, AC, and RF chain analysis.
agent: general
subtask: true
---

# Simulate Design

Run SPICE simulation on a circuit-weaver design.

## Steps

1. Run `circuit-weaver simulate <design.yaml> -o ./sims` to generate simulation artifacts.
2. Review simulation output for stability, ripple, and transient response.
3. Optionally run `circuit-weaver confidence <design.yaml> --run-sims -o report.html` for a full confidence report.

## Examples

```
circuit-weaver simulate design.yaml -o ./sims
circuit-weaver confidence design.yaml --run-sims -o report.html
```
