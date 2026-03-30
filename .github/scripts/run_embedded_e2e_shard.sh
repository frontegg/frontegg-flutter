#!/usr/bin/env bash
set -euo pipefail

METHODS="${E2E_METHODS:-}"

cd embedded
TEST_FILE="integration_test/e2e/embedded_e2e_test.dart"

flutter pub get

run_patrol() {
  local -a cmd=(patrol test)
  if [[ -n "${IOS_DEVICE:-}" ]]; then
    cmd+=(-d "$IOS_DEVICE")
  fi
  cmd+=(-t "$TEST_FILE")
  cmd+=("$@")
  cmd+=(--uninstall)
  if [[ "${PATROL_VERBOSE:-}" == "1" ]]; then
    cmd+=(--verbose)
  fi
  if [[ -n "${PATROL_LOG_FILE:-}" ]]; then
    "${cmd[@]}" 2>&1 | tee -a "$PATROL_LOG_FILE"
    return "${PIPESTATUS[0]}"
  fi
  "${cmd[@]}"
}

# One patrol invocation per shard: comma-separated E2E_TEST_FILTER matches multiple
# e2ePatrolTest entries without paying for N× iOS xcodebuild + install cycles.
if [[ -n "$METHODS" ]]; then
  echo "::notice::Running E2E shard tests: $METHODS"
  run_patrol --dart-define="E2E_TEST_FILTER=$METHODS"
  exit $?
fi

echo "::notice::Running full E2E suite"
run_patrol
