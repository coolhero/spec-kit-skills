# Concern: distributed-consensus

> Consensus protocols and distributed agreement — Raft, Paxos, gossip, leader election.

---

## Signal Keywords

### Semantic (S0 — for init inference)

**Primary**: raft, paxos, gossip, leader election, log replication, term, vote, heartbeat, quorum, consensus protocol, distributed consensus

**Secondary**: snapshot, membership change, configuration change, split brain, network partition, consistency guarantee, linearizability, state machine replication, append entries, request vote

### Code Patterns (R1 — for source analysis)

- **Raft**: state machine with Leader/Follower/Candidate roles, `AppendEntries` RPC, `RequestVote` RPC, term tracking, commit index, log compaction/snapshotting
- **Libraries**: `etcd/raft`, `hashicorp/raft`, `openraft`, `tikv/raft-rs`, `ratis` (Java), `dragonboat` (Go)
- **Gossip**: SWIM protocol, `memberlist`, `serf`, failure detection, protocol period, suspicion timeout
- **Patterns**: quorum calculation (`n/2 + 1`), election timeout randomization, heartbeat interval, log entry persistence

---

## Module Metadata

- **Axis**: Concern
- **Common pairings**: database-engine (archetype), message-broker (archetype)
- **Profiles**: —
