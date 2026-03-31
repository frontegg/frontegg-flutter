#!/usr/bin/env bash
set -euo pipefail

METHODS="${E2E_METHODS:-}"
MAX_RETRIES="${PATROL_MAX_RETRIES:-1}"

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

# Best-effort recovery between retries (Android emulator / adb flakes, e.g. exit 224).
recover_between_retries() {
  if command -v adb >/dev/null 2>&1; then
    adb kill-server || true
    adb start-server || true
    sleep 3
  fi
}

run_with_retries() {
  local -a patrol_args=("$@")
  local attempt=1
  local status=0
  while [[ "$attempt" -le "$MAX_RETRIES" ]]; do
    if [[ "$attempt" -gt 1 ]]; then
      echo "::warning::Patrol attempt $((attempt - 1)) failed; retrying ($attempt/$MAX_RETRIES)..."
      recover_between_retries
    fi
    set +e
    run_patrol "${patrol_args[@]}"
    status=$?
    set -e
    if [[ "$status" -eq 0 ]]; then
      return 0
    fi
    attempt=$((attempt + 1))
  done
  return "$status"
}

# One patrol invocation per shard: comma-separated E2E_TEST_FILTER matches multiple
# e2ePatrolTest entries without paying for N× iOS xcodebuild + install cycles.
if [[ -n "$METHODS" ]]; then
  echo "::notice::Running E2E shard tests: $METHODS"
  run_with_retries --dart-define="E2E_TEST_FILTER=$METHODS"
  exit $?
fi

echo "::notice::Running full E2E suite"
run_with_retries
