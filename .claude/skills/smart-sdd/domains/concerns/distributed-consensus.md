# Concern: distributed-consensus

> Consensus protocols and distributed agreement — Raft, Paxos, gossip, leader election.
> Module type: concern

---

## S0. Signal Keywords

> See [`shared/domains/concerns/distributed-consensus.md`](../../../shared/domains/concerns/distributed-consensus.md) § Signal Keywords

---

## S1. SC Generation Rules

### Required SC Patterns
- Leader election: candidate requests votes → quorum achieved → leader established → heartbeats maintain authority → term increments on re-election
- Log replication: leader appends entry → replicates to followers → quorum ack → entry committed → applied to state machine
- Membership change: add/remove node → joint consensus or single-step change → cluster continues operating during transition
- Partition handling: network split → minority partition stops accepting writes → partition heals → state reconciliation

### SC Anti-Patterns (reject)
- "Nodes agree on state" — must specify consensus protocol, quorum size, and partition behavior
- "Leader is elected" — must specify election timeout, term tracking, vote persistence, and split-brain prevention
- "Data is replicated" — must specify replication factor, ack policy (majority/all), and consistency guarantee

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| **Protocol** | Raft? Paxos? Multi-Paxos? Gossip (SWIM)? ZAB? Custom? |
| **Quorum** | Majority quorum? Flexible quorum? Witness nodes? |
| **Persistence** | Where are log entries and votes persisted? WAL? fsync policy? |
| **Snapshot** | Log compaction strategy? Snapshot transfer to slow followers? Snapshot frequency? |
| **Membership** | Static or dynamic membership? Joint consensus for config changes? Bootstrap procedure? |
| **Testing** | Fault injection (network partition, node crash, disk failure)? Deterministic simulation? Jepsen-style testing? |

---

## S7. Bug Prevention — Consensus-Specific

| ID | Pattern | Detection | Prevention |
|----|---------|-----------|------------|
| DC-001 | Split brain | Network partition with both sides accepting writes → data divergence | Quorum-based writes; minority partition must reject mutations |
| DC-002 | Stale read | Reading from follower with uncommitted entries → returning data that may be rolled back | Read from leader, or follower read with leader lease check; linearizable read protocol |
| DC-003 | Election storm | Aggressive election timeouts → constant re-elections → no stable leader | Randomized election timeouts; pre-vote protocol to prevent disruption from partitioned nodes |
| DC-004 | Log divergence | Leader crash before replication completes → followers have divergent logs | Log matching property enforcement; truncate divergent entries on new leader establishment |
| DC-005 | Snapshot corruption | Incomplete or corrupted snapshot transfer → follower starts with invalid state | Checksum verification on snapshot; streaming with resumption on failure |
