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

# Fisher: imperative install (skip when no TTY to avoid /dev/tty errors)
HAS_FISHER=false
if command -v fisher >/dev/null 2>&1; then
  HAS_FISHER=true
  dbg "fisher found: $(command -v fisher)"
else
  dbg "fisher not found in PATH"
fi
dbg "stdin is TTY: [ -t 0 ]=$([ -t 0 ] && echo true || echo false)"

if [ "$HAS_FISHER" = true ] && [ -t 0 ]; then
  dbg "running fisher install + tide"
  fisher install \
    oh-my-fish/plugin-brew \
    oh-my-fish/plugin-extract \
    oh-my-fish/plugin-osx \
    oh-my-fish/plugin-grc \
    kidonng/zoxide.fish \
    rkbk60/onedark-fish \
    halostatue/fish-brew \
    pfgray/fish-completion-sync \
    oh-my-fish/plugin-foreign-env \
    edc/bass \
    oddlama/fzf.fish \
    ilancosman/tide@v6

  # Tide prompt config
  if command -v tide >/dev/null 2>&1; then
    tide configure --auto --style=Lean --prompt_colors='True color' --show_time=No --lean_prompt_height='One line' --prompt_spacing=Compact --icons='Few icons' --transient=No
  else
    dbg "tide not found, skipping tide configure"
  fi
elif [ "$HAS_FISHER" = true ]; then
  dbg "skipping fisher + tide (no TTY); run in a shell: fisher install <plugins...> then tide configure ..."
fi

dbg "done"
