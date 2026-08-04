#=============================================================================
 Part 2 — PROJECTION, OBSERVATION, AND MULTI-OBSERVER TRIANGULATION
 Julia translation of Questions 3 & 4:
   "How can one level project into another when the geometry of observation
    is not the geometry of the system?"
   "Can a coordinated family of observations reduce projection blindness?"

 The detailed system lives in a rich state space X; observers describe it
 through reduced spaces Y via projections π. Every formula in the source is
 rendered as executable Julia, again ranging across Julia's expression forms.
=============================================================================#

module ProjectionObservation

using LinearAlgebra, Statistics, Random

# ---------------------------------------------------------------------------
# Q3 §0   x ∈ X;  y = π(x) ∈ Y
# ---------------------------------------------------------------------------

"A projection π: X → Y (measurement, averaging, categorization, reduction)."
π₁(x::Vector) = x[1]                                     # keep first coordinate only
π₂(x::Vector) = mean(x)                                  # averaging projection
π₃(x::Vector) = x[1] < 0.5 ? :A : :B                     # categorizing projection

# ---------------------------------------------------------------------------
# Q3 §1  Many-to-one:  π(x₁) = π(x₂) = y ;  fiber π⁻¹(y) = {x ∈ X : π(x) = y}
# ---------------------------------------------------------------------------

"The fiber (preimage): the set hidden behind one observation.
Filter-comprehension form over a sampled state cloud."
fiber(π, y, X̂; tol = 1e-9) = [x for x in X̂ if isapprox(π(x), y; atol = tol)]

"Observational equivalence without dynamical equivalence (predicate form)."
obs_equivalent(π, x1, x2)  = π(x1) == π(x2)
dyn_equivalent(F, x1, x2)  = F(x1) == F(x2)

# ---------------------------------------------------------------------------
# Q3 §2  The decisive test — does the macrostate predict its own future?
#   dx/dt = F(x);   dy/dt = Dπ_x F(x);   want ∃G: dy/dt = G(y)
#   Failure: π(x₁)=π(x₂) but Dπ_x₁F(x₁) ≠ Dπ_x₂F(x₂)
# ---------------------------------------------------------------------------

"Detailed flow F on X (here: rotation + shear that mixes hidden coordinates)."
F(x) = [-x[2], x[1] - 0.3x[2]]

"Dπ·F for the coordinate projection π₁: projected velocity of the macrostate."
Dπ₁F(x) = F(x)[1]

"""Test whether one fiber carries a single projected velocity.
If states in the same fiber have different projected velocities, the same
observed macrostate leads to different futures — the projection discarded
variables needed for prediction."""
function macrostate_autonomous(π, DπF, X̂; ytol = 1e-2, vtol = 1e-2)
    for x1 in X̂, x2 in X̂                                 # multi-iterator for form
        if abs(π(x1) - π(x2)) < ytol && abs(DπF(x1) - DπF(x2)) > vtol
            return false, (x1, x2)                       # multiple-return-values form
        end
    end
    true, nothing
end

# ---------------------------------------------------------------------------
# Q3 §3  A good coarse-graining approximately commutes:  π∘F_t ≈ G_t∘π
# ---------------------------------------------------------------------------

"Evolve then project vs project then evolve; report the commutation defect."
function commutation_defect(Ft, Gt, π, x; t = 1.0)
    lhs = π(Ft(x, t))                                    # evolve in X, then project
    rhs = Gt(π(x), t)                                    # project, then evolve in Y
    abs(lhs - rhs)                                       # defect ≈ 0 ⇒ reduced autonomy
end

# a system where averaging DOES commute: uniform contraction ẋ = -x
Ft_contract(x, t) = exp(-t) .* x
Gt_contract(y, t) = exp(-t) * y                          # the reduced rule G exists

# ---------------------------------------------------------------------------
# Q3 §4  Lost dimensions create apparent intersections
#   π(x₁) = π(x₂) although x₁ ≠ x₂ — the crossing exists only in observation space
# ---------------------------------------------------------------------------

"Two separated 3-D trajectories whose 2-D shadows cross (array comprehension)."
function shadow_crossing(; n = 400)
    ts    = range(0, 2π; length = n)
    path1 = [[cos(t), sin(t),  1.0] for t in ts]         # z = +1 plane
    path2 = [[cos(t + π), sin(t + π), -1.0] for t in ts] # z = −1 plane
    shadow(p) = (p[1], p[2])                             # π: drop z (nested function form)
    crossings = [(a, b) for a in path1, b in path2       # 2-D generator w/ filter
                 if hypot(shadow(a)[1]-shadow(b)[1], shadow(a)[2]-shadow(b)[2]) < 2e-2]
    seperated3D = all(norm(a - b) > 1.9 for (a, b) in crossings)
    (n_apparent_crossings = length(crossings), truly_separate_in_3D = seperated3D)
end

# ---------------------------------------------------------------------------
# Q3 §5  A plot need not preserve the system's geometry
#   d_X(x₁,x₂) ≪ 1 while d_Y(π(x₁),π(x₂)) ≫ 1  (or the reverse)
# ---------------------------------------------------------------------------

d_X(x1, x2) = norm(x1 - x2)                              # geometry of the system
d_Y(π, x1, x2) = abs(π(x1) - π(x2))                      # geometry of display

"Metric distortion ratio between system geometry and observed geometry."
distortion(π, x1, x2) = d_Y(π, x1, x2) / max(d_X(x1, x2), eps())

# ---------------------------------------------------------------------------
# Q3 §6  Continuous processes appear as discrete categories
#   C(z) = A if z < 0.5;  C(z) = B if z ≥ 0.5
# ---------------------------------------------------------------------------

C(z) = z < 0.5 ? :A : :B                                 # the observer's threshold rule

"Does a category boundary coincide with a dynamical separatrix, or is it
only a threshold in the description? Compare flows on both sides."
category_is_dynamical(flow, z; δ = 1e-3) =
    sign(flow(z - δ)) != sign(flow(z + δ))               # real basin boundary test

# ---------------------------------------------------------------------------
# Q3 §7  Hidden variables return as memory (path dependence / hysteresis)
#   y₁(t) = y₂(t) but y₁(t+Δt) ≠ y₂(t+Δt);   dy/dt = G(y(t), y(t−τ), …)
# ---------------------------------------------------------------------------

"Non-Markovian reduced law: a delay-differential Euler step (default-arg form)."
function delayed_step(G, ys::Vector; τ_steps::Int = 10, dt = 0.01)
    y, y_delayed = ys[end], ys[max(1, end - τ_steps)]
    y + dt * G(y, y_delayed)                             # history enters the rule
end

"Hysteresis: same observed y now, different futures because of history."
function hysteresis_demo()
    G(y, yτ) = -y + 2yτ                                  # inner named function
    up   = collect(range(0.0, 1.0; length = 30))         # arrived from below
    down = collect(range(2.0, 1.0; length = 30))         # arrived from above
    y_up, y_dn = delayed_step(G, up), delayed_step(G, down)
    (same_present = up[end] == down[end], future_up = y_up, future_down = y_dn,
     futures_differ = y_up != y_dn)
end

# ---------------------------------------------------------------------------
# Q3 §8  Hidden variables appear as randomness:  dy/dt = G(y) + η(t)
# Deterministic detail, stochastic-looking reduction.
# ---------------------------------------------------------------------------

"Unresolved fiber detail rendered as apparent noise η(t)."
function apparent_noise(π, F, X̂fiber; dt = 0.01)
    velocities = map(x -> π(F(x)), X̂fiber)               # map form
    (G_estimate = mean(velocities), η_std = std(velocities))
end

# ---------------------------------------------------------------------------
# Q3 §9  B = Φ(M, N, E, H): higher-level motion is a transformation, not a sum
# ---------------------------------------------------------------------------

"Keyword-argument function form: the same local event yields different
higher-level motion when the organization N, environment E, history H differ."
Φ(M; N = I, E = zero(first(M)), H = zero(first(M))) =
    sum(N * M) + E + 0.1H                                # relational, not additive

# ---------------------------------------------------------------------------
# Q3 §10  x̄ = (1/N)Σxᵢ hides organization:
#   {0,0,10,10} and {5,5,5,5} share a mean, differ in organization
# ---------------------------------------------------------------------------

x̄(xs) = sum(xs) / length(xs)                             # the simple projection

"aggregate state ≠ average component state (NamedTuple comparison)."
function aggregate_vs_average()
    polarized, homogeneous = [0.0, 0, 10, 10], [5.0, 5, 5, 5]
    (same_mean      = x̄(polarized) == x̄(homogeneous),
     variance_polar = var(polarized),                    # organization lives here
     variance_homog = var(homogeneous))
end

# ---------------------------------------------------------------------------
# Q3 §11  Order parameter — a variable no component possesses:
#   P = |(1/N) Σ vᵢ/‖vᵢ‖|
# ---------------------------------------------------------------------------

"Collective alignment P ∈ [0,1]; belongs to the configuration, not to any part."
P(vs::Vector{<:Vector}) = norm(sum(v / norm(v) for v in vs) / length(vs))

# ---------------------------------------------------------------------------
# Q3 §12  Correlations survive the change of scale:  ⟨xᵢxⱼ⟩ ≠ ⟨xᵢ⟩⟨xⱼ⟩
# ---------------------------------------------------------------------------

"Connected correlation: the collective pattern individual magnitudes miss."
corr_connected(xi, xj) = mean(xi .* xj) - mean(xi) * mean(xj)

# ---------------------------------------------------------------------------
# Q3 §13  Aggregation can reverse an apparent relation (Simpson reversal)
# ---------------------------------------------------------------------------

"Projection that removes the stratifying variable reverses the association."
function simpson_reversal()
    g1x, g1y = [1.0, 2, 3], [10.0, 9, 8]                 # within-group slope < 0
    g2x, g2y = [11.0, 12, 13], [30.0, 29, 28]            # within-group slope < 0
    slope(x, y) = cov(x, y) / var(x)
    (within_1 = slope(g1x, g1y), within_2 = slope(g2x, g2y),
     pooled   = slope(vcat(g1x, g2x), vcat(g1y, g2y)))   # sign flips when pooled
end

# ---------------------------------------------------------------------------
# Q3 §14  Useful macrovariables are discovered, not assumed (trait checklist)
# ---------------------------------------------------------------------------

const MACROVARIABLE_CRITERIA = (
    :predictive, :stable_under_irrelevant_change, :observable,
    :causally_meaningful, :approximately_closed, :scale_appropriate,
)

"useful coarse-graining = compression + prediction  (struct + score form)"
struct Macrovariable
    name::Symbol
    satisfies::Vector{Symbol}
end
quality(m::Macrovariable) = length(m.satisfies ∩ collect(MACROVARIABLE_CRITERIA)) /
                            length(MACROVARIABLE_CRITERIA)

# ---------------------------------------------------------------------------
# Q3 §16  Projection can be part of the system:
#   complex condition → action-relevant representation
# ---------------------------------------------------------------------------

"A system's internal projection feeding back into its own dynamics."
function internal_projection_step(x, senses::Function, act::Function)
    y = senses(x)                                        # the system's own π
    act(x, y)                                            # observation participates
end

# ---------------------------------------------------------------------------
# Q3 compact map of projection failures (Dict-literal form)
# ---------------------------------------------------------------------------

const PROJECTION_FAILURES = Dict(
    :many_to_one         => "identical observed states ⇐ different hidden configurations",
    :dimensional_collapse => "intersecting trajectories ⇐ separate paths in higher dimension",
    :thresholding        => "discrete categories ⇐ continuous variation",
    :averaging           => "homogeneous aggregate ⇐ polarized or clustered aggregate",
    :missing_variables   => "randomness ⇐ hidden deterministic structure",
    :missing_history     => "inconsistent response ⇐ path-dependent dynamics",
    :metric_distortion   => "near/distant states ⇐ different underlying relations",
    :removed_context     => "simple direct relation ⇐ context-dependent or reversed relation",
)

# emergence = structured compression that retains consequential relations
emergence(compress, consequential) = compress ∘ consequential   # composed-op definition

#=============================================================================
 Q4 — A COORDINATED FAMILY OF OBSERVATIONS
   Π(x) = (π₁(x), π₂(x), …, π_n(x));  x ∈ ⋂ᵢ πᵢ⁻¹(yᵢ)
=============================================================================#

"Joint observation Π: a tuple-of-projections applied at once (splat/map form)."
Π(x, πs...) = map(πᵢ -> πᵢ(x), πs)                       # varargs + map

"Ambiguity set intersection: several observers shrink the blind region."
function ambiguity_intersection(observations::Vector, X̂; tol = 5e-2)
    consistent(x) = all(abs(πᵢ(x) - yᵢ) < tol for (πᵢ, yᵢ) in observations)
    filter(consistent, X̂)                                # filter-predicate form
end

"Parallax: π₁ identifies x₁,x₂ while π₂ separates them ⇒ π₂ exposes a
coordinate absent from π₁."
parallax(π1, π2, x1, x2; tol=1e-9) =
    isapprox(π1(x1), π1(x2); atol=tol) && !isapprox(π2(x1), π2(x2); atol=tol)

"The average report ȳ = (1/n)Σyᵢ can destroy what matters:
the midpoint may correspond to no real state at all."
naive_average(ys) = sum(ys) / length(ys)

"Observer model:  yᵢ = πᵢ(x; θᵢ) + εᵢ  (struct with a callable-object form)."
struct Observer{P,T}
    π::P                                                 # transformation
    θ::T                                                 # position, scale, expectations
    ε::Float64                                           # noise level
end
(o::Observer)(x) = o.π(x, o.θ) + o.ε * randn()           # functor: instance is callable

# Four kinds of disagreement (enum expression form)
@enum Disagreement measurement perspectival scale_kind primitive_framework

resolve(d::Disagreement) =
    d == measurement          ? "repeat & recalibrate"                        :
    d == perspectival         ? "integrate, do not pick a winner"             :
    d == scale_kind           ? "both valid at their own scales"              :
                                "build a larger framework containing both"

"Consensus can conceal shared blindness: π₁ ≈ π₂ ≈ … ≈ π_n ⇒ correlated error."
shared_blindness(πs, x_hidden) = length(unique(map(π -> π(x_hidden), πs))) == 1

# ---------------------------------------------------------------------------
# Q4 Triangulation questions (const tuple of strings)
# ---------------------------------------------------------------------------

const TRIANGULATION = (
    "What does each observation preserve?",
    "What does each observation erase?",
    "Where do their ambiguity sets overlap?",
    "Where do their predictions diverge?",
    "What additional observation would distinguish the remaining possibilities?",
)

"Seek the next map π_{n+1} for which competing hypotheses predict different
results (argmax-by-discrimination form)."
next_measurement(candidates, hypotheses) =
    argmax(π -> length(unique(map(π, hypotheses))), candidates)

# ---------------------------------------------------------------------------
# Q4 Conditional-probability update:
#   p(x | y₁…y_n) ∝ p(x) Πᵢ p(yᵢ | x)   [only if conditionally independent!]
# ---------------------------------------------------------------------------

"Bayesian fusion over a discrete hypothesis grid (normalize-after-product)."
function fuse(prior::Vector, likelihoods::Vector{<:Vector})
    posterior = copy(prior)
    for L in likelihoods
        posterior .*= L                                  # p(x)·Πᵢ p(yᵢ|x)
    end
    posterior ./ sum(posterior)                          # ∝ becomes = via normalization
end

"Treating correlated observers as independent creates unjustified confidence:
fuse the same likelihood twice vs once and compare sharpness."
function false_confidence_demo(prior, L)
    honest  = fuse(prior, [L])
    doubled = fuse(prior, [L, L])                        # duplicated 'evidence'
    (honest_max = maximum(honest), doubled_max = maximum(doubled),
     overconfident = maximum(doubled) > maximum(honest))
end

# ---------------------------------------------------------------------------
# Q4 Local views and global coherence: glue U_i where they overlap; failure to
# glue is itself informative. (An atlas of overlapping local descriptions.)
# ---------------------------------------------------------------------------

struct LocalChart{Fn}
    region::Tuple{Float64,Float64}                       # U_i
    describe::Fn                                         # local description
end

"Do two charts agree on their overlap? (glue test, try/catch form)"
function glue(a::LocalChart, b::LocalChart; samples = 20)
    lo, hi = max(a.region[1], b.region[1]), min(a.region[2], b.region[2])
    lo ≥ hi && return :no_overlap
    try
        pts = range(lo, hi; length = samples)
        all(isapprox(a.describe(t), b.describe(t); rtol = 1e-6) for t in pts) ?
            :glues : :fails_to_glue                      # failure is informative
    catch err                                            # exception-handling form
        :incompatible_coordinates
    end
end

# ---------------------------------------------------------------------------
# Q4 The collective observer is another projection:  Σ: Y₁×…×Y_n → Z
# ---------------------------------------------------------------------------

"A synthesis map that PRESERVES structure rather than forcing consensus:
M = {shared invariants, perspective-specific, conflicts, uncertainties, missing}."
function Σ(reports::Dict{Symbol,<:Any})
    vals = collect(values(reports))
    Dict(
        :shared_invariants    => length(unique(vals)) == 1 ? vals[1] : nothing,
        :perspective_specific => reports,                # provenance preserved
        :conflicts            => length(unique(vals)) > 1,
        :uncertainties        => :tracked,
        :missing_observations => setdiff([:π1, :π2, :π3, :π4], keys(reports)),
    )
end

"failure of model A + failure of model B → search for coupling between A and B"
generative_boundary(failA::Bool, failB::Bool) =
    failA && failB ? :search_for_coupling : :models_sufficient

# ---------------------------------------------------------------------------
# Demonstration
# ---------------------------------------------------------------------------

function demo()
    Random.seed!(42)
    println("── Part 2: Projection & Observation ──")

    X̂ = [randn(2) for _ in 1:400]                        # sampled detailed states
    fib = fiber(π₁, 0.0, X̂; tol = 0.1)
    println("fiber π₁⁻¹(0): ", length(fib), " hidden states behind one observation")

    auto, witness = macrostate_autonomous(π₁, Dπ₁F, X̂[1:60])
    println("macrostate autonomous under π₁? ", auto,
            auto ? "" : "  (same y, different projected velocities ⇒ hidden variable)")

    def = commutation_defect(Ft_contract, Gt_contract, π₂, [1.0, 2.0, 3.0])
    println("commutation π∘F_t ≈ G_t∘π defect (contraction+mean): ", round(def; digits=12))

    sc = shadow_crossing()
    println("lost dimension: ", sc.n_apparent_crossings, " apparent 2-D crossings; ",
            "separate in 3-D: ", sc.truly_separate_in_3D)

    println("threshold C(0.49)=", C(0.49), " C(0.51)=", C(0.51),
            " — dynamical boundary? ", category_is_dynamical(z -> z - 0.5, 0.5))

    h = hysteresis_demo()
    println("hysteresis: same present=", h.same_present,
            ", futures differ=", h.futures_differ,
            "  (", round(h.future_up; digits=4), " vs ", round(h.future_down; digits=4), ")")

    fibcloud = [[0.0, z] for z in randn(200)]
    η = apparent_noise(π₁, F, fibcloud)
    println("hidden detail as noise: dy/dt ≈ G(y)+η,  std(η) = ", round(η.η_std; digits=3))

    agg = aggregate_vs_average()
    println("aggregate ≠ average: same mean=", agg.same_mean,
            "; var ", agg.variance_polar, " vs ", agg.variance_homog)

    aligned  = [[1.0, 0.0] for _ in 1:50]
    scattered = [[cos(θ), sin(θ)] for θ in 2π .* rand(50)]
    println("order parameter P: aligned=", round(P(aligned); digits=3),
            "  scattered=", round(P(scattered); digits=3))

    s = simpson_reversal()
    println("aggregation reversal: within-group slopes ",
            round(s.within_1; digits=2), ", ", round(s.within_2; digits=2),
            " → pooled ", round(s.pooled; digits=2))

    m = Macrovariable(:collective_alignment,
                      [:predictive, :observable, :approximately_closed, :causally_meaningful])
    println("macrovariable quality(", m.name, ") = ", quality(m))

    println("\n── Q4: coordinated observation ──")
    x_true = [0.3, -0.7]
    X̂2 = vcat(X̂, [x_true])                               # ensure the true state is in the cloud
    only_first  = ambiguity_intersection([(π₁, π₁(x_true))], X̂2; tol = 0.15)
    both_views  = ambiguity_intersection([(π₁, π₁(x_true)),
                                          ((x -> x[2]), x_true[2])], X̂2; tol = 0.15)
    println("ambiguity set: ", length(X̂2), " states → ", length(only_first),
            " (one observer) → ", length(both_views), " (two observers intersected)")

    println("parallax exposes hidden coordinate: ",
            parallax(π₁, x -> x[2], [0.5, 1.0], [0.5, -1.0]))

    println("naive average of opposing reports [-1,+1] = ", naive_average([-1.0, 1.0]),
            "  (may correspond to no real state)")

    for d in instances(Disagreement)
        println("  ", d, " → ", resolve(d))
    end

    prior = fill(1/5, 5)
    L = [0.05, 0.1, 0.6, 0.2, 0.05]
    fc = false_confidence_demo(prior, L)
    println("correlated observers double-counted: honest max p=",
            round(fc.honest_max; digits=3), " → inflated ",
            round(fc.doubled_max; digits=3), " (overconfident=", fc.overconfident, ")")

    chartA = LocalChart((0.0, 2.0), t -> sin(t))
    chartB = LocalChart((1.0, 3.0), t -> sin(t))
    chartC = LocalChart((1.0, 3.0), t -> cos(t))
    println("atlas glue A~B: ", glue(chartA, chartB), " | A~C: ", glue(chartA, chartC))

    synth = Σ(Dict(:π1 => 0.4, :π2 => 0.4, :π3 => 0.9))
    println("synthesis preserves disagreement: conflicts=", synth[:conflicts],
            ", missing=", synth[:missing_observations])

    println("generative boundary: ", generative_boundary(true, true))
    println("\nProjection failure map:")
    foreach(kv -> println("  ", kv.first, ": ", kv.second),
            sort(collect(PROJECTION_FAILURES); by = first))
    nothing
end

end # module

ProjectionObservation.demo()
