#!/usr/bin/env bash
# =============================================================================
# 06_test_mpas_jedi.sh
# =============================================================================
# Run CTest for the reduced MPAS-JEDI-only bundle on JACI.
# =============================================================================

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=00_common.sh
source "${script_dir}/00_common.sh"

require_cmd ctest
load_monan_jedi_stack

export MONAN_JEDI_CTEST_REGEX="${MONAN_JEDI_CTEST_REGEX:-}"
export MONAN_JEDI_CTEST_EXCLUDE_REGEX="${MONAN_JEDI_CTEST_EXCLUDE_REGEX:-}"
export MONAN_JEDI_CTEST_JOBS="${MONAN_JEDI_CTEST_JOBS:-1}"

if [[ ! -f "${JEDI_BUNDLE_BUILD_DIR}/CTestTestfile.cmake" ]]; then
  log_error "Build tree does not contain CTestTestfile.cmake: ${JEDI_BUNDLE_BUILD_DIR}"
  log_error "Run configure and build first."
  exit 1
fi

cd "${JEDI_BUNDLE_BUILD_DIR}"

ctest_args=(--output-on-failure -j "${MONAN_JEDI_CTEST_JOBS}")

if [[ -n "${MONAN_JEDI_CTEST_REGEX}" ]]; then
  ctest_args+=(-R "${MONAN_JEDI_CTEST_REGEX}")
fi

if [[ -n "${MONAN_JEDI_CTEST_EXCLUDE_REGEX}" ]]; then
  ctest_args+=(-E "${MONAN_JEDI_CTEST_EXCLUDE_REGEX}")
fi

log_info "Running MPAS-JEDI CTest"
log_info "  JEDI_BUNDLE_BUILD_DIR=${JEDI_BUNDLE_BUILD_DIR}"
log_info "  MONAN_JEDI_CTEST_REGEX=${MONAN_JEDI_CTEST_REGEX}"
log_info "  MONAN_JEDI_CTEST_EXCLUDE_REGEX=${MONAN_JEDI_CTEST_EXCLUDE_REGEX}"
log_info "  MONAN_JEDI_CTEST_JOBS=${MONAN_JEDI_CTEST_JOBS}"
log_info "  log=${MONAN_JEDI_LOG_ROOT}/06_ctest.log"

ctest "${ctest_args[@]}" 2>&1 | tee "${MONAN_JEDI_LOG_ROOT}/06_ctest.log"

log_info "MPAS-JEDI CTest completed."
