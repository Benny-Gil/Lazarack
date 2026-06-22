// =====================================================================
// parts/reference_board.scad  ->  reference_board()
//
// VISUAL REFERENCE ONLY — a recognizable Dell Inspiron 15-5558/5559
// laptop motherboard prop. NEVER printed, never sliced. It sits inside
// the case in the assembly + exploded renders and in the README, so a
// faithful, DENSE, photo-accurate SILHOUETTE matters far more than
// electrical accuracy.
//
// STYLE: DENSE + REALISTIC. A busy, populated board — full VRM section
// (MOSFET arrays + inductors + cap banks), big PCH + EC chips, many
// small passives, refined connectors with metal shells/throats and gold
// contacts, dual (forked) heatpipe, blower fan with a volute/scroll
// housing + skewed blades + label, individual heatsink fins, an X spring
// bracket over the CPU/GPU plate, populated SODIMM + M.2 + WLAN, SATA FFC
// connector, board mounting-hole ring pads, and the characteristic
// rear-left notch in the PCB outline.
//
// BOARD-LOCAL COORDINATE FRAME (main.scad 'use's this file and places it
// at the board datum, so everything here is board-local):
//   PCB occupies  X 0..BOARD_W_X (=203, width)
//                 Y 0..BOARD_D_Y (=197, depth)   Y=0 = FRONT (rack I/O)
//                 Z 0..BOARD_T   (~1, the PCB slab)
//   ALL components sit ON TOP, growing +Z from Z=BOARD_T.
//
// Colors are applied per-feature with color("#hex").  params.scad
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
// ---- extended palette (new) -----------------------------------------
GOLD_COL     = "#c9a23a";   // gold edge contacts / fingers
IND_COL      = "#222428";   // chunky VRM inductor blocks
CAP_TAN_COL  = "#b8860b";   // tantalum / electrolytic caps
CAP_ALU_COL  = "#3a3f45";   // aluminum can caps
PAD_COL      = "#c7ccd0";   // silver ring pad around mounting holes
LABEL_COL    = "#eceff1";   // white fan label
STEEL_COL    = "#7d8388";   // spring bracket / latches
LATCH_COL    = "#8a9096";   // SODIMM retention latch arms

ZTOP = BOARD_T;             // everything grows up from here

// =====================================================================
// COMPONENT PLACEMENT CONSTANTS  (board-local, all inside 0..203 X,
// 0..197 Y).  Retune HERE — every module reads these, nothing hardcoded.
// Datum reminders:  Y=0 = FRONT (rack I/O) ;  Y=BOARD_D_Y = REAR.
// =====================================================================

// --- 2. BLOWER FAN ---  (front-right, exhaust snout points -Y toward fins)
BLOWER_CX    = 150;         // fan center X
BLOWER_CY    = 52;          // fan center Y (near front)
BLOWER_RO    = 34;          // outer fan radius (enlarged from 30)
BLOWER_H     = 14;          // fan height

// --- 3. HEATSINK FINS ---  (radiator at the FRONT edge, exhaust faces -Y)
FINS_X0      = 116;         // fin block X span...
FINS_X1      = 184;
FINS_Y0      = 2;           // ...sits at the very front edge (Y near 0)
FINS_Y1      = 18;
FINS_H       = 12;

// --- 4. HEATPIPE ---  copper waypoint chain: CPU/GPU plate -> blower.
//   First point sits on the plate (rear), last point at the fan/fins.
HEATPIPE_PTS = [
    [ 78, 150], [ 96, 132], [118, 110],
    [134,  86], [146,  68], [150,  54]
];
// SECOND (forked) branch — GPU branch splits off near the plate and runs
// a short way before merging visually back toward the fan.
HEATPIPE_FORK = [
    [ 78, 150], [ 92, 158], [108, 154], [124, 132], [140, 104]
];
HEATPIPE_R   = 4;           // pipe radius (~D8)

// --- 5. CPU/GPU HEATSINK PLATE ---  (mid/rear of the board)
PLATE_X0     = 58;
PLATE_Y0     = 128;
PLATE_X1     = 122;
PLATE_Y1     = 176;
PLATE_H      = 3;

// --- 5b. VRM / POWER SECTION ---  cluster next to the plate/fan
VRM_X0       = 120;
VRM_X1       = 168;
VRM_Y0       = 150;
VRM_Y1       = 192;

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

// --- 10b. SATA FFC CONNECTOR ---  rear-left/left edge, feeds 2.5" SSD
SATA_X0      = 6;
SATA_X1      = 30;
SATA_Y0      = 144;
SATA_Y1      = 156;

// --- 10c. MOUNTING HOLES ---  4 corners (inset 10) + 1 near center
HOLE_INSET   = 10;
MOUNT_HOLES = [
    [HOLE_INSET,             HOLE_INSET            ],   // FL
    [BOARD_W_X - HOLE_INSET, HOLE_INSET            ],   // FR
    [HOLE_INSET,             BOARD_D_Y - HOLE_INSET],   // RL
    [BOARD_W_X - HOLE_INSET, BOARD_D_Y - HOLE_INSET],   // RR
    [BOARD_W_X/2 + 4,        BOARD_D_Y/2 - 6       ]    // CTR-ish
];
HOLE_R       = 1.75;        // ~D3.5
PAD_R        = 3.2;         // silver ring-pad outer radius

// --- PCB rear-left NOTCH ---  stepped bite out of the slab silhouette
NOTCH_X0     = 0;
NOTCH_X1     = 28;
NOTCH_Y0     = 179;
NOTCH_Y1     = 197;

// --- 11. FRONT-EDGE I/O ---  (Y near 0) HDMI + RJ45 + USB-A x2, spread X.
IO_DEPTH     = 14;          // how far the connector stack reaches in +Y
HDMI_X0      = 14;   HDMI_X1  = 32;     // HDMI
RJ45_X0      = 44;   RJ45_X1  = 64;     // RJ45
USBA1_X0     = 78;   USBA1_X1 = 92;     // USB-A #1
USBA2_X0     = 100;  USBA2_X1 = 114;    // USB-A #2
DISP_X0      = 172;  DISP_X1  = 196;    // display/power connector (black)

// --- 12. REAR-EDGE I/O ---  (Y near BOARD_D_Y) USB-C + SD + audio
USBC_X0      = 30;   USBC_X1  = 44;
SD_X0        = 92;   SD_X1    = 116;
AUDIO_CX     = 188;                     // 3.5mm audio jack barrel center X

// ---------------------------------------------------------------------
// small helpers (UNCHANGED signatures)
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
// NEW small helpers (texture / passives)
// ---------------------------------------------------------------------

// little MLCC / resistor passive: tiny tan or grey chip
module passive_0805(cx, cy, col="#cdb892") {
    color(col)
        rrect_prism(cx - 1.0, cy - 0.6, cx + 1.0, cy + 0.6, ZTOP, 0.7, r=0.2);
}

// tantalum / electrolytic cap can
module cap_can(cx, cy, r=1.6, h=3.5, col=CAP_TAN_COL) {
    color(col) translate([cx, cy, ZTOP]) cylinder(h = h, r = r);
    // marked + stripe on top
    color("#1a1a1a")
        translate([cx, cy, ZTOP + h]) cylinder(h = 0.3, r = r*0.55);
}

// VRM MOSFET (small black square package with a silver tab hint)
module mosfet(cx, cy, s=4) {
    color(CHIP_COL)
        rrect_prism(cx - s/2, cy - s/2, cx + s/2, cy + s/2, ZTOP, 1.6, r=0.4);
    color(METAL_COL)
        box2(cx - s/2, cy + s/2 - 0.6, cx + s/2, cy + s/2, ZTOP, 1.7);
}

// chunky VRM power inductor (~6x6x4 dark block, slightly bevelled)
module inductor(cx, cy, sx=6.5, sy=6.5, h=4.2) {
    color(IND_COL)
        rrect_prism(cx - sx/2, cy - sy/2, cx + sx/2, cy + sy/2, ZTOP, h, r=1.0);
    // a faint metal winding hint on top
    color("#4a4d52")
        rrect_prism(cx - sx/2 + 1, cy - sy/2 + 1, cx + sx/2 - 1, cy + sy/2 - 1,
                    ZTOP + h, 0.3, r=0.6);
}

// ---------------------------------------------------------------------
// 1. PCB SLAB  (dark blue, rounded corners) — with rear-left NOTCH bored
//    and mounting holes drilled through.
// ---------------------------------------------------------------------
module rb_pcb() {
    color(PCB_COL)
        difference() {
            rrect_prism(0, 0, BOARD_W_X, BOARD_D_Y, 0, BOARD_T, r=5);
            // rear-left stepped notch — break the plain rounded silhouette
            translate([NOTCH_X0 - 1, NOTCH_Y0, -1])
                cube([NOTCH_X1 - NOTCH_X0 + 1, NOTCH_Y1 - NOTCH_Y0 + 2, BOARD_T + 2]);
            // second, smaller step so the bite is "stepped" not a flat cut
            translate([NOTCH_X1, NOTCH_Y0 + 8, -1])
                cube([12, NOTCH_Y1 - NOTCH_Y0, BOARD_T + 2]);
            // bore the mounting holes through the slab
            for (h = MOUNT_HOLES)
                translate([h[0], h[1], -1])
                    cylinder(h = BOARD_T + 2, r = HOLE_R);
        }
}

// silver ring pads around each mounting hole, sitting on the PCB top
module rb_mount_pads() {
    color(PAD_COL)
        for (h = MOUNT_HOLES)
            difference() {
                translate([h[0], h[1], ZTOP - 0.2]) cylinder(h = 0.5, r = PAD_R);
                translate([h[0], h[1], ZTOP - 1]) cylinder(h = 2, r = HOLE_R + 0.2);
            }
}

// ---------------------------------------------------------------------
// 2. BLOWER FAN  (volute/scroll housing + hub + intake + skewed blades +
//    white top label).  Front-right; exhaust snout points -Y toward fins.
// ---------------------------------------------------------------------
module rb_blower(cx=BLOWER_CX, cy=BLOWER_CY) {
    rO = BLOWER_RO;     // outer fan radius
    fh = BLOWER_H;      // fan height
    z0 = ZTOP;

    // ---- volute / scroll housing ----
    color(FAN_COL) {
        translate([cx, cy, z0]) {
            cylinder(h = fh, r = rO);
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

    // ---- top intake ring ----
    difference() {
        color(FAN_COL)
            translate([cx, cy, z0 + fh - 1.5])
                cylinder(h = 2.0, r1 = rO * 0.92, r2 = rO * 0.82);
        translate([cx, cy, z0 + fh - 2.0])
            cylinder(h = 4, r = rO * 0.66);
    }

    // ---- hub ----
    color(HUB_COL)
        translate([cx, cy, z0 + fh - 3.0])
            cylinder(h = 3.2, r = 11);

    // ---- skewed blades peeking through the intake ----
    color("#3a3d42")
        translate([cx, cy, z0 + fh - 3.2])
            for (a = [0:14:359])
                rotate([0, 0, a])
                    translate([14, 0, 0])
                        rotate([0, 0, 28])
                            cube([17, 1.1, 2.6], center = true);

    // ---- white rectangular label on the top rim (off to one side) ----
    color(LABEL_COL)
        translate([cx + rO*0.30, cy + rO*0.34, z0 + fh])
            rrect_prism(0, 0, 14, 8, 0, 0.4, r=1);
}

// ---------------------------------------------------------------------
// 3. HEATSINK FINS  (exhaust radiator) — individual vertical fins at the
//    FRONT edge beside the fan; airflow blows -Y toward the rack front.
// ---------------------------------------------------------------------
module rb_fins(x0=FINS_X0, x1=FINS_X1, y0=FINS_Y0, y1=FINS_Y1, h=FINS_H) {
    z0 = ZTOP;
    finT  = 0.7;        // fin thickness (along X)
    pitch = 1.9;        // tighter pitch -> denser radiator
    n = floor((x1 - x0) / pitch);
    color(METAL_COL) {
        // top + bottom cap rails
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
//    CPU/GPU plate (rear) forward to the fan/fins (front).  FORKED: a
//    second short branch reads as a dual CPU+GPU heatpipe.
// ---------------------------------------------------------------------
module rb_pipe_chain(pts, rP, zc) {
    color(PIPE_COL)
        for (i = [0 : len(pts) - 2])
            hull() {
                translate([pts[i][0],   pts[i][1],   zc])
                    scale([1, 1, 0.7]) sphere(r = rP);
                translate([pts[i+1][0], pts[i+1][1], zc])
                    scale([1, 1, 0.7]) sphere(r = rP);
            }
}

module rb_heatpipe() {
    rP = HEATPIPE_R;                // pipe radius (~D8)
    zc = ZTOP + PLATE_H + 2.0;      // ride a touch above the plate top
    rb_pipe_chain(HEATPIPE_PTS, rP, zc);             // main (CPU) branch
    rb_pipe_chain(HEATPIPE_FORK, rP * 0.82, zc - 0.4); // GPU fork branch
    // flattened contact saddle where the pipe meets the plate
    color(PIPE_COL)
        translate([HEATPIPE_PTS[0][0], HEATPIPE_PTS[0][1], ZTOP + PLATE_H])
            scale([1.6, 1.6, 0.5]) sphere(r = rP);
    // a clamp tab where the fork emerges from the plate
    color(STEEL_COL)
        translate([HEATPIPE_FORK[1][0], HEATPIPE_FORK[1][1], zc])
            rrect_prism(-4, -3, 4, 3, 0, 0.8, r=1);
}

// ---------------------------------------------------------------------
// 5. CPU/GPU HEATSINK PLATE  (flat silver) with a thin X-shaped spring
//    bracket on top.  Mid/rear of the board.  (X bracket bug kept fixed.)
// ---------------------------------------------------------------------
module rb_cpu_plate(x0=PLATE_X0, y0=PLATE_Y0, x1=PLATE_X1, y1=PLATE_Y1, h=PLATE_H) {
    z0 = ZTOP;
    color(METAL_COL)
        rrect_prism(x0, y0, x1, y1, z0, h, r=2);

    // two raised copper die-contact pads (CPU + GPU)
    color(PIPE_COL) {
        translate([x0 + 16, y0 + 16, z0 + h - 0.4])
            rrect_prism(0, 0, 14, 14, 0, 0.8, r=1);
        translate([x0 + 36, y0 + 24, z0 + h - 0.4])
            rrect_prism(0, 0, 14, 14, 0, 0.8, r=1);
    }

    // ---- X-shaped spring bracket (two crossed steel arms + 4 turrets) ----
    cx = (x0 + x1)/2; cy = (y0 + y1)/2;
    plateW = x1 - x0; plateD = y1 - y0;
    armT = 1.6;
    inset = 4;
    diag  = sqrt(plateW*plateW + plateD*plateD);
    armL  = diag - 2*inset;
    armW  = 5;
    ang = atan2(plateD, plateW);
    bz = z0 + h;
    color(STEEL_COL) {
        translate([cx, cy, bz + armT/2])
            rotate([0, 0,  ang])
                cube([armL, armW, armT], center = true);
        translate([cx, cy, bz + armT/2])
            rotate([0, 0, -ang])
                cube([armL, armW, armT], center = true);
        // 4 hold-down screw turrets — AT THE PLATE CORNERS (kept fixed)
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
// 5b. VRM / POWER SECTION  — MOSFET array (2 rows) + inductors + caps.
//     Sits between the plate and the fan/rear-right.
// ---------------------------------------------------------------------
module rb_vrm() {
    // 2 rows of MOSFETs (4 per row = 8) along X
    for (row = [0:1])
        for (i = [0:3])
            mosfet(VRM_X0 + 6 + i*9, VRM_Y0 + 6 + row*8, 5);

    // 3 chunky inductors above the MOSFETs
    for (i = [0:2])
        inductor(VRM_X0 + 9 + i*14, VRM_Y0 + 30, 7, 7, 4.4);

    // cap bank — a cluster of tantalum/aluminum cans beside the inductors
    for (p = [
            [VRM_X0 + 4,  VRM_Y1 - 6], [VRM_X0 + 4,  VRM_Y1 - 12],
            [VRM_X0 + 40, VRM_Y0 + 4], [VRM_X0 + 44, VRM_Y0 + 10],
            [VRM_X1 - 4,  VRM_Y0 + 18]
        ])
        cap_can(p[0], p[1], 1.7, 3.6, CAP_TAN_COL);

    // a couple of bigger aluminum can caps
    color(CAP_ALU_COL) {
        translate([VRM_X1 - 6, VRM_Y1 - 8, ZTOP]) cylinder(h = 5.5, r = 3);
        translate([VRM_X0 + 22, VRM_Y1 - 5, ZTOP]) cylinder(h = 5.0, r = 2.6);
    }
    // top caps for the aluminum cans (cross-vent score)
    color("#202327") {
        translate([VRM_X1 - 6, VRM_Y1 - 8, ZTOP + 5.5]) cylinder(h = 0.3, r = 3);
        translate([VRM_X0 + 22, VRM_Y1 - 5, ZTOP + 5.0]) cylinder(h = 0.3, r = 2.6);
    }
    // a small driver IC for the VRM
    smd_chip(VRM_X0 + 30, VRM_Y0 + 30, 6, 6, 1.4);
}

// ---------------------------------------------------------------------
// 6. SODIMM SLOTS  (slot1 populated w/ green RAM, slot2 empty) +
//    metal retention latch arms at both ends.
// ---------------------------------------------------------------------
module rb_sodimm(y0, y1, populated=false) {
    z0 = ZTOP;
    sh = 5;     // slot height
    x0 = SODIMM_X0; x1 = SODIMM_X1;
    // black slot body with the central key gap
    color(SLOT_COL) {
        box2(x0, y0, x1, y0 + 1.6, z0, sh);             // front rail
        box2(x0, y1 - 1.6, x1, y1, z0, sh);             // rear rail
        box2(x0, y0, x0 + 3, y1, z0, sh);               // left end
        box2(x1 - 3, y0, x1, y1, z0, sh);               // right end
    }
    // metal RETENTION LATCH ARMS (spring clips) at both slot ends
    color(LATCH_COL) {
        // left latch arm pair
        translate([x0 - 2, y0 - 1, z0]) box2(0, 0, 2.2, (y1-y0)+2, 0, sh + 1.5);
        translate([x0 - 2, y0 - 1, z0 + sh + 1.5]) box2(0, 0, 4.5, 2, 0, 1.0);
        translate([x0 - 2, y1 - 1, z0 + sh + 1.5]) box2(0, 0, 4.5, 2, 0, 1.0);
        // right latch arm pair
        translate([x1 - 0.2, y0 - 1, z0]) box2(0, 0, 2.2, (y1-y0)+2, 0, sh + 1.5);
        translate([x1 - 2.5, y0 - 1, z0 + sh + 1.5]) box2(0, 0, 4.5, 2, 0, 1.0);
        translate([x1 - 2.5, y1 - 1, z0 + sh + 1.5]) box2(0, 0, 4.5, 2, 0, 1.0);
    }
    if (populated) {
        // green RAM module lying flat on top of the slot
        color(RAM_COL)
            rrect_prism(x0 + 5, y0 + 1, x1 - 5, y1 - 1, z0 + sh - 1.2, 1.6, r=1);
        // a row of black DRAM chips on the module
        for (i = [0:7])
            smd_chip(x0 + 13 + i*15, (y0 + y1)/2, 9, 4.2, 0.9);
        // gold edge-connector hint along the front of the module
        color(GOLD_COL)
            box2(x0 + 7, y0 + 1, x1 - 7, y0 + 2.0, z0 + sh - 1.3, 0.5);
        // SPD chip + a couple passives on the module
        smd_chip(x1 - 16, (y0+y1)/2 + 1.5, 3, 3, 0.8);
    }
}

// ---------------------------------------------------------------------
// 7. DRAM CHIPS  — row of ~4 black rectangles in the front-center area
// ---------------------------------------------------------------------
module rb_dram_row() {
    for (i = [0:3])
        smd_chip(DRAM_X0 + i*DRAM_DX, DRAM_Y, 16, 12, 1.6);
}

// ---------------------------------------------------------------------
// 8. M.2 / NGFF SSD  — connector rear-right + green card lying flat -X,
//    refined gold contacts, NAND/controller chips, standoff screw.
// ---------------------------------------------------------------------
module rb_m2() {
    z0 = ZTOP;
    cMidY = (M2_CONN_Y0 + M2_CONN_Y1)/2;
    // connector body
    color(SLOT_COL) box2(M2_CONN_X0, M2_CONN_Y0, M2_CONN_X1, M2_CONN_Y1, z0, 4);
    // gold contacts — a fine comb of fingers inside the throat
    color(GOLD_COL)
        for (i = [0:6])
            box2(M2_CONN_X0 + 0.5, M2_CONN_Y0 + 1 + i*0.8,
                 M2_CONN_X0 + 4,   M2_CONN_Y0 + 1.4 + i*0.8, z0 + 0.5, 2.0);
    // green M.2 card lying flat (extends toward -X from the connector)
    color(RAM_COL)
        rrect_prism(M2_CARD_X0, M2_CARD_Y - 5, M2_CONN_X0, M2_CARD_Y + 5, z0 + 1.2, 1.0, r=1);
    // gold edge fingers at the card's connector end
    color(GOLD_COL)
        for (i = [0:9])
            box2(M2_CONN_X0 - 3, M2_CARD_Y - 4.5 + i*0.95,
                 M2_CONN_X0 - 0.5, M2_CARD_Y - 4.1 + i*0.95, z0 + 2.1, 0.3);
    // NAND + controller chips on the card
    smd_chip(M2_CARD_X0 + 20, M2_CARD_Y - 1.5, 16, 5, 0.9);
    smd_chip(M2_CARD_X0 + 44, M2_CARD_Y - 1.5, 16, 5, 0.9);
    smd_chip(M2_CARD_X0 + 32, M2_CARD_Y + 3,   8,  4, 0.7);  // controller
    // standoff screw boss at the far end of the card
    color(CONN_COL) translate([M2_CARD_X0 + 2, M2_CARD_Y, z0 + 2.2]) cylinder(h = 0.8, r = 2);
    color(STEEL_COL) translate([M2_CARD_X0 + 2, M2_CARD_Y, z0 + 3.0]) cylinder(h = 0.4, r = 1.4);
}

// ---------------------------------------------------------------------
// 9. WLAN NGFF  — small slot rear-left + tiny card + wifi chip + 2 u.fl
// ---------------------------------------------------------------------
module rb_wlan() {
    z0 = ZTOP;
    cMidY = (WLAN_SLOT_Y0 + WLAN_SLOT_Y1)/2;
    color(SLOT_COL) box2(WLAN_SLOT_X0, WLAN_SLOT_Y0, WLAN_SLOT_X1, WLAN_SLOT_Y1, z0, 3.5);
    // gold contacts in the WLAN slot
    color(GOLD_COL)
        box2(WLAN_SLOT_X0 + 0.5, cMidY - 1.5, WLAN_SLOT_X0 + 2, cMidY + 1.5, z0 + 0.4, 1.8);
    color(RAM_COL)  rrect_prism(WLAN_CARD_X0, WLAN_CARD_Y - 3, WLAN_CARD_X1, WLAN_CARD_Y + 3, z0 + 1.0, 0.9, r=1);
    smd_chip((WLAN_CARD_X0 + WLAN_CARD_X1)/2, WLAN_CARD_Y, 9, 4, 0.8);   // wifi chip
    // two tiny antenna u.fl connectors (gold/silver nubs)
    color(COIN_COL) {
        translate([WLAN_CARD_X0 + 4, WLAN_CARD_Y - 1.5, z0 + 1.9]) cylinder(h = 1.4, r = 1.1);
        translate([WLAN_CARD_X0 + 4, WLAN_CARD_Y + 1.5, z0 + 1.9]) cylinder(h = 1.4, r = 1.1);
    }
    color(GOLD_COL) {
        translate([WLAN_CARD_X0 + 4, WLAN_CARD_Y - 1.5, z0 + 3.3]) cylinder(h = 0.3, r = 0.6);
        translate([WLAN_CARD_X0 + 4, WLAN_CARD_Y + 1.5, z0 + 3.3]) cylinder(h = 0.3, r = 0.6);
    }
}

// ---------------------------------------------------------------------
// 10. COIN CELL (CMOS)  — silver cylinder D16 x ~3 + terminal nub
// ---------------------------------------------------------------------
module rb_coincell(cx=COIN_CX, cy=COIN_CY) {
    color(COIN_COL)
        translate([cx, cy, ZTOP]) cylinder(h = 3.2, r = 8);
    // rim crimp
    color("#aeb2b6")
        translate([cx, cy, ZTOP]) cylinder(h = 0.6, r = 8);
    // + terminal nub on top
    color("#9aa0a6")
        translate([cx, cy, ZTOP + 3.2]) cylinder(h = 0.4, r = 4);
    // small retention clip terminal to one side
    color(STEEL_COL)
        translate([cx + 8, cy - 2, ZTOP]) box2(0, 0, 3, 4, 0, 2.5);
}

// ---------------------------------------------------------------------
// 10b. SATA FFC CONNECTOR  — low flat black connector w/ flip-up latch
//      bar, on the rear-left/left edge.  Feeds the 2.5" SSD ribbon.
// ---------------------------------------------------------------------
module rb_sata_ffc() {
    z0 = ZTOP;
    // low flat black body
    color(SLOT_COL)
        rrect_prism(SATA_X0, SATA_Y0, SATA_X1, SATA_Y1, z0, 2.4, r=0.6);
    // flip-up latch bar (lighter, sits along the rear lip, tilted slightly)
    color("#33373c")
        translate([SATA_X0 + 1, SATA_Y1 - 2.2, z0 + 2.0])
            rotate([18, 0, 0])
                box2(0, 0, (SATA_X1 - SATA_X0) - 2, 1.6, 0, 1.4);
    // gold contact comb inside the throat (front lip)
    color(GOLD_COL)
        for (i = [0 : floor((SATA_X1 - SATA_X0 - 4)/1.4)])
            box2(SATA_X0 + 2 + i*1.4, SATA_Y0 + 1.2,
                 SATA_X0 + 2.6 + i*1.4, SATA_Y0 + 3.5, z0 + 0.6, 0.5);
    // stub of the FFC ribbon poking out (tan flex)
    color("#caa46a")
        box2(SATA_X0 + 3, SATA_Y0 - 5, SATA_X1 - 3, SATA_Y0 + 0.5, z0 + 0.4, 0.4);
}

// ---------------------------------------------------------------------
// 11. FRONT-EDGE CONNECTORS  (Y near 0) — metallic boxes, spread across X.
//     HDMI + RJ45 + USB-A x2  + black DC/display connector. Refined
//     metal-shell look: shells with chamfered lips + visible throats.
// ---------------------------------------------------------------------
module rb_front_io() {
    z0 = ZTOP;
    d  = IO_DEPTH;

    // --- HDMI: metal shell with a dark throat ---
    color(CONN_COL) box2(HDMI_X0, 0, HDMI_X1, d, z0, 6);
    color(SLOT_COL) box2(HDMI_X0 + 1.5, 0, HDMI_X1 - 1.5, 2.5, z0 + 1.2, 3.6);
    color(GOLD_COL) box2(HDMI_X0 + 3, 0, HDMI_X1 - 3, 1.2, z0 + 2.6, 0.6);  // contacts

    // --- RJ45: taller magjack w/ dark throat + LED hint ---
    color(CONN_COL) box2(RJ45_X0, 0, RJ45_X1, d, z0, 7.8);
    color(SLOT_COL) box2(RJ45_X0 + 2, 0, RJ45_X1 - 2, 2.5, z0 + 1.5, 5.0);  // throat
    color(GOLD_COL)                                                          // gold pins
        for (i = [0:7])
            box2(RJ45_X0 + 3 + i*1.9, 0, RJ45_X0 + 3.6 + i*1.9, 1.0, z0 + 5.0, 1.2);
    color("#1f8a3a") translate([RJ45_X0 + 2.5, 1.5, z0 + 6.8]) cube([1.5, 0.6, 0.8]); // LED
    color("#c08a1a") translate([RJ45_X1 - 4,   1.5, z0 + 6.8]) cube([1.5, 0.6, 0.8]); // LED

    // --- USB-A x2: metal shell, blue inner tongue ---
    color(CONN_COL) {
        box2(USBA1_X0, 0, USBA1_X1, d, z0, 6.5);
        box2(USBA2_X0, 0, USBA2_X1, d, z0, 6.5);
    }
    color("#1f4fa0") {
        box2(USBA1_X0 + 2, 0, USBA1_X1 - 2, 2.0, z0 + 1.8, 3.2);
        box2(USBA2_X0 + 2, 0, USBA2_X1 - 2, 2.0, z0 + 1.8, 3.2);
    }
    color(GOLD_COL) {  // gold contacts on the blue tongues
        box2(USBA1_X0 + 3, 0, USBA1_X1 - 3, 1.0, z0 + 2.6, 1.8);
        box2(USBA2_X0 + 3, 0, USBA2_X1 - 3, 1.0, z0 + 2.6, 1.8);
    }

    // --- black DC/display connector at the end ---
    color(SLOT_COL) box2(DISP_X0, 0, DISP_X1, 8, z0, 4.5);
    color(GOLD_COL)
        for (i = [0:5])
            box2(DISP_X0 + 2 + i*3.5, 0, DISP_X0 + 3.5 + i*3.5, 1.0, z0 + 1.0, 2.5);
}

// ---------------------------------------------------------------------
// 12. REAR-EDGE CONNECTORS  (Y near BOARD_D_Y) — USB-C + SD + audio (light hint)
// ---------------------------------------------------------------------
module rb_rear_io() {
    z0 = ZTOP;
    yR = BOARD_D_Y;       // 197
    color(CONN_COL) {
        box2(USBC_X0, yR - 12, USBC_X1, yR, z0, 5);    // USB-C
        box2(SD_X0,   yR - 14, SD_X1,   yR, z0, 4);    // SD slot
    }
    // USB-C inner pill + gold
    color(SLOT_COL)
        translate([(USBC_X0 + USBC_X1)/2, yR - 6, z0 + 1.2])
            scale([1.6, 0.5, 1]) cylinder(h = 2.4, r = 2.5);
    color(GOLD_COL)
        translate([(USBC_X0 + USBC_X1)/2, yR - 6, z0 + 2.2])
            scale([1.4, 0.35, 1]) cylinder(h = 0.5, r = 2.5);
    // 3.5mm audio jack barrel
    color(SLOT_COL)
        translate([AUDIO_CX, yR - 6, z0]) cylinder(h = 6, r = 3);
    color(METAL_COL)
        translate([AUDIO_CX, yR - 6, z0 + 6]) cylinder(h = 0.6, r = 3);
}

// ---------------------------------------------------------------------
// 13. PCH / EC / SCATTERED SMD CHIPS  — dense texture across open PCB.
//     Big PCH + EC squares plus many small chips/passives.
// ---------------------------------------------------------------------
module rb_scatter() {
    // big chipset squares: PCH + EC
    smd_chip(176, 100, 14, 14, 2.4);   // PCH/chipset (rear-right)  big square
    color("#1a1c20")                   // ball-grid skirt under the PCH
        rrect_prism(176 - 8, 100 - 8, 176 + 8, 100 + 8, ZTOP, 0.5, r=1);
    smd_chip(60, 50, 11, 11, 2.0);     // EC (embedded controller) square
    // dot-1 markers on the big chips
    color("#34373c") {
        translate([176 - 5, 100 + 5, ZTOP + 2.4]) cylinder(h = 0.3, r = 0.8);
        translate([60 - 4,  50 + 4,  ZTOP + 2.0]) cylinder(h = 0.3, r = 0.7);
    }

    // [cx, cy, sx, sy, h]  — denser medium SMD population
    spots = [
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
        [ 96, 158,  5, 9, 1.4],
        [196,  40,  5, 5, 1.0],
        [  8, 110,  5, 12, 1.2],   // edge connector strip (left edge)
        [168,  88,  7, 7, 1.5],    // near PCH
        [160, 110,  6, 6, 1.3],
        [104, 100,  6, 6, 1.2],
        [ 86, 122,  5, 5, 1.1],
        [ 50, 110,  6, 6, 1.3],
        [ 32, 110,  5, 5, 1.1],
        [ 14,  66,  6, 8, 1.3],
        [200, 100,  4, 7, 1.1],    // right edge strip
        [ 70,  44,  7, 5, 1.3],
        [118, 152,  5, 5, 1.2],
    ];
    for (s = spots)
        smd_chip(s[0], s[1], s[2], s[3], s[4]);

    // tantalum / electrolytic cap cans scattered for realism
    for (p = [[60, 158], [50, 150], [44, 162], [160, 142], [170, 132],
              [196, 56], [196, 84], [12, 92], [12, 128], [108, 138],
              [126, 100], [150, 122]])
        cap_can(p[0], p[1], 1.6, 3.4, CAP_TAN_COL);

    // a sea of tiny 0805 passives (MLCC / resistors) for density
    for (p = [
            [44, 48], [48, 48], [52, 48], [56, 48],
            [44, 64], [48, 64], [52, 64],
            [90, 50], [94, 50], [98, 50],
            [110, 60], [114, 60], [118, 60],
            [30, 100], [34, 100], [38, 100],
            [160, 70], [164, 70], [168, 72],
            [184, 134], [188, 134], [192, 134],
            [70, 132], [74, 132], [78, 132],
            [100, 122], [104, 122],
            [20, 60], [24, 60],
            [200, 120], [200, 124],
            [132, 116], [136, 116], [140, 116],
            [180, 60], [184, 60]
        ])
        passive_0805(p[0], p[1]);
}

// =====================================================================
// TOP-LEVEL: reference_board()
// =====================================================================
module reference_board() {
    rb_pcb();
    rb_mount_pads();

    // thermal solution (front-facing exhaust)
    rb_cpu_plate();
    rb_heatpipe();
    rb_fins();
    rb_blower();

    // power delivery
    rb_vrm();

    // memory
    rb_sodimm(SODIMM1_Y0, SODIMM1_Y1, populated = true);   // SODIMM slot 1 (populated)
    rb_sodimm(SODIMM2_Y0, SODIMM2_Y1, populated = false);  // SODIMM slot 2 (empty)
    rb_dram_row();

    // storage / radios
    rb_m2();
    rb_wlan();
    rb_sata_ffc();

    // misc on-board
    rb_coincell();

    // edge I/O
    rb_front_io();
    rb_rear_io();

    // dense SMD texture (PCH/EC + passives)
    rb_scatter();
}

// ---- standalone preview (board-local). main.scad 'use's the module and
//      places it at the board datum; this call only runs when this file is
//      opened directly, and is hidden by 'use'. Modest $fn for fast renders.
$fa = 4;
$fs = 0.6;
reference_board();
