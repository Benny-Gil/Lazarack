// =====================================================================
// parts/io_subplate.scad  ->  io_subplate()
//
// Swappable front-I/O insert that drops into the recessed faceplate window
// (parts faceplate_left + faceplate_right). Modeled IN the shared assembly
// frame so it mates with the faceplate with NO transform in main.scad.
//
// Contract placement (io_subplate):
//   local 120 x 70 x 3  (IO_SUB_W x IO_SUB_H x IO_SUB_T)
//   seated in the faceplate window IO_WIN_X0=35 => assembly X 35..155,
//   bottom at IO_WIN_Z0=20 => assembly Z 20..90, recessed in Y at the
//   faceplate face (faceplate at Y -FACE_T..0; subplate sits Y -IO_SUB_T..0).
//   4x M3 clearance mounts (IO_SUB_M3, axis +Y) into faceplate inserts.
//   Cutouts (LOCAL coords, // MEASURE in params): HDMI, USB-A x2,
//   louvered EXHAUST grille. IO_VARIANT=="rj45" adds a front RJ45 cutout.
//
// LOCAL cutout frame: each cutout [x,z] is referenced from the subplate's
//   lower-left corner (assembly X=IO_WIN_X0, Z=IO_WIN_Z0). This module maps
//   local -> assembly so params can be edited directly against calipers.
//
// Printability: prints FLAT, largest face (120 x 70) on the bed (lay the Y
//   axis vertical at slice time). 3mm thick. M3 bores are CLEARANCE holes
//   (no heat-set, so no upward-bridging concern). Cutouts are clean through
//   differences. Louver slats tilt for a no-support overhang. <=190 in its
//   two largest axes (120 x 70).  EPS overlaps keep it 2-manifold.
// =====================================================================

include <params.scad>
use <../lib/joinery.scad>

module io_subplate() {
    // assembly-frame anchor of the subplate's LOCAL (0,0) corner:
    ax = IO_WIN_X0;        // = 35   (subplate left edge in X)
    az = IO_WIN_Z0;        // = 20   (subplate bottom edge in Z)
    ay = -IO_SUB_T;        // outer face flush with faceplate face plane Y=0;
                           //   plate occupies Y -IO_SUB_T..0 (recessed in window)

    // --- helper: place a LOCAL [x,z] cutout into the assembly frame ---
    //   a rectangular through-window of size [sx (X), sz (Z)] centered on
    //   local [cx, cz], bored through the full Y thickness (+ eps each side).
    module rect_window(cx, cz, sx, sz) {
        translate([ax + cx, ay - EPS, az + cz])
            cube([sx, IO_SUB_T + 2*EPS, sz], center = false);
    }
    // centered variant (pos is the CENTER of the opening, like params define)
    module rect_window_c(pos, size) {
        translate([ax + pos[0] - size[0]/2,
                   ay - EPS,
                   az + pos[1] - size[1]/2])
            cube([size[0], IO_SUB_T + 2*EPS, size[1]], center = false);
    }
    module round_window_c(pos, dia) {
        translate([ax + pos[0], ay - EPS, az + pos[1]])
            rotate([-90, 0, 0])
                cylinder(h = IO_SUB_T + 2*EPS, d = dia);
    }

    difference() {
        // ---- solid plate (the swappable insert body) ----
        translate([ax, ay, az])
            cube([IO_SUB_W, IO_SUB_T, IO_SUB_H], center = false);

        // ---- 4x M3 clearance mount holes (axis +Y), LOCAL IO_SUB_M3 ----
        for (p = IO_SUB_M3)
            translate([ax + p[0], ay - EPS, az + p[1]])
                rotate([-90, 0, 0])
                    cylinder(h = IO_SUB_T + 2*EPS, d = M3_CLEAR);

        // Port cutouts only for the measured variants. The tolerance default
        // "blank" leaves a SOLID insert the user drills once the real port
        // positions are calipered, then reprints just this cheap part.
        if (IO_VARIANT != "blank") {
            // ---- HDMI-A port window ----
            rect_window_c(HDMI_POS, HDMI_SIZE);
            // ---- USB-A x2 (stacked: same size, two centers) ----
            rect_window_c(USBA_POS_1, USBA_SIZE);
            rect_window_c(USBA_POS_2, USBA_SIZE);
            // ---- louvered blower EXHAUST grille ----
            translate([ax + EXHAUST_POS[0] - EXHAUST_SIZE[0]/2,
                       ay,
                       az + EXHAUST_POS[1] - EXHAUST_SIZE[1]/2])
                louver_grille(EXHAUST_SIZE[0], EXHAUST_SIZE[1], IO_SUB_T,
                              n = 6, slat = 3, angle = 30, eps = EPS);
            // ---- front RJ45 (only in the "rj45" variant) ----
            if (IO_VARIANT == "rj45")
                rect_window_c(RJ45_POS, RJ45_SIZE);
        }
    }
}

// standalone render
io_subplate();
