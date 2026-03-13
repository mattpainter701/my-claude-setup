# Claude Hardware Design Skills

A collection of **Claude Code skills** for end-to-end hardware design — from component sourcing through schematic analysis, PCB layout review, fabrication ordering, and 3D-printed enclosure design.

These skills turn Claude into a hardware design assistant that can analyze KiCad projects, search distributor APIs, manage BOMs, download datasheets, review designs for bugs, generate 3D-printable enclosures, and prepare manufacturing files.

## What Are Skills?

Claude Code [skills](https://docs.anthropic.com/en/docs/claude-code/skills) are structured instruction files (`SKILL.md`) that teach Claude how to perform specialized tasks. Some skills also include **Python scripts** that do the heavy lifting (schematic parsing, API calls, datasheet downloads) — Claude invokes these scripts and interprets the results.

Skills are not plugins or extensions. They're markdown files that Claude reads on demand to learn domain-specific workflows. The scripts are standalone Python that Claude runs via its Bash tool.

## Skills Included

| Skill | Purpose | Scripts |
|-|-|-|
| **kicad** | Analyze schematics, PCBs, Gerbers, and PDF reference designs. Cross-reference schematic-to-PCB. Design review with datasheet verification. | 4 analyzers + S-expr parser |
| **bom** | BOM lifecycle — extract from schematic, enrich with distributor data, validate, export tracking CSV, generate per-distributor order files. | 4 scripts (manager, property editor, URL sync, S-expr lib) |
| **digikey** | Search DigiKey API (Product Info v4), download datasheets, sync datasheet directory. Primary prototype sourcing. | 2 scripts (fetch + sync) |
| **mouser** | Search Mouser API, download datasheets. Secondary prototype sourcing. | 2 scripts (fetch + sync) |
| **lcsc** | Search LCSC/jlcsearch API. Production sourcing (JLCPCB parts library). No API key needed. | 2 scripts (fetch + sync) |
| **element14** | Search Newark/Farnell/element14 API. International sourcing. | 2 scripts (fetch + sync) |
| **jlcpcb** | PCB fabrication and assembly ordering — design rules, BOM format, assembly constraints. | Instruction-only |
| **pcbway** | Alternative PCB fab — turnkey assembly, MPN-based sourcing. | Instruction-only |
| **openscad** | Parametric 3D modeling — enclosures, mounts, brackets. FDM print rules, slicer integration. | Instruction-only |

## Installation

### 1. Copy skills to your Claude Code config

```bash
# Clone the repo
git clone https://github.com/YOUR_USERNAME/claude-hardware-skills.git

# Copy all skills into your Claude Code skills directory
cp -r claude-hardware-skills/skills/* ~/.claude/skills/
```

Or symlink individual skills:

```bash
ln -s /path/to/claude-hardware-skills/skills/kicad ~/.claude/skills/kicad
ln -s /path/to/claude-hardware-skills/skills/bom ~/.claude/skills/bom
# ... etc
```

### 2. Register skills in your project or global settings

Add skill triggers to `.claude/settings.json` (project) or `~/.claude/settings.json` (global). See the Claude Code docs for [skill configuration](https://docs.anthropic.com/en/docs/claude-code/skills).

### 3. Dependencies

**Python scripts require:**
- Python 3.10+
- `requests` (strongly recommended — urllib fallback exists but is limited)
- `playwright` (optional — enables headless browser fallback for stubborn datasheet sites)

**API credentials (optional but recommended):**
- **DigiKey:** OAuth 2.0 client credentials — see `skills/digikey/SKILL.md` for setup
- **Mouser:** Search API key — see `skills/mouser/SKILL.md` for setup
- **element14:** API key — see `skills/element14/SKILL.md` for setup
- **LCSC:** No credentials needed (uses free jlcsearch community API)

## Typical Workflows

### Design Review

```
"Review my KiCad project at hardware/myboard/"
```

Claude runs the schematic and PCB analyzers, syncs datasheets, cross-references pin-to-net mappings against datasheets, and produces a prioritized issue report.

### BOM Management

```
"Search DigiKey for all parts in my schematic, update the BOM"
```

Claude extracts components from the schematic, searches distributor APIs by MPN, validates matches (package, specs, lifecycle), writes distributor part numbers back into the schematic properties, and exports a tracking CSV.

### Datasheet Sync

```
"Download datasheets for all components in my board"
```

Claude runs the sync script against your schematic, downloading PDFs from distributor APIs into a local `datasheets/` directory with an `index.json` manifest.

### Enclosure Design

```
"Design a snap-fit enclosure for my 60x40mm PCB with USB-C and 2 SMA ports"
```

Claude generates a parametric OpenSCAD file with proper tolerances, screw bosses, port cutouts, and FDM-friendly geometry. Renders to STL for slicing.

### Fabrication Prep

```
"Generate JLCPCB BOM and CPL files for my board"
```

Claude exports gerbers, BOM with LCSC part numbers, and component placement files in JLCPCB's expected format.

## Reference Documentation

The `kicad` and `bom` skills include extensive reference docs:

| Reference | Topic |
|-|-|
| `kicad/references/schematic-analysis.md` | Deep schematic review methodology |
| `kicad/references/pcb-layout-analysis.md` | Advanced PCB analysis techniques |
| `kicad/references/standards-compliance.md` | IPC/IEC standards tables |
| `kicad/references/report-generation.md` | Design review report template |
| `kicad/references/file-formats.md` | KiCad file format documentation |
| `kicad/references/gerber-parsing.md` | Gerber/Excellon format details |
| `bom/references/kicad-fields.md` | KiCad symbol field definitions |
| `bom/references/ordering-and-fabrication.md` | Distributor order formats |
| `bom/references/part-number-conventions.md` | MPN naming patterns |

## How It Works

The skills follow a **read-analyze-verify** pattern:

1. **Parse** — Python scripts extract structured JSON from KiCad files (S-expression parsing, not regex)
2. **Enrich** — Distributor APIs add pricing, stock, datasheets, parametric data
3. **Verify** — Claude cross-references analyzer output against raw files and datasheets
4. **Report** — Prioritized findings with severity levels and actionable fixes

The analyzer scripts are the foundation — they produce ~60-300KB of structured JSON per file, covering components, nets, signal analysis, power trees, DFM scoring, and more. Claude reads this JSON and reasons about it using the methodology documented in the reference files.

## Contributing

These skills are living documents. If you find a bug, discover a new gotcha, or improve a workflow:

1. Update the relevant `SKILL.md` with the fix
2. Add a changelog entry at the bottom of the skill file
3. If you add a new script, document it in the skill's script section

## License

MIT
