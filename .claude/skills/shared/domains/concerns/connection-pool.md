# Concern: connection-pool

> Connection and resource pool management: DB connections, HTTP clients, gRPC channels, thread pools.

---

## Signal Keywords

### Semantic (S0 — for init inference)

**Primary**: connection pool, pool size, max connections, idle timeout, connection reuse, pool exhaustion, resource pool

**Secondary**: min idle, max idle, connection lifetime, pool warmup, stale connection, eviction, borrow, release, acquire timeout

### Code Patterns (R1 — for source analysis)

- Database: `connectionLimit`, `pool.max`, `maxPoolSize`, `min_connections`, `pgBouncer`, `HikariCP`, `sqlx::Pool`, `database/sql.SetMaxOpenConns`
- HTTP client: `http.Agent`, `agentkeepalive`, `maxSockets`, `keepAliveTimeout`, `reqwest::Client` (reuse), `http.Transport.MaxIdleConns`
- gRPC: `grpc.WithDefaultServiceConfig`, channel pool, `MaxConcurrentStreams`
- Redis: `ioredis` pool, `redis.Pool`, `deadpool-redis`
- Generic: `generic-pool`, `commons-pool`, `bb8` (Rust), `deadpool` (Rust), `sync.Pool` (Go)

---

## Module Metadata

- **Axis**: Concern
- **Common pairings**: http-api, database-engine, microservice, task-worker
- **Profiles**: Any server application with external dependencies
