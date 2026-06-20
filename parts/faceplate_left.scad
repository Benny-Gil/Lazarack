// =====================================================================
// parts/faceplate_left.scad  ->  faceplate_left()
//
// LEFT half of the split 254mm rack faceplate, modeled IN the GLOBAL
// ASSEMBLY FRAME (origin = front-bottom-left interior corner of chassis;
// +X width left->right, +Y depth front->rear, +Z height bottom->top).
//
// Assembly region (per FROZEN CONTRACT part_placements):
//   X  FACE_X0 .. FACE_SPLIT_X            (FACE_TILE_W wide)
//   Y  -FACE_T .. 0                       (thin slab; Y=0 = body front)
//   Z  0       .. FACE_H (43.66, the 1U EIA panel — NOTHING exceeds it)
//
// Features:
//   - Whole LEFT M5 rack cage-nut column at X = M5_X_LEFT: clearance holes
//     at EIA_FACE_HOLES_Z (the three 1U EIA-310 holes, axis +Y).
//   - CENTER seam at X = FACE_SPLIT_X: a BOLTED-OVERLAP lap seam (replaces
//     the old dovetail press-fit + 2U seam block + pin/dowel scheme, all of
//     which overshot the 1U panel). This LEFT tile carries:
//       * a solid SEAM RAIL along its inner edge (meat behind the thin slab),
//       * a thin LAP TONGUE at PARTIAL thickness (back half of FACE_T) that
//         extends LAP_LEN past the seam behind the panel face, so the RIGHT
//         tile's matching rebate nests over it and both front faces stay flush,
//       * 2 M3 SLOTTED holes (M3_SLOT_W, elongated in X) through the overlap
//         with CHAMFER lead-ins, so the tiles bolt together with in/out slop.
//   - BOTTOM flange tongue() bedding onto the baseplate_front front lip,
//     with M3 clearance holes (chamfered) down into the baseplate inserts.
//   - LEFT part of the recessed io_subplate window, with M3 heat-set bosses.
//
// Printability: prints FLAT on its OUTER face (Y = -FACE_T) on the bed. The
// lap tongue, seam rail and bosses all grow +Y (up off the bed) so nothing
// bridges. Tile is FACE_TILE_W (X) x FACE_H (Z) -> both <= PRINT_MAX_XY. OK.
// Renders Simple: yes, Zmax = FACE_H.
// =====================================================================

include <params.scad>
use <../lib/joinery.scad>


// ---- derived local constants (NOT contract params) -------------------
TILE_X0         = FACE_X0;              // left outer edge
TILE_X1         = FACE_SPLIT_X;         // center seam edge
TILE_W          = TILE_X1 - TILE_X0;    // = FACE_TILE_W

// Bottom mounting flange (tongue bedding onto baseplate_front front lip).
FLANGE_H        = 8;                    // MEASURE flange height up the back (Z)
FLANGE_T        = WALL_T;               // = 3  flange thickness into body (+Y)
FLANGE_M3_INSET = 14;                   // MEASURE M3 mount inset from tile ends

// ---- center-seam BOLTED-OVERLAP geometry (seam plane = X = FACE_SPLIT_X) --
// The LEFT tile owns the lap TONGUE; the RIGHT tile owns the matching rebate.
SEAM_RAIL_W     = 8;                    // X-width of the solid seam rail (meat)
SEAM_RAIL_T     = 6;                    // seam-rail depth into the body (+Y)
LAP_LEN         = 12;                   // tongue reach past the seam into +X
LAP_T           = FACE_T / 2;           // tongue thickness (back half of FACE_T)
// Lap tongue occupies Y -LAP_T..0 (back half) so the RIGHT tile's front half
// (Y -FACE_T..-LAP_T) stays solid and both outer faces sit flush at Y=-FACE_T.
// Two bolt slots along Z, kept well inside Z 0..FACE_H:
LAP_BOLT_Z      = [ FACE_H * 0.34, FACE_H * 0.66 ];  // 2 bolt heights (Z)
LAP_BOLT_X      = FACE_SPLIT_X + LAP_LEN/2;           // bolt X (mid-overlap)
LAP_SLOT_TRAVEL = 3;                    // X-elongation of the slot (in/out slop)

// io_subplate window (LEFT part). Built as three NESTED rectangles that never
// share an edge (avoids degenerate zero-width shelves -> stays 2-manifold):
//   * APERTURE  = the through-hole the I/O pokes out of.
//   * RECESS    = a shallow inner-face pocket surrounding the aperture so the
//                 io_subplate seats flush, bounded inside a solid frame.
//   * FRAME     = the solid full-thickness border (incl. the seam rail).
WIN_Z0          = IO_WIN_Z0;            // window bottom (assembly Z) MEASURE
WIN_TOP_RAIL    = 6;                    // solid slab kept above the window
WIN_Z1          = min(WIN_Z0 + IO_SUB_H, FACE_H - WIN_TOP_RAIL); // capped top
WIN_RECESS      = 1.5;                  // inner-face pocket depth (+Y) MEASURE
RECESS_LIP      = 4;                    // recess overhangs aperture each side
FRAME_W         = 9;                    // solid frame width around the recess

// Aperture rectangle (assembly X,Z). Inset from the window envelope by the
// frame + recess lip; its right edge stays clear of the seam rail.
AP_X0           = IO_WIN_X0 + FRAME_W + RECESS_LIP;
AP_X1           = FACE_SPLIT_X - SEAM_RAIL_W - FRAME_W - RECESS_LIP;
AP_Z0           = WIN_Z0 + FRAME_W + RECESS_LIP;
AP_Z1           = WIN_Z1 - FRAME_W - RECESS_LIP;

// Recess rectangle = aperture grown by RECESS_LIP on every side.
RC_X0           = AP_X0 - RECESS_LIP;
RC_X1           = AP_X1 + RECESS_LIP;
RC_Z0           = AP_Z0 - RECESS_LIP;
RC_Z1           = AP_Z1 + RECESS_LIP;

IO_BOSS_H       = 6;                    // M3 boss proud of inner face (+Y)


// ---- local helper: chamfered slotted bolt hole (axis +Y) --------------
// Elongated in X by `travel`, bored through Y `thru`, with a CHAMFER lead-in
// cone at the entry (+Y) face. Origin = slot center on the inner (Y=0) face.
module lap_bolt_slot(travel, thru) {
    // through slot (hull of two cylinders along X), axis +Y
    translate([0, thru + EPS, 0])
        rotate([90, 0, 0])
            linear_extrude(height = thru + 2*EPS)
                hull() {
                    translate([-travel/2, 0]) circle(d = M3_SLOT_W);
                    translate([ travel/2, 0]) circle(d = M3_SLOT_W);
                }
    // CHAMFER lead-in at the +Y entry face (cone widening outward)
    translate([0, thru, 0])
        rotate([-90, 0, 0])
            cylinder(h = CHAMFER + EPS,
                     d1 = M3_SLOT_W, d2 = M3_SLOT_W + 2*CHAMFER);
}


module faceplate_left() {
    difference() {
        union() {
            // -------- main faceplate slab (Y -FACE_T .. 0) --------------
            translate([TILE_X0, -FACE_T, 0])
                cube([TILE_W, FACE_T, FACE_H]);

            // -------- bottom mounting flange (tongue onto baseplate lip) -
            translate([TILE_X0, 0, 0])
                tongue(TILE_W, FLANGE_H, FLANGE_T);     // w(X) x t(Y) x h(Z)

            // -------- center seam RAIL (meat behind the thin slab) ------
            // Solid rail along the inner edge, just left of the seam, fused to
            // the slab; grows +Y into the body. Front face reaches the recess
            // pocket (Y=-WIN_RECESS) so it stays fused across the io-window band.
            translate([FACE_SPLIT_X - SEAM_RAIL_W, -WIN_RECESS, 0])
                cube([SEAM_RAIL_W, SEAM_RAIL_T + WIN_RECESS, FACE_H]);

            // -------- center seam LAP TONGUE (overlaps into the RIGHT tile) -
            // Partial-thickness tongue on the BACK half (Y -LAP_T..0), reaching
            // LAP_LEN past the seam. The RIGHT tile's rebate nests over it; the
            // RIGHT tile's front half keeps both outer faces flush at Y=-FACE_T.
            translate([FACE_SPLIT_X, -LAP_T, 0])
                cube([LAP_LEN, LAP_T, FACE_H]);

            // -------- io_subplate M3 mounting bosses (LEFT column) ------
            for (m = IO_SUB_M3) {
                bx = IO_WIN_X0 + m[0];
                bz = WIN_Z0 + m[1];
                if (bx <= FACE_SPLIT_X - 2)
                    translate([bx, -EPS, bz])
                        rotate([-90, 0, 0])     // boss axis +Y (into body)
                            heatset_boss(M3_BOSS_OD, M3_INSERT_BORE,
                                         IO_BOSS_H, M3_INSERT_DEPTH);
            }
        }

        // ================= NEGATIVES (cuts) =========================

        // -------- M5 rack cage-nut column (whole LEFT column, 3x 1U) ----
        // eia_face_holes assumes plate Y 0..t; shift -FACE_T to bite the real
        // slab at Y -FACE_T..0. Axis +Y. EIA_FACE_HOLES_Z = the three 1U holes.
        translate([0, -FACE_T, 0])
            eia_face_holes(EIA_FACE_HOLES_Z, M5_X_LEFT, M5_CLEAR, FACE_T);

        // -------- io_subplate window: inner-face recess pocket ----------
        translate([RC_X0, -WIN_RECESS, RC_Z0])
            cube([RC_X1 - RC_X0, WIN_RECESS + EPS, RC_Z1 - RC_Z0]);

        // -------- io_subplate window: through-opening (APERTURE) --------
        translate([AP_X0, -FACE_T - EPS, AP_Z0])
            cube([AP_X1 - AP_X0, FACE_T + 2*EPS, AP_Z1 - AP_Z0]);

        // -------- center-seam 2x M3 SLOTTED bolt holes (chamfered) ------
        // Through the lap tongue (back half), axis +Y, elongated in X for slop.
        for (bz = LAP_BOLT_Z)
            translate([LAP_BOLT_X, -LAP_T, bz])
                lap_bolt_slot(LAP_SLOT_TRAVEL, LAP_T);

        // -------- bottom-flange M3 clearance holes (chamfered) ----------
        for (fx = [TILE_X0 + FLANGE_M3_INSET,
                   TILE_X1 - FLANGE_M3_INSET,
                   (TILE_X0 + TILE_X1)/2]) {
            // through clearance hole (axis +Z)
            translate([fx, FLANGE_T/2, -EPS])
                cylinder(h = FLANGE_H + 2*EPS, d = M3_CLEAR);
            // CHAMFER lead-in at the bottom (Z=0) entry face
            translate([fx, FLANGE_T/2, -EPS])
                cylinder(h = CHAMFER + EPS,
                         d1 = M3_CLEAR + 2*CHAMFER, d2 = M3_CLEAR);
        }
    }
}


// ---- standalone render -----------------------------------------------
faceplate_left();
