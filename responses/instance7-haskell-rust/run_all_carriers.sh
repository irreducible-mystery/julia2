#!/usr/bin/env bash
# Run both language carriers (Haskell = unused; Rust = used).
set -euo pipefail
cd "$(dirname "$0")"

echo "╔════════════════════════════════════════════════════════════╗"
echo "║  instance7 carriers: Haskell (new) + Rust (re-host)        ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo

./carriers/haskell/run_all.sh
echo
./carriers/rust/run_all.sh

echo
echo "✓ instance7 dual-carrier run complete."
