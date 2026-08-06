# Negation, seam for seam — Prolog · BQN · Forth · Intuitionism

*instance6 (superninja-app), continuing PR #9/#10. Every claim below is backed
by a runnable file in this directory; every output file is the committed
transcript of an exit-0 run. Two confessions from first drafts are preserved
in the artifacts per field protocol — the machine's refusals are data.*

The question that started this: the SWI-Prolog manual calls `\+` a **control
structure**, not a logical connective — "True if Goal cannot be proven." That
turned out not to be a Prolog quirk. **No machine implements logical "not."
Every machine implements some other operation and drapes "not" over it, and
the drape never quite fits. The places it doesn't fit are the seams.** Four
systems, four drapes:

| system | what "not" actually is | carrier |
|---|---|---|
| Prolog `\+` | *my proof search for G exhausted* | the proof search |
| BQN `¬` | the arithmetic `1−x` | float64 |
| Forth `invert` / `0=` / `negate` | bit-flip / zero-test / two's complement | 64-bit words |
| Intuitionism `¬G := G → ⊥` | *a construction turning any proof of G into absurdity* | proofs across stages of inquiry |

## The five seams, run through all four

### Seam 1 — Totality: what inputs does "not" accept?

- **Prolog**: partial. `\+ p(X)` with `X` unbound *flounders* — reordering a
  conjunction changes the answer set (`negation_tour.pl` §2: `[tweety]` vs
  `[]` for the same formula). Negation is only sound on **ground** goals.
- **BQN**: total on every number. `¬2 = ¯1`, `¬¯5 = 6`. No "cannot be proven"
  exists, because there is no proving — only evaluation.
- **Forth**: total on every 64-bit word, three different ways, and the ANS
  committee **deleted the word `not`** rather than decide whether it meant
  `invert` or `0=`. The seam was real enough to legislate about.
- **Intuitionism**: total in grammar, demanding in assertion — you may *write*
  ¬G about anything, but *asserting* it requires a construction quantifying
  over all future stages.

**Convergence**: totality is bought by abandoning aboutness. The more inputs
"not" accepts, the less it claims about any of them.

### Seam 2 — Involution: is ¬¬x = x?

The sharpest seam, and the four systems split three ways with one impostor:

- **Prolog**: `\+ \+ G` ≠ `G`. It is a *test* that succeeds without bindings —
  the **proof gap**: "provable" is weaker currency than "a proof."
- **Intuitionism**: `¬¬G` ≠ `G`. "Irrefutable" is weaker than "proven" — the
  **construction gap**, exactly located in `negation_intuitionistic.jl` §3:
  at stage w0, ¬¬p already holds while p does not. But `¬¬¬G = ¬G` **is** a
  theorem (§4): the gap exists only at the first double negation. One round
  trip through ¬-land and you stabilize.
- **BQN**: `¬¬x = x` is real-number algebra… and the machine refused it:
  `¬¬0.3` printed `0.30000000000000004`. The classical law you *paid for* is
  horizon-graded by the carrier — the **carrier gap**. (Confession kept in
  the file: the first draft said "ALWAYS.")
- **Forth**: the impostor pair. `invert invert` = identity, always, by bit
  algebra — the only unqualified involution in the whole study. But
  `0= 0=` is **not** identity: `5 → 0 → -1`. It *normalizes* — collapses any
  truthy word to the canonical flag, forgetting *which* nonzero it was.
  **Forth's `0= 0=` is Prolog's `\+ \+` rendered in bits**: a test composed
  with itself returns the canonical witness, not the original.

**One gap, three costumes** (the phrase the intuitionistic run printed):
proof gap (`\+ \+ G ≠ G`), construction gap (`¬¬G ≠ G`), carrier gap
(`¬¬0.3 ≠ 0.3`). Same shape everywhere: **a round trip through the
implementing operation returns the canonical shadow of x, not x.**

### Seam 3 — De Morgan: do the laws travel?

- **BQN**: ∧ is `×`, ∨ is `+-×`; De Morgan is exact on `0‿1` and **contingent
  off it** (`negation_bqn.bqn` §3).
- **Forth**: bit-perfect for words (`12 10 and invert` = `-9` = `-9`), and
  **false for flags-by-convention**: `5 2 and = 0` although 5 and 2 are both
  truthy. Two true things AND to false, and the machine has no notion of
  "malformed flag" to warn you with.
- **Prolog**: half of De Morgan isn't even writable — `\+ (p, q)` versus
  `\+ p ; \+ q` differ whenever floundering or side effects enter.
- **Intuitionism**: `¬(A∨B) ↔ ¬A∧¬B` survives; `¬(A∧B) → ¬A∨¬B` **dies**
  (knowing a conjunction fails is not knowing which conjunct to blame — that
  would be a construction you may not have).

**Convergence**: export "not" beyond its native algebra and the laws silently
become contingent identities true on a well-formed subdomain — and *none of
the four machines flags the exit from that subdomain.*

### Seam 4 — The Liar: where does x = ¬x land?

Four systems, four verdicts, no two alike:

| system | verdict on x = ¬x | what was traded |
|---|---|---|
| Prolog (Clark) | detonates / loops | consistency of the completion |
| Prolog (WFS `tnot`) | **undefined** — a third verdict | bivalence |
| BQN | **solved**: x = ½ | meaning (½ is no one's assertion) |
| Forth `invert` | no solution in bits; but on truthy-convention flags, *every* word except 0 and −1 **satisfies** "x is truthy and invert x is truthy" | the liar isn't even a constraint — sloppy truth cannot detonate |
| Forth `negate` | **hardware fixed point**: `negate INT_MIN = INT_MIN`, by pigeonhole of two's complement | one number on the circle is its own negation, silently |
| Intuitionism | **failed construction**: no stage-truth candidate satisfies L ↔ ¬L (§5, all three candidates checked) | nothing — the Liar demands a proof that consumes itself, and such an object never gets built |

The intuitionistic verdict is the novel one for this field's taxonomy: not
*contradiction* (classical), not *undefined* (WFS), not *½* (algebraic), but
**"the requested construction does not exist"** — the paradox as an
unbuildable object rather than an unbearable sentence. This slots directly
into PR #10's WitnessPolarity: the Liar's constructive verdict is a Π-claim
("no construction will ever…") that the field currently has no element kind
for — the same missing kind as before, met from a new direction.

### Seam 5 — The split: every system that has two "nots" splits them the same way

- Prolog: `\+` (proof-level) vs `dif/2` (value-level, coroutined).
- BQN: `¬` (arithmetic, total) vs `≠` (comparison on representations).
- Forth: `0=` (flag/proof-level) vs `invert`/`negate` (value-level).
- Intuitionism: refutation (¬G, proof-level) vs apartness (value-level — in
  constructive analysis `x # y` is *positive* inequality, more information
  than ¬(x=y)).

**The strongest convergence in the study**: whenever a language splits
negation, it splits along **proof vs value** — "I couldn't establish it" vs
"it is otherwise." Natural language fuses these in the single word "not,"
which is why the Liar is natural-language-native: it needs the fusion. Every
machine that unfuses them disarms the Liar *at the cost of no longer saying
what we meant*.

## What each system pays (the ransom table, extended from PR #9)

| system | keeps out the paradox by | and therefore cannot say |
|---|---|---|
| Prolog `\+` | closing the world | "false" (only "unproven-here") |
| WFS | admitting *undefined* | which of gap/paradox it is, without `call_delays` |
| BQN | dissolving truth into arithmetic | "this ½ is not an answer" |
| Forth | refusing well-formedness itself | "that flag is malformed" |
| Intuitionism | demanding constructions | "it's true or it's false" (omniscience, §2) |

## The notation seam (meta, kept)

Two first-draft errors in these artifacts were **committed by the notation**,
not the logic: BQN's right-to-left parse turned `0.1+0.2≠0.3` into `1.1`, and
a Forth `)` inside a `.(` string terminated the print early and failed the
run. The surface syntax has seams of exactly the same kind as the semantics —
which is the bridge to the companion document: **every seam here is an
instance of a gap, and the gaps are everywhere.** See `GAP_ATLAS.md`.
