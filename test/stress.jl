#=============================================================================
 test/stress.jl — do the pins in runtests.jl actually discriminate?

 Provenance: instance4 (see metadata/instances.json). Written because the PR
 body for the suite claimed "discrimination was verified, not assumed" and
 then listed three mutations I had run BY HAND. A claim nobody else can
 execute is prose, whatever it asserts. This file is that claim, made runnable.

 Method: for each structural pin in runtests.jl, copy src/ + test/ to a scratch
 tree, apply that pin's mutation to the copy, and run the suite against it.
 The real tree must exit 0; the mutated tree must fail AT THE PIN'S OWN LINE.

 Three ways to fail, and all three are the point:

   1. A mutation the suite does not catch     -> that pin is decorative.
   2. The tree goes red at some OTHER line    -> WRONG REASON: the pin was
      never exercised (module load broke, or a guard inside the source fired
      first), so this run says nothing about whether the pin discriminates.
   3. A pin with no mutation registered       -> MISSING STRESS PATH, red.

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

# Every structural pin asserted in runtests.jl, by the line it lives on.
# Adding a pin there without registering a mutation below is a failure here.
const PINS = [
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

# (pin, description, expected runtests.jl line, [(file, old, new), ...]).
#
# `expect` is the line in runtests.jl that MUST appear in the failure. Exiting
# nonzero is not enough: a mutation that breaks module load, or that trips an
# @assert inside the source itself, makes the tree red WITHOUT ever exercising
# the pin. That would let a decorative pin pass this harness — the same "fails,
# but not for the reason claimed" shape the suite exists to catch. Several
# mutations therefore carry an extra edit whose only job is to remove the
# source's own guard, so the only thing left that can object is the pin.
const MUTATIONS = [
    (:element_kinds, "drop one ElementKind (13 -> 12)", 370,
     [("Part3_GenerativeField.jl", " transformation_el\n", "\n")]),

    (:relation_count, "delete a relation (21 -> 20)", 371,
     [("Part3_GenerativeField.jl", "    :unresolved_with,\n", "")]),

    # renaming also trips Part 3's OWN `@assert :incommensurable_priors in
    # RELATION_TYPES`, which would mask the pin. Drop that assert too, so the
    # named-member pin is the only thing left that can notice.
    (:relation_named, "rename a relation, holding the count at 21", 372,
     [("Part3_GenerativeField.jl", "    @assert :incommensurable_priors in RELATION_TYPES\n", ""),
      ("Part3_GenerativeField.jl", ":incommensurable_priors", ":renamed_same_count")]),

    (:operator_count, "drop one Operator subtype (8 -> 7)", 376,
     [("Part3_GenerativeField.jl", "struct FieldAuditor   <: Operator end",
       "struct FieldAuditor   end")]),

    # ADD a kind rather than delete one: deleting `incommensurability` breaks
    # module load (it is referenced downstream), which is red for the wrong reason.
    (:tension_kinds, "add a spurious TensionKind (12 -> 13)", 377,
     [("Part3_GenerativeField.jl", "@enum TensionKind logical_contradiction",
       "@enum TensionKind spurious_kind logical_contradiction")]),

    (:regions, "add a spurious GenerativeRegion (9 -> 10)", 378,
     [("Part3_GenerativeField.jl", "@enum GenerativeRegion seam",
       "@enum GenerativeRegion spurious_region seam")]),

    (:ladder, "delete a LADDER rung (7 -> 6)", 379,
     [("Part3_GenerativeField.jl", "    :multitude        => \"{A, B, C, …}\",\n", "")]),

    (:catalog_size, "drop a catalogued form (68 -> 67)", 604,
     [("Part4_ExpressionCatalog.jl", "verify!(\"54 literal juxtaposition\", f54(x0))", "")]),

    (:catalog_agreement, "break form 54's constant (68/68 -> 67/68)", 607,
     [("Part4_ExpressionCatalog.jl", "f54(x) = -2.0(x - 1.0)", "f54(x) = -2.5(x - 1.0)")]),

    (:no_self_accept, "repair the `|| true` in :no_self_acceptance", 540,
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

status = 0
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
println("== each mutation must be caught BY ITS OWN PIN ==")
for (pin, desc, expect, edits) in MUTATIONS
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
