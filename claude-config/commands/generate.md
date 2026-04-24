---
description: Generate KiCad schematic, PCB, and support files from a circuit-weaver design YAML.
agent: general
subtask: true
---

# Generate Artifacts

Generate KiCad schematic, PCB layout, and support files from a circuit-weaver design YAML.

## Steps

1. Run `circuit-weaver generate <design.yaml> --output <out_dir>`.
2. Verify the output files were created (`.kicad_sch`, `.kicad_pcb`, etc.).
3. Run validation on the generated output to confirm it loads cleanly.

## Examples

```
circuit-weaver generate design.yaml --output out/
```
