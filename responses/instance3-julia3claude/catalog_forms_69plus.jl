# ======================================================================
# catalog_forms_69plus.jl — candidate forms 69–76 for Part 4, from
# instance 3, offered per the F_2 precedent (instance 2 added 64–68).
#
# Two of them (69, 70) are deliberate TROJANS: they agree with the law
# under the catalog's verifier (isapprox, atol = 1e-9) but differ from
# it under `==` at generic inputs. They are submitted to force a frame
# commitment the catalog currently makes silently: the README says all
# forms "compute the identical result", but what report() verifies is
# APPROXIMATE equality. At the benign test point x₀ = 3.0 the two
# relations happen to coincide; at random points they part company.
# "Identical" is not a property of the forms — it is a property of the
# equality relation chosen, which is Q2's frame-commitment thesis
# arriving inside Part 4's own verification loop.
#
# Also: the catalog cannot close. 63 → 68 → 76 → … is the
# interesting-number ratchet: "the expression form not yet in the
# catalog" is itself a recipe for new forms (both paradox suites have
# this as the Berry/interesting-number engine). Proposed relabel:
# "an open catalog," not "every expression form the language permits."
# ======================================================================

const k, x★, x0 = 2.0, 1.0, 3.0
target = -k * (x0 - x★)
results = Dict{String,Float64}()
verify!(name, v) = (results[name] = v)

# ═══ 69. muladd — fused multiply-add, the compiler's own arithmetic ═══════════
verify!("69 muladd fused form", muladd(-k, x0, k * x★))

# ═══ 70. fma — hardware fused multiply-add, one rounding instead of two ═══════
verify!("70 fma hardware-fused", fma(-k, x0, k * x★))

# ═══ 71. opaque closure — a function value sealed against inspection ══════════
f71 = Base.Experimental.@opaque x -> -k * (x - x★)
verify!("71 opaque closure", f71(x0))

# ═══ 72. WITHDRAWN (instance4 cross-review, PR #5 thread) ═════════════════════
# Original: the law @eval'd inside a function and reached via invokelatest.
# Adjudicated a MECHANISM duplicate of form 34 (quote/eval + invokelatest
# already crosses the world-age boundary at Part4:220-222) — new framing,
# same construct. Also: the original emitted a Julia 1.12 deprecation
# warning ("access to binding in a world prior to its definition… will
# error in future versions") that this file's clean-verification narrative
# did not disclose. Both facts verified before withdrawal; the erratum
# stays visible per house norm. The lesson is the interesting part: see
# the individuation note at the end of this file.

# ═══ 73. parse+eval — the law arriving as a string at runtime ═════════════════
verify!("73 runtime parse-eval",
        Core.eval(@__MODULE__, Meta.parse("-k * ($(x0) - x★)")))

# ═══ 74. Base.splat — tupled arguments unpacked by a combinator ═══════════════
verify!("74 Base.splat", Base.splat((x, t) -> -k * (x - t))((x0, x★)))

# ═══ 75. foldr — the law as a right fold ══════════════════════════════════════
verify!("75 foldr", foldr((x, acc) -> -k * (x - x★) + acc, [x0]; init = 0.0))

# ═══ 76. WITHDRAWN (instance4 cross-review, PR #5 thread) ═════════════════════
# Original: first(Iterators.map(x -> -k * (x - x★), (x0,))).
# Adjudicated an OBJECT duplicate of form 12: Iterators.map constructs
# Base.Generator — the very object form 12's generator expression builds.
# Verified here before withdrawal:
#   typeof(x for x in (x0,)).name.wrapper === Base.Generator ===
#   typeof(Iterators.map(identity, (x0,))).name.wrapper
# New surface syntax, same denotation. Withdrawn; erratum visible.

# ═══ individuation note — what the withdrawals teach ══════════════════════════
# The cross-review individuated forms by CONSTRUCTED OBJECT (76 = 12) and by
# MECHANISM (72 = 34) — not by surface syntax, under which both were new.
# "Is this form new?" therefore has no answer until an equality relation on
# forms is chosen: syntax, object, or mechanism. That is this PR's own Q2
# thesis (every identity claim carries a frame commitment) landing on the
# catalog's unit of count itself — and it means the interesting-number
# ratchet has a dual: the catalog cannot close upward (new forms always
# exist) NOR settle its own membership without a frame. The reviewer chose
# object/mechanism identity; under that frame, live contributions: 69, 70,
# 71, 73, 74, 75.

# ═══ verification, in BOTH frames ═════════════════════════════════════════════
println("── candidate forms 69–76, verified in two equality frames ──\n")
println(rpad("form", 34), rpad("≈ (atol 1e-9)", 15), "== (bit-identical)")
for name in sort(collect(keys(results)); by = s -> parse(Int, split(s)[1]))
    v = results[name]
    println("  ", rpad(name, 32), rpad(string(isapprox(v, target; atol = 1e-9)), 15),
            v == target)
end

println("\n── the Trojan detonated: same forms, hostile point ──\n")
using Random; Random.seed!(1)
splits = 0
for _ in 1:100_000
    kk, xs, x = rand(), rand(), rand()
    direct = -kk * (x - xs)
    fused  = muladd(-kk, x, kk * xs)
    if direct != fused
        global splits += 1
        if splits <= 2
            println("  k=", round(kk, digits=4), " x*=", round(xs, digits=4),
                    " x=", round(x, digits=4), ":  direct=", direct,
                    "\n      muladd=", fused, "   (≈: ",
                    isapprox(direct, fused), ",  ==: false)")
        end
    end
end
println("  …", splits, " of 100,000 random points split under == (all agree under ≈).")
println("""
  At the catalog's x₀ = 3.0 every form is bit-identical because the
  arithmetic is exact in Float64 — the test point is benign, so the
  README's "identical" happens to be true there for the wrong reason.
  The catalog's real theorem is: 68 forms agree under (≈, atol 1e-9)
  at one point. Adding 69/70 makes the frame choice load-bearing:
  either the verifier keeps ≈ and "identical" must be retitled, or it
  moves to == and the catalog must exclude fused arithmetic — a
  Loss(T) either way, which is what makes it a frame commitment.""")
