#!/usr/bin/env bash

set -euo pipefail

dbg() { echo "[run_tide_configure] $*" >&2; }

dbg "start"

if ! command -v fish >/dev/null 2>&1; then
  dbg "fish not found, skipping tide configure"
  exit 0
fi
dbg "fish found: $(command -v fish)"

dbg "running tide configure via fish"
fish -c '
  if type -q tide
    tide configure --auto --style=Classic --prompt_colors="True color" --classic_prompt_color=Lightest --show_time=No --classic_prompt_separators=Angled --powerline_prompt_heads=Sharp --powerline_prompt_tails=Flat --powerline_prompt_style="One line" --prompt_spacing=Compact --icons="Few icons" --transient=Yes
  else
    echo "[run_tide_configure] tide not found" >&2
    exit 1
  end
' || dbg "tide configure failed (exit $?)"

dbg "done"
