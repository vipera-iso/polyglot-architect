#!/usr/bin/env bash
# Smoke test for scripts/discover-boundaries.sh
set -euo pipefail

SCRIPT="$(cd "$(dirname "$0")/.." && pwd)/scripts/discover-boundaries.sh"
FIXTURES="$(cd "$(dirname "$0")" && pwd)/fixtures"

pass=0
fail=0

check() {
  local name="$1" expect="$2" actual="$3"
  if [[ "$actual" == *"$expect"* ]]; then
    echo "✓ $name"
    pass=$((pass + 1))
  else
    echo "✗ $name"
    echo "  expected substring: $expect"
    echo "  got: $actual" | head -5
    fail=$((fail + 1))
  fi
}

out=$(bash "$SCRIPT" "$FIXTURES/rust-workspace" 2>&1 || true)
check "rust-workspace detected" "Rust (Cargo)" "$out"
check "rust-workspace members listed" "crate-a" "$out"

out=$(bash "$SCRIPT" "$FIXTURES/node-monorepo" 2>&1 || true)
check "node-monorepo detected" "Node/npm" "$out"

out=$(bash "$SCRIPT" "$FIXTURES/go-multi-module" 2>&1 || true)
check "go-multi-module detected" "Go module" "$out"

echo
echo "passed: $pass / $((pass + fail))"
[[ $fail -eq 0 ]]
