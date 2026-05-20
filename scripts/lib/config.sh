#!/usr/bin/env bash
# YAML configuration loader for MONAN-JEDI.

load_monan_jedi_config() {
  local default_config="config/jaci.yaml"
  export MONAN_JEDI_CONFIG="${MONAN_JEDI_CONFIG:-${default_config}}"

  if [[ ! -f "${MONAN_JEDI_CONFIG}" ]]; then
    log_error "Configuration file not found: ${MONAN_JEDI_CONFIG}"
    exit 1
  fi

  require_cmd python3

  # shellcheck disable=SC1090
  eval "$(python3 "$(dirname "${BASH_SOURCE[0]}")/read_config.py" "${MONAN_JEDI_CONFIG}")"

  export STACK_WORK_ROOT="${STACK_WORK_ROOT:-${PROJECT_ROOT}/work/${STACK_INSTANCE}}"
  export STACK_ROOT="${STACK_ROOT:-${STACK_WORK_ROOT}/spack-stack}"
  export STACK_MODULE_ROOT="${STACK_MODULE_ROOT:-${STACK_ROOT}/envs/${STACK_ENV_NAME}/modules}"

  export MONAN_JEDI_WORK_ROOT="${MONAN_JEDI_WORK_ROOT:-${PROJECT_ROOT}/work/${MONAN_JEDI_RUN_ID}}"
  export MONAN_JEDI_LOG_ROOT="${MONAN_JEDI_LOG_ROOT:-${PROJECT_ROOT}/logs/${MONAN_JEDI_RUN_ID}}"

  export JEDI_BUNDLE_SRC_DIR="${JEDI_BUNDLE_SRC_DIR:-${MONAN_JEDI_WORK_ROOT}/jedi-bundle}"
  export JEDI_BUNDLE_BUILD_DIR="${JEDI_BUNDLE_BUILD_DIR:-${MONAN_JEDI_WORK_ROOT}/build-jedi-bundle-mpas-only}"

  mkdir -p "${MONAN_JEDI_WORK_ROOT}" "${MONAN_JEDI_LOG_ROOT}"
}
