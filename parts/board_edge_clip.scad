// =====================================================================
// parts/board_edge_clip.scad  ->  board_edge_clip()
//
// TOLERANCE-FIRST failsafe board retention. Bolts to a baseplate grid point
// and a finger reaches over the board's EDGE to clamp it down from above --
// so the board is held flat even if NONE of its mounting holes line up with
// the grid. Use ~4 (one per side/corner).
//
// The mount hole is SLOTTED (along Y) so you slide the clip in/out to press
// the board edge with light force before tightening -- forgiving of where the
// board edge actually sits (poor measurement) and of a loose printer.
//
// Modeled in its own local frame: foot at the origin, finger reaching +Y over
// the board edge. main.scad places/rotates one at each board edge. Prints flat
// on the bed (foot down), zero supports.
//
//   foot top (and finger underside) sit at the board top plane so the finger
//   lightly traps the PCB: BOARD_TOP = STANDOFF_H + BOARD_T above the floor.
// =====================================================================

include <params.scad>

module board_edge_clip(reach = 14) {
    foot_w   = 16;                         // foot width (X), spans a grid cell
    foot_d   = 16;                         // foot depth (Y)
    board_top = STANDOFF_H + BOARD_T;      // finger underside height above floor
    foot_h   = board_top + 2.5;            // foot rises a bit above the finger
    fing_t   = 2.5;                        // finger thickness (Z)
    slot_len = 7;                          // M3 slot travel (Y) for in/out adjust

    difference() {
        union() {
            // foot block (bolts to the grid)
            cube([foot_w, foot_d, foot_h]);
            // cantilever finger reaching over the board edge (+Y) at board-top
            // plane, so its underside lightly traps the PCB. A 45° gusset under
            // the root keeps the cantilever stiff and support-free.
            translate([0, foot_d - EPS, board_top])
                cube([foot_w, reach, fing_t]);
            // FULL-height 45° gusset: its vertical face fuses to the foot and
            // its top face meets the finger underside at board_top, so it
            // actually braces the cantilever AND self-supports the finger in
            // print (the old 3mm gusset stopped board_top-3 below the finger).
            translate([0, foot_d - EPS, board_top])
                rotate([0, 90, 0])
                    linear_extrude(foot_w)
                        polygon([[0,0],[board_top,0],[0,board_top]]);
        }
        // slotted M3 clearance hole through the foot, into the grid pilot below.
        // Slot runs in Y so the clip slides in/out before tightening.
        translate([foot_w/2, foot_d/2 - slot_len/2, -EPS])
            hull() {
                cylinder(h = foot_h + 2*EPS, d = M3_CLEAR);
                translate([0, slot_len, 0]) cylinder(h = foot_h + 2*EPS, d = M3_CLEAR);
            }
        // counterbore so the M3 head sits below the foot top (clears the board)
        translate([foot_w/2, foot_d/2 - slot_len/2, foot_h - 3])
            hull() {
                cylinder(h = 3 + EPS, d = M3_HEAD_D);
                translate([0, slot_len, 0]) cylinder(h = 3 + EPS, d = M3_HEAD_D);
            }
    }
}

// ---- standalone render ----
$fa = 2; $fs = 0.3;
board_edge_clip();
