#!/usr/bin/env bash
# Build commands for the MONAN-JEDI reduced MPAS-JEDI workflow.
#
# Purpose:
#   Compile the already configured JEDI bundle build tree with make.
#
# Requires:
#   load_monan_jedi_config must have defined JEDI_BUNDLE_BUILD_DIR,
#   MONAN_JEDI_BUILD_JOBS and MONAN_JEDI_LOG_ROOT. The configure step must have
#   completed successfully and produced a Makefile in JEDI_BUNDLE_BUILD_DIR.
#
# Produces:
#   ${MONAN_JEDI_LOG_ROOT}/05_make.log
#
# Expected result:
#   make exits with status zero and the log contains the normal CMake target
#   build progress. Any compiler, linker or missing dependency error is captured
#   in 05_make.log.

monan_jedi_build_bundle() {
  monan_jedi_load_stack
  require_cmd make

  if [[ ! -f "${JEDI_BUNDLE_BUILD_DIR}/Makefile" ]]; then
    log_error "Build tree does not contain Makefile: ${JEDI_BUNDLE_BUILD_DIR}"
    exit 1
  fi

  cd "${JEDI_BUNDLE_BUILD_DIR}"
  make -j "${MONAN_JEDI_BUILD_JOBS}" 2>&1 | tee "${MONAN_JEDI_LOG_ROOT}/05_make.log"
}
