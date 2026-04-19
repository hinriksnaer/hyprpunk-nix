#!/usr/bin/env bash
# Hawker test runner
# Discovers and runs test-*.sh files, or a single test if specified.
# Usage:
#   bash tests/run-tests.sh                      # run all
#   bash tests/run-tests.sh test-settings.sh      # run one
set -euo pipefail

TESTS_DIR="$(cd "$(dirname "$0")" && pwd)"
export REPO_DIR="${REPO_DIR:-$(cd "$TESTS_DIR/.." && pwd)}"

FILTER="${1:-}"
TOTAL_PASS=0
TOTAL_FAIL=0
FAILED_TESTS=()

echo ""
echo "=== Hawker Test Suite ==="
echo ""

for test_file in "$TESTS_DIR"/test-*.sh; do
  [[ -f "$test_file" ]] || continue
  name=$(basename "$test_file")

  # Skip if filter is set and doesn't match
  if [[ -n "$FILTER" && "$name" != "$FILTER" ]]; then
    continue
  fi

  if bash "$test_file"; then
    TOTAL_PASS=$((TOTAL_PASS + 1))
  else
    TOTAL_FAIL=$((TOTAL_FAIL + 1))
    FAILED_TESTS+=("$name")
  fi
  echo ""
done

echo "=== Suite: $TOTAL_PASS passed, $TOTAL_FAIL failed ==="

if [[ $TOTAL_FAIL -gt 0 ]]; then
  echo "Failed: ${FAILED_TESTS[*]}"
  exit 1
fi
