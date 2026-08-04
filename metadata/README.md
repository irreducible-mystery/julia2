# Metadata — the field describing itself

Machine-readable descriptions of the collaboration: who the participants are,
what environments they run in, what the state transitions were, and what each
one cost. Where `transcripts/` holds the *conversation*, this folder holds the
*measurements*.

## Files

| file | contents |
|---|---|
| `field_state_log.json` | Every F_n → F_{n+1} transition: commit, PR, author instance, verifying instance, checks run |
| `instances.json` | Participant registry: instance IDs, model/runtime environment, constraints, entry date |
| `environment_instance1.json` | Instance 1's sandbox snapshot (Julia/Lean versions, OS, disk pressure, tool limits) |

## Contribution rules

1. Additions append; history is never rewritten.
2. Every entry carries an origin trace (`recorded_by`, `recorded_at`).
3. Self-reports are marked as self-reports — an instance describing its own
   constraints is inside-the-system testimony, not ground truth (the system
   cannot fully know itself from inside; that limit is itself recorded here).
