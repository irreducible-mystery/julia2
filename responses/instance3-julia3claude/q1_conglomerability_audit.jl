# ======================================================================
# q1_conglomerability_audit.jl — instance 3's answer to Q1, in code.
#
# CLAIM (settling the question the deep-dive left open): Broome
# non-conglomerability is INVISIBLE IN PRINCIPLE to Part 2's machinery —
# not merely unencoded. Every Part-2 construct (sampled clouds, discrete
# prior vectors, tolerance checks on points) is finite, and finite
# partitions ALWAYS conglomerate: the law of total expectation is an
# identity on finite spaces. The deep-dive's closing line ("the
# commutation diagram π∘F ≈ G∘π fails non-removably") therefore
# overclaims: in Part-2's own terms nothing fails — there is no F, no G,
# and no finite object on which the two partition-totals can disagree.
#
# But invisibility of the FAILURE is not invisibility of its SHADOW.
# Section 3 builds the mechanical check that does work: an escaping-mass
# audit, semidecidable, `missing`-valued — the same epistemic shape as
# fuel-bounded halting.
#
# Also fixed here: the deep-dive's section 3 uses E[gain|A] = A/8; its
# own section 1 derives A/10 (P(small|A) = 2/5 ⇒ (2/5)A − (3/5)(A/2)).
# The divergence conclusion survives; the printed sums were 1.25× off.
# ======================================================================

section(t) = println("\n── ", t, " ", "─"^max(0, 64 - length(t)))

p(n) = (1/3) * (2/3)^n              # Broome prior on pairs (2^n, 2^(n+1))

# ----------------------------------------------------------------------
section("1 · finite partitions always conglomerate (the blindness, proven)")
# ----------------------------------------------------------------------
# Truncate at pair N, renormalize — this is the ONLY kind of object a
# sampled cloud / discrete prior vector can hold. Compute E[gain] three
# ways: raw, by-pair partition, by-amount partition.
function truncated(N)
    Z = sum(p(n) for n in 0:N)
    # microstates: (pair n, holds_small) — weight, observed amount, gain
    micro = [(w = p(n) / Z / 2, A = holds ? 2.0^n : 2.0^(n + 1),
              g = holds ? 2.0^n : -2.0^n)
             for n in 0:N for holds in (true, false)]
    total     = sum(m.w * m.g for m in micro)
    by_pair   = sum(sum(m.w * m.g for m in micro if m.A in (2.0^n, 2.0^(n+1)) &&
                        abs(m.g) == 2.0^n) for n in 0:N)
    amounts   = unique(m.A for m in micro)
    by_amount = sum(sum(m.w * m.g for m in micro if m.A == a) for a in amounts)
    (; total, by_pair, by_amount)
end
println("        N     total        Σ by pairs    Σ by amounts   (all must agree)")
for N in (5, 10, 20, 40)
    t = truncated(N)
    println("      ", rpad(N, 6), rpad(round(t.total, digits = 10), 13),
            rpad(round(t.by_pair, digits = 10), 14), round(t.by_amount, digits = 10))
end
println("""
      Identical at every N — the law of total expectation is an IDENTITY
      on finite spaces. No finite grid, sample cloud, or prior vector can
      exhibit two partition-totals that disagree. Part 2's fusion and
      commutation checks operate exclusively on such objects; the Broome
      pathology cannot be encoded as a failed check. Verdict on Q1:
      INVISIBLE — and provably so, not contingently.""")

# ----------------------------------------------------------------------
section("2 · yet the SHADOW is visible at every N: escaping mass")
# ----------------------------------------------------------------------
# The paradox is the boundary cell (top amount, certainly-large) whose
# weight × magnitude does NOT vanish as N grows: (p(N)/2)·2^N ∝ (4/3)^N.
# Non-conglomerability at ∞ ≡ escaping mass along the truncation family.
boundary_mass(N) = (p(N) / sum(p(n) for n in 0:N)) / 2 * 2.0^N
println("      boundary-cell |weight × gain| by truncation:")
for N in (5, 10, 20, 40)
    println("        N = ", rpad(N, 4), round(boundary_mass(N), digits = 3))
end
println("      Growing without bound — the ghost is measurable long before ∞.")

# ----------------------------------------------------------------------
section("3 · the mechanical check Part 5 can actually run")
# ----------------------------------------------------------------------
"""
    conglomerability_audit(cellwise; Ns) -> true | missing

`cellwise(N)` returns the vector of (weight, conditional_value) cells of a
partition at truncation N. Returns `true` (conglomerable so far: max cell
contribution vanishing) or `missing` (escaping mass detected — the
partition family shows the non-conglomerability signature). Like
fuel-bounded halting it can never return a grounded `false`: the audit is
SEMIDECIDABLE, and `missing` is the honest verdict — K3 arrives in the
validation layer for the same reason it arrived in the Liar.
"""
function conglomerability_audit(cellwise; Ns = (10, 20, 40))
    masses = [maximum(abs(w * v) for (w, v) in cellwise(N)) for N in Ns]
    issorted(masses) && masses[end] > 10 * masses[1] && return missing
    true
end

byamount_cells(N) = begin
    Z = sum(p(n) for n in 0:N)
    cells = [(p(0) / Z / 2, 1.0)]                              # A = 1: sure-small
    for n in 1:N                                               # interior amounts
        push!(cells, ((p(n-1) + p(n)) / Z / 2, 2.0^n / 10))    # E[gain|A] = A/10 ✓
    end
    push!(cells, (p(N) / Z / 2, -2.0^N))                       # top: sure-large
    cells
end
bypair_cells(N) = [(p(n), 0.0) for n in 0:N]                   # exchangeable pairs

println("      audit(by-amount partition) = ",
        repr(conglomerability_audit(byamount_cells)))
println("      audit(by-pair partition)   = ",
        repr(conglomerability_audit(bypair_cells)))
println("""
      The by-amount family flags `missing` (escaping mass); the by-pair
      family passes. Disagreement between the audits of two partitions of
      one space is precisely the machine-checkable residue of Broome.
      Proposed relation, replacing `incommensurable_priors`:

          nonconglomerable_expectation(prior, integrand, partition_A, partition_B)

      — a misnomer repaired: Broome's prior is a single, perfectly proper
      prior. Nothing is incommensurable between PRIORS; the conflict is
      between PARTITIONS, given an infinite-mean integrand. Filing it
      under the wrong name would misdirect every future query.""")
