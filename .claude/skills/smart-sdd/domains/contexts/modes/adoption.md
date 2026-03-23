# Context Mode: adoption

> Wrapping existing code with SDD documentation. No new implementation.
> Module type: scenario

---

## S4. Adoption-Specific Behavior

> Defined in `commands/adopt.md` (pipeline flow) and `reference/injection/adopt-verify.md` (non-blocking verify).
> Key differences: test/build/lint failures are non-blocking (recorded as baseline), demo is optional, Feature status is `adopted` (not `completed`).

| Field | Behavior |
|-------|----------|
| **Verify treatment** | Test/build/lint failures are non-blocking (recorded as pre-existing baseline) |
| **Demo pattern** | Optional in adoption mode (existing code may not have demo infrastructure) |
| **Injection framing** | "Extract what exists" — not "define what to build" |
| **Feature status** | `adopted` (not `completed`) — indicates documented but not re-implemented |

## SC Rules (extends _core)

- SCs describe EXISTING behavior, not desired behavior
- SCs should be verifiable against current implementation
- SCs that fail against current code are recorded as "known issues"

## Verification Strategy

- Non-blocking: failures recorded as baseline, not pipeline blockers
- Purpose: establish what works and what doesn't in current code
- Foundation for future incremental improvements
