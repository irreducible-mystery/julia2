# ============================================================
# BQN's ¬ SEAM-FOR-SEAM — negation as ARITHMETIC (1-x)
# Prolog's seams: absence≠falsity, order trap, double-negation gap,
# loop detonation. Where are BQN's? Every seam is where "not" and
# "1 minus" stop agreeing.
# ============================================================

•Out "=== 1. ¬ is literally 1-x: total on ALL numbers ==="
•Out "  ¬0, ¬1:        "∾•Fmt ¬0‿1
•Out "  ¬0.3:          "∾•Fmt ¬0.3
•Out "  ¬2:            "∾•Fmt ¬2
•Out "  ¬¯5:           "∾•Fmt ¬¯5
•Out "  Prolog's \\+ is partial (flounders); ¬ is total. No 'cannot be"
•Out "  proven' exists here -- every input HAS a negation. The Closed"
•Out "  World seam is gone... because there is no world, only numbers."
•Out ""
•Out "=== 2. The involution seam: when is ¬¬x = x? ==="
•Out "  ¬¬0.3 = "∾•Fmt ¬¬0.3
•Out "  ¬¬¯7  = "∾•Fmt ¬¬¯7
•Out "  CONFESSION (kept, per protocol): this file's first draft said"
•Out "  'ALWAYS -- 1-(1-x)=x is algebra.' The machine refused: ¬¬0.3"
•Out "  printed 0.30000000000000004. The involution holds in R and"
•Out "  FAILS in float64 -- my claim was about the abstraction, the"
•Out "  run was about the carrier. So BQN's double-negation law is"
•Out "  EXACT on integers-in-float and dyadic rationals, approximate"
•Out "  elsewhere: even the classical law you buy is horizon-graded."
•Out "  (Prolog's \\+ \\+ G =/= G is a PROOF gap; intuitionism's ~~G"
•Out "  =/= G is a CONSTRUCTION gap; float ¬¬x =/= x is a CARRIER gap.)"
•Out ""
•Out "=== 3. De Morgan seam: ∧∨ are ×(+-×) -- laws hold only on 0‿1 ==="
•Out "  on Booleans: ¬(a∧b) ≡ (¬a)∨(¬b)?  "∾•Fmt (¬∧⌜˜0‿1)≡{(¬𝕨)∨(¬𝕩)}⌜˜0‿1
•Out "  off-domain:  a=2, b=0.5:"
•Out "    ¬2∧0.5     = "∾•Fmt ¬2∧0.5
•Out "    (¬2)∨(¬0.5) = "∾•Fmt (¬2)∨(¬0.5)
•Out "  De Morgan BREAKS off 0‿1: ∧ is ×, ∨ is +-×, and the identities"
•Out "  1-ab = (1-a)+(1-b)-(1-a)(1-b) hold iff a,b∈0‿1 (or fuzzy [0,1]:"
•Out "  there they're Łukasiewicz-ish but ∧ is product t-norm, not min)."
•Out "  The seam: BQN exports 'not' beyond logic, and the LAWS quietly"
•Out "  become CONTINGENT identities true on a subdomain."
•Out ""
•Out "=== 4. The fixed-point seam (the Liar's home) ==="
•Out "  ¬0.5 = "∾•Fmt ¬0.5
•Out "  Prolog: liar detonates Clark completion / goes UNDEFINED in WFS."
•Out "  BQN: x=¬x is an EQUATION, solution ½. The liar seam is not"
•Out "  avoided -- it is RELOCATED into the codomain. Cost: ½ is not a"
•Out "  truth value anyone asserted; it is where the algebra says the"
•Out "  oscillation balances. Meaning was traded for solvability."
•Out ""
•Out "=== 5. The comparison seam: ¬ vs ≠ vs 'not equal to anything' ==="
•Out "  (0.1+0.2)≠0.3?  "∾•Fmt (0.1+0.2)≠0.3
•Out "  (and a meta-seam caught live: my first draft wrote 0.1+0.2≠0.3"
•Out "   unparenthesized -- BQN's right-to-left parse made it 0.1+(0.2≠0.3)"
•Out "   = 1.1. The NOTATION has seams too.)"
•Out "  Absence-of-equality is IEEE ≠, a DIFFERENT negation than ¬, with"
•Out "  its own seams (float dirt). BQN has two nots that never meet:"
•Out "  arithmetic ¬ (total, classical) and comparison ≠ (bitwise on"
•Out "  representations). Prolog also had two (\\+ vs dif/2). Pattern:"
•Out "  EVERY language that splits negation splits it along proof/value."