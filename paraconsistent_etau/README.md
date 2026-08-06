# Paraconsistent Annotated Evidential Logic Eτ — download record

Requested: *download Paraconsistent Annotated Evidential Logic Eτ*.

This directory records **what was actually downloaded, what was refused, and how to
finish the job on an unrestricted network**. Read `PROVENANCE` blocks and exit codes,
not the prose — consistent with the rest of this repository, nothing here asks to be
trusted on its word.

## Summary

| Item | Status |
|---|---|
| Working Eτ / PAL2v **implementation** (source + distributions) | **downloaded, verified** |
| Eτ **literature** (papers, book chapters, the foundational 1991 paper) | **blocked by network egress policy** — not downloaded |

The session's egress proxy permits GitHub and the language package registries and
denies every scholarly host. So the *algorithm* of Eτ arrived; the *papers* did not.
`fetch_sources.sh` completes the literature download anywhere the network is open.

## What was downloaded

### 1. `paraconsistent` 0.2.4 — PyPI

A dependency-free Python implementation of Lógica Paraconsistente Anotada de dois
valores (LPA2v / PAL2v), the two-valued-annotation form of Eτ.

```
https://pypi.org/project/paraconsistent/0.2.4/
sha256(paraconsistent-0.2.4.tar.gz)          = 2aa537d4048dec80fc7503c0bc167dc0088da241c1a0ff754b79bbb697c5e440
sha256(paraconsistent-0.2.4-py3-none-any.whl) = b5b69a1893d5ba5eff0df5a10e7851cdc5e4788cbb85e41d2ed2c215a67c6b9f
```

### 2. `eailab-ifsp/paraconsistent-lib` — GitHub

The upstream source repository for the same package (EAI Lab, IFSP).

```
https://github.com/eailab-ifsp/paraconsistent-lib
commit e6106a9356928ce693bb01ec1682a9d9a9b29eb6  (2025-11-10)
```

Neither artifact is vendored into this repository. Both are pinned by hash above and
re-fetched by `fetch_sources.sh`, which is the honest way to carry someone else's code:
the upstream project declares `license = { file = "LICENSE" }` in its `pyproject.toml`
and ships an MIT classifier, **but no LICENSE file exists** in either the repository or
the sdist. Until upstream fixes that, redistribution here would be asserting a licence
that upstream has not actually stated.

## What was refused

The egress proxy answered `403` to `CONNECT` for every scholarly host tried:

```
arxiv.org           export.arxiv.org      link.springer.com     www.sciencedirect.com
www.mdpi.com        doi.org               pmc.ncbi.nlm.nih.gov  europepmc.org
api.crossref.org    api.openalex.org      api.semanticscholar.org  core.ac.uk
zenodo.org          archive.org           dblp.org              philpapers.org
plato.stanford.edu  en.wikipedia.org      inria.hal.science     onlinelibrary.wiley.com
```

Recorded gateway reason, verbatim:

```json
{ "kind": "connect_rejected",
  "detail": "gateway answered 403 to CONNECT (policy denial or upstream failure)",
  "host": "arxiv.org:443" }
```

This is an organization policy denial, so it was reported rather than routed around.
The server-side fetch tool is governed by the same policy and returned `403` for the
same hosts, including Wikipedia — so no text of these papers reached this session.
**Nothing in `SOURCES.md` was transcribed from a fetched document**; it is a citation
manifest, assembled from search-result metadata, for a download that has not happened yet.

## Finishing the download

```bash
./fetch_sources.sh            # open-access items + the pinned implementation
./fetch_sources.sh --all      # also attempts the paywalled items (will need entitlement)
python3 verify_etau.py        # exit 0 iff the implementation obeys the Eτ axes
```

`fetch_sources.sh` writes into `downloads/` (git-ignored) and verifies the two pinned
sha256 sums. It never disables TLS verification.

## The logic itself, in one screen

Eτ (da Costa, Subrahmanian, Vago; developed by Abe and colleagues) annotates each
proposition `p` with a pair drawn from the unit square:

```
p(μ, λ)     μ ∈ [0,1] = degree of favourable evidence
            λ ∈ [0,1] = degree of unfavourable evidence
```

μ and λ are **independent** — that independence is the whole point, and it is what
separates Eτ from fuzzy logic, where `λ = 1 − μ` is forced. Two derived axes:

```
degree of certainty      G_c(μ,λ)  = μ − λ           ∈ [−1, 1]
degree of contradiction  G_ct(μ,λ) = μ + λ − 1       ∈ [−1, 1]
```

The four corners of the square are the extreme logical states:

```
        λ
        1 ┌──────────────┬──────────────┐
          │ F  false     │ ⊤ inconsistent│   (1,1)  ⊤  both, G_ct = +1
          │ (0,1)        │ (1,1)         │   (0,0)  ⊥  neither, G_ct = −1
          │              │               │   (1,0)  t  true, G_c = +1
          │ ⊥ paracomplete│ t  true      │   (0,1)  F  false, G_c = −1
        0 └──────────────┴──────────────┘
          0                             1   μ
```

`⊤` (inconsistent) is a *state*, not an explosion: Eτ is paraconsistent, so
`p ∧ ¬p` does not entail everything. `⊥` (paracomplete) is the dual: evidence for
neither, so excluded middle does not hold either. Between the corners, the
para-analyzer partitions the square into 12 regions (4 extreme + 8 transition states
such as `Q⊤→t`, "quasi-inconsistent tending to true"), which is what the downloaded
implementation computes.

Negation swaps the annotation, `¬p(μ, λ) = p(λ, μ)`, which is exactly why contradiction
is representable without triviality: negation moves a point across the `μ = λ` diagonal
rather than off a two-valued cliff.

### Verified, not asserted

`verify_etau.py` checks the downloaded implementation against those definitions:

```
  mu  lam      dc     dct       D label
 1.0  0.0   1.000   0.000   0.000 t          OK   true
 0.0  1.0  -1.000   0.000   0.000 f          OK   false
 1.0  1.0   0.000   1.000   1.000 ┬          OK   inconsistent
 0.0  0.0   0.000  -1.000   1.000 ┴          OK   paracomplete
 0.5  0.5   0.000   0.000   1.000 I          OK   centre
 0.8  0.3   0.500   0.100   0.510 t          OK   mixed
```

Both axes agree with `G_c = μ − λ` and `G_ct = μ + λ − 1` to machine precision, and all
four corners land on the correct extreme state.

Two defects found in the downloaded package while checking it, recorded because this
repository preserves findings rather than averaging them away:

- `src/paraconsistent/examples/demo_wiring.py` is dead on arrival — it imports
  `mrn.paraconsistent.block`, a module path that no longer exists in the distribution.
- The declared `LICENSE` file is absent from both the sdist and the repository.

Neither affects the core computation, which is correct.

## Why this belongs in this repository

`Part3_GenerativeField.jl` already carries `contradicts_under` relations, tension typing,
and a `DifferencePreserver` operator, and the field model's stated commitment is that
dissent is *preserved, not averaged away*. Eτ is the formal logic for exactly that
commitment: it gives a contradiction a coordinate (`G_ct > 0`) instead of a
truth-value crisis. The natural next step — **not taken here, because it was not
asked for** — is a `Part5_ParaconsistentEtau.jl` translating the lattice, the 12
regions, and the para-analyzer into Julia, so that `contradicts_under` returns an
annotation rather than a boolean.
