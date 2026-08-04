-- | Antinomy exhibits re-carried into Haskell.
--
-- Origin traces:
--   responses/paradox-instance/paradoxes/01_antinomies.jl  (instance2)
--   PR #9 WFS-vs-Kripke truth-teller tension (instance6)
--   PR #5 K3/missing fixed-point observations (instance3)
--
-- What this carrier can and cannot show:
--   * Classical fixed-point search over {True,False} — empty for the Liar.
--   * Maybe-as-K3: Nothing is a fixed point of a three-valued negation.
--   * Strengthened Liar re-erupts when "not even Nothing" is asked.
--   * Truth-teller under two three-valued policies (a tiny dial).
--   * Haskell cannot natively loop-overflow the way Julia Tasks can without
--     fuel; fuel-bounded regress is the honest host-shaped exhibit.
--
-- Instance: instance7-haskell-rust. Correlated observer.

module Main where

import System.Exit (exitSuccess)

section :: String -> IO ()
section t = putStrLn $ "\n" ++ replicate 70 '═' ++ "\n  " ++ t ++ "\n" ++ replicate 70 '═'

verdict :: String -> IO ()
verdict v = putStrLn $ "  VERDICT: " ++ v

--------------------------------------------------------------------------------
-- Kleene K3 on Maybe Bool  (Nothing = undefined/missing)
--------------------------------------------------------------------------------

-- Strong Kleene negation: ¬T=F, ¬F=T, ¬U=U
k3not :: Maybe Bool -> Maybe Bool
k3not (Just b) = Just (not b)
k3not Nothing  = Nothing

-- Strong Kleene OR
k3or :: Maybe Bool -> Maybe Bool -> Maybe Bool
k3or (Just True)  _            = Just True
k3or _            (Just True)  = Just True
k3or (Just False) (Just False) = Just False
k3or _            _            = Nothing

-- Curry operator on K3:  x ↦ (¬x ∨ ⊥)  which is extensionally ¬x on K3
-- (instance6's observation that curry_op ≡ liar_op on K3 when the consequent is false).
curryOp, liarOp :: Maybe Bool -> Maybe Bool
liarOp  = k3not
curryOp x = k3or (k3not x) (Just False)

--------------------------------------------------------------------------------
-- Fuel-bounded diagonal
--------------------------------------------------------------------------------

-- liar n = not (liar (n-1)); at 0, refuse.
fuelLiar :: Int -> Either String Bool
fuelLiar 0 = Left "infinite regress — sentence never grounds"
fuelLiar n = case fuelLiar (n - 1) of
  Left e  -> Left e
  Right b -> Right (not b)

--------------------------------------------------------------------------------
-- Main exhibits
--------------------------------------------------------------------------------

main :: IO ()
main = do
  putStrLn "── Haskell carrier: antinomy exhibits (re-carrying) ──"

  section "THE LIAR — classical fixed-point search"
  let classical = [v | v <- [True, False], v == not v]
  putStrLn $ "    {v ∈ {True,False} : v == not v} = " ++ show classical
  putStrLn "    ← EMPTY: no classical truth value"
  verdict "ANTINOMY — does not resolve classically"

  section "THE LIAR — fuel-bounded regress (host-honest divergence)"
  case fuelLiar 10000 of
    Left e  -> putStrLn $ "    fuelLiar 10000 → 💥 " ++ e
    Right b -> putStrLn $ "    unexpected value: " ++ show b
  verdict "ANTINOMY — host shows divergence only under a fuel budget (no Task stack)"

  section "THE LIAR — K3 escape via Maybe (Nothing = missing)"
  let u = Nothing :: Maybe Bool
  putStrLn $ "    k3not Nothing == Nothing : " ++ show (k3not u == u)
  putStrLn "    ← Nothing is the unique K3 fixed point of negation"
  putStrLn "    …but the Strengthened Liar («not even Nothing») re-erupts:"
  let strengthened = filter (\v -> v /= Nothing && v == k3not v)
                            [Just True, Just False, Nothing]
  putStrLn $ "    {v ∈ K3 : v ≠ Nothing ∧ v == k3not v} = " ++ show strengthened
  putStrLn "    ← EMPTY again one level up (Tarski rent)"
  verdict "DISPLACED, not resolved — K3 buys a fixed point, pays a meta-liar"

  section "CURRY vs LIAR on K3 (instance6 gate-gap exhibit)"
  let domain = [Just True, Just False, Nothing]
      extEqual = and [curryOp v == liarOp v | v <- domain]
  putStrLn $ "    curryOp ≡ liarOp on K3 (consequent=False): " ++ show extEqual
  putStrLn "    ← A Curry row that uses (¬x ∨ ⊥) tests the Liar twice under two names."
  putStrLn "    Coverage of the hard Curry (with contraction) is asserted, not shown."
  verdict "TENSION — gate labels ≠ gate extensions (PR #9 §2 replication on Haskell)"

  section "TRUTH-TELLER dial: T ≡ T  under two grounded policies"
  -- Policy A (Kripke-LFP style on finite K3): least fixed point from Nothing.
  -- Iterate Φ(I)(tt) = I(tt) starting from Nothing; stays Nothing.
  -- Policy B (a WFS-flavoured collapse): unfounded if only self-supported → False.
  let kripkeTruthTeller = Nothing :: Maybe Bool   -- least FP: undefined
      wfsTruthTeller    = Just False              -- unfounded → false
  putStrLn $ "    Kripke-LFP truth-teller : " ++ show kripkeTruthTeller
  putStrLn $ "    WFS-style truth-teller  : " ++ show wfsTruthTeller
  putStrLn $ "    agree? " ++ show (kripkeTruthTeller == wfsTruthTeller)
  putStrLn "    ← Same sentence, two least-fixed-point operators, two values."
  putStrLn "    (PR #9 tension, re-hosted. Dial exists; boundary not swept here.)"
  verdict "FRAME-RELATIVE — truth-teller value is a policy choice, not a fact"

  section "QUINE shape without the bang (harmless self-ref)"
  -- A quine-ish fixed point of the identity on strings: s is its own description.
  let desc s = s
      sample = "this string"
  putStrLn $ "    desc sample == sample : " ++ show (desc sample == sample)
  putStrLn "    Self-reference without negation is idle — the bang installs the antinomy."
  verdict "CONTROL — diagonal without negation does not explode"

  putStrLn ""
  putStrLn "── end paradox carrier ──"
  exitSuccess
