# Archetype: database-engine

> Storage engines, query processors, and database systems — from embedded DBs to distributed OLAP/OLTP.
> Module type: archetype

---

## A0. Signal Keywords

> See [`shared/domains/archetypes/database-engine.md`](../../../shared/domains/archetypes/database-engine.md) § Signal Keywords

---

## A1. Philosophy Principles

| Principle | Description | Implication |
|-----------|-------------|-------------|
| **Storage/Compute Separation** | Storage layer (disk I/O, page management) is independent from compute layer (query processing). Changes to one should not require changes to the other. | Features must be scoped to one layer. SCs crossing the boundary must specify the interface contract between layers. |
| **ACID Guarantees** | Atomicity (WAL + undo), Consistency (constraints), Isolation (MVCC/locking), Durability (fsync + WAL). Every code path must preserve these guarantees. | Every Feature touching data mutation must specify which ACID properties it maintains. Verify must include crash recovery testing. |
| **Query Lifecycle** | Parse → Bind → Plan → Optimize → Execute. Each stage has clear input/output contracts. | Features modifying query processing must specify which stage(s) are affected and preserve stage boundaries. |
| **Replication & Consistency Model** | Explicit consistency model (strong, eventual, causal). Replication protocol documented and tested under partition. | SCs must specify consistency guarantee. Distributed features must include partition tolerance testing. |
| **Schema Evolution** | Schema changes must be backward-compatible or have explicit migration paths. Online DDL preferred over locking DDL. | Features adding schema changes must specify migration strategy, backward compatibility, and locking behavior. |

---

## A2. SC Generation Extensions

### Required SC Patterns (append to S1)
- **ACID compliance**: SC must specify which ACID properties the feature maintains and how (WAL for durability, MVCC for isolation, etc.)
- **Crash recovery**: SC must specify behavior after unclean shutdown — WAL replay, consistency check, data integrity guarantee
- **Query plan impact**: SC modifying query processing must specify expected plan changes and performance implications
- **Concurrency control**: SC must specify isolation level, locking strategy (optimistic/pessimistic), and deadlock handling

### SC Anti-Patterns (reject)
- "Data is stored" — must specify storage format, durability guarantee (fsync policy), and crash recovery behavior
- "Query returns results" — must specify which query stage is modified, plan impact, and correctness guarantee
- "Transactions work" — must specify isolation level, conflict resolution, and rollback mechanism

---

## A3. Elaboration Probes (append to S5)

| Sub-domain | Probe Questions |
|------------|----------------|
| **Storage engine** | B-tree? LSM-tree? Custom? Page size? Compression? |
| **Query processing** | SQL? Custom query language? Hand-written parser or parser generator? Cost-based optimizer? |
| **Transaction model** | MVCC? 2PL? OCC? Isolation levels supported? |
| **WAL** | WAL format? fsync policy? Log compaction/checkpointing? |
| **Replication** | Single-node or distributed? Raft? Primary-replica? Sharding strategy? |
| **Testing** | Crash recovery tests? Deterministic simulation? Fuzzing? Correctness proofs? |

---

## A4. Constitution Injection

| Principle | Rationale |
|-----------|-----------|
| Every data mutation path must be WAL-protected — no direct page modification without log entry | Without WAL, any crash during write corrupts data permanently; WAL enables crash recovery |
| Storage and compute layers must communicate through defined interfaces — no direct cross-layer access | Tight coupling prevents independent evolution; interface contracts enable storage engine swaps |
| All query processing must follow the Parse → Plan → Execute pipeline — no shortcut paths | Shortcut paths bypass optimization and permission checks; pipeline stages are correctness boundaries |
| Crash recovery must be tested as a first-class feature — not an afterthought | Database correctness is meaningless without durability; crash recovery bugs are silent data loss |
| Concurrent access uses explicit isolation levels — never "undefined" or "implementation-dependent" behavior | Users depend on documented isolation guarantees; undefined behavior causes subtle data corruption |

---

## A5. Brief Completion Criteria

| Required Element | Completion Signal |
|-----------------|-------------------|
| Storage model | B-tree, LSM, or other storage structure identified |
| ACID scope | Which ACID guarantees are provided and how |
| Query interface | Query language or API for data access described |
| Durability mechanism | WAL, fsync policy, or other durability strategy stated |
