#!/usr/bin/env bash
# Clone / update shared ReMe knowledge base (zhb_kb) for team installs.
# Called from team_install.sh (same directory).
set -e

if [ "${QWENPAW_SKIP_KB:-0}" = "1" ]; then
  echo "[team_install] Skipping knowledge base setup (QWENPAW_SKIP_KB=1)."
  exit 0
fi

KB_GIT_URL="git@gitlab.internal.qifeng.ai:qifeng_test/zhb_kb.git"
# Business KB lives under ReMe's knowledge_bases root; directory name == kb_id.
KB_ID="zhb_kb"
KB_ROOT="${HOME}/.reme/knowledge_bases"
KB_PATH="${KB_ROOT}/${KB_ID}"
BRANCH="feature/dev-$(date +%Y%m%d)"

kb_clone_error() {
  cat >&2 <<EOF
[team_install] Failed to set up knowledge base at ${KB_PATH}

Please check:
  1. Git is installed and available in PATH
  2. SSH key is loaded and registered on GitLab (gitlab.internal.qifeng.ai)
  3. You have read access to: qifeng_test/zhb_kb

Test SSH:
  ssh -T git@gitlab.internal.qifeng.ai

Clone manually:
  cd ${KB_ROOT} && git clone ${KB_GIT_URL}
EOF
  exit 1
}

if ! command -v git >/dev/null 2>&1; then
  echo "[team_install] Git is required to clone the shared knowledge base (${KB_GIT_URL})." >&2
  exit 1
fi

echo "[team_install] Setting up ReMe knowledge base '${KB_ID}' under ${KB_ROOT}"
mkdir -p "$KB_ROOT"

# Previous installs used directory name ``zhb``; rename when present.
LEGACY_KB_PATH="${KB_ROOT}/zhb"
if [ ! -e "$KB_PATH" ] && [ -d "${LEGACY_KB_PATH}/.git" ]; then
  echo "[team_install] Renaming legacy knowledge base '${LEGACY_KB_PATH}' -> '${KB_PATH}'"
  mv "$LEGACY_KB_PATH" "$KB_PATH"
fi

if [ -d "${KB_PATH}/.git" ]; then
  echo "[team_install] Knowledge base repo exists, fetching latest..."
  (cd "$KB_PATH" && git fetch --all --prune) || kb_clone_error
elif [ -e "$KB_PATH" ]; then
  echo "[team_install] Path exists but is not a git repo: ${KB_PATH}" >&2
  exit 1
else
  echo "[team_install] Cloning ${KB_GIT_URL} into ${KB_ROOT} (dir=${KB_ID}) ..."
  # Clone into knowledge_bases so the repo folder name becomes zhb_kb.
  (cd "$KB_ROOT" && git clone "$KB_GIT_URL") || kb_clone_error
  if [ ! -d "${KB_PATH}/.git" ]; then
    kb_clone_error
  fi
fi

(
  cd "$KB_PATH"
  if git checkout -b "$BRANCH" 2>/dev/null; then
    echo "[team_install] Created local branch: ${BRANCH}"
  elif git checkout "$BRANCH"; then
    echo "[team_install] Checked out existing branch: ${BRANCH}"
  else
    echo "[team_install] Failed to checkout branch ${BRANCH}" >&2
    exit 1
  fi
)

echo "[team_install] Knowledge base ready (kb_id=${KB_ID}, path=${KB_PATH}, branch=${BRANCH})."
