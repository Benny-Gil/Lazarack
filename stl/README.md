# Printable STLs

Exported, ready-to-slice parts for the 1U case. **Regenerate after you edit
`parts/params.scad`** (e.g. once you caliper the board):

```bash
./export_stl.sh        # from the repo root
```

> ⚠️ These are **prototype** exports from the `// MEASURE` placeholder
> dimensions in `params.scad`. Re-export once you've measured the board.
> `reference_board.scad` is a visual prop and is **not** exported.

## Print settings (Ender 3 V3 SE, low-accuracy)

PETG · 0.2 mm layer · 3–4 walls · ~30 % infill · **no supports** · **brim**
(the design is "loose-fit, bolt-tight", so a brim + the FIT_CLEARANCE gaps
absorb dimensional slop). All parts print **flat, largest face down**.

## Print order

Print **bottom-up / structure-first**, and validate fit on a small cheap part
before committing to the big ones:

| # | Part(s) | Qty | Notes |
|---|---|---|---|
| 0 | `board_edge_clip` **or** `m25_grid_insert` | 1 | **Print this first** — a 5-min part to dial in your printer + the slot/peg fit before the big prints. |
| 1 | `baseplate_FL` `baseplate_FR` `baseplate_RL` `baseplate_RR` | 1 each | The structural floor. One quadrant per plate (~106 × 110 mm). |
| 2 | `seam_splice` | ~6 | Tiny bars that bolt the quadrants together — batch several per plate. |
| 3 | `m25_grid_insert` | ~5 | Board standoffs (place at the grid points nearest your board's holes). |
| 4 | `board_edge_clip` | ~4 | Board edge hold-downs. Batch with the inserts/splices. |
| 5 | `faceplate_left` `faceplate_right` | 1 each | Front rack faceplate (cage-nut to the rails). |
| 6 | `rear_panel` | 1 | Blank closure (drill USB-C/SD/audio after a fit check). |
| 7 | `m2_retainer` | 1 | Supplies the missing M.2 standoff. |
| 8 | `io_subplate` | 1 | Blank front insert (drill HDMI/RJ45/USB/exhaust after fit, then reprint just this part). |
| 9 | `ssd_mezzanine` | 1 | *Optional* — only if mounting a 2.5" SATA SSD. |
| 10 | `lid_front` `lid_rear` | 1 each | *Optional* vented top. |

Steps 2–4 are small and can share one build plate. Steps 9–10 are optional.

## Assembly (quick)

1. Bolt the 4 quadrants together with `seam_splice` bars into the grid.
2. Drop `m25_grid_insert` standoffs at the grid points nearest the board's
   holes; set the board on them; add `board_edge_clip`s to trap the edges.
3. Bolt on `m2_retainer`, then the faceplates (front) and rear panel.
4. Drill + fit `io_subplate` to your real port positions; add the optional
   `ssd_mezzanine` and `lid`.
5. Cage-nut the faceplate to the 10" rack front rails (M5, 236.525 mm spacing).
