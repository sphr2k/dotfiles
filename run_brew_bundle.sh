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

# Fisher is a Fish function, not a binary — run it via fish
dbg "stdin is TTY: [ -t 0 ]=$([ -t 0 ] && echo true || echo false)"
HAS_FISH=false
if command -v fish >/dev/null 2>&1; then
  HAS_FISH=true
  dbg "fish found: $(command -v fish)"
else
  dbg "fish not found in PATH, skipping fisher + tide"
fi

if [ "$HAS_FISH" = true ]; then
  dbg "running fisher install + tide via fish"
  fish -c '
    if type -q fisher
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
      if type -q tide
        tide configure --auto --style=Lean --prompt_colors=\"True color\" --show_time=No --lean_prompt_height=\"One line\" --prompt_spacing=Compact --icons=\"Few icons\" --transient=No
      end
    else
      echo "[run_brew_bundle] fisher not loaded in fish (add to config or run interactively)" >&2
    end
  ' || dbg "fish -c fisher/tide failed (exit $?)"
fi

dbg "done"
