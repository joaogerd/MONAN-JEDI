#!/usr/bin/env bash
# Common helper functions for MONAN-JEDI scripts.
#
# Purpose:
#   Provide small shared shell utilities used by the workflow modules.
#   This file should remain independent from site-specific paths and from the
#   Spack-stack environment.
#
# Functions:
#   log_info, log_warn, log_error
#     Print standardized messages.
#
#   require_cmd <command>
#     Abort if a required command is not available in PATH.
#
#   resolve_cmd <name> <value>
#     Resolve either an absolute executable path or a command name after the
#     stack environment has been loaded.
#
# Expected result:
#   All workflow modules can emit consistent messages and fail early when a
#   required command or compiler wrapper is missing.

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
