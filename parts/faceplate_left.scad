// =====================================================================
// parts/faceplate_left.scad  ->  faceplate_left()
//
// LEFT half of the split 254mm rack faceplate, modeled IN the GLOBAL
// ASSEMBLY FRAME (origin = front-bottom-left interior corner of chassis;
// +X width left->right, +Y depth front->rear, +Z height bottom->top).
//
// Assembly region (per FROZEN CONTRACT part_placements):
//   X  FACE_X0(-32) .. FACE_SPLIT_X(95)      (FACE_TILE_W = 127 wide)
//   Y  -FACE_T(-4)  .. 0                      (thin slab; Y=0 = body front)
//   Z  0            .. FACE_H (~86, covers the EIA 2U hole column)
//
// Features:
//   - Whole LEFT M5 rack cage-nut column at X = M5_X_LEFT (-23.2625): 6
//     clearance holes at EIA_FACE_HOLES_Z (EIA-310 2U pattern, axis +Y).
//   - CENTER seam at X = FACE_SPLIT_X (95): dovetail_male tongue (grows +Y
//     into the body) + 1 transverse M3 pin-bolt clearance hole + 2 dowel
//     pin holes -> mates faceplate_right (dovetail_female).
//   - BOTTOM flange tongue() bedding onto the baseplate_front front lip,
//     with M3 clearance holes down into the baseplate inserts.
//   - LEFT part of the recessed io_subplate window (X 35..95, Z from
//     IO_WIN_Z0), an inner-face pocket + a smaller through-opening that
//     keeps a continuous frame, with M3 heat-set bosses so the swappable
//     io_subplate bolts in (bores open toward +Y / the body interior).
//
// Printability: prints FLAT on its OUTER face (Y = -FACE_T) on the bed ->
// the slab is the largest face, zero supports. Every heat-set bore opens
// "up" in that print orientation (toward +Y here) and never bridges a hole.
// Tile is 127 (X) x ~86 (Z) -> both bed-plane axes <= 190. OK.
//
// Every uncertain dim is a // MEASURE default living in params.scad.
// =====================================================================

include <params.scad>
use <../lib/joinery.scad>


// ---- derived local constants (NOT contract params) -------------------
// FACE_H now comes from params.scad (1U front-panel height, 43.66mm) — the
// faceplate panel is taller than the interior side walls (UPSTAND_H).
TILE_X0         = FACE_X0;              // -32  left outer edge
TILE_X1         = FACE_SPLIT_X;         //  95  center seam edge
TILE_W          = TILE_X1 - TILE_X0;    // 127  = FACE_TILE_W

// Bottom mounting flange (tongue bedding onto baseplate_front front lip).
FLANGE_H        = 8;                    // MEASURE flange height up the back (Z)
FLANGE_T        = WALL_T;               // = 3  flange thickness into body (+Y)
FLANGE_M3_INSET = 14;                   // MEASURE M3 mount inset from tile ends

// Center-seam joinery geometry (seam plane = X = FACE_SPLIT_X = 95).
// The dovetail tongue protrudes from the seam face into the body (+Y), with
// its locking taper in the X-Z plane: it widens in X (w_root -> w_tip) going
// up in Z, so the two tiles slide together along Z and lock against pull-out.
DT_DEPTH        = 8;                    // dovetail protrusion into body (+Y)
DT_W_ROOT       = 12;                   // dovetail root width in X (top)
DT_W_TIP        = 18;                   // dovetail tip  width in X (bottom)
DT_ZSPAN        = 22;                   // dovetail Z extent (taper run)
DT_Z_TOP        = FACE_H * 0.66;        // dovetail top Z (root edge)
// NOTE: this centerline dovetail-seam geometry is still 2U-proportioned and
// overshoots the 1U panel; it needs replacing with a bolted-overlap seam
// (directive #8). Tracked as remaining work — kept manifold for now.
DT_Z_BOT        = DT_Z_TOP - DT_ZSPAN;  // dovetail bottom Z (tip edge)
SEAM_RAIL_W     = 6;                    // X-width of solid seam rail (frame)
SEAM_BLOCK_T    = DT_DEPTH + 4;         // seam block depth into body (+Y)
SEAM_BLOCK_Z0   = DT_Z_BOT - 10;        // seam block bottom Z (brackets tongue)
SEAM_BLOCK_Z1   = DT_Z_TOP + 20;        // seam block top Z (hosts pin + dowel)
// pin + 2 alignment dowels live WITHIN the seam block Z-span, clear of each
// other and the dovetail (pin axis +X spans the whole block; dowels are
// shallow +X bores from the seam face):
PIN_Z           = DT_Z_TOP + 14;        // transverse M3 pin-bolt, topmost
DOWEL_Z_LO      = DT_Z_BOT - 5;         // lower alignment-dowel, below dovetail
DOWEL_Z_HI      = DT_Z_TOP + 6;         // upper alignment-dowel, above dovetail
DOWEL_D         = 4;                    // alignment dowel pin diameter
DOWEL_DEPTH     = 8;                    // dowel hole depth into seam block (+Y)

// io_subplate window (LEFT part). The io_subplate is 120 wide and its window
// straddles the seam (X 35..155); on THIS tile it occupies X 35..95. The
// window is built as three NESTED rectangles that never share an edge (avoids
// degenerate zero-width shelves / coincident faces -> stays 2-manifold, one
// solid):
//   * APERTURE  = the through-hole the I/O pokes out of.
//   * RECESS    = a shallow inner-face pocket, strictly SURROUNDS the aperture
//                 by RECESS_LIP, so the io_subplate seats flush; bounded so a
//                 solid full-thickness frame remains around it.
//   * FRAME     = the solid full-thickness border outside the recess (incl. the
//                 SEAM_RAIL_W seam rail) that keeps the tile one body and seats
//                 the four M3 bosses.
WIN_Z0          = IO_WIN_Z0;            // 20  window bottom (assembly Z) MEASURE
WIN_TOP_RAIL    = 6;                    // solid slab kept above the window
WIN_Z1          = min(WIN_Z0 + IO_SUB_H, FACE_H - WIN_TOP_RAIL); // capped top
WIN_RECESS      = 1.5;                  // inner-face pocket depth (+Y) MEASURE
RECESS_LIP      = 4;                    // recess overhangs aperture each side
FRAME_W         = 9;                    // solid frame width around the recess

// Aperture rectangle (assembly X,Z). Inset from the window envelope by the
// frame + recess lip; its right edge stays clear of the seam rail.
AP_X0           = IO_WIN_X0 + FRAME_W + RECESS_LIP;          // 48
AP_X1           = FACE_SPLIT_X - SEAM_RAIL_W - FRAME_W - RECESS_LIP; // 76
AP_Z0           = WIN_Z0 + FRAME_W + RECESS_LIP;             // 33
AP_Z1           = WIN_Z1 - FRAME_W - RECESS_LIP;             // 67

// Recess rectangle = aperture grown by RECESS_LIP on every side.
RC_X0           = AP_X0 - RECESS_LIP;   // 44
RC_X1           = AP_X1 + RECESS_LIP;   // 80
RC_Z0           = AP_Z0 - RECESS_LIP;   // 29
RC_Z1           = AP_Z1 + RECESS_LIP;   // 71

IO_BOSS_H       = 6;                    // M3 boss proud of inner face (+Y)


module faceplate_left() {
    difference() {
        union() {
            // -------- main faceplate slab (Y -FACE_T .. 0) --------------
            translate([TILE_X0, -FACE_T, 0])
                cube([TILE_W, FACE_T, FACE_H]);

            // -------- bottom mounting flange (tongue onto baseplate lip) -
            // grows into the body (+Y) right behind the slab inner face.
            translate([TILE_X0, 0, 0])
                tongue(TILE_W, FLANGE_H, FLANGE_T);     // w(X) x t(Y) x h(Z)

            // -------- center-seam reinforcing block ---------------------
            // Straddles just LEFT of the seam, fused to the slab, hosting the
            // dovetail + pin + dowels and giving the thin slab real meat.
            // Spans X from a rail left of the seam to SEAM_BLOCK_T into body.
            // Front face reaches Y=-WIN_RECESS so it bridges the io-window
            // recess pocket and stays fused to the slab in that Z-band.
            translate([FACE_SPLIT_X - SEAM_RAIL_W, -WIN_RECESS, SEAM_BLOCK_Z0])
                cube([SEAM_RAIL_W + SEAM_BLOCK_T, SEAM_BLOCK_T + WIN_RECESS,
                      SEAM_BLOCK_Z1 - SEAM_BLOCK_Z0]);

            // -------- dovetail_male tongue at the seam ------------------
            // Native dovetail_male(h, depth, w_root, w_tip): trapezoid in X-Y
            // (root w_root in X at native Y=0 -> tip w_tip in X at Y=depth),
            // extruded +Z by h, centered in X. rotate([-90,0,0]) maps:
            //   native +Z(h)     -> world +Y  (tongue protrudes into body)
            //   native +Y(depth) -> world -Z  (taper runs downward in Z)
            //   native +X(width) -> world +X  (the X dovetail taper)
            // So root (w_root) is at world Z=DT_Z_TOP, tip (w_tip) at the
            // bottom Z=DT_Z_BOT; tongue protrudes Y 0..DT_DEPTH into the body.
            // faceplate_right applies the SAME transform to dovetail_female.
            translate([FACE_SPLIT_X, 0, DT_Z_TOP])
                rotate([-90, 0, 0])
                    dovetail_male(DT_DEPTH, DT_ZSPAN, DT_W_ROOT, DT_W_TIP);

            // -------- io_subplate M3 mounting bosses (LEFT column) ------
            // IO_SUB_M3 holes are io_subplate-LOCAL; mapped to assembly via the
            // window origin (IO_WIN_X0, WIN_Z0). Only the LEFT column (assembly
            // X <= seam) lives on this tile. Each lands on the SOLID full-
            // thickness frame around the recess, so it roots at the inner face
            // (Y=0) and rises +Y into the body; the bore opens at the +Y top so
            // the io_subplate's M3 screws drive in -- no bridging over a hole.
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

        // -------- M5 rack cage-nut column (whole LEFT column) ----------
        // eia_face_holes assumes plate Y 0..t; shift -FACE_T to bite the
        // real slab at Y -FACE_T..0. Axis +Y.
        translate([0, -FACE_T, 0])
            eia_face_holes(EIA_FACE_HOLES_Z, M5_X_LEFT, M5_CLEAR, FACE_T);

        // -------- io_subplate window: inner-face recess pocket ----------
        // RECESS rectangle (RC_*), shallow pocket on the inner face (Y -1.5..0)
        // so the subplate seats flush. Strictly SURROUNDS the aperture and is
        // bounded inside the solid frame -> no zero-width shelf, stays manifold.
        translate([RC_X0, -WIN_RECESS, RC_Z0])
            cube([RC_X1 - RC_X0, WIN_RECESS + EPS, RC_Z1 - RC_Z0]);

        // -------- io_subplate window: through-opening (APERTURE) --------
        // APERTURE rectangle (AP_*), the through-hole the I/O exits. Strictly
        // inside the recess -> a continuous full-thickness frame (+ the recess
        // shelf) surrounds it; tile stays one solid body.
        translate([AP_X0, -FACE_T - EPS, AP_Z0])
            cube([AP_X1 - AP_X0, FACE_T + 2*EPS, AP_Z1 - AP_Z0]);

        // -------- center-seam transverse M3 pin-bolt --------------------
        // Drilled along +X through the seam block, clearance hole.
        translate([FACE_SPLIT_X - SEAM_RAIL_W - EPS, SEAM_BLOCK_T/2, PIN_Z])
            rotate([0, 90, 0])
                cylinder(h = SEAM_RAIL_W + SEAM_BLOCK_T + 2*EPS, d = M3_CLEAR);

        // -------- center-seam 2x alignment-dowel holes ------------------
        // Axis +X into the seam block (dowel pins run across the seam).
        for (dz = [DOWEL_Z_LO, DOWEL_Z_HI])
            translate([FACE_SPLIT_X - DOWEL_DEPTH, SEAM_BLOCK_T/2, dz])
                rotate([0, 90, 0])
                    cylinder(h = DOWEL_DEPTH + EPS, d = DOWEL_D);

        // -------- bottom-flange M3 clearance holes (down into baseplate) -
        for (fx = [TILE_X0 + FLANGE_M3_INSET,
                   TILE_X1 - FLANGE_M3_INSET,
                   (TILE_X0 + TILE_X1)/2]) {
            translate([fx, FLANGE_T/2, -EPS])
                cylinder(h = FLANGE_H + 2*EPS, d = M3_CLEAR);
        }
    }
}


// ---- standalone render -----------------------------------------------
faceplate_left();
