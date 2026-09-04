#!/usr/bin/env bash
# Build team distribution wheels: qwenpaw + local ReMe (reme-ai).
# Run from repo root: bash scripts/team_wheel_build.sh
#
# ReMe checkout path: QWENPAW_REME_SRC (default: ../ReMe)
set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REME_SRC="${QWENPAW_REME_SRC:-$REPO_ROOT/../ReMe}"
DIST_DIR="$REPO_ROOT/dist"

if [ ! -f "$REME_SRC/pyproject.toml" ]; then
  echo "[team_wheel_build] ReMe checkout not found: $REME_SRC" >&2
  echo "[team_wheel_build] Set QWENPAW_REME_SRC to your ReMe directory." >&2
  exit 1
fi

echo "[team_wheel_build] Step 1/2: qwenpaw wheel (includes console frontend)..."
bash "$REPO_ROOT/scripts/wheel_build.sh"

echo "[team_wheel_build] Step 2/2: reme-ai wheel from $REME_SRC ..."
python3 -m pip install --quiet build
(cd "$REME_SRC" && python3 -m build --wheel --outdir "$DIST_DIR")

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$REPO_ROOT/scripts/team_pack_dist.ps1" -DistDir "$DIST_DIR" -ScriptsDir "$REPO_ROOT/scripts"

echo ""
echo "[team_wheel_build] Done. Package directory: $DIST_DIR/"
ls -1 "$DIST_DIR"/*.whl 2>/dev/null || dir "$DIST_DIR\\*.whl"
echo "  team_install.ps1 / team_install.sh / INSTALL.txt"
echo ""
echo "Team install (one command, after cd to dist):"
echo "  cd $DIST_DIR"
echo "  powershell -ExecutionPolicy Bypass -File .\\team_install.ps1"
echo ""
echo "Linux / macOS:"
echo "  cd $DIST_DIR && bash ./team_install.sh"
