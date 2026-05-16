#!/usr/bin/env bash
# =============================================================================
# 06_test_mpas_jedi_pbs.sh
# =============================================================================
# Submit MPAS-JEDI CTest execution to a PBS compute node on JACI.
#
# Why this exists
# ---------------
# Many JEDI/MPAS-JEDI tests are MPI tests and should not be used as a first-pass
# login-node validation. This launcher creates a PBS job that reloads the stack
# and runs a controlled CTest subset from the build directory.
#
# Default test:
#   ^mpasjedi_geometry$
#
# Usage
# -----
#   export STACK_TEST_ID=spack-stack-inpe-overlay-20260515T181917Z
#   export MONAN_JEDI_TEST_ID=monan-jedi-mpas-only-20260516T170436Z
#   bash scripts/06_test_mpas_jedi_pbs.sh
#
# Optional overrides
# ------------------
#   MONAN_JEDI_PBS_QUEUE=pesqmini
#   MONAN_JEDI_PBS_NCPUS=64
#   MONAN_JEDI_PBS_WALLTIME=00:30:00
#   MONAN_JEDI_CTEST_REGEX='^mpasjedi_geometry$'
#   MONAN_JEDI_CTEST_EXCLUDE_REGEX=''
#   MONAN_JEDI_CTEST_JOBS=1
#
# =============================================================================

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=00_common.sh
source "${script_dir}/00_common.sh"

require_cmd qsub

export MONAN_JEDI_PBS_QUEUE="${MONAN_JEDI_PBS_QUEUE:-pesqmini}"
export MONAN_JEDI_PBS_NCPUS="${MONAN_JEDI_PBS_NCPUS:-64}"
export MONAN_JEDI_PBS_WALLTIME="${MONAN_JEDI_PBS_WALLTIME:-00:30:00}"
export MONAN_JEDI_CTEST_REGEX="${MONAN_JEDI_CTEST_REGEX:-^mpasjedi_geometry$}"
export MONAN_JEDI_CTEST_EXCLUDE_REGEX="${MONAN_JEDI_CTEST_EXCLUDE_REGEX:-}"
export MONAN_JEDI_CTEST_JOBS="${MONAN_JEDI_CTEST_JOBS:-1}"

mkdir -p "${MONAN_JEDI_LOG_ROOT}"

pbs_script="${MONAN_JEDI_LOG_ROOT}/06_mpas_jedi_ctest.pbs"

cat > "${pbs_script}" <<EOF
#PBS -N monan_jedi_ctest
#PBS -q ${MONAN_JEDI_PBS_QUEUE}
#PBS -l select=1:ncpus=${MONAN_JEDI_PBS_NCPUS}
#PBS -l walltime=${MONAN_JEDI_PBS_WALLTIME}
#PBS -o ${MONAN_JEDI_LOG_ROOT}/06_ctest_pbs.out
#PBS -e ${MONAN_JEDI_LOG_ROOT}/06_ctest_pbs.err

set -euo pipefail

cd ${PWD}

export PROJECT_ROOT=${PROJECT_ROOT}
export STACK_TEST_ID=${STACK_TEST_ID}
export MONAN_JEDI_TEST_ID=${MONAN_JEDI_TEST_ID}
export STACK_WORK_ROOT=${STACK_WORK_ROOT}
export STACK_ENV_NAME=${STACK_ENV_NAME}
export STACK_ROOT=${STACK_ROOT}
export STACK_MODULE_ROOT=${STACK_MODULE_ROOT}
export STACK_ENV_MODULE=${STACK_ENV_MODULE}
export MONAN_JEDI_WORK_ROOT=${MONAN_JEDI_WORK_ROOT}
export MONAN_JEDI_LOG_ROOT=${MONAN_JEDI_LOG_ROOT}
export JEDI_BUNDLE_SRC_DIR=${JEDI_BUNDLE_SRC_DIR}
export JEDI_BUNDLE_BUILD_DIR=${JEDI_BUNDLE_BUILD_DIR}
export MONAN_JEDI_CTEST_REGEX='${MONAN_JEDI_CTEST_REGEX}'
export MONAN_JEDI_CTEST_EXCLUDE_REGEX='${MONAN_JEDI_CTEST_EXCLUDE_REGEX}'
export MONAN_JEDI_CTEST_JOBS=${MONAN_JEDI_CTEST_JOBS}

source ${script_dir}/00_common.sh
load_monan_jedi_stack

cd "${JEDI_BUNDLE_BUILD_DIR}"

ctest_args=(--output-on-failure -j "${MONAN_JEDI_CTEST_JOBS}" -R "${MONAN_JEDI_CTEST_REGEX}")
if [[ -n "${MONAN_JEDI_CTEST_EXCLUDE_REGEX}" ]]; then
  ctest_args+=(-E "${MONAN_JEDI_CTEST_EXCLUDE_REGEX}")
fi

{
  echo "GeneratedAt="][\$(date -u +%Y-%m-%dT%H:%M:%SZ)]
  echo "Host=\$(hostname)"
  echo "PBS_JOBID=\${PBS_JOBID:-}"
  echo "PBS_QUEUE=\${PBS_QUEUE:-}"
  echo "PBS_NODEFILE=\${PBS_NODEFILE:-}"
  echo "PWD=\$(pwd)"
  echo "MONAN_JEDI_CTEST_REGEX=${MONAN_JEDI_CTEST_REGEX}"
  echo "MONAN_JEDI_CTEST_EXCLUDE_REGEX=${MONAN_JEDI_CTEST_EXCLUDE_REGEX}"
  echo "which ctest=\$(command -v ctest)"
  echo "which mpiexec=\$(command -v mpiexec || true)"
  echo "which mpirun=\$(command -v mpirun || true)"
  module list 2>&1 || true
} | tee "${MONAN_JEDI_LOG_ROOT}/06_ctest_pbs_environment.log"

ctest "\${ctest_args[@]}" 2>&1 | tee "${MONAN_JEDI_LOG_ROOT}/06_ctest_pbs.log"
EOF

log_info "Submitting PBS MPAS-JEDI CTest job"
log_info "  PBS script=${pbs_script}"
log_info "  queue=${MONAN_JEDI_PBS_QUEUE}"
log_info "  walltime=${MONAN_JEDI_PBS_WALLTIME}"
log_info "  regex=${MONAN_JEDI_CTEST_REGEX}"

qsub "${pbs_script}" | tee "${MONAN_JEDI_LOG_ROOT}/06_ctest_pbs_jobid.txt"
