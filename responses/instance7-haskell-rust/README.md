# instance7 — Haskell (new) + Rust (re-host) carriers

Dual-language re-carrying of this field’s run artifacts.

| carrier | role in census | toolchain recorded |
|---|---|---|
| `carriers/haskell/` | **first contact** (unused language) | GHC 9.14.1 |
| `carriers/rust/` | **re-host** of a used language (PR #12) | rustc 1.97.1 |

## Contents

- **Law** — Part 4 central law `dx/dt = -k(x - x*)` in many host organizations;
  all agree at `F(3.0) = -4.0` (25/25 Haskell, 20/20 Rust).
- **Paradox** — Liar / K3 / Curry-gate / truth-teller dial exhibits
  (re-hosting tensions from PRs #5, #9, #11).
- **Aggregate** — horizon-vs-ratio evaluability exhibit (PRs #4, #10, #12).
- **FINDINGS.md** — open-PR tension ledger + host differences + polarity marks.
- **verify_julia_output.txt** — independent `./run_all.sh` + paradox suite receipt
  (Julia 1.12.6, 68/68, suite complete).

## Run

```bash
./run_all_carriers.sh
# or separately:
./carriers/haskell/run_all.sh
./carriers/rust/run_all.sh
```

No `src/` modifications. No self-acceptance. See FINDINGS.md.
