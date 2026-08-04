#=============================================================================
 Part 4 — THE EXPRESSION CATALOG
 "Julia language allows for many different expressions. Please translate the
  attached into every Julia expression the language permits."

 We take the single central equation of both documents —

        dx/dt = F(x, e, c)          (the organization of change)

 concretely instantiated as the document's fixed-target regulation

        F(x) = -k(x - x*)           (deviation → corrective response)

 — and write it in EVERY expression form the Julia language provides.
 Each numbered section is a distinct syntactic construct of Julia.
 All forms are verified at the bottom to compute the identical value.
=============================================================================#

module ExpressionCatalog

using Statistics

const k  = 2.0          # restoring strength
const x★ = 1.0          # the target x*   (Unicode identifier: itself form #0)
const x0 = 3.0          # test state — every form must map 3.0 ↦ -4.0

results = Dict{String,Float64}()                          # collected verifications
verify!(name, val) = (results[name] = val; val)

# ═══ 1. Compact "assignment form" function definition ═══════════════════════
f1(x) = -k * (x - x★)
verify!("1 assignment-form function", f1(x0))

# ═══ 2. Full `function ... end` declaration ═════════════════════════════════
function f2(x)
    return -k * (x - x★)                                  # explicit return
end
verify!("2 function/end with return", f2(x0))

# ═══ 3. Implicit return (value of last expression) ══════════════════════════
function f3(x)
    -k * (x - x★)                                         # no `return` keyword
end
verify!("3 implicit return", f3(x0))

# ═══ 4. Anonymous function via arrow `->` ═══════════════════════════════════
f4 = x -> -k * (x - x★)
verify!("4 arrow lambda", f4(x0))

# ═══ 5. Anonymous `function` expression ═════════════════════════════════════
f5 = function (x)
    -k * (x - x★)
end
verify!("5 anonymous function-block", f5(x0))

# ═══ 6. `do`-block syntax (trailing function argument) ══════════════════════
apply_flow(g, x) = g(x)
v6 = apply_flow(x0) do x                                  # do-block creates the λ
    -k * (x - x★)
end
verify!("6 do-block", v6)

# ═══ 7. Function composition operator ∘ ═════════════════════════════════════
deviation(x) = x - x★
scale_by_neg_k(d) = -k * d
f7 = scale_by_neg_k ∘ deviation                           # F = (-k·) ∘ (· - x*)
verify!("7 composition ∘", f7(x0))

# ═══ 8. Pipe operator |> ════════════════════════════════════════════════════
v8 = x0 |> deviation |> scale_by_neg_k                    # data flows left→right
verify!("8 pipe |>", v8)

# ═══ 9. Broadcast (dot) call — vectorized expression ════════════════════════
v9 = (-k .* ([x0] .- x★))[1]                              # x may be a whole field
verify!("9 broadcast dot-call", v9)

# ═══ 10. The @. macro — fuse every operation into broadcast ═════════════════
xs = [x0]
v10 = (@. -k * (xs - x★))[1]
verify!("10 @. broadcast macro", v10)

# ═══ 11. Array comprehension ════════════════════════════════════════════════
v11 = [-k * (x - x★) for x in [x0]][1]
verify!("11 comprehension", v11)

# ═══ 12. Generator expression (lazy comprehension) ══════════════════════════
v12 = first(-k * (x - x★) for x in (x0,))
verify!("12 generator", v12)

# ═══ 13. `map` with a lambda ════════════════════════════════════════════════
v13 = map(x -> -k * (x - x★), [x0])[1]
verify!("13 map", v13)

# ═══ 14. `foldl` / `reduce` — the flow as a fold over operations ════════════
v14 = foldl((acc, op) -> op(acc), [deviation, scale_by_neg_k]; init = x0)
verify!("14 foldl over operator sequence", v14)

# ═══ 15. Ternary conditional expression ═════════════════════════════════════
f15(x) = x == x★ ? 0.0 : -k * (x - x★)                    # at target: no correction
verify!("15 ternary ?:", f15(x0))

# ═══ 16. `if / elseif / else` — the block IS an expression (returns a value) ═
v16 = if x0 > x★
    -k * (x0 - x★)                                        # above target: pull down
elseif x0 < x★
    -k * (x0 - x★)                                        # below target: pull up
else
    0.0
end
verify!("16 if-expression value", v16)

# ═══ 17. Short-circuit && and || as control expressions ═════════════════════
function f17(x)
    x == x★ && return 0.0                                 # && guard
    x != x★ || return 0.0                                 # || guard (unreachable here)
    -k * (x - x★)
end
verify!("17 short-circuit guards", f17(x0))

# ═══ 18. `begin ... end` compound block expression ══════════════════════════
v18 = begin
    d = x0 - x★
    -k * d
end
verify!("18 begin block", v18)

# ═══ 19. `let` block with its own bindings ══════════════════════════════════
v19 = let x = x0, κ = k, target = x★
    -κ * (x - target)
end
verify!("19 let block", v19)

# ═══ 20. `(...; ...)` chain — semicolon sequence expression ═════════════════
v20 = (d = x0 - x★; -k * d)
verify!("20 semicolon chain", v20)

# ═══ 21. `while` loop computing the same increment ══════════════════════════
function f21(x)
    total, remaining = 0.0, k                             # accumulate -1·(x-x★), k times
    while remaining > 0
        total -= (x - x★)
        remaining -= 1
    end
    total
end
verify!("21 while loop", f21(x0))

# ═══ 22. `for` loop form ════════════════════════════════════════════════════
function f22(x)
    total = 0.0
    for _ in 1:Int(k)
        total -= (x - x★)
    end
    total
end
verify!("22 for loop", f22(x0))

# ═══ 23. Recursion (the loop as self-reference) ═════════════════════════════
f23(x, n = Int(k)) = n == 0 ? 0.0 : -(x - x★) + f23(x, n - 1)
verify!("23 recursion", f23(x0))

# ═══ 24. Multiple dispatch — the flow specialized by TYPE of organization ═══
abstract type Regulation end
struct FixedTarget   <: Regulation end                    # dx/dt = -k(x - x*)
struct MovingTarget  <: Regulation; x★t::Function end     # x(t) ≈ x*(t)
struct NoRegulation  <: Regulation end

flow(x, ::FixedTarget)          = -k * (x - x★)
flow(x, r::MovingTarget; t = 0) = -k * (x - r.x★t(t))
flow(x, ::NoRegulation)         = 0.0
verify!("24 multiple dispatch", flow(x0, FixedTarget()))

# ═══ 25. Parametric method with type constraint ═════════════════════════════
f25(x::T) where {T<:Real} = -T(k) * (x - T(x★))           # where-clause form
verify!("25 parametric where-method", f25(x0))

# ═══ 26. Callable struct (functor) — organization c literally carries F ═════
struct Organization₂                                      # the `c` of dx/dt = F(x,e,c)
    k::Float64
    x★::Float64
end
(c::Organization₂)(x) = -c.k * (x - c.x★)                 # instances are callable
verify!("26 callable struct (functor)", Organization₂(k, x★)(x0))

# ═══ 27. Closure — e and c captured from the enclosing scope ════════════════
make_F(e, c) = x -> -c.k * (x - c.x★) + e.drive           # returns dx/dt = F(x,e,c)
f27 = make_F((drive = 0.0,), (k = k, x★ = x★))
verify!("27 closure over (e, c)", f27(x0))

# ═══ 28. Keyword arguments & defaults ═══════════════════════════════════════
f28(x; k = 2.0, target = 1.0) = -k * (x - target)
verify!("28 keyword arguments", f28(x0))

# ═══ 29. Varargs (splat) — coupled multi-component form ═════════════════════
f29(xs...) = sum(-k * (x - x★) for x in xs) / length(xs)
verify!("29 varargs splat", f29(x0, x0, x0))

# ═══ 30. Destructuring & multiple return values ═════════════════════════════
function f30(x)
    d, κ = x - x★, k                                      # tuple destructuring
    velocity, magnitude = -κ * d, abs(κ * d)              # multiple returns
    velocity, magnitude
end
v30, _ = f30(x0)
verify!("30 destructuring / multi-return", v30)

# ═══ 31. NamedTuple expression ══════════════════════════════════════════════
state31 = (x = x0, dxdt = -k * (x0 - x★))                 # labeled state record
verify!("31 NamedTuple", state31.dxdt)

# ═══ 32. Dict lookup as a piecewise expression ══════════════════════════════
regime_flow = Dict(:regulated => x -> -k * (x - x★), :free => x -> 0.0)
verify!("32 Dict-of-functions", regime_flow[:regulated](x0))

# ═══ 33. Array/matrix linear-algebra expression: ẋ = A(x - x*) ══════════════
A33 = [-k;;]                                              # 1×1 matrix literal (;; syntax)
verify!("33 matrix form ẋ=A(x-x*)", (A33 * [x0 - x★])[1])

# ═══ 34. String macro / metaprogramming: build F from an expression tree ════
ex = :( -$k * (x - $x★) )                                 # quoted expression w/ interpolation
f34 = eval(:(x -> $ex))                                   # code that writes code
verify!("34 metaprogramming (quote/eval)", Base.invokelatest(f34, x0))

# ═══ 35. A user-defined macro — the law as a syntactic transformation ════════
macro flow(xexpr)                                          # macro definition form
    esc(:( -k * ($xexpr - x★) ))
end
verify!("35 user-defined macro", @flow x0)

# ═══ 36. Generated function — code specialized per input TYPE at compile time
@generated function f36(x)
    :( -k * (x - x★) )                                    # returns an expression
end
verify!("36 @generated function", f36(x0))

# ═══ 37. User-defined operator — regulation as an infix symbol ═══════════════
⊙(x, target) = -k * (x - target)                          # x ⊙ x★  "flows toward"
verify!("37 custom infix operator ⊙", x0 ⊙ x★)

# ═══ 38. Operator overloading on a custom type ═══════════════════════════════
struct StateVal; x::Float64 end
Base.:-(a::StateVal, b::StateVal) = StateVal(a.x - b.x)   # extend Base.- (method-on-Base)
Base.:*(c::Real, s::StateVal)     = StateVal(c * s.x)
verify!("38 operator overloading", (-k * (StateVal(x0) - StateVal(x★))).x)

# ═══ 39. try / catch / finally as a value-producing expression ═══════════════
v39 = try
    x0 < -1e10 && throw(DomainError(x0, "outside viable region Ω"))
    -k * (x0 - x★)
catch err
    NaN                                                   # collapse: x ∉ Ω_viable
finally
    nothing                                               # cleanup always runs
end
verify!("39 try/catch expression", v39)

# ═══ 40. Tasks / channels — the flow produced by a coroutine ═════════════════
ch = Channel{Float64}(1) do c
    put!(c, -k * (x0 - x★))                               # producer task expression
end
verify!("40 channel/coroutine", take!(ch))

# ═══ 41. Async task expression ════════════════════════════════════════════════
t41 = @async -k * (x0 - x★)                               # concurrency macro form
verify!("41 @async task", fetch(t41))

# ═══ 42. Threaded loop expression ═════════════════════════════════════════════
acc42 = Threads.Atomic{Float64}(0.0)
Threads.@threads for i in 1:Int(k)                        # parallel-for macro form
    Threads.atomic_add!(acc42, -(x0 - x★))
end
verify!("42 @threads parallel loop", acc42[])

# ═══ 43. Iterator protocol — the trajectory as a custom iterable ══════════════
struct GradientDescent                                    # the settling dynamics of
    x0::Float64; dt::Float64; steps::Int                  # dx/dt = -k(x-x*) as iterator
end
Base.iterate(g::GradientDescent) = (g.x0, (g.x0, 1))
Base.iterate(g::GradientDescent, (x, n)) =
    n ≥ g.steps ? nothing : begin
        x′ = x + g.dt * (-k * (x - x★))
        (x′, (x′, n + 1))
    end
Base.length(g::GradientDescent) = g.steps
traj = collect(GradientDescent(x0, 0.01, 500))
# the law evaluated at the iterator's initial state (and note: traj settles → x★):
verify!("43 iterator protocol", -k * (first(traj) - x★))
@assert isapprox(traj[end], x★; atol = 1e-3)              # the trajectory indeed settles at x*

# ═══ 44. Ranges & stepping expressions ════════════════════════════════════════
v44 = first(-k .* ((x0:x0) .- x★))                        # range as the state set
verify!("44 range expression", v44)

# ═══ 45. Slurp/splat assignment (first, rest...) ══════════════════════════════
first_state, rest... = [x0, 2.0, 1.5]                     # slurping form
verify!("45 slurp assignment", -k * (first_state - x★))

# ═══ 46. Property destructuring of a NamedTuple ═══════════════════════════════
(; x) = (x = x0, e = :env)                                # (; name) destructuring form
verify!("46 property destructuring", -k * (x - x★))

# ═══ 47. Symbol/getfield dynamic access expression ════════════════════════════
params = (k = 2.0, x★ = 1.0)
v47 = -getfield(params, :k) * (x0 - getfield(params, :x★))
verify!("47 dynamic getfield", v47)

# ═══ 48. Union types & missing-tolerant expression ════════════════════════════
f48(x::Union{Float64,Missing}) = ismissing(x) ? missing : -k * (x - x★)
verify!("48 Union{T,Missing} handling", coalesce(f48(x0), NaN))

# ═══ 49. `@evalpoly` / macro-based polynomial (F as its Taylor form) ══════════
# -k(x - x*) = kx★ + (-k)x  — a degree-1 polynomial in x:
verify!("49 @evalpoly", @evalpoly(x0, k * x★, -k))

# ═══ 50. Enum-directed piecewise expression ═══════════════════════════════════
@enum Mode stable_regime threshold new_regime
f50(x, m::Mode) = m == new_regime ? -k * (x - x★) : m == threshold ? -k * (x - x★) : -k * (x - x★)
verify!("50 enum dispatch", f50(x0, new_regime))

# ═══ 51. Rational & irrational literal arithmetic ═════════════════════════════
v51 = Float64(-2//1 * (3//1 - 1//1))                      # exact rational form
verify!("51 rational literals", v51)

# ═══ 52. Complex-number expression (the same law on ℂ) ════════════════════════
verify!("52 complex plane", real(-k * ((x0 + 0im) - x★)))

# ═══ 53. BigFloat arbitrary precision form ════════════════════════════════════
verify!("53 BigFloat precision", Float64(-big(k) * (big(x0) - big(x★))))

# ═══ 54. Numeric-literal coefficient juxtaposition ════════════════════════════
f54(x) = -2.0(x - 1.0)                                    # 2.0(x…): implicit multiply form
verify!("54 literal juxtaposition", f54(x0))

# ═══ 55. Chained comparison expression as viability test ══════════════════════
# The document:  x(t) ∈ Ω_viable  —  chained comparisons express the region:
in_Ω(x) = -10.0 ≤ x ≤ 10.0                                # chained a ≤ x ≤ b form
verify!("55 chained comparison", in_Ω(x0) ? -k * (x0 - x★) : NaN)

# ═══ 56. Bit/boolean arithmetic expression ════════════════════════════════════
f56(x) = (-k * (x - x★)) * (true)                         # Bool as arithmetic 1
verify!("56 bool arithmetic", f56(x0))

# ═══ 57. `ifelse` — branch-free functional conditional ════════════════════════
verify!("57 ifelse builtin", ifelse(x0 == x★, 0.0, -k * (x0 - x★)))

# ═══ 58. `mapreduce` fused expression ═════════════════════════════════════════
verify!("58 mapreduce", mapreduce(x -> -k * (x - x★), +, [x0]))

# ═══ 59. `sum` with generator over a coupled ensemble ═════════════════════════
verify!("59 sum-generator", sum(-k * (x - x★) for x in [x0]))

# ═══ 60. `accumulate` — the running trace of corrections ══════════════════════
verify!("60 accumulate", accumulate(+, [-k * (x0 - x★)])[end])

# ═══ 61. Module-qualified call expression ═════════════════════════════════════
module Inner
    const k′, x★′ = 2.0, 1.0
    F(x) = -k′ * (x - x★′)
end
verify!("61 module-qualified call", Inner.F(x0))

# ═══ 62. `invoke` — call a specific method explicitly ═════════════════════════
f62(x::Real)    = -k * (x - x★)
f62(x::Float64) = invoke(f62, Tuple{Real}, x)             # delegate to the Real method
verify!("62 invoke specific method", f62(x0))

# ═══ 63. Docstring'd + typed + defaulted — the full formal declaration ════════
"""
    regulate(x::Real; k::Real = 2.0, target::Real = 1.0) -> Float64

The document's fixed-target restoring regulation  dx/dt = −k(x − x*):
deviation activates a response toward the target; departures create
compensating motion.
"""
regulate(x::Real; k::Real = 2.0, target::Real = 1.0)::Float64 = -k * (x - target)
verify!("63 documented+typed+default", regulate(x0))

# ═══════════════════════════════════════════════════════════════════════════
# Forms 64–68 — added by instance 2 (response/paradox-instance-part4),
# adjudicated as genuinely absent by instance 1 in issue #1.
# ═══════════════════════════════════════════════════════════════════════════

# ═══ 64. Val-type dispatch — branching moved into the type domain ═══════════
law(::Val{:linear}, x) = -k * (x - x★)
law(::Val{:off},    x) = 0.0                              # another regime, another type
verify!("64 Val-type dispatch", law(Val(:linear), x0))

# ═══ 65. Zero-dimensional broadcast — a scalar as a 0-dim container ═════════
v65 = (-k .* (fill(x0) .- x★))[]                          # fill(x) is 0-dim; [] extracts
verify!("65 zero-dim broadcast fill()[]", v65)

# ═══ 66. Custom string macro — the law as a literal syntax ══════════════════
macro law_str(s)                                          # enables law"3.0"
    :( -k * (parse(Float64, $s) - x★) )
end
verify!("66 custom string macro law\"…\"", law"3.0")

# ═══ 67. Base.Fix1/Fix2 — allocation-free partial application ═══════════════
f67 = Base.Fix1(*, -k) ∘ Base.Fix2(-, x★)                 # x ↦ (x − x★) ↦ −k·(x − x★)
verify!("67 Base.Fix1/Fix2 partial application", f67(x0))

# ═══ 68. Threads.@spawn — the law as a spawned unit of parallel work ════════
v68 = fetch(Threads.@spawn -k * (x0 - x★))
verify!("68 Threads.@spawn fetch", v68)

# ═══ VERIFICATION — every expression form computes the identical flow ═════════
function report()
    println("── Part 4: the same law  dx/dt = -k(x - x*)  in every Julia form ──\n")
    target = -k * (x0 - x★)
    ok = 0
    for name in sort(collect(keys(results)); by = s -> parse(Int, split(s)[1]))
        val   = results[name]
        match = isapprox(val, target; atol = 1e-9)
        ok   += match
        println("  ", match ? "✓" : "✗", "  ", rpad(name, 42), " = ", val)
    end
    println("\n  ", ok, "/", length(results),
            " expression forms agree:  F(", x0, ") = ", target)
    println("  One law of organized change — ", length(results),
            " syntactic organizations of it.")
end

end # module

ExpressionCatalog.report()
