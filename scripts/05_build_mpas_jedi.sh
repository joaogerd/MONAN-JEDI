#!/usr/bin/env bash
# =============================================================================
# 05_build_mpas_jedi.sh
# =============================================================================
# Build the reduced MPAS-JEDI-only bundle on JACI.
# =============================================================================

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=00_common.sh
source "${script_dir}/00_common.sh"

require_cmd make
load_monan_jedi_stack

export MONAN_JEDI_BUILD_JOBS="${MONAN_JEDI_BUILD_JOBS:-8}"

if [[ ! -f "${JEDI_BUNDLE_BUILD_DIR}/Makefile" ]]; then
  log_error "Build tree does not contain Makefile: ${JEDI_BUNDLE_BUILD_DIR}"
  log_error "Run scripts/04_configure_mpas_jedi.sh first."
  exit 1
fi

cd "${JEDI_BUNDLE_BUILD_DIR}"

log_info "Building MPAS-JEDI-only bundle"
log_info "  JEDI_BUNDLE_BUILD_DIR=${JEDI_BUNDLE_BUILD_DIR}"
log_info "  MONAN_JEDI_BUILD_JOBS=${MONAN_JEDI_BUILD_JOBS}"
log_info "  log=${MONAN_JEDI_LOG_ROOT}/05_make.log"

make -j "${MONAN_JEDI_BUILD_JOBS}" 2>&1 | tee "${MONAN_JEDI_LOG_ROOT}/05_make.log"

log_info "MPAS-JEDI build completed."
