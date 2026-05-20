#!/usr/bin/env bash
# JEDI bundle preparation helpers.

monan_jedi_prepare_bundle() {
  require_cmd git

  # This step only prepares the user-owned source tree. It does not need the
  # spack-stack runtime environment.
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
    echo
    git status --short
    echo
    git submodule status --recursive || true
  } | tee "${MONAN_JEDI_LOG_ROOT}/02_jedi_bundle_source_state.log"

  log_info "Prepared JEDI bundle source"
}

monan_jedi_create_mpas_only_bundle() {
  # This step only edits the user-owned source tree. It does not need the
  # spack-stack runtime environment.
  if [[ ! -d "${JEDI_BUNDLE_SRC_DIR}/.git" ]]; then
    log_error "JEDI bundle source not found: ${JEDI_BUNDLE_SRC_DIR}"
    exit 1
  fi

  local repo_root
  repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

  local template_file="${JEDI_BUNDLE_CMAKELISTS_TEMPLATE:-templates/CMakeLists.monan-jedi-mpas-only.txt}"
  if [[ "${template_file}" != /* ]]; then
    template_file="${repo_root}/${template_file}"
  fi

  if [[ ! -f "${template_file}" ]]; then
    log_error "CMakeLists template not found: ${template_file}"
    exit 1
  fi

  cd "${JEDI_BUNDLE_SRC_DIR}"

  local backup_file="CMakeLists.txt.monan-jedi-backup"
  if [[ ! -f "${backup_file}" ]]; then
    cp CMakeLists.txt "${backup_file}"
  fi

  cp "${template_file}" CMakeLists.txt

  {
    echo "JEDI_BUNDLE_SRC_DIR=${JEDI_BUNDLE_SRC_DIR}"
    echo "template=${template_file}"
    echo "backup=${backup_file}"
    echo "commit=$(git rev-parse HEAD)"
    echo
    git diff -- CMakeLists.txt || true
  } | tee "${MONAN_JEDI_LOG_ROOT}/03_mpas_only_cmake_patch.log"

  if grep -Eq 'fv3|fv3-jedi|fv3jedi|fv3jedilm|FMS' CMakeLists.txt; then
    log_error "Reduced MPAS-only CMakeLists.txt still references FV3/FMS."
    log_error "Template is not MPAS-only: ${template_file}"
    exit 1
  fi

  log_info "Reduced MPAS-JEDI-only CMakeLists.txt generated"
}
