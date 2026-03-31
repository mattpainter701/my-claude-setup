---
name: openscad
description: "Generate parametric 3D models in OpenSCAD — enclosures, brackets, mounts, mechanical parts. Produce printable STL/3MF files for FDM printers (Bambu, Prusa, etc). Use this skill when the user asks to design a 3D printed part, enclosure, case, mount, bracket, jig, or fixture. Also trigger on: 'make me a box for...', 'print a case', '3D print', 'enclosure for my PCB', 'MOLLE mount', 'snap-fit', 'screw boss', 'parametric design', or any request involving physical objects that could be 3D printed. Covers OpenSCAD language, BOSL2 library, CLI rendering, slicer integration, and FDM print design rules."
metadata:
  version: "2.0"
  effort: high
  auto-invocable: false
  category: hardware
  compatible-claude-code:
    when_to_use: "When designing 3D printed parts, enclosures, or mechanical components"
    allowed-tools: ["Bash", "Read", "Write", "Edit", "Glob"]
---

# OpenSCAD — Parametric 3D Modeling & Print-Ready Export

Generate `.scad` files, render to STL/3MF, slice and print. OpenSCAD is script-based CSG — perfect for parametric enclosures, brackets, and mechanical parts where dimensions need to be tunable.

## When to Use

- **Enclosures** for PCBs, electronics, batteries, sensors
- **Mounts & brackets** — MOLLE, DIN rail, wall mount, tripod, clamp
- **Mechanical parts** — gears, pulleys, cams, hinges, latches
- **Jigs & fixtures** — alignment tools, test fixtures, assembly aids
- **Adapters** — connector adapters, cable strain relief, antenna mounts

## Quick Start

```scad
// Minimal parametric box
inner = [60, 40, 25];  // [w, d, h]
wall = 2;

difference() {
    cube([inner.x + 2*wall, inner.y + 2*wall, inner.z + wall]);
    translate([wall, wall, wall])
        cube([inner.x, inner.y, inner.z + 1]);
}
```

## Language Reference

### 3D Primitives
```scad
cube([w, d, h]);                    // box (origin at corner)
cube([w, d, h], center=true);       // centered on origin
sphere(r=10);                       // sphere
sphere(d=20);                       // diameter form
cylinder(h=20, r=5);               // cylinder
cylinder(h=20, r1=10, r2=5);      // cone/frustum
cylinder(h=20, d=10);             // diameter form
polyhedron(points=[], faces=[]);   // arbitrary mesh
```

### 2D Primitives (for extrusion)
```scad
square([w, h]);
square([w, h], center=true);
circle(r=10);
circle(d=20);
polygon(points=[[0,0],[10,0],[5,10]]);
text("VARTA", size=8, font="Liberation Sans:style=Bold", halign="center");
```

### Boolean Operations
```scad
union() { a(); b(); }          // combine shapes
difference() { a(); b(); }     // subtract b from a
intersection() { a(); b(); }   // keep only overlap
```

### Transformations
```scad
translate([x, y, z])           // move
rotate([rx, ry, rz])           // rotate (degrees)
rotate(a=45, v=[0,0,1])        // rotate around axis
scale([sx, sy, sz])            // scale
mirror([1, 0, 0])              // mirror across plane
color("red")                   // color (preview only)
color([r, g, b, a])            // RGBA 0-1
```

### Advanced Transforms
```scad
hull() { a(); b(); }           // convex hull (FAST — preferred for rounded boxes)
minkowski() { a(); b(); }      // Minkowski sum (SLOW — avoid for complex shapes)
offset(r=2)                    // 2D: round outward (negative = inward)
offset(delta=2, chamfer=true)  // 2D: chamfered offset
```

### Extrusion (2D → 3D)
```scad
linear_extrude(height=10)              // straight extrude
linear_extrude(height=10, twist=90)    // twisted extrude
linear_extrude(height=10, scale=0.5)   // tapered extrude
linear_extrude(height=10, center=true) // centered vertically
rotate_extrude(angle=360)              // lathe/revolve
```

### Control Flow
```scad
for (i = [0:4]) translate([i*10, 0, 0]) cube(5);     // range
for (p = [[0,0],[10,0],[5,10]]) translate(p) sphere(2); // list
if (wall > 2) { /* thick wall design */ }
let (d = sqrt(w*w + h*h)) echo(d);                    // local variable
```

### Modules & Functions
```scad
module rounded_box(size, r) {           // reusable shape
    hull() for (x=[r,size.x-r], y=[r,size.y-r])
        translate([x,y,0]) cylinder(r=r, h=size.z);
}

function hyp(a, b) = sqrt(a*a + b*b);  // pure function (returns value)
```

### Special Variables
```scad
$fn = 40;       // circle/sphere segments (global or per-shape)
$fa = 12;       // minimum angle per segment
$fs = 2;        // minimum segment length (mm)
$preview       // true in preview (F5), false in render (F6)
$children      // number of child shapes in a module
```

### Debug Modifiers
```scad
# cube(10);    // highlight (transparent red in preview)
% cube(10);    // transparent/background
* cube(10);    // disable (comment out)
! cube(10);    // show only this
```

### Import/Export
```scad
import("file.stl");           // import mesh
import("file.svg");           // import 2D SVG
import("file.dxf");           // import 2D DXF
surface("heightmap.png", center=true);  // heightmap → 3D
```

## Enclosure Design Patterns

### Rounded Box (hull method — fast)
```scad
module rbox(w, d, h, r) {
    hull() for (x=[r,w-r], y=[r,d-r])
        translate([x, y, 0]) cylinder(r=r, h=h);
}
```

### Rounded Box (offset+extrude — fastest for simple shapes)
```scad
module rbox2(w, d, h, r) {
    linear_extrude(h)
        offset(r=r) square([w - 2*r, d - 2*r], center=true);
}
```

### Shell (hollow box with open top)
```scad
module shell(outer, wall) {
    difference() {
        rbox(outer.x, outer.y, outer.z, 3);
        translate([wall, wall, wall])
            rbox(outer.x-2*wall, outer.y-2*wall, outer.z+1, max(1, 3-wall));
    }
}
```

### Screw Boss
```scad
module screw_boss(h, od=8, id=3.2) {
    difference() {
        cylinder(d=od, h=h);
        translate([0, 0, -0.1]) cylinder(d=id, h=h+0.2);
    }
}
```

### Snap-Fit Clip (cantilever)
```scad
module snap_clip(len=10, w=4, t=1.2, hook=0.8) {
    // Vertical beam
    cube([w, t, len]);
    // Hook at top
    translate([0, 0, len])
        cube([w, t + hook, t]);
}
```

### Port Cutout Helper
```scad
module port_cutout(size, wall, pos) {
    // size = [w, h], wall = wall thickness, pos = [x, y] on wall face
    translate([pos.x - size.x/2, -0.1, pos.y - size.y/2])
        cube([size.x, wall + 0.2, size.y]);
}
```

### MOLLE Slot Grid
```scad
module molle_slots(cols=2, rows=3, wall=2.5) {
    // Standard PALS: 25.4mm horizontal, 38.1mm vertical
    slot_w = 4; slot_h = 32;
    h_space = 25.4; v_space = 38.1;
    for (c=[0:cols-1], r=[0:rows-1])
        translate([c*h_space - slot_w/2, r*v_space - slot_h/2, -0.1])
            cube([slot_w, slot_h, wall+0.2]);
}
```

### Text Emboss / Deboss
```scad
// Debossed (into surface)
difference() {
    cube([50, 20, 3]);
    translate([25, 10, 2.5])
        linear_extrude(1)
            text("VARTA", size=8, halign="center", valign="center");
}

// Embossed (raised from surface)
cube([50, 20, 3]);
translate([25, 10, 3])
    linear_extrude(0.6)
        text("VARTA", size=8, halign="center", valign="center");
```

### Lid with Inset Lip
```scad
module lid(outer_w, outer_d, wall, lip_depth=6, tol=0.3) {
    union() {
        // Flat top
        rbox(outer_w, outer_d, wall, 3);
        // Inset lip
        translate([wall+tol, wall+tol, -lip_depth])
            rbox(outer_w-2*wall-2*tol, outer_d-2*wall-2*tol, lip_depth, 1);
    }
}
```

### PCB Standoff
```scad
module standoff(h=5, od=5, id=2.5, base_h=1) {
    cylinder(d=od, h=base_h);           // base flange
    cylinder(d=od*0.7, h=h);            // post
    translate([0,0,h-3])
        difference() {
            cylinder(d=od*0.7, h=3);
            translate([0,0,-0.1]) cylinder(d=id, h=3.2);  // screw hole
        }
}
```

## FDM Print Design Rules

### Tolerances
| Feature | Tolerance |
|-|-|
| Press-fit hole | +0.1mm over shaft diameter |
| Sliding fit (lid, cover) | +0.3mm per side |
| Screw clearance (M3) | 3.2mm hole |
| Screw tap (M3, into plastic) | 2.5mm hole |
| Snap-fit clearance | +0.2mm |

### Printability (FDM, no supports)
| Rule | Value |
|-|-|
| Min wall thickness | 1.2mm (3 perimeters @ 0.4mm nozzle) |
| Min feature size | 0.8mm |
| Max overhang angle | 45° from vertical (no supports) |
| Max bridge span | 15mm (PLA), 10mm (PETG) |
| Min hole diameter (horizontal) | 3mm (teardrop shape preferred) |
| Layer height | 0.2mm standard, 0.12mm detail |
| First layer squish | 0.04mm helps adhesion |

### Avoiding Support Structures
- Orient overhangs within 45° of vertical
- Use chamfers instead of fillets on bottom edges
- Teardrop holes for horizontal holes (flat at top)
- Bridge short spans (<15mm) rather than support them
- Split model into printable orientations

### Material Selection
| Material | Use Case | Bed Temp | Nozzle |
|-|-|-|-|
| PLA | Prototypes, indoor use | 60°C | 210°C |
| PETG | Functional parts, outdoor | 80°C | 235°C |
| ASA | UV-resistant outdoor | 100°C | 250°C |
| TPU | Flexible, shock absorbing | 50°C | 230°C |

## Common Component Dimensions

### Electronics
| Component | Size (mm) |
|-|-|
| Raspberry Pi 5 | 85 x 56.5 x 20 |
| Raspberry Pi Zero 2W | 65 x 30 x 5 |
| Arduino Uno | 68.6 x 53.4 x 15 |
| ESP32 DevKit | 51 x 28 x 7 |
| SSD1306 OLED 0.96" | PCB 27.5 x 27.8, active 23.7 x 12.9 |
| SSD1306 OLED 1.3" | PCB 35 x 33, active 30 x 17 |
| 18650 cell | 65 x 18.5 (diameter) |
| USB-C port | 8.94 x 3.26 (cutout: 10 x 4) |
| Micro-USB port | 7.5 x 2.5 (cutout: 9 x 4) |
| SMA bulkhead | 6.35mm hole, 9.5mm nut |
| RP-SMA bulkhead | 6.35mm hole |
| M3 screw clearance | 3.2mm hole |
| M3 heat-set insert | 4.0mm hole, 5.5mm depth |

### Mounting Standards
| Standard | Dimensions |
|-|-|
| MOLLE/PALS | 25.4mm H-spacing, 38.1mm V-spacing, 4mm slot width |
| DIN rail (35mm) | 35mm width, 7.5mm depth, 1mm thick |
| VESA 75 | 75 x 75mm bolt pattern, M4 |
| VESA 100 | 100 x 100mm bolt pattern, M4 |
| 1/4"-20 (tripod) | 6.35mm hole |
| GoPro mount | 2-prong: 15mm wide, 3mm slot, 8mm spacing |
| Picatinny rail | 22mm wide, 4.8mm slot, 9.5mm spacing |

## CLI Rendering & Export

```bash
# Render to binary STL (smallest file)
openscad -o output.stl --export-format binstl input.scad

# Render to 3MF (preserves units, modern format)
openscad -o output.3mf input.scad

# Override parameters from CLI (parametric batch)
openscad -o small.stl -D 'inner_w=50' -D 'inner_h=30' input.scad
openscad -o large.stl -D 'inner_w=100' -D 'inner_h=60' input.scad

# Render preview image (for documentation)
openscad -o preview.png --render --imgsize=1920,1080 --viewall --autocenter input.scad

# Batch: render multiple variants
for size in 50 75 100; do
    openscad -o "box_${size}.stl" -D "inner_w=${size}" input.scad
done
```

**Performance tip:** Add `--enable manifold` on OpenSCAD nightly builds for 5-30x faster rendering.

## BOSL2 Library

[BOSL2](https://github.com/BelfrySCAD/BOSL2) adds high-level modules for enclosure design. Install to `Documents/OpenSCAD/libraries/BOSL2/`.

```scad
include <BOSL2/std.scad>

// Rounded cuboid with edge rounding
cuboid([60, 40, 25], rounding=3, edges="Z");

// Threaded screw hole
threaded_rod(d=3, l=10, pitch=0.5, internal=true);

// Snap-fit joint
snap_pin(size=3, thick=1.5);
snap_socket(size=3, thick=1.5);

// Hinged box
cuboid([60,40,25], anchor=BOTTOM) {
    attach(TOP) hinge_half(l=40, inner=true);
}
```

**Don't assume BOSL2 is installed.** Generate standalone `.scad` files using built-in OpenSCAD modules unless the user confirms BOSL2 is available. BOSL2 adds convenience but isn't required for any design task.

## NopSCADlib

[NopSCADlib](https://github.com/nophead/NopSCADlib) provides dimensional "vitamins" (real-world parts) for visualization and fit-checking. Includes screws, nuts, PCBs, displays, stepper motors, fans, bearings, connectors, and more. Auto-generates BOMs and assembly instructions.

Useful for visualizing hardware inside enclosures but not required. Mock components with simple cubes if NopSCADlib isn't installed.

## Slicer Integration

### Bambu Studio
1. Export `.stl` (binary) or `.3mf` from OpenSCAD
2. Drag into Bambu Studio
3. If multiple parts on one plate: **Right-click → Split to Objects**
4. Parts must have a gap between them (≥1mm) for auto-split to work
5. Orient parts flat (open side up for shells, flat for panels)

### PrusaSlicer / OrcaSlicer
Same workflow. All accept STL and 3MF from OpenSCAD.

### Multi-Part Designs
**Always export parts with physical separation** (translate one part away from the other). This allows slicer auto-split. Alternatively, export each part as a separate STL from OpenSCAD by commenting out other parts.

## Common Pitfalls

### Z-Fighting (Coincident Faces)
Boolean `difference()` fails silently when the cutting shape is flush with the surface. Always extend cuts by 0.1mm beyond each surface:
```scad
// BAD — cutting face flush with outer surface
difference() {
    cube([10, 10, 5]);
    translate([2, 2, 0]) cube([6, 6, 5]);  // flush at z=0 and z=5
}

// GOOD — extend cut 0.1mm past each surface
difference() {
    cube([10, 10, 5]);
    translate([2, 2, -0.1]) cube([6, 6, 5.2]);
}
```

### Performance
- Prefer `hull()` over `minkowski()` (10-100x faster)
- Use `$fn=6` in preview, `$fn=40-60` for export (or use `$fn = $preview ? 12 : 48;`)
- Avoid deep nesting of `minkowski()` operations
- Use `linear_extrude(offset())` instead of `minkowski(cube, cylinder)` for rounded boxes

### Disconnected Geometry (Slicer Split-Body)
Internal features (shelves, ledges, standoffs) that aren't physically connected to the main shell body will be detected as **separate objects** by slicers. Bambu Studio's "Split to Objects" will split them out, causing unexpected 3-part prints.

**Prevention:** Always `union()` internal features with the shell, or ensure they physically intersect the wall geometry (overlap by ≥0.1mm). If the feature is optional (e.g., a PCB shelf when the user will hot-glue instead), omit it entirely rather than leaving a floating body.

**Detection:** After export, import into slicer and check object count. If "Split to Objects" produces more parts than expected, you have disconnected geometry.

### Non-Manifold Geometry
- No zero-thickness walls (use ≥0.1mm minimum)
- No self-intersecting shapes
- Ensure boolean operands overlap (no touching-only surfaces)
- OpenSCAD nightly's Manifold engine is stricter but produces cleaner meshes

### File Size
- Use `--export-format binstl` for binary STL (5-10x smaller than ASCII)
- Reduce `$fn` on non-critical curves
- 3MF is compressed — smaller than ASCII STL for complex models

## Design Workflow

1. **Measure components** — calipers or datasheets. Include tolerances.
2. **Define parameters** at top of file — all dimensions tunable.
3. **Build bottom-up** — shell first, then add posts/bosses, then cut holes.
4. **Preview often** (F5) — fast check during development.
5. **Render (F6) and export STL** when ready to print.
6. **Slice** — import STL into Bambu Studio / PrusaSlicer.
7. **Test fit** — print a thin slice first (`linear_extrude(2)` of the cross-section) to verify dimensions before full print.

## Tips

- **Parametric everything** — put dimensions in variables at the top, never hardcode in geometry.
- **Name your modules** — `module front_shell()`, `module back_panel()`, not inline geometry.
- **Separate parts for printing** — offset parts on the build plate with `translate()`.
- **Test fit cuts** — print just the lid or just the port area as a thin slab to verify fit.
- **Comment cutouts** — label what each `difference()` operation removes.
- **Version control** — `.scad` files are text, git-friendly. Commit them.
- **Chamfer bottom edges** — 0.5mm chamfer on print bed contact edges prevents elephant foot.
- **Heat-set inserts** — stronger than screwing into plastic. 4.0mm hole for M3 insert.

## Changelog
- 2026-03-12: Created skill — language ref, enclosure patterns, FDM rules, CLI, BOSL2, slicer integration
- 2026-03-12: Added disconnected geometry pitfall (OLED shelf split-body in Bambu Studio)
- 2026-03-12: Antenna pass-through holes need 12mm for rubber duck WiFi antennas (not 6.5mm SMA)
- 2026-03-12: MOLLE slots verified: 4mm wide x 32mm tall, 25.4mm H / 38.1mm V spacing
- 2026-03-12: SSD1306 0.96" OLED exact dims: PCB 27.5x27.8mm, active 23.74x12.86mm, 4-pin 2.54mm
