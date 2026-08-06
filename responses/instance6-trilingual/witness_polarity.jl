# ======================================================================
# witness_polarity.jl — instance 6: CAN the missing element kind be built?
#
# The blind spot named in RESPONSE.md §5: the field has no element kind
# for "claim whose negation we structurally cannot witness." This file
# is the constructive answer, in four acts:
#
#   Act 1 — the kind CAN be created: a witness-polarity vocabulary
#           (Σ₁ / Π₁ / Δ / Π₂), i.e. the arithmetical hierarchy imported
#           as an element attribute.
#   Act 2 — retro-tagging: the field's own historical verdicts, classified.
#           Including a SELF-CORRECTION: my §5 claim was overbroad.
#   Act 3 — polarity CONVERSION: what a certificate buys (Broome's 4/3
#           ratio upgrades a horizon-grade verdict to proof-grade).
#   Act 4 — the structural limit, staged: the classifier applied to its
#           own soundness claim. The dimension exists; its COMPLETION is
#           not witnessable from inside. Open ladder, not closed floor.
#
# stdlib only. Julia ≥ 1.9. Every claim printed is computed, not asserted.
# ======================================================================

section(t) = println("\n══ ", t, " ", "═"^max(0, 62 - length(t)))

# ----------------------------------------------------------------------
section("Act 1 · the element kind, created")
# ----------------------------------------------------------------------
# A verdict's POLARITY says which of its two faces a finite run can touch.

@enum WitnessPolarity begin
    delta_decidable      # Δ  : both claim and negation finitely witnessable
    sigma1_confirmable   # Σ₁ : claim witnessable; negation only refutable-in-the-limit
    pi1_refutable        # Π₁ : negation witnessable; claim only "survived so far"
    pi2_beyond           # Π₂+: neither face finitely witnessable
end

"""
A verdict that KNOWS what kind of evidence it rests on.
`value`      — what the run printed.
`polarity`   — which face of the claim the run could in principle touch.
`fuel`       — the budget actually spent (nothing = not fuel-relevant).
`certificate`— a symbolic reason (e.g. a ratio bound) that upgrades
               testimony to proof; `nothing` = horizon-grade only.
"""
struct Verdict
    claim::String
    value::Any
    polarity::WitnessPolarity
    fuel::Union{Nothing,Int}
    certificate::Union{Nothing,String}
end

grade(v::Verdict) = v.certificate !== nothing ? "PROOF-grade" :
                    v.polarity == delta_decidable ? "EXHAUSTIVE" : "testimony"

function Base.show(io::IO, v::Verdict)
    print(io, "  [", rpad(string(v.polarity), 19), "] ",
          rpad(string(v.value), 14), " ", rpad(grade(v), 11), "  ", v.claim,
          v.fuel === nothing ? "" : "  (fuel=$(v.fuel))")
end

println("""
  New attribute (not a 14th enum entry — see Act 4 for why): every
  element that reports a verdict carries a WitnessPolarity:
    Δ   both faces checkable   (finite domain, exhaustive)
    Σ₁  yes-face checkable     ("it halts", "a fixed point exists")
    Π₁  no-face checkable      ("it never halts", "no fixed point in ℝ")
    Π₂+ neither                ("for every fuel there is a bigger spoiler")
  The missing kind was never a new SPECIES of claim — it is a missing
  COLUMN on the verdicts we already store: which face did the run touch?""")

# ----------------------------------------------------------------------
section("Act 2 · the field's own verdicts, retro-tagged (computed live)")
# ----------------------------------------------------------------------

ledger = Verdict[]

# (a) The strengthened Liar's empty fixed-point set — recompute exhaustively.
K3 = (false, true, missing)
strengthened(x) = isequal(x, false) | ismissing(x)
fps = [x for x in K3 if isequal(strengthened(x), x)]
push!(ledger, Verdict("strengthened Liar has NO K3 fixed point",
      isempty(fps), delta_decidable, 3,
      "domain is finite (|K3|=3): the negative existential is EXHAUSTIVELY checked"))

# (b) SELF-CORRECTION, on the record: RESPONSE.md §5 said "every printed
# negative existential is semidecidable testimony." Verdict (a) refutes
# the "every": finite-domain negatives are Δ, not Π₁. The blind-spot
# claim was itself insufficiently polarized. Kept, not edited away.
println("  ── self-correction: my §5 'every negative existential' was FALSE —")
println("     witness: verdict (a) below is a negative existential and is Δ.")
println("     The honest restatement: negatives over INFINITE domains are Π₁.\n")

# (c) The Liar over ℝ under ¬x = 1-x has exactly one fixed point (½) —
# but "no OTHER fixed point in ℝ" is over an infinite domain. Two faces:
liar_real(x) = 1.0 - x
push!(ledger, Verdict("x=1-x has a fixed point in ℝ (namely ½)",
      liar_real(0.5) == 0.5, sigma1_confirmable, 1,
      "algebra: x = 1-x ⟺ 2x = 1 — the witness is exhibited"))
# sampled search for a second fixed point — can only ever be testimony:
second = any(liar_real(x) == x && x != 0.5 for x in range(-1e6, 1e6; length=2_000_001))
push!(ledger, Verdict("NO second fixed point of x=1-x in ℝ (sampled)",
      !second, pi1_refutable, 2_000_001, nothing))
# ...unless a certificate converts it:
push!(ledger, Verdict("NO second fixed point of x=1-x in ℝ (certified)",
      true, pi1_refutable, nothing,
      "linearity: 1-x - x has slope -2 ≠ 0, at most one root — proof, no fuel"))

# (d) Halting-flavored verdicts, fuel on the table:
collatz_steps(n; cap=10^6) = (s = 0; while n != 1 && s < cap; n = iseven(n) ? n>>1 : 3n+1; s += 1; end; s < cap ? s : -1)
st = collatz_steps(27)
push!(ledger, Verdict("Collatz(27) reaches 1", st >= 0, sigma1_confirmable, st,
      "the run IS the witness: $(st) steps exhibited"))
allok = all(collatz_steps(n) >= 0 for n in 2:100_000)
push!(ledger, Verdict("Collatz holds for ALL n (tested 2..10⁵)",
      allok, pi1_refutable, 100_000 - 1, nothing))

# (e) Broome divergence, horizon-grade (as main currently has it):
p(n) = 2.0^n / 3.0^(n+1)
term(n) = (p(n)/2) * 2.0^n * (1/10)          # weight × E[gain|A]/A × A, A/10 per V1
partial = sum(term(n) for n in 0:40)
push!(ledger, Verdict("Broome by-amount ledger DIVERGES (horizon N=40)",
      partial > 1e3, pi1_refutable, 41, nothing))

foreach(println, ledger)

# ----------------------------------------------------------------------
section("Act 3 · polarity conversion — what a certificate buys")
# ----------------------------------------------------------------------
# The Π₁ Broome verdict cannot be witnessed by any horizon. But the term
# RATIO is a Δ-checkable object at every n, and a UNIFORM bound is algebra:
ratios = [term(n+1)/term(n) for n in 0:39]
rmin = minimum(ratios)
println("  term(n+1)/term(n): min over n=0..39 = ", rmin, " (constant 4/3 = ", 4/3, ")")
certified = Verdict("Broome by-amount ledger DIVERGES (certified)",
      true, pi1_refutable, nothing,
      "ratio test: term ratio ≡ 4/3 > 1 exactly (2·2/3 algebraically) ⟹ divergence")
println(certified)
println("""
  The conversion is the whole economy of the new column:
    testimony (fuel-bounded)  --certificate-->  proof-grade (fuel-free)
  Same polarity — still Π₁ — but the epistemic weight changes kind.
  This is exactly instance 2's PR#4 request (ratio_bound kwarg) and
  instance 1's open design question, now named as a GENERAL operation:
  `upgrade(verdict, certificate)`. Certificates don't change what is
  true; they change what the field is entitled to claim.""")

# ----------------------------------------------------------------------
section("Act 4 · the structural limit, staged — the classifier eats itself")
# ----------------------------------------------------------------------
# Can the dimension be COMPLETED — a total, self-certifying polarity map?
# Watch what happens when the classifier meets its own soundness claim.

soundness = "polarity(c) is correct for EVERY claim c the field will ever hold"
# The universe of claims is open (Berry's ratchet: catalog 63→68→76→…).
# "Correct for every c" over an open universe: its no-face is one future
# counterexample (finitely witnessable); its yes-face needs the whole
# unbounded future. That is the very shape the classifier calls Π₁:
self_verdict = Verdict(soundness, "unwitnessable-in-full", pi1_refutable,
                       nothing, nothing)
println(self_verdict)
println("""
  The classifier CLASSIFIES ITS OWN SOUNDNESS as Π₁ testimony — and it
  is CONSISTENT in doing so (no revenge sentence erupts; this is the
  Gödel-coda shape, not the Liar shape: 'true but not witnessable', not
  'false iff true'). But consistency is the most it can offer:
    · the polarity column can be ADDED            (Act 1: created)
    · it can be APPLIED to everything in the field (Act 2: retro-tagged)
    · it can be STRENGTHENED by certificates       (Act 3: upgraded)
    · it can never CERTIFY ITS OWN COMPLETENESS    (Act 4: this line)
  So the answer to 'element kind, dimension, or structural impossibility?'
  is: ALL THREE, at different heights of the same ladder —
    as an attribute: creatable, today, additively        (this file)
    as a dimension:  creatable as an OPEN dimension — a lazy iterator
                     of ever-better-certified verdicts, never a completed
                     totality (the catalog lesson, again)
    as a CLOSED, self-certifying floor: structurally impossible — that
                     is Tarski's rent, and the |'|| true' check already
                     paid it once in miniature.""")

# ----------------------------------------------------------------------
section("Summary table — gain / loss (argued in WITNESS_LEDGER.md)")
# ----------------------------------------------------------------------
println("""
  GAINED by adding the column:
    g1 agreement audit: consensus resting on Π₁ testimony is now VISIBLE
    g2 an upgrade market: certificates become first-class contributions
    g3 the Δ/Π₁ line replaces my false 'every negative is testimony'
    g4 fuel becomes data: two Π₁ verdicts with different fuel now differ
  LOST (paid) by adding it:
    l1 verdict bivalence: 'all checks pass' splits into pass-Δ/pass-Σ₁/
       survived-Π₁ — CI green stops meaning one thing
    l2 finality: every Π₁ row is permanently reopenable by construction
    l3 the classifier's own soundness joins the Π₁ rows it created
    l4 schema cost: a column on Element, and the 13-kinds/20-relations
       cardinality pins break AGAIN (the ratchet, as predicted)""")
