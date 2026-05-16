# MONAN-JEDI

Repository for the MONAN-JEDI development workflow on INPE/JACI.

This repository is intentionally separated from `spack-stack-inpe`.

## Scope

`spack-stack-inpe` contains the site configuration and the reproducible software stack for JACI.

`MONAN-JEDI` contains the workflow used to prepare, configure, build and validate the MPAS-JEDI/JEDI bundle using that stack.

## Initial target

The first technical target is a reduced MPAS-JEDI-only build on JACI using:

```text
spack-stack release/2.1
JACI CrayPE
PrgEnv-gnu/8.6.0
gcc-native/12.3
cray-mpich/8.1.31
jedi-mpas-env/1.0.0
```

The stack must already have been created and validated by `spack-stack-inpe` before running the scripts in this repository.

## Expected stack location

By default, scripts expect:

```text
/p/projetos/monan_das/${USER}/work/${STACK_TEST_ID}/spack-stack
```

where `STACK_TEST_ID` is the identifier used when the stack was created by `spack-stack-inpe`.

Example:

```bash
export STACK_TEST_ID="spack-stack-inpe-overlay-20260515T181917Z"
```

## Workflow

```bash
export STACK_TEST_ID="spack-stack-inpe-overlay-20260515T181917Z"
export MONAN_JEDI_TEST_ID="monan-jedi-mpas-only-$(date -u +%Y%m%dT%H%M%SZ)"

bash scripts/01_load_stack_env.sh
bash scripts/02_prepare_jedi_bundle.sh
bash scripts/03_create_mpas_only_bundle.sh
bash scripts/04_configure_mpas_jedi.sh
bash scripts/05_build_mpas_jedi.sh
bash scripts/06_test_mpas_jedi.sh
bash scripts/07_collect_logs.sh
```

## Repository layout

```text
MONAN-JEDI/
├── README.md
├── docs/
│   └── JACI_MPAS_JEDI_BUILD_STEPS.md
└── scripts/
    ├── 00_common.sh
    ├── 01_load_stack_env.sh
    ├── 02_prepare_jedi_bundle.sh
    ├── 03_create_mpas_only_bundle.sh
    ├── 04_configure_mpas_jedi.sh
    ├── 05_build_mpas_jedi.sh
    ├── 06_test_mpas_jedi.sh
    └── 07_collect_logs.sh
```

## Status

Initial repository scaffold for JACI/MPAS-JEDI validation.
