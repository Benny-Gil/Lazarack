#!/usr/bin/env bash
# Regenerate the docs/img/ renders from the model. Run after geometry changes.
#   ./render_docs.sh        (set OSCAD if OpenSCAD isn't at the default path)
set -euo pipefail
OSCAD="${OSCAD:-/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD}"
cd "$(dirname "$0")"
SZ=1280,960
CS=Tomorrow
ISO="--camera=0,0,0,55,0,25,0 --viewall --autocenter --projection=p"
TOP="--camera=0,0,0,0,0,0,0 --viewall --autocenter"

echo "assembly_iso";       "$OSCAD" main.scad                                   -o docs/img/assembly_iso.png       --imgsize=$SZ --colorscheme=$CS $ISO
echo "assembly_exploded";  "$OSCAD" main.scad -D EXPLODE=42                     -o docs/img/assembly_exploded.png  --imgsize=$SZ --colorscheme=$CS $ISO
echo "assembly_labeled";   "$OSCAD" main.scad -D EXPLODE=42                     -o docs/img/assembly_labeled.png   --imgsize=$SZ --colorscheme=$CS $ISO
echo "assembly_interior";  "$OSCAD" main.scad -D SHOW_LID=false -D SHOW_BOARD=false -o docs/img/assembly_interior.png --imgsize=$SZ --colorscheme=$CS --camera=0,0,0,62,0,22,0 --viewall --autocenter --projection=p
echo "assembly_top";       "$OSCAD" main.scad -D SHOW_LID=false                 -o docs/img/assembly_top.png       --imgsize=$SZ --colorscheme=$CS $TOP
echo "baseplate_assembly"; "$OSCAD" parts/baseplate.scad                        -o docs/img/baseplate_assembly.png --imgsize=$SZ --colorscheme=$CS $ISO
echo "baseplate_grid";     "$OSCAD" parts/baseplate.scad                        -o docs/img/baseplate_grid.png     --imgsize=$SZ --colorscheme=$CS $TOP
echo DONE
