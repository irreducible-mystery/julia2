//! Part 4 central law, re-carried into Rust (a language already on the census).
//!
//!   dx/dt = F(x) = -k (x - x*)
//!
//! Origin: `src/Part4_ExpressionCatalog.jl` (F_2, 68 Julia forms).
//! PR #12 notes Elixir/Rust translations of the Broome deep-dive in the
//! sibling repo; this file re-hosts the *Part 4 law* itself so the used
//! language has a run artifact inside *this* field, not only across the
//! repo boundary.
//!
//! Berry note: form counts are carrier fingerprints, not invariants
//! (instance5). We verify agreement at F(3.0) = -4.0.
//!
//! Instance: instance7-haskell-rust. Correlated observer. Stdlib only.

#![allow(dead_code)]

const K: f64 = 2.0;
const X_STAR: f64 = 1.0;
const X0: f64 = 3.0;
const TARGET: f64 = -4.0; // -K * (X0 - X_STAR)

fn approx(a: f64, b: f64) -> bool {
    (a - b).abs() < 1e-9
}

// 1. Free function
fn f1(x: f64) -> f64 {
    -K * (x - X_STAR)
}

// 2. Block expression with locals
fn f2(x: f64) -> f64 {
    let deviation = x - X_STAR;
    let result = -K * deviation;
    result
}

// 3. Closure assigned to a variable
fn f3(x: f64) -> f64 {
    let f = |v: f64| -K * (v - X_STAR);
    f(x)
}

// 4. Function composition via explicit chaining
fn deviation(d: f64) -> f64 {
    d - X_STAR
}
fn scale(d: f64) -> f64 {
    -K * d
}
fn f4(x: f64) -> f64 {
    scale(deviation(x))
}

// 5. Iterator fold over operator list
fn f5(x: f64) -> f64 {
    let ops: [fn(f64) -> f64; 2] = [deviation, scale];
    ops.iter().fold(x, |acc, op| op(acc))
}

// 6. match guards / regime dispatch (~ Val-type)
enum Regime {
    Linear,
    Off,
}
fn f6(regime: Regime, x: f64) -> f64 {
    match regime {
        Regime::Linear => -K * (x - X_STAR),
        Regime::Off => 0.0,
    }
}

// 7. Trait method (law as overloaded vocabulary)
trait Regulate {
    fn regulate(self, k: f64, target: f64) -> Self;
}
impl Regulate for f64 {
    fn regulate(self, k: f64, target: f64) -> Self {
        -k * (self - target)
    }
}
fn f7(x: f64) -> f64 {
    x.regulate(K, X_STAR)
}

// 8. Newtype callable via inherent method
struct Flow;
impl Flow {
    fn run(x: f64) -> f64 {
        -K * (x - X_STAR)
    }
}
fn f8(x: f64) -> f64 {
    Flow::run(x)
}

// 9. Option short-circuit
fn f9(x: f64) -> f64 {
    Some(x)
        .map(|v| -K * (v - X_STAR))
        .unwrap_or(f64::NAN)
}

// 10. Result as try/catch analogue
fn f10(x: f64) -> f64 {
    let r: Result<f64, &str> = if x.is_nan() { Err("nan") } else { Ok(x) };
    match r {
        Ok(v) => -K * (v - X_STAR),
        Err(_) => 0.0,
    }
}

// 11. Iterator map + next
fn f11(x: f64) -> f64 {
    std::iter::once(x)
        .map(|v| -K * (v - X_STAR))
        .next()
        .unwrap()
}

// 12. Recursive countdown wrapper
fn f12(x: f64) -> f64 {
    fn go(n: u32, y: f64) -> f64 {
        if n == 0 {
            -K * (y - X_STAR)
        } else {
            go(n - 1, y)
        }
    }
    go(3, x)
}

// 13. Array / matrix 1x1 form
fn f13(x: f64) -> f64 {
    let a = [-K];
    let v = [x - X_STAR];
    a[0] * v[0]
}

// 14. Tuple destructuring
fn f14(x: f64) -> f64 {
    let (kk, tt) = (K, X_STAR);
    let (v, _) = (x, ());
    -kk * (v - tt)
}

// 15. Dict-of-functions via slice of pairs
fn f15(x: f64) -> f64 {
    let dict: &[(&str, fn(f64) -> f64)] = &[
        ("linear", f1),
        ("off", |_| 0.0),
    ];
    for (name, f) in dict {
        if *name == "linear" {
            return f(x);
        }
    }
    f64::NAN
}

// 16. if-expression as value
fn f16(x: f64) -> f64 {
    if x == X_STAR {
        0.0
    } else {
        -K * (x - X_STAR)
    }
}

// 17. loop + break-value
fn f17(x: f64) -> f64 {
    let mut acc = x;
    let mut i = 0;
    let out = loop {
        if i == 1 {
            break -K * (acc - X_STAR);
        }
        i += 1;
        acc = x;
    };
    out
}

// 18. const generics dummy (type-level 1)
fn apply_scale_n<const N: i32>(d: f64) -> f64 {
    // N unused except as a type-level tag that we chose the linear regime
    let _ = N;
    -K * d
}
fn f18(x: f64) -> f64 {
    apply_scale_n::<1>(x - X_STAR)
}

// 19. Higher-order function taking a strategy
fn with_strategy(strat: impl Fn(f64) -> f64, x: f64) -> f64 {
    strat(x)
}
fn f19(x: f64) -> f64 {
    with_strategy(|v| -K * (v - X_STAR), x)
}

// 20. Macros: law at call site
macro_rules! law {
    ($x:expr) => {
        -K * (($x) - X_STAR)
    };
}
fn f20(x: f64) -> f64 {
    law!(x)
}

fn main() {
    println!("── Rust carrier: dx/dt = -k(x - x*)  (Part 4 re-carrying) ──");
    println!("  test point x0 = {X0}  target F(x0) = {TARGET}");
    println!();

    let results: Vec<(&str, f64)> = vec![
        ("01 free function", f1(X0)),
        ("02 block locals", f2(X0)),
        ("03 closure", f3(X0)),
        ("04 explicit composition", f4(X0)),
        ("05 iterator fold ops", f5(X0)),
        ("06 Regime match dispatch", f6(Regime::Linear, X0)),
        ("07 trait Regulate", f7(X0)),
        ("08 newtype inherent method", f8(X0)),
        ("09 Option map", f9(X0)),
        ("10 Result match", f10(X0)),
        ("11 iterator map/next", f11(X0)),
        ("12 recursion wrapper", f12(X0)),
        ("13 1x1 array multiply", f13(X0)),
        ("14 tuple destructuring", f14(X0)),
        ("15 slice dict-of-functions", f15(X0)),
        ("16 if-expression value", f16(X0)),
        ("17 loop break-value", f17(X0)),
        ("18 const-generic tag", f18(X0)),
        ("19 higher-order strategy", f19(X0)),
        ("20 macro_rules law!", f20(X0)),
    ];

    let mut ok = 0;
    for (name, val) in &results {
        let m = approx(*val, TARGET);
        if m {
            ok += 1;
        }
        println!(
            "  {}  {:<40} = {}",
            if m { "✓" } else { "✗" },
            name,
            val
        );
    }
    let total = results.len();
    println!();
    println!("  {ok}/{total} Rust organizations agree:  F({X0}) = {TARGET}");
    println!("  (Berry note: {total} is a Rust spelling count, not an invariant.)");
    if ok != total {
        std::process::exit(1);
    }
}
