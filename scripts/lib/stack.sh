#!/usr/bin/env bash
# Stack environment handling.

monan_jedi_reset_modules() {
  module --force purge 2>/dev/null || module purge 2>/dev/null || true

  for d in \
    /opt/cray/pe/modulefiles \
    /opt/cray/modulefiles \
    /opt/cray/pe/craype-targets/default/modulefiles \
    /p/app/modulefiles \
    /opt/cray/pals/modulefiles
  do
    [[ -d "${d}" ]] && module use "${d}"
  done
}

monan_jedi_load_stack() {
  if [[ ! -d "${STACK_ROOT}" ]]; then
    log_error "STACK_ROOT not found: ${STACK_ROOT}"
    exit 1
  fi

  if [[ ! -d "${STACK_MODULE_ROOT}" ]]; then
    log_error "STACK_MODULE_ROOT not found: ${STACK_MODULE_ROOT}"
    exit 1
  fi

  monan_jedi_reset_modules

  cd "${STACK_ROOT}"
  source configs/sites/tier2/jaci/setup.sh

  module use "${STACK_MODULE_ROOT}"
  module load "${STACK_ENV_MODULE}"

  export CC="$(resolve_cmd CC "${MONAN_JEDI_CC}")"
  export CXX="$(resolve_cmd CXX "${MONAN_JEDI_CXX}")"
  export FC="$(resolve_cmd FC "${MONAN_JEDI_FC}")"

  export MPICC="$(resolve_cmd MPICC "${MONAN_JEDI_MPICC}")"
  export MPICXX="$(resolve_cmd MPICXX "${MONAN_JEDI_MPICXX}")"
  export MPIFC="$(resolve_cmd MPIFC "${MONAN_JEDI_MPIFC}")"

  log_info "Loaded MONAN-JEDI stack environment"
}
