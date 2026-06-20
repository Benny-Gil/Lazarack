// =====================================================================
// parts/faceplate_right.scad  ->  faceplate_right()
// Project: Dell Inspiron 15-5558/5559 motherboard -> NiH DIY 10" rack
// Printer: Ender 3 V3 SE (bed 220x220x250). Material: PETG.
//
// RIGHT half of the 254mm-wide split faceplate (the LEFT|RIGHT seam is at
// the rack centerline X = FACE_SPLIT_X). This tile spans
//   X  FACE_SPLIT_X .. FACE_X1   (FACE_TILE_W wide)
//   Y  -FACE_T .. 0              (the faceplate plate, thin in depth)
//   Z  0 .. FACE_H (43.66)       (the 1U EIA panel — NOTHING exceeds it)
//
// Modeled DIRECTLY in the GLOBAL ASSEMBLY FRAME so it mates with its
// neighbors (faceplate_left at the seam, baseplate_front lip at the bottom
// flange) with NO transform in main.scad.
//
// FROZEN CONTRACT: params come from params.scad; joinery from
// lib/joinery.scad. This file does NOT redefine any of them.
//
// SEAMS:
//   - Whole RIGHT M5 rack column at X = M5_X_RIGHT, drilled with
//     eia_face_holes() over the three 1U EIA_FACE_HOLES_Z holes.
//   - CENTER seam at X = FACE_SPLIT_X: a BOLTED-OVERLAP lap seam (replaces
//     the old dovetail_female pocket + transverse pin/dowel scheme). This
//     RIGHT tile carries:
//       * a solid SEAM RAIL along its inner edge (meat behind the thin slab),
//       * a REBATE in its BACK half over the lap region so faceplate_left's
//         partial-thickness lap tongue nests in and the outer faces stay flush,
//       * 2 M3 SLOTTED clearance holes (M3_SLOT_W) through the overlap with
//         CHAMFER lead-ins, matching the left tile, so they bolt with slop.
//   - BOTTOM flange: tongue() that beds into the baseplate_front lip, plus
//     M3 clearance holes (chamfered) to bolt down.
//   - RIGHT part of the recessed io_subplate window + that side's M3 bosses.
//
// PRINTABILITY: prints FLAT, largest face (the X-Z plate) down on the bed.
// Plate is FACE_TILE_W (X) x FACE_H (Z) -> both <= PRINT_MAX_XY. The seam
// rail / bosses grow +Y (up off the bed); the rebate is a back-face pocket;
// nothing bridges. Renders Simple: yes, Zmax = FACE_H.
// =====================================================================

include <params.scad>
use <../lib/joinery.scad>

// ---------------------------------------------------------------------
// Local design constants for THIS tile (kept local; not contract globals)
// ---------------------------------------------------------------------
FR_X0        = FACE_SPLIT_X;          // tile inner (seam) edge
FR_X1        = FACE_X1;               // tile outer edge
FR_W         = FR_X1 - FR_X0;         // tile width (== FACE_TILE_W)
FR_H         = FACE_H;                // tile height in Z (1U panel)
FR_T         = FACE_T;                // plate thickness (Y), at Y -FACE_T..0

// ---- center-seam BOLTED-OVERLAP geometry (MUST match faceplate_left) -----
// The LEFT tile owns the lap TONGUE (back half, Y -LAP_T..0, reaching LAP_LEN
// past the seam). THIS tile owns the matching REBATE so the tongue nests in,
// and a SEAM RAIL for meat. FIT_CLEARANCE on the rebate absorbs printer slop.
SEAM_RAIL_W     = 8;                  // X-width of the solid seam rail (meat)
SEAM_RAIL_T     = 6;                  // seam-rail depth into the body (+Y)
LAP_LEN         = 12;                 // tongue reach past the seam into +X
LAP_T           = FR_T / 2;           // tongue thickness (back half of FACE_T)
LAP_BOLT_Z      = [ FR_H * 0.34, FR_H * 0.66 ];  // 2 bolt heights (Z), match left
LAP_BOLT_X      = FR_X0 + LAP_LEN/2;             // bolt X (mid-overlap), match left
LAP_SLOT_TRAVEL = 3;                  // X-elongation of the slot (in/out slop)

// ---- bottom flange (tongue) into baseplate_front lip ----
FLANGE_H     = 6;                     // tongue height in Z (beds into lip)  // MEASURE
FLANGE_T     = 3;                     // tongue thickness in Y               // MEASURE
FLANGE_BOLTS_X = [ FR_X0 + 25, FR_X1 - 25 ]; // 2x M3 bolt-down X positions // MEASURE
FLANGE_BOLT_Z  = FLANGE_H/2;          // bolt height within the flange

// ---- io_subplate window: RIGHT part of the full window ----
// Full window in assembly frame: X IO_WIN_X0 .. IO_WIN_X0+IO_SUB_W,
// Z IO_WIN_Z0 .. IO_WIN_Z0+IO_SUB_H (capped under the 1U panel). This tile
// owns the X >= FR_X0 portion. The subplate FOOTPRINT (recess) spans the full
// envelope; the THROUGH-OPENING is inset by IO_FRAME so a seating lip remains.
IO_FOOT_X0   = IO_WIN_X0;
IO_FOOT_X1   = IO_WIN_X0 + IO_SUB_W;
IO_FOOT_Z0   = IO_WIN_Z0;
IO_FOOT_Z1   = min(IO_WIN_Z0 + IO_SUB_H, FR_H - 6); // capped under the 1U panel
IO_FRAME     = 8;                     // seating-lip width around the opening
IO_OPEN_X0   = IO_FOOT_X0 + IO_FRAME;
IO_OPEN_X1   = IO_FOOT_X1 - IO_FRAME;
IO_OPEN_Z0   = IO_FOOT_Z0 + IO_FRAME;
IO_OPEN_Z1   = IO_FOOT_Z1 - IO_FRAME;
IO_RECESS    = 1.5;                   // recess depth so subplate sits flush // MEASURE
function io_m3_to_asm(p) = [ IO_WIN_X0 + p[0], IO_WIN_Z0 + p[1] ];


// ---- local helper: chamfered slotted bolt hole (axis +Y) --------------
// Elongated in X by `travel`, bored through Y `thru`, with a CHAMFER lead-in
// cone at the entry (+Y) face. Origin = slot center on the inner (Y=0) face.
module lap_bolt_slot(travel, thru) {
    translate([0, thru + EPS, 0])
        rotate([90, 0, 0])
            linear_extrude(height = thru + 2*EPS)
                hull() {
                    translate([-travel/2, 0]) circle(d = M3_SLOT_W);
                    translate([ travel/2, 0]) circle(d = M3_SLOT_W);
                }
    translate([0, thru, 0])
        rotate([-90, 0, 0])
            cylinder(h = CHAMFER + EPS,
                     d1 = M3_SLOT_W, d2 = M3_SLOT_W + 2*CHAMFER);
}


// ---------------------------------------------------------------------
module faceplate_right() {
    difference() {
        union() {
            // ---- main faceplate plate (this tile) -------------------
            translate([FR_X0, -FR_T, 0])
                cube([FR_W, FR_T, FR_H]);

            // ---- center seam RAIL (meat behind the thin slab) -------
            // Solid rail along the inner (seam) edge, grown +Y into the body
            // (Y 0..SEAM_RAIL_T). It sits body-side of the plate, clear of the
            // back-half rebate (Y -LAP_T..0) and of the left tile's tongue.
            translate([FR_X0, 0, 0])
                cube([SEAM_RAIL_W, SEAM_RAIL_T, FR_H]);

            // ---- bottom flange / tongue into baseplate_front lip ----
            translate([FR_X0, 0 - EPS, 0])
                tongue(FR_W, FLANGE_H, FLANGE_T, EPS);

            // ---- io_subplate mount bosses (right-side pair) ---------
            for (p = IO_SUB_M3) {
                a = io_m3_to_asm(p);
                if (a[0] >= FR_X0) {            // only bosses on THIS tile
                    translate([a[0], 0 - EPS, a[1]])
                        rotate([-90, 0, 0])     // boss axis -> +Y (toward body)
                            heatset_boss(M3_BOSS_OD, M3_INSERT_BORE,
                                         M3_INSERT_DEPTH + 1.5, M3_INSERT_DEPTH, EPS);
                }
            }
        }

        // =================================================================
        // SUBTRACTIONS (clean through-cuts / pockets / bores)
        // =================================================================

        // ---- M5 rack column (whole RIGHT column, 3x 1U) -------------
        // eia_face_holes drills +Y at X=x for each Z; bore through FR_T. Plate
        // is at Y -FR_T..0, so shift by -FR_T. EIA_FACE_HOLES_Z = three 1U holes.
        translate([0, -FR_T, 0])
            eia_face_holes(EIA_FACE_HOLES_Z, M5_X_RIGHT, M5_CLEAR, FR_T, EPS);

        // ---- center-seam REBATE for the left tile's lap tongue ------
        // Remove the BACK half (Y -LAP_T..0) over the overlap region so the
        // left tongue nests flush. Oversized by FIT_CLEARANCE on the loose
        // faces (depth/length) so a dimensionally loose print still seats.
        translate([FR_X0 - EPS, -LAP_T - FIT_CLEARANCE, -EPS])
            cube([LAP_LEN + FIT_CLEARANCE + EPS,
                  LAP_T + FIT_CLEARANCE + EPS,
                  FR_H + 2*EPS]);

        // ---- center-seam 2x M3 SLOTTED bolt holes (chamfered) -------
        // Through the front-half material remaining over the overlap, axis +Y,
        // elongated in X for slop. Matches the left tile's slot positions so a
        // single bolt clamps both overlapping layers.
        for (bz = LAP_BOLT_Z)
            translate([LAP_BOLT_X, -FR_T, bz])
                lap_bolt_slot(LAP_SLOT_TRAVEL, FR_T);

        // ---- bottom-flange M3 bolt-down clearance holes (chamfered) -
        for (xc = FLANGE_BOLTS_X) {
            translate([xc, -EPS, FLANGE_BOLT_Z])
                rotate([-90, 0, 0])  // axis +Y
                    cylinder(h = FLANGE_T + 2*EPS + 1, d = M3_CLEAR);
            // CHAMFER lead-in at the +Y entry face
            translate([xc, FLANGE_T + 1, FLANGE_BOLT_Z])
                rotate([90, 0, 0])
                    cylinder(h = CHAMFER + EPS,
                             d1 = M3_CLEAR, d2 = M3_CLEAR + 2*CHAMFER);
        }

        // ---- io_subplate window (RIGHT part) ------------------------
        // This tile owns X >= FR_X0. Clip both cuts to X >= FR_X0.
        // 1) Through-opening (full plate thickness) — inset by IO_FRAME:
        op_x0 = max(IO_OPEN_X0, FR_X0);
        translate([op_x0 - EPS, -FR_T - EPS, IO_OPEN_Z0])
            cube([ (IO_OPEN_X1 - op_x0) + EPS,
                   FR_T + 2*EPS,
                   (IO_OPEN_Z1 - IO_OPEN_Z0) ]);
        // 2) Front recess shelf (footprint-sized pocket on the FRONT face):
        rc_x0 = max(IO_FOOT_X0, FR_X0);
        translate([rc_x0 - EPS, -FR_T - EPS, IO_FOOT_Z0])
            cube([ (IO_FOOT_X1 - rc_x0) + EPS,
                   IO_RECESS + EPS,
                   (IO_FOOT_Z1 - IO_FOOT_Z0) ]);
    }
}

// ---------------------------------------------------------------------
// Standalone render: this part renders alone when opened directly.
// ---------------------------------------------------------------------
faceplate_right();
