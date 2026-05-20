#!/usr/bin/env bash
# =============================================================================
# MONAN-JEDI build and validation command dispatcher
# =============================================================================
# Purpose:
#   Provide a single command-line entry point for preparing, configuring,
#   building and validating the reduced MONAN-JEDI MPAS-JEDI bundle on JACI.
#
# Notes:
#   The `test-pbs` command submits the complete CTest suite to PBS. It does not
#   wait for the PBS job to finish. For that reason, the `all` command submits
#   the PBS test job but does not collect logs immediately after submission.
#   Run `logs` after the PBS job has completed.
# =============================================================================

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=lib/common.sh
source "${script_dir}/lib/common.sh"
# shellcheck source=lib/config.sh
source "${script_dir}/lib/config.sh"
# shellcheck source=lib/stack.sh
source "${script_dir}/lib/stack.sh"
# shellcheck source=lib/bundle.sh
source "${script_dir}/lib/bundle.sh"
# shellcheck source=lib/configure.sh
source "${script_dir}/lib/configure.sh"
# shellcheck source=lib/build.sh
source "${script_dir}/lib/build.sh"
# shellcheck source=lib/test.sh
source "${script_dir}/lib/test.sh"
# shellcheck source=lib/pbs.sh
source "${script_dir}/lib/pbs.sh"
# shellcheck source=lib/logs.sh
source "${script_dir}/lib/logs.sh"

usage() {
  cat <<EOF
Usage:
  bash scripts/monan-jedi.sh <command> [--config config/jaci.yaml]

Commands:
  load        Load and validate the spack-stack environment
  prepare     Clone/update jedi-bundle
  reduce      Generate reduced MPAS-JEDI-only CMakeLists.txt
  configure   Configure the bundle with ecbuild
  build       Build the configured bundle
  test        Run login-node-safe CTest subset
  test-pbs    Submit the complete CTest suite to PBS
  logs        Collect logs after local commands or after PBS job completion
  all         Run load, prepare, reduce, configure, build, test, then submit test-pbs

Important:
  test-pbs submits a PBS job and returns immediately. Run logs only after the
  PBS job has completed.
EOF
}

command_name="${1:-}"
shift || true

while [[ $# -gt 0 ]]; do
  case "$1" in
    --config)
      export MONAN_JEDI_CONFIG="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      log_error "Unknown argument: $1"
      usage
      exit 1
      ;;
  esac
done

load_monan_jedi_config

case "${command_name}" in
  load)
    monan_jedi_load_stack
    monan_jedi_record_environment_snapshot "${MONAN_JEDI_LOG_ROOT}/01_stack_environment.log"
    ;;
  prepare)
    monan_jedi_prepare_bundle
    ;;
  reduce)
    monan_jedi_create_mpas_only_bundle
    ;;
  configure)
    monan_jedi_configure_bundle
    ;;
  build)
    monan_jedi_build_bundle
    ;;
  test)
    monan_jedi_test_login
    ;;
  test-pbs)
    monan_jedi_test_pbs
    ;;
  logs)
    monan_jedi_collect_logs
    ;;
  all)
    monan_jedi_load_stack
    monan_jedi_record_environment_snapshot "${MONAN_JEDI_LOG_ROOT}/01_stack_environment.log"
    monan_jedi_prepare_bundle
    monan_jedi_create_mpas_only_bundle
    monan_jedi_configure_bundle
    monan_jedi_build_bundle
    monan_jedi_test_login
    monan_jedi_test_pbs
    log_info "PBS test job submitted. The 'all' command does not wait for PBS completion."
    log_info "After the PBS job finishes, run: bash scripts/monan-jedi.sh logs --config ${MONAN_JEDI_CONFIG}"
    ;;
  ""|-h|--help)
    usage
    ;;
  *)
    log_error "Unknown command: ${command_name}"
    usage
    exit 1
    ;;
esac
