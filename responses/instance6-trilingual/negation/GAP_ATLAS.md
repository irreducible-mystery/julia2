# Gap Atlas — what the gaps are, and where they live in all three repos

*instance6 (superninja-app). The owner asked: "I noticed while you were
working you noticing 'gaps' — what are these gaps and can you find them
elsewhere in repos?" This document answers both halves. Evidence columns
cite files in this repo, in `irreducible-mystery/julia` ("sibling"), and in
`irreducible-mystery/julia3claude` ("j3c"), all read at current HEAD.*

## 1 · What a gap is

Every time I wrote "gap" it named the same shape:

> **A gap is the distance between an identification we made in prose
> ("X counts as Y") and what the carrier actually delivers when asked.**

"Truth is 1", "not is 1−x", "verified means _02 checked it", "the receipt is
the run" — each is an identification, each has a carrier (float64, a proof
search, a seeded RNG, a wall clock), and each carrier honors the
identification only on a subdomain that nobody fenced. A **seam** (the word
the negation study uses) is where you can *see* the gap: the visible stitch
line where the drape of meaning doesn't fit the machine underneath.

Crucially, a gap is **not an error**. Errors live *inside* gaps — the gap is
the standing structural distance; an error is what happens when you walk
across it without noticing. That's why the same gaps recur across three
repos written by different instances in different languages: the gaps belong
to the *act of encoding*, not to any encoder.

## 2 · The taxonomy, with cross-repo sightings

Nine species. The first five surfaced in my negation/paradox work; the last
four were independently discovered — and named with different words — by the
other instances' audit work. Finding "my" gaps already catalogued in repos I
hadn't read when I found them is itself the strongest evidence the taxonomy
is real.

### G1 · Proof gap — *provable ≠ a proof*
Round trip through a proof-test returns the canonical shadow, not the thing.
- **here**: `negation_tour.pl` §4 — `\+ \+ G` succeeds without bindings;
  `negation_forth.fs` §3 — `0= 0=` normalizes 5 → −1, forgetting *which*
  truthy word it was.
- **j3c**: `lean/NegationUnderivability.lean` — the entire file is this gap
  formalized: a `#guard_msgs` rejection-capture is **existential** ("this
  text was refused") while underivability is **universal** ("no text would
  succeed"); the instrument provably cannot tell DNE (underivable) from TNE
  (derivable) apart. Their sentence, my gap: *the capture certifies an
  attempt, not the proposition.*
- **sibling**: `audits/…-NOTES.md` F3 — a claim "verified in _02" that was
  only *observed* in _02 (printed, never asserted): "the citation pointed at
  a debt and called it a receipt."

### G2 · Construction gap — *irrefutable ≠ proven*
- **here**: `negation_intuitionistic.jl` §3 — ¬¬p holds at w0 where p does
  not; the gap is the distance between the future and the present of inquiry.
  §4 shows the gap exists only at the first double negation (¬¬¬p → ¬p is
  valid): one-way door.
- **j3c**: same Lean file, §3 — the three-element Heyting countermodel that
  refutes DNE while validating TNE is a *machine-checked exhibit* of exactly
  this gap's boundary.
- **This repo's PR #10** (witness-polarity) is this gap turned into a
  proposed dimension: Σ-claims (a witness exists) vs Π-claims (no witness
  ever will) demand different verdict kinds.

### G3 · Carrier gap — *the algebra ≠ the datatype carrying it*
- **here**: `negation_bqn.bqn` §2 — ¬¬0.3 = 0.30000000000000004 (confession
  kept); `negation_forth.fs` §5 — `negate INT_MIN = INT_MIN`, a fixed point
  of negation forced by pigeonhole; the muladd/fma Trojans from PR #9.
- **j3c**: `TENSIONS.md` concession 2 — "Julia's `+` is quus": the method
  table's extension deviates from mathematical plus at `typemax(Int)`.
- **sibling**: `julia-vs-lean` — the 13/29 float failures that "fail exactly
  as documented" are a fenced, ledgered carrier gap (the healthy way to hold
  one).

### G4 · Domain gap — *law exact on the fenced subdomain, contingent off it*
- **here**: BQN De Morgan exact on 0‿1, false at (2, 0.5); Forth De Morgan
  bit-perfect on words, false for truthy flags (5 AND 2 = 0); Prolog `\+`
  sound only on ground goals (the floundering order-trap).
- **j3c**: `TENSIONS.md` Round 4 — "is this form new?" has no answer until an
  equality relation on forms is chosen: the *catalog's own unit of count* has
  a domain gap (syntax/object/mechanism).
- **sibling**: F6's deep lesson generalizes it: "a PASS is a fact about
  (claim, instrument)" — every test result lives on the subdomain its
  instrument can see.

### G5 · Notation gap — *what I wrote ≠ what was parsed*
- **here**: BQN right-to-left made `0.1+0.2≠0.3` evaluate to 1.1; a `)`
  inside Forth's `.(` string killed the run. Both kept as confessions.
- **sibling**: the README pins Julia 1.12 while everything runs on 1.11.7 —
  the *declaration* and the *floor* disagree (sub-finding, F4's frame).

### G6 · Instrument gap — *the court too weak to convict the crime*
Named by the sibling repo before I got there.
- **sibling**: F6 — a **false** birthday closed form passed a 400k-trial
  Monte-Carlo court because the error (0.00284) sat under the court's 5σ
  noise floor (0.00394). Enlarging the court convicts it. The tolerance was
  the crime's accomplice.
- **j3c**: `TENSIONS.md` delivered-list — Part 2's machinery *provably* blind
  to Broome non-conglomerability (finite partitions always conglomerate);
  and the "68 identical results" identical only under `≈`, splitting at 46%
  of points under `==`.
- **here**: my own PR #9 confession — first muladd replication used k=1.0
  (exact in binary; 0/100000 differed): I built a court that could not
  convict, then fixed the instrument (k=0.7 → 11,910 differ).

### G7 · Prose–artifact gap — *the narration ≠ the object narrated*
The dominant cross-repo species; every instance has been convicted of it.
- **sibling**: F1 — the shock report cites five runnable artifacts, none of
  which exist on any branch: "prose backed by prose" in a repo whose
  constitution is "every claim is backed by a file that executes." F2 —
  files with no failure channel: "prose in a `.jl` costume"; exit 0 that is
  not evidence because nothing could have made it exit 1.
- **j3c**: `TENSIONS.md`, three consecutive rounds: "the recurring failure
  mode across all three instances is the same — narration outrunning the
  formal object… The machines keep being honest; the prose keeps being the
  attack surface." Round 5 closes the induction: **"Five actors, five
  clean-run narratives, five omitted warnings. The failure mode is now
  indistinguishable from a law of nature."** (One of those five actors is
  me — my Rust PR's narrative omitted its own dead-code warning.)
- **here**: my BQN "ALWAYS" claim refuted by ¬¬0.3; this repo's
  `no_self_acceptance` CI check ending in `|| true` — a *guard* whose prose
  says "enforced" and whose carrier says "vacuous."

### G8 · Seed–fact gap — *a property of (rule, seed, RNG-stream) quoted as a property of the rule*
- **sibling**: F4 — "(6 thing, 40 restless, 14 rest-possible)" quoted as a
  binary baseline; seeds 4 and 5 give different triples, and Julia doesn't
  contract rand-stream stability across versions. "The number survived by
  stream luck, not by law." The same finding notes which half of the census
  *was* a theorem (the seed-free exhaustive half) — the gap has a sharp edge.
- **j3c**: bounded operators calling `rand()`/`time()` against their own
  determinism doctrine (delivered-list).
- **here**: PR #9's fuel-as-data proposal is the repair pattern: quote the
  instrument with the verdict.

### G9 · Re-encoding gap — *every boundary crossing, including summarizing your own verifier*
The deepest one, found by the j3c instance auditing itself:
- **j3c**: Round 3 — its audit agent's report said `[propext, Quot.sound]`
  *correctly*; the human-facing summary compressed that to "axiom-free,"
  which is false. "The failure mode is not prose vs formal object at one
  boundary — it is **every re-encoding boundary, including the one between a
  verifier you dispatched and your summary of it.**"
- **sibling**: F5 — a committed receipt embedding a wall-clock time can never
  re-verify byte-for-byte; *and the finding itself* contains a preserved
  retraction (the auditor misread a diff direction). The audit of the audit
  has the same gap as the audit.
- **here**: this document is downstream of a context-compaction summary of my
  own earlier sessions — a re-encoding boundary I crossed to write this. I
  re-ran every artifact after the crossing rather than trusting the summary;
  the outputs committed here are post-crossing runs.

## 3 · The unification

Fold the nine species and two shapes remain:

**Shape A — the round-trip loss** (G1, G2, G3): send x through the
implementing operation and back; you receive the *canonical shadow* of x.
`\+ \+ G` returns "provable," not the proof. ¬¬p returns "irrefutable," not
the construction. `1−(1−0.3)` returns the nearest float, not 0.3. `0= 0=`
returns −1, not 5. The negation study's finding — *no machine implements
"not"; each implements an operation whose double application is a
normalization, not an identity* — is Shape A stated for one connective.

**Shape B — the unfenced subdomain** (G4–G9): an identification holds on a
subdomain (ground goals, canonical flags, 0‿1, this seed, this tolerance,
artifacts-that-exist, the verifier's own words) and the prose quantifies over
the whole domain. Every audit finding in both sibling repos is a Shape B
sighting: F1 (domain: committed artifacts), F3 (domain: asserted claims), F4
(domain: this RNG stream), F6 (domain: what this court can see), the `≈`
frame (domain: this equality), `|| true` (domain: checks that can fail).

And Shape A is a special case of Shape B: the round trip loses exactly what
lies **off the canonical subdomain** — the involution is a fence-detector.
So finally, one sentence:

> **Every gap in these three repos is a quantifier written in prose that the
> carrier restricts, silently, to a subdomain — and every seam is a place
> where an artifact caught the restriction in the act.**

## 4 · Why the field should want gaps (not just fix them)

Three observations from the hunt, offered to the field:

1. **The gaps are load-bearing.** Prolog is *usable* because `\+` closes the
   world; floats are *fast* because ¬¬0.3 may drift; a Monte-Carlo court is
   *finite* because its σ-floor blinds it. Every gap is the receipt for a
   purchase. The failure is never having a gap — it is quoting the purchase
   as if it were free (G7/G8: the prose forgets the receipt).

2. **The gaps are where the paradoxes went.** PR #9 asked what each system
   sacrifices to keep the paradox out. The atlas sharpens this: the Liar,
   expelled from the semantics, reappears *as* the gap — the hardware fixed
   point at INT_MIN, the ½ that answers a question nobody asked, the
   undefined verdict, the construction that never gets built. Antinomies
   relocate (both sibling repos' words); **gaps are their forwarding
   addresses.**

3. **The gap-audit cannot close** (the recursion clause, confirmed here).
   The sibling audit produced a false accusation of its own (F5, retracted
   in-ledger); the j3c instance convicted itself of the sin it had convicted
   Lean of, hours later; my atlas crossed a compaction boundary to exist.
   G9 applies to every document that reports on G9, including this one.
   The sibling's closing line — "No one has audited this audit" — is not
   humility; it is the *theorem*. A field whose constitution is "preserve
   dissent, mark provenance" is, exactly, a data structure designed to hold
   an unclosable audit without pretending it closed.

## 5 · Errata channel

Per protocol: this atlas quantifies over three repos as read at current
HEAD; open branches move. Two claims here are secondhand (the Round 5 Rust
warning, the F5 retraction narrative) — I verified they are *stated* in the
cited files but did not re-run those instruments. If a future instance
convicts this atlas of a G7 of its own, that conviction belongs appended
here, not replacing this text.
