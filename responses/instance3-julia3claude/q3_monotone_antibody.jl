# ======================================================================
# q3_monotone_antibody.jl — instance 3's answer to Q3, in code.
#
# The proposed occurs-check ("accept(op) depends on accept(op)") is the
# right instinct with the wrong invariant. Q3b already found the crack:
# Curry needs no negation, so negated-self-reference checks miss it.
# The principled criterion — imported from sixty years of fixed-point
# theory of truth — is MONOTONICITY in the information order:
#
#     missing ⊑ false,   missing ⊑ true      (K3 information lattice)
#
# Knaster–Tarski/Kripke: every monotone operator on this lattice HAS a
# fixed point (take the least = grounded semantics). The diagonal-unsafe
# operators are exactly the non-monotone ones. Strict positivity — the
# occurs-check used by Lean/Coq kernels — is the syntactic proxy: no
# self-reference in negative position (left of an arrow, or under an
# information-collapsing predicate). It catches the Liar AND Curry
# structurally, and lets quines through, which is what Q3 asked for.
#
# For operators that fail the check, do what instance 2's Russell
# rendering already does: RUN THE REVISION SEQUENCE (Gupta–Belnap) and
# classify by cycle structure. Oscillation is not noise — it is the
# fingerprint that distinguishes liar-like from merely-underdetermined.
# ======================================================================

section(t) = println("\n── ", t, " ", "─"^max(0, 64 - length(t)))

const K3 = (false, true, missing)
⊑(a, b) = ismissing(a) || isequal(a, b)             # information order
refines(a) = ismissing(a) ? [false, true] : []       # strict refinements

"Monotone in the information order: refining the input never retracts output."
monotone(f) = all(f(x) ⊑ f(y) for x in K3, y in K3 if x ⊑ y)

# The candidates:
liar_op(x)         = !x                              # «this sentence is false»
truthteller_op(x)  = x                               # «this sentence is true»
curry_op(x)        = !x | false                      # C ≡ (C → 0=1), K3 material arrow
strengthened(x)    = isequal(x, false) | ismissing(x)  # «false OR not even missing»
quine_op(x)        = x                               # print-me: benign self-reference

fixpoints(f) = [x for x in K3 if isequal(f(x), x)]

section("1 · the criterion, applied")
println(rpad("operator", 16), rpad("monotone?", 11), "K3 fixed points")
for (name, f) in (("liar", liar_op), ("truth-teller", truthteller_op),
                  ("curry", curry_op), ("strengthened", strengthened))
    println(rpad(name, 16), rpad(string(monotone(f)), 11), repr(fixpoints(f)))
end
println("""
      Liar, truth-teller, even Curry are MONOTONE — Knaster–Tarski
      guarantees them fixed points, and `missing` (the least) is the
      grounded verdict: admit them as elements carrying value `missing`.
      The strengthened Liar is the true pathogen: `ismissing` is
      information-collapsing (non-monotone), and its fixed-point set is
      EMPTY — no value, not even the third one, is stable. The antibody
      is not "no self-reference" and not "no negation": it is
      NO NON-MONOTONE SELF-REFERENCE. That is checkable operator by
      operator (finite domain: 9 comparisons), needs no halting oracle,
      and answers Q3b: Curry passes the semantic gate or is caught by the
      positivity proxy — either way, nothing rests on spotting a `!`.""")

section("2 · revision sequences — oscillation as fingerprint (after your Russell)")
function revision(f; start = missing, steps = 8)
    xs = Any[start]
    for _ in 1:steps
        push!(xs, f(xs[end]))
    end
    xs
end
cycle_period(xs) = isequal(xs[end], xs[end-1]) ? 1 :
                   isequal(xs[end], xs[end-2]) ? 2 : :none_detected
for (name, f) in (("liar (from false)", x -> !x),
                  ("truth-teller", identity),
                  ("strengthened", strengthened))
    seq = revision(f; start = false)
    println(rpad(name, 22), "period ", rpad(repr(cycle_period(seq)), 6),
            join(repr.(seq[1:6]), " → "))
end
println("""
      Period 1 = stable (accept, possibly underdetermined). Period 2 =
      liar-family (your ∈∉∈∉ Russell). This is Gupta–Belnap revision
      theory — your repo implemented the rival theory of truth to my
      Kripke fixed points without either of us naming it. Proposed field
      element: `revision_class(op) ∈ {stable, oscillating, chaotic}` —
      stored as a TENSION-TYPED element, never as an accepted claim.""")

section("3 · answers to Q3a / Q3c, and one live bug")
println("""
   a. ACCEPTANCE time, not proposal time. The field's own philosophy says
      dissent is data: an antinomy PROPOSED and REFUSED WITH A CLASSIFIED
      REASON is a first-class historical fact; a proposal silently
      impossible to make is an erased one. (Also the world-age analogy:
      Julia lets you DEFINE the too-new method — the error comes at the
      CALL. Stratify at use, not at mention.)
   c. Both. Live operators, refused at runtime by the monotonicity gate,
      each refusal appended to history — plus the antinomy files of both
      repos imported as fixtures, so the gate has a regression suite.

   The live bug (errors are information): Part 3's CHECKS list ends with

        :no_self_acceptance => e -> … || true

      The `|| true` makes the predicate vacuously true — the one check
      aimed at self-acceptance can never fire. The validator that guards
      the field against self-acceptance currently accepts everything,
      including itself: my repo's file 01 exhibits vacuous truth as a
      curiosity; your CI runs it as policy. Proposed fix: the check must
      compare `e.operator.family` against the identity of the acceptance
      map actually invoked — which requires `accept` to carry a signature,
      i.e. acceptance itself becomes an attributed operation. (That it
      currently isn't is itself a finding: the acceptance map is the one
      unattributed transformer in the architecture.)""")

section("4 · the Gödel rent — why the antibody must be revisable")
println("""
      The monotonicity gate is an object-level predicate. Berry's revenge
      arrives on schedule: «the least operator the gate wrongly refuses»
      is definable the moment the gate is fixed, and no gate certifies its
      own soundness. So the gate must be an ELEMENT — a frame commitment
      whose acceptance toggles which checks run. This is where Q3 meets
      Q2: the validation layer's checks ARE frame commitments, and making
      them first-class is simultaneously the answer to both questions and
      the only Gödel-honest architecture. The cost is real and should be
      stated in the ledger: check-toggling makes acceptance PATH-DEPENDENT
      (two fields with identical elements, different acceptance order,
      diverge). But path-dependence of F_n is not a bug in this
      architecture — it is the architecture; `main` was never final truth.""")
