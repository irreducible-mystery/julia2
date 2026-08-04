#=============================================================================
 Part 1 — THE ORGANIZATION OF CHANGE
 Julia translation of "Organized Change, Projection, and Generative Fields"
 (Questions 1 & 2)

 Every equation and structure in the source document is rendered here in
 executable Julia, deliberately using a wide range of Julia expression forms.
=============================================================================#

module OrganizedChange

using LinearAlgebra, Statistics

# ---------------------------------------------------------------------------
# Q1 §0  "Change has a structure":   dx/dt = F(x, e, c)
#
# x = present state, e = surrounding condition, c = internal organization.
# Julia form: a higher-order function returning the structured flow F.
# ---------------------------------------------------------------------------

"Structured evolution law  dx/dt = F(x, e, c).  F is *structured*: not every
state can transform directly into every other state."
F(x, e, c) = c.mask .* (c.coupling * x .+ e.drive)      # compact (one-line) function form

"A constraint set `c`: which directions are permitted, how variables couple."
struct Organization{T}
    mask::Vector{T}        # permitted directions (0 = forbidden region)
    coupling::Matrix{T}    # which changes trigger others
end

# Euler integrator — full `function ... end` declaration form
function evolve(x0::Vector, e, c::Organization; dt = 0.01, steps = 1_000)
    x = copy(x0)
    trajectory = [copy(x)]
    for _ in 1:steps                                    # `for` loop expression
        x .+= dt .* F(x, e, c)                          # broadcast-fused update
        push!(trajectory, copy(x))
    end
    return trajectory
end

# ---------------------------------------------------------------------------
# Q1 §1  Change is selective:   x_i(t) ∈ Ω_i
# Some regions Ω_i are broad; others narrow → structured flexibility.
# ---------------------------------------------------------------------------

const Ω = (broad = (-10.0, 10.0), narrow = (-0.1, 0.1))  # NamedTuple constant

"Is each variable inside its admissible region Ω_i?  (comprehension form)"
selective(x, Ωs) = all(lo ≤ xi ≤ hi for (xi, (lo, hi)) in zip(x, Ωs))  # generator expression

# ---------------------------------------------------------------------------
# Q1 §2  Change is coordinated:   supplied rate ≈ required rate
# Identity belongs to the coordination, not to one component value.
# ---------------------------------------------------------------------------

"Dynamic compatibility: supplied ≈ required within tolerance (ternary form)."
coordinated(supplied, required; tol = 0.05) =
    abs(supplied - required) / max(abs(required), eps()) ≤ tol ? true : false

# custom infix operator expression form: `≈̇` is impractical, use ⊜
⊜(a, b) = coordinated(a, b)                              # user-defined Unicode infix operator

# ---------------------------------------------------------------------------
# Q1 §3  Nested clocks — fast/slow systems:
#        dx/dt = f(x, y)
#        dy/dt = ε g(x, y),  0 < ε ≪ 1
# ---------------------------------------------------------------------------

function fast_slow(f, g, x0, y0; ε = 1e-2, dt = 1e-3, T = 10.0)
    x, y, ts = x0, y0, 0.0:dt:T
    X = similar(collect(ts)); Y = similar(X)
    for (i, _) in enumerate(ts)
        X[i], Y[i] = x, y                                # tuple-destructuring assignment
        x += dt * f(x, y)
        y += dt * ε * g(x, y)                            # slow variable shapes the fast one
    end
    (t = collect(ts), fast = X, slow = Y)                # NamedTuple return expression
end

# The slow variable shapes conditions for the fast; fast events alter the slow:
demo_fastslow() = fast_slow((x, y) -> y - x^3 + 3x,      # anonymous-function (λ) form
                            (x, y) -> -x,                # arrow (->) expression
                            0.1, 0.1)

# ---------------------------------------------------------------------------
# Q1 §4  Change is sequenced:  A -> B -> C  vs  C -> A -> B
# Order matters even with the same elements.
# ---------------------------------------------------------------------------

apply_sequence(x0, fs...) = foldl(|>, fs; init = x0)     # varargs + foldl + pipe as value

A(x) = x + 1;  B(x) = 2x;  C(x) = x^2                    # multiple defs on one line via `;`

# same elements, different outcomes — demonstrating sequencing:
seq1() = apply_sequence(1.0, A, B, C)                    # A→B→C : ((1+1)*2)^2 = 16
seq2() = apply_sequence(1.0, C, A, B)                    # C→A→B : ((1^2)+1)*2 = 4

# composition operator form (right-to-left):
seq1_composed = C ∘ B ∘ A                                # function-composition expression

# ---------------------------------------------------------------------------
# Q1 §5  Tendency landscape:   dx/dt = -∇V(x)
# Valleys = attractive states; ridges separate alternatives.
# ---------------------------------------------------------------------------

"Double-well tendency landscape V(x) = x⁴/4 − x²/2 (two valleys, one ridge)."
V(x) = x^4 / 4 - x^2 / 2
∇V(x) = x^3 - x                                          # Unicode identifier expression

gradient_flow(x; dt = 0.01) = x - dt * ∇V(x)             # one Euler step

"Descend the landscape until change is negligible (while-loop form)."
function settle(x; dt = 0.01, tol = 1e-10)
    while abs(∇V(x)) > tol                               # `while` expression
        x = gradient_flow(x; dt)
    end
    x                                                    # implicit return (last expression)
end

# Self-modifying landscape:  dx/dt = F(x,V);  dV/dt = G(x,V)
# The state changes within a landscape while activity reshapes the landscape.
mutable struct Landscape                                 # mutable struct form
    depth::Float64                                       # channel deepened by passage
end

function coupled_step!(x, L::Landscape; dt = 0.01)
    dx = -(x^3 - L.depth * x)                            # motion in current landscape
    L.depth += dt * 0.1 * abs(x)                         # repeated passage deepens channel
    x + dt * dx
end

# ---------------------------------------------------------------------------
# Q1 §6  Feedback gives change direction
#   counteracting: deviation -> corrective response -> reduced deviation
#   reinforcing:   change -> amplification -> more change
# ---------------------------------------------------------------------------

counteracting(x, target; k = 1.0) = -k * (x - target)    # negative feedback
reinforcing(x; r = 1.0)           = +r * x               # positive feedback

"Organized change alternates stabilization and controlled transition."
function feedback_regime(x, mode::Symbol)
    mode === :counteract && return counteracting(x, 0.0) # short-circuit && form
    mode === :reinforce  && return reinforcing(x)
    error("too much counteraction → rigidity; too much reinforcement → runaway")
end

# ---------------------------------------------------------------------------
# Q1 §7  Anticipation:  predicted disturbance -> preparation -> reduced disruption
# ---------------------------------------------------------------------------

"Anticipatory regulation: act on the predicted future, not just the present."
anticipate(x, predict::Function; horizon = 1.0) =
    let x̂ = predict(x, horizon)                          # `let` block expression
        x - 0.5 * (x̂ - x)                                # prepare against predicted deviation
    end

# ---------------------------------------------------------------------------
# Q1 §8  Memory:   x(t+Δt) = F(x(t), H_t)   — history alters future rules
# ---------------------------------------------------------------------------

"History-dependent dynamics via a closure that carries H_t (closure form)."
function with_memory(F2; capacity = 50)
    H = Float64[]                                        # captured history H_t
    return function (x)                                  # anonymous `function` form
        push!(H, x)
        length(H) > capacity && popfirst!(H)
        F2(x, mean(H))                                   # next state depends on trajectory
    end
end

# ---------------------------------------------------------------------------
# Q1 §9  Thresholds:   stable regime -> threshold -> new regime
# ---------------------------------------------------------------------------

"Below threshold: compensate. Beyond it: reorganize.  (if/elseif/else form)"
function regime(x; θ = 1.0)
    if abs(x) < θ
        :stable_regime
    elseif abs(x) == θ
        :threshold
    else
        :new_regime
    end
end

# ---------------------------------------------------------------------------
# Q1 §10 Restoration is a sequence of temporary organizations (pipeline form)
# ---------------------------------------------------------------------------

const RESTORATION = [
    :isolate_disturbance, :remove_unusable_structure, :redirect_capacity,
    :rebuild_boundaries,  :restore_coupling,          :rejoin_larger_dynamics,
]

"Each stage changes conditions for the next; a regime must be exited on time."
restore(state) = foldl((s, stage) -> merge(s, Dict(stage => :done)),
                       RESTORATION; init = state)

# ---------------------------------------------------------------------------
# Q1 §11 Repertoire:   R(x) = {viable transformations accessible from x}
# Identity = preserved capacity, not current state.
# ---------------------------------------------------------------------------

"Set-comprehension form: the accessible repertoire from state x."
R(x, transforms, viable) = Set(t for t in transforms if viable(t(x)))

"Failure appears as narrowing of the repertoire."
narrowed(R1::Set, R2::Set) = length(R2) < length(R1)

# ---------------------------------------------------------------------------
# Q1 §12 Three levels of change (abstract-type + dispatch form)
# ---------------------------------------------------------------------------

abstract type LevelOfChange end
struct StateChange        <: LevelOfChange end           # change of state
struct ParameterChange    <: LevelOfChange end           # change of transition rules
struct OrganizationChange <: LevelOfChange end           # change of how regulation is arranged

describe(::StateChange)        = "change of state"
describe(::ParameterChange)    = "change of parameters governing state transitions"
describe(::OrganizationChange) = "change in how regulation itself is arranged"

# ---------------------------------------------------------------------------
# Q1 §13 Organization is relational:  A regulates B; B restores C; C constrains A
# ---------------------------------------------------------------------------

const RELATIONAL_LOOP = Dict(:A => (:regulates, :B),
                             :B => (:restores,  :C),
                             :C => (:constrains, :A))

"Persistence lies in the regeneration of relations (recursion form)."
function loop_closes(g::Dict, start; node = start, seen = Symbol[])
    node ∈ seen && return node == start                  # recursion terminates on revisit
    loop_closes(g, start; node = g[node][2], seen = [seen; node])
end

# Conservative vs transformative change:
conservative(x, disturb) = x                             # disturbance → return/compensation
transformative(x, disturb) = disturb(x)                  # old org → transition → new org

# ---------------------------------------------------------------------------
# Q1 compact formulation — five interlocking structures (NamedTuple map)
# ---------------------------------------------------------------------------

const FIVE_STRUCTURES = (
    Constraints  = "what may change",
    Coordination = "what must change together",
    Timing       = "when and how quickly change occurs",
    Feedback     = "how consequences redirect change",
    Memory       = "how past change alters future possibility",
)

#=============================================================================
 Q2 — TYPES OF ORGANIZATION UNDER DISTURBANCE
   ΔC = C_after_recovery − C_before_disturbance
=============================================================================#

ΔC(before, after) = after - before                       # Unicode function name form

"""
Classify organization by disturbance outcome (document's exact taxonomy):

    fragile        ΔC < 0
    robust         ΔC ≈ 0
    antifragile    ΔC > 0
"""
function classify(before, after; tol = 1e-3)
    δ = ΔC(before, after)
    δ < -tol ? :fragile :                                # nested-ternary chain form
    δ >  tol ? :antifragile :
               :robust
end

"Resilience:  C(t): C₀ → C_reduced → C₀  (dip-and-return trace test)."
resilient(trace::Vector) = trace[end] ≈ trace[1] && minimum(trace) < trace[1]

"Adaptive/plastic:  F_θ1(x) → F_θ2(x) — the rules change (parametric closure)."
adapt(F, θ_new) = x -> F(x, θ_new)

"Antifragility is conditional — the document's dose curve (piecewise dispatch):"
dose_response(load) =
    load < 0.2 ? :under_formation :                      # too little disturbance
    load ≤ 0.8 ? :adaptation_or_improvement :            # bounded disturbance
                 :damage_or_collapse                     # excessive disturbance

"Collapse:  x(t) ∉ Ω_viable  (membership-test expression)."
collapsed(x, Ω_viable) = x ∉ Ω_viable

"Transformative:  A -> disruption -> B (neither preserved nor restored)."
struct Regime; name::Symbol end
transform(::Regime, disruption) = Regime(disruption)

# ---------------------------------------------------------------------------
# Q2 Regulatory arrangements
# ---------------------------------------------------------------------------

"Fixed-target restoring regulation:  dx/dt = -k(x - x*)"
fixed_target(x, x★; k = 1.0) = -k * (x - x★)

"Moving-target trajectory regulation:  x(t) ≈ x*(t) — track a course, not a point."
moving_target(x, x★t::Function, t; k = 1.0) = -k * (x - x★t(t))

"Context-adjusted regulation:  x* = x*(e, t, h) — target depends on context."
context_target(e, t, h) = e.baseline + 0.1t + 0.05 * sum(h)

"Metastable regulation:  A₁ ⟷ A₂ ⟷ A₃ — a structured repertoire of regimes."
const METASTABLE = Dict(:A1 => [:A2], :A2 => [:A1, :A3], :A3 => [:A2])
can_transition(from, to) = to ∈ get(METASTABLE, from, Symbol[])

# ---------------------------------------------------------------------------
# Q2 Structural arrangements — one dispatch family (the document's table)
# ---------------------------------------------------------------------------

abstract type Architecture end
struct Hierarchy     <: Architecture end                 # lower → intermediate → higher
struct Heterarchy    <: Architecture end                 # A ⟷ B ⟷ C, context-dependent control
struct Modular       <: Architecture end                 # M₁ | M₂ | M₃
struct Compartmental <: Architecture end                 # Ω₁ ≠ Ω₂
struct Redundant     <: Architecture end                 # A₁, A₂, A₃ → F
struct Degenerate    <: Architecture end                 # A,B,C → F; elsewhere A→G, B→H
struct Distributed   <: Architecture end                 # global pattern = local interactions
struct Fractal       <: Architecture end                 # N(l) ∝ l^(-D)

outcome(::Hierarchy)     = "coordination across scale; risk: bottlenecks, central dependence"
outcome(::Heterarchy)    = "flexible distributed control; risk: coordination conflict"
outcome(::Modular)       = "local change without total reorganization"
outcome(::Compartmental) = "controlled coexistence of incompatible processes"
outcome(::Redundant)     = "reliability; risk: shared vulnerability of identical backups"
outcome(::Degenerate)    = "robustness + adaptability without identical copies"
outcome(::Distributed)   = "graceful degradation; risk: slow global coordination"
outcome(::Fractal)       = "scaling describes form, NOT resilience"

"Fractal scaling law  N(l) ∝ l^(−D): estimate D by log-log regression."
function scaling_dimension(l::Vector, N::Vector)
    X = [ones(length(l)) log.(l)]                        # matrix-literal expression
    β = X \ log.(N)                                      # backslash solve expression
    -β[2]                                                # D
end

"Redundancy:  A₁, A₂, A₃ → F — any survivor performs the role (findfirst form)."
redundant_output(units, failed::Set) =
    (i = findfirst(u -> u ∉ failed, units)) === nothing ? missing : units[i]

"Functional degeneracy: structurally different components, same function here,
different functions elsewhere (Dict-of-functions form)."
const DEGENERACY = Dict(
    :normal => Dict(:A => :F, :B => :F, :C => :F),       # A,B,C → F
    :other  => Dict(:A => :G, :B => :H, :C => :F),       # under other conditions
)
role(component, condition) = DEGENERACY[condition][component]

"Convergent outcome:  x₁, x₂, x₃ → A  (map-to-constant expression)."
converge(states) = map(_ -> :A, states)

"Conditional differentiation:  x → A when e = e₁;  x → B when e = e₂."
differentiate(x, e) = e === :e1 ? :A : e === :e2 ? :B : :undetermined

"Scale-free network caveat: robust to random loss, fragile to hub loss."
function hub_fragility(degrees::Vector{Int})
    hubs = count(>(quantile(float.(degrees), 0.9)), degrees)
    (random_loss = :tolerated, hub_loss = hubs > 0 ? :critical : :none)
end

# ---------------------------------------------------------------------------
# Q2 "Antifragile to disturbance S over [S₁,S₂] on timescale T" — never abstract
# ---------------------------------------------------------------------------

struct AntifragileClaim{S}                               # parametric struct form
    disturbance::S
    range::Tuple{Float64,Float64}
    timescale::Float64
end

Base.show(io::IO, a::AntifragileClaim) = print(io,       # method-extension form
    "antifragile to $(a.disturbance) over $(a.range) on timescale $(a.timescale)")

# ---------------------------------------------------------------------------
# The unified map (document's closing table of Q2)
# ---------------------------------------------------------------------------

const UNIFIED_MAP = [
    "Resistance to displacement"  => :Robustness,        # Pair-literal expressions
    "Return after displacement"   => :Resilience,
    "Contextual adjustment"       => :Adaptation,
    "Improved future capacity"    => :Antifragility,
    "A new viable regime"         => :Transformation,
    "Loss of self-maintenance"    => :Collapse,
]

# ---------------------------------------------------------------------------
# Demonstration entry point
# ---------------------------------------------------------------------------

function demo()
    println("── Part 1: The Organization of Change ──")

    c  = Organization([1.0, 1.0, 0.0], [-0.5 0.1 0.0; 0.1 -0.5 0.0; 0.0 0.0 -1.0])
    e  = (drive = [0.1, 0.0, 0.0],)
    tr = evolve([1.0, -1.0, 0.5], e, c; steps = 200)
    println("dx/dt = F(x,e,c): x(0)=", first(tr), " → x(T)=", round.(last(tr); digits=3),
            "   (masked dim 3 pinned by organization)")

    println("selective change x∈Ω: ", selective((0.5, 0.05), values(Ω)))
    println("coordination 99 ⊜ 100: ", 99.0 ⊜ 100.0, ";  50 ⊜ 100: ", 50.0 ⊜ 100.0)

    fs = demo_fastslow()
    println("fast/slow: fast range=", round(maximum(fs.fast)-minimum(fs.fast); digits=2),
            "  slow range=", round(maximum(fs.slow)-minimum(fs.slow); digits=2))

    println("sequencing A→B→C = ", seq1(), "  vs  C→A→B = ", seq2(),
            "  (composed: ", seq1_composed(1.0), ")")

    println("gradient flow settles: x₀=0.3 → ", round(settle(0.3); digits=6),
            " ;  x₀=-0.3 → ", round(settle(-0.3); digits=6), "  (two valleys)")

    mem = with_memory((x, h̄) -> 0.5x + 0.5h̄)
    println("memory rule (same input, different history): ",
            round(mem(1.0); digits=3), " then ", round(mem(1.0); digits=3))

    println("regimes: ", regime(0.5), " | ", regime(1.0), " | ", regime(2.0))

    viable(x) = abs(x) < 10
    rep = R(1.0, [A, B, C], viable)
    println("repertoire R(x): ", length(rep), " viable transformations accessible")

    println("relational loop closes: ", loop_closes(RELATIONAL_LOOP, :A))

    for lvl in (StateChange(), ParameterChange(), OrganizationChange())
        println("  level: ", describe(lvl))
    end

    println("\n── Q2: outcomes under disturbance ──")
    for (b, a) in [(1.0, 0.7), (1.0, 1.0), (1.0, 1.3)]
        println("  C: $b → $a  ⇒  ", classify(b, a))
    end
    println("resilient dip-and-return: ", resilient([1.0, 0.4, 0.7, 1.0]))
    println("dose curve: ", dose_response(0.1), " | ", dose_response(0.5),
            " | ", dose_response(0.95))
    println(AntifragileClaim(:load, (0.2, 0.8), 30.0))

    D = scaling_dimension([1.0, 2.0, 4.0, 8.0], [64.0, 16.0, 4.0, 1.0])
    println("fractal N(l) ∝ l^(-D): estimated D = ", round(D; digits=3))

    println("degeneracy: role(A,normal)=", role(:A, :normal),
            "  role(A,other)=", role(:A, :other))

    for arch in (Hierarchy(), Modular(), Fractal())
        println("  ", nameof(typeof(arch)), ": ", outcome(arch))
    end

    println("\nUnified map:")
    foreach(p -> println("  ", p.first, " ⇒ ", p.second), UNIFIED_MAP)
    return nothing
end

end # module

OrganizedChange.demo()
