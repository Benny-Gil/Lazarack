// =====================================================================
// parts/baseplate_front.scad  ->  baseplate_front()
//
// PART 1 of 9.  Front floor tile of the chassis body.
// Assembly region: X 0..190, Y 0..122, Z 0..86.
//   - Floor (Z 0..FLOOR) for Y 0..(FRONT_TILE_D-LAP_LEN), then a LOWER
//     rabbet tongue (Z 0..LAP_STEP_Z) for the 25mm depth-seam lap.
//   - Integral L/R side-wall upstands (X 0..WALL_T and BODY_W-WALL_T..BODY_W),
//     Z 0..UPSTAND_H.
//   - Front faceplate lip/tongue at Y~0 (beds into the faceplate flange groove).
//   - Front half of the 15mm M3 heat-set grid (rows with Y < FRONT_TILE_D).
//   - 2x front M2.5 board standoffs (board FL / FR holes).
//   - REAR edge seam: rabbet_lap_male (MALE lower tongue) + 2 dowel holes
//     + 4x M3 heat-set inserts along the lap -> mates baseplate_rear.
//
// Modeled directly in the GLOBAL ASSEMBLY FRAME (origin = front-bottom-left
// interior corner). main.scad unions this module with NO transform.
//
// FROZEN CONTRACT: do NOT redefine params or joinery here.
// =====================================================================

include <params.scad>
use <../lib/joinery.scad>


// ---- local placement helpers (assembly-frame constants for THIS tile) ----

// Y at which the lower rabbet tongue begins (front MALE step Y 97..122):
LAP_Y_START      = FRONT_TILE_D - LAP_LEN;     // = 97

// X positions of the 4 M3 inserts along the rear lap (inboard of the walls):
FRONT_LAP_M3_X   = [ WALL_T + 18, BODY_CX - 28, BODY_CX + 28, BODY_W - WALL_T - 18 ];
// Y center of those inserts: near mid-lap. Held at 110 (not 109.5) so the
// boss is >7mm from the nearest grid rows (y 102.5 / 117.5) -> avoids the
// exact-tangent-cylinder non-manifold seam (boss OD = 7 = 2*radius).
FRONT_LAP_M3_Y   = 110;

// 2 alignment dowel holes along the lap (between the M3 inserts):
FRONT_LAP_DOWEL_X = [ BODY_CX - 55, BODY_CX + 55 ];
FRONT_LAP_DOWEL_Y = 110;
DOWEL_D           = 4;     // alignment pin diameter
DOWEL_DEPTH       = 8;     // pin hole depth

// Lap fastening pillar heights (rise from Z=0 through the thin 1.5mm tongue):
LAP_M3_BOSS_H     = LAP_STEP_Z + M3_INSERT_DEPTH + 2;   // = 8.5 (insert clears tongue)
LAP_DOWEL_BOSS_H  = LAP_STEP_Z + DOWEL_DEPTH + 1;       // = 10.5 (blind 8mm hole)

// Front faceplate lip: a low tongue along the front edge (Y 0..LIP_T) that
// the faceplate bottom flange grooves over.  Sits on top of the floor.
FACE_LIP_T        = 6;     // lip depth in Y
FACE_LIP_H        = 6;     // lip height above floor (Z FLOOR..FLOOR+FACE_LIP_H)

// Front board standoff holes = the two FRONT board mounting holes (FL, FR):
FRONT_STANDOFF_XY = [ BOARD_HOLES[0], BOARD_HOLES[1] ];   // FL ~[18,10], FR ~[172,10]

// Points the grid pilot-holes must steer clear of (standoffs + lap bosses +
// dowel pillars). A grid pilot within GRID_CLEAR of any of these is skipped.
FRONT_GRID_EXCLUDE = concat(
    FRONT_STANDOFF_XY,
    [ for (x = FRONT_LAP_M3_X)    [x, FRONT_LAP_M3_Y]    ],
    [ for (x = FRONT_LAP_DOWEL_X) [x, FRONT_LAP_DOWEL_Y] ]
);

// true if (gx,gy) is at least `md` from every point in `pts`.
function _far(gx, gy, pts, md) =
    len([ for (p = pts) if (norm([gx - p[0], gy - p[1]]) < md) 1 ]) == 0;


module baseplate_front() {
    difference() {
        union() {
            // ---------- (1) FLOOR: full thickness up to the lap ----------
            // Y 0..LAP_Y_START at full FLOOR thickness.
            cube([BODY_W, LAP_Y_START, FLOOR]);

            // ---------- (2) REAR rabbet-lap MALE tongue ----------
            // Lower tongue Z 0..LAP_STEP_Z spanning the lap (Y 97..122).
            // Local origin of rabbet_lap_male is front-bottom-left, extends +Y.
            translate([0, LAP_Y_START, 0])
                rabbet_lap_male(BODY_W, LAP_LEN, LAP_STEP_Z, FLOOR, EPS);

            // ---------- (3) L/R integral side-wall upstands ----------
            // Left wall: X 0..WALL_T.   Right wall: X BODY_W-WALL_T..BODY_W.
            // Span Y 0..FRONT_TILE_D, Z 0..UPSTAND_H. Overlap floor by EPS.
            // (walls rise from Z 0; floor shares Z 0..FLOOR -> already joined)
            translate([0, 0, 0])
                cube([WALL_T, FRONT_TILE_D, UPSTAND_H]);
            translate([BODY_W - WALL_T, 0, 0])
                cube([WALL_T, FRONT_TILE_D, UPSTAND_H]);

            // ---------- (4) FRONT faceplate lip / tongue ----------
            // Low bar along the front edge, on top of the floor, between walls.
            // X WALL_T..BODY_W-WALL_T so it tucks inside the side walls.
            translate([WALL_T - EPS, 0, FLOOR - EPS])
                cube([BODY_W - 2*WALL_T + 2*EPS, FACE_LIP_T, FACE_LIP_H + EPS]);

            // ---------- (5) M3 self-tap pilot grid ----------
            //   (moved to the difference() scope below — the grid is now
            //    BLIND PILOT HOLES bored into the flat floor, not bosses.)

            // ---------- (6) 2x FRONT M2.5 board standoffs ----------
            // Raise board to Z = FLOOR + STANDOFF_H. Standoff base at floor top.
            for (p = FRONT_STANDOFF_XY)
                translate([p[0], p[1], FLOOR - EPS])
                    m25_standoff(STANDOFF_H + EPS, M25_BOSS_OD,
                                 M25_INSERT_BORE, M25_INSERT_DEPTH, 2, EPS);

            // ---------- (7) M3 heat-set bosses along the rear lap ----------
            // 4 inserts that bolt the rear tile down through the lap. Bosses
            // rise from Z=0 (base on the tongue bottom -> fully fused through
            // the 1.5mm tongue) tall enough that the upward insert bore clears
            // the thin tongue. Boss top at LAP_M3_BOSS_H.
            for (x = FRONT_LAP_M3_X)
                translate([x, FRONT_LAP_M3_Y, 0])
                    heatset_boss(M3_BOSS_OD, M3_INSERT_BORE,
                                 LAP_M3_BOSS_H, M3_INSERT_DEPTH, EPS);

            // ---------- (8) 2x dowel pillars (pre-drilled) on the lap ----------
            // Solid pillars from Z=0 with a BLIND dowel hole, built+drilled in
            // their own local difference() (below) so the boolean stays local
            // and never interacts with the grid bores / standoff fillets in
            // the main union (keeps the whole part cleanly 2-manifold).
            for (x = FRONT_LAP_DOWEL_X)
                translate([x, FRONT_LAP_DOWEL_Y, 0])
                    dowel_pillar();
        }

        // ---- M3 self-tap pilot grid (front tile rows, Y < FRONT_TILE_D) ----
        // Blind holes bored DOWN from the floor top; skipped wherever they'd
        // fall under a standoff / lap boss / dowel pillar (keeps them clear &
        // manifold). dowel_hole() bores from its local Z=0 downward, so place
        // its top at Z=FLOOR.
        for (cx = [0 : GRID_COLS-1], ry = [0 : GRID_ROWS-1]) {
            gx = GRID_X0 + cx * GRID_PITCH;
            gy = GRID_Y0 + ry * GRID_PITCH;
            if (gy < FRONT_TILE_D - EPS
                && gx > WALL_T + GRID_PILOT_D
                && gx < BODY_W - WALL_T - GRID_PILOT_D
                && _far(gx, gy, FRONT_GRID_EXCLUDE, GRID_CLEAR))
                translate([gx, gy, FLOOR])
                    dowel_hole(GRID_PILOT_D, GRID_PILOT_DEPTH, EPS);
        }

        // (Lap dowel holes are differenced locally inside dowel_pillar().)
    }
}


// ---- local: a single pre-drilled dowel alignment pillar -------------
// Solid M3_BOSS_OD pillar rising from Z=0 to LAP_DOWEL_BOSS_H with a blind
// DOWEL_D hole opening UPWARD (bottom of hole sits above the thin tongue).
module dowel_pillar() {
    difference() {
        cylinder(h = LAP_DOWEL_BOSS_H, d = M3_BOSS_OD);
        // dowel_hole bores DOWNWARD from Z=0 (its local top); position its top
        // at the pillar top so the DOWEL_DEPTH hole stays blind in the pillar.
        translate([0, 0, LAP_DOWEL_BOSS_H])
            dowel_hole(DOWEL_D, DOWEL_DEPTH, EPS);
    }
}


// ---- standalone render ----------------------------------------------
// $fa/$fs normally live ONLY in main.scad; these are scoped to the standalone
// call so the part renders smooth + 2-manifold when opened/exported on its own.
// (main.scad `use <>`s this file, which does NOT execute these statements, so
//  the project's single-source-of-resolution convention is preserved.)
$fa = 1;
$fs = 0.4;
baseplate_front();
