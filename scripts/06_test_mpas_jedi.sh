#!/usr/bin/env bash
# =============================================================================
# 06_test_mpas_jedi.sh
# =============================================================================
# Run a login-node-safe CTest subset for the reduced MPAS-JEDI-only bundle on
# JACI.
#
# Important
# ---------
# This script intentionally does not run MPI tests by default.
#
# On JACI, MPI tests such as mpasjedi_geometry need a PBS compute-node
# allocation. Running them directly on the login node can fail with:
#
#   No host list provided
#
# Default login-node-safe scope:
#   ^mpasjedi_coding_norms$
#
# For MPI tests, use:
#   scripts/06_test_mpas_jedi_pbs.sh
#
# To override manually:
#   MONAN_JEDI_CTEST_REGEX='^mpasjedi_coding_norms$' bash scripts/06_test_mpas_jedi.sh
# =============================================================================

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=00_common.sh
source "${script_dir}/00_common.sh"

load_monan_jedi_stack
require_cmd ctest

export MONAN_JEDI_CTEST_REGEX="${MONAN_JEDI_CTEST_REGEX:-^mpasjedi_coding_norms$}"
export MONAN_JEDI_CTEST_EXCLUDE_REGEX="${MONAN_JEDI_CTEST_EXCLUDE_REGEX:-}"
export MONAN_JEDI_CTEST_JOBS="${MONAN_JEDI_CTEST_JOBS:-1}"

if [[ ! -f "${JEDI_BUNDLE_BUILD_DIR}/CTestTestfile.cmake" ]]; then
  log_error "Build tree does not contain CTestTestfile.cmake: ${JEDI_BUNDLE_BUILD_DIR}"
  log_error "Run configure and build first."
  exit 1
fi

cd "${JEDI_BUNDLE_BUILD_DIR}"

ctest_args=(--output-on-failure -j "${MONAN_JEDI_CTEST_JOBS}" -R "${MONAN_JEDI_CTEST_REGEX}")

if [[ -n "${MONAN_JEDI_CTEST_EXCLUDE_REGEX}" ]]; then
  ctest_args+=(-E "${MONAN_JEDI_CTEST_EXCLUDE_REGEX}")
fi

log_info "Running login-node-safe MPAS-JEDI CTest subset"
log_info "  JEDI_BUNDLE_BUILD_DIR=${JEDI_BUNDLE_BUILD_DIR}"
log_info "  MONAN_JEDI_CTEST_REGEX=${MONAN_JEDI_CTEST_REGEX}"
log_info "  MONAN_JEDI_CTEST_EXCLUDE_REGEX=${MONAN_JEDI_CTEST_EXCLUDE_REGEX}"
log_info "  MONAN_JEDI_CTEST_JOBS=${MONAN_JEDI_CTEST_JOBS}"
log_info "  log=${MONAN_JEDI_LOG_ROOT}/06_ctest.log"

ctest "${ctest_args[@]}" 2>&1 | tee "${MONAN_JEDI_LOG_ROOT}/06_ctest.log"

log_info "Login-node-safe MPAS-JEDI CTest subset completed."
