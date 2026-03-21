# Archetype: cache-server

<!-- Format defined in smart-sdd/domains/_schema.md § Archetype Section Schema. -->

> In-memory data stores, caching servers, and key-value stores. Memory-first, eviction-aware, data-structure-rich.
> Distinct from database-engine: no ACID guarantees by default, memory is primary storage, persistence is optional.

---

## A0. Signal Keywords

> See [`shared/domains/archetypes/cache-server.md`](../../../shared/domains/archetypes/cache-server.md) § Signal Keywords

---

## A1. Domain Philosophy

| Principle | Description |
|-----------|-------------|
| **Memory-First** | Data lives in memory. Persistence (RDB, AOF) is a secondary concern. Design for memory constraints: bounded memory, eviction policies, memory-efficient data structures. Every feature must consider memory impact |
| **Data Structure Semantics** | The server exposes rich data structures (strings, lists, sets, sorted sets, hashes, streams, HyperLogLog) as first-class operations. Each data structure has specific time complexity guarantees. Operations are atomic at the command level |
| **Eviction as Feature** | Memory limits trigger eviction, not errors. Eviction policy (LRU, LFU, random, volatile-TTL) is a conscious design choice. Applications must handle cache misses gracefully. TTL is first-class |
| **Single-Threaded Correctness** | Core operations are single-threaded (or use shared-nothing multi-threading). This eliminates lock contention and ensures command atomicity. Multi-key transactions (MULTI/EXEC) are serialized |
| **Pub/Sub as Native** | Message passing (PUBLISH/SUBSCRIBE) is built into the server, not bolted on. Channels are lightweight, fire-and-forget (no persistence, no replay). Fan-out to all subscribers |

---

## A2. SC Extensions

| Domain | SC Extension |
|--------|-------------|
| **Eviction** | SC must specify: what happens when memory limit is reached? Which eviction policy is used? Verify: fill memory → insert new key → verify evicted key is correct policy victim |
| **TTL** | SC must specify: which keys have TTL? What is the TTL value? Verify: SET with TTL → wait → GET returns nil/miss. Verify: TTL does not drift under load |
| **Atomic operations** | SC must specify: which multi-key operations require atomicity? Verify: MULTI/EXEC or Lua script → concurrent access → no partial state observable |
| **Persistence** | SC must specify: RDB snapshots vs AOF log vs none. Verify: write data → trigger save → restart → verify data survived (or intentionally didn't) |

---

## A3. Probes

| Area | Probe Questions |
|------|----------------|
| **Memory** | Max memory limit? Eviction policy? Memory-efficient encoding (ziplist, listpack)? |
| **Data structures** | Which data types used (string, list, set, sorted set, hash, stream)? Custom data types? |
| **Persistence** | RDB, AOF, both, or none? fsync policy (always, everysec, no)? |
| **Cluster** | Single-node or cluster? Sharding strategy (hash slots)? Replication (master-replica)? |
| **Pub/Sub** | Pub/Sub channels used? Pattern subscriptions? Keyspace notifications? |
| **Scripting** | Lua scripts? Redis Functions? Atomicity guarantees? |

---

## A4. Constitution Injection

- **Memory budget awareness**: Every feature must document memory impact. New data structures must estimate per-key memory overhead. Features that grow unboundedly must have eviction or TTL
- **Cache miss is normal**: Application code must handle cache misses gracefully (fetch from source, not error). Cache hit rate is a metric, not a correctness requirement
- **No ACID assumptions**: Unlike databases, caches may lose data on restart (unless persistence is configured). Applications must not use cache as sole source of truth for critical data
- **Atomic command design**: Multi-step operations must use MULTI/EXEC or Lua scripts for atomicity. No "read-modify-write" without proper protection

---

## A5. Bug Prevention Extensions

| ID | Pattern | Detection | Prevention |
|----|---------|-----------|------------|
| CS-001 | Unbounded key growth | Key count grows monotonically → memory exhaustion → OOM kill or eviction storm | Every key namespace must have TTL or explicit cleanup. Monitor key count by prefix |
| CS-002 | Hot key bottleneck | Single key receives disproportionate traffic → single-thread saturation → latency spike for all clients | Detect hot keys via slowlog/latency monitoring. Split hot keys across shards or use client-side caching |
| CS-003 | Cache stampede | Cache miss → all concurrent requests fetch from DB simultaneously → DB overload | Use distributed lock (SETNX) or probabilistic early recomputation. Return stale data while refreshing |
| CS-004 | Persistence fork OOM | RDB save forks process → copy-on-write doubles memory on write-heavy workload → OOM | Monitor memory during save. Use AOF instead of RDB for write-heavy workloads. Set maxmemory with headroom for fork |
| CS-005 | Pub/Sub message loss | Subscriber disconnects → messages during disconnect are lost forever (pub/sub is fire-and-forget) | Use Redis Streams (XADD/XREAD with consumer groups) for durable messaging instead of PUBLISH/SUBSCRIBE |
