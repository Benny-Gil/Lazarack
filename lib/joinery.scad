// =====================================================================
// lib/joinery.scad  —  FROZEN PARAMETRIC JOINERY LIBRARY
//
// Self-contained. Every module takes explicit args and does NOT read any
// params.scad global. Small epsilon overlaps (eps) keep unions/differences
// 2-manifold. `use <lib/joinery.scad>` from a part file.
//
// All modules are modeled at the LOCAL origin/orientation documented in
// their header, then the CALLER translate()/rotate()s them into the shared
// assembly frame (origin = front-bottom-left interior corner; +X width,
// +Y depth, +Z height).
//
// ---------------------------------------------------------------------
// API (signatures are FROZEN — do not change order/name of args):
//
//  rabbet_lap_male(w, lap, step_z, floor_t, eps=0.01)
//      Male half of the depth-seam stepped rabbet-lap. Models a tongue of
//      width w (X), length lap (Y), at the LOWER step (Z 0..step_z), sitting
//      under the mating female. Local origin at lap's front-bottom-left; the
//      tongue extends +Y. Union this onto the front tile's rear edge.
//
//  rabbet_lap_female(w, lap, step_z, floor_t, eps=0.01)
//      Female half: returns the SOLID block (w x lap x floor_t) with the
//      lower step REMOVED (a pocket Z 0..step_z) so difference()/union() it
//      forms the receiving rabbet. Use as: union the rear floor, then this
//      provides the upper-step ledge that overlaps the male tongue.
//      Local origin at front-bottom-left; pocket opens toward -Y (front).
//
//  dovetail_male(h, depth, w_root, w_tip, eps=0.01)
//      Angled dovetail tongue for the faceplate centerline (X=95) seam.
//      Extruded along Z (height h). Trapezoid in the X-Y plane: root width
//      w_root at the seam plane (Y=0), tip width w_tip at Y=depth. Local
//      origin centered in X on the seam, base at Z=0, growing +Y.
//
//  dovetail_female(h, depth, w_root, w_tip, clearance=0.2, eps=0.01)
//      Negative pocket matching dovetail_male, oversized by `clearance`
//      on each tail face for a press/slide fit. difference() this from the
//      receiving (right) faceplate tile. Same local frame as the male.
//
//  dowel_hole(d, depth, eps=0.01)
//      Simple cylindrical dowel/alignment-pin hole, axis +Z, opening up.
//      difference() from a part. Origin at hole center, top at Z=0 going -Z
//      ... NO: bored from Z=0 downward to Z=-depth (so caller places top).
//
//  tongue(w, h, t, eps=0.01)
//      Panel-bottom tongue (flange) that beds into a lip groove. A bar of
//      width w (X), thickness t (Y), height h (Z). Local origin front-bottom
//      -left, extends +Z. Union to a panel's bottom edge.
//
//  groove(w, h, t, clearance=0.2, eps=0.01)
//      Matching groove pocket for tongue(); difference() from a lip. Sized
//      t+2*clearance wide. Same local frame; opens +Z.
//
//  heatset_boss(od, bore_d, h, bore_depth, eps=0.01)
//      Cylindrical boss, axis +Z, base at Z=0, height h. Bore (diameter
//      bore_d, depth bore_depth) opens UPWARD from the top (no bridging).
//      Origin at boss center.
//
//  m3_grid(cols, rows, pitch, od, bore_d, h, bore_depth, eps=0.01)
//      Stamps a cols x rows array of heatset_boss() at `pitch` spacing.
//      Origin = center of the [0,0] boss; grid grows +X, +Y.
//
//  m25_standoff(h, od, bore_d, bore_depth, fillet=2, eps=0.01)
//      M2.5 board standoff, axis +Z, base at Z=0, with a base fillet for
//      side-load strength. Bore opens UPWARD. Origin at standoff center.
//
//  eia_face_holes(z_list, x, d, t, eps=0.01)
//      Drills M5 clearance holes (diameter d) through a faceplate of
//      thickness t (along Y), at X=x, for each Z in z_list. Axis +Y.
//      difference() from the faceplate. Local origin = faceplate inner face
//      at Y=0; holes bored Y -eps .. t+eps.
//
//  louver_grille(w, h, t, n=6, slat=3, angle=30, eps=0.01)
//      Louvered exhaust grille: n angled slots across height h, each cut
//      through thickness t (along Y). Returns the NEGATIVE (slot solids) to
//      difference() from a plate. Origin front-bottom-left of the w x h
//      window; angle is the louver tilt (deg) for a no-support overhang.
// =====================================================================


// ---- depth-seam stepped rabbet-lap -----------------------------------
module rabbet_lap_male(w, lap, step_z, floor_t, eps=0.01) {
    // lower tongue: Z 0..step_z, full width w, length lap in +Y
    translate([0, -eps, 0])
        cube([w, lap + eps, step_z]);
}

module rabbet_lap_female(w, lap, step_z, floor_t, eps=0.01) {
    // upper ledge: a floor block with the lower step pocketed out so the
    // male tongue slides under it. Result = the UPPER half over the lap.
    difference() {
        cube([w, lap, floor_t]);
        translate([-eps, -eps, -eps])
            cube([w + 2*eps, lap + eps, step_z + eps]);
    }
}


// ---- faceplate centerline dovetail -----------------------------------
module dovetail_male(h, depth, w_root, w_tip, eps=0.01) {
    // trapezoid in X-Y, extruded +Z. root at Y=0 (w_root), tip at Y=depth.
    linear_extrude(height = h)
        polygon(points = [
            [-w_root/2, 0],
            [ w_root/2, 0],
            [ w_tip/2,  depth],
            [-w_tip/2,  depth]
        ]);
}

module dovetail_female(h, depth, w_root, w_tip, clearance=0.2, eps=0.01) {
    // oversized negative of the male; extends slightly past faces by eps.
    linear_extrude(height = h + 2*eps)
        translate([0, 0, 0])
        offset(delta = clearance)
        polygon(points = [
            [-w_root/2, -eps],
            [ w_root/2, -eps],
            [ w_tip/2,  depth + eps],
            [-w_tip/2,  depth + eps]
        ]);
}


// ---- dowel / alignment pin hole --------------------------------------
module dowel_hole(d, depth, eps=0.01) {
    // bored from Z=0 downward; caller positions the part's top at Z=0.
    translate([0, 0, -depth])
        cylinder(h = depth + eps, d = d);
}


// ---- panel tongue + groove -------------------------------------------
module tongue(w, h, t, eps=0.01) {
    cube([w, t, h]);
}

module groove(w, h, t, clearance=0.2, eps=0.01) {
    translate([-eps, -clearance, -eps])
        cube([w + 2*eps, t + 2*clearance, h + eps]);
}


// ---- heat-set boss (opens upward) ------------------------------------
module heatset_boss(od, bore_d, h, bore_depth, eps=0.01) {
    difference() {
        cylinder(h = h, d = od);
        // bore opens UP from top -> no bridging over the hole
        translate([0, 0, h - bore_depth])
            cylinder(h = bore_depth + eps, d = bore_d);
    }
}


// ---- M3 heat-set grid -------------------------------------------------
module m3_grid(cols, rows, pitch, od, bore_d, h, bore_depth, eps=0.01) {
    for (cx = [0 : cols-1], ry = [0 : rows-1])
        translate([cx * pitch, ry * pitch, 0])
            heatset_boss(od, bore_d, h, bore_depth, eps);
}


// ---- M2.5 standoff with base fillet ----------------------------------
module m25_standoff(h, od, bore_d, bore_depth, fillet=2, eps=0.01) {
    union() {
        heatset_boss(od, bore_d, h, bore_depth, eps);
        // base fillet ring (rotate_extrude quarter-round skirt)
        translate([0, 0, 0])
        rotate_extrude($fn = 48)
            translate([od/2, 0, 0])
                difference() {
                    square([fillet, fillet]);
                    translate([fillet, fillet])
                        circle(r = fillet, $fn = 32);
                }
    }
}


// ---- EIA M5 clearance holes through a faceplate ----------------------
module eia_face_holes(z_list, x, d, t, eps=0.01) {
    for (z = z_list)
        translate([x, -eps, z])
            rotate([-90, 0, 0])      // axis +Y
                cylinder(h = t + 2*eps, d = d);
}


// ---- louvered exhaust grille (negative slots) ------------------------
module louver_grille(w, h, t, n=6, slat=3, angle=30, eps=0.01) {
    // n slots evenly across height h; each slot is a tilted slab cut in Y.
    pitch = h / n;
    for (i = [0 : n-1]) {
        zc = (i + 0.5) * pitch;
        translate([w/2, t/2, zc])
            rotate([angle, 0, 0])
                cube([w + 2*eps, t + 2*eps + 4, slat], center = true);
    }
}
