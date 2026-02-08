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

# Fisher: imperative install (skip when no TTY to avoid /dev/tty errors)
if command -v fisher >/dev/null 2>&1 && [ -t 0 ]; then
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
  fi
elif command -v fisher >/dev/null 2>&1; then
  echo "skipping fisher + tide (no TTY); run in a shell: fisher install <plugins...> then tide configure ..."
fi
