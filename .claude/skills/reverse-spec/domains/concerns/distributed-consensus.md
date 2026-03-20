# Concern: distributed-consensus (reverse-spec)

> Extends shared S0/R1 signals with reverse-spec-specific analysis rules.

## R1: Detection Signals
See `shared/domains/concerns/distributed-consensus.md` for S0 keywords and code patterns.

## R3: Feature Boundary Impact
When distributed consensus is detected:
- **Consensus module** (Raft/Paxos implementation) = Foundation-level, not a Feature
- Each **consumer of consensus** (e.g., replicated KV store, distributed lock) = separate Feature
- Leader election and membership changes = separate Feature if user-facing (e.g., admin API)

## R4: Data Flow Extraction
- Trace: Client Request → Leader → Log Append → Replicate → Commit → Apply to State Machine
- Record consensus protocol choice and consistency guarantees in pre-context.md § Foundation Decisions
- Note quorum size and failure tolerance in Architecture Notes
