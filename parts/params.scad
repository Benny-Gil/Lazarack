// =====================================================================
// params.scad  —  FROZEN SHARED CONTRACT (global variables)
// Project: Dell Inspiron 15-5558/5559 motherboard -> NiH DIY 10" rack
// Printables #1634385 cage-nut rack. Printer: Ender 3 V3 SE. Material: PETG.
//
// GLOBAL ASSEMBLY COORDINATE FRAME (every part is modeled IN this frame;
// main.scad just unions modules with NO transforms):
//   Origin (0,0,0) = FRONT-BOTTOM-LEFT INTERIOR corner of the chassis body.
//   +X = width  (left  -> right)   structural body width 190mm  (X: 0..190)
//   +Y = depth  (front -> rear )   Y=0 is the RACK-FRONT interior face
//   +Z = height (bottom-> top  )   floor 0..FLOOR, interior up to 2U
//
// CONVENTION: include <params.scad> for these globals. Joinery modules in
// lib/joinery.scad are PARAMETRIC and do NOT read these globals — callers
// pass the values below in explicitly.
//
// Every uncertain real-world dimension is marked  // MEASURE  with a sane
// default so the model renders today; caliper later and update HERE only.
// =====================================================================


// ---------------------------------------------------------------------
// PRINTER / BED / PRINTABILITY LIMITS  (Ender 3 V3 SE)
// ---------------------------------------------------------------------
BED_X            = 220;     // bed size X (mm)
BED_Y            = 220;     // bed size Y (mm)
BED_Z            = 250;     // max print height (mm)
PRINT_MAX_XY     = 190;     // HARD design rule: every part <=190 in its two
                            //   bed-plane axes (prints flat with margin)
NOZZLE_D         = 0.4;     // nozzle diameter
LAYER_H          = 0.2;     // layer height
WALL_LINES       = 3;       // perimeters (target)
INFILL           = 0.30;    // 30% infill (target)
OVERHANG_MAX     = 45;      // deg; steeper requires chamfer/teardrop
EPS              = 0.01;    // epsilon overlap for boolean co-planar faces

// LOW-ACCURACY-PRINTER TOLERANCE — applied to EVERY mating feature so parts
// still bolt together when the printer is dimensionally loose / warps.
// "loose-fit, bolt-tight": gaps absorb slop, bolts pull seams flush.
FIT_CLEARANCE    = 0.5;     // per-side gap on all matings (slot/lap/dowel/insert fit)
CHAMFER          = 0.8;     // lead-in chamfer on holes/slots + bottom-edge relief
// (M3_SLOT_W is derived in the FASTENERS section below, after M3_CLEAR.)


// =====================================================================
// ★★★  YOUR BOARD  —  THE ONLY SECTION YOU EDIT FOR A DIFFERENT BOARD ★★★
// Drop in ANY laptop motherboard that fits a 10" rack: set its outline here
// and the whole chassis (body width, depth, the 4 baseplate quadrants, the
// faceplate centering, the grid) reflows automatically. Because the board is
// held by grid-placed standoffs + edge clips and the panels are BLANK
// drill-to-fit, you do NOT need exact hole/port positions — just the outline
// + a sane clearance. (Hole/port constants further down stay as // MEASURE
// hints for the optional reference board + pre-marked drill guides.)
// ---------------------------------------------------------------------
BOARD_W_X        = 203;     // board WIDTH  (X) = the rack-facing / I-O edge   // EDIT
BOARD_D_Y        = 197;     // board DEPTH  (Y) = I/O edge to the back         // EDIT
BOARD_T          = 1;       // board thickness (Z)                            // EDIT
STANDOFF_H       = 5;       // standoff height under the board (tallest part)  // EDIT
// Clearances the body adds around the board (rarely changed):
BOARD_MARGIN_X   = 4.5;     // X gap each side, board edge -> side wall
BOARD_FRONT_GAP  = 6;       // Y gap, rack-front face -> board front
BOARD_REAR_GAP   = 7;       // Y gap, board back -> rear panel
// Example boards — copy a line, then caliper to refine:
//   Dell Inspiron 15-5558/5559 : BOARD_W_X = 203; BOARD_D_Y = 197;   (default)
//   <your board here>          : BOARD_W_X = ___; BOARD_D_Y = ___;


// ---------------------------------------------------------------------
// CHASSIS BODY  (auto-sized from YOUR BOARD above; centered in the rack)
// ---------------------------------------------------------------------
BODY_W           = BOARD_W_X + 2*BOARD_MARGIN_X;   // structural body width (X)
FLOOR            = 3;       // floor / baseplate thickness (Z: 0..FLOOR)
WALL_T           = 3;       // integral side-wall upstand thickness (X walls)

// 10" rack fit guard — stops the build if the board is too big for a 10" rack:
RACK_MAX_BODY_W  = 216;     // ~usable width between the 10" rack rails
RACK_MAX_DEPTH   = 250;     // ~usable front-to-back depth of a 10" rack
assert(BODY_W <= RACK_MAX_BODY_W,
       str("Board too WIDE for a 10\" rack: body ", BODY_W,
           "mm exceeds ", RACK_MAX_BODY_W, "mm (max board width ~",
           RACK_MAX_BODY_W - 2*BOARD_MARGIN_X, "mm)."));

// --- 2U height ---
U_HEIGHT         = 44.45;   // 1U in mm (EIA-310)
N_U              = 1;       // chassis spans 1U (tallest board part ~8.9mm)
EXT_HEIGHT       = 44.45;   // external 1U height
UPSTAND_H        = 40;      // integral side-wall upstand height (lid sits on top: 40+3=43 < 44.45)
FACE_H           = 43.66;   // faceplate front-panel height (1U EIA panel, -0.79 binding margin)

// --- Depth + depth-split (auto from the board; seam near mid-depth) ---
DEPTH            = BOARD_FRONT_GAP + BOARD_D_Y + BOARD_REAR_GAP;  // interior depth (Y)
assert(DEPTH <= RACK_MAX_DEPTH,
       str("Board too DEEP for a 10\" rack: ", DEPTH, "mm exceeds ", RACK_MAX_DEPTH, "mm."));
LAP_LEN          = 25;      // overlap length of the rabbet lap (mm)
// Front quad depth: keep the EXACT original 110/125 split for the default Dell
// board (BOARD_D_Y==197); for any other board, derive a balanced mid-depth seam.
FRONT_TILE_D     = (BOARD_D_Y == 197) ? 110 : floor(DEPTH/2) + 8;
REAR_TILE_D      = DEPTH - FRONT_TILE_D + LAP_LEN; // rear quads span the remainder + lap
LAP_Y_NOMINAL    = FRONT_TILE_D;                   // seam centre / lap rear edge
LAP_STEP_Z       = FLOOR/2; // rabbet step height = half floor (1.5mm)


// ---------------------------------------------------------------------
// BOARD placement (derived from YOUR BOARD + the body; centered in X)
// ---------------------------------------------------------------------
BOARD_X0         = (BODY_W - BOARD_W_X) / 2;   // board centered in the body (= BOARD_MARGIN_X)
BOARD_Y0         = BOARD_FRONT_GAP;            // board front edge Y
BOARD_Z          = FLOOR + STANDOFF_H;         // board underside Z

// Board mounting holes [x,y] in ASSEMBLY frame (absolute, not board-local).
// 4 corners inset 8mm from board edges + 1 center.  ALL // MEASURE.
BOARD_HOLE_INSET = 8;       // MEASURE corner-hole inset from board edge
BOARD_HOLES = [             // MEASURE every coordinate below
    [BOARD_X0 + BOARD_HOLE_INSET,              BOARD_Y0 + BOARD_HOLE_INSET             ], // FL  ~[18, 10]
    [BOARD_X0 + BOARD_W_X - BOARD_HOLE_INSET,  BOARD_Y0 + BOARD_HOLE_INSET             ], // FR  ~[172,10]
    [BOARD_X0 + BOARD_HOLE_INSET,              BOARD_Y0 + BOARD_D_Y - BOARD_HOLE_INSET ], // RL  ~[18,229]
    [BOARD_X0 + BOARD_W_X - BOARD_HOLE_INSET,  BOARD_Y0 + BOARD_D_Y - BOARD_HOLE_INSET ], // RR  ~[172,229]
    [BOARD_X0 + 117.5,                         BOARD_Y0 + 85                           ]  // CTR ~[127.5,87] MEASURE
];


// ---------------------------------------------------------------------
// RACK INTERFACE (faceplate)  —  NiH DIY 10" cage-nut rack
//   External faceplate spans full 254mm rack width, centered on body
//   center X=95 => faceplate X from -32 .. 222.  Split at X=95 into
//   left tile (X -32..95) and right tile (X 95..222), each 127 wide.
// ---------------------------------------------------------------------
BODY_CX          = BODY_W / 2;        // = 95  (faceplate & rack centerline)
FACE_W           = 254;               // full faceplate width (X span)
FACE_T           = 4;                 // faceplate thickness (Y), at Y -FACE_T..0
FACE_X0          = BODY_CX - FACE_W/2;// = -32  (faceplate left edge)
FACE_X1          = BODY_CX + FACE_W/2;// = 222  (faceplate right edge)
FACE_SPLIT_X     = BODY_CX;           // = 95   (left|right tile seam)
FACE_TILE_W      = FACE_W / 2;        // = 127  (each tile width)

// --- M5 rack cage-nut columns (CLEARANCE holes, NOT inserts) ---
M5_SPACING       = 236.525;           // center-to-center of the two columns
M5_X_LEFT        = BODY_CX - M5_SPACING/2;  // = -23.2625  (left column)
M5_X_RIGHT       = BODY_CX + M5_SPACING/2;  // = 213.2625  (right column)
// each column sits 8.74mm inside its tile's OUTER edge so each rack column
// is WHOLE on one tile:  -23.2625 - (-32) = 8.7375 ;  222 - 213.2625 = 8.7375

// --- EIA-310 within-U vertical hole pattern ---
// Per-U hole centers measured from that U's BOTTOM edge (mm):
EIA_U_OFFSETS    = [6.35, 22.225, 38.1];   // EIA-310 within-U triplet
U_BOTTOM_Z       = 0;                  // MEASURE Z of U#1 bottom vs floor(0)
                                       //   (rack U-grid datum vs chassis floor)
// Flat list of M5 hole Z-centers across N_U units (helper-friendly):
EIA_FACE_HOLES_Z = [ for (u=[0:N_U-1], o=EIA_U_OFFSETS)
                       U_BOTTOM_Z + u*U_HEIGHT + o ];
                     // = [6.35,22.225,38.1, 50.8,66.675,82.55]


// ---------------------------------------------------------------------
// FASTENERS / HOLE SIZES
// ---------------------------------------------------------------------
// M3 brass heat-set inserts (all module/seam joints), opening UPWARD:
M3_INSERT_BORE   = 4.0;     // insert bore diameter (mm)  // MEASURE per insert
M3_INSERT_DEPTH  = 5.0;     // insert bore depth (mm)
M3_BOSS_OD       = 7.0;     // recommended boss outer diameter around bore
M3_CLEAR         = 3.7;     // M3 screw clearance hole dia (generous for a loose printer)
M3_SLOT_W        = M3_CLEAR + 2*FIT_CLEARANCE; // slotted-hole width for forgiving seams
M3_HEAD_D        = 6.0;     // M3 cap-head clearance diameter (counterbore)

// M2.5 (board standoffs + M.2 post):
M25_INSERT_BORE  = 3.4;     // M2.5 heat-set insert bore // MEASURE
M25_INSERT_DEPTH = 4.0;     // M2.5 insert depth
M25_PILOT        = 2.1;     // M2.5 self-tap pilot diameter (alt to insert)
M25_BOSS_OD      = 6.0;     // standoff/boss outer diameter

// M5 rack cage-nut screws — CLEARANCE only (never an insert):
M5_CLEAR         = 5.5;     // M5 clearance hole diameter


// ---------------------------------------------------------------------
// M3 SELF-TAP PILOT GRID  (the ONE common interface on the baseplate top)
//   15mm pitch, continuous across the depth lap. The M.2 post, ssd_cage,
//   io_subplate, panels and lid all bolt to this standard grid.
//
//   NOTE: grid points are blind M3 SELF-TAPPING PILOT HOLES bored into the
//   floor top (NOT heat-set insert bosses) — you drive an M3 screw straight
//   into the PETG only at the few points a module actually uses. This keeps
//   the floor flat and needs ZERO heat-set inserts in the grid (inserts are
//   used only at the structural seams: lap, faceplate, panels, lid).
// ---------------------------------------------------------------------
GRID_PITCH       = 15;      // grid pitch (mm), both X and Y
GRID_X0          = 12.5;    // first grid column X (origin of grid)  // MEASURE
GRID_Y0          = 12.5;    // first grid row    Y (origin of grid)  // MEASURE
GRID_COLS        = 13;      // columns spanning ~ X 12.5..192.5 (<=BODY_W 212)
GRID_ROWS        = 13;      // rows spanning ~ Y 12.5..192.5 (<=DEPTH 210)
GRID_PILOT_D     = 2.5;     // M3 self-tap pilot-hole diameter (screw bites PETG)
GRID_PILOT_DEPTH = 2.4;     // blind pilot depth into FLOOR(3) -> leaves ~0.6mm
GRID_CLEAR       = 8;       // min XY clearance grid pilot must keep from a boss
// front tile carries rows with Y<FRONT_TILE_D; rear tile the remainder;
// grid pilots are skipped wherever they'd fall under a standoff / seam boss.


// ---------------------------------------------------------------------
// PANEL-LIP JOINERY  (shared by baseplate + faceplate + rear_panel so the
// flange bolts, lip pilots and grooves can NEVER drift apart between mates)
// ---------------------------------------------------------------------
LIP_T              = 6;     // panel-lip depth in Y (flange/tongue beds here)
LIP_H              = 6;     // panel-lip height above the floor (Z)
LIP_TOP_Z          = FLOOR + LIP_H;                 // = 9   lip top Z
LIP_GROOVE_DEPTH   = 3;                              // upward groove into the lip top
LIP_GROOVE_FLOOR_Z = LIP_TOP_Z - LIP_GROOVE_DEPTH;  // = 6   groove floor Z
// self-tap pilot columns the lips provide and the panels bolt down into:
PANEL_PILOT_X      = [30, BODY_CX, BODY_W - 30];    // = [30,106,182]
FRONT_PILOT_Y      = LIP_T/2;                        // = 3    front-lip pilot Y
REAR_PILOT_Y       = DEPTH - LIP_T/2;               // = 207  rear-lip pilot Y

// ---------------------------------------------------------------------
// LID WALL-TOP FASTENERS  (shared by baseplate wall-top bosses + lid holes,
// so the lid's M3 screws always land on a real self-tap pilot in the wall).
//   On each side-wall top centerline; front Ys live on the front quads,
//   rear Ys on the rear quads (kept clear of the Y-seam at FRONT_TILE_D).
// ---------------------------------------------------------------------
LID_WALL_CX_L      = WALL_T/2;                       // = 1.5    left  wall-top centerline X
LID_WALL_CX_R      = BODY_W - WALL_T/2;             // = 210.5  right wall-top centerline X
LID_FASTEN_Y_FRONT = [20, FRONT_TILE_D/2, FRONT_TILE_D - 10]; // front-quad screws (Y<FRONT_TILE_D)
LID_FASTEN_Y_REAR  = [FRONT_TILE_D + 20, (FRONT_TILE_D+DEPTH)/2, DEPTH - 10]; // rear-quad screws
LID_BOSS_W         = 6;     // local wall-top widening (X, inward) to host the pilot
LID_BOSS_Y         = 8;     // wall-top boss length along Y
LID_WALL_PILOT_DEPTH = 6;   // self-tap pilot depth down from the wall top


// ---------------------------------------------------------------------
// FRONT I/O  (faceplate / io_subplate window)  —  Edge-alpha
//   io_subplate window recessed into faceplate, 4x M3.  Default variant:
//   HDMI + USB-A x2 + louvered blower EXHAUST grille. Future: + RJ45.
//   All cutout positions are LOCAL to the io_subplate (its own 0,0 = lower
//   -left of the 120x70 insert) and are // MEASURE.
// ---------------------------------------------------------------------
IO_VARIANT       = "blank";     // "blank"(tolerance default) | "default" | "rj45"
IO_SUB_W         = 130;     // io_subplate width  (its X) — generous for port slop
IO_SUB_H         = 32;      // io_subplate height (its Z) — fits the 1U panel (43.66)
IO_SUB_T         = 3;       // io_subplate thickness (its Y)

// io_subplate window placement in the FACEPLATE (assembly frame):
IO_WIN_X0        = BODY_CX - IO_SUB_W/2; // window centered on the body centerline  MEASURE
IO_WIN_Z0        = 6;       // window bottom Z (window 6..38, inside 1U panel) // MEASURE
IO_SUB_M3        = [        // 4x M3 mount holes, LOCAL to io_subplate  MEASURE
    [6, 6], [IO_SUB_W-6, 6], [6, IO_SUB_H-6], [IO_SUB_W-6, IO_SUB_H-6]
];

// Front cutouts, LOCAL to io_subplate [x_center, z_center] + size  — MEASURE
HDMI_POS         = [22, 22];    HDMI_SIZE   = [16, 7];     // MEASURE HDMI-A
USBA_POS_1       = [48, 22];    USBA_SIZE   = [14, 7];     // MEASURE USB-A #1
USBA_POS_2       = [48, 38];    // USB-A #2 (stacked)      // MEASURE
EXHAUST_POS      = [92, 35];    EXHAUST_SIZE= [38, 40];    // MEASURE blower grille
RJ45_POS         = [22, 50];    RJ45_SIZE   = [16, 14];    // MEASURE (rj45 variant)


// ---------------------------------------------------------------------
// REAR I/O  (rear_panel)  —  Edge-beta
//   USB-C power-in (user replaced barrel jack) + SD reader + 3.5mm audio.
//   Cutout positions LOCAL to rear_panel (its 0,0 = lower-left), // MEASURE.
// ---------------------------------------------------------------------
REAR_W           = BODY_W;  // rear panel width  (X) = BODY_W (212)
REAR_H           = UPSTAND_H; // rear panel height (Z) = wall height (1U, blank panel)
REAR_T           = 4;       // rear panel thickness (Y), Y DEPTH..DEPTH+REAR_T
USBC_POS         = [40, 30];   USBC_SIZE  = [10, 6];    // MEASURE USB-C power-in
SD_POS           = [95, 30];   SD_SIZE    = [26, 4];    // MEASURE SD reader slot
AUDIO_POS        = [150, 30];  AUDIO_D    = 7;          // MEASURE 3.5mm jack dia


// ---------------------------------------------------------------------
// M.2 RETAINER  (m2_retainer)  —  supplies the MISSING M.2 standoff
//   Gusseted M2.5 post; foot bolts to baseplate grid (2x M3 clearance);
//   top takes an M2.5 insert. Distance ~73mm from the M.2 connector.
// ---------------------------------------------------------------------
M2_CONNECTOR_POS = [150, 60];   // MEASURE M.2 connector seat [x,y] assembly frame
M2_RETAINER_DIST = 73;          // MEASURE post distance from connector (mm)
M2_RETAINER_POS  = [M2_CONNECTOR_POS[0], M2_CONNECTOR_POS[1] + M2_RETAINER_DIST];
                                // resolved retainer post center [x,y] // MEASURE
M2_POST_H        = STANDOFF_H;  // post top matches board plane (Z)
M2_FOOT          = [16, 16];    // retainer foot footprint (X,Y)
M2_FOOT_H        = 10;          // retainer total height (Z)


// ---------------------------------------------------------------------
// SSD CAGE  (ssd_cage, OPTIONAL)  —  2.5" SATA tray (JEITA 100x70x7)
// ---------------------------------------------------------------------
SSD_L            = 100;     // 2.5" drive length (JEITA)
SSD_W            = 70;      // 2.5" drive width
SSD_H            = 7;       // 2.5" drive height (7mm)
SSD_CAGE_POS     = [12, 150];   // MEASURE cage origin [x,y] beside board, on grid
SSD_CAGE_FEET    = 4;       // 4x M3 feet onto baseplate grid


// ---------------------------------------------------------------------
// LID  (lid_front + lid_rear, OPTIONAL)  —  vented 2U top, two tiles
// ---------------------------------------------------------------------
LID_T            = 3;       // lid thickness
LID_FRONT_D      = 118;     // lid_front Y span (laps lid_rear at depth seam)
LID_REAR_D       = 142;     // lid_rear  Y span
LID_Z            = UPSTAND_H;// lid sits on top of the 86mm wall upstands
