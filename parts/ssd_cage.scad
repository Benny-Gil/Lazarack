// =====================================================================
// parts/ssd_cage.scad  ->  ssd_cage()   (OPTIONAL part #8)
//
// 2.5" SATA SSD/HDD tray for a JEITA-standard drive (SSD_L x SSD_W x SSD_H
// = 100 x 70 x 7mm). It bolts onto the common 15mm M3 heat-set grid on the
// baseplate, BESIDE the motherboard, so a boot/data SSD can ride inside the
// chassis. The drive drops into the tray flat-side-down and is retained by
// 4x M3 screws through the two long side walls into the drive's standard
// 2.5" side mounting holes.
//
// FROZEN CONTRACT — modeled in the GLOBAL ASSEMBLY FRAME:
//   Origin (0,0,0) = front-bottom-left interior corner of the chassis body.
//   +X width, +Y depth, +Z height (floor 0..FLOOR=3).
// main.scad unions this module with NO transform, so it is PRE-PLACED here
// at SSD_CAGE_POS=[12,150] and rests on the baseplate floor top (Z=FLOOR).
// Assembly region: ~105 x 75 x 16 (X,Y,Z).  Long axis of the drive runs in
// +Y (depth), so the 100mm drive length stays well clear of the board edge.
//
// Mounting / seams (from params.scad + contract):
//   - 4x M3 CLEARANCE feet through the tray floor land on the nearest 15mm
//     grid points so M3 screws pass DOWN into the baseplate grid inserts.
//     The cage itself takes NO inserts -> clearance holes only.
//   - SSD held by 4x M3 CLEARANCE holes through the side walls into the
//     drive's standard 2.5" side holes (positions are // MEASURE in params).
//
// Printability: flat largest-face-down (tray floor on the bed), no overhang
// >45deg (wall tops chamfered, drive-entry mouth chamfered), every vertical
// bore is a simple through-hole (no bridging over a blind insert), side
// retention holes are small horizontal bores that self-bridge in PETG.
// All // MEASURE values live ONLY in params.scad.
// =====================================================================

include <params.scad>
use <../lib/joinery.scad>

module ssd_cage() {
    // ---- resolved placement (assembly frame) ----------------------------
    ox    = SSD_CAGE_POS[0];      // cage origin X (~12)  // MEASURE
    oy    = SSD_CAGE_POS[1];      // cage origin Y (~150) // MEASURE
    z0    = FLOOR;                // tray floor bottom sits on the baseplate top (Z=3)

    // Drive footprint (JEITA 2.5"): length in +Y, width in +X.
    drv_l = SSD_L;                // 100 (Y, drive length)
    drv_w = SSD_W;               //  70 (X, drive width)
    drv_h = SSD_H;               //   7 (Z, drive height)

    // ---- tray geometry --------------------------------------------------
    floor_t  = 3;                 // tray floor thickness (Z)
    wall_t   = 2.4;               // side-wall thickness (X), 6 perimeters @0.4
    clr      = 0.6;               // drive-to-wall slip clearance (per side, X & Y)
    wall_h   = drv_h + 2;         // side-wall height above floor top (Z), 9mm
    chamf    = 1.2;               // top-edge + mouth chamfer (no >45deg overhang)

    // Inner pocket the drive drops into (drive + clearance on all sides).
    pocket_w = drv_w + 2*clr;     // X inner
    pocket_l = drv_l + 2*clr;     // Y inner

    // Outer tray shell footprint.
    outer_w  = pocket_w + 2*wall_t;   // X total (~76mm  -> well under 190)
    outer_l  = pocket_l + 2*wall_t;   // Y total (~106mm -> well under 190)

    // Tray inner-pocket corner (assembly frame): drive bottom rests on floor top.
    px0 = ox + wall_t;            // pocket X0
    py0 = oy + wall_t;            // pocket Y0
    pz0 = z0 + floor_t;           // pocket floor top Z (drive underside)

    // Tray outer corner (assembly frame).
    sx0 = ox;                     // shell X0
    sy0 = oy;                     // shell Y0
    sz0 = z0;                     // shell Z0 (on baseplate top)
    sz1 = z0 + floor_t + wall_h;  // shell top Z (~15mm above floor -> ~18 abs)

    // Drive center (assembly frame) for the side retention holes.
    drv_cx = px0 + pocket_w/2;    // = drive center X
    drv_y0 = py0 + clr;           // drive front face Y (inside pocket)

    // ---- 4x M3 floor feet: nearest 15mm grid points ---------------------
    // The tray must bolt to REAL grid bosses. Pick the two grid columns and
    // two grid rows that fall INSIDE the floor footprint with an M3 edge
    // margin, straddling the tray center, so all 4 screws land on the grid.
    foot_margin = M3_CLEAR/2 + 2.0;                  // wall around an M3 hole
    cx_mid = sx0 + outer_w/2;                         // tray center X
    cy_mid = sy0 + outer_l/2;                         // tray center Y
    // grid column straddle around tray center X
    gx_lo = GRID_X0 + GRID_PITCH * floor((cx_mid - GRID_X0)/GRID_PITCH);
    gx_hi = gx_lo + GRID_PITCH;
    // grid rows straddle around tray center Y (use a wider span for stability)
    gy_lo = GRID_Y0 + GRID_PITCH * floor((cy_mid - GRID_Y0)/GRID_PITCH - 1);
    gy_hi = GRID_Y0 + GRID_PITCH * ceil ((cy_mid - GRID_Y0)/GRID_PITCH + 1);
    foot_pts = [ [gx_lo, gy_lo], [gx_hi, gy_lo],
                 [gx_lo, gy_hi], [gx_hi, gy_hi] ];   // 4x M3 clearance // MEASURE

    // ---- 4x M3 side retention holes (drive's standard 2.5" side holes) ---
    // JEITA 2.5": side mounting holes lie on the drive's long sides, axis
    // along the drive WIDTH (here = +X). Standard set is 4 holes, 2 per side,
    // at a longitudinal spacing along the drive length and a fixed height of
    // ~3.0mm above the drive bottom. All positions below are // MEASURE.
    side_hole_z   = pz0 + 3.0;                    // 3.0mm above drive bottom // MEASURE
    // longitudinal (Y) hole centers along the drive, from the drive front:
    side_y_near   = drv_y0 + 14.0;                // // MEASURE
    side_y_far    = drv_y0 + 90.6;                // // MEASURE (JEITA span ~76.6)
    side_ys       = [ side_y_near, side_y_far ];

    difference() {
        union() {
            // ---- tray shell: floor + two long side walls ----------------
            // (Open front/rear ends ease drive insertion and let the SATA
            //  connector breathe; the two long walls carry the retention
            //  screws and brace the drive.)
            // floor slab
            translate([sx0, sy0, sz0])
                cube([outer_w, outer_l, floor_t]);

            // left + right side walls (full tray length in Y)
            for (wx = [ sx0, sx0 + outer_w - wall_t ])
                translate([wx, sy0, sz0])
                    cube([wall_t, outer_l, floor_t + wall_h]);
        }

        // ---- top-edge chamfers on the side walls (no >45deg overhang on
        //      the outer top corners; cosmetic + deburring) ----------------
        for (s = [0, 1]) {
            wx = (s == 0) ? sx0 : sx0 + outer_w;     // outer wall face X
            sgn = (s == 0) ? 1 : -1;                  // cut toward inside
            translate([wx, sy0 - EPS, sz1])
                rotate([0, 45, 0])
                    translate([0, 0, 0])
                        cube([chamf*1.6, outer_l + 2*EPS, chamf*1.6]);
        }

        // ---- drive-entry mouth chamfer at the wall inner-top edges -------
        // 45deg lead-in on the inner-top of each side wall so the drive
        // slides in; printed face stays <=45deg (overhang ramps inward+down).
        for (s = [0, 1]) {
            ix = (s == 0) ? px0 : px0 + pocket_w;    // inner wall face X
            translate([ix, sy0 - EPS, sz1])
                rotate([0, 45, 0])
                    cube([chamf*1.6, outer_l + 2*EPS, chamf*1.6], center = false);
        }

        // ---- 4x M3 floor feet (clearance, axis +Z, through floor) -------
        // Counterbored from the TOP so the screw head sits flush-ish and does
        // not foul the drive; counterbore is shallow and OPENS UPWARD (the
        // through-hole is fully open below it -> no bridging).
        for (p = foot_pts) {
            // through clearance hole
            translate([p[0], p[1], sz0 - EPS])
                cylinder(h = floor_t + 2*EPS, d = M3_CLEAR);
            // shallow head counterbore from the floor top (opens up)
            translate([p[0], p[1], sz0 + floor_t - 1.2])
                cylinder(h = 1.2 + EPS, d = M3_HEAD_D);
        }

        // ---- 4x M3 side retention holes (axis +X, through both walls) ----
        for (sy = side_ys) {
            // left wall hole
            translate([sx0 - EPS, sy, side_hole_z])
                rotate([0, 90, 0])
                    cylinder(h = wall_t + 2*EPS, d = M3_CLEAR);
            // right wall hole
            translate([sx0 + outer_w - wall_t - EPS, sy, side_hole_z])
                rotate([0, 90, 0])
                    cylinder(h = wall_t + 2*EPS, d = M3_CLEAR);
        }

        // ---- floor lightening / airflow + cable-relief slot -------------
        // A central longitudinal slot under the drive saves plastic and lets
        // SATA cabling pass; kept inboard of all 4 feet so it never breaks a
        // bolt land. Rounded ends (hull of two cylinders) -> clean manifold.
        slot_w  = 12;                                  // slot width (X)
        slot_y0 = py0 + 18;                            // start inboard of feet
        slot_y1 = py0 + pocket_l - 18;                 // end inboard of feet
        translate([0, 0, sz0 - EPS])
            linear_extrude(height = floor_t + 2*EPS)
                hull() {
                    translate([cx_mid, slot_y0]) circle(d = slot_w);
                    translate([cx_mid, slot_y1]) circle(d = slot_w);
                }
    }
}

// standalone render
ssd_cage();
