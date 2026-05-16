#!/usr/bin/env bash
# =============================================================================
# 09_clean_mpas_jedi_test_outputs.sh
# =============================================================================
# Clean generated MPAS-JEDI test outputs without deleting the build tree.
#
# Purpose
# -------
# This script is useful before re-running CTest to ensure that old `.run`,
# `.run.ref`, PBS logs and generated diagnostic files do not contaminate the
# validation evidence.
#
# It does NOT delete:
#   - source tree
#   - build tree
#   - compiled executables
#   - input test data
#   - bundled reference files such as testoutput/*.ref
#
# Usage
# -----
#   export STACK_TEST_ID=spack-stack-inpe-overlay-20260515T181917Z
#   export MONAN_JEDI_TEST_ID=monan-jedi-mpas-only-20260516T170436Z
#   bash scripts/09_clean_mpas_jedi_test_outputs.sh
# =============================================================================

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=00_common.sh
source "${script_dir}/00_common.sh"

mpas_test_dir="${JEDI_BUNDLE_BUILD_DIR}/mpas-jedi/test"

if [[ ! -d "${mpas_test_dir}" ]]; then
  log_error "MPAS-JEDI test directory not found: ${mpas_test_dir}"
  log_error "Configure/build the bundle first."
  exit 1
fi

log_info "Cleaning generated MPAS-JEDI test outputs"
log_info "  test dir=${mpas_test_dir}"
log_info "  log dir=${MONAN_JEDI_LOG_ROOT}"

# Remove generated test output files, but preserve bundled reference symlinks/files.
find "${mpas_test_dir}/testoutput" -maxdepth 1 -type f \
  \( -name '*.run' -o -name '*.run.ref' -o -name '*.run.log' -o -name '*.run.err' \) \
  -print -delete 2>/dev/null || true

# Remove generated MPAS-JEDI data products from previous test runs where present.
find "${mpas_test_dir}/Data" -type f \
  \( -name 'obsout_*.nc4' -o -name 'an.*.nc' -o -name 'an.var.*.nc' -o -name 'increment.*.nc' \) \
  -print -delete 2>/dev/null || true

# Remove CTest temporary logs so the next run has clean evidence.
rm -rf "${JEDI_BUNDLE_BUILD_DIR}/Testing/Temporary" 2>/dev/null || true

# Remove previous MONAN-JEDI validation logs, but keep configure/build logs.
rm -f \
  "${MONAN_JEDI_LOG_ROOT}/06_ctest.log" \
  "${MONAN_JEDI_LOG_ROOT}/06_ctest_pbs.log" \
  "${MONAN_JEDI_LOG_ROOT}/06_ctest_pbs.out" \
  "${MONAN_JEDI_LOG_ROOT}/06_ctest_pbs.err" \
  "${MONAN_JEDI_LOG_ROOT}/06_ctest_pbs_environment.log" \
  "${MONAN_JEDI_LOG_ROOT}/06_ctest_pbs_jobid.txt" \
  "${MONAN_JEDI_LOG_ROOT}/06_mpas_jedi_ctest.pbs" \
  "${MONAN_JEDI_LOG_ROOT}/07_summary.log" 2>/dev/null || true

log_info "Clean completed."
