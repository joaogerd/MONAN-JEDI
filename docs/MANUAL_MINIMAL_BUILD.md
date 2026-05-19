# Manual minimal build of MONAN-JEDI

## 1. Purpose

This document describes the minimal manual procedure to configure and build MONAN-JEDI using an existing Spack-stack environment.

This document intentionally does not use automation scripts.

The purpose is to show each command explicitly, so that every user can understand:

1. where the software stack comes from;
2. which module tree is being used;
3. which JEDI environment is loaded;
4. where the JEDI bundle source code is cloned;
5. where the reduced MPAS-JEDI-only `CMakeLists.txt` comes from;
6. where the build directory is created;
7. how `ecbuild` is called;
8. how the build is executed.

This document assumes that the Spack-stack environment has already been created and validated by `spack-stack-inpe`.

This document does not install Spack, does not concretize packages, does not install dependencies and does not generate modules.

## 2. Assumed stack

The initial MONAN-JEDI target on JACI uses:

```text
spack-stack release/2.1
JACI CrayPE
PrgEnv-gnu/8.6.0
gcc-native/12.3
cray-mpich/8.1.31
jedi-mpas-env/1.0.0
```

The example below assumes that the validated stack is located at:

```text
/p/projetos/monan_das/<user>/work/spack-stack-inpe-overlay-20260515T181917Z/spack-stack
```

Replace `<user>` with your actual JACI username.

Example:

```text
/p/projetos/monan_das/joao.gerd/work/spack-stack-inpe-overlay-20260515T181917Z/spack-stack
```

## 3. Enter the MONAN-JEDI repository

```bash
cd /p/projetos/monan_das/<user>/projects/MONAN-JEDI
```

Update the repository if needed:

```bash
git pull
```

## 4. Start from a clean module environment

This step removes modules previously loaded in the shell.

```bash
module --force purge
```

If `module --force purge` is not accepted by the local module system, use:

```bash
module purge
```

## 5. Re-add the basic JACI/Cray module trees

The MONAN-JEDI workflow expects the standard JACI/Cray module trees to be visible.

Run these commands manually:

```bash
module use /opt/cray/pe/modulefiles
module use /opt/cray/modulefiles
module use /opt/cray/pe/craype-targets/default/modulefiles
module use /p/app/modulefiles
module use /opt/cray/pals/modulefiles
```

Check the current module path:

```bash
echo $MODULEPATH
```

## 6. Enter the Spack-stack directory

```bash
cd /p/projetos/monan_das/<user>/work/spack-stack-inpe-overlay-20260515T181917Z/spack-stack
```

## 7. Load the JACI site setup from spack-stack

The JACI site setup is provided by the stack itself.

```bash
source configs/sites/tier2/jaci/setup.sh
```

This step prepares the base environment expected by the JACI Spack-stack site configuration.

## 8. Add the generated module tree from the validated stack

The MONAN-JEDI workflow expects the generated module tree from the Spack-stack environment.

```bash
module use /p/projetos/monan_das/<user>/work/spack-stack-inpe-overlay-20260515T181917Z/spack-stack/envs/jaci-mpas-jedi-gcc12-craympich/modules
```

Check that the JEDI environment module is visible:

```bash
module avail jedi-mpas-env
```

## 9. Load the JEDI MPAS environment module

Load the generated JEDI environment module:

```bash
module load cray-mpich/8.1.31/none/none/jedi-mpas-env/1.0.0
```

Check what was loaded:

```bash
module list
```

## 10. Load the Spack-stack runtime setup

The MONAN-JEDI workflow also sources the `setup.sh` file located at the root of the Spack-stack clone.

```bash
source setup.sh
```

This step makes the stack runtime environment available to the shell.

## 11. Check compilers and basic tools

Check the Cray compiler wrappers:

```bash
which cc
which CC
which ftn
```

Check the build tools:

```bash
which ecbuild
which cmake
which make
which ctest
which python
```

Check Python:

```bash
python --version
```

Check basic Python packages expected by the current workflow:

```bash
python -c "import mpi4py; print('mpi4py ok')"
python -c "import netCDF4; print('netCDF4 ok')"
```

## 12. Create a work directory for this manual build

This directory is where the JEDI bundle source and build tree will be placed.

```bash
mkdir -p /p/projetos/monan_das/<user>/work/manual-monan-jedi-mpas-only
```

Enter the work directory:

```bash
cd /p/projetos/monan_das/<user>/work/manual-monan-jedi-mpas-only
```

## 13. Clone the JEDI bundle

```bash
git clone https://github.com/JCSDA/jedi-bundle.git jedi-bundle
```

Enter the source tree:

```bash
cd /p/projetos/monan_das/<user>/work/manual-monan-jedi-mpas-only/jedi-bundle
```

Checkout the target branch:

```bash
git fetch --all --tags --prune
git checkout develop
```

Initialize submodules:

```bash
git submodule sync --recursive
git submodule update --init --recursive --checkout
```

Check the source state:

```bash
git status --short
git submodule status --recursive
```

## 14. Replace the JEDI bundle CMakeLists.txt with the MONAN-JEDI reduced template

The current MONAN-JEDI workflow uses a reduced MPAS-JEDI-only bundle.

The adjusted CMake file is versioned in this repository at:

```text
MONAN-JEDI/templates/CMakeLists.monan-jedi-mpas-only.txt
```

Before replacing the upstream file, save a copy:

```bash
cp CMakeLists.txt CMakeLists.txt.original
```

Copy the MONAN-JEDI reduced template manually:

```bash
cp /p/projetos/monan_das/<user>/projects/MONAN-JEDI/templates/CMakeLists.monan-jedi-mpas-only.txt CMakeLists.txt
```

Check what changed:

```bash
git diff -- CMakeLists.txt
```

The reduced template includes the following projects:

```text
gsw
oops
vader
saber
crtm
ioda-data
ioda
ufo-data
ufo
mpas
mpas-jedi-data
mpas-jedi
```

`BUILD_GSIBEC` is disabled by default in this reduced template.

## 15. Create the build directory

```bash
mkdir -p /p/projetos/monan_das/<user>/work/manual-monan-jedi-mpas-only/build-jedi-bundle-mpas-only
```

Enter the build directory:

```bash
cd /p/projetos/monan_das/<user>/work/manual-monan-jedi-mpas-only/build-jedi-bundle-mpas-only
```

## 16. Create a CMake initial cache for Python

The current MONAN-JEDI configure step forces CMake to use the Python provided by the loaded stack environment.

First, identify Python:

```bash
which python
python --version
```

Discover the Python prefix:

```bash
python - <<'PY'
import sys
print(sys.prefix)
PY
```

Discover the Python include path:

```bash
python - <<'PY'
import sysconfig
print(sysconfig.get_path('include') or '')
PY
```

Create the initial cache file manually:

```bash
vi monan-jedi-initial-cache.cmake
```

Add the following content, replacing `/path/to/python`, `/path/to/python/prefix` and `/path/to/python/include` with the values from your loaded stack:

```cmake
set(Python3_EXECUTABLE "/path/to/python" CACHE FILEPATH "" FORCE)
set(Python_EXECUTABLE "/path/to/python" CACHE FILEPATH "" FORCE)
set(PYTHON_EXECUTABLE "/path/to/python" CACHE FILEPATH "" FORCE)
set(Python3_ROOT_DIR "/path/to/python/prefix" CACHE PATH "" FORCE)
set(Python3_INCLUDE_DIR "/path/to/python/include" CACHE PATH "" FORCE)
set(_Python3_INCLUDE_DIR "/path/to/python/include" CACHE PATH "" FORCE)
set(Python3_FIND_STRATEGY LOCATION CACHE STRING "" FORCE)
set(Python3_FIND_REGISTRY NEVER CACHE STRING "" FORCE)
set(Python3_FIND_FRAMEWORK NEVER CACHE STRING "" FORCE)
```

## 17. Create the after-project CMake include file

The current MONAN-JEDI configure step also uses a small CMake include file after the project is initialized.

Create it manually:

```bash
vi monan-jedi-after-project.cmake
```

Add:

```cmake
if(NOT MONAN_JEDI_AFTER_PROJECT_INCLUDE_DONE)
  set(MONAN_JEDI_AFTER_PROJECT_INCLUDE_DONE TRUE CACHE INTERNAL "")
  find_package(ip CONFIG QUIET)
  if(TARGET ip::ip_d)
    message(STATUS "MONAN-JEDI after-project include: ip::ip_d is available")
  else()
    message(STATUS "MONAN-JEDI after-project include: ip::ip_d not available; continuing")
  endif()
endif()
```

## 18. Configure with ecbuild

Run `ecbuild` manually from the build directory:

```bash
ecbuild /p/projetos/monan_das/<user>/work/manual-monan-jedi-mpas-only/jedi-bundle \
  -C/p/projetos/monan_das/<user>/work/manual-monan-jedi-mpas-only/build-jedi-bundle-mpas-only/monan-jedi-initial-cache.cmake \
  -DCMAKE_PROJECT_INCLUDE=/p/projetos/monan_das/<user>/work/manual-monan-jedi-mpas-only/build-jedi-bundle-mpas-only/monan-jedi-after-project.cmake \
  -DCMAKE_C_COMPILER=$(which cc) \
  -DCMAKE_CXX_COMPILER=$(which CC) \
  -DCMAKE_Fortran_COMPILER=$(which ftn) \
  -DMPI_C_COMPILER=$(which cc) \
  -DMPI_CXX_COMPILER=$(which CC) \
  -DMPI_Fortran_COMPILER=$(which ftn) \
  -DPython3_EXECUTABLE=$(which python) \
  -DPython_EXECUTABLE=$(which python) \
  -DPYTHON_EXECUTABLE=$(which python) \
  -DBUILD_MPAS=ON \
  -DBUILD_GSIBEC=OFF
```

If configuration succeeds, the build directory should contain:

```bash
ls Makefile
ls CMakeCache.txt
```

## 19. Build

```bash
make -j 8
```

Use a smaller or larger number according to the machine policy and the resources available.

Example:

```bash
make -j 16
```

## 20. List available tests

```bash
ctest -N
```

## 21. Run only the login-node-safe test

The current MONAN-JEDI workflow avoids broad MPI tests on the login node.

Run only the coding norms test:

```bash
ctest --output-on-failure -j 1 -R '^mpasjedi_coding_norms$'
```

Do not run broad MPAS-JEDI MPI tests directly on the login node.

Tests such as `mpasjedi_geometry` may require a compute-node allocation.

## 22. Check build products

Look for generated executables:

```bash
find /p/projetos/monan_das/<user>/work/manual-monan-jedi-mpas-only/build-jedi-bundle-mpas-only -type f -executable | head
```

Check for CMake errors:

```bash
grep -i "CMake Error" /p/projetos/monan_das/<user>/work/manual-monan-jedi-mpas-only/build-jedi-bundle-mpas-only/CMakeFiles/CMakeError.log
```

Check the final build output manually.

## 23. What comes from where

### From spack-stack-inpe

The following items come from the previously generated and validated Spack-stack environment:

```text
compiler wrappers
MPI
ecbuild
cmake
python
mpi4py
netCDF4
JEDI dependency modules
jedi-mpas-env
generated module tree
```

### From MONAN-JEDI

The MONAN-JEDI repository provides this manual procedure and the reduced MPAS-JEDI-only CMake template:

```text
templates/CMakeLists.monan-jedi-mpas-only.txt
```

In this manual procedure, no MONAN-JEDI script is executed.

### From JCSDA/jedi-bundle

The source code is cloned from:

```text
https://github.com/JCSDA/jedi-bundle.git
```

The reduced MPAS-JEDI-only build is created by manually replacing the top-level `CMakeLists.txt` with the template provided by MONAN-JEDI.

### Build output

The build output is written to:

```text
/p/projetos/monan_das/<user>/work/manual-monan-jedi-mpas-only/build-jedi-bundle-mpas-only
```

## 24. Success criteria

This manual procedure is considered successful when:

1. the stack module tree is added with `module use`;
2. `jedi-mpas-env/1.0.0` is loaded;
3. `cc`, `CC` and `ftn` resolve correctly;
4. `ecbuild`, `cmake`, `make`, `ctest` and `python` are available;
5. Python can import `mpi4py`;
6. Python can import `netCDF4`;
7. `jedi-bundle` is cloned and checked out;
8. the reduced MPAS-JEDI-only `CMakeLists.txt` is copied from the MONAN-JEDI template;
9. `ecbuild` completes without fatal error;
10. `make` completes without fatal error;
11. `ctest -N` lists tests;
12. the login-node-safe CTest command completes or fails with a clearly diagnosed reason.

## 25. What this manual procedure intentionally does not do

This procedure does not:

```text
install Spack
create a Spack environment
concretize packages
install packages
generate modules
run automatic scripts
submit PBS jobs
collect logs automatically
patch files automatically
detect paths automatically
```

Those steps belong to other documents or to future automation, once the manual procedure is understood and accepted by the group.
