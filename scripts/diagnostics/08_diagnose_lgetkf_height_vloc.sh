#!/usr/bin/env bash
# =============================================================================
# 08_diagnose_lgetkf_height_vloc.sh
# =============================================================================
# Diagnose the known MPAS-JEDI test failure:
#
#   mpasjedi_lgetkf_height_vloc
#
# This test has been observed to fail on JACI after a successful MPAS-JEDI build
# because the generated floating-point summary differs from the bundled
# reference beyond the test tolerance.
#
# This script does not modify references. It collects enough evidence to decide
# whether the failure is deterministic and limited to reference sensitivity.
# =============================================================================

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=00_common.sh
source "${script_dir}/00_common.sh"

load_monan_jedi_stack
require_cmd ctest
require_cmd diff

export DIAG_DIR="${DIAG_DIR:-${MONAN_JEDI_LOG_ROOT}/diagnostics/lgetkf_height_vloc}"
mkdir -p "${DIAG_DIR}"

if [[ ! -d "${JEDI_BUNDLE_BUILD_DIR}/mpas-jedi/test" ]]; then
  log_error "MPAS-JEDI test directory not found: ${JEDI_BUNDLE_BUILD_DIR}/mpas-jedi/test"
  exit 1
fi

cd "${JEDI_BUNDLE_BUILD_DIR}"

{
  echo "# lgetkf_height_vloc diagnostic"
  echo "GeneratedAt=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "Host=$(hostname)"
  echo "STACK_TEST_ID=${STACK_TEST_ID}"
  echo "MONAN_JEDI_TEST_ID=${MONAN_JEDI_TEST_ID}"
  echo "JEDI_BUNDLE_BUILD_DIR=${JEDI_BUNDLE_BUILD_DIR}"
  echo
  echo "## CTest command"
  ctest -N -V -R '^mpasjedi_lgetkf_height_vloc$' || true
} | tee "${DIAG_DIR}/00_ctest_command.log"

log_info "Running first lgetkf_height_vloc attempt"
ctest --output-on-failure -V -R '^mpasjedi_lgetkf_height_vloc$' \
  2>&1 | tee "${DIAG_DIR}/01_lgetkf_height_vloc_run1.log" || true

if [[ -f "${JEDI_BUNDLE_BUILD_DIR}/mpas-jedi/test/testoutput/lgetkf_height_vloc.run.ref" ]]; then
  cp "${JEDI_BUNDLE_BUILD_DIR}/mpas-jedi/test/testoutput/lgetkf_height_vloc.run.ref" \
     "${DIAG_DIR}/lgetkf_height_vloc.run1.ref"
fi

log_info "Running second lgetkf_height_vloc attempt"
ctest --output-on-failure -V -R '^mpasjedi_lgetkf_height_vloc$' \
  2>&1 | tee "${DIAG_DIR}/02_lgetkf_height_vloc_run2.log" || true

if [[ -f "${JEDI_BUNDLE_BUILD_DIR}/mpas-jedi/test/testoutput/lgetkf_height_vloc.run.ref" ]]; then
  cp "${JEDI_BUNDLE_BUILD_DIR}/mpas-jedi/test/testoutput/lgetkf_height_vloc.run.ref" \
     "${DIAG_DIR}/lgetkf_height_vloc.run2.ref"
fi

cd "${JEDI_BUNDLE_BUILD_DIR}/mpas-jedi/test"

if [[ -f testoutput/lgetkf_height_vloc.ref && -f testoutput/lgetkf_height_vloc.run.ref ]]; then
  diff -u testoutput/lgetkf_height_vloc.ref testoutput/lgetkf_height_vloc.run.ref \
    > "${DIAG_DIR}/reference_vs_run.diff" || true
fi

if [[ -f "${DIAG_DIR}/lgetkf_height_vloc.run1.ref" && -f "${DIAG_DIR}/lgetkf_height_vloc.run2.ref" ]]; then
  diff -u "${DIAG_DIR}/lgetkf_height_vloc.run1.ref" \
          "${DIAG_DIR}/lgetkf_height_vloc.run2.ref" \
    > "${DIAG_DIR}/run1_vs_run2.diff" || true
fi

{
  echo "# lgetkf_height_vloc diagnostic summary"
  echo "GeneratedAt=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo
  echo "## Failure lines"
  grep -RniE 'Float mismatch|TestReferenceFloatMismatchError|Test Val|Ref  Val|Delta|Relative tolerance|Absolute tolerance|The following tests FAILED|mpasjedi_lgetkf_height_vloc' \
    "${DIAG_DIR}" || true
  echo
  echo "## Reference vs run diff head"
  sed -n '1,220p' "${DIAG_DIR}/reference_vs_run.diff" 2>/dev/null || true
  echo
  echo "## Run1 vs run2 diff head"
  sed -n '1,220p' "${DIAG_DIR}/run1_vs_run2.diff" 2>/dev/null || true
} | tee "${DIAG_DIR}/summary.log"

log_info "Diagnostic files written to: ${DIAG_DIR}"
