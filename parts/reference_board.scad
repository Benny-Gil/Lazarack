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
//   PCB occupies  X 0..BOARD_W_X (=170, width)
//                 Y 0..BOARD_D_Y (=235, depth)   Y=0 = FRONT (rack I/O)
//                 Z 0..BOARD_T   (~2, the PCB slab)
//   ALL components sit ON TOP, growing +Z from Z=BOARD_T.
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
//    centered near (X=118, Y=72), round body ~D60, ~14 tall.
// ---------------------------------------------------------------------
module rb_blower(cx=118, cy=72) {
    rO = 30;        // outer fan radius
    fh = 14;        // fan height
    z0 = ZTOP;

    // ---- volute / scroll housing: round body that grows a tangential
    //      exhaust snout toward the heatsink (front-left, toward -Y/-X) ----
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
            translate([cx - 6, cy - rO + 2, z0]) cube([24, 6, fh]);
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
//    FRONT edge beside the fan.  Roughly X 96..146, Y 5..18, ~12 tall.
//    Exhaust faces the front (Y~0): fins run along X, gaps along X.
// ---------------------------------------------------------------------
module rb_fins(x0=96, x1=146, y0=5, y1=18, h=12) {
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
//    CPU/GPU plate (~X 60, Y 168) to the fan/fins (~X 112, Y 60).
// ---------------------------------------------------------------------
module rb_heatpipe() {
    rP = 4;                         // pipe radius (~D8)
    zc = ZTOP + 3 + 2.0;            // ride a touch above the plate top
    // curved waypoint chain (board-local). Flattened, slightly elliptical
    // cross-section like a real laptop heatpipe.
    pts = [
        [60, 168], [54, 140], [62, 116],
        [82, 96],  [98, 78],  [112, 60]
    ];
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
        translate([60, 168, ZTOP + 3])
            scale([1.6, 1.6, 0.5]) sphere(r = rP);
}

// ---------------------------------------------------------------------
// 5. CPU/GPU HEATSINK PLATE  (flat silver) X 45..108, Y 150..196, ~3 tall
//    with a thin X-shaped spring bracket on top.
// ---------------------------------------------------------------------
module rb_cpu_plate(x0=45, y0=150, x1=108, y1=196, h=3) {
    z0 = ZTOP;
    color(METAL_COL)
        rrect_prism(x0, y0, x1, y1, z0, h, r=2);

    // two raised copper die-contact pads (CPU + GPU) under the plate area
    color(PIPE_COL) {
        translate([x0 + 16, y0 + 18, z0 + h - 0.4])
            rrect_prism(0, 0, 14, 14, 0, 0.8, r=1);
        translate([x0 + 36, y0 + 26, z0 + h - 0.4])
            rrect_prism(0, 0, 14, 14, 0, 0.8, r=1);
    }

    // ---- X-shaped spring bracket (two crossed steel arms + 4 screw bosses) ----
    cx = (x0 + x1)/2; cy = (y0 + y1)/2;
    armL = 64; armW = 5; armT = 1.6;
    bz = z0 + h;                    // bracket rides on the plate top
    color("#7d8388") {
        // crossed arms (a thin X), centered on the plate
        translate([cx, cy, bz + armT/2])
            rotate([0, 0, 38])
                cube([armL, armW, armT], center = true);
        translate([cx, cy, bz + armT/2])
            rotate([0, 0, -38])
                cube([armL, armW, armT], center = true);
        // 4 hold-down screw turrets at the X arm tips (compute tip xy, then
        // place an upright cylinder there — no frame rotation, so they can't
        // fly off the board)
        for (a = [38, -38, 142, -142]) {
            tx = cx + (armL/2 - 3) * cos(a);
            ty = cy + (armL/2 - 3) * sin(a);
            translate([tx, ty, bz]) cylinder(h = 2.6, r = 2.6);
        }
    }
}

// ---------------------------------------------------------------------
// 6. SODIMM SLOTS  (slot1 populated w/ green RAM, slot2 empty)
// ---------------------------------------------------------------------
module rb_sodimm(y0, y1, populated=false) {
    z0 = ZTOP;
    sh = 5;     // slot height
    // black slot body with the central key gap
    color(SLOT_COL) {
        box2(15, y0, 150, y0 + 1.6, z0, sh);            // front rail
        box2(15, y1 - 1.6, 150, y1, z0, sh);            // rear rail
        box2(15, y0, 18, y1, z0, sh);                   // left end (latch)
        box2(147, y0, 150, y1, z0, sh);                 // right end (latch)
    }
    if (populated) {
        // green RAM module lying flat on top of the slot
        color(RAM_COL)
            rrect_prism(20, y0 + 1, 145, y1 - 1, z0 + sh - 1.2, 1.6, r=1);
        // a row of black DRAM chips on the module
        for (i = [0:7])
            smd_chip(28 + i*15, (y0 + y1)/2, 9, 4.2, 0.9);
        // gold edge-connector hint along the front of the module
        color("#c9a23a")
            box2(22, y0 + 1, 143, y0 + 2.0, z0 + sh - 1.3, 0.5);
    }
}

// ---------------------------------------------------------------------
// 7. DRAM CHIPS  — row of ~4 black rectangles  X 55..135, Y 90..104
// ---------------------------------------------------------------------
module rb_dram_row() {
    for (i = [0:3])
        smd_chip(62 + i*22, 97, 16, 12, 1.6);
}

// ---------------------------------------------------------------------
// 8. M.2 / NGFF SSD  — connector near (X 96..104, Y 176..184) + green
//    card lying flat X 18..96, Y 177..183.
// ---------------------------------------------------------------------
module rb_m2() {
    z0 = ZTOP;
    // connector
    color(SLOT_COL) box2(96, 176, 104, 184, z0, 4);
    color("#c9a23a") box2(96, 178.5, 100, 181.5, z0 + 0.5, 2.2);   // gold contacts
    // green M.2 card lying flat
    color(RAM_COL)
        rrect_prism(18, 177, 96, 183, z0 + 1.2, 1.0, r=1);
    // a couple of NAND/controller chips on the card
    smd_chip(40, 180, 16, 4, 0.8);
    smd_chip(66, 180, 16, 4, 0.8);
    // standoff screw boss at the far end of the card
    color(CONN_COL) translate([20, 180, z0 + 2.2]) cylinder(h = 0.8, r = 2);
}

// ---------------------------------------------------------------------
// 9. WLAN NGFF  — small slot near (X 78, Y 212) + tiny card
// ---------------------------------------------------------------------
module rb_wlan() {
    z0 = ZTOP;
    color(SLOT_COL) box2(74, 210, 82, 214, z0, 3.5);
    color(RAM_COL)  rrect_prism(50, 209, 74, 215, z0 + 1.0, 0.9, r=1);  // mini card
    smd_chip(60, 212, 9, 4, 0.8);                                       // wifi chip
    // two tiny antenna u.fl connectors
    color(COIN_COL) {
        translate([55, 211, z0 + 1.9]) cylinder(h = 1.2, r = 1.1);
        translate([55, 213, z0 + 1.9]) cylinder(h = 1.2, r = 1.1);
    }
}

// ---------------------------------------------------------------------
// 10. COIN CELL (CMOS)  — silver cylinder D16 x ~3 near (X 140, Y 35)
// ---------------------------------------------------------------------
module rb_coincell(cx=140, cy=35) {
    color(COIN_COL)
        translate([cx, cy, ZTOP]) cylinder(h = 3.2, r = 8);
    // little + terminal nub on top
    color("#9aa0a6")
        translate([cx, cy, ZTOP + 3.2]) cylinder(h = 0.4, r = 4);
}

// ---------------------------------------------------------------------
// 11. FRONT-EDGE CONNECTORS  (Y near 0) — metallic boxes
// ---------------------------------------------------------------------
module rb_front_io() {
    z0 = ZTOP;
    color(CONN_COL) {
        box2(25, 0, 43, 14, z0, 6);     // HDMI
        box2(50, 0, 64, 14, z0, 6.5);   // USB-A #1
        box2(70, 0, 84, 14, z0, 6.5);   // USB-A #2
    }
    color(SLOT_COL)
        box2(128, 0, 150, 8, z0, 4);    // display/power connector (black)
    // USB ports: blue inner tongue so they read as USB
    color("#1f4fa0") {
        box2(52, 0, 62, 1.5, z0 + 1.5, 3.5);
        box2(72, 0, 82, 1.5, z0 + 1.5, 3.5);
    }
}

// ---------------------------------------------------------------------
// 12. REAR-EDGE CONNECTORS  (Y near 235) — metallic
// ---------------------------------------------------------------------
module rb_rear_io() {
    z0 = ZTOP;
    yR = BOARD_D_Y;       // 235
    color(CONN_COL) {
        box2(30, yR - 12, 44, yR, z0, 5);      // USB-C
        box2(90, yR - 14, 114, yR, z0, 4);     // SD slot
    }
    // USB-C inner pill
    color(SLOT_COL)
        translate([37, yR - 6, z0 + 1.2]) scale([1.6, 0.5, 1]) cylinder(h = 2.4, r = 2.5);
    // 3.5mm audio jack barrel, D6
    color(SLOT_COL)
        translate([150, yR - 6, z0]) cylinder(h = 6, r = 3);
    color(METAL_COL)
        translate([150, yR - 6, z0 + 6]) cylinder(h = 0.6, r = 3);
}

// ---------------------------------------------------------------------
// 13. SCATTERED SMD CHIPS  — texture across the open PCB areas
// ---------------------------------------------------------------------
module rb_scatter() {
    // [cx, cy, sx, sy, h]
    spots = [
        [128, 100, 10, 8, 2.0],   // PCH-ish big chip
        [150, 70,  9,  9, 1.6],
        [156, 110, 7,  7, 1.4],
        [40,  60,  8,  6, 1.4],
        [30,  90,  6,  6, 1.2],
        [22,  150, 7,  9, 1.4],
        [150, 150, 8,  6, 1.4],
        [158, 180, 6,  6, 1.2],
        [120, 200, 9,  7, 1.6],
        [40,  205, 7,  7, 1.4],
        [108, 130, 6,  5, 1.2],
        [88,  150, 5,  9, 1.4],   // tall MOSFET-ish
        [162, 40,  5,  5, 1.0],
        [10,  120, 5,  12, 1.2],  // edge connector strip
    ];
    for (s = spots)
        smd_chip(s[0], s[1], s[2], s[3], s[4]);

    // a few tiny passives (tantalum/electrolytic caps) for realism
    color("#b8860b")
        for (p = [[135, 175], [142, 165], [128, 168], [50, 175], [44, 165]])
            translate([p[0], p[1], ZTOP]) cylinder(h = 3.5, r = 1.6);
}

// =====================================================================
// TOP-LEVEL: reference_board()
// =====================================================================
module reference_board() {
    rb_pcb();

    // thermal solution
    rb_cpu_plate();
    rb_heatpipe();
    rb_fins();
    rb_blower();

    // memory
    rb_sodimm(112, 120, populated = true);   // SODIMM slot 1 (populated)
    rb_sodimm(132, 140, populated = false);  // SODIMM slot 2 (empty)
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
