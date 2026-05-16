#!/usr/bin/env bash
# =============================================================================
# 10_audit_ctest_labels.sh
# =============================================================================
# Count CTest tests by label, especially MPI-dependent versus non-MPI tests.
#
# This script reads the actual CTest metadata from the configured build tree.
# It does not run tests.
#
# Usage
# -----
#   export STACK_TEST_ID=spack-stack-inpe-overlay-20260515T181917Z
#   export MONAN_JEDI_TEST_ID=monan-jedi-mpas-only-20260516T170436Z
#   bash scripts/10_audit_ctest_labels.sh
# =============================================================================

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=00_common.sh
source "${script_dir}/00_common.sh"

load_monan_jedi_stack
require_cmd ctest
require_cmd python

if [[ ! -f "${JEDI_BUNDLE_BUILD_DIR}/CTestTestfile.cmake" ]]; then
  log_error "Build tree does not contain CTestTestfile.cmake: ${JEDI_BUNDLE_BUILD_DIR}"
  log_error "Run configure first."
  exit 1
fi

cd "${JEDI_BUNDLE_BUILD_DIR}"

json_file="${MONAN_JEDI_LOG_ROOT}/10_ctest_show_only.json"
summary_file="${MONAN_JEDI_LOG_ROOT}/10_ctest_label_summary.txt"

ctest --show-only=json-v1 > "${json_file}"

python - "${json_file}" "${summary_file}" <<'PY'
import json
import sys
from collections import Counter, defaultdict
from pathlib import Path

json_file = Path(sys.argv[1])
summary_file = Path(sys.argv[2])

data = json.loads(json_file.read_text())
tests = data.get("tests", [])

def labels_of(test):
    labels = []
    for prop in test.get("properties", []):
        if prop.get("name") == "LABELS":
            value = prop.get("value", [])
            if isinstance(value, str):
                labels.extend([x for x in value.split(";") if x])
            elif isinstance(value, list):
                labels.extend(value)
    return sorted(set(labels))

label_counter = Counter()
project_counter = Counter()
mpi_tests = []
non_mpi_tests = []
by_prefix = defaultdict(lambda: Counter(total=0, mpi=0, non_mpi=0))

for test in tests:
    name = test.get("name", "")
    labels = labels_of(test)
    has_mpi = "mpi" in labels

    for label in labels:
        label_counter[label] += 1

    if has_mpi:
        mpi_tests.append(name)
    else:
        non_mpi_tests.append(name)

    prefix = name.split("_", 1)[0] if "_" in name else name
    by_prefix[prefix]["total"] += 1
    if has_mpi:
        by_prefix[prefix]["mpi"] += 1
    else:
        by_prefix[prefix]["non_mpi"] += 1

lines = []
lines.append("# CTest label audit")
lines.append("")
lines.append(f"Total tests: {len(tests)}")
lines.append(f"MPI-labeled tests: {len(mpi_tests)}")
lines.append(f"Non-MPI tests: {len(non_mpi_tests)}")
lines.append("")
lines.append("## Label counts")
for label, count in sorted(label_counter.items(), key=lambda x: (-x[1], x[0])):
    lines.append(f"{label}: {count}")
lines.append("")
lines.append("## Counts by test-name prefix")
lines.append("prefix total mpi non_mpi")
for prefix, counts in sorted(by_prefix.items(), key=lambda x: (-x[1]["total"], x[0])):
    lines.append(f"{prefix} {counts['total']} {counts['mpi']} {counts['non_mpi']}")
lines.append("")
lines.append("## MPI tests")
lines.extend(mpi_tests)
lines.append("")
lines.append("## Non-MPI tests")
lines.extend(non_mpi_tests)

summary_file.write_text("\n".join(lines) + "\n")
print("\n".join(lines[:80]))
print(f"\n[INFO] Full summary written to: {summary_file}")
PY

log_info "CTest label audit written to: ${summary_file}"
