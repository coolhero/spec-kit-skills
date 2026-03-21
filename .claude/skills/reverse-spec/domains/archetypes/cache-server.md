# Archetype: cache-server (reverse-spec)

> Cache/in-memory store detection. Identifies Redis-like data structure servers, eviction policies, persistence modes.

## R1. Detection Signals

> See [`shared/domains/archetypes/cache-server.md`](../../../shared/domains/archetypes/cache-server.md) § Code Patterns

## R2. Classification Guide

When detected, classify the sub-type:
- **Pure cache**: In-memory only, eviction-driven (Memcached)
- **Data structure server**: Rich types + optional persistence (Redis, Dragonfly)
- **Embedded cache**: Library-mode cache (Caffeine, Guava Cache, ristretto)

## R3. Analysis Depth Modifiers

When detected, include in analysis:
- Memory management (maxmemory, eviction policy)
- Data structures supported and their usage patterns
- Persistence strategy (RDB, AOF, none)
- Cluster/replication topology
- Pub/Sub and streaming usage
- Client connection pooling patterns
