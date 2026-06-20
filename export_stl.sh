#!/usr/bin/env bash
# Export every PRINTABLE part to stl/ .
# Regenerate after editing parts/params.scad:  ./export_stl.sh
# Override the binary with:  OSCAD=/path/to/openscad ./export_stl.sh
set -euo pipefail

OSCAD="${OSCAD:-/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD}"
ROOT="$(cd "$(dirname "$0")" && pwd)"
OUT="$ROOT/stl"
mkdir -p "$OUT"

# render a part whose file already ends in a standalone module call
render() { echo "  -> $1.stl"; "$OSCAD" -o "$OUT/$1.stl" "$2"; }

# render a specific module from a multi-module file via a temp wrapper
wrap() { # <out-name> <call> <abs-part-file>
  local tmp; tmp="$(mktemp /tmp/wrap.XXXXXX.scad)"
  printf '$fa=2;$fs=0.6;\nuse <%s>\n%s\n' "$3" "$2" > "$tmp"
  echo "  -> $1.stl"; "$OSCAD" -o "$OUT/$1.stl" "$tmp"; rm -f "$tmp"
}

echo "Exporting printable STLs to stl/ ..."

# --- structural: 4 baseplate quadrants + the seam splice (multi-module file) ---
wrap baseplate_FL "baseplate_quad(0,0);" "$ROOT/parts/baseplate.scad"
wrap baseplate_FR "baseplate_quad(1,0);" "$ROOT/parts/baseplate.scad"
wrap baseplate_RL "baseplate_quad(0,1);" "$ROOT/parts/baseplate.scad"
wrap baseplate_RR "baseplate_quad(1,1);" "$ROOT/parts/baseplate.scad"
wrap seam_splice  "seam_splice();"       "$ROOT/parts/baseplate.scad"

# --- lid tiles (multi-module file) ---
wrap lid_front "lid_front();" "$ROOT/parts/lid.scad"
wrap lid_rear  "lid_rear();"  "$ROOT/parts/lid.scad"

# --- single-module parts (their file ends with a standalone call) ---
for p in faceplate_left faceplate_right rear_panel io_subplate m2_retainer \
         ssd_mezzanine m25_grid_insert board_edge_clip; do
  render "$p" "$ROOT/parts/$p.scad"
done

echo "Done. STLs in $OUT"
echo "(reference_board.scad is a visual prop and is intentionally NOT exported.)"
