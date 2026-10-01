{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE ScopedTypeVariables #-}
-- | Part 4 central law, re-carried into Haskell.
--
--   dx/dt = F(x) = -k (x - x*)
--
-- Origin: src/Part4_ExpressionCatalog.jl (F_2, 68 Julia forms).
-- This file is not a form-count race with Julia. Berry-class counts are
-- carrier fingerprints (instance5's invariant ledger). We exercise
-- *distinct Haskell organizations* of the same law and verify they agree
-- at the Part-4 test point: F(3.0) = -4.0.
--
-- Carrier: GHC (see output header for version). Stdlib only.
-- Instance: instance7-haskell-rust. Self-report: correlated observer.

module Main where

import Control.Applicative (liftA2)
import Control.Monad (foldM)
import Data.Complex (Complex((:+)), realPart)
import Data.Foldable (foldl')
import Data.Functor.Identity (Identity(..), runIdentity)
import Data.Monoid (Endo(..))
import Data.Ratio (approxRational, (%))
import System.Exit (exitFailure, exitSuccess)
import Text.Printf (printf)

k, xStar, x0, target :: Double
k      = 2.0
xStar  = 1.0
x0     = 3.0
target = -k * (x0 - xStar)   -- -4.0

approx :: Double -> Double -> Bool
approx a b = abs (a - b) < 1e-9

type Result = (String, Double)

verify :: String -> Double -> Result
verify name val = (name, val)

--------------------------------------------------------------------------------
-- Expression forms
--------------------------------------------------------------------------------

-- 1. Top-level equation
f1 :: Double -> Double
f1 x = -k * (x - xStar)

-- 2. Where-clause bindings (local organization)
f2 :: Double -> Double
f2 x = result
  where
    deviationLocal = x - xStar
    result         = -k * deviationLocal

-- 3. Lambda bound to a name
f3 :: Double -> Double
f3 = \x -> -k * (x - xStar)

-- 4. Point-free composition
deviation, scale :: Double -> Double
deviation d = d - xStar
scale     d = -k * d

f4 :: Double -> Double
f4 = scale . deviation

-- 5. Explicit composition (same ops, written differently)
f5 :: Double -> Double
f5 = scale . deviation

-- 6. Fold over an operator sequence (Endo monoid)
-- Endo composition is (.), so ops must be listed in application order
-- from the *right*: last-applied outermost. We want deviation then scale,
-- i.e. scale ∘ deviation = mconcat [Endo scale, Endo deviation].
f6 :: Double -> Double
f6 x = appEndo (mconcat $ map Endo [scale, deviation]) x

-- 7. foldl' over operator list (left-to-right application order)
f7 :: Double -> Double
f7 x = foldl' (\acc op -> op acc) x [deviation, scale]

-- 8. Guards
f8 :: Double -> Double
f8 x
  | x == xStar = 0.0
  | otherwise  = -k * (x - xStar)

-- 9. Pattern-matching on a sum type (regime dispatch ~ Val-type)
data Regime = Linear | Off

f9 :: Regime -> Double -> Double
f9 Linear x = -k * (x - xStar)
f9 Off    _ = 0.0

-- 10. Type-class method (law as overloaded vocabulary)
class Regulate a where
  regulate :: a -> a -> a -> a   -- k, target, x

instance Regulate Double where
  regulate kk tt x = -kk * (x - tt)

f10 :: Double -> Double
f10 = regulate k xStar

-- 11. Newtype + record field as callable organization
newtype Flow = Flow { runFlow :: Double -> Double }

f11 :: Double -> Double
f11 = runFlow (Flow $ \x -> -k * (x - xStar))

-- 12. Maybe short-circuit (present value required)
f12 :: Double -> Double
f12 x = maybe (0.0 / 0.0) (\v -> -k * (v - xStar)) (Just x)

-- 13. Either as try/catch analogue
f13 :: Double -> Double
f13 x = case (if isNaN x then Left "nan" else Right x) of
  Left  _ -> 0.0
  Right v -> -k * (v - xStar)

-- 14. List comprehension (singleton field)
f14 :: Double -> Double
f14 x = case [-k * (v - xStar) | v <- [x]] of
  (r:_) -> r
  []    -> 0.0 / 0.0

-- 15. map over singleton
f15 :: Double -> Double
f15 x = case map (\v -> -k * (v - xStar)) [x] of
  (r:_) -> r
  []    -> 0.0 / 0.0

-- 16. Applicative liftA2 form (Identity)
f16 :: Double -> Double
f16 x = runIdentity $ liftA2 (*) (pure (-k)) (Identity (x - xStar))

-- 17. Monadic do over []
f17 :: Double -> Double
f17 x = case (do d <- [x - xStar]; return (-k * d)) of
  (r:_) -> r
  []    -> 0.0 / 0.0

-- 18. Recursion (countdown identity wrapper)
f18 :: Double -> Double
f18 x = go (3 :: Int) x
  where
    go 0 y = -k * (y - xStar)
    go n y = go (n - 1) y

-- 19. foldM over ops
f19 :: Double -> Double
f19 x = case foldM (\acc op -> Right (op acc)) x [deviation, scale] of
  Right v -> v
  Left (_ :: String) -> 0.0 / 0.0

-- 20. Partial application / operator sections
f20 :: Double -> Double
f20 = (* (-k)) . subtract xStar

-- 21. Matrix-ish linear form: A*(x - x*) with A = -k (1x1)
f21 :: Double -> Double
f21 x =
  let a = -k
      v = x - xStar
  in  a * v

-- 22. Rational intermediate (exact) then to Double
f22 :: Double -> Double
f22 x =
  let kr = 2 % 1
      xr = approxRational x 1e-12
      tr = 1 % 1
  in  fromRational (-kr * (xr - tr))

-- 23. Complex plane, take real part
f23 :: Double -> Double
f23 x = realPart $ ((-k) :+ 0) * ((x :+ 0) - (xStar :+ 0))

-- 24. Tupled state (x, params) destructuring
f24 :: Double -> Double
f24 x =
  let (kk, tt) = (k, xStar)
      (v, _)   = (x, ())
  in  -kk * (v - tt)

-- 25. Dictionary-of-functions (association list)
f25 :: Double -> Double
f25 x =
  let dict =
        [ ("linear", \v -> -k * (v - xStar))
        , ("off", const 0.0)
        ]
  in  case lookup "linear" dict of
        Just f  -> f x
        Nothing -> 0.0 / 0.0

--------------------------------------------------------------------------------
-- Collect & report
--------------------------------------------------------------------------------

results :: [Result]
results =
  [ verify "01 top-level equation"            (f1 x0)
  , verify "02 where-clause"                  (f2 x0)
  , verify "03 lambda"                        (f3 x0)
  , verify "04 point-free composition"        (f4 x0)
  , verify "05 composition (repeat writing)"  (f5 x0)
  , verify "06 Endo mconcat ops"              (f6 x0)
  , verify "07 foldl' op sequence"            (f7 x0)
  , verify "08 guards"                        (f8 x0)
  , verify "09 Regime sum-type dispatch"      (f9 Linear x0)
  , verify "10 type-class Regulate"           (f10 x0)
  , verify "11 newtype Flow record"           (f11 x0)
  , verify "12 Maybe case"                    (f12 x0)
  , verify "13 Either case"                   (f13 x0)
  , verify "14 list comprehension"            (f14 x0)
  , verify "15 map singleton"                 (f15 x0)
  , verify "16 Applicative liftA2"            (f16 x0)
  , verify "17 monadic do over []"            (f17 x0)
  , verify "18 recursion wrapper"             (f18 x0)
  , verify "19 foldM Either"                  (f19 x0)
  , verify "20 operator sections"             (f20 x0)
  , verify "21 1x1 linear map"                (f21 x0)
  , verify "22 Rational intermediate"         (f22 x0)
  , verify "23 Complex real part"             (f23 x0)
  , verify "24 tuple destructuring"           (f24 x0)
  , verify "25 assoc-list dict-of-functions"  (f25 x0)
  ]

main :: IO ()
main = do
  putStrLn "── Haskell carrier: dx/dt = -k(x - x*)  (Part 4 re-carrying) ──"
  putStrLn $ "  test point x0 = " ++ show x0 ++ "  target F(x0) = " ++ show target
  putStrLn ""
  let judged = [ (name, val, approx val target) | (name, val) <- results ]
      ok     = length (filter (\(_,_,m) -> m) judged)
      total  = length judged
  mapM_ (\(name, val, m) ->
           printf "  %s  %-40s = %s\n"
                  (if m then "✓" else "✗" :: String) name (show val))
        judged
  putStrLn ""
  printf "  %d/%d Haskell organizations agree:  F(%.1f) = %.1f\n" ok total x0 target
  putStrLn "  (Berry note: 25 is a Haskell spelling count, not an invariant.)"
  if ok == total then exitSuccess else exitFailure
