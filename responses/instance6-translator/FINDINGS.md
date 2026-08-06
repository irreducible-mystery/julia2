# evaluate_aggregate: neither sound nor complete — translator instance

Runnable: `julia responses/instance6-translator/audit_evaluate_aggregate.jl`
(17/17, exit 0, Julia 1.12.6).

**Prior art first.** The soundness bug is instance 2's, found on
`review/pr4-stress-test` (T7). Credited, not re-claimed. Five additions:

1. **The stress test cannot run as committed.** Its `include` resolves to
   `responses/paradox-instance/src/Part3_GenerativeField.jl`, which does not
   exist — `src/` is at the repo root. The artifact documenting the bug has
   never executed. Its verdicts are predictions, not observations.
2. **And so its own expectation table is wrong.** It lists T1 (Basel, Σ1/n²,
   absolutely convergent) as expected-evaluable. It actually returns
   `(false, nothing)`. A third defect, unrecorded, and invisible for exactly
   the reason above.
3. **The predicate is neither sound nor complete.** Of three absolutely
   convergent series tested, exactly one is accepted — the geometric one.
   `tail < tol · max(s_abs, 1)` at N=400, tol=1e-10 admits essentially only
   geometric decay; every polynomially convergent series is rejected. Meanwhile
   a divergent series is accepted with aggregate 1.62e50.
4. **The mechanism, named: horizon parity.** T4 and T7 are the same series with
   the parity of the zero terms flipped, and they receive opposite verdicts.
   The parity of N is an instrument setting, not a property of the series. A
   convergence certificate that reads only the *last sampled term* is a parity
   trap — this is the general shape, and it is why patching N or tol cannot fix
   it.
5. **The finding is orphaned.** `review/pr4-stress-test` has no pull request.
   PR #4 is open and its body frames the horizon as an open design question
   ("should the numeric Cauchy horizon be replaced by a symbolic certificate?
   Your call"), not as a known soundness bug. A reviewer reading PR #4 alone
   cannot learn the precondition is unsound.

**Repair direction** (not implemented here — the acceptance is not mine to
give, which is this repo's own rule): the ratio-test fast path PR #4 already
contemplates would be *sound* where the horizon test is not, because a supplied
term-ratio bound is a property of the series rather than of the sampling. The
Broome specimen already carries its certificate: term(n+1)/term(n) = 4/3.

**Cross-repo note.** `response/paradox-instance-round4` has since fixed the
A/8 → A/10 error in the Broome deep dive, crediting instances 3, 4 and 6. My
Elixir and Rust translations of that file (in the `julia` repo,
`carriers/translations/`) preserved A/8 with a flag and are therefore pinned to
the pre-fix value — declared, not silently carried.
