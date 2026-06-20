// =====================================================================
// parts/reference_board.scad  ->  reference_board()
//
// VISUAL REFERENCE ONLY — a recognizable Dell Inspiron 15-5558/5559
// laptop motherboard prop. NEVER printed, never sliced. It sits inside
// the case in the assembly + exploded renders and in the README, so a
// faithful SILHOUETTE matters far more than electrical accuracy.
//
// STYLE: DETAILED REALISTIC. Curved hull-chain heatpipe, blower fan with
// a volute/scroll housing + hint of blades, individual heatsink fins, an
// X spring-bracket over the CPU/GPU plate, and scattered SMD chips.
//
// BOARD-LOCAL COORDINATE FRAME (main.scad 'use's this file and places it
// at the board datum, so everything here is board-local):
//   PCB occupies  X 0..BOARD_W_X (=203, width)
//                 Y 0..BOARD_D_Y (=197, depth)   Y=0 = FRONT (rack I/O)
//                 Z 0..BOARD_T   (~1, the PCB slab)
//   ALL components sit ON TOP, growing +Z from Z=BOARD_T.
//
// CORRECTED LAYOUT: the board is now ~SQUARE (203 x 197) instead of the
// old 170 x 235.  EVERY component position is a local constant below so
// it is easy to retune.  Thermal solution lives at the FRONT (Y near 0)
// so the blower exhaust + fins face the rack front; the copper heatpipe
// runs from the CPU/GPU plate (mid/rear) forward to the blower.
//
// Colors are applied per-feature with color("#hex").  // params.scad
// supplies BOARD_W_X / BOARD_D_Y / BOARD_T only.
// =====================================================================

include <params.scad>

// ---- local palette ---------------------------------------------------
PCB_COL      = "#16386e";
PIPE_COL     = "#b87333";
METAL_COL    = "#bfc4c8";   // heatsink / fins / plate
FAN_COL      = "#2c2f33";   // fan volute housing
HUB_COL      = "#17191c";   // fan hub
RAM_COL      = "#2e7d32";   // green DIMM / M.2 card
SLOT_COL     = "#15171a";   // black sockets
CONN_COL     = "#9aa0a6";   // metallic connector shells
COIN_COL     = "#d0d3d6";   // CMOS coin cell
CHIP_COL     = "#0e0f12";   // black SMD chips

ZTOP = BOARD_T;             // everything grows up from here

// =====================================================================
// COMPONENT PLACEMENT CONSTANTS  (board-local, all inside 0..203 X,
// 0..197 Y).  Retune HERE — every module reads these, nothing hardcoded.
// Datum reminders:  Y=0 = FRONT (rack I/O) ;  Y=BOARD_D_Y = REAR.
// =====================================================================

// --- 2. BLOWER FAN ---  (front-right, exhaust snout points -Y toward fins)
BLOWER_CX    = 150;         // fan center X
BLOWER_CY    = 52;          // fan center Y (near front)
BLOWER_RO    = 30;          // outer fan radius
BLOWER_H     = 14;          // fan height

// --- 3. HEATSINK FINS ---  (radiator at the FRONT edge, exhaust faces -Y)
FINS_X0      = 118;         // fin block X span...
FINS_X1      = 182;
FINS_Y0      = 2;           // ...sits at the very front edge (Y near 0)
FINS_Y1      = 18;
FINS_H       = 12;

// --- 4. HEATPIPE ---  copper waypoint chain: CPU/GPU plate -> blower.
//   First point sits on the plate (rear), last point at the fan/fins.
HEATPIPE_PTS = [
    [ 78, 150], [ 96, 132], [118, 110],
    [134,  86], [146,  68], [150,  54]
];
HEATPIPE_R   = 4;           // pipe radius (~D8)

// --- 5. CPU/GPU HEATSINK PLATE ---  (mid/rear of the board)
PLATE_X0     = 58;
PLATE_Y0     = 128;
PLATE_X1     = 122;
PLATE_Y1     = 176;
PLATE_H      = 3;

// --- 6. SODIMM SLOTS ---  two stacked slots, run along X.  X 20..150.
SODIMM_X0    = 20;
SODIMM_X1    = 150;
SODIMM1_Y0   = 96;          // slot 1 (populated)
SODIMM1_Y1   = 104;
SODIMM2_Y0   = 110;         // slot 2 (empty)
SODIMM2_Y1   = 118;

// --- 7. DRAM CHIP ROW ---  open area, front-center
DRAM_Y       = 78;
DRAM_X0      = 64;          // first chip center X
DRAM_DX      = 22;          // chip-to-chip X pitch

// --- 8. M.2 / NGFF SSD ---  connector rear-right, card lies toward -X
M2_CONN_X0   = 150;
M2_CONN_X1   = 158;
M2_CONN_Y0   = 158;
M2_CONN_Y1   = 166;
M2_CARD_X0   = 70;          // card far end
M2_CARD_Y    = 162;         // card centerline Y

// --- 9. WLAN NGFF ---  small slot, rear-left
WLAN_SLOT_X0 = 36;
WLAN_SLOT_X1 = 44;
WLAN_SLOT_Y0 = 182;
WLAN_SLOT_Y1 = 186;
WLAN_CARD_X0 = 18;          // tiny card extends toward -X
WLAN_CARD_X1 = 36;
WLAN_CARD_Y  = 184;

// --- 10. COIN CELL (CMOS) ---  rear-right open corner
COIN_CX      = 186;
COIN_CY      = 178;

// --- 11. FRONT-EDGE I/O ---  (Y near 0) HDMI + RJ45 + USB-A x2, spread X.
//   [x0, x1] window for each, all at the front edge.
IO_DEPTH     = 14;          // how far the connector stack reaches in +Y
HDMI_X0      = 14;   HDMI_X1  = 32;     // HDMI
RJ45_X0      = 44;   RJ45_X1  = 64;     // RJ45 (ADDED)
USBA1_X0     = 78;   USBA1_X1 = 92;     // USB-A #1
USBA2_X0     = 100;  USBA2_X1 = 114;    // USB-A #2
DISP_X0      = 172;  DISP_X1  = 196;    // display/power connector (black)

// --- 12. REAR-EDGE I/O ---  (Y near BOARD_D_Y) USB-C + SD + audio
USBC_X0      = 30;   USBC_X1  = 44;
SD_X0        = 92;   SD_X1    = 116;
AUDIO_CX     = 188;                     // 3.5mm audio jack barrel center X

// ---------------------------------------------------------------------
// small helpers
// ---------------------------------------------------------------------

// rounded-rectangle prism sitting on its base at z0, extruded h in +Z
module rrect_prism(x0, y0, x1, y1, z0, h, r=1.2) {
    w = x1 - x0; d = y1 - y0;
    rr = min(r, w/2 - 0.01, d/2 - 0.01);
    translate([x0, y0, z0])
        linear_extrude(height = h)
            offset(r = rr) offset(delta = -rr)
                square([w, d]);
}

// plain axis-aligned box from two corners
module box2(x0, y0, x1, y1, z0, h) {
    translate([x0, y0, z0]) cube([x1 - x0, y1 - y0, h]);
}

// a chip: rounded black SMD body on small standoff so it reads as a part
module smd_chip(cx, cy, sx, sy, h=1.4) {
    color(CHIP_COL)
        rrect_prism(cx - sx/2, cy - sy/2, cx + sx/2, cy + sy/2, ZTOP, h, r=0.5);
}

// ---------------------------------------------------------------------
// 1. PCB SLAB  (dark blue, rounded corners)
// ---------------------------------------------------------------------
module rb_pcb() {
    color(PCB_COL)
        rrect_prism(0, 0, BOARD_W_X, BOARD_D_Y, 0, BOARD_T, r=5);
}

// ---------------------------------------------------------------------
// 2. BLOWER FAN  (volute/scroll housing + hub + intake + hint of blades)
//    Front-right of the board; exhaust snout points -Y toward the fins.
// ---------------------------------------------------------------------
module rb_blower(cx=BLOWER_CX, cy=BLOWER_CY) {
    rO = BLOWER_RO;     // outer fan radius
    fh = BLOWER_H;      // fan height
    z0 = ZTOP;

    // ---- volute / scroll housing: round body that grows a tangential
    //      exhaust snout toward the heatsink (front, toward -Y) ----
    color(FAN_COL) {
        translate([cx, cy, z0]) {
            // main round drum
            cylinder(h = fh, r = rO);
            // scroll wrap: an off-center fattening that spirals the wall out
            for (a = [0:30:150])
                rotate([0, 0, a + 200])
                    translate([rO * 0.55, 0, 0])
                        cylinder(h = fh, r = rO * (0.55 + a/600));
        }
        // tangential exhaust snout, pointing toward the fins (front, -Y)
        hull() {
            translate([cx - 18, cy - rO + 2, z0]) cube([24, 6, fh]);
            translate([cx - rO + 4, cy - rO + 10, z0])
                cylinder(h = fh, r = 11);
        }
    }

    // ---- top intake ring: raise a rim, then sink a round intake hole ----
    difference() {
        union() {
            // rim lip around the intake
            color(FAN_COL)
                translate([cx, cy, z0 + fh - 1.5])
                    cylinder(h = 2.0, r1 = rO * 0.92, r2 = rO * 0.82);
        }
        // intake bore
        translate([cx, cy, z0 + fh - 2.0])
            cylinder(h = 4, r = rO * 0.66);
    }

    // ---- hub (~D22) ----
    color(HUB_COL)
        translate([cx, cy, z0 + fh - 3.0])
            cylinder(h = 3.2, r = 11);

    // ---- hint of blades: thin radial fins around the hub, just below
    //      the intake plane so they peek through the intake hole ----
    color("#3a3d42")
        translate([cx, cy, z0 + fh - 3.2])
            for (a = [0:18:359])
                rotate([0, 0, a])
                    translate([13, 0, 0])
                        rotate([0, 0, 28])      // skewed like real blower blades
                            cube([15, 1.1, 2.6], center = true);
}

// ---------------------------------------------------------------------
// 3. HEATSINK FINS  (exhaust radiator) — individual vertical fins at the
//    FRONT edge beside the fan.  Exhaust faces the front (Y~0): fins run
//    along X, gaps along X, so airflow blows out -Y toward the rack front.
// ---------------------------------------------------------------------
module rb_fins(x0=FINS_X0, x1=FINS_X1, y0=FINS_Y0, y1=FINS_Y1, h=FINS_H) {
    z0 = ZTOP;
    finT  = 0.8;        // fin thickness (along X)
    pitch = 2.4;        // center-to-center
    n = floor((x1 - x0) / pitch);
    color(METAL_COL) {
        // top + bottom cap rails that tie the fins together
        box2(x0, y0, x1, y0 + 1.2, z0, h);
        box2(x0, y1 - 1.2, x1, y1, z0, h);
        // the fins themselves
        for (i = [0:n])
            translate([x0 + i * pitch, y0, z0])
                cube([finT, y1 - y0, h]);
    }
}

// ---------------------------------------------------------------------
// 4. HEATPIPE  (copper ~D8) — hull-chain along curved waypoints from the
//    CPU/GPU plate (rear) forward to the fan/fins (front).
// ---------------------------------------------------------------------
module rb_heatpipe() {
    rP = HEATPIPE_R;                // pipe radius (~D8)
    zc = ZTOP + PLATE_H + 2.0;      // ride a touch above the plate top
    pts = HEATPIPE_PTS;             // curved waypoint chain (board-local)
    color(PIPE_COL)
        for (i = [0 : len(pts) - 2])
            hull() {
                translate([pts[i][0],   pts[i][1],   zc])
                    scale([1, 1, 0.7]) sphere(r = rP);
                translate([pts[i+1][0], pts[i+1][1], zc])
                    scale([1, 1, 0.7]) sphere(r = rP);
            }
    // flattened contact saddle where the pipe meets the plate
    color(PIPE_COL)
        translate([pts[0][0], pts[0][1], ZTOP + PLATE_H])
            scale([1.6, 1.6, 0.5]) sphere(r = rP);
}

// ---------------------------------------------------------------------
// 5. CPU/GPU HEATSINK PLATE  (flat silver) with a thin X-shaped spring
//    bracket on top.  Mid/rear of the board.
// ---------------------------------------------------------------------
module rb_cpu_plate(x0=PLATE_X0, y0=PLATE_Y0, x1=PLATE_X1, y1=PLATE_Y1, h=PLATE_H) {
    z0 = ZTOP;
    color(METAL_COL)
        rrect_prism(x0, y0, x1, y1, z0, h, r=2);

    // two raised copper die-contact pads (CPU + GPU) under the plate area
    color(PIPE_COL) {
        translate([x0 + 16, y0 + 16, z0 + h - 0.4])
            rrect_prism(0, 0, 14, 14, 0, 0.8, r=1);
        translate([x0 + 36, y0 + 24, z0 + h - 0.4])
            rrect_prism(0, 0, 14, 14, 0, 0.8, r=1);
    }

    // ---- X-shaped spring bracket (two crossed steel arms + 4 screw bosses) ----
    cx = (x0 + x1)/2; cy = (y0 + y1)/2;
    plateW = x1 - x0; plateD = y1 - y0;
    armT = 1.6;
    // arm length spans the plate diagonal minus a small inset, so the X
    // fits the plate; turrets land at the PLATE CORNERS (inset 4mm).
    inset = 4;
    diag  = sqrt(plateW*plateW + plateD*plateD);
    armL  = diag - 2*inset;
    armW  = 5;
    // angle of the plate diagonal (corner-to-corner)
    ang = atan2(plateD, plateW);
    bz = z0 + h;                    // bracket rides on the plate top
    color("#7d8388") {
        // crossed arms (a thin X), centered on the plate, each along a diagonal
        translate([cx, cy, bz + armT/2])
            rotate([0, 0,  ang])
                cube([armL, armW, armT], center = true);
        translate([cx, cy, bz + armT/2])
            rotate([0, 0, -ang])
                cube([armL, armW, armT], center = true);
        // 4 hold-down screw turrets — placed directly at the PLATE CORNERS
        // (inset), so they can never fly off the board.
        for (c = [
                [x0 + inset, y0 + inset],
                [x1 - inset, y0 + inset],
                [x0 + inset, y1 - inset],
                [x1 - inset, y1 - inset]
            ])
            translate([c[0], c[1], bz]) cylinder(h = 2.6, r = 2.6);
    }
}

// ---------------------------------------------------------------------
// 6. SODIMM SLOTS  (slot1 populated w/ green RAM, slot2 empty)
// ---------------------------------------------------------------------
module rb_sodimm(y0, y1, populated=false) {
    z0 = ZTOP;
    sh = 5;     // slot height
    x0 = SODIMM_X0; x1 = SODIMM_X1;
    // black slot body with the central key gap
    color(SLOT_COL) {
        box2(x0, y0, x1, y0 + 1.6, z0, sh);             // front rail
        box2(x0, y1 - 1.6, x1, y1, z0, sh);             // rear rail
        box2(x0, y0, x0 + 3, y1, z0, sh);               // left end (latch)
        box2(x1 - 3, y0, x1, y1, z0, sh);               // right end (latch)
    }
    if (populated) {
        // green RAM module lying flat on top of the slot
        color(RAM_COL)
            rrect_prism(x0 + 5, y0 + 1, x1 - 5, y1 - 1, z0 + sh - 1.2, 1.6, r=1);
        // a row of black DRAM chips on the module
        for (i = [0:7])
            smd_chip(x0 + 13 + i*15, (y0 + y1)/2, 9, 4.2, 0.9);
        // gold edge-connector hint along the front of the module
        color("#c9a23a")
            box2(x0 + 7, y0 + 1, x1 - 7, y0 + 2.0, z0 + sh - 1.3, 0.5);
    }
}

// ---------------------------------------------------------------------
// 7. DRAM CHIPS  — row of ~4 black rectangles in the front-center open area
// ---------------------------------------------------------------------
module rb_dram_row() {
    for (i = [0:3])
        smd_chip(DRAM_X0 + i*DRAM_DX, DRAM_Y, 16, 12, 1.6);
}

// ---------------------------------------------------------------------
// 8. M.2 / NGFF SSD  — connector rear-right + green card lying flat -X.
// ---------------------------------------------------------------------
module rb_m2() {
    z0 = ZTOP;
    cMidY = (M2_CONN_Y0 + M2_CONN_Y1)/2;
    // connector
    color(SLOT_COL) box2(M2_CONN_X0, M2_CONN_Y0, M2_CONN_X1, M2_CONN_Y1, z0, 4);
    color("#c9a23a")
        box2(M2_CONN_X0, cMidY - 1.5, M2_CONN_X0 + 4, cMidY + 1.5, z0 + 0.5, 2.2);  // gold contacts
    // green M.2 card lying flat (extends toward -X from the connector)
    color(RAM_COL)
        rrect_prism(M2_CARD_X0, M2_CARD_Y - 3, M2_CONN_X0, M2_CARD_Y + 3, z0 + 1.2, 1.0, r=1);
    // a couple of NAND/controller chips on the card
    smd_chip(M2_CARD_X0 + 22, M2_CARD_Y, 16, 4, 0.8);
    smd_chip(M2_CARD_X0 + 48, M2_CARD_Y, 16, 4, 0.8);
    // standoff screw boss at the far end of the card
    color(CONN_COL) translate([M2_CARD_X0 + 2, M2_CARD_Y, z0 + 2.2]) cylinder(h = 0.8, r = 2);
}

// ---------------------------------------------------------------------
// 9. WLAN NGFF  — small slot rear-left + tiny card
// ---------------------------------------------------------------------
module rb_wlan() {
    z0 = ZTOP;
    cMidY = (WLAN_SLOT_Y0 + WLAN_SLOT_Y1)/2;
    color(SLOT_COL) box2(WLAN_SLOT_X0, WLAN_SLOT_Y0, WLAN_SLOT_X1, WLAN_SLOT_Y1, z0, 3.5);
    color(RAM_COL)  rrect_prism(WLAN_CARD_X0, WLAN_CARD_Y - 3, WLAN_CARD_X1, WLAN_CARD_Y + 3, z0 + 1.0, 0.9, r=1);
    smd_chip((WLAN_CARD_X0 + WLAN_CARD_X1)/2, WLAN_CARD_Y, 9, 4, 0.8);            // wifi chip
    // two tiny antenna u.fl connectors
    color(COIN_COL) {
        translate([WLAN_CARD_X0 + 4, WLAN_CARD_Y - 1, z0 + 1.9]) cylinder(h = 1.2, r = 1.1);
        translate([WLAN_CARD_X0 + 4, WLAN_CARD_Y + 1, z0 + 1.9]) cylinder(h = 1.2, r = 1.1);
    }
}

// ---------------------------------------------------------------------
// 10. COIN CELL (CMOS)  — silver cylinder D16 x ~3
// ---------------------------------------------------------------------
module rb_coincell(cx=COIN_CX, cy=COIN_CY) {
    color(COIN_COL)
        translate([cx, cy, ZTOP]) cylinder(h = 3.2, r = 8);
    // little + terminal nub on top
    color("#9aa0a6")
        translate([cx, cy, ZTOP + 3.2]) cylinder(h = 0.4, r = 4);
}

// ---------------------------------------------------------------------
// 11. FRONT-EDGE CONNECTORS  (Y near 0) — metallic boxes, spread across X.
//     HDMI + RJ45 + USB-A x2  (RJ45 added).
// ---------------------------------------------------------------------
module rb_front_io() {
    z0 = ZTOP;
    d  = IO_DEPTH;
    color(CONN_COL) {
        box2(HDMI_X0,  0, HDMI_X1,  d, z0, 6);     // HDMI
        box2(RJ45_X0,  0, RJ45_X1,  d, z0, 7.5);   // RJ45 (taller magjack)
        box2(USBA1_X0, 0, USBA1_X1, d, z0, 6.5);   // USB-A #1
        box2(USBA2_X0, 0, USBA2_X1, d, z0, 6.5);   // USB-A #2
    }
    color(SLOT_COL)
        box2(DISP_X0, 0, DISP_X1, 8, z0, 4);       // display/power connector (black)
    // RJ45 dark throat so it reads as an ethernet jack
    color(SLOT_COL)
        box2(RJ45_X0 + 2, 0, RJ45_X1 - 2, 2, z0 + 1.5, 4.5);
    // USB ports: blue inner tongue so they read as USB
    color("#1f4fa0") {
        box2(USBA1_X0 + 2, 0, USBA1_X1 - 2, 1.5, z0 + 1.5, 3.5);
        box2(USBA2_X0 + 2, 0, USBA2_X1 - 2, 1.5, z0 + 1.5, 3.5);
    }
}

// ---------------------------------------------------------------------
// 12. REAR-EDGE CONNECTORS  (Y near BOARD_D_Y) — metallic
// ---------------------------------------------------------------------
module rb_rear_io() {
    z0 = ZTOP;
    yR = BOARD_D_Y;       // 197
    color(CONN_COL) {
        box2(USBC_X0, yR - 12, USBC_X1, yR, z0, 5);    // USB-C
        box2(SD_X0,   yR - 14, SD_X1,   yR, z0, 4);    // SD slot
    }
    // USB-C inner pill
    color(SLOT_COL)
        translate([(USBC_X0 + USBC_X1)/2, yR - 6, z0 + 1.2])
            scale([1.6, 0.5, 1]) cylinder(h = 2.4, r = 2.5);
    // 3.5mm audio jack barrel, D6
    color(SLOT_COL)
        translate([AUDIO_CX, yR - 6, z0]) cylinder(h = 6, r = 3);
    color(METAL_COL)
        translate([AUDIO_CX, yR - 6, z0 + 6]) cylinder(h = 0.6, r = 3);
}

// ---------------------------------------------------------------------
// 13. SCATTERED SMD CHIPS  — texture across the open PCB areas.
//     All spots kept within 0..203 (X), 0..197 (Y).
// ---------------------------------------------------------------------
module rb_scatter() {
    // [cx, cy, sx, sy, h]
    spots = [
        [176, 100, 10, 8, 2.0],   // PCH-ish big chip (rear-right)
        [192,  70,  9, 9, 1.6],
        [186, 120,  7, 7, 1.4],
        [ 40,  56,  8, 6, 1.4],
        [ 28,  86,  6, 6, 1.2],
        [ 22, 140,  7, 9, 1.4],
        [190, 150,  8, 6, 1.4],
        [192, 186,  6, 6, 1.2],
        [140, 188,  9, 7, 1.6],
        [ 40, 168,  7, 7, 1.4],
        [128, 122,  6, 5, 1.2],
        [ 96, 158,  5, 9, 1.4],   // tall MOSFET-ish near plate
        [196,  40,  5, 5, 1.0],
        [  8, 110,  5, 12, 1.2],  // edge connector strip (left edge)
    ];
    for (s = spots)
        smd_chip(s[0], s[1], s[2], s[3], s[4]);

    // a few tiny passives (tantalum/electrolytic caps) for realism
    color("#b8860b")
        for (p = [[60, 158], [50, 150], [44, 162], [160, 140], [168, 130]])
            translate([p[0], p[1], ZTOP]) cylinder(h = 3.5, r = 1.6);
}

// =====================================================================
// TOP-LEVEL: reference_board()
// =====================================================================
module reference_board() {
    rb_pcb();

    // thermal solution (front-facing exhaust)
    rb_cpu_plate();
    rb_heatpipe();
    rb_fins();
    rb_blower();

    // memory
    rb_sodimm(SODIMM1_Y0, SODIMM1_Y1, populated = true);   // SODIMM slot 1 (populated)
    rb_sodimm(SODIMM2_Y0, SODIMM2_Y1, populated = false);  // SODIMM slot 2 (empty)
    rb_dram_row();

    // storage / radios
    rb_m2();
    rb_wlan();

    // misc on-board
    rb_coincell();

    // edge I/O
    rb_front_io();
    rb_rear_io();

    // texture
    rb_scatter();
}

// ---- standalone preview (board-local). main.scad 'use's the module and
//      places it at the board datum; this call only runs when this file is
//      opened directly, and is hidden by 'use'. Modest $fn for fast renders.
$fa = 4;
$fs = 0.6;
reference_board();
