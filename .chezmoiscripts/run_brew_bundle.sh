#!/usr/bin/env bash

set -euo pipefail

_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
# shellcheck source=.chezmoiscripts/log.sh
[ -f "${_dir}/log.sh" ] && source "${_dir}/log.sh" || log() { local l="${1:-info}"; shift; echo "[$l] $*" >&2; }

log info "start (CHEZMOI_SOURCE_DIR=${CHEZMOI_SOURCE_DIR:-<unset>})"

if ! command -v brew >/dev/null 2>&1; then
  log warn "brew not found, skipping brew bundle"
  exit 0
fi
log info "brew found: $(command -v brew)"

if [ -n "${CHEZMOI_SOURCE_DIR:-}" ]; then
  BREWFILE_PATH="${CHEZMOI_SOURCE_DIR}/Brewfile"
else
  BREWFILE_PATH="$(pwd)/Brewfile"
fi
log info "BREWFILE_PATH=$BREWFILE_PATH"

if [ ! -f "$BREWFILE_PATH" ]; then
  log warn "brewfile not found, skipping brew bundle"
  exit 0
fi

log info "running brew bundle"
brew bundle --file "$BREWFILE_PATH"

log info "done"
