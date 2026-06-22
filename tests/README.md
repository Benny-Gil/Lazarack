# Tests

`run_tests.sh` is a self-contained unit-test suite that renders every part
headless with OpenSCAD and asserts the things that actually break a print or a
board swap. It runs in CI (`.github/workflows/ci.yml`) on every push/PR and
gates merges to `main`.

```bash
# local (macOS / bash 3.2 ok)
OSCAD=/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD ./tests/run_tests.sh
# headless Linux / CI
xvfb-run -a ./tests/run_tests.sh
```

## What it checks

1. **Renders clean** — every part (and `main.scad` + the reference board)
   renders with no OpenSCAD errors, unknown-variable warnings, or failed asserts.
2. **Manifold** — every *printable* part is 2-manifold (`Simple: yes`), so it's
   sliceable. (Skipped gracefully if an older OpenSCAD doesn't emit the line.)
3. **Bed-fit** — every printable part's two largest axes fit the 220 mm bed.
4. **Parametric invariants** — the Dell default derives the expected
   `BODY_W=212`, `DEPTH=210`, `FRONT_TILE_D=110`, etc. (catches a regression in
   the auto-sizing math).
5. **Rack-fit guards** — an over-wide (230 mm) or over-deep (260 mm) board
   **fails** the build via `assert`, and a valid 180 × 180 mm board **passes**
   (proves the parametric path works for boards other than the Dell).

Exit code is non-zero if any check fails.
