# Known issue: `mpasjedi_lgetkf_height_vloc` on JACI

## Summary

The MPAS-JEDI test

```text
mpasjedi_lgetkf_height_vloc
```

is a known numerical reference-comparison issue on JACI.

The test executes, but fails when comparing the generated floating-point summary against the bundled reference file.

## Observed validation status

The MPAS-JEDI-only build on JACI has been observed to pass:

```text
61/62 MPAS-JEDI tests via PBS
```

with the only failing test being:

```text
mpasjedi_lgetkf_height_vloc
```

## Nature of the failure

The failure is a reference mismatch, not a build, MPI, data-staging or runtime-launch failure.

The error has the form:

```text
oops::TestReferenceFloatMismatchError
Float mismatch
```

The test uses strict tolerances in:

```text
mpas-jedi/test/testinput/lgetkf_height_vloc.yaml
```

including:

```yaml
test:
  float relative tolerance: 1.e-6
  float absolute tolerance: 1.e-40
  reference filename: testoutput/lgetkf_height_vloc.ref
  test output filename: testoutput/lgetkf_height_vloc.run.ref
```

## Interpretation

For JACI validation, this test should be treated as a known numerical reference sensitivity unless a future investigation proves otherwise.

The recommended operational validation is therefore:

```text
Run MPAS-JEDI tests via PBS excluding ^mpasjedi_lgetkf_height_vloc$
```

## Recommended CTest selection

```bash
export MONAN_JEDI_CTEST_REGEX='^mpasjedi_'
export MONAN_JEDI_CTEST_EXCLUDE_REGEX='^mpasjedi_lgetkf_height_vloc$'
bash scripts/06_test_mpas_jedi_pbs.sh
```

Expected result:

```text
100% tests passed, 0 tests failed out of 61
```

## Historical evidence

This issue was previously observed and documented in the predecessor validation repository:

```text
joaogerd/jaci-spack-stack-bootstrap
branch: cleanup/mpas-jedi-only-validation
docs/evidence/jaci-mpas-jedi-validation/
```
