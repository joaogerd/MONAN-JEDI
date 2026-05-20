# MONAN-JEDI

Repository for the MONAN-JEDI development workflow on INPE/JACI.

This repository is intentionally separated from `spack-stack-inpe`.

## Scope

`spack-stack-inpe` contains the site configuration and the reproducible software stack for JACI.

`MONAN-JEDI` contains the workflow used to prepare, configure, build and validate the MPAS-JEDI/JEDI bundle using that stack.

## Current JACI target

The current target is a MPAS-JEDI build on JACI using:

```text
spack-stack release/2.1
JACI CrayPE
PrgEnv-gnu/8.6.0
gcc-native/12.3
cray-mpich/8.1.31
libfabric/1.22.0
cray-pals/1.6.1
jedi-mpas-env/1.0.0
```

The stack must already have been created and validated by `spack-stack-inpe` before running the scripts in this repository.

## Important: do not edit scripts to change variables

All user-specific values must be set as environment variables before running the scripts.

Do not edit the scripts directly to change paths, user names, queue names, walltime or CTest filters.

## Shared stack variables

When using the shared stack installed under `joao.gerd`, use:

```bash
export STACK_OWNER="joao.gerd"
export STACK_TEST_ID="spack-stack-inpe-overlay-20260515T181917Z"
export MONAN_JEDI_TEST_ID="monan-jedi-mpas-only-$(date -u +%Y%m%dT%H%M%SZ)"
```

With these settings:

```text
STACK_ROOT=/p/projetos/monan_das/joao.gerd/work/spack-stack-inpe-overlay-20260515T181917Z/spack-stack
```

The MONAN-JEDI source tree, build tree and logs remain under the account of the user running the scripts:

```text
/p/projetos/monan_das/$USER/work/$MONAN_JEDI_TEST_ID
/p/projetos/monan_das/$USER/logs/$MONAN_JEDI_TEST_ID
```

## PBS and CTest variables

The complete CTest suite must be executed on a compute node through PBS.

Recommended values for the current JACI validation are:

```bash
export MONAN_JEDI_PBS_QUEUE="pesqmini"
export MONAN_JEDI_PBS_NCPUS=64
export MONAN_JEDI_PBS_WALLTIME="00:30:00"
export MONAN_JEDI_CTEST_JOBS=1
```

The current full CTest run contains 2294 tests. Three tests are currently treated as known issues:

```text
ioda_bufr_python_encoder
ioda_bufr_python_parallel
mpasjedi_lgetkf_height_vloc
```

To run the complete suite excluding these known issues:

```bash
export MONAN_JEDI_CTEST_EXCLUDE_REGEX='^(ioda_bufr_python_encoder|ioda_bufr_python_parallel|mpasjedi_lgetkf_height_vloc)$'
```

## Recommended workflow using the shared JACI stack

```bash
cd /p/projetos/monan_das/$USER/projects/MONAN-JEDI

git pull

export STACK_OWNER="joao.gerd"
export STACK_TEST_ID="spack-stack-inpe-overlay-20260515T181917Z"
export MONAN_JEDI_TEST_ID="monan-jedi-mpas-only-$(date -u +%Y%m%dT%H%M%SZ)"

export MONAN_JEDI_PBS_QUEUE="pesqmini"
export MONAN_JEDI_PBS_NCPUS=64
export MONAN_JEDI_PBS_WALLTIME="00:30:00"
export MONAN_JEDI_CTEST_JOBS=1
export MONAN_JEDI_CTEST_EXCLUDE_REGEX='^(ioda_bufr_python_encoder|ioda_bufr_python_parallel|mpasjedi_lgetkf_height_vloc)$'

bash scripts/01_load_stack_env.sh
bash scripts/02_prepare_jedi_bundle.sh
bash scripts/03_create_mpas_only_bundle.sh
bash scripts/04_configure_mpas_jedi.sh
bash scripts/05_build_mpas_jedi.sh
bash scripts/11_test_all_jedi_pbs.sh
```

Monitor the PBS job with:

```bash
qstat -u $USER
```

After the PBS job finishes, collect and inspect logs:

```bash
bash scripts/07_collect_logs.sh

grep -nE "tests passed|tests failed|The following tests FAILED|Total Test time" \
  /p/projetos/monan_das/$USER/logs/$MONAN_JEDI_TEST_ID/11_ctest_all_pbs.log \
  /p/projetos/monan_das/$USER/logs/$MONAN_JEDI_TEST_ID/11_ctest_all_pbs.out 2>/dev/null
```

Expected result when excluding the known issues:

```text
100% tests passed, 0 tests failed out of 2291
```

## Test notes

The full configured CTest suite contains:

```text
Total tests: 2294
MPI-labeled tests: 818
Non-MPI tests: 1476
```

The MPAS-JEDI subset contains:

```text
Total mpasjedi tests: 62
MPI mpasjedi tests: 61
Non-MPI mpasjedi tests: 1
```

Therefore, broad CTest selections must be run through PBS. Running MPI tests directly on the login node can fail with:

```text
No host list provided
```

## Known issues

Known issues are documented under:

```text
docs/known-issues/
```

Current known issues:

```text
JACI_LGETKF_HEIGHT_VLOC.md
JACI_IODA_BUFR_PYTHON.md
```

## Repository layout

```text
MONAN-JEDI/
├── README.md
├── docs/
│   ├── JACI_MPAS_JEDI_BUILD_STEPS.md
│   └── known-issues/
└── scripts/
    ├── 00_common.sh
    ├── 01_load_stack_env.sh
    ├── 02_prepare_jedi_bundle.sh
    ├── 03_create_mpas_only_bundle.sh
    ├── 04_configure_mpas_jedi.sh
    ├── 05_build_mpas_jedi.sh
    ├── 06_test_mpas_jedi.sh
    ├── 06_test_mpas_jedi_pbs.sh
    ├── 07_collect_logs.sh
    ├── 08_diagnose_lgetkf_height_vloc.sh
    ├── 09_clean_mpas_jedi_test_outputs.sh
    ├── 10_audit_ctest_labels.sh
    ├── 11_test_all_jedi_pbs.sh
    └── 12_diagnose_ioda_bufr_python.sh
```

## Status

Current JACI validation status:

```text
spack-stack environment: validated
MPAS-JEDI configure: passed
MPAS-JEDI build: passed
Complete CTest run: 2291/2294 passed
Known issues: 3 tests
```
