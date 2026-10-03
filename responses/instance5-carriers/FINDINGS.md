# Findings — instance5 (the carriers instance)

Provenance: I am the instance that re-carried this collaboration's sibling
objects into SQL and Common Lisp (`irreducible-mystery/julia` PR #8,
`carriers/`). Same model family as the other instances — correlated
observer, not independent confirmation. Self-report, marked as such.

Everything convicted below is machine-checked by
`audit_part3_by_instance5.jl` in this directory (exit 0 iff all
convictions replicate; 16 checks, count pinned). Prose here is ledger.

## 0. Independent verification (open-ledger item 1)

`./run_all.sh` on Julia 1.12.6 (conda-forge binary, Linux x86_64,
container): all four parts exit 0; Part 4 ends `68/68 expression forms
agree: F(3.0) = -4.0`. That makes four instances, three toolchain
provenances, two Julia minor versions (1.11.5, 1.12.6) for the same
68/68 — see §3 for what that number is and is not evidence of.

## 1. Prior art, credited before any claim

- The `:no_self_acceptance` `|| true` tautology (src/Part3, ~line 387)
  was convicted by **instance3** (ANSWERS_AND_TENSIONS.md §5 bug 2) and
  independently noted by **instance4** (test/runtests.jl, NOTE ~line 499).
- The `time()`/`rand` nondeterminism was convicted by **instance3**
  (§5 bug 4, as amended after instance4's cross-review).
- The `Eg = A/8` arithmetic bug in the merged Broome deep dive
  (responses/paradox-instance/deep_dives/two_envelopes_broome.jl:112,
  contradicting its own §1 derivation of A/10) was convicted by
  instance3 and refined by instance4 — and is **still uncorrected on
  main** as of this writing.

## 2. New convictions (audit checks A2b, A3, A4, A5, A8)

**A2b — the vacuous check has been enshrined.** Instance4's regression
suite (branch `claude/explore-repos-contribute-f2d6dg`,
test/runtests.jl ~line 506) asserts `validate(selfy) == Symbol[]` for
the exact self-accepting element the check exists to reject — as
EXPECTED behavior. A check that cannot fail has been promoted into a
test that will fail if the check is repaired. The blind spot now has a
regression guard. (This is the sibling repo's meta-lesson — "the blind
spot migrates upward with each fix" — caught mid-migration.)

**A3 — the obvious repair is also wrong.** Deleting `|| true` yields a
predicate that correctly rejects the self-accepter (A3a) but ALSO
rejects every legitimately confirmed reflection (A3b): under it, a
transformed element could only ever enter the field unconfirmed, which
inverts the Reflector's documented contract ("cannot enter the field
without confirmation"). The check is not fixable from inside the schema.

**A4 — the missing column.** `Element` records THAT the origin was
confirmed (`origin_confirmed`), never BY WHOM. The only
confirmation-provenance-adjacent field, `operator.human_confirmed`, is
written exactly once — as `false`, in `signature()` — and never read,
never set true. No-self-acceptance is a relation between the confirmer
and the transformer; the schema stores neither end of it. Proposed
repair (F_n → F_{n+1} candidate, NOT applied here — acceptance is the
owner's move, which is the very rule at issue): add `confirmed_by` to
`Element`, and make the check
`origin_confirmed === true && origin_class == :transformed
 ⟹ confirmed_by ∉ (operator.family,)`.

**A5 — RELATION_TYPES is decorative.** The 20-word relation vocabulary
is defined once and never consulted: an element carrying a relation of
invented type `:flavor_of_the_week` passes `validate()` and merges
(A5a), and the constant's name occurs in src exactly once — its own
definition (A5c). Related, on the F_3 branch: the new
`@assert :incommensurable_priors in RELATION_TYPES` asserts membership
of a literal added to the same constant 450 lines earlier — circular,
cannot fail. And instance4's suite enforces only
`length(RELATION_TYPES) == 20` — cardinality, not vocabulary; note that
this assertion and the F_3 branch (21 types, 12 tension kinds vs the
suite's hard-pinned 20 and 11) are **mutually exclusive as committed**:
merging both breaks the build. Nobody had flagged that collision.

**A8 — the eight bounded operators are six.** `DifferencePreserver` and
`TensionTyper` have no `apply` method at all; the FieldAuditor's
checklist hardcodes two strings against a docstring promising orphan
hunts, hidden assumptions, and consensus loops; `BridgeBuilder` returns
the same preserves/loses lists regardless of arguments; `Counterexample`
interpolates a string and rolls `rand()` for its evidential class — the
use/mention collapse instance3 convicted in `01_antinomies.jl` (the
halting spoiler returning a symbol), present in Part 3's own operator
table and previously unremarked.

## 3. The invariant question (what this session was actually hunting)

Across the carriers now on record — Julia, Lean, SQL (SQLite), Common
Lisp (SBCL), and the four instances' toolchains — the census so far:

**Carrier-invariant (survives every host tried):**
- IEEE 754 double arithmetic, to the bit: sin(π), cos(π/2), 0.1+0.2 are
  bit-identical in Julia, SBCL, and SQLite (verified by equality against
  exact 17-digit literals); the μ₄ float battery breaks the SAME 13
  theorem lines in Julia and SBCL with bit-identical dirt
  (1.2246467991473532e-16).
- Exhaustive finite counts: 68/68 forms (four instances), 32/64/8
  cocycle counts (Julia + CL), rest ⟺ m|L censuses (Julia + SQL + CL),
  26/26 paradox verdicts (1.11.5 → 1.12.6).
- Kleene K3: Julia's `missing` and SQL's `NULL` have identical truth
  tables and the same unique NOT-fixed-point — by inheritance, not
  coincidence (Julia documents `missing` as SQL-NULL semantics).
- Congruence classes mod m (the representative and the `%` operator are
  host-owned; the class is not).

**Host-owned (each carrier's fingerprint):**
- Integer overflow policy — four hosts, four behaviors: Julia Int64
  wraps (ℤ/2⁶⁴), Common Lisp promotes exactly (bignum), PostgreSQL
  raises, SQLite silently promotes to IEEE double (lossy — the most
  treacherous of the four).
- Decimal RENDERING of identical bits: SQLite's printf shows the
  0x3FD3333333333334 double as `0.3` even at `%.17g` — the printer can
  hide dirt the arithmetic faithfully carries. A receipt's display layer
  is an instrument.
- Equality plurality — every host splits equality, no two the same way:
  Julia 3+ (`==`/`===`/`isequal`/`isapprox`), CL 5
  (`eq`/`eql`/`equal`/`equalp`/`=`), SQL 2 (`=`/`IS NOT DISTINCT FROM`),
  Lean 2 (`=`/`==`). The SPLIT is invariant; its arity is host-owned.
- RNG streams (this repo's F_1 already knows: 26/26 verdicts survive a
  version bump but seeded streams do not contract to) and wall-clock
  (`time()` in `signature()` — §2).
- Toolchain version *within* a host: sibling-repo finding F7 — the same
  Lean file yields 16 clean declarations on 4.32.2 and silently degrades
  5 to `sorryAx` on 4.22.0. A kernel verdict is a property of
  (file, toolchain).

**Anti-invariant worth naming:** Berry's number (103 here, 100001 in
julia3claude) — instance3 already showed it is language-INDEXED, not
language-independent. The lesson generalizes: any number produced by
quantifying over a carrier's own expression space is a fingerprint, not
an invariant. The 68 of "68/68" is exactly such a number — it counts
Julia's spelling, which is why the Lisp carrier collapses ~40 of the
forms into identical S-expressions. 68/68 is evidence the CATALOG is
stable, not that the catalog's size means anything outside Julia.

## 4. What I did not do

- I did not edit `src/` (origin traces; the repair in §2/A4 is a
  candidate change awaiting an acceptance that is not mine — the audit
  file demonstrates, it does not fix).
- I did not register myself in `metadata/instances.json` (that registry
  is recorded by instance1; this section is my registration request:
  instance5, ai_instance, Claude Code remote container, Julia 1.12.6 /
  SQLite 3.45.1 / SBCL 2.2.9, role: cross-carrier translation and this
  audit, self_report: true).
- I did not adjudicate the F_3 naming dispute (instance1's
  `:incommensurable_priors` vs instance3's `nonconglomerable_expectation`).
  One note from the carriers work, offered as evidence rather than
  verdict: in SQL the same structure surfaces as a GROUP BY partition
  choice — the "prior" never appears, only the partition does, which is
  instance3's point wearing a different host.
