# ============================================================
# INTUITIONISTIC NEGATION, RUN — ¬G means "G implies absurdity"
# Truth = provability-at-a-stage-of-knowledge. Kripke semantics:
# worlds ordered by information growth; a formula holds at w iff
# it holds in every future of w it needs to. Negation:
#     w ⊩ ¬G   iff   NO future world w' ≥ w has w' ⊩ G
# i.e. "G is not merely unproven — G is FOREVER unprovable."
# Compare Prolog's \+: "G is unproven RIGHT NOW." Intuitionistic ¬
# is \+ quantified over all possible futures of inquiry.
# ============================================================

# --- a tiny Kripke frame: w0 (now) ≤ w1 (after more inquiry) ---
# proposition p: UNKNOWN at w0, PROVEN at w1  (e.g. an open conjecture
# that will in fact be settled positively)
worlds   = [:w0, :w1]
leq      = Dict(:w0 => [:w0, :w1], :w1 => [:w1])   # future cones
val      = Dict(:p => [:w1])                        # where p is proven

abstract type Fm end
struct Atom  <: Fm; name::Symbol end
struct And   <: Fm; a::Fm; b::Fm end
struct Or    <: Fm; a::Fm; b::Fm end
struct Imp   <: Fm; a::Fm; b::Fm end
struct Bot   <: Fm end
Neg(a::Fm) = Imp(a, Bot())                          # ¬G ≡ G → ⊥  (definition!)

holds(w, f::Atom) = w in get(val, f.name, Symbol[])
holds(w, ::Bot)   = false
holds(w, f::And)  = holds(w, f.a) && holds(w, f.b)
holds(w, f::Or)   = holds(w, f.a) || holds(w, f.b)
holds(w, f::Imp)  = all(!holds(v, f.a) || holds(v, f.b) for v in leq[w])

valid(f) = all(holds(w, f) for w in worlds)

p = Atom(:p)
sec(t) = println("\n== ", t, " ", "="^max(0, 58-length(t)))

sec("1 · negation is a PROMISE about all futures")
println("  w0 ⊩ p        : ", holds(:w0, p), "   (not yet proven)")
println("  w0 ⊩ ¬p       : ", holds(:w0, Neg(p)),
        "   (¬p FAILS too: p becomes provable at w1)")
println("  → at w0, NEITHER p nor ¬p holds. Not a third value — a")
println("    genuine gap: assertion requires construction, and neither")
println("    'p' nor 'p leads to absurdity' has one yet.")

sec("2 · excluded middle dies, constructively")
println("  w0 ⊩ p ∨ ¬p   : ", holds(:w0, Or(p, Neg(p))))
println("  valid(p ∨ ¬p) : ", valid(Or(p, Neg(p))))
println("  → 'true or false' is not a law — it is a CLAIM OF OMNISCIENCE:")
println("    asserting p∨¬p means 'I can already tell you which.' At w0")
println("    you cannot. (Bivalence was Prolog's CWA in philosopher's dress.)")

sec("3 · the double-negation gap, exactly located")
println("  w0 ⊩ ¬¬p      : ", holds(:w0, Neg(Neg(p))),
        "   ('p will never be refuted' — TRUE: p gets proven at w1)")
println("  w0 ⊩ p        : ", holds(:w0, p), "    (but p itself has no proof YET)")
println("  → ¬¬p HOLDS where p does NOT. The double-negation gap is the")
println("    distance between 'irrefutable' and 'proven' — between the")
println("    future and the present of inquiry. Prolog's \\+ \\+ G ≠ G was")
println("    this gap's operational shadow (proof-test vs proof); BQN's")
println("    float ¬¬x ≠ x was its carrier shadow. One gap, three costumes.")

sec("4 · what intuitionism KEEPS: the safe direction + triple-¬")
println("  valid(p → ¬¬p)      : ", valid(Imp(p, Neg(Neg(p)))), "   (proven ⟹ irrefutable: always)")
println("  valid(¬¬¬p → ¬p)    : ", valid(Imp(Neg(Neg(Neg(p))), Neg(p))), "   (triple collapses to single)")
println("  → ¬¬¬p = ¬p but ¬¬p ≠ p: negation stabilizes after ONE round trip.")
println("    The gap exists only at the first double-negation — landing in")
println("    ¬-land is a one-way door (Glivenko's shadow).")

sec("5 · the Liar under constructive negation")
println("  liar ≡ L ↔ ¬L. Seek a fixed point among stage-truths:")
for name in ["'never provable' (∅)", "'provable at w1' ({w1})", "'provable now' ({w0,w1})"]
    println("    candidate L = ", name)
end
# check each monotone truth-set for L = ¬L (as sets of worlds):
cands = [Symbol[], [:w1], [:w0, :w1]]
for c in cands
    empty!(get!(val, :L, Symbol[])); append!(val[:L], c)
    L = Atom(:L)
    lhs = [w for w in worlds if holds(w, L)]
    rhs = [w for w in worlds if holds(w, Neg(L))]
    println("    L=", rpad(string(c),12), " ⟦L⟧=", rpad(string(lhs),12),
            " ⟦¬L⟧=", rpad(string(rhs),12), lhs == rhs ? "  ← FIXED POINT?!" : "  no")
end
println("  → no candidate matches: the Liar has no stage-truth solution")
println("    here either — but the DIAGNOSIS changes: not 'contradiction'")
println("    (classical), not 'undefined' (WFS), not '½' (BQN): the Liar")
println("    demands a construction that consumes itself — a proof that is")
println("    its own refutation — and constructively such an object simply")
println("    never gets built. The paradox becomes a FAILED CONSTRUCTION.")
