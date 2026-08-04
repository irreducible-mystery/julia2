# Paradoxes Across Domains, Translated into Julia

*Which paradoxes resolve, which do not — demonstrated in executable code.*

---

## 1. The Taxonomy (after Quine)

Philosophers since W.V.O. Quine sort paradoxes into three kinds, and the sorting
turns out to predict **exactly how each one behaves when you compile it**:

| Class | Definition | Resolves? | How it shows up in Julia |
|---|---|---|---|
| **Veridical** | The conclusion is *true*; only intuition rebels | ✅ Yes — compute it and the shock dissolves | Simulation / exact arithmetic confirms the "absurd" answer |
| **Falsidical** | The conclusion is *false*; a hidden fallacy lurks | ✅ Yes — expose the broken step | Julia *refuses* the broken step: `DivideError`, `DomainError`, `NaN`, non-convergence |
| **Antinomy** | Sound-looking reasoning yields genuine contradiction | ❌ **No** — only displaced by changing the logic or banning the construction | `StackOverflowError`, empty fixed-point sets, oscillating state, refuted oracles |
| *(bonus)* **Ill-posed** | The "paradox" is an underspecified question | ⚪ *Dissolves* rather than resolves | Three different `rand()` protocols, three different answers (Bertrand) |

The deep result visible in the code: **every unresolvable paradox is the same
paradox** — a diagonal construction of the form `x = not(x)`. The Liar, Russell,
Grelling, Curry, Turing's halting problem, and Berry are one machine wearing
five costumes. And the quine (§ 5) shows the machine is harmless until you
install the `!`.

---

## 2. The Antinomies — DO NOT RESOLVE (`01_antinomies.jl`)

### The Liar — *"This sentence is false"* — 6 Julia expressions

Julia's expressiveness lets one paradox take six different shapes:

1. **Recursive function** — `liar() = !liar()` → `StackOverflowError`. The
   run-time stack *is* the infinite regress made physical.
2. **Fixed-point search** — `[v for v in (true,false) if v == !v]` → `Bool[]`.
   The empty vector is Julia's way of saying *no classical truth value exists*.
3. **Multiple dispatch** — `truth(::Liar) = !truth(::Liar)`: the paradox as a
   method on a type.
4. **Gas-limited regress** — unfolding the sentence never reaches ground.
5. **Macro expansion** — `@liar` expands into its own negation: paradox at
   *compile* time, via homoiconicity.
6. **Three-valued escape** — Julia ships Kleene's K3 logic natively:
   `!missing === missing`. `missing` is the unique fixed point of `!`, so the
   Liar can be *assigned* the third value... but the Strengthened Liar ("this
   sentence is not even missing") re-erupts one level up. **Displaced, not
   resolved** — this is Julia enacting Tarski's theorem that no sufficiently
   expressive language can contain its own truth predicate.

### Russell's Paradox — 4 expressions
- Julia happily builds a self-membered set (`Ω ∈ Ω` is `true` — Julia is
  naturally *non-well-founded*, like Aczel's set theory).
- But enforcing the Russell set's own definition on itself makes membership
  **oscillate forever**: `∈ ∉ ∈ ∉ ∈ ∉ …` — the loop is the contradiction.
- Higher-order form `russell(f) = !f(f); russell(russell)` → stack overflow:
  the pure λ-calculus diagonal.
- ZFC "resolves" it only by **outlawing the construction** (restricted
  comprehension) — the programming equivalent of "don't write that expression."

### Curry's Paradox — worse than the Liar
`C ≡ (C → "pigs fly")`. The fixed-point search shows classical logic has *no
consistent assignment unless pigs fly* — Curry proves anything, and needs no
negation, so even some paraconsistent logics fall to it.

### The Halting Problem — the Liar compiled
`trouble() = halts(trouble) ? loop : halt`. The code builds the spoiler
*against every candidate oracle* and refutes each one live. The empirical
Collatz checker can only ever answer `true` or `missing` — undecidability
means the grounded `false` is forever out of reach.

### Berry's Paradox — actually computed
The script enumerates **every ≤7-character Julia expression** over
`{1,2,3,+,*,^}`, finds the smallest positive integer none of them denotes —
and then notes that the phrase *"the smallest number not expressible in ≤7
chars"* just named it. Resolution requires stratifying object language from
metalanguage (Tarski); inside one self-applicable language it does not resolve.

---

## 3. Mathematical Paradoxes — RESOLVE (`02_mathematical.jl`)

| Paradox | Type | Julia resolution |
|---|---|---|
| **Zeno's dichotomy** (5 expressions) | Falsidical | Exact `Rational` partial sums, `Iterators.accumulate` for Achilles, closed form `r/(1-r)` — infinitely many steps, **finite** sum |
| **Grandi's series** 1−1+1−⋯ | Falsidical | Partial sums oscillate (no limit); Cesàro means → ½ — each "answer" is a *different definition of summation* |
| **Gabriel's Horn** | Veridical | Numerical integration: volume → π while area grows as 2π·log(X) → ∞. Both true |
| **Hilbert's Hotel** | Veridical | Lazy infinite iterators: `n→n+1` frees a room, `n→2n` frees infinitely many, Cantor pairing rooms ∞ buses — verified collision-free |
| **"1 = 2" proofs** | Falsidical | Julia *is* the fallacy detector: `÷0` → `DivideError`, `0/0` → `NaN`, `sqrt(-1.0)` → `DomainError`, and in ℂ, √(ab)=√a√b visibly fails |
| **Float paradoxes** | Falsidical | `0.1+0.2 ≠ 0.3`, non-associative `+`, `typemax(Int)+1 < 0`, `NaN ≠ NaN` — resolved by `Rational`, `BigInt`, `isequal` |
| **Potato paradox** | Veridical | Three lines of arithmetic: 100 kg → 50 kg |
| **Wheel of Aristotle** | Falsidical | The inner wheel *slips*: rolling distance ≠ circumference |

---

## 4. Probability Paradoxes — mostly RESOLVE (`03_probability.jl`)

- **Monty Hall** — 4 expressions: full protocol simulation, a one-liner
  (`P(win|switch) = P(first pick wrong)`), *exact* enumeration with `Rational`
  (no dice at all), and the killer control experiment: an **ignorant host**
  destroys the 2/3 advantage. The paradox lives in the host's knowledge.
- **Birthday** — exact product formula vs. simulation; `binomial(23,2) = 253`
  pairs explains the intuition failure.
- **Simpson's** — the real 1973 Berkeley data: women do as well or better in
  most departments yet worse overall. Both computations are true; they answer
  *different causal questions*. Resolves via confounding.
- **Parrondo** — two provably losing games, alternated, **win** (simulated:
  A loses, B loses, ABAB wins, even *random* mixing wins). Veridical; powers
  real Brownian-ratchet physics.
- **Two Envelopes** — simulation shows switching gains nothing; the broken
  step (treating "A" as fixed in both branches) is exposed line by line. *But*
  the unbounded-prior variant keeps philosophers employed — flagged honestly.
- **St. Petersburg** — partial expectations diverge, yet five separate 100k-game
  empirical means are single-digit. "Resolves" only by **changing the model**:
  log utility (Bernoulli) or finite bankrolls — expectation alone was the
  wrong yardstick.
- **Bertrand's chord** — three impeccable sampling protocols, three answers
  (1/3, 1/2, 1/4). Each `rand()` call is a different philosophical commitment.
  **Dissolves**: the question was ill-posed.
- **Benford** — first digits of 2^k match log₁₀(1+1/d) to three decimals.

---

## 5. The Edge Cases (`04_vagueness_selfreference.jl`)

### Sorites — the paradox with no *neutral* resolution
Five rival logics, all runnable side by side:
1. Classical + tolerance → `heap(1) = true` — absurdity, computed.
2. Epistemicism → a sharp cutoff hidden in an opaque closure (it *exists*, you can't inspect it).
3. Fuzzy logic → `μ_heap ∈ [0,1]` — but "exactly 0.5-heap" is a new sharp line (higher-order vagueness).
4. Supervaluationism → truth-value *gaps* over a set of admissible cutoffs.
5. Julia's `missing` as the gap, natively.

**Verdict: every "solution" abandons one intuition. You pick your poison.**

### The Quine — the control experiment
A two-line Julia program that prints its own source, **executed and verified**
(`source == output → true`). Same diagonal self-reference as the Liar — but the
quine says *"print me"* (a fixed point that exists) while the Liar says
*"negate me"* (a fixed point that doesn't). Conclusion, visible in code:

> **Antinomy = self-reference ∘ negation.** Self-reference alone is innocent.

### Gödelian coda
Swap the Liar's "false" for "unprovable" and the unresolvable antinomy becomes
the *resolved* crown jewel of logic: a sentence that is true but unprovable —
incompleteness instead of contradiction.

---

## 6. Why Julia Specifically

The task asked for as many expressions as the language allows. Julia's features
map onto paradox-anatomy unusually well:

| Julia feature | Paradox it expresses |
|---|---|
| Recursion + `StackOverflowError` | Infinite regress of the Liar/Curry/Russell |
| `missing` (Kleene K3, built-in) | Truth-value gaps; the Liar's third value |
| `Rational`, `BigInt`, `BigFloat` | Exact resolutions of Zeno & float "paradoxes" |
| `NaN`, `Inf`, IEEE semantics | A value not equal to itself — by design |
| Lazy infinite iterators | Hilbert's Hotel: countable infinity as a first-class object |
| Multiple dispatch | Paradoxes as *types* with self-referential methods |
| Macros / homoiconicity | Liar at compile time; Berry's expression-enumeration |
| Tasks (green threads) | Sandboxing a divergent paradox in its own universe to watch it implode |
| Monte Carlo + exact enumeration | Veridical probability paradoxes double-checked two ways |
| `DomainError` / `DivideError` | The type system as a built-in fallacy detector |
| Quines (via `repr`/`replace`) | Benign self-reference — the control group |

## 7. The One-Sentence Summary

**Paradoxes that resolve are computations that terminate with a surprising
value; paradoxes that don't resolve are computations that cannot terminate at
all — and Julia lets you watch both happen.**

---

### Files
- `01_antinomies.jl` — Liar (6 forms), Grelling, Russell (4 forms), Curry (3 forms), Halting, Berry, Interesting-Number
- `02_mathematical.jl` — Zeno (5 forms), Grandi, Gabriel's Horn, Hilbert's Hotel (3 forms), 1=2 fallacies, machine arithmetic, Potato, Aristotle's Wheel
- `03_probability.jl` — Monty Hall (4 forms), Birthday, Simpson (real data), Parrondo, Two Envelopes (3 forms), St. Petersburg (4 forms), Bertrand (3 methods), Benford
- `04_vagueness_selfreference.jl` — Sorites (5 logics), executable Quine, Gödel sketch
- `run_all.jl` — runs everything; `output.txt` — the full captured run
