//! Antinomy exhibits re-carried into Rust (used language on the census).
//!
//! Origin traces:
//!   responses/paradox-instance/paradoxes/01_antinomies.jl  (instance2)
//!   PR #9 WFS-vs-Kripke truth-teller tension (instance6)
//!   PR #5 K3/missing fixed-point observations (instance3)
//!
//! Rust has no built-in `missing`. We host K3 on `Option<bool>`:
//!   Some(true)/Some(false)/None  ~  T/F/U
//! Fuel-bounded regress stands in for Julia's Task-sandboxed stack overflow —
//! another host-shaped difference worth recording, not erasing.
//!
//! Instance: instance7-haskell-rust. Correlated observer.

fn section(t: &str) {
    println!("\n{}\n  {}\n{}", "═".repeat(70), t, "═".repeat(70));
}
fn verdict(v: &str) {
    println!("  VERDICT: {v}");
}

/// Strong Kleene negation on Option<bool>.
fn k3not(v: Option<bool>) -> Option<bool> {
    match v {
        Some(b) => Some(!b),
        None => None,
    }
}

/// Strong Kleene OR.
fn k3or(a: Option<bool>, b: Option<bool>) -> Option<bool> {
    match (a, b) {
        (Some(true), _) | (_, Some(true)) => Some(true),
        (Some(false), Some(false)) => Some(false),
        _ => None,
    }
}

fn liar_op(x: Option<bool>) -> Option<bool> {
    k3not(x)
}
fn curry_op(x: Option<bool>) -> Option<bool> {
    // (¬x ∨ ⊥) — extensionally ¬x on K3 (PR #9 gate-gap)
    k3or(k3not(x), Some(false))
}

/// Fuel-bounded Liar. Iterative so the exhibit is the fuel exhaustion,
/// not an accidental host stack overflow (a different, also-interesting
/// failure mode — but not the one this section claims to show).
fn fuel_liar(gas: u32) -> Result<bool, &'static str> {
    if gas == 0 {
        return Err("infinite regress — sentence never grounds");
    }
    // Unfolding n steps of ¬ always bottoms out at the fuel wall.
    let mut _acc = false;
    let mut n = gas;
    while n > 0 {
        n -= 1;
        if n == 0 {
            return Err("infinite regress — sentence never grounds");
        }
        _acc = !_acc;
    }
    Ok(_acc)
}

fn main() {
    println!("── Rust carrier: antinomy exhibits (re-carrying) ──");

    section("THE LIAR — classical fixed-point search");
    let classical: Vec<bool> = [true, false]
        .into_iter()
        .filter(|v| *v == !*v)
        .collect();
    println!("    {{v ∈ {{true,false}} : v == !v}} = {classical:?}");
    println!("    ← EMPTY: no classical truth value");
    verdict("ANTINOMY — does not resolve classically");

    section("THE LIAR — fuel-bounded regress (host-honest divergence)");
    match fuel_liar(10_000) {
        Err(e) => println!("    fuel_liar 10000 → 💥 {e}"),
        Ok(b) => println!("    unexpected value: {b}"),
    }
    // Note: deep recursion may hit stack overflow before fuel on some
    // targets; we use 10_000 which is safe on typical Rust stacks, and
    // the Left-path is the intended exhibit.
    verdict("ANTINOMY — host shows divergence under a fuel budget (no Task stack)");

    section("THE LIAR — K3 escape via Option (None = missing)");
    let u: Option<bool> = None;
    println!("    k3not(None) == None : {}", k3not(u) == u);
    println!("    ← None is the unique K3 fixed point of negation");
    println!("    …but the Strengthened Liar («not even None») re-erupts:");
    let strengthened: Vec<Option<bool>> = [Some(true), Some(false), None]
        .into_iter()
        .filter(|v| *v != None && *v == k3not(*v))
        .collect();
    println!("    {{v ∈ K3 : v ≠ None ∧ v == k3not v}} = {strengthened:?}");
    println!("    ← EMPTY again one level up (Tarski rent)");
    verdict("DISPLACED, not resolved — K3 buys a fixed point, pays a meta-liar");

    section("CURRY vs LIAR on K3 (instance6 gate-gap exhibit)");
    let domain = [Some(true), Some(false), None];
    let ext_equal = domain.iter().all(|&v| curry_op(v) == liar_op(v));
    println!("    curry_op ≡ liar_op on K3 (consequent=false): {ext_equal}");
    println!("    ← A Curry row that uses (¬x ∨ ⊥) tests the Liar twice under two names.");
    verdict("TENSION — gate labels ≠ gate extensions (PR #9 §2 replication on Rust)");

    section("TRUTH-TELLER dial: T ≡ T under two grounded policies");
    let kripke_tt: Option<bool> = None; // least FP from undefined
    let wfs_tt: Option<bool> = Some(false); // unfounded → false
    println!("    Kripke-LFP truth-teller : {kripke_tt:?}");
    println!("    WFS-style truth-teller  : {wfs_tt:?}");
    println!("    agree? {}", kripke_tt == wfs_tt);
    println!("    ← Same sentence, two least-fixed-point operators, two values.");
    verdict("FRAME-RELATIVE — truth-teller value is a policy choice, not a fact");

    section("QUINE shape without the bang (harmless self-ref)");
    let sample = "this string";
    fn desc(s: &str) -> &str {
        s
    }
    println!("    desc(sample) == sample : {}", desc(sample) == sample);
    println!("    Self-reference without negation is idle — the bang installs the antinomy.");
    verdict("CONTROL — diagonal without negation does not explode");

    println!("\n── end paradox carrier ──");
}
