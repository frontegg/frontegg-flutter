#!/usr/bin/env bash
set -euo pipefail

METHODS="${E2E_METHODS:-}"

cd embedded
TEST_FILE="integration_test/e2e/embedded_e2e_test.dart"

flutter pub get

if [[ -n "$METHODS" ]]; then
  _old_ifs=$IFS
  IFS=,
  for m in $METHODS; do
    IFS=$_old_ifs
    [[ -z "$m" ]] && continue
    echo "::notice::Running E2E test: $m"
    patrol test -t "$TEST_FILE" --dart-define="E2E_TEST_FILTER=$m" --uninstall || true
  done
  IFS=$_old_ifs
else
  echo "::notice::Running full E2E suite"
  patrol test -t "$TEST_FILE" --uninstall
fi
