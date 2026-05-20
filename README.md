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

The stack must already have been created and validated by `spack-stack-inpe` before running the workflow in this repository.

## Configuration

Runtime settings are centralized in YAML files under `config/`.

For JACI, the default configuration is:

```text
config/jaci.yaml
```

This file defines the stack instance, stack module, workflow run identifier, compiler wrappers, MPI wrappers, JEDI bundle reference, build options, CTest options and PBS options.

A generic template for new sites is available at:

```text
config/template.yaml
```

## Workflow

The main entry point is the orchestrator:

```bash
bash scripts/monan-jedi.sh <command> --config config/jaci.yaml
```

Available commands:

```text
load        Load and validate the spack-stack environment
prepare     Clone/update jedi-bundle
reduce      Generate the reduced MPAS-JEDI-only bundle logic
configure   Configure the bundle with ecbuild
build       Build the configured bundle
test        Run the login-node-safe CTest subset
test-pbs    Submit CTest to PBS
logs        Collect logs
all         Run the main workflow sequence
```

Example:

```bash
bash scripts/monan-jedi.sh load --config config/jaci.yaml
bash scripts/monan-jedi.sh prepare --config config/jaci.yaml
bash scripts/monan-jedi.sh configure --config config/jaci.yaml
bash scripts/monan-jedi.sh build --config config/jaci.yaml
bash scripts/monan-jedi.sh test --config config/jaci.yaml
bash scripts/monan-jedi.sh logs --config config/jaci.yaml
```

Or, for the full sequence:

```bash
bash scripts/monan-jedi.sh all --config config/jaci.yaml
```

## Repository layout

```text
MONAN-JEDI/
├── README.md
├── config/
│   ├── jaci.yaml
│   └── template.yaml
├── docs/
│   └── JACI_MPAS_JEDI_BUILD_STEPS.md
└── scripts/
    ├── monan-jedi.sh
    └── lib/
        ├── build.sh
        ├── bundle.sh
        ├── common.sh
        ├── config.sh
        ├── configure.sh
        ├── logs.sh
        ├── pbs.sh
        ├── read_config.py
        ├── stack.sh
        └── test.sh
```

## Design principle

User-editable settings should live in YAML configuration files, not inside shell scripts.

The shell scripts provide workflow logic. The YAML files describe the site-specific environment.

This keeps the MONAN-JEDI workflow reproducible, easier to review and easier to adapt to additional INPE systems in the future.
