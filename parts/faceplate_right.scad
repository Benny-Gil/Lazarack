// =====================================================================
// parts/faceplate_right.scad  ->  faceplate_right()
// Project: Dell Inspiron 15-5558/5559 motherboard -> NiH DIY 10" rack
// Printer: Ender 3 V3 SE (bed 220x220x250). Material: PETG.
//
// RIGHT half of the 254mm-wide split faceplate (the LEFT|RIGHT seam is at
// the rack centerline X = FACE_SPLIT_X = 95). This tile spans
//   X  95 .. 222   (FACE_TILE_W = 127 wide)
//   Y  -FACE_T .. 0  (= -4 .. 0 ; the faceplate plate, thin in depth)
//   Z  0 .. ~90      (covers the 2U EIA face hole pattern + margin)
//
// Modeled DIRECTLY in the GLOBAL ASSEMBLY FRAME so it mates with its
// neighbors (faceplate_left at the X=95 seam, baseplate_front lip at the
// bottom flange) with NO transform in main.scad.
//
// FROZEN CONTRACT: params come from params.scad; joinery from
// lib/joinery.scad. This file does NOT redefine any of them.
//
// SEAMS (per the contract part_placements["parts/faceplate_right.scad"]):
//   - Whole RIGHT M5 rack column at X = M5_X_RIGHT (213.2625), drilled with
//     eia_face_holes() over the 2U EIA_FACE_HOLES_Z pattern.
//   - CENTER seam at X=95: dovetail_female() pocket receiving faceplate_left's
//     dovetail_male, + 1 transverse M3 pin-bolt clearance hole + 2 dowel holes.
//   - BOTTOM flange: tongue() that beds into the baseplate_front front lip,
//     plus M3 clearance holes to bolt down.
//   - RIGHT part of the recessed io_subplate window (X 95..155) + that
//     side's io_subplate M3 mount bosses.
//
// PRINTABILITY: prints FLAT, largest face (the X-Z plate) down on the bed.
// The plate is only 127(X) x 90(Z) -> both <=190, fits the bed with margin.
// All heat-set bores open along +Z (upward when printing flat). The window
// is a clean through-cut; no overhang steeper than 45deg needs support
// because the plate is printed flat (the Y-thickness is the layer stack).
// =====================================================================

include <params.scad>
use <../lib/joinery.scad>

// ---------------------------------------------------------------------
// Local design constants for THIS tile (kept local; not contract globals)
// ---------------------------------------------------------------------
FR_X0        = FACE_SPLIT_X;          // 95   tile inner (seam) edge
FR_X1        = FACE_X1;               // 222  tile outer edge
FR_W         = FR_X1 - FR_X0;         // 127  tile width (== FACE_TILE_W)
FR_H         = FACE_H;                // tile height in Z (1U panel, covers 3 EIA holes)
FR_T         = FACE_T;                // 4    plate thickness (Y), at Y -4..0

// --- center-seam dovetail params (MUST match faceplate_left's male) ---
// The dovetail is a KEY in the plane of the faceplate: its trapezoid lies in
// the X-Z plane (engagement along -X into this tile; flare/width along Z) and
// it is extruded through the plate THICKNESS in Y (h == FR_T). This locks the
// two tiles against an in-plane pull-apart in +/-X. It is a LOCALIZED key
// centered at mid-height, NOT a full-height feature.
DT_DEPTH     = 8;                     // engagement depth across the seam (mm)
DT_W_ROOT    = 12;                    // root width (along Z) at the seam plane
DT_W_TIP     = 18;                    // tip width  (along Z), the locking flare
DT_CLEAR     = 0.2;                   // female oversize per face (slide fit)
DT_Z         = FR_H/2;                // dovetail key center height (Z) // MEASURE

// --- center-seam transverse M3 pin-bolt + dowels (match left tile) ---
SEAM_PIN_Z   = FR_H/2;                // M3 pin-bolt height up the seam // MEASURE
SEAM_DOWEL_Z = [ FR_H*0.25, FR_H*0.75 ]; // 2 dowel heights // MEASURE
SEAM_DOWEL_D = 4;                     // dowel pin diameter
SEAM_DOWEL_L = 8;                     // dowel hole depth (into the seam face)

// --- bottom flange (tongue) into baseplate_front lip ---
FLANGE_H     = 6;                     // tongue height in Z (beds into lip)  // MEASURE
FLANGE_T     = 3;                     // tongue thickness in Y               // MEASURE
FLANGE_BOLTS_X = [ FR_X0 + 25, FR_X1 - 25 ]; // 2x M3 bolt-down X positions // MEASURE
FLANGE_BOLT_Z  = FLANGE_H/2;          // bolt height within the flange

// --- io_subplate window: RIGHT part of the full window (X 95..155) ---
// Full window in assembly frame: X IO_WIN_X0 .. IO_WIN_X0+IO_SUB_W = 35..155,
// Z IO_WIN_Z0 .. IO_WIN_Z0+IO_SUB_H = 20..90. This tile owns X 95..155.
// The subplate FOOTPRINT (the recess it seats into) spans the full IO_SUB
// envelope; the actual THROUGH-OPENING is inset by IO_FRAME so a seating lip
// remains all around. The M3 mount bosses sit ON that lip (solid material),
// NOT inside the opening, so they stay connected to the plate.
IO_FOOT_X0   = IO_WIN_X0;              // 35   subplate footprint left
IO_FOOT_X1   = IO_WIN_X0 + IO_SUB_W;   // 155  subplate footprint right
IO_FOOT_Z0   = IO_WIN_Z0;              // 20   footprint bottom
IO_FOOT_Z1   = IO_WIN_Z0 + IO_SUB_H;   // 90   footprint top
IO_FRAME     = 8;                      // seating-lip width around the opening
IO_OPEN_X0   = IO_FOOT_X0 + IO_FRAME;  // through-opening left
IO_OPEN_X1   = IO_FOOT_X1 - IO_FRAME;  // through-opening right
IO_OPEN_Z0   = IO_FOOT_Z0 + IO_FRAME;  // through-opening bottom
IO_OPEN_Z1   = IO_FOOT_Z1 - IO_FRAME;  // through-opening top
IO_RECESS    = 1.5;                    // recess depth so subplate sits flush // MEASURE
// io_subplate M3 mount bosses owned by THIS tile (the right-side pair).
// IO_SUB_M3 are LOCAL to the subplate; convert to assembly X,Z and keep the
// ones falling on this tile (X>=95). Bosses sit on the BACK (Y=0) face, on
// the seating lip. (Corner holes at inset 6 land within the IO_FRAME=8 lip.)
function io_m3_to_asm(p) = [ IO_WIN_X0 + p[0], IO_WIN_Z0 + p[1] ];

// ---------------------------------------------------------------------
module faceplate_right() {
    difference() {
        union() {
            // ---- main faceplate plate (this tile) -------------------
            // Plate occupies X FR_X0..FR_X1, Y -FR_T..0, Z 0..FR_H.
            translate([FR_X0, -FR_T, 0])
                cube([FR_W, FR_T, FR_H]);

            // ---- bottom flange / tongue into baseplate_front lip ----
            // tongue(w,h,t): bar w(X) x t(Y) x h(Z). Place it on the INNER
            // (Y=0) face, hanging just below into the lip groove region.
            // We attach it along the plate inner face and extend a little
            // below Z=0 so it beds; baseplate lip captures it.
            translate([FR_X0, 0 - EPS, 0])
                tongue(FR_W, FLANGE_H, FLANGE_T, EPS);
            // ^ tongue() = cube([w, t, h]) at local origin -> occupies
            //   X FR_X0..FR_X1, Y 0..FLANGE_T (inner side), Z 0..FLANGE_H.

            // ---- io_subplate mount bosses (right-side pair) ---------
            // Heat-set M3 bosses on the inner face for the io_subplate screws.
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

        // ---- M5 rack column (whole RIGHT column) --------------------
        // eia_face_holes drills +Y at X=x for each Z; bore through FR_T.
        // The plate inner face is Y=0; module bores Y -eps..t+eps, but our
        // plate is at Y -FR_T..0, so shift it by -FR_T in Y.
        translate([0, -FR_T, 0])
            eia_face_holes(EIA_FACE_HOLES_Z, M5_X_RIGHT, M5_CLEAR, FR_T, EPS);

        // ---- center-seam dovetail FEMALE pocket ---------------------
        // dovetail_female builds the trapezoid in module-X-Y (root@Y=0, tip@
        // Y=depth, width along module-X) extruded along module-Z by h. We want
        // it as an in-plane key: trapezoid in assembly X-Z, engagement along
        // -X (into this tile), flare-width along Z, extruded through the plate
        // thickness in Y. The two rotations map:
        //   rotate([90,0,0]):  module-Y(depth) -> +Z,  module-Z(extrude) -> -Y
        //   rotate([0,-90,0]): then +Z(depth)  -> -X,  -Y(extrude) stays -Y
        // => depth -> -X (into tile), width -> Z, extrude -Y through thickness.
        // Translate Y=+EPS so the -Y extrude (h=FR_T+2*EPS) clears both faces.
        translate([FR_X0, EPS, DT_Z])
            rotate([0, -90, 0])
                rotate([90, 0, 0])
                    dovetail_female(FR_T + 2*EPS, DT_DEPTH, DT_W_ROOT,
                                    DT_W_TIP, DT_CLEAR, EPS);

        // ---- center-seam transverse M3 pin-bolt clearance -----------
        // A horizontal M3 bolt crossing the seam in -X (pin-bolts the tiles
        // together). Clearance hole through this tile near the seam.
        translate([FR_X0 + DT_DEPTH + 6, -FR_T/2, SEAM_PIN_Z])
            rotate([0, -90, 0])      // axis -> X
                cylinder(h = 20, d = M3_CLEAR, center = true);

        // ---- center-seam dowel holes (axis +X, into this tile) ------
        // The LEFT tile carries protruding dowel pins; THIS tile receives
        // them. The hole must open at the seam face (X=95) and bore +X INTO
        // the right tile. dowel_hole() makes a cylinder Z=-depth..+eps along
        // +Z; rotate([0,-90,0]) maps +Z->-X so the open (+eps) end sits at
        // X=95 and the bore extends to X=95+depth.
        for (zc = SEAM_DOWEL_Z)
            translate([FR_X0, -FR_T/2, zc])
                rotate([0, -90, 0])  // bore +X into the tile from the seam
                    dowel_hole(SEAM_DOWEL_D, SEAM_DOWEL_L, EPS);

        // ---- bottom-flange M3 bolt-down clearance holes -------------
        // Bolt the flange to the baseplate_front lip: clearance holes through
        // the flange thickness (axis +Y).
        for (xc = FLANGE_BOLTS_X)
            translate([xc, -EPS, FLANGE_BOLT_Z])
                rotate([-90, 0, 0])  // axis +Y
                    cylinder(h = FLANGE_T + 2*EPS + 1, d = M3_CLEAR);

        // ---- io_subplate window (RIGHT part: X 95..155) -------------
        // The swappable io_subplate drops into a FRONT recess (sized to its
        // footprint) and air/IO pass through a smaller through-opening, leaving
        // a seating lip all around that carries the M3 mount bosses.
        //
        // This tile owns X >= FR_X0(95). Clip both cuts to X>=FR_X0.
        // 1) Through-opening (full plate thickness) — inset by IO_FRAME:
        op_x0 = max(IO_OPEN_X0, FR_X0);
        translate([op_x0 - EPS, -FR_T - EPS, IO_OPEN_Z0])
            cube([ (IO_OPEN_X1 - op_x0) + EPS,
                   FR_T + 2*EPS,
                   (IO_OPEN_Z1 - IO_OPEN_Z0) ]);
        // 2) Front recess shelf (footprint-sized pocket on the FRONT face,
        //    Y -FR_T .. -FR_T+IO_RECESS) so the subplate sits flush:
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
