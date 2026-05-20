#!/usr/bin/env bash
# JEDI bundle preparation helpers.
#
# Purpose:
#   Prepare the user-owned JEDI bundle source tree used by the MONAN-JEDI
#   reduced MPAS-JEDI workflow.
#
# Functions:
#   monan_jedi_prepare_bundle
#     Clone or update the configured JEDI bundle repository, check out the
#     requested reference and initialize submodules.
#
#   monan_jedi_create_mpas_only_bundle
#     Replace the upstream JEDI bundle CMakeLists.txt with the MONAN-JEDI
#     MPAS-only template and verify that FV3/FMS references are not present.

monan_jedi_prepare_bundle() {
  require_cmd git

  # This step only prepares the user-owned source tree. It does not need the
  # spack-stack runtime environment.
  mkdir -p "$(dirname "${JEDI_BUNDLE_SRC_DIR}")" "${MONAN_JEDI_LOG_ROOT}"

  # Clone the JEDI bundle only when the local source tree does not exist yet.
  if [[ ! -d "${JEDI_BUNDLE_SRC_DIR}/.git" ]]; then
    git clone "${JEDI_BUNDLE_REPO}" "${JEDI_BUNDLE_SRC_DIR}"
  fi

  cd "${JEDI_BUNDLE_SRC_DIR}" || {
    log_error "Failed to enter JEDI bundle source directory: ${JEDI_BUNDLE_SRC_DIR}"
    exit 1
  }

  # Refresh remote metadata and move the checkout to the configured reference.
  git fetch --all --tags --prune
  git checkout "${JEDI_BUNDLE_REF}"

  # Submodule operations are allowed to continue because some references may not
  # require every optional submodule to be checked out successfully.
  git submodule sync --recursive || true
  git submodule update --init --recursive --checkout || true

  # Record enough source metadata to make the build reproducible later.
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
  # Validate that the JEDI bundle source was prepared before patching CMake.
  if [[ ! -d "${JEDI_BUNDLE_SRC_DIR}/.git" ]]; then
    log_error "JEDI bundle source not found: ${JEDI_BUNDLE_SRC_DIR}"
    exit 1
  fi

  local repo_root
  repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

  # Resolve the template path. Relative paths are interpreted from the
  # MONAN-JEDI repository root so that the YAML configuration remains portable.
  local template_file="${JEDI_BUNDLE_CMAKELISTS_TEMPLATE:-templates/CMakeLists.monan-jedi-mpas-only.txt}"
  if [[ "${template_file}" != /* ]]; then
    template_file="${repo_root}/${template_file}"
  fi

  if [[ ! -f "${template_file}" ]]; then
    log_error "CMakeLists template not found: ${template_file}"
    exit 1
  fi

  cd "${JEDI_BUNDLE_SRC_DIR}" || {
    log_error "Failed to enter JEDI bundle source directory: ${JEDI_BUNDLE_SRC_DIR}"
    exit 1
  }

  # Preserve the original file once, allowing repeated executions to remain
  # idempotent and easy to inspect.
  local backup_file="CMakeLists.txt.monan-jedi-backup"
  if [[ ! -f "${backup_file}" ]]; then
    cp CMakeLists.txt "${backup_file}"
  fi

  # Install the reduced MPAS-only CMakeLists.txt.
  cp "${template_file}" CMakeLists.txt

  # Record the applied change for traceability.
  {
    echo "JEDI_BUNDLE_SRC_DIR=${JEDI_BUNDLE_SRC_DIR}"
    echo "template=${template_file}"
    echo "backup=${backup_file}"
    echo "commit=$(git rev-parse HEAD)"
    echo
    git diff -- CMakeLists.txt || true
  } | tee "${MONAN_JEDI_LOG_ROOT}/03_mpas_only_cmake_patch.log"

  # The reduced bundle must not keep FV3/FMS dependencies.
  if grep -Eq 'fv3|fv3-jedi|fv3jedi|fv3jedilm|FMS' CMakeLists.txt; then
    log_error "Reduced MPAS-only CMakeLists.txt still references FV3/FMS."
    log_error "Template is not MPAS-only: ${template_file}"
    exit 1
  fi

  log_info "Reduced MPAS-JEDI-only CMakeLists.txt generated"
}
