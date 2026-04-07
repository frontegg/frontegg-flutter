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
  local capture
  capture="$(mktemp)"
  set +e
  if [[ -n "${PATROL_LOG_FILE:-}" ]]; then
    "${cmd[@]}" 2>&1 | tee -a "$PATROL_LOG_FILE" | tee "$capture"
    local rc="${PIPESTATUS[0]}"
  else
    "${cmd[@]}" 2>&1 | tee "$capture"
    local rc="${PIPESTATUS[0]}"
  fi
  set -e
  # Patrol CLI 3.6.0 has a known bug in PatrolLogReader (`Bad state: No element`)
  # that crashes the wrapper AFTER tests finish, returning a non-zero exit code
  # even when every test passed.  Recover by trusting the xcodebuild test summary
  # captured in the same output.
  if [[ "$rc" -ne 0 ]] && grep -q "Bad state: No element" "$capture" \
       && grep -q "PatrolLogReader.readEntries" "$capture"; then
    if grep -q "❌ Failed: 0" "$capture" && grep -q "✅ Successful:" "$capture"; then
      echo "::warning::Patrol CLI crashed in PatrolLogReader after success — treating as pass"
      rm -f "$capture"
      return 0
    fi
    if grep -q "test result: PASSED" "$capture" && ! grep -q "test result: FAILED" "$capture"; then
      echo "::warning::Patrol CLI crashed in PatrolLogReader after success — treating as pass"
      rm -f "$capture"
      return 0
    fi
  fi
  rm -f "$capture"
  return "$rc"
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
