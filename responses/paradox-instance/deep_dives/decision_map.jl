# ======================================================================
# decision_map.jl — THE DECISION-THEORETIC MAP (owner-requested).
#
# Two deliverables in one runnable file:
#
#   PART A — for each paradox that ends in «no neutral resolution», an
#            executable ransom table: every escape route, WHAT YOU KEEP,
#            WHAT YOU PAY. The map is data (a Julia structure), so the
#            field can query it, not just read it.
#
#   PART B — the owner's «hidden variables to sweep» suggestion, taken
#            literally: three of these paradoxes have a SINGLE hidden
#            dial, and the paradox is a PHASE BOUNDARY on that dial.
#            Sweeping the dial turns «paradox: yes/no» into a computed
#            phase diagram:
#              • Broome:        prior tail-ratio q  — boundary q = 1/2
#              • St.Petersburg: risk-aversion ρ     — boundary ρ = 0
#              • Bertrand:      measure exponent α  — NO boundary, a
#                               continuum (all three classic answers are
#                               points on one dial) — which is exactly
#                               why it dissolves rather than resolves.
# ======================================================================

using Printf
section(t) = println("\n", "═"^72, "\n  ", t, "\n", "═"^72)

# ----------------------------------------------------------------------
# PART A — THE RANSOM TABLES (as data, then rendered)
# ----------------------------------------------------------------------

struct Route
    name    :: String
    keep    :: String      # the intuition/principle you retain
    pay     :: String      # the ransom
    class   :: Symbol      # :orthodox | :revisionist | :heroic
end

struct ParadoxMap
    paradox :: String
    verdict :: String
    routes  :: Vector{Route}
end

const MAPS = ParadoxMap[

ParadoxMap("Broome Two-Envelopes (infinite-mean prior)",
    "argument falsidical; DECISION problem open",
    [Route("Finitism: ban infinite-mean priors",
           "expectation as the universal decision criterion",
           "expressive power — such priors are coherent & occur in physics (Cauchy dists)",
           :orthodox),
     Route("Bounded utility (Savage axioms)",
           "decision theory's axioms, conglomerability",
           "utility unboundedness — must assert money has a value ceiling a priori",
           :orthodox),
     Route("Median / quantile decision rules",
           "unbounded stakes, well-defined advice everywhere",
           "expectation itself — two positive-median gambles can't be summed sanely",
           :revisionist),
     Route("Accept non-conglomerable local advice",
           "Bayesian conditioning exactly as-is",
           "the sure-thing principle — «good in every case» no longer implies «good»",
           :heroic)]),

ParadoxMap("St. Petersburg",
    "resolves only relative to a chosen frame",
    [Route("Log/CRRA utility (Bernoulli)",
           "expected-utility maximization",
           "scale invariance — the fair price now depends on your wealth",
           :orthodox),
     Route("Finite bankroll cap",
           "linear utility, realism",
           "the mathematical problem — you answered a different (finite) question",
           :orthodox),
     Route("Median payoff (= 2)",
           "robustness to tails",
           "dominance: you'd decline games every expectation-user calls infinitely good",
           :revisionist),
     Route("Bite the bullet: pay any price",
           "expectation, pure and total",
           "bankruptcy with probability → 1 on any finite path — keep the math, lose the money",
           :heroic)]),

ParadoxMap("Sorites (vagueness)",
    "no neutral resolution — five logics, five ransoms",
    [Route("Epistemicism: sharp unknown cutoff",
           "classical logic, bivalence, truth-functionality",
           "plausibility — one grain REALLY makes the heap, we just can never know which",
           :orthodox),
     Route("Fuzzy degrees μ ∈ [0,1]",
           "gradualism (matches usage)",
           "bivalence AND the problem recurs: «exactly μ=0.5» is a new sharp line",
           :revisionist),
     Route("Supervaluation gaps",
           "classical tautologies (penumbral truths)",
           "truth-functionality — «p ∨ ¬p» true while neither disjunct is",
           :revisionist),
     Route("K3 / missing (this repo's native logic)",
           "truth-functionality, simple semantics",
           "excluded middle; and higher-order vagueness re-erupts at the gap's edge",
           :revisionist),
     Route("Nihilism: no heaps exist",
           "classical logic, tolerance principle",
           "the world — ordinary predicates denote nothing",
           :heroic)]),

ParadoxMap("Liar-family antinomies (Liar, Russell, Curry, Grelling)",
    "DO NOT RESOLVE — every route is containment, not solution",
    [Route("Tarski: stratified metalanguages",
           "classical logic everywhere within each level",
           "self-applicability — no language can state its own truth (this repo's |`|| true`| bug is this ransom being dodged and failing)",
           :orthodox),
     Route("Kripke: K3 fixed points (Julia's missing)",
           "one self-applicable language",
           "excluded middle; ghost sentences (truth-teller) settle arbitrarily; strengthened Liar re-erupts",
           :revisionist),
     Route("Paraconsistency: true contradictions",
           "naive truth AND self-reference",
           "explosion-freedom must be re-engineered; Curry still lethal unless CONTRACTION also goes",
           :heroic),
     Route("Substructural: drop contraction",
           "naive truth, negation, self-reference",
           "the most invisible rule in all of reasoning — using a premise twice",
           :heroic)]),

ParadoxMap("Bertrand's chord",
    "DISSOLVES: ill-posed — see Part B sweep (a continuum, no boundary)",
    [Route("Jaynes: maximum-ignorance invariance",
           "a unique answer (1/2) from symmetry axioms",
           "«uniform» now means «invariant», a substantive physical commitment",
           :orthodox),
     Route("Pluralism: every measure its own answer",
           "mathematical honesty",
           "the question — «THE probability» has no referent",
           :revisionist)]),
]

section("PART A — THE RANSOM MAP (queryable data + rendered tables)")
for m in MAPS
    println("\n  ▶ ", m.paradox, "   [", m.verdict, "]")
    @printf("    %-38s │ %-11s │ %s\n", "route", "class", "you keep → you pay")
    println("    ", "─"^100)
    for r in m.routes
        @printf("    %-38s │ %-11s │ KEEP: %s\n", r.name, r.class, r.keep)
        @printf("    %-38s │ %-11s │ PAY:  %s\n", "", "", r.pay)
    end
end

# The map is data — so we can compute over it:
section("PART A′ — QUERIES OVER THE MAP (the point of making it executable)")
all_routes = [(m.paradox, r) for m in MAPS for r in m.routes]
println("  Total escape routes catalogued: ", length(all_routes))
for c in (:orthodox, :revisionist, :heroic)
    n = count(pr -> pr[2].class == c, all_routes)
    println("    ", rpad(c, 12), n, "  ",
            c == :orthodox    ? "(keep the logic, ban the object)"    :
            c == :revisionist ? "(keep the object, weaken the logic)" :
                                "(keep both, pay somewhere unthinkable)")
end
pays_ex_middle = [p for (p, r) in all_routes if occursin("excluded middle", r.pay)]
println("  Routes that pay with EXCLUDED MIDDLE: ", length(pays_ex_middle),
        "  (", join(unique(pays_ex_middle), "; "), ")")
println("  ⇒ One currency dominates the ransom economy: classical bivalence.")
println("    The K3/missing route this repo already uses is the SAME coin spent")
println("    on Sorites, the Liar, and (via non-contractive →) Curry — one")
println("    frame_commitment, three paradoxes contained. Cheapest bundle on the map.")

# ----------------------------------------------------------------------
# PART B — HIDDEN-VARIABLE SWEEPS: the paradox as a phase boundary
# ----------------------------------------------------------------------

section("PART B.1 — BROOME: sweep the prior's tail ratio q   [p(n) = (1-q)qⁿ]")
# Hidden variable: q. Posterior P(small | A=2ⁿ) = q/(1+q) for n ≥ 1.
# E[gain|A] = A(3·ps − 1)/2  > 0  ⟺  ps > 1/3  ⟺  q > 1/2.
# E[amount] terms ∝ (2q)ⁿ — divergent  ⟺  q ≥ 1/2.
# SAME threshold. The «everywhere-positive gain» and the divergent mean
# are one phase, and q = 1/2 is the phase boundary.
@printf("  %6s %14s %16s %14s %s\n",
        "q", "P(small|A)", "E[gain|A]/A", "E[amount]", "phase")
for q in (0.30, 0.40, 0.49, 0.50, 0.51, 0.60, 2/3, 0.80, 0.90)
    ps    = q / (1 + q)
    gainA = (3ps - 1) / 2
    Eam   = q < 0.5 ? sum((1-q)*q^n * 3*2.0^n/2 for n in 0:2000) : Inf
    phase = q < 0.5 ? "tame: switch only for small A"      :
            q == 0.5 ? "★ CRITICAL: marginal everywhere"    :
                       "PARADOX: switch everywhere & E=∞"
    @printf("  %6.3f %14.4f %+16.4f %14s %s\n",
            q, ps, gainA, Eam == Inf ? "∞" : @sprintf("%.3f", Eam), phase)
end
println("""
  ⇒ ONE dial. Below q=1/2 conditional advice is amount-dependent and sane,
    the mean is finite, conglomerability holds — no paradox. At exactly the
    point the mean diverges, the advice becomes uniform («always switch»)
    and non-conglomerability switches on. The paradox is not a property of
    envelopes: it is the q > 1/2 PHASE of a one-parameter family.
    (Broome's famous prior is q = 2/3 — comfortably inside the phase.)""")

section("PART B.2 — ST. PETERSBURG: sweep risk-aversion ρ   [CRRA utility]")
# u(x) = x^(1-ρ)/(1-ρ)  (ρ≠1),  log at ρ=1.  Payoff 2^k w.p. 2^-(k+1), k≥0.
# E[u] = Σ 2^-(k+1) u(2^k): converges ⟺ ρ > 0. Certainty equivalent CE = u⁻¹(E[u]).
function ce(ρ; K=10_000)
    # Overflow discipline: work in exponent space. 0.5^(k+1)·(2^k)^s = 2^(k·s−(k+1));
    # the naive (2.0^k)^s overflows to Inf at k=1024 and poisons the sum — an
    # instance of the repo-wide lesson: the carrier (Float64) smuggles in its own
    # hidden variable (the overflow threshold) if you let it.
    # EVALUABILITY PRECONDITION (the PR #4 lesson, applied to ourselves):
    # the terms 2^(k(1−ρ)−(k+1)) form a geometric series with ratio 2^(−ρ);
    # it converges iff ρ > 0. Decide convergence by the RATIO, not by whether
    # a truncated sum happens to look finite — at ρ = 0 every term is exactly
    # 1/2 and a K-term truncation returns the perfectly finite lie (K+1)/2.
    ρ > 0 || return Inf
    if ρ == 1.0
        Eu = sum(exp2(-(k+1)) * (k * log(2.0)) for k in 0:K)
        return exp(Eu)
    else
        s = 1 - ρ
        Eu = sum(exp2(k*s - (k+1)) / s for k in 0:K)   # underflows to 0, never Inf
        return (Eu * s)^(1/s)
    end
end
@printf("  %8s %18s %s\n", "ρ", "certainty equiv.", "phase")
for ρ in (0.0, 1e-3, 0.05, 0.25, 0.50, 1.0, 2.0, 5.0)
    v = ce(ρ)
    @printf("  %8.3f %18s %s\n", ρ,
            isfinite(v) ? @sprintf("%.4f", v) : "∞ (diverges)",
            ρ <= 0 ? "PARADOX: no finite fair price" :
            ρ < 0.06 ? "resolved, but price still explodes as ρ→0⁺" :
                        "resolved: finite, stable price")
end
println("""
  ⇒ The paradox is the single point ρ = 0 (risk neutrality) — a phase
    boundary of measure zero that classical decision theory happened to
    make its default. Any ρ > 0 resolves it; NOTHING selects a particular
    ρ > 0. «Resolved by changing the model» = «moved off the boundary,
    direction unforced» — which is why it lands frame-relative on the map.""")

section("PART B.3 — BERTRAND: sweep the measure exponent α   [midpoint radius ∝ rᵅ]")
# Hidden variable: sample the chord's midpoint radius with density ∝ r^α.
# P(chord > √3) = P(r < 1/2) = (1/2)^(α+1).  The three classic answers are
# three POINTS on this dial:  α=0 → 1/2 (radial),  α=1 → 1/4 (area),
# α = log2(3)−1 ≈ 0.585 → 1/3 (endpoints).
P(α) = 0.5^(α + 1)
@printf("  %10s %14s %s\n", "α", "P(long chord)", "which classic method this is")
for (α, label) in [(0.0, "«random radial point»  (Bertrand method 2)"),
                   (log2(3) - 1, "«random endpoints»     (Bertrand method 1)"),
                   (1.0, "«random midpoint area» (Bertrand method 3)"),
                   (2.0, "(no classic name — just as legitimate)"),
                   (5.0, "(ditto)")]
    @printf("  %10.4f %14.4f %s\n", α, P(α), label)
end
# And empirically, mid-sweep, with actual chords:
using Random; Random.seed!(11)
function bertrand_alpha(α; trials=200_000)
    hits = 0
    for _ in 1:trials
        r = rand()^(1 / (α + 1))          # inverse-CDF sample of density ∝ r^α
        hits += 2 * sqrt(1 - r^2) > sqrt(3)
    end
    hits / trials
end
for α in (0.0, log2(3) - 1, 1.0)
    @printf("  Monte-Carlo check α=%.4f:  simulated %.4f  vs analytic %.4f\n",
            α, bertrand_alpha(α), P(α))
end
println("""
  ⇒ CONTRAST WITH B.1/B.2: no phase boundary. P(α) = 2^−(α+1) is a smooth
    bijection from α ∈ [0,∞) onto (0, 1/2] — every answer in that range is
    some measure's honest verdict, and all three classic answers are just
    three points that historically got names. A paradox with a phase
    boundary RESOLVES once you find the dial (Broome, St. Petersburg: the
    dial's setting was a hidden empirical/normative commitment). A paradox
    whose dial sweeps a CONTINUUM with no distinguished point DISSOLVES —
    the question, not the answer, was underdetermined. That is the
    computable difference between «resolves relative to a frame» and
    «ill-posed», and it is the sharpest operational cash-out yet for the
    field's proposed frame_commitment kind: a frame_commitment is
    A CHOICE OF POINT ON A DIAL THE PROBLEM ITSELF CANNOT SET.""")

section("SUMMARY — what the sweeps add to the taxonomy")
println("""
  Old taxonomy (F_1):  resolves / doesn't / dissolves — assigned by verdict.
  New, computable refinement:
    • antinomies:            no dial exists (the contradiction is dial-free)
    • frame-relative:        a dial exists WITH a phase boundary; the paradox
                             is the boundary; frames = sides of the boundary
                             (Broome q=1/2, St. Petersburg ρ=0)
    • ill-posed (dissolves): a dial exists with NO distinguished point;
                             the question underdetermines its own answer
                             (Bertrand α — a continuum of equal citizens)
  Conjecture for the field (falsifiable, dear instances): every «no neutral
  resolution» paradox in this repo's census is one of these three shapes,
  and the shape can be decided by exhibiting (or proving absent) the dial.""")
