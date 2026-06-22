// =====================================================================
// parts/baseplate.scad  ->  baseplate_quad(qx, qy)  +  seam_splice()
//
// The structural floor, split into FOUR bed-friendly QUADRANTS for a
// low-accuracy printer (each ~106 x ~105mm prints flat with no warp).
//
// Design: model the COMPLETE baseplate once (floor + integral L/R side-wall
// upstands + front & rear panel lips + the 15mm M3 self-tap pilot grid), then
// CLIP it into quadrants. There are NO fixed board standoffs — the board sits
// on user-placed m25_grid_insert standoffs at whatever grid points match its
// real holes (tolerance-first).
//
// Quadrants BUTT together and are tied by flat seam_splice() bars that bolt
// into the grid pilots on each side of a seam (slotted = forgiving). No
// precision interlock to print — "loose-fit, bolt-tight".
//
//   qx: 0 = left  (X 0..CX),   1 = right (X CX..BODY_W)
//   qy: 0 = front (Y 0..SY),   1 = rear  (Y SY..DEPTH)
// =====================================================================

include <params.scad>
use <../lib/joinery.scad>

CX      = BODY_W / 2;          // 106  X-seam (also the faceplate centerline)
SY      = FRONT_TILE_D;        // 110  Y-seam (front/rear cut)
CH      = CHAMFER;             // bottom-edge relief for elephant-foot
// (LIP_T, LIP_H, LIP_TOP_Z + the shared pilot columns now live in params.scad,
//  so the faceplate/rear-panel flanges can never drift from these pilots.)

// ---- the complete (un-split) baseplate -------------------------------
module _baseplate_full() {
    difference() {
        union() {
            // floor
            cube([BODY_W, DEPTH, FLOOR]);
            // integral L / R side-wall upstands (1U)
            cube([WALL_T, DEPTH, UPSTAND_H]);
            translate([BODY_W - WALL_T, 0, 0]) cube([WALL_T, DEPTH, UPSTAND_H]);
            // front + rear panel lips (raised bars the panel flanges bolt onto)
            translate([WALL_T - EPS, 0, FLOOR - EPS])
                cube([BODY_W - 2*WALL_T + 2*EPS, LIP_T, LIP_H + EPS]);
            translate([WALL_T - EPS, DEPTH - LIP_T, FLOOR - EPS])
                cube([BODY_W - 2*WALL_T + 2*EPS, LIP_T, LIP_H + EPS]);
            // wall-top bosses: a local INWARD thickening of each side-wall top
            // at every lid fastener Y, so the lid's M3 thumb-screws have real
            // material to self-tap into (a bare 3mm wall top cannot hold M3).
            for (y = concat(LID_FASTEN_Y_FRONT, LID_FASTEN_Y_REAR)) {
                translate([0, y - LID_BOSS_Y/2, UPSTAND_H - LID_WALL_PILOT_DEPTH])
                    cube([LID_BOSS_W, LID_BOSS_Y, LID_WALL_PILOT_DEPTH]);
                translate([BODY_W - LID_BOSS_W, y - LID_BOSS_Y/2, UPSTAND_H - LID_WALL_PILOT_DEPTH])
                    cube([LID_BOSS_W, LID_BOSS_Y, LID_WALL_PILOT_DEPTH]);
            }
        }
        // --- 15mm M3 self-tap pilot grid (blind holes in the flat floor) ---
        for (cx = [0 : GRID_COLS-1], ry = [0 : GRID_ROWS-1]) {
            gx = GRID_X0 + cx * GRID_PITCH;
            gy = GRID_Y0 + ry * GRID_PITCH;
            if (gx > WALL_T + GRID_PILOT_D && gx < BODY_W - WALL_T - GRID_PILOT_D
                && gy > LIP_T + 2 && gy < DEPTH - LIP_T - 2)
                translate([gx, gy, FLOOR]) dowel_hole(GRID_PILOT_D, GRID_PILOT_DEPTH, EPS);
        }
        // --- panel-flange M3 self-tap pilots in the lips (front + rear) ---
        // SHARED columns: faceplate + rear_panel flanges bolt straight down
        // into these exact (X,Y) points (params: PANEL_PILOT_X/FRONT/REAR).
        for (x = PANEL_PILOT_X) {
            translate([x, FRONT_PILOT_Y, LIP_TOP_Z]) dowel_hole(GRID_PILOT_D, LIP_H, EPS);
            translate([x, REAR_PILOT_Y,  LIP_TOP_Z]) dowel_hole(GRID_PILOT_D, LIP_H, EPS);
        }
        // --- lid wall-top self-tap pilots (bored down from each wall top) ---
        for (y = concat(LID_FASTEN_Y_FRONT, LID_FASTEN_Y_REAR)) {
            translate([LID_WALL_CX_L, y, UPSTAND_H]) dowel_hole(GRID_PILOT_D, LID_WALL_PILOT_DEPTH, EPS);
            translate([LID_WALL_CX_R, y, UPSTAND_H]) dowel_hole(GRID_PILOT_D, LID_WALL_PILOT_DEPTH, EPS);
        }
        // --- bottom-edge chamfer (elephant-foot relief) around the floor ---
        _bottom_chamfer();
    }
}

// 45deg relief cut around the bottom outer perimeter of the floor.
module _bottom_chamfer() {
    for (e = [
        [[0,0,0],        [0,0,0],   [BODY_W,0,0]],   // front edge (along X)
        [[0,DEPTH,0],    [0,0,0],   [BODY_W,0,0]],   // rear edge
    ]) {}  // (placeholder kept simple)
    // four straight chamfers via long triangular prisms along each edge:
    // front (y=0) and rear (y=DEPTH)
    for (yy = [0, DEPTH])
        translate([-EPS, yy, 0])
            rotate([yy == 0 ? 0 : 180, 0, 0])
                _cham_prism(BODY_W + 2*EPS);
    // left (x=0) and right (x=BODY_W)
    for (xx = [0, BODY_W])
        translate([xx, -EPS, 0])
            rotate([0, 0, xx == 0 ? -90 : 90])
                _cham_prism(DEPTH + 2*EPS);
}
// a triangular prism running +X, cutting the bottom edge at 45deg.
module _cham_prism(len) {
    translate([0, 0, 0])
        rotate([0, 90, 0])
            linear_extrude(len)
                polygon([[0,0],[CH,0],[0,CH]]);
}

// ---- one printed quadrant --------------------------------------------
module baseplate_quad(qx, qy) {
    x0 = qx * CX;  x1 = (qx + 1) * CX;
    y0 = (qy == 0) ? 0  : SY;
    y1 = (qy == 0) ? SY : DEPTH;
    intersection() {
        _baseplate_full();
        translate([x0, y0, -1]) cube([x1 - x0, y1 - y0, UPSTAND_H + 2]);
    }
}

// ---- flat splice bar tying two quadrants across a seam ---------------
// Lies flat on the floor spanning a seam; two slotted M3 holes self-tap into a
// grid pilot on EACH quad. Slots absorb print/measurement slop.
module seam_splice(span = 40) {
    w = 16; t = FLOOR; hole_dy = GRID_PITCH;   // holes one grid pitch apart
    difference() {
        translate([0, 0, 0]) cube([span, w, t]);
        for (sx = [span/2 - hole_dy/2, span/2 + hole_dy/2])
            translate([sx, w/2 - M3_SLOT_W/2, -EPS])
                hull() {
                    cylinder(h = t + 2*EPS, d = M3_CLEAR);
                    translate([0, M3_SLOT_W, 0]) cylinder(h = t + 2*EPS, d = M3_CLEAR);
                }
    }
}

// ---- standalone render: the 4 quadrants laid out + a splice ----------
$fa = 1; $fs = 0.4;
baseplate_quad(0, 0);
translate([CX + 6, 0, 0])     baseplate_quad(1, 0);
translate([0, SY + 6, 0])     baseplate_quad(0, 1);
translate([CX + 6, SY + 6, 0]) baseplate_quad(1, 1);
translate([0, DEPTH + 16, 0]) seam_splice();
