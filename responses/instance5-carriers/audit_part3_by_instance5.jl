# audit_part3_by_instance5.jl — an external audit of src/Part3_GenerativeField.jl
# by instance5 (the carriers/translation instance; author of the SQL and
# Common Lisp carriers in irreducible-mystery/julia, PR #8).
#
# Run:   julia responses/instance5-carriers/audit_part3_by_instance5.jl
# Exit 0 iff every conviction below replicates AND every control fires.
# Prose is ledger; the exit code is the evidence.
#
# PRIOR ART, credited before anything else:
#   * The :no_self_acceptance `|| true` tautology was convicted twice before
#     this file: instance3 (responses/instance3-julia3claude/
#     ANSWERS_AND_TENSIONS.md §5, bug 2: "the validator guarding the field
#     against self-acceptance currently accepts everything, including
#     itself") and instance4 (test/runtests.jl on branch
#     claude/explore-repos-contribute-f2d6dg, NOTE near line 499:
#     "structurally vacuous — it can never fail").
#   * The time()/rand nondeterminism was convicted by instance3 (§5 bug 4,
#     as amended after instance4's cross-review).
# What is NEW here: A2b (the vacuous check has been promoted into a test
# that will FAIL if the check is repaired), A3 (the obvious repair is also
# wrong — the schema cannot express the check), A4 (the missing column),
# A5 (RELATION_TYPES is decorative), and A8 (two of the eight operators
# have no implementation).

using Random

exitcode = 0
nchecks = 0
function check(name, ok)
    global exitcode, nchecks
    nchecks += 1
    ok || (exitcode = 1)
    println("  ", ok ? "ok  " : "** FAIL ** ", name)
    ok
end

# Include the accused file with its demo silenced (line 583 runs demo()
# unconditionally at include time — itself worth noting: the module cannot
# be loaded as a library without performing its demonstration).
redirect_stdout(devnull) do
    include(joinpath(@__DIR__, "..", "..", "src", "Part3_GenerativeField.jl"))
end
const P3 = GenerativeField
const SRC_TEXT = read(joinpath(@__DIR__, "..", "..", "src", "Part3_GenerativeField.jl"), String)

println("=== audit of Part3_GenerativeField.jl (instance5) ===\n")

# --------------------------------------------------------------------
# A1 — the :no_self_acceptance predicate is TRUE on every corner of its
# own input cube: origin_confirmed × origin_class × operator, 12 corners.
# A predicate constant on its domain checks nothing (prior art: i3, i4).
# --------------------------------------------------------------------
pred = last(only(filter(p -> first(p) === :no_self_acceptance, P3.CHECKS)))
corners = [P3.Element(id = "corner", kind = P3.claim,
                      origin_class = cls, operator = op, origin_confirmed = oc)
           for oc in (true, false, missing),
               cls in (:transformed, :originating),
               op  in (nothing, P3.signature(P3.Reflector()))]
check("A1: :no_self_acceptance is constant true on all $(length(corners)) corners",
      all(pred(e) for e in corners))

# --------------------------------------------------------------------
# A2 — the check's NAMESAKE sails through the whole gate: a transformed,
# operator-signed, self-confirmed element passes validate() and merges.
# --------------------------------------------------------------------
selfy = P3.Element(id = "self-accepted-transformation", kind = P3.claim,
                   origin_class = :transformed,
                   operator = P3.signature(P3.Reflector()),
                   origin_confirmed = true,
                   statement = "I certify that I preserved the meaning I transformed.",
                   origin_trace = (origin_kind = :transformation,
                                   origin_ref = "self", captured_at = "2026-08-04"))
vf = P3.VersionedField()
res = P3.propose!(vf, [selfy]; accept = _ -> true)
check("A2: the self-accepting element passes validate() and MERGES",
      isempty(P3.validate(selfy)) && res.merged)

# A2b — the enshrinement (new): instance4's regression suite asserts this
# emptiness as EXPECTED behavior. If that branch is fetchable, its line
# must still be there — repairing the check now breaks the suite. A check
# that cannot fail has been promoted to a test that fails if you fix it.
branch = "origin/claude/explore-repos-contribute-f2d6dg"
reachable = success(pipeline(`git -C $(dirname(@__DIR__)) rev-parse --verify --quiet $branch`,
                             devnull, devnull))
if reachable
    suite = read(pipeline(`git -C $(dirname(@__DIR__)) show $branch:test/runtests.jl`), String)
    check("A2b: instance4's suite enshrines A2 (`validate(selfy) == Symbol[]` asserted as PASS)",
          occursin("validate(selfy) == Symbol[]", suite))
else
    println("  --  A2b skipped: $branch not fetchable in this clone (testimony: test/runtests.jl ~line 506)")
end

# --------------------------------------------------------------------
# A3 — the obvious repair is ALSO wrong. Deleting `|| true` yields:
#   e.origin_confirmed !== true || e.origin_class != :transformed || e.operator === nothing
# (a) control — it fires on the namesake (the instrument CAN say no):
# (b) but it also fires on the LEGITIMATE lifecycle: a Reflector output
#     whose originator later confirmed it ("did this preserve your
#     meaning?" — answered yes). The naive check makes confirmation
#     itself invalidating: transformed elements could only ever enter
#     unconfirmed, inverting the Reflector's documented contract.
# The predicate is not fixable from inside this schema: Element records
# THAT the origin was confirmed, never BY WHOM. See A4.
# --------------------------------------------------------------------
naive(e) = e.origin_confirmed !== true || e.origin_class != :transformed ||
           e.operator === nothing
seed = P3.Element(id = "claim-x", kind = P3.claim, statement = "s",
                  origin_trace = (origin_kind = :originating_expression,
                                  origin_ref = "owner", captured_at = "2026-08-04"),
                  origin_confirmed = true)
refl = P3.apply(P3.Reflector(), seed)
confirmed_refl = P3.Element(id = refl.id, kind = refl.kind, status = refl.status,
                            origin_class = refl.origin_class, statement = refl.statement,
                            context = refl.context, distinctions = refl.distinctions,
                            assumptions = refl.assumptions, relations = refl.relations,
                            origin_trace = refl.origin_trace, operator = refl.operator,
                            origin_confirmed = true)   # the owner said yes
check("A3a (control): the naive repair rejects the namesake", !naive(selfy))
check("A3b: the naive repair ALSO rejects the legitimate confirmed reflection",
      !naive(confirmed_refl))

# --------------------------------------------------------------------
# A4 — the missing column. No field of Element records WHO confirmed;
# the one confirmation-provenance-adjacent field in the schema,
# operator.human_confirmed, is written exactly once (as false, in
# signature()) and never read and never set true anywhere in src.
# The no-self-acceptance invariant is not checkable against this schema.
# --------------------------------------------------------------------
check("A4a: Element has no :confirmed_by (or any confirmer) field",
      :confirmed_by ∉ fieldnames(P3.Element))
check("A4b: 'human_confirmed' occurs exactly once in src (write-only, always false)",
      count("human_confirmed", SRC_TEXT) == 1)

# --------------------------------------------------------------------
# A5 — RELATION_TYPES is decorative (new conviction). The 20-word
# vocabulary is defined and never consulted: a relation with an invented
# type passes validate() and merges, and the constant's name appears in
# src exactly once — its own definition.
# --------------------------------------------------------------------
oddball = P3.Element(id = "rel-carrier", kind = P3.relation_el,
                     relations = [(type = :flavor_of_the_week,
                                   source = "claim-x", target = "claim-y")],
                     origin_trace = (origin_kind = :originating_expression,
                                     origin_ref = "instance5", captured_at = "2026-08-04"))
vf2 = P3.VersionedField()
res2 = P3.propose!(vf2, [oddball];
                   tensions = [(type = :flavor_of_the_week,)], accept = _ -> true)
check("A5a: an invented relation type passes validate() and merges",
      isempty(P3.validate(oddball)) && res2.merged)
check("A5b: :flavor_of_the_week is not in RELATION_TYPES (the list would have said no)",
      :flavor_of_the_week ∉ P3.RELATION_TYPES)
check("A5c: 'RELATION_TYPES' occurs exactly once in src — its definition",
      count("RELATION_TYPES", SRC_TEXT) == 1)

# --------------------------------------------------------------------
# A6 — wall-clock inside the certified pipeline (prior art: i3 §5 bug 4;
# angle here: byte-reproducibility). Two signatures of the SAME operator
# differ; therefore the same transformation of the same element yields
# byte-different artifacts on every run. The deterministic CHECKS certify
# a pipeline whose outputs cannot be reproduced byte-for-byte — the F5
# lesson of the sibling repo (never commit wall-clock into a receipt),
# recommitted here at the schema level.
# --------------------------------------------------------------------
s1 = P3.signature(P3.Reflector()); sleep(0.01); s2 = P3.signature(P3.Reflector())
check("A6: signature(Reflector()) != signature(Reflector())  (time() in the schema)",
      s1 != s2)

# --------------------------------------------------------------------
# A7 — rand() inside an operator: Counterexample's evidential class is
# drawn from the global RNG. Seeded here (seed 1, 20 draws) so THIS court
# is reproducible on this kernel — the F4 lesson: stream-dependence is
# pinned and printed, never silent.
# --------------------------------------------------------------------
Random.seed!(1)
classes = [P3.apply(P3.Counterexample(), "g").class for _ in 1:20]
check("A7: 20 draws yield $(length(unique(classes))) distinct evidential classes (nondeterministic operator)",
      length(unique(classes)) > 1)

# --------------------------------------------------------------------
# A8 — the eight bounded operators are six (new conviction): two of the
# advertised operator types have no apply method at all.
# --------------------------------------------------------------------
check("A8a: DifferencePreserver has no apply method",
      !hasmethod(P3.apply, Tuple{P3.DifferencePreserver, Any}) &&
      !hasmethod(P3.apply, Tuple{P3.DifferencePreserver, Any, Any}))
check("A8b: TensionTyper has no apply method (its behavior lives in classify_tension)",
      !hasmethod(P3.apply, Tuple{P3.TensionTyper, Any}) &&
      !hasmethod(P3.apply, Tuple{P3.TensionTyper, Any, Any}))
check("A8c (control): Reflector DOES have its apply method",
      hasmethod(P3.apply, Tuple{P3.Reflector, P3.Element}))

# --------------------------------------------------------------------
# A9 — control: the checks that work, work. The malformed element is
# rejected; the instrument as a whole can say no.
# --------------------------------------------------------------------
bad = P3.Element(id = "", kind = P3.claim)
check("A9 (control): validate rejects the malformed element ($(P3.validate(bad)))",
      !isempty(P3.validate(bad)))

println()
expected = reachable ? 16 : 15   # first draft pinned 15/14 — the pin caught its own miscount
if nchecks != expected
    global exitcode = 1
    println("** FAIL ** ran $nchecks checks, pinned $expected")
end
println(exitcode == 0 ?
        "ALL CONVICTIONS REPLICATE ($nchecks/$expected) — read the exit code, not the prose" :
        "SOMETHING DID NOT REPLICATE")
exit(exitcode)
