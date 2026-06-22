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
use <parts/baseplate.scad>         // baseplate_quad(qx,qy), seam_splice()
use <parts/faceplate_left.scad>    // faceplate_left()
use <parts/faceplate_right.scad>   // faceplate_right()
use <parts/io_subplate.scad>       // io_subplate()
use <parts/m2_retainer.scad>       // m2_retainer()
use <parts/rear_panel.scad>        // rear_panel()
use <parts/ssd_mezzanine.scad>     // ssd_mezzanine()   (optional)
use <parts/lid.scad>               // lid_front(), lid_rear()  (optional)
use <parts/m25_grid_insert.scad>   // m25_grid_insert()  (board standoff, illustrative)
use <parts/board_edge_clip.scad>   // board_edge_clip()  (board retention, illustrative)
use <parts/reference_board.scad>   // reference_board()  (visual ref, not printed)


// ---------------------------------------------------------------------
// VIEW TOGGLES
// ---------------------------------------------------------------------
SHOW_SSD   = true;   // include the optional 2.5" SSD mezzanine
SHOW_LID   = true;   // include the optional vented 2U lid (two tiles)
SHOW_BOARD = true;   // faint %ghost of the motherboard for reference
SHOW_MOUNTS = true;  // illustrate a couple grid standoffs + edge clips on board

// EXPLODE: 0 = assembled. >0 (mm) separates modules along their mating
// axes for an exploded view. Try EXPLODE = 40.
EXPLODE = 0;


// ---------------------------------------------------------------------
// DISTINCT PER-PART PALETTE  (matches the labeled screenshot legend)
// ---------------------------------------------------------------------
C_BASE_FRONT = "#4c72b0";   // 1  blue        baseplate_front
C_BASE_REAR  = "#55a868";   // 2  green       baseplate_rear
C_FACE_LEFT  = "#c44e52";   // 3  red         faceplate_left
C_FACE_RIGHT = "#8172b3";   // 4  purple      faceplate_right
C_IO_SUB     = "#ccb974";   // 5  sand        io_subplate
C_M2         = "#dd8452";   // 6  orange      m2_retainer
C_REAR_PANEL = "#da70d6";   // 7  orchid      rear_panel
C_SSD        = "#937860";   // 8  brown       ssd_mezzanine
C_LID_FRONT  = "#4fb0c6";   // 9  cyan        lid_front
C_LID_REAR   = "#9edae5";   // 10 light-cyan  lid_rear


module main_assembly() {

    // --- Structural floor: 4 bed-friendly quadrants (no fixed standoffs;
    //     board mounts on user-placed m25_grid_insert standoffs + edge clips) ---
    for (q = [[0,0],[1,0],[0,1],[1,1]]) {
        ex = (q[0] == 0 ? -EXPLODE : EXPLODE);
        ey = (q[1] == 0 ? -EXPLODE : EXPLODE);
        color(q[1] == 0 ? C_BASE_FRONT : C_BASE_REAR)
            translate([ex, ey, 0])
                baseplate_quad(q[0], q[1]);
    }
    // seam splice bars tie the quadrants across BOTH seams (bolt into the grid).
    // Mostly hidden under the board here — see docs/img/baseplate_assembly.png.
    if (EXPLODE == 0) {
        // X-seam bars: y snapped so each bolt hole lands on a grid pilot row
        // (hole-center = y+8 -> 42.5 / 162.5); previously landed on bare floor.
        for (y = [34.5, 154.5]) color("#cfcfcf") translate([90, y, FLOOR]) seam_splice();      // X-seam
        // Y-seam bars: x snapped so each hole lands on a grid pilot column (42.5/162.5).
        for (x = [50.5, 170.5]) color("#cfcfcf") translate([x, 90, FLOOR]) rotate([0,0,90]) seam_splice(); // Y-seam
    }

    // --- Faceplate (two tiles), in front of the body. Explodes -Y. ---
    color(C_FACE_LEFT)
        translate([0, -2 * EXPLODE, 0])
            faceplate_left();

    color(C_FACE_RIGHT)
        translate([0, -2 * EXPLODE, 0])
            faceplate_right();

    // --- Swappable front I/O subplate, recessed into the faceplate window.
    //     Explodes further -Y than the faceplate so it clears the window. ---
    color(C_IO_SUB)
        translate([0, -3 * EXPLODE, 0])
            io_subplate();

    // --- Rear I/O panel, behind the body. Explodes +Y. ---
    color(C_REAR_PANEL)
        translate([0, 2 * EXPLODE, 0])
            rear_panel();

    // --- M.2 retainer post (supplies the missing standoff). Sits on rear
    //     tile grid, so it follows the rear tile +Y when exploded. ---
    color(C_M2)
        translate([0, EXPLODE, 0])
            m2_retainer();

    // --- Optional 2.5" SSD mezzanine, on stilts ABOVE the board, bolted to
    //     the front-tile grid. Explodes -Y with the front tile. ---
    if (SHOW_SSD)
        color(C_SSD)
            translate([0, -EXPLODE, 0])
                ssd_mezzanine();

    // --- Optional vented 2U lid (two tiles) on the wall-tops. Explodes +Z;
    //     the two tiles also separate along Y like the baseplate lap. ---
    if (SHOW_LID) {
        // 4 bed-friendly lid tiles: split in X at center (like the baseplate)
        // so no tile exceeds the bed; each half thumb-screws to its own wall.
        for (qx = [0, 1]) {
            ex = (qx == 0 ? -EXPLODE : EXPLODE);
            color(C_LID_FRONT) translate([ex, -EXPLODE, 3 * EXPLODE]) lid_front(qx);
            color(C_LID_REAR)  translate([ex,  EXPLODE, 3 * EXPLODE]) lid_rear(qx);
        }
    }

    // --- The motherboard (visual reference; sits on the standoffs) ---
    if (SHOW_BOARD)
        _board();

    // --- Illustrative tolerance-first board mounting (not part of the
    //     printed-panel count): a couple m25_grid_insert standoffs under the
    //     board's nearest grid points, and a couple board_edge_clip fingers
    //     trapping the board edge. Shows HOW the board is held. ---
    if (SHOW_MOUNTS) {
        // two grid standoffs at grid points near board corners
        color("#b0a070")
            translate([GRID_X0, GRID_Y0, FLOOR]) m25_grid_insert();
        color("#b0a070")
            translate([GRID_X0 + 12*GRID_PITCH, GRID_Y0, FLOOR]) m25_grid_insert();

        // two edge clips: one on the front edge (finger reaching +Y over board
        // front), one on the left edge (rotated to reach +X over board left)
        color("#707070")
            translate([GRID_X0 - 8, GRID_Y0 - 8, FLOOR]) board_edge_clip();
        color("#707070")
            translate([GRID_X0 + 12*GRID_PITCH + 8, GRID_Y0 - 8, FLOOR])
                mirror([1, 0, 0]) board_edge_clip();
    }
}


// Recognizable Dell 5558 board model, placed on the standoff plane
// (PCB underside at Z = BOARD_Z). Visual reference only — never printed.
module _board() {
    translate([BOARD_X0, BOARD_Y0, BOARD_Z])
        reference_board();
}


main_assembly();
