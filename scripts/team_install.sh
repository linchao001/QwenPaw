#!/usr/bin/env bash
# Install qwenpaw + bundled local reme-ai wheels for team members.
#
# From repo:  bash scripts/team_install.sh
# From dist/: bash ./team_install.sh
#
# Options (env):
#   QWENPAW_SKIP_VENV=1     Skip virtualenv creation
#   QWENPAW_VENV_DIR=.venv  Virtualenv directory
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

if [ -n "${1:-}" ]; then
  DIST_DIR="$1"
elif compgen -G "$SCRIPT_DIR/reme_ai-*.whl" > /dev/null; then
  DIST_DIR="$SCRIPT_DIR"
else
  DIST_DIR="$REPO_ROOT/dist"
fi

if [ -n "${QWENPAW_VENV_DIR:-}" ]; then
  VENV_DIR="$QWENPAW_VENV_DIR"
elif [ "$DIST_DIR" = "$SCRIPT_DIR" ]; then
  VENV_DIR="$DIST_DIR/.venv"
else
  VENV_DIR="$REPO_ROOT/.venv"
fi

REME_WHEEL=( "$DIST_DIR"/reme_ai-*.whl )
QWENPAW_WHEEL=( "$DIST_DIR"/qwenpaw-*.whl )

if [ ! -f "${REME_WHEEL[0]}" ]; then
  echo "[team_install] Missing reme-ai wheel in $DIST_DIR" >&2
  exit 1
fi
if [ ! -f "${QWENPAW_WHEEL[0]}" ]; then
  echo "[team_install] Missing qwenpaw wheel in $DIST_DIR" >&2
  exit 1
fi

if [ "${QWENPAW_SKIP_VENV:-0}" != "1" ]; then
  if [ ! -d "$VENV_DIR" ]; then
    echo "[team_install] Creating virtualenv: $VENV_DIR"
    python3 -m venv "$VENV_DIR"
  fi
  # shellcheck disable=SC1091
  source "$VENV_DIR/bin/activate"
fi

echo "[team_install] Installing reme-ai + qwenpaw from $DIST_DIR ..."
python3 -m pip install --upgrade pip
python3 -m pip install "${REME_WHEEL[0]}" "${QWENPAW_WHEEL[0]}"

KB_SETUP="$SCRIPT_DIR/team_setup_kb.sh"
if [ ! -f "$KB_SETUP" ]; then
  echo "[team_install] Missing $KB_SETUP" >&2
  exit 1
fi
# shellcheck disable=SC1090
source "$KB_SETUP"

echo ""
echo "[team_install] Installed versions:"
qwenpaw --version
python3 -c "import reme; print('reme-ai', reme.__version__)"

echo ""
echo "[team_install] Next steps:"
echo "  qwenpaw init --defaults"
echo "  qwenpaw app"
echo "  # knowledge base: clone into ~/.reme/knowledge_bases/ (dir=zhb_kb, kb_id=zhb_kb)"
echo "  # open http://127.0.0.1:8088/"
