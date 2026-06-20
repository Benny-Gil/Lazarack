// =====================================================================
// parts/m25_grid_insert.scad  ->  m25_grid_insert()
//
// TOLERANCE-FIRST board standoff. Instead of fixed standoff bosses at exact
// (and poorly-known) board-hole positions, the board rests on these small
// PRINTED standoffs that drop into ANY point of the baseplate's 15mm M3
// self-tap pilot grid. Because the grid is on a 15mm lattice, every real
// board hole lands within ±7.5mm of a grid point -> no exact measurement
// needed; place a standoff at the nearest grid point to each board hole.
//
//   - A locating PEG on the bottom drops into a grid pilot hole (GRID_PILOT_D).
//   - The board's own M2.5 screw self-taps into the bore on top, pulling the
//     board down onto the standoff.
//   - Print a handful (4-5) flat on the bed, zero supports.
//
// Height = STANDOFF_H so the board sits at BOARD_Z = FLOOR + STANDOFF_H.
// =====================================================================

include <params.scad>

module m25_grid_insert(h = STANDOFF_H) {
    peg_h    = 2.5;                      // locating peg length into the grid pilot
    od       = M25_BOSS_OD + 1.0;        // standoff body OD (~7mm)
    floor_t  = 1.5;                      // solid floor under the bore (keeps peg attached)
    bore_d   = max(0, h - floor_t);      // blind M2.5 bore depth from the top
    difference() {
        union() {
            // standoff body
            cylinder(h = h, d = od);
            // bottom locating peg (loose fit into a grid pilot, per FIT_CLEARANCE)
            translate([0, 0, -peg_h])
                cylinder(h = peg_h + EPS, d = GRID_PILOT_D - FIT_CLEARANCE);
        }
        // BLIND M2.5 self-tap bore on top (leaves floor_t solid bottom -> peg stays attached)
        translate([0, 0, floor_t])
            cylinder(h = bore_d + EPS, d = M25_PILOT);
        // lead-in chamfer at the bore mouth (forgiving start for the screw)
        translate([0, 0, h - CHAMFER])
            cylinder(h = CHAMFER + EPS, d1 = M25_PILOT, d2 = M25_PILOT + 2*CHAMFER);
    }
}

// ---- standalone render ----
$fa = 2; $fs = 0.3;
m25_grid_insert();
