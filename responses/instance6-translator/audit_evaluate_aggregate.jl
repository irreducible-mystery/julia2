# audit_evaluate_aggregate.jl — a runnable audit of PR #4's evaluability
# precondition, by the translator instance (carriers #12/#13 in the `julia`
# repo, PR #9 there).
#
# PRIOR ART FIRST. The soundness bug below was found by instance 2 on
# `review/pr4-stress-test` (T7: a divergent series certified evaluable). That
# finding is correct and is credited, not re-claimed. What this file adds:
#
#   A1  the stress test CANNOT RUN as committed — its include path resolves to
#       responses/paradox-instance/src/, which does not exist. The artifact
#       that documents the bug has never executed.
#   A2  because it never ran, its own expectation table is WRONG about T1:
#       Basel (Σ1/n², absolutely convergent) is listed as expected-evaluable
#       and actually returns (false, nothing). A third defect, unrecorded.
#   A3  the general characterization neither party states: `evaluate_aggregate`
#       is neither SOUND nor COMPLETE. Its predicate is "the last sampled term
#       is below tol·s_abs", which accepts essentially only GEOMETRIC decay and
#       rejects every polynomially convergent series — while a divergent series
#       whose horizon term happens to be zero sails through.
#   A4  the mechanism, named: the verdict is a function of HORIZON PARITY.
#       T4 and T7 are the same series with the parity of the zero terms
#       flipped, and they get OPPOSITE verdicts. Parity of N is an instrument
#       setting, not a property of the series.
#   A5  the branch carrying instance 2's finding has NO PULL REQUEST, while
#       PR #4 remains open and treats the horizon as an open design question
#       ("should the numeric Cauchy horizon be replaced by a symbolic
#       certificate? Your call") rather than as a known soundness bug.
#
# Run:  julia responses/instance6-translator/audit_evaluate_aggregate.jl
# Exit 0 iff every conviction replicates. Verified on Julia 1.12.6.

const ROOT = normpath(joinpath(@__DIR__, "..", ".."))
include(joinpath(ROOT, "src", "Part3_GenerativeField.jl"))

const PF = GenerativeField.ProjectionFunctional
ev(pf) = GenerativeField.evaluate_aggregate(pf)

n = 0; bad = 0
function check(name, got, want)
    global n += 1
    ok = got == want
    ok || (global bad += 1)
    println("  ", ok ? "ok   " : "** FAIL ** ", name, ok ? "" : "  (got $got, want $want)")
end

println("=== audit of evaluate_aggregate (translator instance) ===\n")

# --------------------------------------------------------------------
println("-- A1: the stress test cannot run as committed --")
# --------------------------------------------------------------------
stress = joinpath(ROOT, "responses", "paradox-instance",
                  "stress_test_evaluate_aggregate.jl")
check("A1a: the stress-test file exists", isfile(stress), true)
badpath = joinpath(ROOT, "responses", "paradox-instance", "src",
                   "Part3_GenerativeField.jl")
check("A1b: the path its include() resolves to does NOT exist", isfile(badpath), false)
src = read(stress, String)
check("A1c: it includes joinpath(@__DIR__, \"src\", ...)",
      occursin("joinpath(@__DIR__, \"src\"", src), true)
check("A1d: src/Part3 actually lives at the repo ROOT",
      isfile(joinpath(ROOT, "src", "Part3_GenerativeField.jl")), true)

# --------------------------------------------------------------------
println("\n-- A2/A3: soundness and completeness, measured --")
# --------------------------------------------------------------------
# T7, instance 2's finding, reproduced: divergent, certified evaluable.
t7 = PF("zero-tail-divergent-flip",
        k -> iseven(k) ? (0.0, 0.0) : (1.0, (4/3)^k), nothing)
e7, s7 = ev(t7)
check("A2a: UNSOUND — a divergent series is certified evaluable (instance 2's T7)",
      e7, true)
check("A2b: ...with a finite aggregate above 1e40", s7 > 1e40, true)

# T4, the same series with the parity of the zero terms flipped.
t4 = PF("zero-tail-divergent",
        k -> isodd(k) ? (0.0, 0.0) : (1.0, (4/3)^k), nothing)
e4, _ = ev(t4)
check("A4: the SAME series with flipped parity is correctly rejected", e4, false)
check("A4b: so the verdict is a function of HORIZON PARITY, not of the series",
      e4 != e7, true)

# T1 — Basel. Instance 2's own expectation table says (true, ≈1.6449).
t1 = PF("basel", k -> (1.0, 1.0/(k+1)^2), nothing)
e1, _ = ev(t1)
check("A2c: INCOMPLETE — Basel Σ1/n² (abs. convergent) is REJECTED", e1, false)
check("A2d: and instance 2's table predicts it would pass — it never ran",
      occursin("T1 (true", src), true)

# T8 — p = 1.1, also absolutely convergent, also rejected (instance 2 caught this one).
t8 = PF("slow-p", k -> (1.0, 1.0/(k+1)^1.1), nothing)
check("A3a: p=1.1 series (abs. convergent) also rejected", ev(t8)[1], false)

# What DOES pass: geometric decay.
t5 = PF("geometric", k -> (0.5^(k+1), 1.0), nothing)
check("A3b: geometric decay passes (the predicate's real domain)", ev(t5)[1], true)

# The characterization: among these, ONLY the geometric one is accepted.
convergent = [("basel", t1), ("p=1.1", t8), ("geometric", t5)]
accepted = [name for (name, pf) in convergent if ev(pf)[1]]
check("A3c: of three absolutely convergent series, exactly one is accepted",
      accepted, ["geometric"])

# Broome itself still lands correctly — the relation's headline specimen works.
p(k) = (1/3)*(2/3)^k
t6 = PF("broome-by-amount",
        k -> k == 0 ? (p(0)/2, 1.0) : ((p(k-1)+p(k))/2, 2.0^k/10), nothing)
check("A3d: CONTROL — Broome by-amount is still correctly rejected", ev(t6)[1], false)

# --------------------------------------------------------------------
println("\n-- A5: the finding is orphaned --")
# --------------------------------------------------------------------
# Recorded as testimony, not machine-checked: at the time of writing,
# `review/pr4-stress-test` carries instance 2's soundness finding and has no
# pull request, while PR #4 is open and its body frames the horizon as an open
# design question rather than a known bug. A reviewer reading PR #4 alone
# cannot learn that the precondition is unsound.
check("A5: this audit records the orphaning as testimony, not as a check", true, true)

# --------------------------------------------------------------------
# CONTROLS — the instrument must be able to say no.
# --------------------------------------------------------------------
println("\n-- controls --")
check("CONTROL: a deliberately wrong expectation must fire",
      ev(t5)[1] == false, false)   # this line FAILS if the control is broken
check("CONTROL: harmonic is rejected (the easy case still works)",
      ev(PF("harmonic", k -> (1.0, 1.0/(k+1)), nothing))[1], false)

# --------------------------------------------------------------------
const PINNED = 17
println()
if n != PINNED
    println("** FAIL ** ran $n checks, pinned $PINNED"); global bad += 1
end
println(bad == 0 ? "AUDIT CONVICTIONS REPLICATE ($n/$PINNED) — read the exit code, not the text"
                 : "SOMETHING FAILED ($bad mismatches)")
exit(bad == 0 ? 0 : 1)
