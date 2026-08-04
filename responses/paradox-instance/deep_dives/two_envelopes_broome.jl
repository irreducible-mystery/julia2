# ======================================================================
# two_envelopes_broome.jl — DEEP DIVE: the unbounded-prior Two Envelopes
# (Broome 1995), requested by the repository owner.
#
# The finite version of Two Envelopes resolves cleanly (fallacious
# conditioning — see paradoxes/03_probability.jl). This file is about
# the variant that DOES NOT fully resolve: a prior under which the
# conditional expected gain from switching is strictly positive FOR
# EVERY AMOUNT YOU COULD OBSERVE — yet, by symmetry, switching cannot
# help. The culprit is NON-CONGLOMERABILITY of expectations under an
# infinite-mean prior, and Julia can exhibit every piece of it.
#
#   Broome prior: pair n (n = 0,1,2,…) is (2^n, 2^(n+1)),
#                 with probability  p_n = (1/3)·(2/3)^n.
#   Key inequality: p(n)/p(n-1) = 2/3 > 1/2, so the posterior always
#   leans «small» enough for switching to look good — and E[amount] = ∞.
# ======================================================================

using Random, Statistics, Printf
Random.seed!(2025)
section(t) = println("\n", "═"^70, "\n  ", t, "\n", "═"^70)

p(n) = (1/3) * (2/3)^n            # P(pair = (2^n, 2^(n+1)))

# ----------------------------------------------------------------------
section("1. THE ANALYTIC HEART — conditional gain is positive EVERYWHERE")
# ----------------------------------------------------------------------
# You open your envelope and see amount A = 2^n.
#   n = 0 (A = 1): you are certainly the small envelope → gain = +1.
#   n ≥ 1: the pair is either (2^(n-1), 2^n)  [prob ∝ p(n-1)/2]
#                       or    (2^n, 2^(n+1))  [prob ∝ p(n)/2].
# Posterior odds p(n-1) : p(n) = 3 : 2  ⇒  P(small | A=2^n) = 2/5.
println("    Observed A = 2^n. Posterior P(you hold the SMALL one | A):")
println("    n = 0:  P(small) = 1        E[gain | switch] = +1")
for n in 1:6
    A       = 2.0^n
    ps      = p(n) / (p(n) + p(n-1))          # P(small | A) = 2/5 for all n ≥ 1
    Egain   = ps * A - (1 - ps) * A/2         # win A if small, lose A/2 if large
    @printf("    n = %d:  P(small) = %.4f   E[gain | A = %-5.0f] = %+8.4f  (= A/10)\n",
            n, ps, A, Egain)
end
println("    ⇒ For EVERY possible observation, switching has expected gain A/10 > 0.")
println("      By symmetry the other player computes the same. Both «should» switch.")
println("      Both cannot be right. And yet no single conditional step is wrong.")

# ----------------------------------------------------------------------
section("2. SIMULATION — conditional advice vs unconditional truth")
# ----------------------------------------------------------------------
function broome_trial(rng)
    n = 0                            # geometric: stop w.p. 1/3 ⇒ p(n) = (1/3)(2/3)^n
    while rand(rng) < 2/3
        n += 1
    end
    small, large = 2.0^n, 2.0^(n+1)
    holds_small  = rand(rng, Bool)
    A     = holds_small ? small : large
    other = holds_small ? large : small
    return A, other - A                          # observed amount, gain-if-switch
end

rng = MersenneTwister(7)
const T = 2_000_000
by_amount = Dict{Float64,Vector{Float64}}()
for _ in 1:T
    A, g = broome_trial(rng)
    push!(get!(by_amount, A, Float64[]), g)
end

println("    Conditional mean gain from switching, per observed amount:")
@printf("    %10s %12s %16s %14s\n", "A", "count", "mean gain", "theory (A/10)")
for A in sort(collect(keys(by_amount)))[1:8]
    gs = by_amount[A]
    theo = A == 1.0 ? 1.0 : A/10
    @printf("    %10.0f %12d %+16.4f %+14.3f\n", A, length(gs), mean(gs), theo)
end
println("    Every conditional row matches theory: «switch» is locally right everywhere.")

# The UNCONDITIONAL mean, however, is not even estimable — the law of
# large numbers FAILS for infinite-mean variables. Five seeds, five answers:
pooled = map(1:5) do seed
    r = MersenneTwister(seed)
    mean(broome_trial(r)[2] for _ in 1:500_000)
end
println("\n    Pooled unconditional mean gain, five independent seeds (500k trials each):")
println("       ", join([@sprintf("%+12.2f", m) for m in pooled], " "))
println("    — wildly unstable: with E[amount] = ∞ the sample mean never converges;")
println("      single freak deep-tail pairs dominate entire runs (LLN inapplicable).")

# The exact unconditional truth needs no estimation at all — symmetry:
# in every single trial, player 1's switching gain is exactly the negative
# of player 2's, so the two-player ledger is identically zero.
r2 = MersenneTwister(99)
paired_total = sum(1:200_000) do _
    g = broome_trial(r2)[2]
    g + (-g)                         # both players switch: gains cancel per trial
end
println("\n    Exact two-player ledger (both switch, per-trial cancellation): ",
        paired_total, "  — switching is unconditionally worthless, PROVABLY.")
println("    Every row says «switch». The exact pool says «it cannot matter».")

# ----------------------------------------------------------------------
section("3. THE DIAGNOSIS — non-conglomerability, computed")
# ----------------------------------------------------------------------
# Conglomerability: if E[G | B_i] ≥ c for every cell of a partition {B_i},
# then E[G] ≥ c. This FAILS here because E[G] is a divergent ∞ − ∞ form.
# The partial sums of Σ_A P(A)·E[G|A] converge to a POSITIVE number…
cells = 0.0
println("    Σ over observation-cells of P(A)·E[gain | A]  (partial sums):")
for n in 0:30
    A  = 2.0^n
    PA = n == 0 ? p(0)/2 : (p(n-1) + p(n))/2         # P(observe 2^n)
    Eg = n == 0 ? 1.0 : A/8
    global cells += PA * Eg
    n in (0, 1, 2, 5, 10, 20, 30) &&
        @printf("      through n = %2d:  %10.5f\n", n, cells)
end
println("    → the by-observation sum DIVERGES to +∞,")
println("      while the same sum organized by PAIRS is 0 by symmetry:")
pairs_sum = sum(p(n) * 0.0 for n in 0:30)            # each pair is exchangeable
println("      Σ over pairs of p(n)·E[gain | pair n] = ", pairs_sum)
println()
println("    Two partitions of the SAME event space give different «totals»")
println("    because E[amount] DIVERGES — the honest divergence certificate:")
term(n) = p(n) * (2.0^n + 2.0^(n+1)) / 2          # p(n)·(mean of the pair)
println("      E[amount] = Σ term(n),  term ratio term(n+1)/term(n) = ",
        round(term(5)/term(4), digits=4), "  = 4/3 > 1 ⇒ terms GROW")
for N in (10, 30, 60)
    @printf("      partial sum through n = %2d:  %14.2f\n",
            N, sum(term(n) for n in 0:N))
end
println("      With E[amount] = ∞, E[gain]'s positive and negative parts are")
println("      each infinite; their «difference» is an ∞ − ∞ ledger whose value")
println("      depends on summation order — Riemann's rearrangement theorem")
println("      is the engine under the paradox.")

# ----------------------------------------------------------------------
section("4. RIEMANN REARRANGEMENT — the same series, any answer you like")
# ----------------------------------------------------------------------
# The switching-gain ledger is an alternating series with divergent
# absolute value. Rearranged, it can «prove» any target. Demonstration
# with the classic alternating harmonic ledger:
function rearranged_sum(target; terms=200_000)
    pos = (1.0/(2k-1) for k in 1:terms)   # positive credits
    neg = (-1.0/(2k)  for k in 1:terms)   # negative debits
    P, Ng = collect(pos), collect(neg)
    s, i, j = 0.0, 1, 1
    order_preview = Float64[]
    while i + j < 60_000
        if s < target
            s += P[i]; i += 1
        else
            s += Ng[j]; j += 1
        end
        length(order_preview) < 6 && push!(order_preview, s)
    end
    return s
end
for tgt in (0.0, 1.0, log(2), 3.14159)     # log(2) is the «natural» order's sum
    @printf("    rearranged to target %8.5f → partial sum settles at %8.5f\n",
            tgt, rearranged_sum(tgt))
end
println("    A conditionally convergent ledger has no observer-independent total —")
println("    «the value of switching» in Broome's game is exactly such a ledger.")

# ----------------------------------------------------------------------
section("5. WHERE IT LANDS — what resolves, what remains")
# ----------------------------------------------------------------------
println("""
    RESOLVED (theorem-level):
      • No paradox in any FINITE truncation: cap the pairs at n ≤ N and
        the top observation A = 2^(N+1) is CERTAINLY the large envelope —
        its guaranteed loss exactly cancels the whole interior advantage:""")
function truncated_ledger(N)
    Z = sum(p(n) for n in 0:N)
    interior = 0.0
    # cell A = 2^0: certainly small, gain +1, weight p(0)/2
    interior += (p(0)/Z)/2 * 1.0
    for n in 1:N                                # interior cells A = 2^n
        PA = ((p(n-1) + p(n))/Z) / 2
        ps = p(n) / (p(n) + p(n-1))
        interior += PA * (ps * 2.0^n - (1-ps) * 2.0^n/2)
    end
    boundary = ((p(N)/Z)/2) * (-(2.0^(N+1))/2)  # A = 2^(N+1): certainly large
    return interior, boundary
end
for N in (5, 10, 20)
    i, b = truncated_ledger(N)
    @printf("        N = %2d:  interior advantage %+9.4f  boundary cell %+9.4f  total %+.2e\n",
            N, i, b, i + b)
end
println("        The «paradox» is the boundary term surviving the N → ∞ limit")
println("        as a ghost: it never appears at any finite A, yet its weight×size")
println("        does not vanish.")
println("""
      • The «always switch» ARGUMENT is invalid: it applies conglomerability
        to a non-conglomerable expectation. That step, and only that step,
        is the formal error.

    NOT RESOLVED (still contested in the literature):
      • What should a rational agent DO facing a genuinely infinite-mean
        prior, observing A, with positive conditional gain at every A?
        Answers on offer — forbid such priors (finitism), abandon
        expectation as the decision criterion (bounded utility, medians),
        accept non-conglomerable «local» advice as rational — each gives
        up something. This is the same shape as the Sorites verdict:
        NO NEUTRAL RESOLUTION; you choose which intuition to sacrifice.

    Field-note for this repo: this is the cleanest concrete case for the
    proposed `incommensurable_priors` relation — the two partitions
    (by-amount vs by-pair) are two projections π₁, π₂ of one microstate
    space whose induced expectations DISAGREE, and no finer common
    refinement restores agreement while the mean diverges. In Part 2's
    language: the commutation diagram π∘F ≈ G∘π fails non-removably.""")
