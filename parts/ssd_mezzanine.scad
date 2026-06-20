// =====================================================================
// parts/ssd_mezzanine.scad  ->  ssd_mezzanine()
//
// 2.5" SATA SSD tray carried ON STILTS ABOVE the motherboard. A 1U chassis
// has ~27mm of clear air over the board (the tallest board part is only
// ~8.9mm), so a JEITA 100x70x7mm drive fits comfortably in that dead space.
// This part exploits it: a flat tray holds the SSD on 4 tall legs whose feet
// bolt straight DOWN into the baseplate's 15mm M3 self-tap pilot grid, while
// the drive itself floats above the board with clearance.
//
// FROZEN CONTRACT — modeled in the GLOBAL ASSEMBLY FRAME:
//   Origin (0,0,0) = front-bottom-left interior corner of the chassis body.
//   +X width, +Y depth, +Z height (floor 0..FLOOR=3).
// main.scad unions this module with NO transform. It is PRE-PLACED here over
// a LOW area near the FRONT-LEFT of the board, offset so the tray CLEARS the
// blower intake. Feet sit at Z=FLOOR; tray top lands near Z=FLOOR+18.
//
// Mounting / seams (from params.scad + contract):
//   - 4x legs ~17mm tall. Each foot has an M3 CLEARANCE hole that lands on a
//     real 15mm grid point; an M3 screw passes DOWN into the GRID_PILOT
//     (self-tap into the floor) OR uses an M3 clearance into a grid insert.
//   - Tray holds the drive flat. The drive is retained by 4x M3 CLEARANCE
//     holes through the tray's two long side rails into the drive's standard
//     2.5" side mounting holes (JEITA 100/70 spacing). Side holes axis +X.
//   - The cage takes NO heat-set inserts -> clearance/self-tap only.
//
// Printability / orientation:
//   - The tray (rails + floor + foot pads) prints FLAT, largest face down.
//     Its two bed-plane axes are ~104 x 74  (both << PRINT_MAX_XY 190).
//   - The 4 tall legs are slender; print them AS PART OF the tray standing up
//     is a tall thin overhang risk, so the recommended orientation is to
//     print the tray flat and the LEGS LAID FLAT beside it (each leg's tab
//     face on the bed), then bolt the feet to the grid at assembly. Legs are
//     modeled here in their MOUNTED (vertical) pose for the assembly view.
//   - No bore bridges over a blind feature; every hole is a clean through-hole.
// All // MEASURE values live ONLY in params.scad.
// =====================================================================

include <params.scad>

// ---------------------------------------------------------------------
// MEASURE-style placement constant: where the tray sits in XY (assembly
// frame). Front-left of the board, offset to clear the blower intake which
// sits toward board center. Tray spans +X / +Y from this origin.
// ---------------------------------------------------------------------
SSD_MEZ_POS   = [12, 18];   // MEASURE tray origin [x,y], front-left, clears blower
SSD_MEZ_LEG_H = 17;         // MEASURE leg height (16-18mm); tray top ~ FLOOR+18

module ssd_mezzanine() {
    // ---- resolved placement (assembly frame) ----------------------------
    ox    = SSD_MEZ_POS[0];        // tray origin X  // MEASURE
    oy    = SSD_MEZ_POS[1];        // tray origin Y  // MEASURE
    leg_h = SSD_MEZ_LEG_H;         // leg height (Z)

    // Drive footprint (JEITA 2.5"): length in +Y, width in +X.
    drv_l = SSD_L;                 // 100 (Y, drive length)
    drv_w = SSD_W;                 //  70 (X, drive width)

    // ---- tray geometry --------------------------------------------------
    floor_t = 2.4;                 // tray floor thickness (Z), 12 layers @0.2
    rail_t  = 3.0;                 // long side-rail thickness (X)
    rail_h  = 6.0;                 // rail height above tray floor top (Z)
    clr     = 0.6;                 // drive slip clearance per side (X & Y)
    chamf   = 1.0;                 // lead-in / top-edge chamfer (<=45deg)

    // Inner pocket (drive + clearance).
    pocket_w = drv_w + 2*clr;      // X inner
    pocket_l = drv_l + 2*clr;      // Y inner

    // Outer tray shell footprint (~104 x 74 -> both << 190, prints flat).
    outer_w  = pocket_w + 2*rail_t;    // X total (~77mm)
    outer_l  = pocket_l + 2*rail_t;    // Y total (~107mm)
    // NOTE: outer_l ~107, outer_w ~77 -> two largest bed-plane axes <=190. OK.

    // Tray Z datum: feet bottoms at Z=FLOOR, tray floor sits at top of legs.
    sz0   = FLOOR;                 // foot bottom Z (on baseplate top)
    tz0   = sz0 + leg_h;           // tray floor BOTTOM Z (= FLOOR + 17 = 20)
    tz1   = tz0 + floor_t;         // tray floor TOP Z (drive underside ~22)
    rz1   = tz1 + rail_h;          // rail top Z (~28, still inside 1U interior)

    // Shell corner (assembly frame).
    sx0 = ox;
    sy0 = oy;

    // Drive origin inside the pocket (drive bottom rests on tray floor top).
    px0 = sx0 + rail_t;            // pocket X0
    py0 = sy0 + rail_t;            // pocket Y0
    drv_x0 = px0 + clr;            // drive left face X
    drv_y0 = py0 + clr;            // drive front face Y

    // ---- 4x leg foot positions: nearest 15mm grid points ----------------
    // Pick grid columns/rows that fall inside the tray footprint with an M3
    // edge margin, straddling the tray center, so all 4 feet land on the grid.
    cx_mid = sx0 + outer_w/2;
    cy_mid = sy0 + outer_l/2;
    gx_lo = GRID_X0 + GRID_PITCH * floor((cx_mid - GRID_X0)/GRID_PITCH);
    gx_hi = gx_lo + GRID_PITCH;
    // wider Y straddle for tip stability of the tall tray
    gy_lo = GRID_Y0 + GRID_PITCH * floor((cy_mid - GRID_Y0)/GRID_PITCH - 1);
    gy_hi = GRID_Y0 + GRID_PITCH * ceil ((cy_mid - GRID_Y0)/GRID_PITCH + 1);
    foot_pts = [ [gx_lo, gy_lo], [gx_hi, gy_lo],
                 [gx_lo, gy_hi], [gx_hi, gy_hi] ];   // 4x M3 clearance // MEASURE

    // Leg cross-section (square post) and foot pad.
    leg_w   = 7.0;                 // leg post side (X & Y)
    foot_w  = 12.0;                // foot pad side (X & Y) — wide bolt land
    foot_t  = 3.0;                 // foot pad thickness (Z)

    // ---- 4x M3 side retention holes (drive's standard 2.5" side holes) ---
    // JEITA 2.5": 4 side holes, 2 per long side, axis along drive WIDTH (+X),
    // ~3.0mm above the drive bottom, longitudinal span ~76.6mm. // MEASURE.
    side_hole_z = tz1 + 3.0;                  // 3.0mm above drive bottom // MEASURE
    side_y_near = drv_y0 + 14.0;              // // MEASURE
    side_y_far  = drv_y0 + 90.6;              // // MEASURE (JEITA span ~76.6)
    side_ys     = [ side_y_near, side_y_far ];

    difference() {
        union() {
            // ---- 4 tall legs + foot pads (mounted/vertical pose) --------
            for (p = foot_pts) {
                // foot pad on the baseplate (bolts into grid)
                translate([p[0] - foot_w/2, p[1] - foot_w/2, sz0])
                    cube([foot_w, foot_w, foot_t]);
                // leg post rising INTO the tray floor (overlap -> one solid)
                translate([p[0] - leg_w/2, p[1] - leg_w/2, sz0])
                    cube([leg_w, leg_w, leg_h + floor_t]);
            }

            // ---- tray floor slab (drive sits flat on top) ----------------
            translate([sx0, sy0, tz0])
                cube([outer_w, outer_l, floor_t]);

            // ---- two long side rails (carry the drive side screws) -------
            for (rx = [ sx0, sx0 + outer_w - rail_t ])
                translate([rx, sy0, tz0])
                    cube([rail_t, outer_l, floor_t + rail_h]);
        }

        // ---- M3 clearance up through each foot (axis +Z) -----------------
        // The mount screw enters from the FOOT BOTTOM and self-taps DOWN into
        // the grid pilot below. The clearance bore runs up through the foot
        // and into the leg but STOPS short of the tray floor (leg stays joined
        // to the tray -> one solid). A counterbore at the foot BOTTOM recesses
        // the M3 cap head flush with the baseplate (opens DOWN -> no bridging).
        bore_h = foot_t + leg_h - 3.0;             // stop ~3mm below tray floor
        for (p = foot_pts) {
            translate([p[0], p[1], sz0 - EPS])
                cylinder(h = bore_h + EPS, d = M3_CLEAR);
            translate([p[0], p[1], sz0 - EPS])
                cylinder(h = 1.6 + EPS, d = M3_HEAD_D);
        }

        // ---- 4x M3 side retention holes (axis +X, through both rails) ----
        for (sy = side_ys) {
            // left rail
            translate([sx0 - EPS, sy, side_hole_z])
                rotate([0, 90, 0])
                    cylinder(h = rail_t + 2*EPS, d = M3_CLEAR);
            // right rail
            translate([sx0 + outer_w - rail_t - EPS, sy, side_hole_z])
                rotate([0, 90, 0])
                    cylinder(h = rail_t + 2*EPS, d = M3_CLEAR);
        }

        // ---- top-edge chamfer on the side rails (<=45deg, deburr) --------
        for (s = [0, 1]) {
            rx = (s == 0) ? sx0 : sx0 + outer_w;     // outer rail face X
            translate([rx, sy0 - EPS, rz1])
                rotate([0, 45, 0])
                    cube([chamf*1.6, outer_l + 2*EPS, chamf*1.6]);
        }

        // ---- drive-entry mouth chamfer on the inner-top of each rail -----
        for (s = [0, 1]) {
            ix = (s == 0) ? px0 : px0 + pocket_w;    // inner rail face X
            translate([ix, sy0 - EPS, rz1])
                rotate([0, 45, 0])
                    cube([chamf*1.6, outer_l + 2*EPS, chamf*1.6], center = false);
        }

        // ---- floor lightening + airflow windows under the drive ----------
        // Saves plastic and lets warm air rise off the board through the tray.
        // Two windows sit in the Y-GAP BETWEEN the leg rows (gy_lo..gy_hi) so
        // they NEVER undercut a leg/foot land -> the floor stays solid over
        // every leg and the tray remains ONE connected solid.
        win_w  = pocket_w - 20;                   // X window width (inboard of rails)
        win_cx = px0 + pocket_w/2;                // window center X (clear of rails)
        // central window, fully between the two leg rows
        win_a0 = gy_lo + leg_w/2 + 4;             // start just past the near legs
        win_a1 = gy_hi - leg_w/2 - 4;             // end just before the far legs
        translate([0, 0, tz0 - EPS])
            linear_extrude(height = floor_t + 2*EPS)
                hull() {
                    translate([win_cx, win_a0]) circle(d = win_w);
                    translate([win_cx, win_a1]) circle(d = win_w);
                }
    }
}

// ---- standalone render ----
ssd_mezzanine();
