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
  # that crashes the wrapper, returning a non-zero exit code.
  #
  # Case 1: crash AFTER every test passed — treat as pass.
  # Case 2: crash BEFORE any test result was reported — flake, let the
  #         outer retry loop try again instead of failing the shard.
  # Case 3: crash WITH an observed FAILED result — genuine failure, propagate.
  if [[ "$rc" -ne 0 ]] && grep -q "Bad state: No element" "$capture" \
       && grep -q "PatrolLogReader.readEntries" "$capture"; then
    local has_failed_result
    has_failed_result=0
    if grep -q "test result: FAILED" "$capture"; then has_failed_result=1; fi
    if grep -q "❌ Failed: [1-9]" "$capture"; then has_failed_result=1; fi

    if [[ "$has_failed_result" -eq 0 ]]; then
      if grep -q "❌ Failed: 0" "$capture" && grep -q "✅ Successful:" "$capture"; then
        echo "::warning::Patrol CLI crashed in PatrolLogReader after success — treating as pass"
        rm -f "$capture"
        return 0
      fi
      if grep -q "test result: PASSED" "$capture"; then
        echo "::warning::Patrol CLI crashed in PatrolLogReader after success — treating as pass"
        rm -f "$capture"
        return 0
      fi
      # Crash BEFORE any test result was emitted — pure Patrol flake.
      # Return a distinct exit code so the outer retry loop retries.
      echo "::warning::Patrol CLI crashed in PatrolLogReader before any test result — treating as flake, will retry"
      rm -f "$capture"
      return 77
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
  # Normalize sentinel exit codes (77 = patrol flake, retries exhausted) to 1
  # so the shell step fails with a clean non-zero rather than a surprising code.
  if [[ "$status" -eq 77 ]]; then
    return 1
  fi
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
