// =====================================================================
// main.scad  —  TOP-LEVEL ASSEMBLY
// Project: Dell Inspiron 15-5558/5559 motherboard -> NiH DIY 10" rack
// Printables #1634385 cage-nut rack. Printer: Ender 3 V3 SE. Material: PETG.
//
// Every part is modeled in the SHARED ASSEMBLY COORDINATE FRAME defined in
// parts/params.scad, so main_assembly() simply unions the 9 printed-part
// modules with NO transforms. The EXPLODE variable pulls the panels apart
// for an exploded inspection view; it does NOT change the printed geometry.
//
//   View:        open this file in OpenSCAD  (renders main_assembly()).
//   Export STL:  openscad -o output.stl main.scad
//   Export part: openscad -o part.stl parts/baseplate_front.scad
// =====================================================================

// Global resolution (set ONLY here, never per-part).
$fa = 1;
$fs = 0.4;

include <parts/params.scad>

// --- The 9 printed parts (each pre-placed in the assembly frame) ---
use <parts/baseplate_front.scad>   // baseplate_front()
use <parts/baseplate_rear.scad>    // baseplate_rear()
use <parts/faceplate_left.scad>    // faceplate_left()
use <parts/faceplate_right.scad>   // faceplate_right()
use <parts/io_subplate.scad>       // io_subplate()
use <parts/m2_retainer.scad>       // m2_retainer()
use <parts/rear_panel.scad>        // rear_panel()
use <parts/ssd_cage.scad>          // ssd_cage()        (optional)
use <parts/lid.scad>               // lid_front(), lid_rear()  (optional)


// ---------------------------------------------------------------------
// VIEW TOGGLES
// ---------------------------------------------------------------------
SHOW_SSD   = true;   // include the optional 2.5" SSD cage
SHOW_LID   = true;   // include the optional vented 2U lid (two tiles)
SHOW_BOARD = true;   // faint %ghost of the motherboard for reference

// EXPLODE: 0 = assembled. >0 (mm) separates modules along their mating
// axes for an exploded view. Try EXPLODE = 40.
EXPLODE = 0;


module main_assembly() {

    // --- Structural body: two baseplate tiles + integral walls ---
    // Front tile pulls -Y, rear tile pulls +Y when exploded (split the lap).
    color("SteelBlue", 0.85)
        translate([0, -EXPLODE, 0])
            baseplate_front();

    color("SteelBlue", 0.85)
        translate([0, EXPLODE, 0])
            baseplate_rear();

    // --- Faceplate (two tiles), in front of the body. Explodes -Y. ---
    color("Silver", 0.95)
        translate([0, -2 * EXPLODE, 0])
            faceplate_left();

    color("Silver", 0.95)
        translate([0, -2 * EXPLODE, 0])
            faceplate_right();

    // --- Swappable front I/O subplate, recessed into the faceplate window.
    //     Explodes further -Y than the faceplate so it clears the window. ---
    color("DarkSlateGray", 0.95)
        translate([0, -3 * EXPLODE, 0])
            io_subplate();

    // --- Rear I/O panel, behind the body. Explodes +Y. ---
    color("SlateGray", 0.95)
        translate([0, 2 * EXPLODE, 0])
            rear_panel();

    // --- M.2 retainer post (supplies the missing standoff). Sits on rear
    //     tile grid, so it follows the rear tile +Y when exploded. ---
    color("Goldenrod", 0.95)
        translate([0, EXPLODE, 0])
            m2_retainer();

    // --- Optional 2.5" SSD cage, beside the board on the front-tile grid. ---
    if (SHOW_SSD)
        color("DimGray", 0.95)
            translate([0, -EXPLODE, 0])
                ssd_cage();

    // --- Optional vented 2U lid (two tiles) on the wall-tops. Explodes +Z;
    //     the two tiles also separate along Y like the baseplate lap. ---
    if (SHOW_LID) {
        color("Gainsboro", 0.9)
            translate([0, -EXPLODE, 3 * EXPLODE])
                lid_front();

        color("Gainsboro", 0.9)
            translate([0, EXPLODE, 3 * EXPLODE])
                lid_rear();
    }

    // --- Faint ghost of the motherboard for spatial reference ---
    if (SHOW_BOARD)
        %_board_ghost();
}


// Faint reference board: 170(X) x 235(Y) x 2mm, on the standoff plane.
module _board_ghost() {
    color("DodgerBlue", 0.20)
        translate([BOARD_X0, BOARD_Y0, BOARD_Z])
            cube([BOARD_W_X, BOARD_D_Y, BOARD_T]);
}


main_assembly();
