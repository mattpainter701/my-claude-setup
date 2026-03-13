# Glob: **/*.kicad_sch, **/*.kicad_pcb, **/*.kicad_sym, **/*.kicad_mod

## KiCad File Rules
- Never hand-edit KiCad files without understanding S-expression structure. Use analysis scripts first.
- `lib_id` in schematic instances: BARE names (no `library:` prefix).
- Power symbols: bare `lib_id` (e.g. `"VCC"` not `"power:VCC"`), `(power)` flag required.
- 1.27mm connection grid: all pin endpoints, labels, wires must snap to 1.27mm grid.
- Wire stubs REQUIRED between pins and labels for reliable connectivity.
- Symbol sub-units `_0_1`/`_1_1` required (SnapEDA flat format fails silently).
- Version 20231120 (KiCad 8+) for per-symbol `instances` blocks.
- After programmatic edits, always verify with "Update PCB from Schematic" in KiCad GUI.
