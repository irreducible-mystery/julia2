#=============================================================================
 test/stress.jl — do the pins in runtests.jl actually discriminate?

 Provenance: instance4 (see metadata/instances.json). Written because the PR
 body for the suite claimed "discrimination was verified, not assumed" and
 then listed three mutations I had run BY HAND. A claim nobody else can
 execute is prose, whatever it asserts. This file is that claim, made runnable.

 Method: for each structural pin in runtests.jl, copy src/ + test/ to a scratch
 tree, apply that pin's mutation to the copy, and run the suite against it.
 The real tree must exit 0; the mutated tree must fail AT THE PIN'S OWN LINE.

 Five ways to fail, and all five are the point:

   1. A mutation the suite does not catch     -> that pin is decorative.
   2. The tree goes red at some OTHER line    -> WRONG REASON: the pin was
      never exercised (module load broke, or a guard inside the source fired
      first), so this run says nothing about whether the pin discriminates.
   3. A pin with no mutation registered       -> MISSING STRESS PATH, red.
   4. A vocabulary count in the suite that is registered nowhere here
                                              -> UNREGISTERED PIN, red. This
      one is derived from runtests.jl rather than from my list, so forgetting
      to update the list is itself caught.
   5. A mutation whose anchor no longer resolves to exactly one line
                                              -> STALE / AMBIGUOUS ANCHOR, red.
      A mutation pointing at nothing, or at two things, cannot establish which
      assertion it exercised, so it is not allowed to report success.

 (2) is here because the first version of this file did not check it, and two
 of its ten "ok" results were reached without the pin ever running — red for
 the wrong reason, which is the exact defect the suite exists to catch, in the
 instrument built to catch it. Exit status alone is not evidence about a pin.

 (3) matters most. A pin without a stress path is a number nobody has tried to
 break; it can harden into "the shape of the field" while the suite reports
 green forever. Adding a pin to runtests.jl without adding a mutation here
 fails this file, by construction.

 Nothing in the repository is modified: every mutation is applied to a copy
 under mktempdir(), which is removed on exit.

 Run:  julia test/stress.jl      (exit 0 iff every pin is covered and catching)
=============================================================================#

const ROOT = normpath(joinpath(@__DIR__, ".."))

# The structural pins I SELECTED from runtests.jl. This is a choice, not a
# discovered fact about the file, and the earlier version of this comment said
# "every structural pin" — a completeness claim I could not back. It was also
# false: `length(instances(P2.Disagreement)) == 4` is an enum-inventory pin of
# exactly the same kind and I had missed it.
#
# Criterion, stated so it can be disagreed with: a pin here counts a MODULE-LEVEL
# vocabulary — an @enum's instances, a const collection, or a subtype set. Counts
# over per-fixture state (e.g. `length(P3.current(vf).accepted) == 2`) are
# deliberately excluded: they assert what one constructed example contains, not
# what the field's vocabulary is.
#
# The claim is no longer asserted, it is enforced: scan_unregistered() below
# re-derives the pin shape from runtests.jl and fails on anything matching it
# that is not registered here. Adding a vocabulary count to the suite without a
# mutation now fails this file whether or not I remembered to update this list.
const PINS = [
    :disagreement_kinds => "length(instances(P2.Disagreement)) == 4",
    :element_kinds     => "length(instances(P3.ElementKind)) == 13",
    :relation_count    => "length(P3.RELATION_TYPES) == 21",
    :relation_named    => ":incommensurable_priors in P3.RELATION_TYPES",
    :operator_count    => "count(T -> T <: P3.Operator ...) == 8",
    :tension_kinds     => "length(instances(P3.TensionKind)) == 12",
    :regions           => "length(instances(P3.GenerativeRegion)) == 9",
    :ladder            => "length(P3.LADDER) == 7",
    :catalog_size      => "length(P4.results) == 68",
    :catalog_agreement => "count(isapprox(target), values(P4.results)) == 68",
    :no_self_accept    => "@test_broken P3.validate(selfy) == [:no_self_acceptance]",
]

# (pin, description, ANCHOR TEXT in runtests.jl, [(file, old, new), ...]).
#
# The anchor is a distinctive substring of the assertion this mutation must
# trip; its line number is derived from the file at run time. An earlier
# version hardcoded line numbers, which meant inserting any line into the suite
# reported a REGISTERED pin as UNREGISTERED — red for the wrong reason, the
# defect this file exists to catch, reintroduced by the fix for it. Deriving
# the line removes the failure mode instead of documenting it.
#
# The derived line MUST appear in the failure. Exiting
# nonzero is not enough: a mutation that breaks module load, or that trips an
# @assert inside the source itself, makes the tree red WITHOUT ever exercising
# the pin. That would let a decorative pin pass this harness — the same "fails,
# but not for the reason claimed" shape the suite exists to catch. Several
# mutations therefore carry an extra edit whose only job is to remove the
# source's own guard, so the only thing left that can object is the pin.
const MUTATIONS = [
    (:disagreement_kinds, "add a spurious Disagreement kind (4 -> 5)",
     "length(instances(P2.Disagreement)) == 4",
     [("Part2_ProjectionObservation.jl", "@enum Disagreement measurement",
       "@enum Disagreement spurious_disagreement measurement")]),

    (:element_kinds, "drop one ElementKind (13 -> 12)",
     "length(instances(P3.ElementKind)) == 13",
     [("Part3_GenerativeField.jl", " transformation_el\n", "\n")]),

    (:relation_count, "delete a relation (21 -> 20)",
     "length(P3.RELATION_TYPES) == 21",
     [("Part3_GenerativeField.jl", "    :unresolved_with,\n", "")]),

    # renaming also trips Part 3's OWN `@assert :incommensurable_priors in
    # RELATION_TYPES`, which would mask the pin. Drop that assert too, so the
    # named-member pin is the only thing left that can notice.
    (:relation_named, "rename a relation, holding the count at 21",
     ":incommensurable_priors in P3.RELATION_TYPES",
     [("Part3_GenerativeField.jl", "    @assert :incommensurable_priors in RELATION_TYPES\n", ""),
      ("Part3_GenerativeField.jl", ":incommensurable_priors", ":renamed_same_count")]),

    (:operator_count, "drop one Operator subtype (8 -> 7)",
     "op_types) == 8",
     [("Part3_GenerativeField.jl", "struct FieldAuditor   <: Operator end",
       "struct FieldAuditor   end")]),

    # ADD a kind rather than delete one: deleting `incommensurability` breaks
    # module load (it is referenced downstream), which is red for the wrong reason.
    (:tension_kinds, "add a spurious TensionKind (12 -> 13)",
     "length(instances(P3.TensionKind)) == 12",
     [("Part3_GenerativeField.jl", "@enum TensionKind logical_contradiction",
       "@enum TensionKind spurious_kind logical_contradiction")]),

    (:regions, "add a spurious GenerativeRegion (9 -> 10)",
     "length(instances(P3.GenerativeRegion)) == 9",
     [("Part3_GenerativeField.jl", "@enum GenerativeRegion seam",
       "@enum GenerativeRegion spurious_region seam")]),

    (:ladder, "delete a LADDER rung (7 -> 6)",
     "length(P3.LADDER) == 7",
     [("Part3_GenerativeField.jl", "    :multitude        => \"{A, B, C, …}\",\n", "")]),

    (:catalog_size, "drop a catalogued form (68 -> 67)",
     "length(P4.results) == 68",
     [("Part4_ExpressionCatalog.jl", "verify!(\"54 literal juxtaposition\", f54(x0))", "")]),

    (:catalog_agreement, "break form 54's constant (68/68 -> 67/68)",
     "@test all(v -> isapprox(v, target; atol = 1e-9), values(P4.results))",
     [("Part4_ExpressionCatalog.jl", "f54(x) = -2.0(x - 1.0)", "f54(x) = -2.5(x - 1.0)")]),

    (:no_self_accept, "repair the `|| true` in :no_self_acceptance",
     "@test_broken P3.validate(selfy)",
     [("Part3_GenerativeField.jl",
       "                                  e.operator === nothing ||\n                                  true,",
       "                                  e.operator === nothing,")]),
]

"Copy src/ + test/ into `dst`, preserving the layout runtests.jl expects."
function stage(dst)
    for d in ("src", "test")
        cp(joinpath(ROOT, d), joinpath(dst, d))
    end
    # the harness must not recurse into itself
    rm(joinpath(dst, "test", "stress.jl"); force = true)
    dst
end

"Run the suite in `tree`; return (exitcode, first interesting line, full output)."
function run_suite(tree)
    out = IOBuffer()
    p = run(pipeline(ignorestatus(`julia $(joinpath(tree, "test", "runtests.jl"))`),
                     stdout = out, stderr = out))
    txt = String(take!(out))
    marker = ""
    for line in eachsplit(txt, '\n')
        if occursin("Test Failed", line) || occursin("Error During Test", line) ||
           occursin("LoadError", line) || occursin("Unexpectedly Pass", line)
            marker = strip(line); break
        end
    end
    (p.exitcode, marker, txt)
end

"Line of the unique assertion containing `anchor`; 0 if absent, -1 if ambiguous."
function anchor_line(anchor)
    src = readlines(joinpath(ROOT, "test", "runtests.jl"))
    hits = [i for (i, l) in enumerate(src) if occursin(anchor, l)]
    length(hits) == 1 ? hits[1] : (isempty(hits) ? 0 : -1)
end

"""
Re-derive the pin shape from runtests.jl. Any assertion counting a module-level
vocabulary must be registered above; if the suite grows one and nobody adds a
mutation, that is an unregistered pin and this file says so.
"""
function scan_unregistered(registered_lines)
    src = readlines(joinpath(ROOT, "test", "runtests.jl"))
    shape = r"@test\s+(length\(instances\(|count\(T ->|length\(P\d\.[A-Za-z_]+\))"
    found = Tuple{Int,String}[]
    for (i, line) in enumerate(src)
        occursin(shape, line) && !(i in registered_lines) &&
            push!(found, (i, strip(line)))
    end
    found
end

status = 0
println("== every mutation anchor must resolve to exactly one line ==")
const EXPECT = Dict{Symbol,Int}()
for (pin, desc, anchor, _) in MUTATIONS
    ln = anchor_line(anchor)
    if ln > 0
        EXPECT[pin] = ln
        println("  ok   $(rpad(string(pin), 19)) -> runtests.jl:$ln")
    elseif ln == 0
        println("  ** STALE ANCHOR ** $pin: \"$anchor\" not found in runtests.jl")
        global status = 1
    else
        println("  ** AMBIGUOUS ANCHOR ** $pin: \"$anchor\" matches more than one line")
        global status = 1
    end
end

println()
println("== baseline: the real tree must pass ==")
mktempdir() do d
    tree = stage(d)
    rc, _, _ = run_suite(tree)
    if rc == 0
        println("  ok   unmutated copy exits 0")
    else
        println("  ** FAIL ** unmutated copy exits $rc — the harness itself is wrong")
        global status = 1
    end
end

println()
println("== every pin must have a registered mutation ==")
covered = Set(m[1] for m in MUTATIONS)
for (pin, claim) in PINS
    if pin in covered
        println("  ok   $pin")
    else
        println("  ** MISSING STRESS PATH ** $pin  —  $claim")
        global status = 1
    end
end
for m in MUTATIONS
    if !(m[1] in Set(first.(PINS)))
        println("  ** ORPHAN MUTATION ** $(m[1]) targets no registered pin")
        global status = 1
    end
end

println()
println("== no unregistered vocabulary pins in the suite ==")
let missed = scan_unregistered(Set(values(EXPECT)))
    if isempty(missed)
        println("  ok   every vocabulary count in runtests.jl is registered")
    else
        for (ln, txt) in missed
            println("  ** UNREGISTERED PIN ** runtests.jl:$ln")
            println("       $txt")
        end
        global status = 1
    end
end

println()
println("== each mutation must be caught BY ITS OWN PIN ==")
for (pin, desc, _anchor, edits) in MUTATIONS
    haskey(EXPECT, pin) || continue
    expect = EXPECT[pin]
    mktempdir() do d
        tree = stage(d)
        stale = false
        for (file, old, new) in edits
            path = joinpath(tree, "src", file)
            body = read(path, String)
            if !occursin(old, body)
                println("  ** STALE MUTATION ** $pin: anchor not found in $file")
                println("       ($desc)")
                stale = true; break
            end
            write(path, replace(body, old => new, count = 1))
        end
        if stale
            global status = 1
            return
        end
        rc, marker, txt = run_suite(tree)
        want = "runtests.jl:$expect"
        if rc == 0
            println("  ** NOT CAUGHT ** $(rpad(string(pin), 18)) $desc")
            println("       mutated tree still exits 0 — this pin is decorative")
            global status = 1
        elseif !occursin(want, txt)
            println("  ** WRONG REASON ** $(rpad(string(pin), 18)) $desc")
            println("       tree went red, but NOT at $want — the pin was never exercised")
            isempty(marker) || println("       actual: $marker")
            global status = 1
        else
            println("  ok   $(rpad(string(pin), 18)) $desc")
            println("       tripped $want")
        end
    end
end

println()
if status == 0
    println("STRESS PASSED — $(length(PINS)) pins, all covered, all discriminating")
else
    println("STRESS FAILED")
end
exit(status)
