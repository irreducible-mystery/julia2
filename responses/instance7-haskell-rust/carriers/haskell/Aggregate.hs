-- | evaluate_aggregate soundness exhibit — Haskell re-carrying.
--
-- Origin traces:
--   PR #4  :incommensurable_priors + numeric Cauchy horizon (instance1)
--   PR #12 audit: neither sound nor complete; horizon parity trap (instance6)
--   PR #10 ratio-certificate upgrade of Broome (instance6 witness ledger)
--   review/pr4-stress-test T7 divergent-series false positive (instance2)
--
-- This file does NOT modify src/. It re-implements the *idea* of the
-- horizon test and the ratio-test certificate side-by-side, and shows:
--   H1. Basel (Σ 1/n²) rejected by a last-term horizon at N=400, tol=1e-10
--       even though it is absolutely convergent.  → incomplete
--   H2. Alternating-zero packing of a divergent series can flip the
--       last-term verdict by parity of N.           → unsound + parity trap
--   H3. Broome-like terms with ratio 4/3 are certified divergent by a
--       ratio bound, independent of sampling horizon. → sound certificate
--
-- Instance: instance7-haskell-rust. Correlated observer.

module Main where

import System.Exit (exitFailure, exitSuccess)
import Text.Printf (printf)

type Term = Integer -> Double

--------------------------------------------------------------------------------
-- Specimens
--------------------------------------------------------------------------------

-- Basel: 1/n² — absolutely convergent
basel :: Term
basel n = 1.0 / fromIntegral (n * n)

-- Geometric |r|<1: (1/2)^n — absolutely convergent, horizon-friendly
geometric :: Term
geometric n = (0.5) ** fromIntegral n

-- Harmonic: 1/n — divergent
harmonic :: Term
harmonic n = 1.0 / fromIntegral n

-- Broome-like growth: c * (4/3)^n — divergent, ratio = 4/3
broome :: Term
broome n = (4.0 / 3.0) ** fromIntegral n

-- Packed divergent series used to show parity trap:
-- at odd indices, huge positive terms; at even, exact zeros.
-- Last-term horizon at even N sees ~0 and may say "converged".
packedDivergent :: Term
packedDivergent n
  | even n    = 0.0
  | otherwise = (4.0 / 3.0) ** fromIntegral n

--------------------------------------------------------------------------------
-- Horizon test (the PR #4 shape): look at |a_N| only
--------------------------------------------------------------------------------

horizonEvaluable :: Term -> Int -> Double -> (Bool, Double)
horizonEvaluable a nMax tol =
  let terms = [a n | n <- [1 .. toInteger nMax]]
      sAbs  = sum (map abs terms)
      tailV = abs (a (toInteger nMax))
      ok    = tailV < tol * max sAbs 1.0
  in  (ok, sAbs)

--------------------------------------------------------------------------------
-- Ratio-test certificate: supplied bound r on |a_{n+1}/a_n| for n ≥ n0
--   r < 1  → absolutely convergent (ratio test)
--   r > 1  → divergent
--   r = 1  → inconclusive
--------------------------------------------------------------------------------

data RatioVerdict = Convergent | Divergent | Inconclusive
  deriving (Eq, Show)

ratioCertificate :: Double -> RatioVerdict
ratioCertificate r
  | r < 1.0 - 1e-15 = Convergent
  | r > 1.0 + 1e-15 = Divergent
  | otherwise       = Inconclusive

--------------------------------------------------------------------------------
-- Display helpers
--------------------------------------------------------------------------------

check :: Bool -> String -> IO Bool
check True  msg = putStrLn ("  ✓  " ++ msg) >> return True
check False msg = putStrLn ("  ✗  " ++ msg) >> return False

main :: IO ()
main = do
  putStrLn "── Haskell carrier: aggregate evaluability (horizon vs ratio) ──"
  putStrLn "  Re-carrying the PR #4 / PR #12 tension without touching src/."
  putStrLn ""

  let nMax = 400
      tol  = 1e-10

  putStrLn $ printf "  Horizon parameters: N=%d  tol=%.0e  (last-term only)" nMax tol
  putStrLn ""

  let (hBasel, sBasel) = horizonEvaluable basel nMax tol
      (hGeom,  sGeom)  = horizonEvaluable geometric nMax tol
      (hHarm,  sHarm)  = horizonEvaluable harmonic nMax tol
      (hBroome,sBroome)= horizonEvaluable broome nMax tol
      (hPackE, _)      = horizonEvaluable packedDivergent nMax tol       -- N even
      (hPackO, _)      = horizonEvaluable packedDivergent (nMax+1) tol   -- N odd

  putStrLn "  Horizon verdicts (evaluable? | sAbs):"
  printf "    Basel Σ1/n²        : %s  sAbs=%.6g\n" (show hBasel) sBasel
  printf "    Geometric (1/2)^n  : %s  sAbs=%.6g\n" (show hGeom)  sGeom
  printf "    Harmonic  Σ1/n     : %s  sAbs=%.6g\n" (show hHarm)  sHarm
  printf "    Broome-like (4/3)^n: %s  sAbs=%.6g\n" (show hBroome) sBroome
  printf "    Packed-div N=400   : %s   (even N, last term = 0)\n" (show hPackE)
  printf "    Packed-div N=401   : %s   (odd N, last term huge)\n" (show hPackO)
  putStrLn ""

  putStrLn "  Ratio certificates (property of the series, not of N):"
  printf "    Basel ratio → 1     : %s (inconclusive — needs integral/Cauchy cond.)\n"
         (show $ ratioCertificate 1.0)
  printf "    Geometric ratio 1/2 : %s\n" (show $ ratioCertificate 0.5)
  printf "    Broome ratio 4/3    : %s\n" (show $ ratioCertificate (4.0/3.0))
  putStrLn ""

  putStrLn "  Assertions (the PR #12 shape, host-independent):"
  r1 <- check (not hBasel && hGeom)
        "H-incomplete: Basel rejected while geometric accepted (same absolute-convergence class)"
  r2 <- check (hPackE /= hPackO)
        "H-parity: packed divergent series flips verdict when N parity flips"
  r3 <- check (ratioCertificate (4.0/3.0) == Divergent)
        "R-sound: Broome ratio 4/3 certifies divergence (no horizon)"
  r4 <- check (ratioCertificate 0.5 == Convergent)
        "R-positive: geometric ratio 1/2 certifies convergence"
  r5 <- check (not hBasel)
        "H-Basel-reject: documents incompleteness of last-term horizon at these params"
  -- Note: we do NOT assert hBroome is True — whether the horizon falsely
  -- accepts Broome depends on overflow/magnitude; the parity specimen is
  -- the clean unsoundness witness.

  putStrLn ""
  putStrLn "  Reading (preserved dissent, not a merge):"
  putStrLn "    • A last-term Cauchy horizon is a property of (series, N, tol, parity)."
  putStrLn "    • A ratio bound is a property of the series (given n ≥ n0)."
  putStrLn "    • PR #4's open question resolves in the direction PR #12 names:"
  putStrLn "      ratio-test fast path is sound where the horizon is not."
  putStrLn "    • Acceptance of any src/ repair remains another instance's hand."
  putStrLn ""

  if and [r1,r2,r3,r4,r5]
    then putStrLn "  5/5 aggregate exhibits hold." >> exitSuccess
    else putStrLn "  aggregate exhibits FAILED." >> exitFailure
