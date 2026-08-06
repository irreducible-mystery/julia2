#!/usr/bin/env python3
"""Check a downloaded PAL2v/Eτ implementation against the definitions of Eτ.

Exit 0 iff the implementation agrees with

    G_c (μ,λ) = μ − λ        degree of certainty
    G_ct(μ,λ) = μ + λ − 1    degree of contradiction

and places the four corners of the unit square on the four extreme logical
states (t, F, ⊤, ⊥).  This is the whole point of the check: prose about a
downloaded library proves nothing, a passing exit code proves something.

Usage:
    python3 verify_etau.py                 # uses an installed `paraconsistent`
    python3 verify_etau.py path/to/src     # or a source tree extracted from the sdist
"""
from __future__ import annotations

import sys
import pathlib

TOL = 1e-12

# (mu, lam, expected extreme state or None, human label)
CASES = [
    (1.0, 0.0, "t", "true"),
    (0.0, 1.0, "f", "false"),
    (1.0, 1.0, "┬", "inconsistent"),
    (0.0, 0.0, "┴", "paracomplete"),
    (0.5, 0.5, None, "centre"),
    (0.8, 0.3, None, "mixed"),
]


def load_block():
    """Import ParaconsistentBlock, optionally from a path given on the command line."""
    if len(sys.argv) > 1:
        root = pathlib.Path(sys.argv[1]).resolve()
        # accept either .../src or a directory containing src/
        candidate = root / "src" if (root / "src").is_dir() else root
        sys.path.insert(0, str(candidate))
    try:
        from paraconsistent.blocks import ParaconsistentBlock
    except ImportError as exc:
        print("cannot import `paraconsistent`:", exc)
        print()
        print("Fetch it first:   ./fetch_sources.sh")
        print("then either      pip install downloads/implementation/*.whl")
        print("or               python3 verify_etau.py <extracted-sdist-dir>")
        raise SystemExit(2)
    return ParaconsistentBlock


def main() -> int:
    Block = load_block()

    print(f"{'mu':>4} {'lam':>4} {'dc':>8} {'dct':>8} {'D':>8}  {'state':<6} {'':<8} case")
    print("─" * 66)

    failures = []
    for mu, lam, expect_state, label in CASES:
        c = Block(mu=mu, lam=lam).complete

        want_dc = mu - lam
        want_dct = mu + lam - 1.0

        problems = []
        if abs(c.dc - want_dc) > TOL:
            problems.append(f"dc={c.dc!r} expected {want_dc!r}")
        if abs(c.dct - want_dct) > TOL:
            problems.append(f"dct={c.dct!r} expected {want_dct!r}")
        if expect_state is not None and c.label != expect_state:
            problems.append(f"state={c.label!r} expected {expect_state!r}")

        verdict = "OK" if not problems else "FAIL"
        if problems:
            failures.append((label, problems))

        print(
            f"{mu:4.1f} {lam:4.1f} {c.dc:8.3f} {c.dct:8.3f} {c.D:8.3f}  "
            f"{c.label:<6} {verdict:<8} {label}"
        )

    print("─" * 66)

    # Negation in Eτ swaps the annotation: ¬p(μ,λ) = p(λ,μ).
    # Consequence: certainty flips sign, contradiction is invariant.
    neg_problems = []
    for mu, lam in [(0.9, 0.2), (0.3, 0.7), (0.6, 0.6), (0.1, 0.1)]:
        p = Block(mu=mu, lam=lam).complete
        n = Block(mu=lam, lam=mu).complete
        if abs(n.dc + p.dc) > TOL:
            neg_problems.append(f"({mu},{lam}): G_c not antisymmetric under negation")
        if abs(n.dct - p.dct) > TOL:
            neg_problems.append(f"({mu},{lam}): G_ct not invariant under negation")

    if neg_problems:
        failures.append(("negation ¬p(μ,λ) = p(λ,μ)", neg_problems))
        print("negation law:  FAIL")
    else:
        print("negation law:  OK   (G_c flips sign, G_ct invariant under ¬p(μ,λ)=p(λ,μ))")

    print()
    if failures:
        print("FAILED — the implementation does not match Eτ:")
        for name, problems in failures:
            for p in problems:
                print(f"  · {name}: {p}")
        return 1

    print("PASS — dc = μ − λ, dct = μ + λ − 1, four corners correct, negation law holds.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
