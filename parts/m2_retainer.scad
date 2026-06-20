// =====================================================================
// parts/m2_retainer.scad  ->  m2_retainer()
//
// Gusseted M2.5 retainer post that supplies the MISSING M.2 standoff for
// the Dell Inspiron 15-5558/5559 board (the board's far M.2 mounting hole
// has no factory standoff on this chassis floor). It bolts onto the common
// 15mm M3 heat-set grid on baseplate_rear and presents an upward-opening
// M2.5 insert at the board plane so the M.2 SSD screws down into it.
//
// FROZEN CONTRACT — modeled in the GLOBAL ASSEMBLY FRAME:
//   Origin (0,0,0) = front-bottom-left interior corner of the chassis body.
//   +X width, +Y depth, +Z height (floor 0..FLOOR=3, board underside Z=8).
// main.scad unions this module with NO transform, so it is PRE-PLACED here
// at M2_RETAINER_POS and rests on the baseplate floor top (Z = FLOOR).
//
// Placement / sizing (all from params.scad):
//   - Foot footprint  M2_FOOT = [16,16] (X,Y), centered on M2_RETAINER_POS.
//   - Base sits on the floor top at Z = FLOOR (3). The retainer is a SEPARATE
//     printed piece that bolts down onto the grid bosses below it.
//   - M2.5 post rises M2_POST_H (=STANDOFF_H=5) from the floor top to the
//     board plane Z = FLOOR + M2_POST_H = 8, with an M2.5 heat-set insert
//     bore opening UPWARD (no bridging).
//   - Foot carries 2x M3 CLEARANCE through-holes on the nearest 15mm grid
//     points so M3 screws pass through into the baseplate grid inserts.
//   - Diagonal gussets brace the side-loaded post (45deg faces, print-flat,
//     zero supports).
//
// Printability: flat largest-face-down (foot on bed), no overhang >45deg,
// the only bore opens upward. // MEASURE values live ONLY in params.scad.
// =====================================================================

include <params.scad>
use <../lib/joinery.scad>

module m2_retainer() {
    // ---- resolved placement (assembly frame) ----
    cx     = M2_RETAINER_POS[0];          // post center X  (~150) // MEASURE
    cy     = M2_RETAINER_POS[1];          // post center Y  (~133) // MEASURE
    fw     = M2_FOOT[0];                  // foot X extent (16)
    fd     = M2_FOOT[1];                  // foot Y extent (16)
    z0     = FLOOR;                       // base sits on floor top  (Z=3)
    z_top  = FLOOR + M2_POST_H;           // post top = board plane  (Z=8)

    // foot slab: keep thin enough for clean M3 through-holes, thick enough
    // to seat the screw heads / spread load. Stops short of the board plane.
    foot_h = 2.5;                         // foot slab thickness (Z)
    post_h = z_top - z0;                  // M2.5 post height (= M2_POST_H = 5)

    // ---- 2x M3 clearance holes on the nearest 15mm grid points ----------
    // Grid points: X = GRID_X0 + n*GRID_PITCH, Y = GRID_Y0 + m*GRID_PITCH.
    // Pick the two grid columns straddling the post X, on the grid row
    // nearest the post Y, so both screws land on REAL grid bosses 15mm apart.
    gx_lo = GRID_X0 + GRID_PITCH * floor((cx - GRID_X0) / GRID_PITCH); // 147.5
    gx_hi = gx_lo + GRID_PITCH;                                        // 162.5
    gy    = GRID_Y0 + GRID_PITCH * round((cy - GRID_Y0) / GRID_PITCH); // 132.5
    bolt_pts = [ [gx_lo, gy], [gx_hi, gy] ];   // 2x M3 clearance // MEASURE

    // Foot footprint: the contract's nominal M2_FOOT is [16,16], but two
    // grid bolts sit 15mm apart (GRID_PITCH), so a strict 16mm foot leaves no
    // wall around the outer hole. Size the foot to ENVELOPE both holes plus an
    // M3 edge margin (X), keep the nominal depth (Y), and center it on the
    // bolt span / row. The post stays exactly on M2_RETAINER_POS so it still
    // mates with the board's M.2 hole. Two largest axes stay << 190 (bed OK).
    hole_margin = M3_CLEAR/2 + 2.5;       // wall around an M3 clearance hole
    fw_used = max(fw, (gx_hi - gx_lo) + 2*hole_margin);  // ~19.9mm in X
    fd_used = fd;                                         // 16mm in Y (nominal)
    fcx = (gx_lo + gx_hi) / 2;             // foot center X = bolt-span midpoint
    fcy = gy;                              // foot center Y = bolt row
    fx0 = fcx - fw_used/2;                 // foot X0
    fy0 = fcy - fd_used/2;                 // foot Y0

    difference() {
        union() {
            // ---- foot slab (flat-bottom on floor top) -------------------
            translate([fx0, fy0, z0])
                cube([fw_used, fd_used, foot_h]);

            // ---- M2.5 post (heat-set boss, bore opens upward) -----------
            // m25_standoff bases at Z=0 with an upward bore + base fillet;
            // lift it to the foot base so it spans z0..z_top.
            translate([cx, cy, z0])
                m25_standoff(post_h, M25_BOSS_OD, M25_INSERT_BORE,
                             M25_INSERT_DEPTH, fillet = 1.5, EPS);

            // ---- 4 diagonal gussets bracing the post (print-flat) -------
            // Each gusset is a right-triangle web rooted on the post wall and
            // ramping down to the foot top; its only downward face is the flat
            // bottom on the foot, so it prints with zero support. The reach is
            // bounded by the nearest foot edge from the (off-center) post.
            gus_t   = 2;                          // gusset web thickness
            gus_run = min(fcx - fx0, fx0 + fw_used - fcx,
                          fcy - fy0, fy0 + fd_used - fcy) - M25_BOSS_OD/2 - 1;
            for (a = [0, 90, 180, 270])
                translate([cx, cy, z0 + foot_h - EPS])
                    rotate([0, 0, a])
                        gusset(M25_BOSS_OD/2, gus_run, post_h - foot_h + EPS, gus_t);
        }

        // ---- 2x M3 clearance through-holes ------------------------------
        for (p = bolt_pts)
            translate([p[0], p[1], z0 - EPS])
                cylinder(h = foot_h + 2*EPS, d = M3_CLEAR);
    }
}

// Right-triangle gusset web in the X-Z plane: stands on the foot top (its
// own Z=0), rooted at the post wall (local X = inner), extends outward +X by
// `run`, rises +Z by `rise`. The hypotenuse runs from the outer foot corner
// up to the post-wall apex, so its overhang face is <=45deg when run>=rise
// (printable, zero support). Web thickness `t` centered on the Y axis.
module gusset(inner, run, rise, t) {
    // build the triangle in X-Z (polygon is X-Y), then stand it up about X.
    translate([0, -t/2, 0])
        rotate([90, 0, 0])                // X-Y polygon -> X-Z web plane
            linear_extrude(height = t)
                polygon(points = [
                    [inner,        0],     // root at post wall, on the foot
                    [inner + run,  0],     // outer reach, on the foot
                    [inner,        rise]   // apex up the post wall
                ]);
}

// standalone render
m2_retainer();
