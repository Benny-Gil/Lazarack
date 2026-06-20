// =====================================================================
// parts/rear_panel.scad  ->  rear_panel()
//
// Part 7 of 9.  REAR external I/O panel (Edge-beta), modeled IN the GLOBAL
// ASSEMBLY FRAME (origin = front-bottom-left interior corner of chassis;
// +X width left->right, +Y depth front->rear, +Z height bottom->top) so it
// mates with neighbors with NO transform in main.scad.
//
// Assembly region (per FROZEN CONTRACT part_placements):
//   X  0 .. REAR_W(190)
//   Y  DEPTH(239) .. DEPTH+REAR_T(243)   (thin slab; FRONT face Y=239)
//   Z  0 .. REAR_H(95)
//
// Features:
//   - Main rear plate (X 0..190, Y 239..243, Z 0..95)
//   - BOTTOM tongue (REAR_T wide in Y) projecting DOWN into the
//     baseplate_rear rear-lip groove, + a bottom mounting flange carrying
//     3x M3 clearance holes down into the baseplate rear-lip inserts
//     (REAR_FASTEN_X = [30,95,160], bores open UP on the baseplate).
//   - SIDE-edge tongues that slot into the wall-top grooves milled along
//     the inner-top of the baseplate_rear L/R upstands.
//   - Rear I/O cutouts (LOCAL to panel lower-left, all // MEASURE):
//       USB-C power-in  (USBC_POS / USBC_SIZE)
//       SD reader slot  (SD_POS   / SD_SIZE)
//       3.5mm audio     (AUDIO_POS / AUDIO_D)
//
// PRINTABILITY: prints FLAT on its back (outer face Y=243 down on the bed)
// -> the 190x95 plate is the largest face, zero supports. Footprint
// X 190 and Z 95 are each <= PRINT_MAX_XY(190) in the bed plane (Y=4 is the
// vertical print axis). Heat-set bores (none on this part; only clearance
// holes here) would open UP; clearance holes pass clean through. Cutout top
// edges are small (<=6mm spans) so no overhang support needed; the wide SD
// slot is only 4mm tall.
//
// CONVENTION: shared globals from params.scad; parametric joinery from
// lib/joinery.scad (modules take explicit args, do not read globals).
// =====================================================================

include <params.scad>
use <../lib/joinery.scad>


// ---------------------------------------------------------------------
// Local helper values (derived from frozen params; no param redefinition)
// ---------------------------------------------------------------------
PANEL_Y0          = DEPTH;                 // = 239  panel inner (front) face
PANEL_Y1          = DEPTH + REAR_T;        // = 243  panel outer (rear) face

// --- bottom tongue + flange (mate to baseplate_rear rear-lip groove) ---
// baseplate_rear cuts a groove on TOP of its rear lip:
//   groove width REAR_LIP_T(=REAR_T=4) in Y, centered ~Y 232.. , depth 3,
//   lip top at Z = FLOOR+6 = 9, groove floor at Z = 6.
// We project a tongue DOWN from the panel bottom into that groove and add a
// thin flange in front of the panel that the 3x M3 screws pass through.
LIP_TOP_Z         = FLOOR + 6;             // = 9   baseplate rear-lip top Z
GROOVE_DEPTH      = 3.0;                   // baseplate WALLTOP_GROOVE_D
GROOVE_FLOOR_Z    = LIP_TOP_Z - GROOVE_DEPTH;   // = 6   floor of groove
// baseplate groove is centered at Y = (REAR_Y1 - REAR_LIP_T - 1.5) + REAR_LIP_T/2
//   = (239 - 4 - 1.5) + 2 = 235.5  -> tongue sits there.
TONGUE_Y_CTR      = (DEPTH - REAR_T - 1.5) + REAR_T/2;   // = 235.5
TONGUE_T          = REAR_T;                // = 4   tongue thickness (Y) (groove adds clearance)
TONGUE_BOT_Z      = GROOVE_FLOOR_Z + 0.4;  // bottom of tongue (0.4 seat clearance)
TONGUE_TOP_Z      = LIP_TOP_Z + 0.5;       // overlaps up into panel body for a clean union

// bottom mounting flange: a bar in front of the panel (toward -Y) at the
// lip top, carrying the 3x M3 clearance holes into the baseplate inserts.
FLANGE_T          = 8;                      // flange depth toward body (-Y)
FLANGE_H          = 6;                      // flange height (Z) above lip top
FLANGE_Y1         = PANEL_Y0;               // flange back edge = panel front face (239)
FLANGE_Y0         = PANEL_Y0 - FLANGE_T;    // = 231  flange front edge
// baseplate rear-lip M3 inserts are centered at Y = DEPTH - REAR_T - 3 = 232
REAR_FASTEN_Y     = DEPTH - REAR_T - 3;     // = 232  insert column Y (mirror baseplate)
// X columns of the 3x M3 inserts in baseplate_rear's rear lip. MUST match
// baseplate_rear.scad's local REAR_FASTEN_X (= [30,95,160]) so the panel's
// clearance holes register onto the baseplate inserts. // MEASURE
REAR_FASTEN_X     = [ 30, 95, 160 ];        // 3x M3 mount columns (mirror baseplate)

// --- side-edge tongues (mate to wall-top grooves on baseplate_rear) ----
// baseplate_rear wall-top grooves: a channel along the inner-top of each
// upstand, opening +Z, at Z UPSTAND_H-3 .. UPSTAND_H (83..86):
//   left  channel X (WALL_T-WALLTOP_GROOVE_W)..WALL_T   = 0..3
//   right channel X (BODY_W-WALL_T)..(BODY_W-WALL_T+WALLTOP_GROOVE_W) = 187..190
// The panel side edges drop tongues DOWN into these channels for alignment.
WALLTOP_GROOVE_W  = 3.0;                    // baseplate channel width (X)
WALLTOP_GROOVE_D  = 3.0;                    // baseplate channel depth (Z)
SIDE_TONGUE_W     = WALLTOP_GROOVE_W - 0.4; // = 2.6  fit clearance in X
SIDE_TONGUE_T     = REAR_T;                 // tongue thickness (Y) = panel thickness
SIDE_TONGUE_TOP_Z = UPSTAND_H + 0.5;        // overlaps up into panel for clean union
SIDE_TONGUE_BOT_Z = UPSTAND_H - WALLTOP_GROOVE_D + 0.3;  // = 83.3  seat clearance
// left tongue centered in the left channel (X 0..3 -> center 1.5)
SIDE_TONGUE_X_L   = (WALL_T - WALLTOP_GROOVE_W) ;        // left channel start X (0)
SIDE_TONGUE_X_R   = (BODY_W - WALL_T) + (WALLTOP_GROOVE_W - SIDE_TONGUE_W)/2; // right channel


module rear_panel() {

    difference() {

        union() {

            // ---- 1. Main rear plate (X 0..190, Y 239..243, Z 0..95) ----
            translate([0, PANEL_Y0, 0])
                cube([REAR_W, REAR_T, REAR_H]);

            // ---- 2. Bottom tongue into baseplate rear-lip groove -------
            // a bar centered on TONGUE_Y_CTR projecting down from the panel
            // bottom into the groove; overlaps up into the plate (EPS-clean).
            translate([0, TONGUE_Y_CTR - TONGUE_T/2, TONGUE_BOT_Z])
                cube([REAR_W, TONGUE_T, TONGUE_TOP_Z - TONGUE_BOT_Z]);

            // ---- 3. Bottom mounting flange (in front of panel, -Y) -----
            // a bar in front of the panel front face at the lip top, takes
            // the 3x M3 clearance holes down into the baseplate inserts.
            translate([0, FLANGE_Y0, LIP_TOP_Z - EPS])
                cube([REAR_W, FLANGE_T + EPS, FLANGE_H]);

            // ---- 4. Side-edge tongues into wall-top grooves ------------
            // left
            translate([SIDE_TONGUE_X_L, PANEL_Y0, SIDE_TONGUE_BOT_Z])
                cube([SIDE_TONGUE_W, SIDE_TONGUE_T,
                      SIDE_TONGUE_TOP_Z - SIDE_TONGUE_BOT_Z]);
            // right
            translate([SIDE_TONGUE_X_R, PANEL_Y0, SIDE_TONGUE_BOT_Z])
                cube([SIDE_TONGUE_W, SIDE_TONGUE_T,
                      SIDE_TONGUE_TOP_Z - SIDE_TONGUE_BOT_Z]);
        }

        // ===== NEGATIVE FEATURES (difference) ========================
        // All I/O cutouts pass through the slab in +Y. Cutout positions are
        // LOCAL to the panel lower-left [X_local, Z_local] (== assembly X,Z
        // since the panel's lower-left in X,Z is (0,0)). Bored from the front
        // face (Y=PANEL_Y0) cleanly through to the rear face (+ EPS each end).

        // ---- A. USB-C power-in (rounded rectangle slot) -------------
        translate([USBC_POS[0], PANEL_Y0 - EPS, USBC_POS[1]])
            rounded_yslot(USBC_SIZE[0], USBC_SIZE[1], REAR_T + 2*EPS, 1.5);

        // ---- B. SD reader slot (thin wide rectangle) ----------------
        translate([SD_POS[0], PANEL_Y0 - EPS, SD_POS[1]])
            rounded_yslot(SD_SIZE[0], SD_SIZE[1], REAR_T + 2*EPS, 0.8);

        // ---- C. 3.5mm audio jack (round hole) -----------------------
        translate([AUDIO_POS[0], PANEL_Y0 - EPS, AUDIO_POS[1]])
            rotate([-90, 0, 0])             // axis +Y, bore through panel
                cylinder(h = REAR_T + 2*EPS, d = AUDIO_D);

        // ---- D. 3x M3 clearance holes through the bottom flange -----
        // axis +Z, drop down into baseplate_rear rear-lip inserts.
        for (fx = REAR_FASTEN_X)
            translate([fx, REAR_FASTEN_Y, LIP_TOP_Z - EPS])
                cylinder(h = FLANGE_H + 2*EPS, d = M3_CLEAR);
    }
}


// ---------------------------------------------------------------------
// local helper: a rounded-corner rectangular slot, axis +Y (bore through
// the panel). w = width (X), h = height (Z), depth = bore length (Y),
// r = corner radius. Origin = slot lower-left at the front face, depth +Y.
// Kept local (not a contract joinery module) so the frozen API is untouched.
// ---------------------------------------------------------------------
module rounded_yslot(w, h, depth, r) {
    rr = min(r, w/2 - EPS, h/2 - EPS);      // clamp radius to fit
    translate([0, 0, 0])
        rotate([-90, 0, 0])                  // map plate X-Z plane, extrude +Y
            linear_extrude(height = depth)
                offset(r = rr)
                    offset(delta = -rr)
                        square([w, h]);
}


// ---- standalone render (renders this part alone) ---------------------
$fa = 1; $fs = 0.4;
rear_panel();
