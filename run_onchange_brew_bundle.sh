#!/usr/bin/env bash

set -euo pipefail

if ! command -v brew >/dev/null 2>&1; then
  echo "brew not found, skipping brew bundle"
  exit 0
fi

if [ -n "${CHEZMOI_SOURCE_DIR:-}" ]; then
  BREWFILE_PATH="${CHEZMOI_SOURCE_DIR}/Brewfile"
else
  BREWFILE_PATH="$(pwd)/Brewfile"
fi

if [ ! -f "$BREWFILE_PATH" ]; then
  echo "brewfile not found at ${BREWFILE_PATH}, skipping brew bundle"
  exit 0
fi

brew bundle --file "$BREWFILE_PATH"

# Run after chezmoi has written files; use destination path
FISH_PLUGINS="${XDG_CONFIG_HOME:-$HOME/.config}/fish/fish_plugins"
if command -v fisher >/dev/null 2>&1 && [ -f "$FISH_PLUGINS" ]; then
  fisher install < "$FISH_PLUGINS"
fi
