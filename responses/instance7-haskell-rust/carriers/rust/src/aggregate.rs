//! evaluate_aggregate soundness exhibit — Rust re-carrying (used language).
//!
//! Origin traces:
//!   PR #4  numeric Cauchy horizon (instance1)
//!   PR #12 neither sound nor complete; horizon parity trap (instance6)
//!   PR #10 ratio-certificate upgrade (instance6)
//!   review/pr4-stress-test T7 (instance2)
//!
//! Side-by-side: last-term horizon vs ratio-test certificate.
//! Does not modify src/. Acceptance of any repair is not ours to give.
//!
//! Instance: instance7-haskell-rust. Correlated observer.

fn horizon_evaluable(a: &dyn Fn(i64) -> f64, n_max: i64, tol: f64) -> (bool, f64) {
    let mut s_abs = 0.0;
    for n in 1..=n_max {
        s_abs += a(n).abs();
    }
    let tail = a(n_max).abs();
    let ok = tail < tol * s_abs.max(1.0);
    (ok, s_abs)
}

#[derive(Debug, PartialEq)]
enum RatioVerdict {
    Convergent,
    Divergent,
    Inconclusive,
}

fn ratio_certificate(r: f64) -> RatioVerdict {
    if r < 1.0 - 1e-15 {
        RatioVerdict::Convergent
    } else if r > 1.0 + 1e-15 {
        RatioVerdict::Divergent
    } else {
        RatioVerdict::Inconclusive
    }
}

fn check(cond: bool, msg: &str) -> bool {
    println!("  {}  {}", if cond { "✓" } else { "✗" }, msg);
    cond
}

fn main() {
    println!("── Rust carrier: aggregate evaluability (horizon vs ratio) ──");
    println!("  Re-carrying the PR #4 / PR #12 tension without touching src/.");
    println!();

    let n_max: i64 = 400;
    let tol = 1e-10;
    println!("  Horizon parameters: N={n_max}  tol={tol:.0e}  (last-term only)");
    println!();

    let basel = |n: i64| 1.0 / ((n * n) as f64);
    let geometric = |n: i64| 0.5_f64.powi(n as i32);
    let harmonic = |n: i64| 1.0 / (n as f64);
    let broome = |n: i64| (4.0_f64 / 3.0).powi(n as i32);
    let packed = |n: i64| {
        if n % 2 == 0 {
            0.0
        } else {
            (4.0_f64 / 3.0).powi(n as i32)
        }
    };

    let (h_basel, s_basel) = horizon_evaluable(&basel, n_max, tol);
    let (h_geom, s_geom) = horizon_evaluable(&geometric, n_max, tol);
    let (h_harm, s_harm) = horizon_evaluable(&harmonic, n_max, tol);
    let (h_broome, s_broome) = horizon_evaluable(&broome, n_max, tol);
    let (h_pack_e, _) = horizon_evaluable(&packed, n_max, tol);
    let (h_pack_o, _) = horizon_evaluable(&packed, n_max + 1, tol);

    println!("  Horizon verdicts (evaluable? | sAbs):");
    println!("    Basel Σ1/n²        : {h_basel}  sAbs={s_basel:.6e}");
    println!("    Geometric (1/2)^n  : {h_geom}  sAbs={s_geom:.6e}");
    println!("    Harmonic  Σ1/n     : {h_harm}  sAbs={s_harm:.6e}");
    println!("    Broome-like (4/3)^n: {h_broome}  sAbs={s_broome:.6e}");
    println!("    Packed-div N=400   : {h_pack_e}   (even N, last term = 0)");
    println!("    Packed-div N=401   : {h_pack_o}   (odd N, last term huge)");
    println!();

    println!("  Ratio certificates (property of the series, not of N):");
    println!(
        "    Basel ratio → 1     : {:?} (inconclusive)",
        ratio_certificate(1.0)
    );
    println!(
        "    Geometric ratio 1/2 : {:?}",
        ratio_certificate(0.5)
    );
    println!(
        "    Broome ratio 4/3    : {:?}",
        ratio_certificate(4.0 / 3.0)
    );
    println!();

    println!("  Assertions (the PR #12 shape, host-independent):");
    let r1 = check(
        !h_basel && h_geom,
        "H-incomplete: Basel rejected while geometric accepted (same absolute-convergence class)",
    );
    let r2 = check(
        h_pack_e != h_pack_o,
        "H-parity: packed divergent series flips verdict when N parity flips",
    );
    let r3 = check(
        ratio_certificate(4.0 / 3.0) == RatioVerdict::Divergent,
        "R-sound: Broome ratio 4/3 certifies divergence (no horizon)",
    );
    let r4 = check(
        ratio_certificate(0.5) == RatioVerdict::Convergent,
        "R-positive: geometric ratio 1/2 certifies convergence",
    );
    let r5 = check(
        !h_basel,
        "H-Basel-reject: documents incompleteness of last-term horizon at these params",
    );

    println!();
    println!("  Reading (preserved dissent, not a merge):");
    println!("    • A last-term Cauchy horizon is a property of (series, N, tol, parity).");
    println!("    • A ratio bound is a property of the series (given n ≥ n0).");
    println!("    • PR #4's open question resolves in the direction PR #12 names:");
    println!("      ratio-test fast path is sound where the horizon is not.");
    println!("    • Acceptance of any src/ repair remains another instance's hand.");
    println!();

    if r1 && r2 && r3 && r4 && r5 {
        println!("  5/5 aggregate exhibits hold.");
    } else {
        println!("  aggregate exhibits FAILED.");
        std::process::exit(1);
    }
}
