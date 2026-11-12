#!/usr/bin/env bash
# Smoke test for scripts/profile.sh — verifies dispatch without requiring
# real profilers to be installed.
set -euo pipefail

SCRIPT="$(cd "$(dirname "$0")/.." && pwd)/scripts/profile.sh"
FIXTURES="$(cd "$(dirname "$0")" && pwd)/fixtures"

pass=0
fail=0

check() {
  local name="$1" expect="$2" actual="$3"
  if [[ "$actual" == *"$expect"* ]]; then
    echo "✓ $name"
    pass=$((pass + 1))
  else
    echo "✗ $name (expected '$expect')"
    fail=$((fail + 1))
  fi
}

out=$(bash "$SCRIPT" "$FIXTURES/rust-workspace" 2>&1 || true)
check "rust dispatch" "[Rust detected]" "$out"

out=$(bash "$SCRIPT" "$FIXTURES/go-multi-module" 2>&1 || true)
check "go dispatch" "[Go detected]" "$out"

out=$(bash "$SCRIPT" "$FIXTURES/node-monorepo" 2>&1 || true)
check "node dispatch" "[Node detected]" "$out"

echo
echo "passed: $pass / $((pass + fail))"
[[ $fail -eq 0 ]]
