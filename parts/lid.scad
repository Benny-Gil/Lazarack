// =====================================================================
// parts/lid.scad  ->  lid_front()  +  lid_rear()
//
// PART 9 of 9 (OPTIONAL).  Vented 2U top, split into TWO flat tiles that
// thumb-screw to the wall-top M3 inserts and LAP each other at the depth
// seam (mirroring the baseplate_front/baseplate_rear rabbet-lap so the
// joinery registers vertically through the whole chassis).
//
// Modeled IN the GLOBAL ASSEMBLY FRAME (origin = front-bottom-left interior
// corner; +X width, +Y depth, +Z height) so both tiles mate with their
// neighbors and with each other with NO transform in main.scad.  The
// standalone render at the bottom calls lid_front() in-place, then
// translates a COPY of lid_rear() beside it (so the two tiles render apart,
// flat, for a quick visual check) AND also calls lid_rear() in-place last so
// the assembled lap is visible too.
//
// Assembly region (from FROZEN contract part_placements):
//   lid_front : X 0..BODY_W(190),  Y 0..LID_FRONT_D(118),  Z LID_Z..LID_Z+LID_T (86..89)
//   lid_rear  : X 0..BODY_W(190),  Y (DEPTH-LID_REAR_D).. DEPTH,  Z 86..89
//   Both tiles lap at the depth seam using
//     rabbet_lap_male / rabbet_lap_female(w=BODY_W, lap=LAP_LEN=25,
//                                         step_z=LID_T/2=1.5, floor_t=LID_T=3)
//   so the male LOWER tongue (front tile) tucks under the female UPPER ledge
//   (rear tile).  Tiles thumb-screw down into the wall-top M3 inserts with
//   M3 clearance holes; vent slots are louver_grille() negatives (no-support
//   overhang) over the central area of each tile.
//
// PRINTABILITY: each tile prints FLAT (largest face down on the bed), zero
// supports.  The lap male tongue is the LOWER step (Z 0..1.5 of the 3mm
// plate) so it prints as a simple thinned edge; the female ledge is the
// UPPER step (a pocket on the underside) -> its small ceiling spans only the
// 25mm lap and is bridged in PETG (or, since the part prints upside-up with
// the pocket opening DOWN onto the bed, the pocket is just a missing lower
// layer = self-supporting).  Louver slats are angled <=30deg so each slot's
// top edge needs no support.  Tile footprints:
//   lid_front 190 x 118  -> both bed-plane axes <= PRINT_MAX_XY(190).  OK.
//   lid_rear  190 x 146  -> both bed-plane axes <= PRINT_MAX_XY(190).  OK.
//   (146 = DEPTH - lap front edge; see LID_REAR_Y0 note below.  Slightly
//    deeper than nominal LID_REAR_D=142 because we honor the FROZEN lap=25
//    joinery call exactly rather than the rounded 142.)  LID_T=3 is the
//    vertical print axis.
//
// All M3 clearance holes pass cleanly through the 3mm plate (axis +Z).  No
// heat-set bores live ON the lid (the inserts are in the wall tops); the lid
// only carries clearance holes + vent slots, so nothing must "open upward".
//
// CONVENTION (FROZEN): shared globals from params.scad; parametric joinery
// from lib/joinery.scad (modules take explicit args, do not read globals).
// Do NOT redefine params or joinery here.
// =====================================================================

include <params.scad>
use <../lib/joinery.scad>


// ---------------------------------------------------------------------
// Local placement helpers (derived from frozen params; NO param redefinition)
// ---------------------------------------------------------------------

// Lid plate sits ON TOP of the 86mm wall upstands:  Z LID_Z .. LID_Z+LID_T.
LID_Z0            = LID_Z;                 // = 86  underside of lid plate
LID_Z1            = LID_Z + LID_T;         // = 89  top face of lid plate
LID_STEP_Z        = LID_T / 2;            // = 1.5 rabbet step (half the plate)

// --- depth-seam lap (mirror baseplate lap, anchored to LID_FRONT_D) ---
// Seam nominal at the front-tile rear edge; lap occupies the 25mm in front
// of it.  Front tile = solid up to LAP front edge, then the MALE lower tongue
// over the lap.  Rear tile = FEMALE upper ledge over the lap, then solid to
// the rear face.
LID_SEAM_Y        = LID_FRONT_D;                 // = 118  seam (front tile rear edge)
LID_LAP_Y0        = LID_SEAM_Y - LAP_LEN;        // = 93   lap front edge
LID_LAP_Y1        = LID_SEAM_Y;                  // = 118  lap rear edge
LID_FRONT_SOLID_D = LID_LAP_Y0;                  // = 93   front-tile solid depth

LID_REAR_Y0       = LID_LAP_Y0;                  // = 93   rear tile starts at lap front
LID_REAR_Y1       = DEPTH;                        // = 239  rear tile rear edge
LID_REAR_SOLID_Y0 = LID_LAP_Y1;                  // = 118  rear-tile solid starts here

// --- wall-top mounting (thumb-screw M3 clearance into wall-top inserts) ---
// The integral upstands are WALL_T(3) wide at X 0..3 and 187..190.  Their
// tops are at Z=UPSTAND_H(86)=LID_Z.  We drop M3 clearance holes along each
// wall-top centerline (X=1.5 and X=188.5) into wall-top heat-set inserts.
WALL_L_CX         = WALL_T / 2;                   // = 1.5   left  wall-top centerline X
WALL_R_CX         = BODY_W - WALL_T / 2;          // = 188.5 right wall-top centerline X
// Mounting-screw Y positions per tile (along each wall).  // MEASURE: the
// matching wall-top inserts must be added to baseplate_front/_rear at these Y.
LID_FRONT_FASTEN_Y = [ 18, 58, 100 ];            // 3 per wall on the front tile // MEASURE
LID_REAR_FASTEN_Y  = [ 135, 175, 215 ];          // 3 per wall on the rear tile  // MEASURE

// --- vent field (louvered slots through the plate, axis-of-cut +Y) ---
// A central vent window on each tile, inset from the walls and the lap so
// slats land in solid plate.  louver_grille() cuts n angled slots across its
// height (here mapped to the tile DEPTH) through the full plate thickness.
VENT_X_INSET      = 25;                           // keep slots off the wall tops
VENT_W            = BODY_W - 2*VENT_X_INSET;      // = 140  vent window width (X)
VENT_Y_INSET      = 18;                           // keep slots off front/rear edges & lap
VENT_SLATS_FRONT  = 5;                            // louver slots on front tile
VENT_SLATS_REAR   = 7;                            // louver slots on rear tile
VENT_SLAT_W       = 4;                            // each slot width along Y
VENT_ANGLE        = 30;                           // louver tilt (<=45 -> no support)

// FRONT-tile vent window (assembly Y), over the solid plate (Y 0..93):
VENT_FRONT_Y0     = VENT_Y_INSET;                          // = 18
VENT_FRONT_Y1     = LID_FRONT_SOLID_D - VENT_Y_INSET;     // = 75
VENT_FRONT_D      = VENT_FRONT_Y1 - VENT_FRONT_Y0;        // = 57

// REAR-tile vent window (assembly Y), over the solid plate (Y 118..239):
VENT_REAR_Y0      = LID_REAR_SOLID_Y0 + VENT_Y_INSET;     // = 136
VENT_REAR_Y1      = LID_REAR_Y1 - VENT_Y_INSET;           // = 221
VENT_REAR_D       = VENT_REAR_Y1 - VENT_REAR_Y0;          // = 85


// ---------------------------------------------------------------------
// lid_vent(): louvered vent NEGATIVE for a window [x0..x0+w] x [y0..y0+depth]
// in the lid plate, cut cleanly THROUGH the plate thickness (assembly +Z).
//
// louver_grille(w, h, t, n, slat, angle) lays n slots along its LOCAL Z
// (height field 0..h), cutting through its LOCAL Y (thickness t).  We map:
//   local X      -> assembly X      (window width w)
//   local Z (h)  -> assembly Y      (window depth)  [marches in -Y after the
//                                                     rotate, so anchor rear]
//   local Y (t)  -> assembly Z      (cut through plate thickness)
// rotate([90,0,0]) sends local (x,y,z) -> (x,-z,y).  We anchor the grille at
// the window REAR edge (y0+depth) and at the plate underside (z_base) so the
// slots march back toward y0 and the t-cut spans the whole plate.
// ---------------------------------------------------------------------
module lid_vent(x0, y0, w, depth, n, z_base) {
    translate([x0, y0 + depth, z_base])
        rotate([90, 0, 0])
            louver_grille(w, depth, LID_T + 2*EPS, n, VENT_SLAT_W, VENT_ANGLE, EPS);
}


// =====================================================================
// lid_front()  —  FRONT lid tile (X 0..190, Y 0..118, Z 86..89)
//   solid plate Y 0..93, MALE lower tongue over the lap Y 93..118,
//   thumb-screw clearance holes into the front wall-top inserts, central
//   louvered vent field.
// =====================================================================
module lid_front() {
    difference() {

        union() {
            // ---- 1. Main plate (full thickness)  Y 0..LID_FRONT_SOLID_D ----
            translate([0, 0, LID_Z0])
                cube([BODY_W, LID_FRONT_SOLID_D + EPS, LID_T]);

            // ---- 2. MALE rabbet-lap LOWER tongue  Y 93..118 ----
            // rabbet_lap_male models the lower step (Z 0..step_z) of width w,
            // length lap, extending +Y from its local origin.  Place its base
            // at the plate underside (LID_Z0) so the tongue is the LOWER half
            // of the plate over the lap; the upper half is left open for the
            // rear tile's ledge to overlap.
            translate([0, LID_LAP_Y0, LID_Z0])
                rabbet_lap_male(BODY_W, LAP_LEN, LID_STEP_Z, LID_T, EPS);
        }

        // ===== NEGATIVE FEATURES =====================================

        // ---- A. Thumb-screw M3 clearance holes (into front wall-tops) ----
        // axis +Z, clean through the 3mm plate.  Two walls x N Y-positions.
        for (fy = LID_FRONT_FASTEN_Y) {
            translate([WALL_L_CX, fy, LID_Z0 - EPS])
                cylinder(h = LID_T + 2*EPS, d = M3_CLEAR);
            translate([WALL_R_CX, fy, LID_Z0 - EPS])
                cylinder(h = LID_T + 2*EPS, d = M3_CLEAR);
        }

        // ---- B. Central louvered vent field (over the solid plate) ----
        lid_vent(VENT_X_INSET, VENT_FRONT_Y0, VENT_W, VENT_FRONT_D,
                 VENT_SLATS_FRONT, LID_Z0 - EPS);
    }
}


// =====================================================================
// lid_rear()  —  REAR lid tile (X 0..190, Y 93..239, Z 86..89)
//   FEMALE upper ledge over the lap Y 93..118 (receives the front tongue),
//   solid plate Y 118..239, thumb-screw clearance holes into the rear
//   wall-top inserts, central louvered vent field.
// =====================================================================
module lid_rear() {
    difference() {

        union() {
            // ---- 1. Main plate (full thickness)  Y 118..239 ----
            translate([0, LID_REAR_SOLID_Y0 - EPS, LID_Z0])
                cube([BODY_W, LID_REAR_Y1 - LID_REAR_SOLID_Y0 + EPS, LID_T]);

            // ---- 2. FEMALE rabbet-lap UPPER ledge  Y 93..118 ----
            // rabbet_lap_female returns the floor block (w x lap x floor_t)
            // with the LOWER step pocketed out, leaving the UPPER ledge that
            // overlaps the front tile's male tongue.  Place its base at the
            // plate underside so the pocket (Z 0..step_z) opens DOWNWARD and
            // the front tongue slides under the ledge.
            translate([0, LID_LAP_Y0, LID_Z0])
                rabbet_lap_female(BODY_W, LAP_LEN, LID_STEP_Z, LID_T, EPS);
        }

        // ===== NEGATIVE FEATURES =====================================

        // ---- A. Thumb-screw M3 clearance holes (into rear wall-tops) ----
        for (fy = LID_REAR_FASTEN_Y) {
            translate([WALL_L_CX, fy, LID_Z0 - EPS])
                cylinder(h = LID_T + 2*EPS, d = M3_CLEAR);
            translate([WALL_R_CX, fy, LID_Z0 - EPS])
                cylinder(h = LID_T + 2*EPS, d = M3_CLEAR);
        }

        // ---- B. Central louvered vent field (over the solid plate) ----
        lid_vent(VENT_X_INSET, VENT_REAR_Y0, VENT_W, VENT_REAR_D,
                 VENT_SLATS_REAR, LID_Z0 - EPS);
    }
}


// =====================================================================
// Standalone render (renders this part file alone).
//
// This file exposes TWO separately-printed tiles (lid_front + lid_rear).
// main.scad `use <>`s this file and calls BOTH modules in-place in the
// shared assembly frame (they do NOT overlap: front Y 0..118, rear Y 93..239,
// lapping at the depth seam), so the executable statements below are NOT run
// by main.scad and exist only for standalone inspection / single-part export.
//
// IMPORTANT (printability / verification): each tile is its OWN print job and
// each already fits the Ender 3 V3 SE bed by itself
//   lid_front 190 x 118 x 3 ,  lid_rear 190 x 146 x 3   (both XY <= PRINT_MAX_XY).
// We therefore render exactly ONE tile here (lid_front, the primary tile), in
// place, matching the one-module-per-render convention of every other part
// file. Rendering both tiles together (or a side-by-side copy) would union
// into a 410 x 239 footprint that BREAKS the per-part bed-fit check even
// though each tile prints fine alone.
//
// To export the rear tile for printing, render lid_rear() instead, e.g.:
//   openscad -D 'render_rear=true' -o lid_rear.stl parts/lid.scad
// (override below) — or `use <parts/lid.scad>` and call lid_rear() yourself.
// =====================================================================
$fa = 1; $fs = 0.4;

render_rear = false;   // set true (e.g. -D render_rear=true) to export lid_rear

if (render_rear) lid_rear();
else             lid_front();
