# Archetype: cache-server

> In-memory data stores, caching servers, and key-value stores optimized for speed over durability.
> Distinct from database-engine: memory-first, eventual persistence, eviction-aware, data-structure-rich.

---

## Signal Keywords

### Semantic (A0 — for init inference)

**Primary**: cache, Redis, Memcached, in-memory store, key-value store, eviction, LRU, LFU, TTL, Dragonfly, KeyDB, Garnet

**Secondary**: cache invalidation, cache aside, write-through, write-behind, pub/sub, expiration, memory limit, maxmemory, data structure server, sorted set, hash map, HyperLogLog, bitmap

### Code Patterns (R1 — for source analysis)

- Redis: `redis-server`, `redis.conf`, `maxmemory`, `maxmemory-policy`, `RDB`, `AOF`, `MULTI/EXEC`
- Client libraries: `ioredis`, `redis-py`, `go-redis`, `fred` (Rust), `Jedis`, `Lettuce`
- Memcached: `memcached`, `-m` (memory limit), `slab allocator`, `cas` (check-and-set)
- Dragonfly: `dragonfly`, `DF_*` configs, multi-threaded architecture
- Patterns: `GET/SET/DEL`, `EXPIRE`, `SUBSCRIBE/PUBLISH`, `ZADD`, `HSET`, `LPUSH/RPUSH`

---

## Module Metadata

- **Axis**: Archetype
- **Common interfaces**: cli (client tool), library (embedded mode)
- **Common concerns**: wire-protocol, distributed-consensus (cluster mode), graceful-lifecycle, connection-pool
- **Profiles**: —
