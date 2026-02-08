#!/usr/bin/env bash

set -euo pipefail

_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
# shellcheck source=.chezmoiscripts/log.sh
[ -f "${_dir}/log.sh" ] && source "${_dir}/log.sh" || log() { local l="${1:-info}"; shift; echo "[$l] $*" >&2; }

log info "start"

if ! command -v fish >/dev/null 2>&1; then
  log warn "fish not found, skipping fisher install"
  exit 0
fi
log info "fish found: $(command -v fish)"

log info "running fisher install via fish"
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
  else
    echo "[run_fisher_install] fisher not loaded in fish" >&2
    exit 1
  end
' || log error "fisher install failed (exit $?)"

log info "done"
