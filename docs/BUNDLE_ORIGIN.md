# MONAN-JEDI bundle origin

This document records the origin and purpose of the top-level `CMakeLists.txt` used by MONAN-JEDI.

## Current model

The MONAN-JEDI repository root is now the bundle source tree.

The file below is the project-controlled bundle definition:

```text
CMakeLists.txt
```

The workflow no longer clones `JCSDA/jedi-bundle` and no longer replaces the upstream `CMakeLists.txt` during the build.

## Original reference

The current bundle definition was derived from the previous MONAN-JEDI reduced MPAS-JEDI-only template:

```text
templates/CMakeLists.monan-jedi-mpas-only.txt
```

That template was used by the old `reduce` step to replace the top-level `CMakeLists.txt` of a local `JCSDA/jedi-bundle` checkout.

The original upstream reference still needs to be filled with the exact commit or tag that served as the base for the template:

```text
repository: https://github.com/JCSDA/jedi-bundle.git
reference:  TO_BE_FILLED
commit:     TO_BE_FILLED
```

Do not invent these values. Fill them only from the real source state log, Git history or the original local checkout used to create the template.

## Why this changed

The previous workflow had three conceptual steps:

```text
clone JCSDA/jedi-bundle
replace its CMakeLists.txt with a MONAN-JEDI MPAS-only template
configure and build that modified tree
```

That made the `jedi-bundle` checkout look like the source of truth, even though the effective build logic was already controlled by MONAN-JEDI.

The new workflow makes the ownership explicit:

```text
MONAN-JEDI provides the bundle definition
spack-stack-inpe provides the software stack
JACI provides the CrayPE execution environment
```

## Current reduced MPAS-JEDI baseline

The current `CMakeLists.txt` keeps a reduced MPAS-JEDI-oriented set of repositories and removes the FV3/FMS path from the build definition.

The current MPAS-related entries are still based on upstream MPAS-JEDI components. The future MONAN-JEDI transition should replace the MPAS model component with the MONAN model component in a controlled commit.

## Future MONAN transition

When MONAN replaces MPAS in this bundle, document at least:

```text
1. Which MPAS entries were removed or changed
2. Which MONAN repository and commit were introduced
3. Which JEDI repositories were kept unchanged
4. Which spack-stack environment was used
5. Which configure, build and CTest results validated the change
```

## Reproducibility rule

Any future change to `CMakeLists.txt` that updates repository URLs, tags or commits must include either:

```text
1. A corresponding update to this document
2. A specific validation log showing the source state and build/test result
```

This keeps the bundle definition traceable without making the build process depend on external patch steps.
