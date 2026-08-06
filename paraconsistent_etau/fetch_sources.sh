#!/usr/bin/env bash
# Complete the Eτ download on a network that permits scholarly hosts.
#
#   ./fetch_sources.sh          open-access literature + the pinned implementation
#   ./fetch_sources.sh --all    also attempt paywalled items (needs entitlement)
#
# Everything lands in downloads/ (git-ignored). Pinned artifacts are sha256-verified.
# TLS verification is never disabled; a blocked host is reported, not worked around.
set -uo pipefail
cd "$(dirname "$0")"

WANT_ALL=0
[[ "${1:-}" == "--all" ]] && WANT_ALL=1

OUT=downloads
mkdir -p "$OUT/papers" "$OUT/implementation"

ok=0; failed=0; skipped=0

say() { printf '%s\n' "$*"; }
rule() { printf '%s\n' "──────────────────────────────────────────────────────────────"; }

# fetch <url> <destination> [expected_sha256]
fetch() {
    local url="$1" dest="$2" want="${3:-}"
    if [[ -s "$dest" ]]; then
        say "  · already present: $(basename "$dest")"
    else
        if ! curl -fsSL --max-time 120 --retry 2 -o "$dest" "$url"; then
            say "  ✗ BLOCKED/FAILED: $url"
            rm -f "$dest"
            failed=$((failed+1))
            return 1
        fi
    fi
    if [[ -n "$want" ]]; then
        local got
        got=$(sha256sum "$dest" | cut -d' ' -f1)
        if [[ "$got" != "$want" ]]; then
            say "  ✗ CHECKSUM MISMATCH for $(basename "$dest")"
            say "      expected $want"
            say "      got      $got"
            failed=$((failed+1))
            return 1
        fi
        say "  ✓ $(basename "$dest")  [sha256 verified]"
    else
        say "  ✓ $(basename "$dest")"
    fi
    ok=$((ok+1))
}

rule; say "  Implementation (pinned by sha256)"; rule

fetch "https://files.pythonhosted.org/packages/89/1e/7e9fe1dd5adf653ca260a72d6efd5db5394b3175d683df2ee0e13156900b/paraconsistent-0.2.4.tar.gz" \
      "$OUT/implementation/paraconsistent-0.2.4.tar.gz" \
      "2aa537d4048dec80fc7503c0bc167dc0088da241c1a0ff754b79bbb697c5e440"

fetch "https://files.pythonhosted.org/packages/26/16/44cde68657e145e0842042341777bde745553441f081c69d0c53f0454223/paraconsistent-0.2.4-py3-none-any.whl" \
      "$OUT/implementation/paraconsistent-0.2.4-py3-none-any.whl" \
      "b5b69a1893d5ba5eff0df5a10e7851cdc5e4788cbb85e41d2ed2c215a67c6b9f"

if [[ ! -d "$OUT/implementation/paraconsistent-lib" ]]; then
    say "  · cloning eailab-ifsp/paraconsistent-lib"
    if git clone --quiet https://github.com/eailab-ifsp/paraconsistent-lib \
            "$OUT/implementation/paraconsistent-lib" 2>/dev/null; then
        git -C "$OUT/implementation/paraconsistent-lib" \
            checkout --quiet e6106a9356928ce693bb01ec1682a9d9a9b29eb6 2>/dev/null \
            && say "  ✓ paraconsistent-lib @ e6106a9" \
            || say "  ✓ paraconsistent-lib (pinned commit not found; left at default branch)"
        ok=$((ok+1))
    else
        say "  ✗ BLOCKED/FAILED: github.com/eailab-ifsp/paraconsistent-lib"
        failed=$((failed+1))
    fi
else
    say "  · already present: paraconsistent-lib"
fi

rule; say "  Open-access literature"; rule

fetch "https://arxiv.org/pdf/2105.07579"  "$OUT/papers/arxiv-2105.07579-fuzzy-and-PAL-network-monitoring.pdf"
fetch "https://arxiv.org/pdf/2009.14192"  "$OUT/papers/arxiv-2009.14192-mobile-robots-corridors-Etau.pdf"
fetch "https://arxiv.org/pdf/2511.20700"  "$OUT/papers/arxiv-2511.20700-paraconsistent-lib-PAL2v.pdf"
fetch "https://www.mdpi.com/1424-8220/21/12/4219/pdf" \
      "$OUT/papers/sensors-21-4219-PAL-network-routes-CC-BY.pdf"
fetch "https://www.sciencedirect.com/science/article/pii/S1877050919314838/pdf" \
      "$OUT/papers/procedia-2019-three-decades-of-PAL.pdf"
fetch "https://www.sciencedirect.com/science/article/pii/S1877050921016835/pdf" \
      "$OUT/papers/procedia-2021-Etau-mobile-robot-obstacles.pdf"
fetch "https://inria.hal.science/hal-04022136/document" \
      "$OUT/papers/hal-04022136-Etau-autonomous-robots-logistics.pdf"

if (( WANT_ALL )); then
    rule; say "  Paywalled — expect failure without an institutional entitlement"; rule
    fetch "https://onlinelibrary.wiley.com/doi/pdf/10.1002/malq.19910370903" \
          "$OUT/papers/daCosta-Subrahmanian-Vago-1991-paraconsistent-logics-Ptau.pdf"
    fetch "https://link.springer.com/content/pdf/10.1007/978-3-319-74110-9_2.pdf" \
          "$OUT/papers/Carvalho-Abe-2018-paraconsistent-annotated-evidential-logic-Etau.pdf"
    fetch "https://link.springer.com/content/pdf/10.1007/978-3-319-17912-4.pdf" \
          "$OUT/papers/Abe-Akama-Nakamatsu-2015-introduction-to-annotated-logics.pdf"
else
    skipped=3
    say
    say "  (3 paywalled items skipped — re-run with --all to attempt them)"
fi

rule
say "  fetched: $ok    failed/blocked: $failed    skipped: $skipped"
say "  destination: $(pwd)/$OUT"
rule

# Blocked scholarly hosts are an environment fact, not a script bug: report, don't fail hard.
(( failed == 0 )) || say "  Some hosts were unreachable. If every paper failed, the network"
(( failed == 0 )) || say "  policy is denying scholarly hosts — see README.md."

exit 0
