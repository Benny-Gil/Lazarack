# Modular Laptop Motherboard Server Case — Design Spec

A 3D-printed 2U enclosure that mounts a **Dell Inspiron 15-5558/5559**
motherboard into a **NiH "DIY 10-inch" cage-nut server rack**
(Printables #1634385). All structural parts print on a **Creality Ender 3
V3 SE** (bed 220 x 220 x 250 mm) in **PETG**, flat, with no supports.

The full parametric model lives in `parts/*.scad` (one module per printed
part), shares one frozen contract in `parts/params.scad`, and is joined by
the reusable joinery library in `lib/joinery.scad`. `main.scad` unions all
parts with no transforms.

---

## Board Analysis

| Parameter | Value |
|---|---|
| Board | Dell Inspiron 15-5558 / 5559 motherboard |
| Footprint | ~235 mm (depth) x 170 mm (width) x ~2 mm |
| Fan | Blower (right side, ~70 mm), heatpipe-fed |
| Front I/O (Edge-alpha) | HDMI + USB-A x2 + blower **exhaust** |
| Rear I/O (Edge-beta) | USB-C power-in (barrel jack replaced) + SD reader + 3.5 mm audio |
| Storage | NGFF (M.2) onboard + SATA ribbon to a 2.5" SSD |
| Mounting | 4 corner holes + 1 center; **M.2 standoff is missing** (added by a printed retainer) |

> Every uncertain real-world dimension is a `// MEASURE` placeholder in
> `params.scad` with a sane default, so the model renders today. Caliper the
> board and edit **only `params.scad`**.

---

## Target Form Factor — 2U, 10" rack

| Dimension | Value |
|---|---|
| Rack standard | NiH DIY 10" cage-nut rack (Printables #1634385) |
| Height | **2U = 88.9 mm** (gives blower + cabling headroom) |
| Structural body width | 190 mm (X: 0..190) |
| Faceplate width | 254 mm (full rack width, X -32..222) |
| Interior depth | 239 mm (front tile + rear tile, 25 mm rabbet-lap) |
| Rack fasteners | M5 cage-nut **clearance** holes (EIA-310 within-U pattern) |

### Shared assembly coordinate frame
Origin `(0,0,0)` = **front-bottom-left interior corner** of the chassis.
`+X` width (left->right), `+Y` depth (front->rear, Y=0 is the rack-front
interior face), `+Z` height (bottom->top). Every part is modeled directly
in this frame; `main.scad` does no transforms. Board is centered in X
(X 10..180), resting on M2.5 standoffs at Z = `FLOOR + STANDOFF_H` = 8 mm.

---

## The 9 Printed Parts

| # | File / module | Assembly bbox (mm) | Role |
|---|---|---|---|
| 1 | `baseplate_front.scad` -> `baseplate_front()` | 190 x 122 x 86 | Floor + L/R wall upstands + front faceplate lip + 2 front M2.5 standoffs + front half of the M3 grid; rear edge = **rabbet-lap MALE** |
| 2 | `baseplate_rear.scad` -> `baseplate_rear()` | 190 x 142 x 86 | Floor + upstands + rear-panel lip + 3 center/rear M2.5 standoffs + M.2 post pad + rear half of grid; front edge = **rabbet-lap FEMALE** |
| 3 | `faceplate_left.scad` -> `faceplate_left()` | 127 x 95 x 4 | Left half of the 254 faceplate; whole **left M5 rack column** (X -23.2625); left io-window; center seam = **dovetail MALE** + M3 pin-bolt + 2 dowels |
| 4 | `faceplate_right.scad` -> `faceplate_right()` | 127 x 95 x 4 | Right half; whole **right M5 column** (X 213.2625); center seam = **dovetail FEMALE** |
| 5 | `io_subplate.scad` -> `io_subplate()` | 120 x 70 x 3 | Swappable front insert (4x M3). `IO_VARIANT`: `"default"` (HDMI + USB-A x2 + louvered exhaust) or `"rj45"` (adds front RJ45) |
| 6 | `m2_retainer.scad` -> `m2_retainer()` | 16 x 16 x 10 | Gusseted M2.5 post supplying the **missing M.2 standoff**; foot 2x M3 onto grid, top M2.5 insert |
| 7 | `rear_panel.scad` -> `rear_panel()` | 190 x 95 x 4 | USB-C power-in + SD + 3.5 mm audio cutouts; tongue-and-groove into rear lip; side edges slot into wall-top grooves |
| 8 | `ssd_cage.scad` -> `ssd_cage()` *(optional)* | 105 x 75 x 16 | 2.5" SATA tray (JEITA 100 x 70 x 7), 4x M3 feet onto grid beside the board |
| 9 | `lid.scad` -> `lid_front()`, `lid_rear()` *(optional)* | 190 x 118 x 3 and 190 x 142 x 3 | Vented 2U top in two tiles; thumb-screw to wall-top inserts; lap each other at the depth seam |

All 9 fit within the 190 mm print limit in both bed-plane axes and print
largest-face-down with no supports.

---

## Joinery & the Common M3 Grid Interface

The single interoperability standard is **one 15 mm-pitch M3 self-tap pilot
grid** on the baseplate top, continuous across the depth lap. The grid points
are blind pilot holes (Ø2.5 mm) you screw an M3 directly into (PETG self-taps)
— **no heat-set inserts in the grid**, and the floor stays flat. The M.2
retainer, SSD cage, io_subplate (into the faceplate), panels, and lid all bolt
to this grid; you only tap the few points each module actually uses. Heat-set
inserts are reserved for the structural **seams** (depth lap, faceplate,
panels, lid, M2.5 standoffs).

Reusable joints live in `lib/joinery.scad` (parametric — they take explicit
args, they do not read `params.scad`):

| Joint | Where used |
|---|---|
| `rabbet_lap_male` / `rabbet_lap_female` | Front<->rear baseplate depth seam (25 mm lap, step = FLOOR/2) and the lid tile lap |
| `dovetail_male` / `dovetail_female` | Faceplate centerline seam at X=95 (+ transverse M3 pin-bolt + 2 dowels) |
| `dowel_hole` | Alignment pins across every seam |
| `tongue` / `groove` | Panel-bottom flanges into baseplate lips; rear panel side edges into wall-top grooves |
| `heatset_boss` | Structural seam/module joints (bores open **upward**, no bridging) |
| M3 pilot grid (blind `dowel_hole` bores) | The 15 mm self-tap grid on the baseplate floor — screw straight in, no inserts |
| `m25_standoff` | Board standoffs + M.2 post top (base fillet for side-load) |
| `eia_face_holes` | M5 rack clearance holes through the faceplate (EIA within-U Z pattern) |
| `louver_grille` | Louvered exhaust negative in the io_subplate |

**Printability rules enforced in geometry:** every part lies flat,
largest-face-down, zero supports; no overhang > 45 deg without a
chamfer/teardrop; all heat-set bores open upward; base fillets/gussets on
side-loaded posts.

---

## Resolved I/O Mapping

```
            FRONT faceplate (Edge-alpha)          REAR panel (Edge-beta)
        ┌──────────────────────────────┐      ┌──────────────────────────────┐
        │  io_subplate window:          │      │  USB-C power-in               │
        │   HDMI                        │      │  SD card reader               │
        │   USB-A x2                    │      │  3.5 mm audio                 │
        │   louvered EXHAUST grille     │      │                               │
        │   (future: + RJ45 swap)       │      │                               │
        └──────────────────────────────┘      └──────────────────────────────┘
```

- **Front** carries the blower exhaust plus the user-facing data ports via
  the swappable `io_subplate`. Switch `IO_VARIANT="rj45"` to add a front
  RJ45 cutout for a planned NGFF->1GbE NIC.
- **Rear** carries power-in and the low-traffic ports.

### Airflow
Blower intake is internal; the case provides a **louvered exhaust** on the
front io_subplate aligned to the fan outlet (`EXHAUST_POS` / `EXHAUST_SIZE`,
both `// MEASURE`). No active case cooling — the laptop fan handles it.

### Power
The barrel jack was replaced with **USB-C power-in** on the rear panel
(`USBC_POS` / `USBC_SIZE`, `// MEASURE`).

---

## Ender 3 V3 SE Print Plate

PETG, **0.2 mm** layer, **3-4 walls**, **30-40% infill**, **no supports**,
**brim** recommended for the tall thin faceplate/rear tiles. Every part
prints flat (largest face down).

| Part | Orientation on bed | Notes |
|---|---|---|
| `baseplate_front` / `baseplate_rear` | floor-down | Grid bores + standoff bores face up; print one per plate (190 mm wide) |
| `faceplate_left` / `faceplate_right` | outer face down (lay the 4 mm Y-thickness onto the bed, plate flat) | Brim; M5/dovetail features need no support when laid flat |
| `io_subplate` | back face down | Louvers cut through 3 mm — no overhang |
| `rear_panel` | outer face down | Brim; tongue along bottom edge |
| `m2_retainer` | foot down | Gussets print in-plane; M2.5 bore opens up |
| `ssd_cage` *(opt)* | tray floor down | |
| `lid_front` / `lid_rear` *(opt)* | flat | Vent slots + lap step |

Suggested grouping: each baseplate tile gets its own print; the two
faceplate tiles + io_subplate share a plate; rear_panel + m2_retainer +
ssd_cage share a plate; the two lid tiles share a plate.

---

## Bill of Materials

### Printed parts (PETG)
| Part | Qty |
|---|---|
| baseplate_front, baseplate_rear | 1 each |
| faceplate_left, faceplate_right | 1 each |
| io_subplate | 1 (+ spare variant optional) |
| m2_retainer | 1 |
| rear_panel | 1 |
| ssd_cage *(optional)* | 1 |
| lid_front, lid_rear *(optional)* | 1 each |

### Fasteners & hardware
| Item | Qty (approx) | Use |
|---|---|---|
| M3 brass heat-set inserts (bore ~4.0 mm x 5 mm) | ~18-24 | Structural seams only (lap, faceplate, panels, lid) — **grid uses no inserts** |
| M3 screws (8-10 mm) | ~24-30 | Mates into the M3 inserts (panels, lid, cage, retainer, seams) |
| M2.5 brass heat-set inserts (bore ~3.4 mm x 4 mm) | 6 | Board standoffs (5) + M.2 post (1) |
| M2.5 screws | ~6 | Board hold-down + M.2 retainer |
| M5 rack cage nuts + screws | 8 | 4 per rack column (clearance holes, not inserts) |
| Alignment dowel pins (~4 mm, e.g. brass/steel) | ~6 | Baseplate lap (2) + faceplate seam (2) + spares |
| 2.5" SATA SSD *(optional)* | 1 | Mounted in ssd_cage with 4x M3 |

> Insert/screw counts are upper-bound estimates; final counts depend on
> which optional parts you print and on the resolved `// MEASURE` grid/hole
> positions.

---

## Assembly Order

1. Heat-set M3 inserts into the **seam** bosses only (lap, faceplate, panels,
   lid); M2.5 inserts into the standoff bosses and the M.2 post top. The
   baseplate **grid needs no inserts** — you self-tap M3 into its pilot holes
   only where a module lands.
2. Press the **rabbet-lap** baseplate tiles together (2 dowels) and bolt the
   4 lap M3 screws.
3. Mount the motherboard on the standoffs; install the **m2_retainer** post
   under the M.2 module and screw the M.2 down.
4. Join the two **faceplate** tiles (dovetail + transverse M3 pin-bolt + 2
   dowels); bolt the faceplate bottom flange to the front baseplate lip.
5. Drop the **io_subplate** into the faceplate window (4x M3) — pick the
   variant for your front I/O.
6. Fit the **rear_panel** (tongue into rear lip, side edges into wall-top
   grooves, 3-4x M3).
7. *(Optional)* Bolt the **ssd_cage** to the grid and install the SSD.
8. *(Optional)* Thumb-screw the two **lid** tiles to the wall-tops.
9. Bolt into the 10" rack with M5 cage nuts (whole left/right columns).

---

## Notes / Next Steps

- **Caliper before printing the final run** — edit only `params.scad`:
  board hole positions, M.2 connector + retainer distance, all I/O cutout
  positions, and the `U_BOTTOM_Z` rack-datum vs chassis-floor offset.
- **Confirm the EIA face-hole Z list** (`EIA_FACE_HOLES_Z`) lines up with
  the physical rack U-grid before committing the faceplate.
- **Verify USB-C power-in** wiring/handshake for the replaced barrel jack.
- STL/PNG outputs are gitignored — only the `.scad` sources are committed.
