# Archetype: database-engine

> Storage engines, query processors, and database systems — from embedded DBs to distributed OLAP/OLTP.

---

## Signal Keywords

### Semantic (A0 — for init inference)

**Primary**: storage engine, query planner, WAL, write-ahead log, B-tree, LSM, LSM-tree, raft, consensus, transaction, MVCC, SQL parser, query optimizer, database engine, embedded database

**Secondary**: page cache, buffer pool, compaction, memtable, SSTable, redo log, undo log, checkpoint, recovery, schema migration, index scan, sequential scan, cost-based optimizer, query execution plan

### Code Patterns (A0 — for source analysis)

- **Storage**: WAL implementation, page/block management, B-tree/LSM-tree data structures, compaction strategies, memtable flush
- **Query**: SQL parser (pest, ANTLR, hand-written recursive descent), AST nodes, logical plan → physical plan transformation, cost estimation
- **Transaction**: MVCC version chains, lock managers, isolation level enforcement, two-phase commit
- **Replication**: Raft state machine, log replication, leader election, snapshot transfer
- **Config files**: `*.conf` with storage/memory/WAL settings, data directory layout

---

## A1: Core Principles

| Principle | Description |
|-----------|-------------|
| **Storage/Compute Separation** | Storage layer (disk I/O, page management) is independent from compute layer (query processing). Changes to one should not require changes to the other. |
| **ACID Guarantees** | Atomicity (WAL + undo), Consistency (constraints), Isolation (MVCC/locking), Durability (fsync + WAL). Every code path must preserve these guarantees. |
| **Query Lifecycle** | Parse → Bind → Plan → Optimize → Execute. Each stage has clear input/output contracts. |
| **Replication & Consistency Model** | Explicit consistency model (strong, eventual, causal). Replication protocol (Raft, Paxos, primary-replica) documented and tested under partition. |
| **Schema Evolution** | Schema changes must be backward-compatible or have explicit migration paths. Online DDL preferred over locking DDL. |

---

## Module Metadata

- **Axis**: Archetype
- **Typical interfaces**: cli, embedded-library, http-api
- **Common pairings**: distributed-consensus, wire-protocol
