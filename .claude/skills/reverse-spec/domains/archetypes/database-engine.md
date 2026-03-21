# Archetype: Database Engine (reverse-spec)

> Storage engine/query processor detection

## R1. Detection Signals

> See [`shared/domains/archetypes/database-engine.md`](../../../shared/domains/archetypes/database-engine.md) § Code Patterns

## R2. Classification Guide

When detected, classify the sub-type:
- **B-tree OLTP** — Row-oriented storage, B-tree/B+tree indexing, MVCC concurrency (PostgreSQL, MySQL)
- **LSM-tree** — Log-structured merge-tree, write-optimized, compaction strategies (RocksDB, LevelDB)
- **Columnar/OLAP** — Column-oriented storage, vectorized execution, analytical query optimization (DuckDB)
- **Distributed** — Sharding/partitioning, consensus protocols, distributed transactions (CockroachDB, TiDB)

## R3. Analysis Depth Modifiers

When detected, include in analysis:
- Storage format (page layout, row/column encoding, compression schemes)
- Indexing strategy (B-tree, LSM-tree, hash index, secondary indexes)
- Query optimizer (cost model, plan enumeration, statistics collection)
- WAL/journal (write-ahead log structure, checkpoint mechanism, recovery protocol)
- Transaction model (isolation levels, MVCC implementation, lock management)
- Replication (leader-follower, multi-leader, consensus algorithm, conflict resolution)
