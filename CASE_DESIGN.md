# Modular Laptop Motherboard Server Case — Design Spec

A 3D-printed **1U** enclosure that mounts a salvaged **laptop motherboard**
into a **NiH "DIY 10-inch" cage-nut server rack** (Printables #1634385). It is
**parametric**: set your board's outline in the `★ YOUR BOARD` block of
`parts/params.scad` and the body width, interior depth, the four baseplate
quadrants, faceplate centering, and the grid all reflow — so it fits **any
laptop board that fits a 10" rack** (the **Dell Inspiron 15-5558/5559** is the
worked example, and `assert`s stop the build if a board is too big). All
structural parts print on a **low-accuracy Creality Ender 3 V3 SE**
(bed 220 x 220 x 250 mm) in **PETG**, flat, with no supports.

The full parametric model lives in `parts/*.scad` (one module per printed
part), shares one frozen contract in `parts/params.scad`, and is joined by
the reusable joinery library in `lib/joinery.scad`. `main.scad` unions all
parts with no transforms.

---

## Design language — LOOSE-FIT, BOLT-TIGHT

This is the **Round-2 redesign**, retargeted at a printer that cannot be
trusted to hit dimensions. The single governing principle:

> **Nothing relies on a dimensionally accurate print to mate. Gaps absorb
> slop; bolts pull seams flush.**

Every mating seam carries `FIT_CLEARANCE = 0.5 mm` of deliberate gap. Seams
are not press-fit interlocks — they are **bolted** flush with `seam_splice`
bars and grid screws. The board is held by **grid-placed standoffs and edge
clips**, not by fixed standoffs that demand a hole hit exactly. The front
and rear panels ship **blank** and are **drilled to the real board after a
test fit**. The result: a misjudged dimension costs a drill bit or a
relocated standoff, never a reprint.

---

## Board Analysis

| Parameter | Value |
|---|---|
| Board | Dell Inspiron 15-5558 / 5559 motherboard |
| Footprint | **near-square ~203 mm (X) x 197 mm (Y) x ~1 mm** |
| Fan | Blower (side), heatpipe-fed |
| Front I/O (Edge-alpha) | HDMI + USB-A x2 + blower **exhaust** (drilled into io_subplate) |
| Rear I/O (Edge-beta) | USB-C power-in (barrel jack replaced) + SD reader + 3.5 mm audio |
| Storage | NGFF (M.2) onboard + SATA to a 2.5" SSD on the mezzanine |
| Mounting | corner + center holes; **M.2 standoff is missing** (added by a printed retainer). Board held by grid-placed M2.5 standoffs + edge clips, not fixed posts |

> Every uncertain real-world dimension is a `// MEASURE` placeholder in
> `params.scad` with a sane default, so the model renders today. Caliper the
> board and edit **only `params.scad`**. Because the panels are drilled to
> fit, port positions are the most forgiving numbers in the file.

---

## Target Form Factor — 1U, 10" rack

| Dimension | Value |
|---|---|
| Rack standard | NiH DIY 10" cage-nut rack (Printables #1634385) |
| Height | **1U = 44.45 mm** (`EXT_HEIGHT`); side walls `UPSTAND_H` = 40 mm, faceplate panel `FACE_H` = 43.66 mm |
| Structural body width | `BODY_W` = 212 mm (X: 0..212), centerline `BODY_CX` = 106 |
| Interior depth | `DEPTH` = 210 mm |
| Faceplate width | `FACE_W` = 254 mm (full rack width, X -21..233) |
| Rack fasteners | **M5** cage-nut clearance holes; three 1U face holes per column at Z = 6.35 / 22.225 / 38.1 mm (`EIA_FACE_HOLES_Z`) |

### Shared assembly coordinate frame
Origin `(0,0,0)` = **front-bottom-left interior corner** of the chassis.
`+X` width (left->right), `+Y` depth (front->rear, Y=0 is the rack-front
interior face), `+Z` height (bottom->top). Every part is modeled directly
in this frame; `main.scad` does no transforms. The board PCB underside sits
at `BOARD_Z` = 8 mm (`FLOOR` 3 + `STANDOFF_H` 5).

---

## The Printed Parts

| # | File / module | Role |
|---|---|---|
| 1–4 | `baseplate.scad` -> `baseplate_quad(qx,qy)` (×4) | Structural floor split into **four bed-friendly quadrants** (qx,qy ∈ {0,1}), each with its integral side/floor walls and its share of the 15 mm M3 self-tap pilot grid. No fixed standoffs. |
| – | `baseplate.scad` -> `seam_splice(span)` | Flat bar that bolts **across** a quadrant seam into the grid on both sides — the "bolt-tight" element that pulls a loose seam flush. |
| 5 | `faceplate_left.scad` -> `faceplate_left()` | Left half of the 254 faceplate; whole **left M5 rack column** (`M5_X_LEFT`); left half of the io-window. Split at `FACE_SPLIT_X` = 106. |
| 6 | `faceplate_right.scad` -> `faceplate_right()` | Right half; whole **right M5 column** (`M5_X_RIGHT`); right half of the io-window. |
| 7 | `io_subplate.scad` -> `io_subplate()` | **Blank** swappable front insert (`IO_SUB_W` 130 x `IO_SUB_H` 32 x `IO_SUB_T` 3) filling the faceplate window. Ports (HDMI / USB-A / exhaust) are **drilled by the user** after a fit check. |
| 8 | `m2_retainer.scad` -> `m2_retainer()` | Gusseted M2.5 post supplying the **missing M.2 standoff**; foot bolts to the grid, top takes an M2.5 insert. |
| 9 | `rear_panel.scad` -> `rear_panel()` | **Blank** rear panel (`REAR_W` 212 x `REAR_H` 40 x `REAR_T` 4). Flange **rests on the rear lip and bolts down into the shared pilots**; USB-C / SD / audio cutouts **drilled later**. |
| 10 | `ssd_mezzanine.scad` -> `ssd_mezzanine()` *(opt)* | 2.5" SATA drive carrier on stilts **above** the board, bolted to the grid (keeps the floor clear). |
| 11–14 | `lid.scad` -> `lid_front(qx)`, `lid_rear(qx)` *(opt)* | Vented **1U** top in **four bed-friendly tiles** (split in X *and* Y); each thumb-screws down into **wall-top self-tap bosses** the baseplate provides. |
| – | `m25_grid_insert.scad` -> `m25_grid_insert(h)` | Grid-dropped M2.5 board standoff — placed wherever the board's holes land on the pilot grid. The tolerance-first replacement for fixed standoffs. |
| – | `board_edge_clip.scad` -> `board_edge_clip(reach)` | Finger that reaches over and traps the board edge — board retention that needs no precise hole. |

Every part fits within the ~190 mm print limit in both bed-plane axes and
prints largest-face-down with no supports.

---

## Joinery & the Common M3 Grid Interface

The single interoperability standard is **one 15 mm-pitch M3 self-tap pilot
grid** (`GRID_PITCH` 15, origin `GRID_X0`/`GRID_Y0` = 12.5, pilots Ø`GRID_PILOT_D`
2.5 x `GRID_PILOT_DEPTH` 2.4 mm) on the quadrant floors. The grid points are
blind pilot holes you screw an M3 directly into (PETG self-taps) — **no
heat-set inserts in the grid**, and the floor stays flat. Everything bolts to
this grid: the seam splices, the M.2 retainer, SSD mezzanine, board standoffs
(`m25_grid_insert`), edge clips. You only tap the few points each item
actually uses.

The loose-fit/bolt-tight rule means seams **never** depend on an accurate
print. Each seam has a `FIT_CLEARANCE` (0.5 mm) gap and is closed by a bolted
element rather than an interference fit. `CHAMFER` (0.8 mm) breaks edges so
parts self-locate as bolts draw them together.

Reusable joints live in `lib/joinery.scad` (parametric — they take explicit
args, they do not read `params.scad`):

| Joint | Where used |
|---|---|
| `rabbet_lap_male` / `rabbet_lap_female` | Quadrant/lid seams where a stepped lap helps the splice register |
| `dovetail_male` / `dovetail_female` | Optional registration on the faceplate centerline seam |
| `dowel_hole` | Alignment pins / the blind pilot-grid bores |
| `tongue` / `groove` | Panel-bottom flanges into baseplate lips |
| `heatset_boss` | Structural seam/module joints (bores open **upward**, no bridging) |
| `m3_grid` | The 15 mm self-tap grid stamped into each quadrant floor |
| `m25_standoff` / `m25_grid_insert` | Board standoffs + M.2 post top, dropped on grid points |
| `eia_face_holes` | M5 rack clearance holes through the faceplate (three 1U Z positions) |
| `louver_grille` | Louvered vents in the lid tiles |

**Printability rules enforced in geometry:** every part lies flat,
largest-face-down, zero supports; no overhang > 45 deg without a
chamfer/teardrop; all heat-set bores open upward; base fillets/gussets on
side-loaded posts.

---

## Resolved I/O Mapping

```
            FRONT faceplate (Edge-alpha)          REAR panel (Edge-beta)
        ┌──────────────────────────────┐      ┌──────────────────────────────┐
        │  io_subplate window (BLANK):  │      │  rear_panel (BLANK):          │
        │   HDMI            ← drilled    │      │   USB-C power-in  ← drilled   │
        │   USB-A x2        ← drilled    │      │   SD card reader  ← drilled   │
        │   blower EXHAUST  ← drilled    │      │   3.5 mm audio    ← drilled   │
        └──────────────────────────────┘      └──────────────────────────────┘
```

- Both panels ship **blank**. After a test fit of the real board you mark and
  **drill** each cutout — the loose-fit philosophy applied to I/O: you never
  have to predict a port position to sub-millimeter and reprint if wrong.
- **Front** carries the user-facing data ports plus the blower exhaust via the
  swappable `io_subplate`.
- **Rear** carries power-in and the low-traffic ports.

### Airflow
Blower intake is internal; the exhaust is **drilled** into the front
io_subplate aligned to the fan outlet (`EXHAUST_POS` / `EXHAUST_SIZE`, both
`// MEASURE`). Vented lid tiles assist; no active case cooling — the laptop
fan handles it.

### Power
The barrel jack was replaced with **USB-C power-in** drilled into the rear
panel (`USBC_POS` / `USBC_SIZE`, `// MEASURE`).

---

## Ender 3 V3 SE Print Plate

PETG, **0.2 mm** layer, **3-4 walls**, **30-40% infill**, **no supports**,
**brim** recommended for the tall thin faceplate/rear tiles. Every part
prints flat (largest face down). The four small **quadrants** each fit the
bed comfortably and are forgiving of warp because the splices, not tight
interlocks, register the seams.

| Part | Orientation on bed | Notes |
|---|---|---|
| `baseplate_quad` ×4 | floor-down | Grid bores face up; one or two quads per plate |
| `seam_splice` | flat | Tiny; batch several per plate |
| `faceplate_left` / `faceplate_right` | outer face down | Brim; M5/window features need no support laid flat |
| `io_subplate` | back face down | Ships blank — drill ports after fit |
| `rear_panel` | outer face down | Brim; ships blank — drill ports after fit |
| `m2_retainer` | foot down | Gussets print in-plane; M2.5 bore opens up |
| `ssd_mezzanine` *(opt)* | floor down | Stilts print up |
| `lid_front(qx)` / `lid_rear(qx)` *(opt)* | flat | 4 tiles (X+Y split); vent slots in-plane |

---

## Bill of Materials

### Printed parts (PETG)
| Part | Qty |
|---|---|
| baseplate_quad | 4 |
| seam_splice | ~4 (one per seam, batch spares) |
| faceplate_left, faceplate_right | 1 each |
| io_subplate (blank) | 1 |
| m2_retainer | 1 |
| rear_panel (blank) | 1 |
| m25_grid_insert (board standoffs) | ~5 (one per board hole) |
| board_edge_clip | ~4 |
| ssd_mezzanine *(optional)* | 1 |
| lid_front(qx), lid_rear(qx) *(optional)* | 2 each (qx = 0 left / 1 right) = 4 tiles |

### Fasteners & hardware
| Item | Qty (approx) | Use |
|---|---|---|
| M3 brass heat-set inserts (bore ~4.0 mm x 5 mm) | ~12-18 | Structural seam bosses only — **grid uses no inserts** |
| M3 screws (8-10 mm) | ~30-40 | Seam splices, panels, mezzanine, retainer, clips — self-tap into the grid |
| M2.5 brass heat-set inserts | ~6 | Board standoff tops (`m25_grid_insert`) + M.2 post |
| M2.5 screws | ~6 | Board hold-down + M.2 retainer |
| M5 rack cage nuts + screws | up to 6 | Three 1U face holes per column (clearance, not inserts) |
| 2.5" SATA SSD *(optional)* | 1 | Mounted on ssd_mezzanine |

> Counts are upper-bound estimates; final counts depend on which optional
> parts you print and on the resolved `// MEASURE` board-hole positions
> (which decide how many `m25_grid_insert` standoffs and clips you place).

---

## Assembly Order

1. Heat-set M3 inserts into the **seam** bosses only; M2.5 inserts into the
   standoff/retainer tops. The grid needs no inserts — self-tap M3 only where
   something lands.
2. Lay out the **four baseplate quadrants** and pull each seam flush with a
   bolted **`seam_splice`** bar into the grid (loose-fit gaps close under the
   bolts).
3. Test-fit the board. Drop **`m25_grid_insert`** standoffs onto the grid
   points nearest each board hole, and add **`board_edge_clip`** fingers to
   trap the edges. Install the **m2_retainer** under the M.2 module.
4. Bolt the two **faceplate** tiles to the front quadrants (each keeps a whole
   M5 column).
5. Drop the **blank io_subplate** into the faceplate window; with the board
   present, **mark and drill** the front port + exhaust cutouts.
6. Fit the **blank rear_panel**; mark and **drill** USB-C / SD / audio to the
   board.
7. *(Optional)* Bolt the **ssd_mezzanine** to the grid above the board and
   install the SSD.
8. *(Optional)* Add the two vented **lid** tiles.
9. Bolt into the 10" rack with M5 cage nuts (whole left/right columns, three
   1U holes each).

---

## Notes / Next Steps

- **Caliper before printing the final run** — edit only `params.scad`:
  board hole positions, M.2 connector + retainer distance, the exhaust/port
  positions you'll drill, and the rack-datum vs chassis-floor offset.
- **Confirm the EIA face-hole Z list** (`EIA_FACE_HOLES_Z` = 6.35 / 22.225 /
  38.1) lines up with the physical 1U rack U-grid before committing the
  faceplate.
- **Verify USB-C power-in** wiring/handshake for the replaced barrel jack.
- The legend-labeled render (`docs/img/assembly_labeled.png`) is from an
  earlier revision and is **stale**; the unlabeled iso/exploded renders are
  current.
- STL/PNG outputs are gitignored — only the `.scad` sources are committed.
