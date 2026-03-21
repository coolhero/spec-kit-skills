# Concern: connection-pool

<!-- Format defined in smart-sdd/domains/_schema.md § Concern Section Schema. -->
<!-- This file provides S0/S1/S5/S7 for smart-sdd pipeline execution. -->
<!-- The corresponding reverse-spec file (reverse-spec/domains/concerns/connection-pool.md) provides R1 detection. -->

> Connection and resource pool management: DB connections, HTTP clients, gRPC channels, thread pools.

---

## S0. Signal Keywords

> See [`shared/domains/concerns/connection-pool.md`](../../../shared/domains/concerns/connection-pool.md) § Signal Keywords

---

## S1. SC Generation Rules

### Required SC Patterns
When this concern is active, every Feature involving pooled resources MUST include SCs for:

| Pattern | SC Requirement |
|---------|---------------|
| **Pool Sizing** | Specify min and max pool size. Max size prevents resource exhaustion on server; min size ensures warm connections available. Justify sizing based on expected concurrency |
| **Acquire Timeout** | When pool is exhausted, new requests wait up to acquire timeout, then fail with clear error (not hang indefinitely). Specify timeout value |
| **Idle Eviction** | Connections idle beyond threshold are closed to free resources. Specify idle timeout. Connections exceeding max lifetime are recycled regardless of activity |
| **Health Validation** | Stale/broken connections detected before use (validation query, ping). Connection validated on borrow or at interval. Broken connections evicted, not returned to pool |
| **Graceful Shutdown** | On process shutdown: stop lending, drain active borrows (with timeout), close all connections. No connection leak on restart |

### SC Anti-Patterns (reject if seen)
- "Connection pool is configured" — must specify min/max size, timeouts, and eviction policy
- "Database connections are managed" — must specify pool vs per-request, sizing rationale, and exhaustion behavior
- "HTTP client reuses connections" — must specify keepalive timeout, max connections per host, and stale detection

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|-----------------|
| **Sizing** | Max pool size? Based on what (CPU cores, expected QPS, upstream limits)? Different per environment? |
| **Lifetime** | Max connection lifetime? Idle timeout? Validation interval? |
| **Exhaustion** | What happens when pool is full? Queue? Reject? Timeout? |
| **Monitoring** | Pool utilization metrics exposed? Alert on near-exhaustion? |
| **Multi-tenant** | Shared pool or per-tenant pools? Tenant isolation in pool? |

---

## S7. Bug Prevention

| ID | Pattern | Detection | Prevention |
|----|---------|-----------|------------|
| CP-001 | Connection leak | Pool gradually empties as connections are borrowed but never returned → acquire timeouts → service degradation | Use try-finally/defer/using to guarantee connection return; monitor active vs idle counts; alert on sustained high active ratio |
| CP-002 | Stale connection error | Connection in pool was closed by server (TCP reset, firewall timeout) → first query after idle fails | Validate connection on borrow (ping/SELECT 1); set max idle time shorter than server/firewall timeout |
| CP-003 | Pool exhaustion cascade | One slow query holds connection → pool fills up → all other requests queue → timeout cascade | Set acquire timeout (fail fast, not hang); set statement/query timeout; monitor pool wait time |
| CP-004 | Over-provisioned pool | Pool max set too high → exceeds upstream connection limit (e.g., PostgreSQL max_connections) → upstream rejects connections | Size pool based on upstream capacity / number of instances; coordinate pool size across replicas |
| CP-005 | Startup connection storm | All instances start simultaneously → each opens max connections → upstream overloaded | Use min pool size (not max) at startup; ramp connections gradually; add startup jitter across instances |
