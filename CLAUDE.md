# CLAUDE.md — irreducible-mystery/julia2

Project memory for sessions working in this repository. It describes what is
here, how to run it, and the conventions the existing files already follow.

## What this repository is

A complete, runnable **Julia translation of two source documents** —
`Organized_Change_Projection_and_Generative_Fields_(2).docx` (a Q&A treatment of
organized change, projection between levels, multi-observer triangulation,
structured and generative fields) and `Geometry_and_Dynamic_Systems_(2).pdf`
(the same program made concrete as a versioned epistemic commons).

Two things make the repo unusual, and both are deliberate:

- The translation exercises **68 distinct Julia expression forms** — the central
  law `dx/dt = −k(x − x*)` written every way the language permits, all verified
  to compute the same value.
- The repo **is** an instance of the thing it translates: a small versioned
  field. `main` is the current accepted state `F_n`, not final truth, and the
  collaboration record (transcripts, metadata, responses) is kept as first-class
  content rather than stripped.

## Layout

| Path | Contents |
|---|---|
| `src/Part1_OrganizedChange.jl` | Q1–Q2: `dx/dt = F(x,e,c)`, Ω-constraints, fast/slow ε-systems, gradient flow, feedback, memory, thresholds, ΔC classification, architectures |
| `src/Part2_ProjectionObservation.jl` | Q3–Q4: projections `y = π(x)`, fibers, macrostate autonomy, commutation, hysteresis, order parameters, Simpson reversal, parallax, Bayes fusion, atlas gluing |
| `src/Part3_GenerativeField.jl` | Q5–Q7 + the PDF: `F = (P,D,R,C,T)`, the representation ladder, bifurcation/frustration/curvature, and the **versioned field** — element kinds, 21 relation types, 8 bounded operators, deterministic validation, preserved dissent |
| `src/Part4_ExpressionCatalog.jl` | The 68 expression forms, verified equal |
| `docs_README.md` | The concept → Julia-construct mapping table |
| `extracted_text/` | Plain-text extractions of both source documents |
| `source_documents/` | The original DOCX and PDF |
| `responses/` | Later contributors' work, one folder per contributor — reviews, audits, negation studies, paradox suites, in Julia, Prolog, BQN and Forth |
| `transcripts/` | The conversation layer: the exchanges that produced each field state, one folder per contributor, add-only |
| `metadata/` | Machine-readable field-state log, participant registry, environment snapshots |
| `paraconsistent_etau/` | A download record for Paraconsistent Annotated Evidential Logic Eτ — what arrived, what the network refused, and a script to finish the job elsewhere |
| `COLLABORATION.md` | The protocol: how to respond, and the field rules below |

There is no `.github/` directory and no CI.

## Running

```bash
./run_all.sh                              # all four parts
julia src/Part1_OrganizedChange.jl        # or individually
julia -t 2 src/Part4_ExpressionCatalog.jl # Part 4 needs ≥2 threads
```

Requirements: **Julia ≥ 1.9** (tested on 1.12.6), **standard library only** —
`LinearAlgebra`, `Statistics`, `Random`, and no packages. Part 4 uses
`Threads.@threads` and `Threads.@spawn` among its 68 forms, so run it with
`-t 2` or more.

The invariant to check after any change to Part 4 — it is the repo's canary:

```
68/68 expression forms agree:  F(3.0) = -4.0
```

Material under `responses/` carries its own runtimes (Python, SWI-Prolog, BQN,
gforth) and its own recorded outputs; it is not part of `run_all.sh`.

## Conventions

These come from `COLLABORATION.md`, which applies the source documents' own
field rules to the repository:

1. **Origin traces.** Don't silently rewrite another contributor's files.
   Propose changes so provenance survives; every interpretation stays
   traceable, challengeable, and revisable.
2. **Preserve dissent.** A disagreement is recorded as an explicit element —
   an issue or a file under `responses/` — not averaged away. State a
   contradiction's conditions (same referent? same scale? same definition?)
   before calling it a contradiction.
3. **No self-acceptance.** A change is not accepted by whoever authored it.
4. **Multiplicity ≠ independence.** Two agreeing contributors from the same
   model family are correlated observers, not independent confirmation; note
   your provenance.
5. **Reopening is allowed.** Nothing is permanently settled.
6. **Append, never rewrite** in `transcripts/` and `metadata/`. Every entry
   carries `recorded_by` / `recorded_at`, and self-reports are marked as
   self-reports — testimony from inside the system, not ground truth.
7. **Strip credentials before committing** anything into `transcripts/`;
   redactions are marked visibly.

## If you are changing things here

- Run `./run_all.sh` and confirm Part 4's `68/68` line before and after.
- New expression forms in Part 4 go through the same `verify!` channel as the
  existing 67; add the form to the list in `docs_README.md` too.
- Additions by a new contributor belong in `responses/<name>/` and
  `transcripts/<name>/`, with the field-state transition logged in
  `metadata/field_state_log.json`.
