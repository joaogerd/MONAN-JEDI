#!/usr/bin/env bash
# Common helpers for MONAN-JEDI scripts.

log_info()  { printf '[INFO] %s\n' "$*"; }
log_warn()  { printf '[WARN] %s\n' "$*" >&2; }
log_error() { printf '[ERROR] %s\n' "$*" >&2; }

require_cmd() {
  local cmd="$1"
  if ! command -v "${cmd}" >/dev/null 2>&1; then
    log_error "Required command not found: ${cmd}"
    exit 1
  fi
}

resolve_cmd() {
  local name="$1"
  local value="$2"

  if [[ "${value}" = /* ]]; then
    if [[ ! -x "${value}" ]]; then
      log_error "${name} points to a non-executable path: ${value}"
      exit 1
    fi
    printf '%s\n' "${value}"
    return 0
  fi

  if ! command -v "${value}" >/dev/null 2>&1; then
    log_error "${name} command not found after loading environment: ${value}"
    exit 1
  fi

  command -v "${value}"
}
