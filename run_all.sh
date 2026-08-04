#!/usr/bin/env bash
# Run all four parts of the Julia translation and verify they succeed.
set -e
cd "$(dirname "$0")"

echo "Julia version: $(julia --version)"
echo

for f in src/Part1_OrganizedChange.jl src/Part2_ProjectionObservation.jl src/Part3_GenerativeField.jl; do
    echo "══════════════════════════════════════════════════════════════"
    echo "  Running $f"
    echo "══════════════════════════════════════════════════════════════"
    julia "$f"
    echo
done

echo "══════════════════════════════════════════════════════════════"
echo "  Running src/Part4_ExpressionCatalog.jl (2 threads)"
echo "══════════════════════════════════════════════════════════════"
julia -t 2 src/Part4_ExpressionCatalog.jl

echo
echo "✓ All four parts completed successfully."
