#! /usr/bin/env bash

# Shared log helpers for .chezmoiscripts. Source with:
#   _d="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; [ -f "${_d}/log.sh" ] && source "${_d}/log.sh"

if [ -t 2 ]; then
  _log_c_red='\033[0;31m'
  _log_c_green='\033[0;32m'
  _log_c_yellow='\033[1;33m'
  _log_c_blue='\033[0;34m'
  _log_c_dim='\033[2m'
  _log_c_reset='\033[0m'
else
  _log_c_red=''
  _log_c_green=''
  _log_c_yellow=''
  _log_c_blue=''
  _log_c_dim=''
  _log_c_reset=''
fi

log() {
  local level="${1:-info}"
  shift
  local c tag
  case "$level" in
    info)  c="$_log_c_blue";   tag="INFO" ;;
    warn)  c="$_log_c_yellow"; tag="WARN" ;;
    error) c="$_log_c_red";    tag="ERROR" ;;
    debug) c="$_log_c_dim";    tag="DEBUG" ;;
    *)     c="$_log_c_blue";   tag="$level" ;;
  esac
  echo -e "${c}[${tag}]${_log_c_reset} $*" >&2
}
