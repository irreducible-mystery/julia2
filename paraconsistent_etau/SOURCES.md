# Eτ — source manifest

Machine-readable twin: `sources.json`. Fetcher: `fetch_sources.sh`.

**Provenance warning.** Every citation below was assembled from *search-engine result
metadata*. None of these documents was retrieved in the session that produced this file —
the network policy denied every scholarly host (see `README.md`). Identifiers marked
**verified** appeared directly in a search-result URL; anything else is weaker. Nothing
here is a summary of a document actually read.

---

## Downloaded ✓

| Item | Provenance |
|---|---|
| `paraconsistent` 0.2.4 (sdist + wheel) | PyPI, sha256-pinned in `sources.json` |
| `eailab-ifsp/paraconsistent-lib` | GitHub, commit `e6106a9` (2025-11-10) |

Verified against the Eτ axes by `verify_etau.py` — exit 0.

---

## Foundational — the logic itself

**da Costa, N. C. A., Subrahmanian, V. S., & Vago, C. (1991).** *The Paraconsistent
Logics Pτ.* Zeitschrift für Mathematische Logik und Grundlagen der Mathematik
(Mathematical Logic Quarterly) **37**, 139–148.
DOI [`10.1002/malq.19910370903`](https://doi.org/10.1002/malq.19910370903) — *verified* · paywalled

> The origin of the annotated paraconsistent family that Eτ specialises. Several
> indexes render the τ as "J" (`The Paraconsistent Logics PJ`) through a glyph
> substitution — same paper.

**Abe, J. M., Akama, S., & Nakamatsu, K. (2015).** *Introduction to Annotated Logics:
Foundations for Paracomplete and Paraconsistent Reasoning.* Intelligent Systems
Reference Library **88**, Springer. ISBN 9783319179117.
DOI [`10.1007/978-3-319-17912-4`](https://doi.org/10.1007/978-3-319-17912-4) — *verified* · paywalled

> The standard book-length treatment; closest thing to a canonical reference.

**Carvalho, F. R. de, & Abe, J. M. (2018).** *Paraconsistent Annotated Evidential Logic
Eτ.* In *A Paraconsistent Decision-Making Method*, Smart Innovation, Systems and
Technologies **87**, Springer.
DOI [`10.1007/978-3-319-74110-9_2`](https://doi.org/10.1007/978-3-319-74110-9_2) — *verified* · paywalled

> A chapter titled exactly for this logic — the most direct definitional source.

**Abe, J. M. (2011).** *Paraconsistent Annotated Evidential Logic Eτ and Applications in
Automation and Robotics.* In *The Handbook on Reasoning-Based Intelligent Systems*,
World Scientific.
DOI [`10.1142/9789814329484_0013`](https://doi.org/10.1142/9789814329484_0013) — *verified* · paywalled

---

## Surveys — best entry points

**A comprehensive review on paraconsistent annotated evidential logic: Algorithms,
Applications, and Perspectives** (2024). *Engineering Applications of Artificial
Intelligence* **127** part B.
DOI [`10.1016/j.engappai.2023.107342`](https://doi.org/10.1016/j.engappai.2023.107342) — *verified* · paywalled

> Covers the algorithm family built on Eτ: Para-Analyzer, PAN, ParaExtrCTR, PANet,
> PAL2v Filter, PNN.

**Three decades of paraconsistent annotated logics** (2019). *Procedia Computer Science.*
PII [`S1877050919314838`](https://www.sciencedirect.com/science/article/pii/S1877050919314838) — *verified* · **open access**

---

## Open-access applications

| Work | Identifier | Notes |
|---|---|---|
| *Paraconsistent Annotated Logic Algorithms Applied in Management and Control of Communication Network Routes* (2021), Sensors 21(12) 4219 | DOI [`10.3390/s21124219`](https://doi.org/10.3390/s21124219) | **CC BY 4.0** — freely redistributable |
| *Analysis of the displacement of terrestrial mobile robots in corridors using paraconsistent annotated evidential logic Eτ* (2020) | [arXiv:2009.14192](https://arxiv.org/abs/2009.14192) | |
| *Monitoring electrical systems data-network equipment by means of Fuzzy and Paraconsistent Annotated Logic* (2021) | [arXiv:2105.07579](https://arxiv.org/abs/2105.07579) | |
| *Application of Paraconsistent Annotated Evidential Logic Eτ for a Terrestrial Mobile Robot to Avoid Obstacles* (2021), Procedia CS | PII [`S1877050921016835`](https://www.sciencedirect.com/science/article/pii/S1877050921016835) | |
| *Paraconsistent Annotated Evidential Logic Eτ Applied to Autonomous Robots in Logistic Center* (2021), APMS | [hal-04022136](https://inria.hal.science/hal-04022136/) · DOI [`10.1007/978-3-030-85906-0_58`](https://doi.org/10.1007/978-3-030-85906-0_58) | HAL deposit usually carries a free author PDF |
| *Paraconsistent-Lib: An Intuitive PAL2v Algorithm Python Library* (2025) | [arXiv:2511.20700](https://arxiv.org/abs/2511.20700) | ⚠ identifier came from a search *summary*, not a result URL — confirm before citing |

---

## Background

**Paraconsistent Logic** — Stanford Encyclopedia of Philosophy.
<https://plato.stanford.edu/entries/logic-paraconsistent/> · free to read

> Context for the paraconsistent family generally; not specific to Eτ.

---

## Blocked hosts

`arxiv.org` · `export.arxiv.org` · `link.springer.com` · `www.sciencedirect.com` ·
`www.mdpi.com` · `doi.org` · `onlinelibrary.wiley.com` · `www.worldscientific.com` ·
`pmc.ncbi.nlm.nih.gov` · `europepmc.org` · `api.crossref.org` · `api.openalex.org` ·
`api.semanticscholar.org` · `core.ac.uk` · `zenodo.org` · `archive.org` · `dblp.org` ·
`philpapers.org` · `plato.stanford.edu` · `en.wikipedia.org` · `inria.hal.science`

All returned `403` at the `CONNECT` stage — an organization egress-policy denial, which
is reported rather than routed around.
