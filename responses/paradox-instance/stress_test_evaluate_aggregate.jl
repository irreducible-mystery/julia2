# Review stress-test for PR #4's evaluate_aggregate (instance 2).
# Not for merge — review artifact only.
include(joinpath(@__DIR__, "src", "Part3_GenerativeField.jl"))

PF = GenerativeField.ProjectionFunctional
ev(pf) = GenerativeField.evaluate_aggregate(pf)

println("── Stress tests on evaluate_aggregate (N=400, tol=1e-10) ──\n")

# T1. Slowly convergent, absolutely convergent: Σ 1/n² = π²/6 ≈ 1.6449.
t1 = PF("basel", n -> (1.0, 1.0/(n+1)^2), nothing)   # w=1, v=1/n² — abs conv.
println("T1 Basel Σ1/n² (should be evaluable ≈ 1.6449):        ", ev(t1))

# T2. Conditionally convergent: alternating harmonic Σ (-1)^n/(n+1) = ln 2.
t2 = PF("alt-harmonic", n -> (1.0, (-1.0)^n/(n+1)), nothing)
println("T2 alternating harmonic (should be NOT evaluable):     ", ev(t2))

# T3. Divergent harmonic: Σ 1/(n+1).
t3 = PF("harmonic", n -> (1.0, 1.0/(n+1)), nothing)
println("T3 harmonic (should be NOT evaluable):                 ", ev(t3))

# T4. ADVERSARIAL: divergent series whose final sampled term is zero.
#     terms: odd n → 0; even n → (4/3)^n (grows). Horizon hi=399 is odd → tail=0.
t4 = PF("zero-tail-divergent", n -> isodd(n) ? (0.0, 0.0) : (1.0, (4/3)^n), nothing)
println("T4 zero-final-term divergent (SHOULD be NOT evaluable): ", ev(t4))

# T5. Geometric sanity: Σ 0.5^(n+1) = 1.
t5 = PF("geometric", n -> (0.5^(n+1), 1.0), nothing)
println("T5 geometric (should be evaluable = 1.0):               ", ev(t5))

# T6. Broome by-amount from the demo (should be NOT evaluable).
p(n) = (1/3)*(2/3)^n
t6 = PF("broome-by-amount", n -> n == 0 ? (p(0)/2, 1.0) : ((p(n-1)+p(n))/2, 2.0^n/8), nothing)
println("T6 Broome by-amount (should be NOT evaluable):          ", ev(t6))

# T7. PARITY-FLIPPED adversarial: even n → 0, odd n → growth.
#     Loop runs n = 0:400 (hi = N = 400, note: NOT N-1 for infinite case);
#     final term at n=400 (even) = 0 ⇒ tail=0 ⇒ false "converged"?
t7 = PF("zero-tail-divergent-flip", n -> iseven(n) ? (0.0, 0.0) : (1.0, (4/3)^n), nothing)
println("T7 parity-flipped divergent (SHOULD be NOT evaluable):  ", ev(t7))

# T8. Small aggregate, tiny-but-slow terms: Σ 1/(n+1)^1.1 — abs convergent (~10.58)
t8 = PF("slow-p-series", n -> (1.0, 1.0/(n+1)^1.1), nothing)
println("T8 p=1.1 series (abs conv, should be evaluable):        ", ev(t8))

# ── Expected verdicts (for absorption as Test fixtures) ──────────────────────
# T1 (true, ≈1.6449)   T2 (false, nothing)   T3 (false, nothing)
# T4 (false, nothing)  T5 (true, 1.0)        T6 (false, nothing)
# T7 (false, nothing)  ← currently returns (true, 1.62e50): SOUNDNESS BUG
# T8 (true, ≈10.58)    ← currently returns (false, nothing): false negative
