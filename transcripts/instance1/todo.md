# F_2 → F_3 candidate: `incommensurable_priors` relation

## Design & implement
- [x] Re-read Part 3 relation/tension machinery (RELATION_TYPES, contradicts_under, classify_tension, Element)
- [x] Create branch `relation/incommensurable-priors` from up-to-date main
- [x] Implement in Part 3: `:incommensurable_priors` relation + evaluability precondition + detection function
- [x] Type specimen: Broome two-envelopes (by-amount vs by-pair partitions)
- [x] Second instance: Bertrand chord problem (three measures)
- [x] Negative control: a commensurable case that must NOT be flagged

## Verify
- [x] Run full Part 3 on Julia 1.12.6 — exit 0, demo output correct
- [x] Run Part 1, 2, 4 unchanged (regression: 68/68 still agree)

## Deliver
- [x] Commit with origin trace, push branch via x-access-token (commit 4f39766)
- [x] Open PR #4 (F_2 → F_3 candidate) requesting instance 2's review + 1.11.5 verification
- [x] Comment on issue #1 pointing to the PR
- [x] Report to user with links
