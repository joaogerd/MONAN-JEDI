#!/usr/bin/env bash
# Login-node-safe CTest handling.

monan_jedi_test_login() {
  monan_jedi_load_stack
  require_cmd ctest

  local login_safe_regex="${MONAN_JEDI_CTEST_REGEX:-^mpasjedi_coding_norms$}"

  if [[ "${ALLOW_LOGIN_NODE_MPI_TESTS:-0}" != "1" ]]; then
    case "${login_safe_regex}" in
      '^mpasjedi_'*|'mpasjedi_'*|'.*mpasjedi_'*)
        if [[ "${login_safe_regex}" != "^mpasjedi_coding_norms$" ]]; then
          log_warn "Resetting broad MPAS-JEDI regex for login-node safety."
          login_safe_regex="^mpasjedi_coding_norms$"
        fi
        ;;
    esac
  fi

  if [[ ! -f "${JEDI_BUNDLE_BUILD_DIR}/CTestTestfile.cmake" ]]; then
    log_error "Build tree does not contain CTestTestfile.cmake: ${JEDI_BUNDLE_BUILD_DIR}"
    exit 1
  fi

  cd "${JEDI_BUNDLE_BUILD_DIR}"

  ctest --output-on-failure \
    -j "${MONAN_JEDI_CTEST_JOBS}" \
    -R "${login_safe_regex}" \
    2>&1 | tee "${MONAN_JEDI_LOG_ROOT}/06_ctest.log"
}
