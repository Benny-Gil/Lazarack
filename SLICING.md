# Slicing guide — Ender 3 V3 SE · 0.4 mm nozzle · PETG

Tuned for this case's **loose-fit, bolt-tight** design (brim, no supports, and
the tolerance lives in the model via `FIT_CLEARANCE = 0.5 mm`, not the slicer).
Field names are Cura-style; OrcaSlicer / Creality Print have the same settings.

> Print everything **flat, largest face down** (the STLs are already oriented).
> See [`stl/README.md`](stl/README.md) for the print order.

## Material & temperature (PETG)

| Setting | Value |
|---|---|
| Nozzle temp | **240 °C** (235–245) |
| Bed temp | **75 °C** (70–80) |
| First-layer nozzle / bed | **245 °C / 80 °C** |
| Flow / extrusion multiplier | **0.95–1.0** — calibrate; PETG over-extrudes easily and that's what closes up holes/slots |

## Quality

| Setting | Value |
|---|---|
| Layer height | **0.2 mm** (0.24 OK for the chunky baseplates) |
| Initial layer height | **0.24 mm** |
| Line width | 0.4 mm |
| Walls / perimeters | **4** (1.6 mm — the 3 mm walls print fully solid) |
| Top / bottom layers | **5** |
| Infill | **30 %**, gyroid or grid |

## Speed (moderate — PETG on an open frame)

- Outer wall **45 mm/s**, inner 60, infill 70
- **First layer 20–25 mm/s** (adhesion). Don't chase the V3 SE's top speed on PETG.

## Cooling · retraction · adhesion

| Setting | Value |
|---|---|
| Fan | **40–50 %** (0 % for the first 2–3 layers) — PETG bond suffers if over-cooled |
| Retraction (Sprite **direct drive**) | **~1.0 mm @ 40 mm/s** (not Bowden's 5–6 mm) |
| Z-hop | 0.2 mm (optional; PETG oozes) |
| **Build-plate adhesion** | **Brim, 6–8 mm** — non-negotiable for the baseplate quads + 212 mm panels |
| **Supports** | **OFF** — everything is designed support-free |
| Z-seam | Rear / sharpest corner |

## ★ Design-specific settings (these matter most)

| Setting | Value | Why |
|---|---|---|
| Horizontal expansion / XY size compensation | **0** | `FIT_CLEARANCE` already builds the slop in — don't double it. |
| Hole horizontal expansion | **0** | Self-tap pilots *want* to print slightly undersized (tighter M3 bite); clearance holes are already oversized. |
| Elephant-foot / initial-layer horizontal expansion | **0** (or −0.15 mm) | A 0.8 mm bottom chamfer is built into the parts; add negative comp only if first layers still squish wide. |

## Per-part notes

- **Baseplate quadrants** — brim on, slow first layer, **one per plate**. Tallest /
  most warp-prone parts (a 40 mm wall on a 106 × 110 floor).
- **Rear panel + lid tiles (212 mm wide)** — brim, and watch the corners: at 212 mm
  they sit near the bed edge where adhesion/warp is worst. Clean bed + slow first layer.
- **Splices / clips / inserts** — batch several per plate; a small brim is plenty.
- **PETG + PEI plate** — the V3 SE's PEI sheet can grip PETG *too* hard and tear it.
  A thin **glue-stick layer acts as a release agent** (counterintuitive, but it
  protects the plate and pops parts off clean).
