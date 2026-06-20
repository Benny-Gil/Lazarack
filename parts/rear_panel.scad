// =====================================================================
// parts/rear_panel.scad  ->  rear_panel()
//
// Part 7 of 9.  REAR closure panel (Edge-beta), modeled IN the GLOBAL
// ASSEMBLY FRAME (origin = front-bottom-left interior corner of chassis;
// +X width left->right, +Y depth front->rear, +Z height bottom->top) so it
// mates with neighbors with NO transform in main.scad.
//
// *** BLANK 1U CLOSURE ***  Rear ports (USB-C / SD / 3.5mm audio) are
// DEFERRED.  This is a flat blank panel; a future iteration or a rear
// swap-insert will carry the actual I/O cutouts.  NO cutouts here.
//
// Assembly region:
//   X  0 .. REAR_W (212)
//   Y  DEPTH(210) .. DEPTH+REAR_T(214)   (thin slab; FRONT face Y=DEPTH)
//   Z  0 .. REAR_H (40)
//
// Features (closure + location only):
//   - Main rear plate (X 0..212, Y 210..214, Z 0..40)
//   - BOTTOM tongue/flange that beds into the baseplate rear lip and bolts
//     down: a flange in front of the panel carrying M3 CLEARANCE holes
//     (a few across X) into the baseplate rear-lip self-tap points.
//   - SIDE tabs that locate against the wall tops (drop into the wall-top
//     grooves on the L/R upstands), with FIT_CLEARANCE on the mating.
//   - All mating edges + the BOTTOM edge get a CHAMFER lead-in/relief.
//
// PRINTABILITY: prints FLAT on its back (outer face Y=DEPTH+REAR_T down on
// the bed) -> the 212 x 40 plate is the largest face, zero supports. The
// bed-plane footprint is X(212) x Z(40); REAR_T(4) is the vertical print
// axis. The chamfered bottom edge prints as a clean 45deg relief. M3
// clearance holes pass straight through the flange (no bridging).
//
// CONVENTION: shared globals from params.scad; parametric joinery from
// lib/joinery.scad (modules take explicit args, do not read globals).
// =====================================================================

include <params.scad>
use <../lib/joinery.scad>


// ---------------------------------------------------------------------
// Local helper values (derived from frozen params; no param redefinition)
// ---------------------------------------------------------------------
PANEL_Y0          = DEPTH;                 // = 210  panel inner (front) face
PANEL_Y1          = DEPTH + REAR_T;        // = 214  panel outer (rear) face

// --- baseplate rear-lip interface (local derived; no param dependency) -
// The baseplate rear lip rises to LIP_TOP_Z and presents an upward-opening
// groove the panel tongue beds into, plus self-tap points for the flange.
LIP_TOP_Z         = FLOOR + 6;             // = 9   baseplate rear-lip top Z
GROOVE_DEPTH      = 3.0;                   // baseplate rear-lip groove depth
GROOVE_FLOOR_Z    = LIP_TOP_Z - GROOVE_DEPTH;   // = 6   floor of groove

// --- bottom tongue (beds DOWN into the baseplate rear-lip groove) ------
TONGUE_Y_CTR      = (DEPTH - REAR_T - 1.5) + REAR_T/2;   // groove center Y
TONGUE_T          = REAR_T - FIT_CLEARANCE;  // loose fit in groove (Y)
TONGUE_BOT_Z      = GROOVE_FLOOR_Z + FIT_CLEARANCE;   // seat clearance
TONGUE_TOP_Z      = LIP_TOP_Z + 0.5;       // overlaps up into panel body

// --- bottom mounting flange + M3 clearance columns ---------------------
// a bar in front of the panel front face at the lip top; the M3 clearance
// holes drop through it into the baseplate rear-lip self-tap points.
FLANGE_T          = 8;                      // flange depth toward body (-Y)
FLANGE_H          = 6;                      // flange height (Z) above lip top
FLANGE_Y1         = PANEL_Y0;               // flange back edge = panel front
FLANGE_Y0         = PANEL_Y0 - FLANGE_T;    // flange front edge
REAR_FASTEN_Y     = DEPTH - REAR_T - 3;     // self-tap column Y (mirror baseplate)
// X columns of the bottom M3 mounts (a few across X). Spread across BODY_W.
REAR_FASTEN_X     = [ 25, REAR_W/2, REAR_W - 25 ];   // 3x M3 mount columns

// --- side location tabs (locate against the wall tops) -----------------
// The L/R upstands present an upward-opening groove along their inner top
// edge (Z UPSTAND_H-3 .. UPSTAND_H); the panel side tabs drop into them.
WALLTOP_GROOVE_W  = 3.0;                    // wall-top channel width (X)
WALLTOP_GROOVE_D  = 3.0;                    // wall-top channel depth (Z)
SIDE_TAB_W        = WALLTOP_GROOVE_W - FIT_CLEARANCE;  // loose fit in X
SIDE_TAB_T        = REAR_T;                 // tab thickness (Y) = panel thick
SIDE_TAB_TOP_Z    = UPSTAND_H + 0.5;        // overlaps up into panel body
SIDE_TAB_BOT_Z    = UPSTAND_H - WALLTOP_GROOVE_D + FIT_CLEARANCE;  // seat clr
SIDE_TAB_X_L      = WALL_T - WALLTOP_GROOVE_W;  // left channel start X (0)
SIDE_TAB_X_R      = (BODY_W - WALL_T) + (WALLTOP_GROOVE_W - SIDE_TAB_W)/2;


module rear_panel() {

    difference() {

        union() {

            // ---- 1. Main rear plate (the blank closure) ---------------
            translate([0, PANEL_Y0, 0])
                cube([REAR_W, REAR_T, REAR_H]);

            // ---- 2. Bottom tongue into baseplate rear-lip groove ------
            translate([0, TONGUE_Y_CTR - TONGUE_T/2, TONGUE_BOT_Z])
                cube([REAR_W, TONGUE_T, TONGUE_TOP_Z - TONGUE_BOT_Z]);

            // ---- 3. Bottom mounting flange (in front of panel, -Y) ----
            translate([0, FLANGE_Y0, LIP_TOP_Z - EPS])
                cube([REAR_W, FLANGE_T + EPS, FLANGE_H]);

            // ---- 4. Side location tabs into wall-top grooves ----------
            // left
            translate([SIDE_TAB_X_L, PANEL_Y0, SIDE_TAB_BOT_Z])
                cube([SIDE_TAB_W, SIDE_TAB_T,
                      SIDE_TAB_TOP_Z - SIDE_TAB_BOT_Z]);
            // right
            translate([SIDE_TAB_X_R, PANEL_Y0, SIDE_TAB_BOT_Z])
                cube([SIDE_TAB_W, SIDE_TAB_T,
                      SIDE_TAB_TOP_Z - SIDE_TAB_BOT_Z]);
        }

        // ===== NEGATIVE FEATURES (difference) ========================
        // NO I/O cutouts: this is a BLANK closure. Only the bottom M3
        // clearance holes + chamfer reliefs are cut.

        // ---- A. M3 clearance holes through the bottom flange --------
        // axis +Z; drop down into the baseplate rear-lip self-tap points.
        // CHAMFER lead-in countersink at the top of each hole.
        for (fx = REAR_FASTEN_X) {
            translate([fx, REAR_FASTEN_Y, LIP_TOP_Z - EPS])
                cylinder(h = FLANGE_H + 2*EPS, d = M3_CLEAR);
            // chamfer lead-in (top entry)
            translate([fx, REAR_FASTEN_Y, LIP_TOP_Z + FLANGE_H - CHAMFER])
                cylinder(h = CHAMFER + EPS,
                         d1 = M3_CLEAR, d2 = M3_CLEAR + 2*CHAMFER);
        }

        // ---- B. Bottom-edge chamfer relief (along the panel base) ---
        // 45deg relief on the front-bottom edge so the panel seats clean
        // and prints a tidy first layer. Runs full width in X.
        translate([-EPS, PANEL_Y0 - EPS, 0])
            rotate([45, 0, 0])
                cube([REAR_W + 2*EPS, CHAMFER*sqrt(2), CHAMFER*sqrt(2)]);
    }
}


// ---- standalone render (renders this part alone) ---------------------
$fa = 1; $fs = 0.4;
rear_panel();
