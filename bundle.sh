#!/usr/bin/env bash
# JEDI bundle preparation.

monan_jedi_prepare_bundle() {
  require_cmd git
  monan_jedi_load_stack

  mkdir -p "$(dirname "${JEDI_BUNDLE_SRC_DIR}")" "${MONAN_JEDI_LOG_ROOT}"

  if [[ ! -d "${JEDI_BUNDLE_SRC_DIR}/.git" ]]; then
    git clone "${JEDI_BUNDLE_REPO}" "${JEDI_BUNDLE_SRC_DIR}"
  fi

  cd "${JEDI_BUNDLE_SRC_DIR}"
  git fetch --all --tags --prune
  git checkout "${JEDI_BUNDLE_REF}"
  git submodule sync --recursive || true
  git submodule update --init --recursive --checkout || true

  {
    echo "JEDI_BUNDLE_REPO=${JEDI_BUNDLE_REPO}"
    echo "JEDI_BUNDLE_REF=${JEDI_BUNDLE_REF}"
    echo "JEDI_BUNDLE_SRC_DIR=${JEDI_BUNDLE_SRC_DIR}"
    echo "commit=$(git rev-parse HEAD)"
    echo "describe=$(git describe --tags --always --dirty || true)"
    git submodule status --recursive || true
  } | tee "${MONAN_JEDI_LOG_ROOT}/02_jedi_bundle_source_state.log"
}

monan_jedi_create_mpas_only_bundle() {
  monan_jedi_load_stack

  if [[ ! -d "${JEDI_BUNDLE_SRC_DIR}/.git" ]]; then
    log_error "JEDI bundle source not found: ${JEDI_BUNDLE_SRC_DIR}"
    exit 1
  fi

  cd "${JEDI_BUNDLE_SRC_DIR}"

  local backup_file="CMakeLists.txt.monan-jedi-backup"
  [[ -f "${backup_file}" ]] || cp CMakeLists.txt "${backup_file}"

  log_warn "Reduced CMakeLists.txt generation should reuse the current implementation from scripts/03_create_mpas_only_bundle.sh."
  log_warn "This module is intentionally separated so the generated CMake content can be maintained in one place."
}
