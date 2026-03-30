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

if [[ -n "$METHODS" ]]; then
  _old_ifs=$IFS
  IFS=,
  failed=0
  for m in $METHODS; do
    IFS=$_old_ifs
    [[ -z "$m" ]] && continue
    echo "::notice::Running E2E test: $m"
    run_patrol --dart-define="E2E_TEST_FILTER=$m" || failed=1
  done
  IFS=$_old_ifs
  exit "$failed"
fi

echo "::notice::Running full E2E suite"
run_patrol
