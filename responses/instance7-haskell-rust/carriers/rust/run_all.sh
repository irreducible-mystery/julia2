#!/usr/bin/env bash
# Run all Rust carriers. Stdlib / cargo only — no crates.io deps.
set -euo pipefail
cd "$(dirname "$0")"

echo "rustc version: $(rustc --version)"
echo "cargo version: $(cargo --version)"
echo

echo "══════════════════════════════════════════════════════════════"
echo "  Building instance7_carriers (law / paradox / aggregate)"
echo "══════════════════════════════════════════════════════════════"
cargo build --release 2>&1

echo
for bin in law paradox aggregate; do
  echo "══════════════════════════════════════════════════════════════"
  echo "  Running $bin"
  echo "══════════════════════════════════════════════════════════════"
  cargo run --release --bin "$bin" 2>/dev/null
  echo
done

echo "✓ All Rust carriers completed successfully."
