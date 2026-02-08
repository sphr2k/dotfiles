#!/usr/bin/env bash

set -euo pipefail

_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
# shellcheck source=.chezmoiscripts/log.sh
[ -f "${_dir}/log.sh" ] && source "${_dir}/log.sh" || log() { local l="${1:-info}"; shift; echo "[$l] $*" >&2; }

log info "start"

if ! command -v fish >/dev/null 2>&1; then
  log warn "fish not found, skipping tide configure"
  exit 0
fi
log info "fish found: $(command -v fish)"

log info "running tide configure via fish"
fish -c '
  if type -q tide
    tide configure --auto --style=Classic --prompt_colors="True color" --classic_prompt_color=Lightest --show_time=No --classic_prompt_separators=Angled --powerline_prompt_heads=Sharp --powerline_prompt_tails=Flat --powerline_prompt_style="One line" --prompt_spacing=Compact --icons="Few icons" --transient=Yes
  else
    echo "[run_tide_configure] tide not found" >&2
    exit 1
  end
' || log error "tide configure failed (exit $?)"

log info "done"
