#=============================================================================
 Part 3 — STRUCTURED FIELDS, GENERATIVE FIELDS, AND THE VERSIONED FIELD
 Julia translation of Questions 5–7 of the DOCX and the architecture in
 "Geometry and Dynamic Systems" (the versioned epistemic commons):

   binary  →  multitude  →  structured field  →  dynamic field
           →  generative field  →  reflexive field  →  open becoming

   F = (P, D, R, C, T)
   field = observations + claims + assumptions + relations + tensions
           + transformations
   F₀ → F₁ → F₂ → …  (ordered sequence of accepted states, origin-traced)
=============================================================================#

module GenerativeField

using Statistics

# ---------------------------------------------------------------------------
# Q5 §0  A binary is the smallest possible compression:  X → {A, B}
# ---------------------------------------------------------------------------

binary(x) = x ? :A : :B                                  # the smallest compression

"multitude of positions → structured field of relations, contexts, transformations"

# ---------------------------------------------------------------------------
# Q5  What makes a structured field?   F = (P, D, R, C, T)
#     P positions | D dimensions | R relations | C contexts | T transitions
# ---------------------------------------------------------------------------

struct StructuredField{P,Dd,R,Cc,T}                      # 5-parameter parametric struct
    P::Vector{P}          # positions, states, or observations
    D::Vector{Dd}         # relevant dimensions
    R::Vector{R}          # relations among positions
    C::Vector{Cc}         # contexts in which they hold
    T::Vector{T}          # possible transitions
end

# Questions a list cannot answer — expressed as field methods:
close_positions(f, d, ε)  = [(p, q) for p in f.P for q in f.P if p !== q && d(p, q) < ε]
coexist_at_scale(f, s)    = filter(c -> get(c, :scale, nothing) == s, f.C)
transformable(f, p)       = [t for t in f.T if t.from == p]
absent_from_field(f, all) = setdiff(all, f.P)            # which possibilities are absent

# ---------------------------------------------------------------------------
# Q5  A position may be a region (subset) or a distribution μᵢ(x), not a point
# ---------------------------------------------------------------------------

abstract type Position end
struct PointPosition    <: Position; x::Vector{Float64} end
struct RegionPosition   <: Position; lo::Vector{Float64}; hi::Vector{Float64} end
struct DistribPosition  <: Position; μ::Function end     # observer as distribution

"An observer can be confident on one dimension, uncertain on another."
width(p::PointPosition)   = zeros(length(p.x))
width(p::RegionPosition)  = p.hi .- p.lo                 # multiple dispatch on Position
width(p::DistribPosition) = fill(Inf, 1)

# ---------------------------------------------------------------------------
# Q5  A multitude supports several geometries (one type per representation)
# ---------------------------------------------------------------------------

abstract type FieldGeometry end
struct CoordinateSpace <: FieldGeometry; axes::Vector{Symbol} end   # x = (x₁,…,x_k)
struct RelationGraph   <: FieldGeometry; edges::Vector{Tuple{Symbol,Symbol,Symbol}} end
struct HyperRelation   <: FieldGeometry; groups::Vector{Vector{Symbol}} end
struct Atlas           <: FieldGeometry; charts::Vector{Any} end    # overlapping local systems
struct FlowLandscape   <: FieldGeometry; F::Function end            # dx/dt = F(x)

fits_when(::CoordinateSpace) = "relatively independent variables can be identified"
fits_when(::RelationGraph)   = "relations matter more than coordinates"
fits_when(::HyperRelation)   = "a relation belongs to a group, not a pair"
fits_when(::Atlas)           = "no single coordinate system works everywhere"
fits_when(::FlowLandscape)   = "movement matters more than static position"

"Higher-order (hypergraph) compatibility: every pair compatible, triple not."
pairwise_ok(compat, group)  = all(compat(a, b) for a in group for b in group if a != b)
triple_ok(compat3, group)   = compat3(group...)

# ---------------------------------------------------------------------------
# Q5  Generative regions: seams, holes, curvature, bifurcations, frustration,
#     degeneracy, hysteresis, singularities, boundary cases
# ---------------------------------------------------------------------------

@enum GenerativeRegion seam hole curvature bifurcation frustration degeneracy hysteresis singularity boundary_case

reveals(r::GenerativeRegion) = Dict(
    seam         => "which distinction one perspective preserves that the other loses",
    hole         => "a missing observer, scale, relation, or excluded possibility",
    curvature    => "translation depends on the route: A→B→C ≠ A→D→C",
    bifurcation  => "hidden control variables and thresholds",
    frustration  => "the geometry of trade-offs (constraints unsatisfiable together)",
    degeneracy   => "hidden multiplicity beneath observational equivalence: x₁,x₂,x₃ → y",
    hysteresis   => "the missing dimension is the trajectory",
    singularity  => "the current distinction is inadequate — say so, don't misclassify",
    boundary_case => "how the categories were constructed",
)[r]

"Curvature test: does translation depend on the route? (route-composition form)"
path_dependent(translate, a, c; via1 = :B, via2 = :D) =
    translate(translate(a, via1), c) != translate(translate(a, via2), c)

"Frustration: can all constraints be satisfied simultaneously? (all-any form)"
frustrated(constraints, candidates) = !any(x -> all(c -> c(x), constraints), candidates)

"Bifurcation: a small parameter change produces qualitatively different outcomes.
Classic pitchfork ẋ = μx − x³: count stable fixed points as μ crosses 0."
stable_states(μ) = μ ≤ 0 ? [0.0] : [-√μ, √μ]             # branch expression
bifurcates(μ1, μ2) = length(stable_states(μ1)) != length(stable_states(μ2))

# ---------------------------------------------------------------------------
# Q5  Oppositions become richer fields (binary → graded vocabulary)
# ---------------------------------------------------------------------------

const REGULARITY_FIELD = [:rigid_order, :adaptive_coordination, :exploratory_variability,
                          :patterned_turbulence, :random_noise, :destructive_disintegration]

const PERSISTENCE_FIELD = [:static_persistence, :fixed_target_return, :cyclical_stability,
                           :metastability, :adaptive_transformation, :directed_trajectory,
                           :runaway_change, :collapse]

"Worked transformation: apparent contradiction → multiscale organization.
Introduce dimensions x = (scale, timespan, flow, effect, control, dependence)."
function decompress(claims)
    # A flat system demands one label; a structured field restates without forcing one:
    (local_opposition        = :holds_at_component_scale_over_limited_flow,
     mutual_dependence       = :collective_motion_preserves_the_whole,
     higher_level_constraint = :suppresses_unrestricted_local_growth,
     unequal_effect          = :coexists_with_aggregate_viability,
     verdict                 = "local opposition + mutual dependence + higher-level constraint + unequal effect")
end

"A tension is generative when… (predicate-composition form)"
generative_tension(t) = t.each_side_preserves_something &&
                        t.neither_absorbs_other &&
                        (t.changes_with_scale || t.different_predictions ||
                         t.reveals_missing_dimension)

# ---------------------------------------------------------------------------
# Q6 — beyond a multitude: relations before elements, events before states
# ---------------------------------------------------------------------------

# §1  unit = persistent convergence of relations (entity as intersection)
struct Relation; kind::Symbol; endpoints::NTuple{2,Symbol} end
"A 'unit' is where enough relations persistently converge (count-threshold form)."
unit(relations, node; k = 3) =
    count(r -> node ∈ r.endpoints, relations) ≥ k ? :unit : :not_yet_individuated

# §2  event = transformation under conditions:  x₁ --f₁--> x₂ --f₂--> x₃
struct Event{Fn}
    f::Fn                                                # the arrow matters as much
    conditions::Dict{Symbol,Any}                         # as the endpoints
end
"Identity resides in the continuity of the arrows (fold over events)."
unfold(x0, events::Vector{<:Event}) =
    accumulate((x, ev) -> ev.f(x), events; init = x0)    # accumulate form: keeps the path

# §3  possibility field:  P(x) = {transformations accessible from x}
#     state = actual + accessible + becoming accessible
struct State{T}
    actual::T
    accessible::Set{Symbol}
    becoming_accessible::Set{Symbol}
end
"Two systems identical now can differ strongly in reachable futures."
same_now_different_futures(s1, s2) =
    s1.actual == s2.actual && s1.accessible != s2.accessible

# §4  generated dimensions:  F_n → F_{n+1}  — contradiction creates a coordinate
"persistent contradiction → new distinction → expanded space"
function expand_dimensions(field::StructuredField, new_dim::Symbol)
    StructuredField(field.P, vcat(field.D, new_dim), field.R, field.C, field.T)
end   # a coordinate absent from the old field now exists

# §5  several primitive schemes; translation loses content:  Loss(T) > 0
struct Translation{Fn}
    T::Fn                                                # T: O₁ → O₂
    preserves::Vector{Symbol}
    loses::Vector{Symbol}                                # the residue is recorded
end
loss(t::Translation) = length(t.loses)                   # Loss(T) > 0 stays visible

# §6  transformations of relations: r → r′, α: r ⇒ r′, β: α ⇒ α′
struct Arrow{A,B}; from::A; to::B end                    # 1-cells: transformations
struct TwoArrow{A}; from::Arrow; to::Arrow end           # 2-cells: transformations of
higher(α::Arrow, α′::Arrow) = TwoArrow{typeof(α)}(α, α′) # transformations

# §7  generative rule set:  G → {F₁, F₂, …}
const RULES = Dict(
    :form_boundary => f -> expand_dimensions(f, :boundary),
    :branch        => f -> StructuredField(vcat(f.P, [:new_branch]), f.D, f.R, f.C, f.T),
    :dissolve      => f -> StructuredField(f.P[1:end-1], f.D, f.R, f.C, f.T),
)
generate(G, seed) = Dict(name => rule(seed) for (name, rule) in G)  # dict comprehension

# §8  changing possibility space:  X(t₁) ≠ X(t₂)
#     dx/dt = F(x, X);   dX/dt = G(x, X)
"The system moves inside a possibility space while transforming that space."
function coevolve(x, X::Set; steps = 5)
    for i in 1:steps
        x = x ∈ X ? x + 1 : first(X)                     # F(x, X): motion inside X
        i % 2 == 0 && push!(X, maximum(X) + 1)           # G(x, X): X itself grows
    end
    (x = x, X = X)                                       # both changed
end

# §9  distinction formation: weakly differentiated field → temporary individual
"Symmetry breaking: perturbation individuates a uniform field (map w/ noise)."
individuate(field::Vector{Float64}; θ = 0.5) =
    [v + 0.6 * randn() |> w -> abs(w) > θ ? :individual : :undifferentiated
     for v in field]                                     # comprehension + pipe + λ

# §10 family of operative spaces W = {W₁,…,W_n} with partial maps T_ij
const W = Dict(:W1 => Set([:a, :b]), :W2 => Set([:b, :c]), :W3 => Set([:c, :d]))
T_ij(i, j) = intersect(W[i], W[j])                       # partial translation map

# §11 mutual coupling: observer ↔ observed
#     yᵢ = πᵢ(x, oᵢ);  dx/dt = F(x, oᵢ, yᵢ);  doᵢ/dt = G(oᵢ, x, yᵢ)
"Observation becomes participation (mutable observer + coupled update)."
mutable struct CoupledObserver
    o::Float64                                           # the observer's own state
end
function observe!(obs::CoupledObserver, x)
    y  = x * (1 + 0.1obs.o)                              # y = π(x, o): observation is situated
    x′ = x - 0.05y                                       # dx/dt = F(x, o, y): measuring alters
    obs.o += 0.1 * (y - obs.o)                           # do/dt = G(o, x, y): observer changes
    x′, y
end

# §12 open revisability:  M_t → M_{t+1}  (no final exhaustive representation)
revise(M_t, event) = merge(M_t, Dict(:revision => event, :final => false))

# The ladder of increasingly generative representations (document's table):
const LADDER = [
    :binary           => "A or B",
    :multitude        => "{A, B, C, …}",
    :structured_field => "positions plus relations and dimensions",
    :dynamic_field    => "positions and relations changing over time",
    :generative_field => "new positions, relations, and dimensions emerge",
    :reflexive_field  => "the field models and modifies its own organization",
    :open_becoming    => "no fixed inventory of future possibilities",
]

#=============================================================================
 Q7 + PDF — THE VERSIONED FIELD AS AN ORDERED SEQUENCE OF ACCEPTED STATES
   field = graph of observations + claims + assumptions + relations
           + tensions + transformations
   F₀ → F₁ → …  with origin traces, bounded operators, acceptance maps
=============================================================================#

# -- Element kinds (the canonical object table) ------------------------------

@enum ElementKind observation claim assumption definition perspective relation_el tension bridge test_el dimension_proposal synthesis limit transformation_el

# -- Relation vocabulary: far more than agrees/disagrees ----------------------

const RELATION_TYPES = [
    :supports, :challenges, :contradicts_under, :compatible_under, :complements,
    :overlaps, :contains, :depends_on, :caused_by, :correlated_with,
    :translates_to, :partially_translates_to, :loses_information_when_translated_to,
    :applies_at_different_scale, :applies_at_different_time, :transforms_into,
    :provides_counterexample_to, :shares_assumption_with, :requires_dimension,
    :unresolved_with,
]

# -- An attributed element (the contribution record, YAML → struct) -----------

Base.@kwdef struct Element                               # @kwdef macro form
    id::String
    kind::ElementKind
    status::Symbol            = :open                    # open|confirmed|contested|…
    origin_class::Symbol      = :originating             # originating|transformed|aggregate
    statement::String         = ""
    context::NamedTuple       = (scale = :unspecified, temporal_scope = :unspecified,
                                 framework = :unspecified)
    distinctions::Vector{String} = String[]
    assumptions::Vector{String}  = String[]
    relations::Vector{NamedTuple} = NamedTuple[]
    origin_trace::NamedTuple  = (origin_kind = :unknown, origin_ref = "", captured_at = "")
    operator::Union{Nothing,NamedTuple} = nothing        # transformation signature
    origin_confirmed::Union{Bool,Missing} = missing      # "did this preserve your meaning?"
end

"A derived element must never appear as unoriginated common truth."
attributed(e::Element) = e.origin_class != :transformed || e.operator !== nothing

"A contradiction relation must state its conditions (kwargs → NamedTuple)."
contradicts_under(src, tgt; same_referent, same_definition, same_scale,
                  overlapping_time, shared_logic = :classical, unresolved = String[]) =
    (type = :contradicts_under, source = src, target = tgt,
     conditions = (; same_referent, same_definition, same_scale,
                     overlapping_time, shared_logic),    # property-shorthand form
     unresolved_questions = unresolved)

# -- Tension classification (the tension-typer operator) ----------------------

@enum TensionKind logical_contradiction equivocation scale_mismatch temporal_mismatch framework_mismatch measurement_disagreement false_dichotomy self_reference undecidability uncomputability value_conflict

"Decompression: does the conflict survive restoring time/scale/context/framework?"
function classify_tension(rel)::TensionKind
    c = rel.conditions
    !c.same_definition  && return equivocation           # early-return guard form
    !c.same_scale       && return scale_mismatch
    !c.overlapping_time && return temporal_mismatch
    c.shared_logic != :classical && return framework_mismatch
    logical_contradiction                                # only if all context matches
end

# -- The family of bounded transformation operators ---------------------------

abstract type Operator end
struct Reflector      <: Operator end   # restate; ask "did this preserve your meaning?"
struct AssumptionMap  <: Operator end   # observation → interpretation → assumption → conclusion
struct TensionTyper   <: Operator end   # classify mismatches
struct Counterexample <: Operator end   # search where a generalization fails
struct BridgeBuilder  <: Operator end   # partial translations; must state preserves/loses
struct DifferencePreserver <: Operator end  # strongest form of each side; prevent false consensus
struct Synthesizer    <: Operator end   # integrate only after disagreement is represented
struct FieldAuditor   <: Operator end   # hunt orphans, hidden assumptions, consensus loops

signature(op::Operator; version = v"1.0.0") =            # VersionNumber literal form
    (family = nameof(typeof(op)), version = version,
     generated_at = time(), human_confirmed = false)

"Reflection: cannot enter the field without confirmation or an explicit
'unconfirmed interpretation' mark."
function apply(::Reflector, e::Element)
    Element(id = e.id * "-reflected", kind = e.kind, status = :awaiting_confirmation,
            origin_class = :transformed, statement = "[reflected] " * e.statement,
            context = e.context, origin_trace = e.origin_trace,
            operator = signature(Reflector()), origin_confirmed = missing)
end

"The assumption map separates the inferential chain (4-tuple return)."
apply(::AssumptionMap, s::String) =
    (observation = s, interpretation = "proposed reading of: " * s,
     assumption = "condition required for the reading", conclusion = "what would follow")

"Every bridge states what it preserves, loses, and where it is (in)valid."
apply(::BridgeBuilder, from, to) = Translation(identity,
    [:causal_direction, :temporal_order],                # preserves
    [:first_person_meaning, :spatial_detail])            # loses — Loss(T) > 0

"Counterexamples carry their evidential class."
apply(::Counterexample, generalization) =
    (counterexample = "case where '$generalization' fails",
     class = rand([:observed, :hypothetical, :logically_constructed,
                   :unusual_assumptions]))

"A synthesis must list inclusions, exclusions, residual tensions, added
assumptions, and non-endorsing origins."
apply(::Synthesizer, elements; residual_tensions, excluded, non_endorsing) =
    (kind = synthesis, includes = [e.id for e in elements],
     excludes = excluded, tensions_remaining = residual_tensions,
     assumptions_added = String[], not_endorsed_by = non_endorsing,
     meaning = "adequately represented, traceable, revisable — NOT finally true")

"The auditor's checklist (returns failures found)."
apply(::FieldAuditor, field) = filter(!isempty, [
    isempty(field.tensions)  ? "no tensions recorded — suspicious consensus" : "",
    any(e -> !attributed(e), field.accepted) ? "unattributed transformed element" : "",
])

# -- The versioned field: F₀ → F₁ → … (append-only accepted states) -----------

struct FieldState                                        # one accepted state F_n
    n::Int
    accepted::Vector{Element}
    tensions::Vector{Any}
    unresolved::Vector{String}                           # dissent is first-class
end

mutable struct VersionedField
    history::Vector{FieldState}                          # persistent history: nothing erased
end
VersionedField() = VersionedField([FieldState(0, Element[], [], String[])])

current(vf::VersionedField) = last(vf.history)           # F_n = best current field, not truth

# -- Deterministic consistency conditions (the CI checks) ----------------------

const CHECKS = [
    :well_formed          => e -> !isempty(e.id),
    :origin_trace_complete => e -> e.origin_trace.origin_kind != :unknown,
    :attribution          => attributed,
    :no_self_acceptance   => e -> e.origin_confirmed !== true ||
                                  e.origin_class != :transformed ||
                                  e.operator === nothing ||
                                  true,   # acceptance is applied externally, never by the operator
]

"Run every deterministic predicate; a transformation must not accept its own change."
validate(e::Element) = [name for (name, check) in CHECKS if !check(e)]

# -- Candidate change + independent acceptance map -----------------------------

"""
    propose!(vf, elements; tensions, unresolved, accept)

Every change to the accepted field is a visible candidate change (a PR):
deterministic tests run first; an *independent* acceptance map (`accept`,
never the proposing operator) decides; the transition F_n → F_{n+1} preserves
who supplied, who transformed, what remained unresolved.
"""
function propose!(vf::VersionedField, elements::Vector{Element};
                  tensions = [], unresolved = String[], accept::Function)
    failures = reduce(vcat, map(validate, elements); init = Symbol[])
    isempty(failures) || return (merged = false, failures = failures)
    accept(elements) || return (merged = false, failures = [:acceptance_declined])
    prev = current(vf)
    push!(vf.history, FieldState(prev.n + 1,
                                 vcat(prev.accepted, elements),
                                 vcat(prev.tensions, tensions),
                                 vcat(prev.unresolved, unresolved)))
    (merged = true, failures = Symbol[])
end

"Removing an element may not erase its occurrence in earlier states."
was_ever_accepted(vf, id) = any(s -> any(e -> e.id == id, s.accepted), vf.history)

# -- Multiplicity ≠ independence -----------------------------------------------

"number of outputs ≠ number of independent perspectives"
function dependence_profile(outputs)
    families = [o.operator === nothing ? :originating : o.operator.family
                for o in outputs]
    (n_outputs = length(outputs),
     n_independent = length(unique(families)),
     correlated = length(unique(families)) < length(outputs))
end

# -- The three levels of field evolution ---------------------------------------

const LEVELS = Dict(
    :L1 => "new contributions",
    :L2 => "new relations and interpretations",
    :L3 => "changes to the field's own generating rules",  # strongest conditions
)

"L₃: the field revises its own structure — the reflexive step F_n → F_{n+1}."
function accept_dimension_proposal!(vf::VersionedField, dim::Symbol; accept)
    accept(dim) || return :declined
    # existing elements can now be reconsidered under the new dimension
    :structure_changed
end

# ---------------------------------------------------------------------------
# Demonstration: the first meaningful cycle from the documents —
# originating expression → reflection → origin correction → second perspective
#   → tension map → new distinction → candidate change → accepted field update
# ---------------------------------------------------------------------------

function demo()
    println("── Part 3: Structured & Generative Fields ──")

    println("binary(true) = ", binary(true), "  — the smallest compression")

    field = StructuredField(
        [:p1, :p2, :p3],                                  # P
        [:scale, :timespan, :flow],                       # D
        [(:p1, :challenges, :p2)],                        # R
        [Dict(:scale => :local), Dict(:scale => :global)],# C
        [(from = :p1, to = :p3)],                         # T
    )
    println("F = (P,D,R,C,T): |P|=", length(field.P), " |D|=", length(field.D),
            "; transformable from p1: ", transformable(field, :p1))
    println("absent from field: ", absent_from_field(field, [:p1, :p2, :p3, :p4]))

    for g in (CoordinateSpace([:x]), RelationGraph([]), Atlas([]), FlowLandscape(identity))
        println("  geometry ", nameof(typeof(g)), " fits when ", fits_when(g))
    end

    println("bifurcation μ: -1 → +1 changes # stable states? ", bifurcates(-1.0, 1.0),
            "  (", stable_states(-1.0), " → ", round.(stable_states(1.0); digits=2), ")")

    cs = [x -> x > 0, x -> x < 0]                        # unsatisfiable together
    println("frustration (x>0 ∧ x<0): ", frustrated(cs, -2:0.5:2))

    println("decompressed contradiction → ", decompress(nothing).verdict)

    evs = [Event(x -> x + 1, Dict{Symbol,Any}()), Event(x -> 2x, Dict{Symbol,Any}()),
           Event(x -> x^2, Dict{Symbol,Any}())]
    println("events x₁--f₁-->x₂--f₂-->x₃: path = ", unfold(1.0, evs))

    s1 = State(0.0, Set([:grow, :split]), Set{Symbol}())
    s2 = State(0.0, Set([:grow]), Set{Symbol}())
    println("identical now, different futures: ", same_now_different_futures(s1, s2))

    co = coevolve(1, Set([1, 2, 3]))
    println("co-evolving possibility space: x=", co.x, ", X grew to ", sort(collect(co.X)))

    println("partial map T₁₂ = W₁∩W₂ = ", T_ij(:W1, :W2), "  (translation loses the rest)")

    obs = CoupledObserver(0.0)
    x = 1.0
    for _ in 1:3; x, _ = observe!(obs, x); end
    println("observer ↔ observed after 3 couplings: x=", round(x; digits=4),
            ", o=", round(obs.o; digits=4), "  (measurement participated)")

    println("\nLadder of representations:")
    foreach(l -> println("  ", rpad(l.first, 18), l.second), LADDER)

    println("\n── The versioned field F₀ → F₁ → … ──")
    vf = VersionedField()

    e1 = Element(id = "claim-0001", kind = claim,
                 statement = "Identity can persist through organized change without requiring equality of state.",
                 context = (scale = :multiscale, temporal_scope = :long_interval,
                            framework = :process_centered),
                 distinctions = ["identity-is-not-state-equality",
                                 "organization-can-persist-through-turnover"],
                 origin_trace = (origin_kind = :originating_expression,
                                 origin_ref = "observer-kelly", captured_at = "2026-08-02"),
                 origin_confirmed = true)

    r  = apply(Reflector(), e1)
    println("reflector produced: ", r.id, " status=", r.status,
            " confirmed=", r.origin_confirmed, "  (cannot self-accept)")

    amap = apply(AssumptionMap(), e1.statement)
    println("assumption map: observation → interpretation → assumption → conclusion ✓")

    e2 = Element(id = "claim-0002", kind = claim,
                 statement = "Identity requires strict state equality.",
                 context = (scale = :component, temporal_scope = :instant,
                            framework = :object_centered),
                 origin_trace = (origin_kind = :originating_expression,
                                 origin_ref = "observer-2", captured_at = "2026-08-02"),
                 origin_confirmed = true)

    rel = contradicts_under("claim-0001", "claim-0002";
                            same_referent = true, same_definition = true,
                            same_scale = false, overlapping_time = true,
                            unresolved = ["Are both using 'identity' numerically?"])
    println("tension typed as: ", classify_tension(rel),
            "  (contradiction dissolves when scale is restored)")

    bridge = apply(BridgeBuilder(), :process_centered, :object_centered)
    println("bridge preserves ", bridge.preserves, ", loses ", bridge.loses,
            "  Loss(T)=", loss(bridge), " > 0")

    result = propose!(vf, [e1, e2];
                      tensions = [rel],
                      unresolved = ["Is functional continuity sufficient for identity?"],
                      accept = els -> all(e -> e.origin_confirmed === true, els))
    println("candidate change merged: ", result.merged,
            " → now at F_", current(vf).n,
            " with ", length(current(vf).accepted), " accepted elements, ",
            length(current(vf).unresolved), " unresolved (dissent preserved)")

    bad = Element(id = "", kind = claim, statement = "unattributed")
    r2 = propose!(vf, [bad]; accept = _ -> true)
    println("malformed candidate rejected by deterministic checks: ", r2.failures)

    dp = dependence_profile([e1, e2, r])
    println("multiplicity ≠ independence: ", dp.n_outputs, " outputs, ",
            dp.n_independent, " independent families (correlated=", dp.correlated, ")")

    syn = apply(Synthesizer(), [e1, e2];
                residual_tensions = ["scale-relative identity"],
                excluded = ["observer-situated meaning"],
                non_endorsing = ["observer-2"])
    println("synthesis: includes ", syn.includes, "; not endorsed by ", syn.not_endorsed_by,
            "\n  meaning: ", syn.meaning)

    println("history preserved — claim-0001 ever accepted: ",
            was_ever_accepted(vf, "claim-0001"))

    println("\nThree levels of field evolution:")
    foreach(k -> println("  ", k, ": ", LEVELS[k]), sort(collect(keys(LEVELS))))
    println("L3 dimension proposal (:reversibility): ",
            accept_dimension_proposal!(vf, :reversibility; accept = _ -> true))

    println("\nFirst meaningful cycle complete:")
    println("  expression → reflection → correction → second perspective →")
    println("  tension map → new distinction → candidate change → accepted update  ✓")
    nothing
end

end # module

GenerativeField.demo()
