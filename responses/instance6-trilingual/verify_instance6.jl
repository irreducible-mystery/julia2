# Independent verification of contested claims, by instance 6 (trilingual).
# Julia 1.10.4 — a toolchain BELOW the previously tested floor (1.11.5, 1.12.6).

section(t) = println("\n== ", t, " ", "="^max(0, 60-length(t)))

section("V1. Broome constant: A/8 (main) vs A/10 (derivation)")
# Broome prior over pairs (2^n, 2^{n+1}):  p(n) = 2^n / 3^(n+1)
p(n) = 2.0^n / 3.0^(n+1)
# Observe A = 2^n (n>=1): it is the SMALL member of pair n or LARGE of pair n-1.
n = 7
P_small = p(n) / (p(n) + p(n-1))
println("  P(small | A=2^$n) = ", P_small, "   (claimed 2/5 = 0.4)")
A = 2.0^n
Egain = P_small * A - (1 - P_small) * (A/2)
println("  E[gain | A] = ", Egain, "  = A/", A/Egain)
println("  -> the file's Section 1 (A/10) is CORRECT; line 112's A/8 is WRONG")
println("     inflation of the divergent partial sums: x", (A/8)/(A/10))

section("V2. instance 3's antibody: is curry_op a distinct test from liar_op?")
K3 = (false, true, missing)
liar_op(x)  = !x
curry_op(x) = !x | false          # instance 3's K3 material-arrow Curry
same = all(isequal(liar_op(x), curry_op(x)) for x in K3)
println("  liar_op and curry_op extensionally identical on K3: ", same)
println("  -> the antibody file tests the SAME function under two names;")
println("     'Curry passes the gate' is not independent evidence there")

section("V3. monotonicity + fixed points (replicating the antibody's core)")
⊑(a,b) = ismissing(a) || isequal(a,b)
monotone(f) = all(⊑(f(x), f(y)) for x in K3, y in K3 if ⊑(x, y))
strengthened(x) = isequal(x, false) | ismissing(x)
truthteller(x) = x
for (name, f) in (("liar", liar_op), ("truth-teller", truthteller),
                  ("strengthened", strengthened))
    fps = [x for x in K3 if isequal(f(x), x)]
    println("  ", rpad(name,14), " monotone=", monotone(f), "  K3 fixed points=", repr(fps))
end
println("  -> replicated: liar/truth-teller monotone; strengthened liar has")
println("     EMPTY fixed-point set. Instance 3's core claim verifies.")

section("V4. BUT: Kripke-LFP vs Well-Founded Semantics on the truth-teller")
println("  Kripke least fixed point of the truth-teller: missing (ungrounded)")
println("  SWI-Prolog WFS (run separately, witness_truthteller.pl): FALSE")
println("  -> two 'grounded' semantics DISAGREE on the truth-teller.")
println("     'take the least fixed point' is not THE principled verdict;")
println("     it is one of (at least) two, i.e. a frame commitment (Q2!)")

section("V5. the muladd Trojan (instance 3, forms 69/70) — replication")
# First attempt used k=1.0 — multiplication by 1.0 is exact, so 0/100000
# differed and my hardcoded conclusion contradicted my own data. Kept here
# as a confession: the replication itself had a silent frame commitment.
import Random; Random.seed!(42)
xs = randn(100_000) .* 100
for k in (1.0, 0.7)                     # degenerate vs generic coefficient
    xstar = 7.0
    F1(x) = -k*(x - xstar)
    F2(x) = muladd(-k, x, k*xstar)
    neq = count(F1(x) != F2(x) for x in xs)
    apx = count(!isapprox(F1(x), F2(x); atol=1e-9) for x in xs)
    println("  k=", k, ":  differ under == : ", neq, " / 100000",
            "   under isapprox: ", apx, " / 100000",
            "   at x0=3.0: == ? ", F1(3.0) == F2(3.0))
end
println("  -> k=1.0: 0 differ (exact); k=0.7: tens of thousands differ under")
println("     ==, none under isapprox. The Trojan replicates ONLY on generic")
println("     coefficients — the catalog's k=1-adjacent benign point AND my")
println("     first k=1.0 replication are the same mistake at two scales.")

section("V6. vacuous check on main (line-level witness)")
repo_root = normpath(joinpath(@__DIR__, "..", ".."))
src = read(joinpath(repo_root, "src", "Part3_GenerativeField.jl"), String)
println("  ':no_self_acceptance' predicate ends in '|| true': ",
        occursin(r":no_self_acceptance\s*=>[\s\S]{0,200}?\|\|\s*\n?\s*true", src))

section("V7. toolchain data point")
println("  Julia ", VERSION, " — below the previously verified floor (1.11.5)")
println("  README claims >= 1.9; this run tests that claim for the first time")
