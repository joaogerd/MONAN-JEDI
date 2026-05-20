#!/usr/bin/env bash
# Build commands.

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
