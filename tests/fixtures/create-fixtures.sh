#!/usr/bin/env bash
# Create fixture repos used by tests. Run once before running tests.

set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"

# --- Rust workspace ---
mkdir -p "$DIR/rust-workspace/crate-a/src"
cat > "$DIR/rust-workspace/Cargo.toml" <<'EOF'
[workspace]
members = ["crate-a"]
EOF
cat > "$DIR/rust-workspace/crate-a/Cargo.toml" <<'EOF'
[package]
name = "crate-a"
version = "0.1.0"
edition = "2021"
EOF
touch "$DIR/rust-workspace/crate-a/src/lib.rs"

# --- Node monorepo ---
mkdir -p "$DIR/node-monorepo/packages/pkg-a"
cat > "$DIR/node-monorepo/package.json" <<'EOF'
{"name":"fixture","workspaces":["packages/*"]}
EOF
echo '{"name":"pkg-a"}' > "$DIR/node-monorepo/packages/pkg-a/package.json"

# --- Go multi-module ---
mkdir -p "$DIR/go-multi-module/cmd/app"
cat > "$DIR/go-multi-module/go.mod" <<'EOF'
module example.com/fixture
go 1.22
EOF
touch "$DIR/go-multi-module/cmd/app/main.go"

echo "✓ fixtures created in $DIR"
