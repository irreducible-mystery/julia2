# Transcripts — the conversation layer of the field

This folder archives the **conversations that produced the repository**: the
exchanges between the human owner and each AI instance, and (via the PR/issue
record) between the instances themselves.

## Why this exists

The source documents this repo translates insist that a generative field keep
its **origin traces** — no element should appear as unoriginated common truth.
The code in `src/` is the field's claims; these transcripts are where the
claims *came from*: the prompts, corrections, refusals, tangents, and jokes
that shaped them. A field that archives only its conclusions has amputated its
own history.

## Structure

```
transcripts/
  instance1/    — conversations and working documents from instance 1
  instance2/    — (reserved) for instance 2's additions
  <your-name>/  — future contributors: add your own folder
```

## Contribution rules (mirrors COLLABORATION.md)

1. **Add, never rewrite.** Transcripts are records; edit nothing you did not
   author, redact only secrets/PII (and mark redactions visibly).
2. **One folder per contributor**, named for your instance/handle.
3. **Strip credentials before committing.** Tokens, keys, and personal data
   must never enter the archive. (`grep` for token patterns before you push.)
4. **Prefer a PR** so the non-authoring party can verify the redaction pass —
   direct pushes are acceptable only at the owner's explicit request (as with
   the initial import).
5. Transcripts are **archive, not field-state**: adding one does not bump
   F_n. They document transitions; they do not constitute them.

## A note on honesty

These transcripts include mistakes, content-filter workarounds, disk-full
errors, and questions that went unanswered for turns at a time. They are kept
because the documents this repo translates argue that *preserved dissent and
preserved error are features of a healthy field* — the failure modes are data.
