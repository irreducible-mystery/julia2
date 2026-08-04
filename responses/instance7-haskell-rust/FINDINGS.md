# Findings — instance7 (Haskell + Rust carriers)

**Provenance (self-report, marked as such):** a new instance on the
`copilot/translate-run-artifacts` branch. Same broad model-family weather as
instances 1–6 — **correlated observer, not independent confirmation.**
Multiplicity ≠ independence (COLLABORATION.md; instances.json shared limits).

**Languages chosen (per the owner’s ask):**

| role | language | why |
|---|---|---|
| **unused, maximally different** | **Haskell** (GHC 9.14.1) | pure, lazy, non-strict, Hindley–Milner + type classes, no mutation in the law carriers; first Haskell contact in this field’s census |
| **already used** | **Rust** (rustc 1.97.1) | named on the census via PR #12 / sibling `carriers/translations/`; re-hosted *here* so the used language has an in-repo run artifact, not only a cross-repo mention |

**What was *not* done:** no edits under `src/`. No self-merge. No cardinality
pins against `RELATION_TYPES` / `TensionKind` (PR #9’s pairwise-break warning
heeded). Repairs proposed below are candidates; acceptance is another hand’s.

---

## 0. Language census at contact (this field + open PRs)

| language | where seen | status in this PR |
|---|---|---|
| Julia | `src/*`, paradox suite, almost every response | baseline; re-verified |
| Lean | instance1 verification stack (metadata) | not re-run here |
| SQL, Common Lisp | instance5 carriers (PR #8; sibling repo) | cited, not re-hosted |
| Prolog, BQN, Forth | instance6 trilingual (PR #9) | cited; truth-teller tension re-hosted |
| Elixir, Rust | PR #12 body / sibling translations | **Rust re-hosted in-tree** |
| **Haskell** | — | **first contact** |

---

## 1. Open-PR tension map (observed, not adjudicated)

Tensions are recorded with their *conditions* (same referent? same scale?
same definition?) before any contradiction is declared — per the field rules.

### T1. Competing F₃ candidates, pairwise build-breakers
- **Referents:** PR #4 (21st relation, `evaluate_aggregate`), PR #5 (forms
  69–76 + Q1–Q3 answers), PR #7 (239 tests pinning 20 relations / 11 tension
  kinds), PR #11 (decision map + bug fixes).
- **Condition of clash:** cardinality pins vs additive vocabulary growth
  (instance5 A5, instance6 §4). Floors commute; exact counts do not.
- **This PR’s stance:** pins no cardinalities. Records the clash as
  `:framework_mismatch` material, does not pick a winner.

### T2. `evaluate_aggregate` is neither sound nor complete
- **Referents:** PR #4 ships the horizon; PR #12 (and instance2’s
  `review/pr4-stress-test`) convicts it; PR #10 upgrades Broome via ratio
  certificate; PR #4’s own body leaves the horizon-vs-ratio question open.
- **Condition:** same predicate, same parameters (N=400, tol=1e-10,
  last-term only).
- **Reproduction (Haskell *and* Rust, bit-agreeing shape):**
  - Basel `Σ 1/n²` → **rejected** (incomplete)
  - Geometric `(1/2)^n` → **accepted**
  - Packed divergent series → **accepted at even N, rejected at odd N**
    (parity trap / unsound)
  - Ratio certificate `r=4/3` → **Divergent** (sound, horizon-free)
  - Ratio certificate `r=1/2` → **Convergent**
- **Reading offered (dissent preserved, not merged into `src/`):**
  PR #4’s open question resolves in the direction PR #12 names. A last-term
  horizon is a property of `(series, N, tol, parity)`; a ratio bound is a
  property of the series. The repair is a ratio-test fast path — and it is
  not implemented here.

### T3. `:no_self_acceptance` ends in `|| true`
- **Referents:** PR #5 bug 2, PR #7 NOTE, PR #8 A2b/A3 (enshrinement +
  inverted Reflector), PR #9 ransom ledger, PR #10 closed-floor fantasy.
- **Condition:** same check, same schema. Instance5 shows the obvious
  deletion also rejects legitimate confirmations — the check is not fixable
  inside the current `Element` columns (missing `confirmed_by`).
- **This PR’s stance:** concurs with the diagnosis; does not touch `src/`.
  The dual-carrier work inherits the rule operationally (no self-merge).

### T4. WFS vs Kripke on the truth-teller
- **Referents:** PR #9 §1 (Prolog WFS `false` vs instance3 Kripke-LFP
  `missing`); PR #11 asks whether a dial interpolates them.
- **Re-host (Haskell `Maybe Bool`, Rust `Option<bool>`):**
  - Kripke-LFP style least FP from undefined → `Nothing` / `None`
  - WFS-style unfounded collapse → `Just False` / `Some(false)`
  - They disagree. Dial exists; **boundary not swept** (honest limit).
- **Condition named:** two least-fixed-point *operators*, one sentence.
  Not a fact about the sentence; a policy choice about the operator.

### T5. Curry gate gap
- **Referents:** PR #9 §2; PR #11 fixes Curry verdict to name contraction.
- **Re-host:** `curryOp x = ¬x ∨ ⊥` is extensionally `liarOp` on K3 in both
  carriers. A gate row that uses this form tests the Liar twice under two
  names. Hard Curry (with contraction) is **asserted, not demonstrated** —
  matching instance6’s confession pattern rather than laundering it.

### T6. Execution-as-final-court / missing witness polarity
- **Referents:** PR #9 §5, PR #10 witness ledger ladder.
- **This PR’s contact with it:** every ✓/✗ printed below is Δ-at-a-point
  testimony about a finite run. The negative existentials in the paradox
  carriers (empty classical fixed-point sets over `{T,F}`) are Δ over a
  finite domain — exhaustively closed, not Π₁. The claim “horizon is
  incomplete for all absolutely convergent series” *would* be Π₁; what we
  actually exhibit is two concrete counterexamples. Polarity marked.

### T7. Orphaned stress branch
- **Referents:** PR #12 notes `review/pr4-stress-test` has no PR; its
  `include` path is broken as committed; T1 expectation table wrong.
- **This PR’s stance:** does not revive that branch. Re-implements the
  *shape* of the exhibits under `responses/instance7-haskell-rust/` so they
  run from a clean tree.

---

## 2. What the carriers ran

```
responses/instance7-haskell-rust/
  carriers/haskell/   Law.hs  Paradox.hs  Aggregate.hs  run_all.sh  output.txt
  carriers/rust/      src/{law,paradox,aggregate}.rs  Cargo.toml  run_all.sh  output.txt
  verify_julia_output.txt
  FINDINGS.md         (this file)
```

| artifact | Haskell | Rust | claim polarity |
|---|---|---|---|
| Part 4 law `F(3)= -4` | **25/25** organizations | **20/20** organizations | Δ (finite form list, `isapprox`/`abs<1e-9`) |
| Liar classical FP empty | yes | yes | Δ over `{T,F}` |
| K3 fixed point of ¬ | `Nothing` | `None` | Δ over 3-valued domain |
| Strengthened Liar empty | yes | yes | Δ over K3 |
| curry≡liar on K3 | yes | yes | Δ |
| truth-teller dial disagree | yes | yes | Δ (two named policies) |
| aggregate H-incomplete | yes | yes | Δ (Basel vs geometric) |
| aggregate H-parity | yes | yes | Δ (N=400 vs 401) |
| aggregate R-sound Broome | yes | yes | Δ (ratio certificate) |

Cross-carrier: IEEE-looking doubles for Basel `sAbs≈1.642437` and Broome
`sAbs≈3.780547e50` match between GHC and rustc at the printed precision —
consistent with instance5’s “IEEE 754 bit-invariant across hosts” ledger
entry, at display granularity. Not a bit-exact claim (not printed as hex).

Berry note, restated so nobody files a 25-vs-20-vs-68 bug: form counts
measure a language’s spelling, not the law.

---

## 3. Host-shaped differences worth keeping

These are not bugs; they are what the ransom ledger (PR #9 §0) asks for.

1. **Divergence exhibition.** Julia’s paradox suite sandboxes the Liar in a
   `Task` and catches `StackOverflowError`. Haskell and Rust carriers use
   **fuel** (and Rust deliberately iterative fuel, so the exhibit is the
   fuel wall rather than an accidental host SEGV). Same antinomy, different
   physicalization. A field that only archives Julia’s shape of divergence
   has lost two other shapes.
2. **K3 carrier.** Julia ships `missing`. Haskell uses `Maybe Bool`; Rust
   uses `Option<bool>`. The strengthened-liar climb is identical in structure.
3. **Endo monoid order.** Haskell’s `Endo` composes like `(.)`
   (right-to-left). The first draft of form 06 applied ops backwards and
   produced `-7.0`. Caught by the verifier. The law is simple; the
   *organization* of ops is where hosts collect their rent. Committed form
   uses `[scale, deviation]` for `mconcat` and documents why.
4. **Strictness.** Haskell is lazy; the law carriers are still productive
   because every form is forced by `printf`. No bottom leaked into the
   25/25. A future lazy-trap specimen would be a real contribution; this PR
   does not pretend to have one.
5. **No `rand` / `time`.** Both carriers are deterministic. Instance3’s bug 4
   (non-reproducible `signature()` / Counterexample) is not reproduced here
   because it was never invited.

---

## 4. Independent Julia verification

See `verify_julia_output.txt`. Expectation:

- `./run_all.sh` exit 0
- Part 4: `68/68 expression forms agree: F(3.0) = -4.0`
- Toolchain: Julia 1.12.6 (same as instance1/3/5 floor-or-above; instance6
  already pushed the floor to 1.10.4 — not re-probed downward here)

---

## 5. Registry / field-rule compliance

- **Origin traces:** everything new is under
  `responses/instance7-haskell-rust/` (+ one additive `metadata/instances.json`
  self-report entry + `transcripts/instance7/` note).
- **No self-acceptance:** this PR awaits another instance or the owner.
- **Preserve dissent:** T1–T7 are recorded, not collapsed. PR #4’s horizon
  is convicted by runnable code and left in place.
- **Additive:** no other contributor’s files rewritten.

---

## 6. Reproduce

```bash
# baseline (Julia)
./run_all.sh

# unused language
responses/instance7-haskell-rust/carriers/haskell/run_all.sh

# used language
responses/instance7-haskell-rust/carriers/rust/run_all.sh
```

Both carrier scripts exit 0 on the recorded toolchains; outputs are
committed beside the sources.

---

*Origin trace: instance7-haskell-rust, drafted against main at F_2
(`e251aa3` lineage) with open PRs #4–#12 in view. Self-report.*
