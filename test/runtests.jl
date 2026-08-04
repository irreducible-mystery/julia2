#=============================================================================
 test/runtests.jl — Test-stdlib suite for the julia2 translation

 Claimed from the repo's open ledger: item 4 ("Test-stdlib suite", unclaimed
 at F_2 — see metadata/field_state_log.json). Authored by a fourth instance.
 Provenance: the correlated-observer caveat applies — this suite was written
 by an instance of the same model family that produced the sources, so
 agreement here is internal consistency, not independent verification
 (cf. Part 2 `shared_blindness`, Part 3 `dependence_profile`).

 Standard library only (Test).  Run:  julia test/runtests.jl
 A failed testset throws at top level, so the script exits nonzero on failure.

 Method: each Part is include()d (its demo runs; the printed demonstration
 output is captured and discarded), then every claim the demo prints
 informally is re-derived here as an explicit @test against the functions
 the Part defines.
=============================================================================#

using Test

const SRC = normpath(joinpath(@__DIR__, "..", "src"))

"Include a demo script while discarding its printed demonstration output."
function include_quiet(path)
    old = stdout
    rd, wr = redirect_stdout()
    drain = @async read(rd, String)          # keep the pipe drained (no deadlock)
    try
        include(path)
    finally
        redirect_stdout(old)
        close(wr)
    end
    fetch(drain)
end

include_quiet(joinpath(SRC, "Part1_OrganizedChange.jl"))
include_quiet(joinpath(SRC, "Part2_ProjectionObservation.jl"))
include_quiet(joinpath(SRC, "Part3_GenerativeField.jl"))
include_quiet(joinpath(SRC, "Part4_ExpressionCatalog.jl"))

const P1 = OrganizedChange
const P2 = ProjectionObservation
const P3 = GenerativeField
const P4 = ExpressionCatalog

@testset "julia2 field invariants" begin

# ═══════════════════════════════════════════════════════════════════════════
@testset "Part 1 — the organization of change" begin
    # §5 gradient flow descends the tendency landscape: V decreases along -∇V
    let x = 0.3, Vs = Float64[P1.V(x)]
        for _ in 1:200
            x = P1.gradient_flow(x)
            push!(Vs, P1.V(x))
        end
        @test all(<(0), diff(Vs))                       # strictly downhill, every step
    end
    # ∇V really is the gradient of V (finite-difference cross-check)
    fd(x; h = 1e-6) = (P1.V(x + h) - P1.V(x - h)) / 2h
    @test isapprox(P1.∇V(0.7), fd(0.7); atol = 1e-6)
    @test isapprox(P1.∇V(-1.6), fd(-1.6); atol = 1e-5)
    # double well: two valleys at ±1 below the ridge at 0; basins select the valley
    @test isapprox(P1.settle(0.3), 1.0; atol = 1e-3)
    @test isapprox(P1.settle(-0.3), -1.0; atol = 1e-3)
    @test P1.settle(0.3) > 0 > P1.settle(-0.3)
    @test P1.V(1.0) < P1.V(0.0) && P1.V(-1.0) < P1.V(0.0)

    # §0 structured flow dx/dt = F(x,e,c): the organization's mask pins dim 3
    c = P1.Organization([1.0, 1.0, 0.0],
                        [-0.5 0.1 0.0; 0.1 -0.5 0.0; 0.0 0.0 -1.0])
    e = (drive = [0.1, 0.0, 0.0],)
    tr = P1.evolve([1.0, -1.0, 0.5], e, c; steps = 200)
    @test last(tr)[3] == 0.5                            # forbidden direction never moves
    @test last(tr)[1] != 1.0                            # permitted directions do move
    @test all(all(abs.(v) .< 10) for v in tr)           # stable coupling ⇒ bounded flow

    # §1 selective change: broad vs narrow admissible regions Ω_i
    @test P1.selective((0.5, 0.05), values(P1.Ω))
    @test !P1.selective((0.5, 0.5), values(P1.Ω))       # narrow Ω rejects

    # §2 coordination: supplied ≈ required within 5%
    @test (P1.:⊜)(99.0, 100.0)
    @test !(P1.:⊜)(50.0, 100.0)
    @test P1.coordinated(95.0, 100.0)                   # exactly at tolerance

    # §4 sequencing: same elements, different order, different outcome
    @test P1.seq1() == 16.0                             # A→B→C
    @test P1.seq2() == 4.0                              # C→A→B
    @test P1.seq1() != P1.seq2()
    @test P1.seq1_composed(1.0) == P1.seq1()            # ∘ agrees with the pipeline

    # §3 nested clocks: the ε-slow variable moves less than the fast one
    fs = P1.demo_fastslow()
    @test (maximum(fs.fast) - minimum(fs.fast)) > (maximum(fs.slow) - minimum(fs.slow))

    # §8 memory: same input, different history ⇒ different next state
    mkmem() = P1.with_memory((x, h̄) -> 0.5x + 0.5h̄)
    mem_primed, mem_fresh = mkmem(), mkmem()
    a = (mem_primed(1.0); mem_primed(0.0))              # history [1.0, 0.0]
    b = mem_fresh(0.0)                                  # history [0.0]
    @test a ≈ 0.25 && b == 0.0
    @test a != b
    # NOTE: the demo's own probe (1.0 twice) prints 1.0 both times — the mean
    # never moves — so the printed line does not exhibit the effect; this does.

    # §9 thresholds: compensate below θ, reorganize beyond it (θ on |x|)
    @test P1.regime(0.5) === :stable_regime
    @test P1.regime(1.0) === :threshold
    @test P1.regime(2.0) === :new_regime
    @test P1.regime(-2.0) === :new_regime

    # §11 repertoire R(x): failure appears as narrowing
    R1 = P1.R(1.0, [P1.A, P1.B, P1.C], x -> abs(x) < 10)
    R2 = P1.R(3.0, [P1.A, P1.B, P1.C], x -> abs(x) < 5)
    @test length(R1) == 3                               # all of A,B,C viable from x=1
    @test length(R2) == 1                               # only A survives from x=3
    @test P1.narrowed(R1, R2)
    @test !P1.narrowed(R1, R1)

    # §13 the relational loop A→B→C→A regenerates itself
    @test P1.loop_closes(P1.RELATIONAL_LOOP, :A)

    # Q2: ΔC classification — the document's exact taxonomy
    @test P1.classify(1.0, 0.7) === :fragile
    @test P1.classify(1.0, 1.0) === :robust
    @test P1.classify(1.0, 1.3) === :antifragile
    @test P1.classify(1.0, 1.0 + 5e-4) === :robust     # inside the tolerance band
    @test P1.ΔC(1.0, 1.3) ≈ 0.3

    # resilience = dip AND return, not either alone
    @test P1.resilient([1.0, 0.4, 0.7, 1.0])
    @test !P1.resilient([1.0, 1.1, 1.2, 1.0])           # no dip
    @test !P1.resilient([1.0, 0.4, 0.6, 0.6])           # no return

    # antifragility is conditional: the dose curve
    @test P1.dose_response(0.1) === :under_formation
    @test P1.dose_response(0.5) === :adaptation_or_improvement
    @test P1.dose_response(0.95) === :damage_or_collapse

    # fractal scaling N(l) ∝ l^(-D): exponent recovery by log-log regression
    @test isapprox(P1.scaling_dimension([1.0, 2.0, 4.0, 8.0],
                                        [64.0, 16.0, 4.0, 1.0]), 2.0; rtol = 1e-10)
    let D₀ = 1.7, ls = [1.0, 2.0, 4.0, 8.0, 16.0]
        @test isapprox(P1.scaling_dimension(ls, 5.0 .* ls .^ (-D₀)), D₀; rtol = 1e-8)
    end

    # scale-free caveat: robust to random loss, fragile to hub loss
    @test P1.hub_fragility([1, 1, 1, 1, 10]).hub_loss === :critical
    @test P1.hub_fragility([3, 3, 3, 3]).hub_loss === :none
    @test P1.hub_fragility([1, 1, 1, 1, 10]).random_loss === :tolerated

    # metastability: a structured repertoire of regimes, not free transit
    @test P1.can_transition(:A1, :A2)
    @test !P1.can_transition(:A1, :A3)
    @test P1.can_transition(:A2, :A3)

    # redundancy: any survivor performs the role; none left ⇒ missing
    @test P1.redundant_output([:A1, :A2, :A3], Set([:A1])) === :A2
    @test P1.redundant_output([:A1, :A2, :A3], Set([:A1, :A2, :A3])) === missing

    # degeneracy: same function here, different functions elsewhere
    @test P1.role(:A, :normal) === :F && P1.role(:B, :normal) === :F
    @test P1.role(:A, :other) === :G

    # convergence / conditional differentiation
    @test P1.converge([1, 2, 3]) == [:A, :A, :A]
    @test P1.differentiate(0.0, :e1) === :A
    @test P1.differentiate(0.0, :e2) === :B
    @test P1.differentiate(0.0, :e3) === :undetermined

    # restoration pipeline: all six temporary organizations completed
    done = P1.restore(Dict{Symbol,Symbol}())
    @test length(done) == 6 && all(==(:done), values(done))

    # §6 feedback direction: counteracting opposes, reinforcing amplifies
    @test P1.counteracting(2.0, 0.0) == -2.0
    @test P1.counteracting(-2.0, 0.0) == 2.0
    @test P1.reinforcing(2.0) == 2.0
    @test P1.feedback_regime(2.0, :counteract) == -2.0
    @test_throws ErrorException P1.feedback_regime(2.0, :runaway)

    # §7 anticipation acts against the predicted deviation
    @test P1.anticipate(2.0, (x, h) -> x + h) == 1.5

    # §5 self-modifying landscape: passage deepens the channel
    L = P1.Landscape(1.0)
    x1 = P1.coupled_step!(2.0, L)
    @test L.depth > 1.0
    @test x1 < 2.0                                      # and the state still descends

    # conservative vs transformative change
    @test P1.conservative(1.0, x -> x + 5) == 1.0
    @test P1.transformative(1.0, x -> x + 5) == 6.0

    # collapse: x ∉ Ω_viable
    @test P1.collapsed(11.0, -10.0:1.0:10.0)
    @test !P1.collapsed(5.0, -10.0:1.0:10.0)

    # three distinct levels of change under dispatch
    @test length(Set([P1.describe(P1.StateChange()),
                      P1.describe(P1.ParameterChange()),
                      P1.describe(P1.OrganizationChange())])) == 3
end

# ═══════════════════════════════════════════════════════════════════════════
@testset "Part 2 — projection, observation, triangulation" begin
    grid = [[i / 10, j / 10] for i in -10:10 for j in -10:10]   # 441 detailed states

    # §1 many-to-one: one observation hides many distinct states (the fiber)
    fib = P2.fiber(P2.π₁, 0.0, grid; tol = 1e-6)
    @test length(fib) == 21
    @test all(x -> x[1] == 0.0, fib)                    # all project to the same y
    @test length(unique(x -> x[2], fib)) == 21          # yet all dynamically distinct
    x1, x2 = [0.5, 1.0], [0.5, -1.0]
    @test P2.obs_equivalent(P2.π₁, x1, x2)
    @test !P2.dyn_equivalent(P2.F, x1, x2)              # observational ≠ dynamical equivalence

    # §2 the decisive test: does the macrostate predict its own future?
    cloud = [[0.0, -1.0], [0.0, 1.0], [0.5, 0.5]]
    auto, witness = P2.macrostate_autonomous(P2.π₁, P2.Dπ₁F, cloud)
    @test auto == false                                 # π₁ discards a needed variable
    @test witness !== nothing
    w1, w2 = witness
    @test abs(P2.π₁(w1) - P2.π₁(w2)) < 1e-2 && abs(P2.Dπ₁F(w1) - P2.Dπ₁F(w2)) > 1e-2
    auto2, witness2 = P2.macrostate_autonomous(P2.π₁, x -> -x[1], cloud)
    @test auto2 == true && witness2 === nothing         # velocity a function of y ⇒ ∃G

    # §3 commutation π∘F_t ≈ G_t∘π: contraction+mean commutes, nonlinearity breaks it
    @test P2.commutation_defect(P2.Ft_contract, P2.Gt_contract,
                                P2.π₂, [1.0, 2.0, 3.0]) < 1e-10
    @test P2.commutation_defect((x, t) -> x .^ 2, (y, t) -> y^2,
                                P2.π₂, [1.0, 2.0, 3.0]) > 0.5

    # §4 lost dimensions create apparent intersections
    sc = P2.shadow_crossing()
    @test sc.n_apparent_crossings > 0                   # shadows cross…
    @test sc.truly_separate_in_3D                       # …the 3-D paths never do

    # §6 thresholding: continuous process, discrete category
    @test P2.C(0.49) === :A && P2.C(0.51) === :B
    @test P2.C(0.5) === :B                              # boundary convention z ≥ 0.5 ⇒ B
    @test P2.category_is_dynamical(z -> z - 0.5, 0.5)   # real separatrix at the boundary
    @test !P2.category_is_dynamical(z -> 1.0, 0.5)      # threshold only in the description

    # §7 hidden variables return as memory (hysteresis)
    h = P2.hysteresis_demo()
    @test h.same_present && h.futures_differ
    @test h.future_down > h.future_up                   # arrived-from-above stays higher

    # §8 hidden deterministic detail appears as noise
    η = P2.apparent_noise(P2.π₁, P2.F, [[0.0, z] for z in [-1.0, 0.0, 1.0]])
    @test isapprox(η.G_estimate, 0.0; atol = 1e-12)
    @test isapprox(η.η_std, 1.0; rtol = 1e-12)          # deterministic, yet σ > 0 observed

    # §10 the average hides organization
    agg = P2.aggregate_vs_average()
    @test agg.same_mean
    @test agg.variance_homog == 0.0
    @test agg.variance_polar > agg.variance_homog

    # §11 order parameter P ∈ [0,1]: alignment 1, opposition 0
    @test isapprox(P2.P([[1.0, 0.0], [1.0, 0.0], [1.0, 0.0]]), 1.0; rtol = 1e-12)
    @test isapprox(P2.P([[1.0, 0.0], [-1.0, 0.0]]), 0.0; atol = 1e-12)
    @test isapprox(P2.P([[1.0, 0.0], [0.0, 1.0], [-1.0, 0.0], [0.0, -1.0]]), 0.0;
                   atol = 1e-12)

    # §13 Simpson reversal: pooling flips the sign of the association
    s = P2.simpson_reversal()
    @test s.within_1 ≈ -1.0 && s.within_2 ≈ -1.0
    @test s.pooled > 0
    @test sign(s.pooled) != sign(s.within_1)

    # §14 macrovariable quality = |satisfied ∩ criteria| / |criteria|
    @test P2.quality(P2.Macrovariable(:m, [:predictive, :observable,
                                           :approximately_closed, :bogus_extra])) == 0.5

    # Q4: ambiguity-set intersection shrinks as observers are added
    x_true = [0.3, -0.7]
    @test x_true ∈ grid
    one_obs = P2.ambiguity_intersection([(P2.π₁, x_true[1])], grid; tol = 0.15)
    two_obs = P2.ambiguity_intersection([(P2.π₁, x_true[1]), (x -> x[2], x_true[2])],
                                        grid; tol = 0.15)
    @test length(one_obs) == 63
    @test length(two_obs) == 9
    @test length(grid) > length(one_obs) > length(two_obs) ≥ 1
    @test x_true ∈ two_obs                              # the true state is never excluded

    # parallax: a second view exposes a coordinate the first erases
    @test P2.parallax(P2.π₁, x -> x[2], [0.5, 1.0], [0.5, -1.0])
    @test !P2.parallax(P2.π₁, x -> x[2], [0.5, 1.0], [0.5, 1.0])
    @test !P2.parallax(P2.π₁, x -> x[2], [0.4, 1.0], [0.5, -1.0])
    @test P2.naive_average([-1.0, 1.0]) == 0.0          # midpoint of opposing reports

    # Bayes fusion over a hypothesis grid
    priorU, L = fill(0.2, 5), [0.05, 0.1, 0.6, 0.2, 0.05]
    post = P2.fuse(priorU, [L])
    @test all(isapprox.(post, L; rtol = 1e-12))          # uniform prior ⇒ posterior ∝ L
    @test sum(post) ≈ 1.0
    @test argmax(post) == 3
    @test all(isapprox.(P2.fuse([0.4, 0.6], [[0.9, 0.1]]),
                        [6 / 7, 1 / 7]; rtol = 1e-12))   # exact hand computation
    fc = P2.false_confidence_demo(priorU, L)
    @test fc.honest_max ≈ 0.6
    @test fc.doubled_max ≈ 0.36 / 0.415                  # L² renormalized
    @test fc.overconfident && fc.doubled_max > fc.honest_max

    # the next measurement is the one competing hypotheses disagree about
    hyps = [[0.5, 1.0], [0.5, -1.0]]
    chosen = P2.next_measurement([x -> x[1], x -> x[2]], hyps)
    @test length(unique(map(chosen, hyps))) == 2

    # atlas gluing: agreement, informative failure, no overlap, bad coordinates
    chartA = P2.LocalChart((0.0, 2.0), t -> sin(t))
    chartB = P2.LocalChart((1.0, 3.0), t -> sin(t))
    chartC = P2.LocalChart((1.0, 3.0), t -> cos(t))
    chartD = P2.LocalChart((5.0, 6.0), t -> sin(t))
    chartE = P2.LocalChart((0.0, 2.0), t -> error("wrong coordinates"))
    @test P2.glue(chartA, chartB) === :glues
    @test P2.glue(chartA, chartC) === :fails_to_glue
    @test P2.glue(chartA, chartD) === :no_overlap
    @test P2.glue(chartA, chartE) === :incompatible_coordinates

    # the synthesis map preserves structure instead of forcing consensus
    conflictual = P2.Σ(Dict(:π1 => 0.4, :π2 => 0.4, :π3 => 0.9))
    @test conflictual[:conflicts] === true
    @test conflictual[:shared_invariants] === nothing
    @test Set(conflictual[:missing_observations]) == Set([:π4])
    consensual = P2.Σ(Dict(:π1 => 0.4, :π2 => 0.4))
    @test consensual[:conflicts] === false
    @test consensual[:shared_invariants] == 0.4
    @test Set(consensual[:missing_observations]) == Set([:π3, :π4])

    # consensus can conceal shared blindness; joint model failure is generative
    @test P2.shared_blindness([x -> x[1], x -> x[1], x -> x[1]], [0.2, 9.9])
    @test P2.generative_boundary(true, true) === :search_for_coupling
    @test P2.generative_boundary(true, false) === :models_sufficient

    # observer functor (ε = 0 ⇒ deterministic), joint observation tuple
    @test P2.Observer((x, θ) -> θ * x, 2.0, 0.0)(3.0) == 6.0
    @test P2.Π([1.0, 2.0], P2.π₁, x -> x[2]) == (1.0, 2.0)
    @test length(instances(P2.Disagreement)) == 4
    @test P2.resolve(P2.perspectival) == "integrate, do not pick a winner"
end

# ═══════════════════════════════════════════════════════════════════════════
@testset "Part 3 — generative fields & the versioned field" begin
    # canonical inventories (README: 13 element kinds, 20 relation types, 8 operators)
    @test length(instances(P3.ElementKind)) == 13
    @test length(P3.RELATION_TYPES) == 20
    @test allunique(P3.RELATION_TYPES)
    op_types = [getfield(P3, n) for n in names(P3; all = true)
                if isdefined(P3, n) && getfield(P3, n) isa DataType]
    @test count(T -> T <: P3.Operator && T !== P3.Operator, op_types) == 8
    @test length(instances(P3.TensionKind)) == 11
    @test length(instances(P3.GenerativeRegion)) == 9
    @test length(P3.LADDER) == 7
    @test first(P3.LADDER).first === :binary && last(P3.LADDER).first === :open_becoming
    @test P3.binary(true) === :A && P3.binary(false) === :B

    # structured field F = (P, D, R, C, T) answers what a flat list cannot
    field = P3.StructuredField([:p1, :p2, :p3], [:scale, :timespan],
                               [(:p1, :challenges, :p2)],
                               [Dict(:scale => :local)],
                               [(from = :p1, to = :p3)])
    @test P3.transformable(field, :p1) == [(from = :p1, to = :p3)]
    @test isempty(P3.transformable(field, :p2))
    @test P3.absent_from_field(field, [:p1, :p2, :p3, :p4]) == [:p4]
    grown = P3.expand_dimensions(field, :boundary)
    @test grown.D == [:scale, :timespan, :boundary] && grown.P == field.P

    # generative rule set G → {F₁, F₂, …}
    g = P3.generate(P3.RULES, field)
    @test :boundary ∈ g[:form_boundary].D
    @test length(g[:branch].P) == 4
    @test length(g[:dissolve].P) == 2

    # bifurcation: pitchfork gains stable states as μ crosses 0
    @test P3.stable_states(-1.0) == [0.0]
    @test P3.stable_states(1.0) == [-1.0, 1.0]
    @test P3.bifurcates(-1.0, 1.0)
    @test !P3.bifurcates(0.5, 2.0)

    # frustration and curvature (route-dependent translation)
    @test P3.frustrated([x -> x > 0, x -> x < 0], -2:0.5:2)
    @test !P3.frustrated([x -> x > 0, x -> x < 1], -2:0.5:2)
    route(x, via) = via === :B ? x + 1 : via === :D ? 3x : x
    flat(x, via) = x + 1
    @test P3.path_dependent(route, 1.0, :C)
    @test !P3.path_dependent(flat, 1.0, :C)

    # unit = persistent convergence of relations
    rels = [P3.Relation(:supports, (:a, :b)), P3.Relation(:challenges, (:a, :c)),
            P3.Relation(:depends_on, (:d, :a))]
    @test P3.unit(rels, :a) === :unit
    @test P3.unit(rels, :b) === :not_yet_individuated

    # events before states: identity in the continuity of the arrows
    evs = [P3.Event(x -> x + 1, Dict{Symbol,Any}()),
           P3.Event(x -> 2x, Dict{Symbol,Any}()),
           P3.Event(x -> x^2, Dict{Symbol,Any}())]
    @test P3.unfold(1.0, evs) == [2.0, 4.0, 16.0]

    # state = actual + accessible: identical now, different futures
    @test P3.same_now_different_futures(
        P3.State(0.0, Set([:grow, :split]), Set{Symbol}()),
        P3.State(0.0, Set([:grow]), Set{Symbol}()))
    @test !P3.same_now_different_futures(
        P3.State(0.0, Set([:grow]), Set{Symbol}()),
        P3.State(0.0, Set([:grow]), Set{Symbol}()))

    # co-evolving possibility space: both x and X changed (deterministic trace)
    co = P3.coevolve(1, Set([1, 2, 3]))
    @test co.x == 6
    @test sort(collect(co.X)) == [1, 2, 3, 4, 5]

    # partial translation maps between operative spaces
    @test P3.T_ij(:W1, :W2) == Set([:b])

    # observer ↔ observed coupling: measuring alters both parties
    obs = P3.CoupledObserver(0.0)
    xnew, y = P3.observe!(obs, 1.0)
    @test xnew ≈ 0.95 && y == 1.0
    @test obs.o ≈ 0.1

    # positions may be points, regions, or distributions (dispatch on width)
    @test P3.width(P3.PointPosition([1.0, 2.0])) == [0.0, 0.0]
    @test P3.width(P3.RegionPosition([0.0], [2.0])) == [2.0]
    @test P3.width(P3.DistribPosition(identity)) == [Inf]

    # a tension is generative only under the document's conditions
    tension_ok = (each_side_preserves_something = true, neither_absorbs_other = true,
                  changes_with_scale = false, different_predictions = true,
                  reveals_missing_dimension = false)
    @test P3.generative_tension(tension_ok)
    @test !P3.generative_tension(merge(tension_ok, (neither_absorbs_other = false,)))

    # ── the versioned field F₀ → F₁ → … ──────────────────────────────────
    vf = P3.VersionedField()
    @test P3.current(vf).n == 0
    @test isempty(P3.current(vf).accepted)

    e1 = P3.Element(id = "claim-0001", kind = P3.claim,
                    statement = "Identity can persist through organized change.",
                    origin_trace = (origin_kind = :originating_expression,
                                    origin_ref = "observer-kelly",
                                    captured_at = "2026-08-02"),
                    origin_confirmed = true)
    e2 = P3.Element(id = "claim-0002", kind = P3.claim,
                    statement = "Identity requires strict state equality.",
                    origin_trace = (origin_kind = :originating_expression,
                                    origin_ref = "observer-2",
                                    captured_at = "2026-08-02"),
                    origin_confirmed = true)
    rel = P3.contradicts_under("claim-0001", "claim-0002";
                               same_referent = true, same_definition = true,
                               same_scale = false, overlapping_time = true,
                               unresolved = ["Are both using 'identity' numerically?"])
    @test rel.type === :contradicts_under               # a contradiction states its conditions
    @test length(rel.unresolved_questions) == 1

    res = P3.propose!(vf, [e1, e2]; tensions = [rel],
                      unresolved = ["Is functional continuity sufficient?"],
                      accept = els -> all(el -> el.origin_confirmed === true, els))
    @test res.merged
    @test P3.current(vf).n == 1
    @test length(P3.current(vf).accepted) == 2
    @test length(P3.current(vf).tensions) == 1          # tension carried, not resolved away
    @test P3.current(vf).unresolved == ["Is functional continuity sufficient?"]
    # origin traces survive the transition F₀ → F₁
    @test [el.origin_trace.origin_ref for el in P3.current(vf).accepted] ==
          ["observer-kelly", "observer-2"]
    @test all(el -> el.origin_trace.origin_kind !== :unknown, P3.current(vf).accepted)
    # append-only history: F₀ still present and untouched
    @test length(vf.history) == 2
    @test isempty(vf.history[1].accepted)
    @test P3.was_ever_accepted(vf, "claim-0001")
    @test !P3.was_ever_accepted(vf, "claim-9999")

    # deterministic validation verdicts
    bad = P3.Element(id = "", kind = P3.claim, statement = "unattributed")
    @test P3.validate(bad) == [:well_formed, :origin_trace_complete]
    res_bad = P3.propose!(vf, [bad];
                          accept = _ -> error("acceptance must not run before checks"))
    @test res_bad.merged == false                       # checks fire, accept never called
    @test res_bad.failures == [:well_formed, :origin_trace_complete]
    @test P3.current(vf).n == 1                         # rejected candidate: no transition

    unattributed = P3.Element(id = "t-1", kind = P3.claim, origin_class = :transformed,
                              origin_trace = (origin_kind = :transformation,
                                              origin_ref = "op",
                                              captured_at = "2026-08-04"))
    @test P3.validate(unattributed) == [:attribution]   # transformed w/o operator flagged

    res_declined = P3.propose!(vf, [e1]; accept = _ -> false)
    @test res_declined.failures == [:acceptance_declined]
    @test length(vf.history) == 2                       # declined ⇒ no new state
    # NOTE: the fourth CHECK, :no_self_acceptance, ends in `|| true` and is
    # therefore structurally vacuous — it can never fail. Documented here:
    selfy = P3.Element(id = "self-1", kind = P3.claim, origin_class = :transformed,
                       operator = P3.signature(P3.Reflector()),
                       origin_trace = (origin_kind = :transformation,
                                       origin_ref = "op", captured_at = "2026-08-04"),
                       origin_confirmed = true)
    @test P3.validate(selfy) == Symbol[]

    # the Reflector: transformed, attributed, awaiting confirmation, trace intact
    r = P3.apply(P3.Reflector(), e1)
    @test r.status === :awaiting_confirmation
    @test r.origin_class === :transformed
    @test r.operator !== nothing && r.operator.family === :Reflector
    @test r.origin_confirmed === missing                # cannot self-accept
    @test r.origin_trace == e1.origin_trace             # origin preserved through the operator
    @test startswith(r.statement, "[reflected] ")
    @test P3.attributed(r)

    # tension typing: decompression restores context before crying contradiction
    mk(; def = true, scal = true, time = true, logic = :classical) =
        P3.contradicts_under("a", "b"; same_referent = true, same_definition = def,
                             same_scale = scal, overlapping_time = time,
                             shared_logic = logic)
    @test P3.classify_tension(mk(def = false)) === P3.equivocation
    @test P3.classify_tension(mk(scal = false)) === P3.scale_mismatch
    @test P3.classify_tension(mk(time = false)) === P3.temporal_mismatch
    @test P3.classify_tension(mk(logic = :paraconsistent)) === P3.framework_mismatch
    @test P3.classify_tension(mk()) === P3.logical_contradiction
    @test P3.classify_tension(mk(def = false, scal = false)) === P3.equivocation
    @test P3.classify_tension(rel) === P3.scale_mismatch  # the demo's tension dissolves at scale

    # every bridge states what it preserves and loses: Loss(T) > 0 stays visible
    bridge = P3.apply(P3.BridgeBuilder(), :process_centered, :object_centered)
    @test P3.loss(bridge) > 0
    @test !isempty(bridge.preserves)

    # synthesis represents disagreement instead of averaging it away
    syn = P3.apply(P3.Synthesizer(), [e1, e2];
                   residual_tensions = ["scale-relative identity"],
                   excluded = ["observer-situated meaning"],
                   non_endorsing = ["observer-2"])
    @test syn.includes == ["claim-0001", "claim-0002"]
    @test syn.not_endorsed_by == ["observer-2"]         # dissent preserved, not merged
    @test syn.tensions_remaining == ["scale-relative identity"]
    @test occursin("NOT finally true", syn.meaning)

    # multiplicity ≠ independence: three outputs, two independent families
    dp = P3.dependence_profile([e1, e2, r])
    @test dp.n_outputs == 3
    @test dp.n_independent == 2
    @test dp.correlated

    # the auditor flags suspicious consensus, passes an honest field
    audit_empty = P3.apply(P3.FieldAuditor(),
                           P3.FieldState(0, P3.Element[], [], String[]))
    @test length(audit_empty) == 1
    @test isempty(P3.apply(P3.FieldAuditor(), P3.current(vf)))

    # L3: the field revises its own structure only under external acceptance
    @test P3.accept_dimension_proposal!(vf, :reversibility; accept = _ -> true) ===
          :structure_changed
    @test P3.accept_dimension_proposal!(vf, :reversibility; accept = _ -> false) ===
          :declined
end

# ═══════════════════════════════════════════════════════════════════════════
@testset "Part 4 — 68 expression forms, one law" begin
    # the 68/68 agreement asserted programmatically, not parsed from output
    target = -P4.k * (P4.x0 - P4.x★)
    @test target == -4.0
    @test length(P4.results) == 68
    nums = sort([parse(Int, first(split(name))) for name in keys(P4.results)])
    @test nums == collect(1:68)                         # forms 1–68, each exactly once
    @test all(v -> isapprox(v, target; atol = 1e-9), values(P4.results))
    @test count(v -> isapprox(v, target; atol = 1e-9), values(P4.results)) ==
          length(P4.results)                            # i.e. 68/68

    # the law itself, spot-checked away from the catalog's single test point
    @test P4.regulate(5.0) == -8.0
    @test P4.f1(-1.0) == 4.0
    @test P4.flow(3.0, P4.NoRegulation()) == 0.0
    @test P4.flow(3.0, P4.MovingTarget(t -> 3.0)) == 0.0  # tracked target ⇒ no correction
    @test P4.Organization₂(2.0, 1.0)(0.0) == 2.0
    @test P4.law(Val(:off), 3.0) == 0.0

    # the iterator form settles at the target, monotonically
    traj = collect(P4.GradientDescent(3.0, 0.01, 500))
    @test isapprox(traj[end], P4.x★; atol = 1e-3)
    @test all(<(0), diff(abs.(traj .- P4.x★)))
end

end # outer testset
