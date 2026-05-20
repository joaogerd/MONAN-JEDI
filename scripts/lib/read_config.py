#!/usr/bin/env python3
"""Read MONAN-JEDI YAML configuration and emit shell exports."""

import os
import shlex
import sys

try:
    import yaml
except ImportError:
    sys.stderr.write("PyYAML is required.\n")
    sys.exit(1)


def get_value(data, path, default=""):
    cur = data
    for key in path.split("."):
        if not isinstance(cur, dict) or key not in cur:
            return default
        cur = cur[key]

    if cur is None:
        return default

    if isinstance(cur, bool):
        return "1" if cur else "0"

    return os.path.expandvars(str(cur))


def emit(name, value):
    env_value = os.environ.get(name, value)
    sys.stdout.write("export {0}={1}\n".format(name, shlex.quote(env_value)))


def read_yaml(path):
    with open(path, "r") as f:
        loaded = yaml.safe_load(f)
    return loaded or {}


def main():
    if len(sys.argv) != 2:
        sys.stderr.write("Usage: read_config.py <config.yaml>\n")
        return 2

    data = read_yaml(sys.argv[1])

    mapping = {
        "PROJECT_ROOT": "project.root",
        "STACK_OWNER": "stack.owner",
        "STACK_INSTANCE": "stack.instance",
        "STACK_WORK_ROOT": "stack.work_root",
        "STACK_ROOT": "stack.root",
        "STACK_ENV_NAME": "stack.env_name",
        "STACK_MODULE_ROOT": "stack.module_root",
        "STACK_SITE_SETUP": "stack.site_setup",
        "STACK_ENV_MODULE": "stack.env_module",
        "MONAN_JEDI_RUN_ID": "build.id",
        "MONAN_JEDI_CC": "compilers.cc",
        "MONAN_JEDI_CXX": "compilers.cxx",
        "MONAN_JEDI_FC": "compilers.fc",
        "MONAN_JEDI_F77": "compilers.f77",
        "MONAN_JEDI_F90": "compilers.f90",
        "MONAN_JEDI_MPICC": "mpi.mpicc",
        "MONAN_JEDI_MPICXX": "mpi.mpicxx",
        "MONAN_JEDI_MPIFC": "mpi.mpifc",
        "MONAN_JEDI_MPIF77": "mpi.mpif77",
        "MONAN_JEDI_MPIF90": "mpi.mpif90",
        "JEDI_BUNDLE_REPO": "jedi_bundle.repo",
        "JEDI_BUNDLE_REF": "jedi_bundle.ref",
        "JEDI_BUNDLE_CMAKELISTS_TEMPLATE": "jedi_bundle.cmakelists_template",
        "MONAN_JEDI_BUILD_JOBS": "build.jobs",
        "MONAN_JEDI_CTEST_REGEX": "ctest.login_regex",
        "MONAN_JEDI_CTEST_PBS_REGEX": "ctest.pbs_regex",
        "MONAN_JEDI_CTEST_EXCLUDE_REGEX": "ctest.exclude_regex",
        "MONAN_JEDI_CTEST_JOBS": "ctest.jobs",
        "ALLOW_LOGIN_NODE_MPI_TESTS": "ctest.allow_login_node_mpi_tests",
        "MONAN_JEDI_PBS_QUEUE": "pbs.queue",
        "MONAN_JEDI_PBS_NCPUS": "pbs.ncpus",
        "MONAN_JEDI_PBS_WALLTIME": "pbs.walltime",
        "MONAN_JEDI_SUBMIT_JOB": "pbs.submit_job",
    }

    defaults = {
        "STACK_OWNER": os.environ.get("USER", "unknown"),
        "STACK_SITE_SETUP": "configs/sites/tier2/jaci/setup.sh",
        "MONAN_JEDI_CC": "cc",
        "MONAN_JEDI_CXX": "CC",
        "MONAN_JEDI_FC": "ftn",
        "MONAN_JEDI_F77": "ftn",
        "MONAN_JEDI_F90": "ftn",
        "MONAN_JEDI_MPICC": "cc",
        "MONAN_JEDI_MPICXX": "CC",
        "MONAN_JEDI_MPIFC": "ftn",
        "MONAN_JEDI_MPIF77": "ftn",
        "MONAN_JEDI_MPIF90": "ftn",
        "JEDI_BUNDLE_REPO": "https://github.com/JCSDA/jedi-bundle.git",
        "JEDI_BUNDLE_REF": "develop",
        "JEDI_BUNDLE_CMAKELISTS_TEMPLATE": "templates/CMakeLists.monan-jedi-mpas-only.txt",
        "MONAN_JEDI_BUILD_JOBS": "8",
        "MONAN_JEDI_CTEST_JOBS": "1",
        "MONAN_JEDI_PBS_QUEUE": "pesqmini",
        "MONAN_JEDI_PBS_NCPUS": "64",
        "MONAN_JEDI_PBS_WALLTIME": "00:30:00",
        "MONAN_JEDI_SUBMIT_JOB": "1",
    }

    for env_name, yaml_path in mapping.items():
        emit(env_name, get_value(data, yaml_path, defaults.get(env_name, "")))

    return 0


if __name__ == "__main__":
    sys.exit(main())
