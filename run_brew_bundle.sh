#!/usr/bin/env bash

set -euo pipefail

dbg() { echo "[run_brew_bundle] $*" >&2; }

dbg "start (CHEZMOI_SOURCE_DIR=${CHEZMOI_SOURCE_DIR:-<unset>})"

if ! command -v brew >/dev/null 2>&1; then
  dbg "brew not found, skipping brew bundle"
  exit 0
fi
dbg "brew found: $(command -v brew)"

if [ -n "${CHEZMOI_SOURCE_DIR:-}" ]; then
  BREWFILE_PATH="${CHEZMOI_SOURCE_DIR}/Brewfile"
else
  BREWFILE_PATH="$(pwd)/Brewfile"
fi
dbg "BREWFILE_PATH=$BREWFILE_PATH"

if [ ! -f "$BREWFILE_PATH" ]; then
  dbg "brewfile not found, skipping brew bundle"
  exit 0
fi

dbg "running brew bundle"
brew bundle --file "$BREWFILE_PATH"

dbg "done"
