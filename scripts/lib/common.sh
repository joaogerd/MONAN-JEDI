#!/usr/bin/env bash
# Common helper functions for MONAN-JEDI scripts.
#
# Purpose:
#   Provide small shared shell utilities used by the workflow modules. This file
#   should remain independent from site-specific paths and from the spack-stack
#   runtime environment.
#
# Functions:
#   log_info, log_warn, log_error
#     Print standardized workflow messages.
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

# Print an informational message to standard output.
log_info()  { printf '[INFO] %s\n' "$*"; }

# Print a warning message to standard error.
log_warn()  { printf '[WARN] %s\n' "$*" >&2; }

# Print an error message to standard error.
log_error() { printf '[ERROR] %s\n' "$*" >&2; }

require_cmd() {
  local cmd="$1"

  # command -v is shell-portable and works for binaries, shell functions and
  # aliases made available by the loaded environment.
  if ! command -v "${cmd}" >/dev/null 2>&1; then
    log_error "Required command not found: ${cmd}"
    exit 1
  fi
}

resolve_cmd() {
  local name="$1"
  local value="$2"

  # Absolute paths must exist and be executable. This is useful when a wrapper
  # must be pinned explicitly instead of resolved through PATH.
  if [[ "${value}" = /* ]]; then
    if [[ ! -x "${value}" ]]; then
      log_error "${name} points to a non-executable path: ${value}"
      exit 1
    fi
    printf '%s\n' "${value}"
    return 0
  fi

  # Command names are resolved only after the stack environment has been loaded.
  if ! command -v "${value}" >/dev/null 2>&1; then
    log_error "${name} command not found after loading environment: ${value}"
    exit 1
  fi

  command -v "${value}"
}
