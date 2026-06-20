// =====================================================================
// parts/baseplate_rear.scad  ->  baseplate_rear()
//
// Part 2 of 9.  REAR floor tile of the chassis body.
// Modeled IN the GLOBAL ASSEMBLY FRAME (origin = front-bottom-left
// interior corner; +X width, +Y depth, +Z height) so it mates with
// neighbors with NO transform in main.scad.
//
// Assembly region (from FROZEN contract):
//   X 0..BODY_W(190), Y (DEPTH-REAR_TILE_D)=97 .. DEPTH(239), Z 0..UPSTAND_H(86)
//
// Features:
//   - Floor (Z 0..FLOOR) across Y 97..239
//   - FRONT edge: rabbet_lap_female() upper ledge (Y 97..122) receiving the
//     baseplate_front male tongue + 2x dowel holes + 4x M3 heat-set inserts
//   - Integral L/R side-wall upstands (Z 0..86), wall thickness WALL_T
//   - Wall-tops carry grooves for rear_panel side edges + lid-edge inserts
//   - REAR lip with a groove for the rear_panel bottom tongue + 3x M3 inserts
//   - Rear half of the common 15mm M3 heat-set grid (rows 8..14 on the solid
//     rear floor; lap rows are carried as dedicated lap-seam bosses instead)
//   - M2.5 board standoffs: the rear-left & rear-right board holes (the
//     contract's "center" board hole resolves ahead of this tile's floor, so
//     it is carried by baseplate_front -- see REAR_STANDOFFS note below)
//   - M.2 retainer anchor pad (flat boss the m2_retainer foot bolts onto)
//
// PRINTABILITY: prints flat (floor face down), zero supports. All heat-set
// bores open UPWARD. Part footprint X 0..190 (190) and Y 97..239 (142) are
// each <= PRINT_MAX_XY(190).  (Z 86 is the vertical print axis, allowed.)
//
// CONVENTION: shared globals from params.scad; parametric joinery from
// lib/joinery.scad (modules take explicit args, do not read globals).
// =====================================================================

include <params.scad>
use <../lib/joinery.scad>

// ---------------------------------------------------------------------
// Local helper values (derived from frozen params; no param redefinition)
// ---------------------------------------------------------------------
REAR_Y0          = DEPTH - REAR_TILE_D;        // = 97   front edge of rear tile
REAR_Y1          = DEPTH;                       // = 239  rear edge (panel face)
LAP_Y0           = LAP_Y_NOMINAL - LAP_LEN;     // = 97   lap front edge
LAP_Y1           = LAP_Y_NOMINAL;               // = 122  lap rear edge

GRID_H           = FLOOR + 4;                   // boss height (4mm proud of floor)
GRID_FN          = 12;                           // facet count for grid bosses
                                                 //   (12-gon bore is round
                                                 //    enough for a self-centering
                                                 //    brass insert; caps the CGAL
                                                 //    cost of the ~84-boss grid)
BOSS_FN          = 24;                            // facet count for the few
                                                 //   structural bosses/standoffs

// rear-panel bottom tongue groove + M3 inserts (in the rear lip, Y near 239)
REAR_LIP_T       = REAR_T;                       // groove width matches panel tongue (=4)
REAR_LIP_Y0      = REAR_Y1 - 12;                 // = 227  rear-lip front face (Y)
REAR_LIP_H       = FLOOR + 6;                     // = 9    rear-lip height (Z)
REAR_FASTEN_X    = [ 30, 95, 160 ];              // 3x M3 inserts under rear panel // MEASURE

// rear-tile grid rows: start at the first grid row that lands on the SOLID
// rear floor (Y >= LAP_Y1=122), so no grid boss intrudes into the lap pocket
// where the baseplate_front male tongue slides in. The shared lap-seam
// fastening is carried by the dedicated lap bosses (item 8) instead.
REAR_FIRST_ROW   = ceil((LAP_Y1 - GRID_Y0) / GRID_PITCH);    // = 8  (Y 132.5)
// last row must clear the rear lip (boss edge Y+OD/2 <= REAR_LIP_Y0):
REAR_LAST_ROW    = floor((REAR_LIP_Y0 - M3_BOSS_OD/2 - GRID_Y0) / GRID_PITCH); // =14 (Y222.5)
REAR_GRID_ROWS   = REAR_LAST_ROW - REAR_FIRST_ROW + 1;        // = 7 rows (8..14)

// front-lap M3 insert + dowel X positions (mirror baseplate_front male side)
LAP_FASTEN_X     = [ 25, 70, 120, 165 ];        // 4x M3 insert columns on lap // MEASURE
LAP_DOWEL_X      = [ 47.5, 142.5 ];             // 2x dowel pin columns on lap  // MEASURE
LAP_FASTEN_Y     = (LAP_Y0 + LAP_Y1) / 2;       // = 109.5 lap centerline (Y)

// M2.5 board standoffs carried by the rear tile.  The contract lists the
// rear tile owning the "rear/center" board holes RL, RR, CTR (indices 2,3,4
// in BOARD_HOLES).  CTR resolves to ~[127.5, 87] which is 10mm AHEAD of the
// rear floor's front edge (lap at Y=97) -> it would float, so it is filtered
// out here (it belongs to / is carried by baseplate_front, whose floor covers
// Y<97).  Only board holes that land on this tile's solid floor are kept.
REAR_STANDOFF_CANDIDATES = [ BOARD_HOLES[2], BOARD_HOLES[3], BOARD_HOLES[4] ]; // RL,RR,CTR
REAR_STANDOFFS   = [ for (p = REAR_STANDOFF_CANDIDATES) if (p[1] >= LAP_Y1) p ]; // RL, RR

// wall-top groove for rear_panel side edges + lid: a shallow, NARROW channel
// down the centre of each upstand top. Must be NARROWER than WALL_T(3) so the
// wall keeps material on both sides (a full-width groove would shear the whole
// wall top off). 1.2mm wide x 2mm deep keying channel.
WALLTOP_GROOVE_W = 1.2;                          // groove channel width  // MEASURE
WALLTOP_GROOVE_D = 2.0;                          // groove channel depth

// M.2 retainer anchor pad: flat reinforced area under m2_retainer foot
M2_PAD           = M2_FOOT;                       // [16,16] foot footprint
M2_PAD_H         = FLOOR + 1.0;                   // pad slightly proud of floor

// Points the rear grid pilot-holes must steer clear of (standoffs + rear-panel
// bosses); the M.2 pad is excluded separately with a wider radius below.
REAR_GRID_EXCLUDE = concat(
    REAR_STANDOFFS,
    [ for (x = REAR_FASTEN_X) [x, REAR_LIP_Y0 + 3] ]
);

// true if (gx,gy) is at least `md` from every point in `pts`.
function _far(gx, gy, pts, md) =
    len([ for (p = pts) if (norm([gx - p[0], gy - p[1]]) < md) 1 ]) == 0;


// ---------------------------------------------------------------------
// Local MANIFOLD M2.5 standoff (replaces lib/joinery.scad m25_standoff).
//
// WHY NOT use the frozen m25_standoff(): that module's rotate_extrude()
// base-fillet has its INNER radius exactly equal to the boss OD/2, so the
// fillet and the boss share a coincident cylindrical face -> the result is
// NON-2-manifold (renders "Simple: no", export-repair warning) even in
// isolation. lib/joinery.scad is FROZEN and must not be edited, so this
// part builds an equivalent M2.5 standoff that is guaranteed 2-manifold:
// a heatset_boss() (bore opening UPWARD) plus a conical skirt frustum that
// OVERLAPS the boss (no coincident faces). The 45deg skirt (fillet wide x
// fillet tall) prints with zero supports. Functionally identical: M2.5
// board standoff with a side-load base fillet and an upward insert bore.
// ---------------------------------------------------------------------
module m25_standoff_manifold(h, od, bore_d, bore_depth, fillet=2, eps=0.01) {
    union() {
        heatset_boss(od, bore_d, h, bore_depth, eps);
        // conical fillet skirt: base r = od/2+fillet, top r = od/2-eps,
        // so it sinks INTO the boss (overlap) -> 2-manifold union.
        cylinder(h = fillet, r1 = od/2 + fillet, r2 = od/2 - eps);
    }
}


// =====================================================================
module baseplate_rear() {

    difference() {

        union() {

            // ---- 1. Main floor slab  (Y 122..239) -------------------
            // solid floor for the rear-tile body, behind the lap.
            translate([0, LAP_Y1 - EPS, 0])
                cube([BODY_W, REAR_Y1 - LAP_Y1 + EPS, FLOOR]);

            // ---- 2. FRONT rabbet-lap FEMALE upper ledge (Y 97..122) --
            // upper half over the lap; lower step (Z 0..LAP_STEP_Z) pocketed
            // so the baseplate_front male tongue slides underneath it.
            translate([0, LAP_Y0, 0])
                rabbet_lap_female(BODY_W, LAP_LEN + EPS, LAP_STEP_Z, FLOOR, EPS);

            // ---- 3. Integral L / R side-wall upstands (Z 0..86) ------
            // left wall  X 0..WALL_T
            translate([0, REAR_Y0, 0])
                cube([WALL_T, REAR_TILE_D, UPSTAND_H]);
            // right wall X (BODY_W-WALL_T)..BODY_W
            translate([BODY_W - WALL_T, REAR_Y0, 0])
                cube([WALL_T, REAR_TILE_D, UPSTAND_H]);

            // ---- 4. REAR lip (raised bar at the back for the panel) --
            // a thicker rail at the rear edge that the rear_panel bottom
            // tongue grooves into; spans full width between the walls.
            translate([0, REAR_LIP_Y0, 0])
                cube([BODY_W, REAR_Y1 - REAR_LIP_Y0 + EPS, REAR_LIP_H]);

            // ---- 5. Rear half of the M3 self-tap pilot grid ---------
            //   (moved to the difference() scope below — the grid is now
            //    BLIND PILOT HOLES in the flat floor, not heat-set bosses,
            //    so no carpet of inserts and a much faster CGAL render.)

            // ---- 6. 3x M2.5 board standoffs (RL, RR, CTR) -----------
            for (p = REAR_STANDOFFS)
                translate([p[0], p[1], FLOOR - EPS])
                    m25_standoff_manifold(STANDOFF_H + EPS, M25_BOSS_OD,
                                          M25_INSERT_BORE, M25_INSERT_DEPTH, 2, EPS,
                                          $fn = BOSS_FN);

            // ---- 7. M.2 retainer anchor pad -------------------------
            // a flat reinforced pad the m2_retainer foot bolts down onto
            // (the foot itself carries M3 clearance into the grid bosses,
            //  this pad just thickens/levels the floor under it).
            translate([M2_RETAINER_POS[0] - M2_PAD[0]/2,
                       M2_RETAINER_POS[1] - M2_PAD[1]/2,
                       0])
                cube([M2_PAD[0], M2_PAD[1], M2_PAD_H]);

            // ---- 8. Lap-seam M3 insert bosses (front lap) ------------
            // 4x bosses on the upper-ledge lap to bolt the front tile down.
            for (x = LAP_FASTEN_X)
                translate([x, LAP_FASTEN_Y, LAP_STEP_Z - EPS])
                    heatset_boss(M3_BOSS_OD, M3_INSERT_BORE,
                                 (FLOOR - LAP_STEP_Z) + 4,
                                 M3_INSERT_DEPTH, EPS, $fn = BOSS_FN);

            // ---- 9. Rear-panel M3 insert bosses (in rear lip) --------
            // sit IN FRONT of the panel-tongue groove (lower Y) so their
            // upward bore is never sliced by the groove pocket.
            for (x = REAR_FASTEN_X)
                translate([x, REAR_LIP_Y0 + 3, 0])
                    heatset_boss(M3_BOSS_OD, M3_INSERT_BORE,
                                 REAR_LIP_H, M3_INSERT_DEPTH, EPS, $fn = BOSS_FN);
        }

        // ===== NEGATIVE FEATURES (difference) ========================

        // ---- A. 2x dowel-alignment-pin holes on the lap -------------
        // vertical pin holes through the upper ledge of the lap. dowel_hole
        // bores from Z=0 DOWN to -depth, so place its top at the ledge TOP
        // (Z=FLOOR): the hole then passes through the full ledge thickness
        // and the mating male tongue's lower step, aligning both tiles.
        for (x = LAP_DOWEL_X)
            translate([x, LAP_FASTEN_Y, FLOOR])
                dowel_hole(4, FLOOR + 2, EPS);

        // ---- B. Rear-panel bottom-tongue GROOVE in the rear lip -----
        // channel opens UP (+Z) on top of the rear lip, at the rear face,
        // to receive the rear_panel bottom tongue (REAR_T wide in Y).
        translate([0, REAR_Y1 - REAR_LIP_T, REAR_LIP_H - WALLTOP_GROOVE_D])
            groove(BODY_W, WALLTOP_GROOVE_D + EPS, REAR_LIP_T, 0.2, EPS);

        // ---- C. Wall-top grooves for rear_panel side edges + lid ----
        // narrow keying channel down the CENTRE of each upstand top (opens
        // +Z), leaving wall material on both sides so the wall top stays at
        // Z=UPSTAND_H(86) except for the 1.2mm channel. The rear_panel side
        // edges / lid locating tabs key into these.
        // left wall (centre X = WALL_T/2)
        translate([WALL_T/2 - WALLTOP_GROOVE_W/2,
                   REAR_Y0 - EPS,
                   UPSTAND_H - WALLTOP_GROOVE_D])
            cube([WALLTOP_GROOVE_W,
                  REAR_TILE_D + 2*EPS,
                  WALLTOP_GROOVE_D + EPS]);
        // right wall (centre X = BODY_W - WALL_T/2)
        translate([BODY_W - WALL_T/2 - WALLTOP_GROOVE_W/2,
                   REAR_Y0 - EPS,
                   UPSTAND_H - WALLTOP_GROOVE_D])
            cube([WALLTOP_GROOVE_W,
                  REAR_TILE_D + 2*EPS,
                  WALLTOP_GROOVE_D + EPS]);

        // ---- D. M3 self-tap pilot grid (rear-tile rows on the solid floor) --
        // Blind holes bored DOWN from the floor top; confined between the lap
        // (Y>LAP_Y1) and the rear lip, and skipped near standoffs / rear bosses
        // / the M.2 pad. dowel_hole() bores from local Z=0 downward.
        for (cx = [0 : GRID_COLS-1], ry = [REAR_FIRST_ROW : REAR_LAST_ROW]) {
            gx = GRID_X0 + cx * GRID_PITCH;
            gy = GRID_Y0 + ry * GRID_PITCH;
            if (gx > WALL_T + GRID_PILOT_D
                && gx < BODY_W - WALL_T - GRID_PILOT_D
                && gy > LAP_Y1 + EPS
                && gy < REAR_LIP_Y0 - GRID_PILOT_D
                && _far(gx, gy, REAR_GRID_EXCLUDE, GRID_CLEAR)
                && _far(gx, gy, [M2_RETAINER_POS], 13))
                translate([gx, gy, FLOOR])
                    dowel_hole(GRID_PILOT_D, GRID_PILOT_DEPTH, EPS);
        }
    }
}


// ---- standalone render (renders this part alone) ---------------------
$fa = 1; $fs = 0.4;
baseplate_rear();
