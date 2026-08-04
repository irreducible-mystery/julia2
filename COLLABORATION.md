# Collaboration Protocol

This repository is shared between two (or more) AI instances collaborating with the
repository owner. In the spirit of the source documents themselves, we treat the repo
as a small **versioned generative field**: the `main` branch is the current accepted
state `F_n` — the best current field, *not* final truth.

## How to respond (for the newly connected instance)

1. **Read**
   - `README.md` (orientation), `docs_README.md` (concept → construct mapping)
   - `extracted_text/` for the source material in plain text
   - `src/*.jl` — the four translation files

2. **Run**
   ```bash
   ./run_all.sh
   ```
   All four parts should exit 0. Part 4 must end with `68/68 expression forms agree`.

3. **Respond** — any of:
   - Open a **branch + pull request** with changes (preferred for code):
     ```bash
     git checkout -b response/<your-instance-name>
     # ... make changes / add files under responses/ or src/ ...
     git push https://x-access-token:$GITHUB_TOKEN@github.com/irreducible-mystery/julia2.git response/<your-instance-name>
     gh pr create --title "..." --body "..."
     ```
   - Open an **issue** for review notes, tensions, or questions
   - Add a file under `responses/` with your commentary

## Field rules (from the source documents, applied to this repo)

- **Origin traces**: don't silently rewrite another contributor's files — propose
  changes via PR so provenance is preserved. Every interpretation must remain
  traceable, challengeable, and revisable.
- **Preserve dissent**: if you disagree with a translation choice, record the
  disagreement as an explicit element (issue or `responses/` file). A contradiction
  should state its conditions (same referent? same scale? same definition?) before
  being declared a contradiction.
- **No self-acceptance**: a transformation operator must not accept its own change —
  i.e., let the owner or the other instance review/merge your PRs.
- **Multiplicity ≠ independence**: two agreeing instances sharing a model family are
  correlated observers, not independent confirmation. Note your provenance.
- **Reopening is allowed**: nothing is permanently settled. A later contribution may
  reopen anything.

## Suggested next tasks (open to the collaborating instance)

- [ ] Independent verification: run all parts, report versions/results in an issue
- [ ] Review Part 4 — are there Julia expression forms we missed? (PRs welcome)
- [ ] Extend Part 3's `VersionedField` (e.g., graph export, atlas generation)
- [ ] Add tests (`Test` stdlib) formalizing each demo's assertions
- [ ] Propose new dimensions: what did the translation lose from the source? (`Loss(T) > 0`)

## Current state

- `F_0`: initial commit — four translation files, source documents, extracted text,
  docs, this protocol. All demos verified on Julia 1.12.6 (Linux x86_64).
