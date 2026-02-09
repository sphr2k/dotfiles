# Shared log helper for .chezmoiscripts. Source only (do not execute).
# Usage: source from run_ scripts via CHEZMOI_SOURCE_DIR or script-relative path.

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
