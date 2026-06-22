#!/usr/bin/env bash
# Unit tests for the lazarack OpenSCAD case.
# Renders every part once (headless) and asserts: no render errors / failed
# asserts, 2-manifold geometry, bed-fit, parametric invariants, rack-fit guards.
# Portable to bash 3.2 (macOS) and bash 5 (CI) — no associative arrays.
#
#   ./tests/run_tests.sh                 # local (set OSCAD if not on PATH)
#   OSCAD=/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD ./tests/run_tests.sh
#   xvfb-run -a ./tests/run_tests.sh     # CI / headless Linux
set -uo pipefail

OSCAD="${OSCAD:-openscad}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
BED=220                       # Ender 3 V3 SE bed (mm); two largest axes must fit
PASS=0; FAIL=0
ok(){ printf "  \033[32mPASS\033[0m %s\n" "$1"; PASS=$((PASS+1)); }
no(){ printf "  \033[31mFAIL\033[0m %s\n        %s\n" "$1" "${2:-}"; FAIL=$((FAIL+1)); }

# "label:module-call"  — empty call means: render parts/<label>.scad directly.
PRINTABLE="
faceplate_left:
faceplate_right:
io_subplate:
m2_retainer:
rear_panel:
ssd_mezzanine:
m25_grid_insert:
board_edge_clip:
baseplate_FL:baseplate_quad(0,0)
baseplate_RL:baseplate_quad(0,1)
seam_splice:seam_splice()
lid_front:lid_front()
lid_rear:lid_rear()
"

# resolve a "label:call" entry to a .scad source path (writes a wrapper if needed)
src_of(){ # <label> <call>
  if [ -z "$2" ]; then echo "$ROOT/parts/$1.scad"; return; fi
  local f="$TMP/$1.scad"
  printf '$fa=2;$fs=0.6;\nuse <%s/parts/baseplate.scad>\nuse <%s/parts/lid.scad>\n%s;\n' "$ROOT" "$ROOT" "$2" > "$f"
  echo "$f"
}

render(){ OUT="$("$OSCAD" --render -o "$1" "${@:2}" 2>&1)"; }   # -> $OUT
has_err(){ echo "$OUT" | grep -qiE "ERROR|WARNING: Ignoring unknown|Assertion failed|undefined operation"; }
errline(){ echo "$OUT" | grep -iE "ERROR|Ignoring unknown|Assertion|undefined" | head -1; }
simple(){ echo "$OUT" | grep -o "Simple:.*" | head -1; }

bbox2(){ python3 - "$1" <<'PY'
import sys,re,struct
d=open(sys.argv[1],'rb').read()
if d[:5]==b'solid' and b'facet' in d[:4096]:
    v=[(float(a),float(b),float(c)) for a,b,c in re.findall(rb'vertex\s+(\S+)\s+(\S+)\s+(\S+)',d)]
else:
    n=struct.unpack('<I',d[80:84])[0]; v=[]; o=84
    for _ in range(n):
        o+=12
        for k in range(3): v.append(struct.unpack('<3f',d[o+12*k:o+12*k+12]))
        o+=38
e=sorted((max(p[i] for p in v)-min(p[i] for p in v) for i in range(3)),reverse=True)
print(f"{e[0]:.1f} {e[1]:.1f}")
PY
}

echo "OpenSCAD: $("$OSCAD" --version 2>&1 | head -1)"

echo "[1] render (no errors) + [2] manifold (Simple: yes) — every printable part"
for entry in $PRINTABLE; do
  label="${entry%%:*}"; call="${entry#*:}"
  src="$(src_of "$label" "$call")"
  render "$TMP/$label.stl" "$src"
  if has_err; then no "render $label" "$(errline)"; continue; fi
  ok "render $label"
  case "$(simple)" in
    *yes*) ok "manifold $label" ;;
    *no*)  no "manifold $label" "Simple: no (non-2-manifold)" ;;
    *)     ok "manifold $label (no CGAL 'Simple' line from this OpenSCAD — skipped)" ;;
  esac
done

echo "[1b] assembly + visual reference board render clean (manifold not required)"
render "$TMP/main.stl" "$ROOT/main.scad";                 has_err && no "render main.scad" "$(errline)" || ok "render main.scad"
render "$TMP/ref.stl" "$ROOT/parts/reference_board.scad"; has_err && no "render reference_board" "$(errline)" || ok "render reference_board"

echo "[3] printable parts fit the ${BED}mm bed (two largest axes)"
for entry in $PRINTABLE; do
  label="${entry%%:*}"
  [ -s "$TMP/$label.stl" ] || { no "bed-fit $label" "no STL (render failed)"; continue; }
  read -r a b < <(bbox2 "$TMP/$label.stl")
  awk -v a="$a" -v bed="$BED" 'BEGIN{exit !(a+0<=bed)}' \
    && ok "bed-fit $label (${a}×${b}mm)" || no "bed-fit $label" "largest ${a}mm > ${BED}mm bed"
done

echo "[4] parametric invariants (Dell default)"
val(){ printf 'include <%s/parts/params.scad>\necho(V=%s);\ncube(1);\n' "$ROOT" "$1" > "$TMP/e.scad"
       "$OSCAD" --render -o "$TMP/e.stl" "$TMP/e.scad" 2>&1 | sed -n 's/.*V = \([-0-9.]*\).*/\1/p' | head -1; }
expect(){ v="$(val "$1")"; [ "$v" = "$2" ] && ok "$1 == $2" || no "$1" "got '$v', expected '$2'"; }
expect BOARD_W_X 203
expect BODY_W 212            # = board + 2*margin (auto-sized)
expect DEPTH 210            # = gaps + board depth (auto-sized)
expect FRONT_TILE_D 110     # Dell pinned to the original split
expect REAR_TILE_D 125
expect BODY_CX 106
expect BOARD_X0 4.5

echo "[5] 10\" rack-fit guards (asserts must fire on oversized boards)"
rejects(){ "$OSCAD" --render -o "$TMP/x.stl" "$ROOT/parts/faceplate_left.scad" "${@:2}" >"$TMP/o" 2>&1
           grep -qi "Assertion" "$TMP/o" && ok "rejects $1" || no "rejects $1" "expected an assert failure, build succeeded"; }
rejects "too-WIDE board (230mm)" -D BOARD_W_X=230
rejects "too-DEEP board (260mm)" -D BOARD_D_Y=260
"$OSCAD" --render -o "$TMP/v.stl" "$ROOT/parts/faceplate_left.scad" -D BOARD_W_X=180 -D BOARD_D_Y=180 >"$TMP/o" 2>&1
grep -qiE "Assertion|ERROR" "$TMP/o" \
  && no "accepts a valid 180×180 board" "$(grep -iE 'Assert|ERROR' "$TMP/o"|head -1)" \
  || ok "accepts a valid 180×180 board"

echo
echo "==================  $PASS passed, $FAIL failed  =================="
[ "$FAIL" -eq 0 ]
