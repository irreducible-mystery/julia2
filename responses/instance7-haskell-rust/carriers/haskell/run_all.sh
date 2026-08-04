#!/usr/bin/env bash
# Run all Haskell carriers. Stdlib / GHC only.
set -euo pipefail
cd "$(dirname "$0")"

echo "GHC version: $(ghc --version)"
echo

run_one () {
  local src="$1"
  local bin
  bin="$(basename "$src" .hs)"
  echo "══════════════════════════════════════════════════════════════"
  echo "  Running $src"
  echo "══════════════════════════════════════════════════════════════"
  ghc -O -o "$bin" "$src" >/dev/null
  ./"$bin"
  echo
}

run_one Law.hs
run_one Paradox.hs
run_one Aggregate.hs

echo "✓ All Haskell carriers completed successfully."
