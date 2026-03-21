# Concern: graceful-lifecycle

<!-- Format defined in smart-sdd/domains/_schema.md § Concern Section Schema. -->
<!-- This file provides S0/S1/S5/S7 for smart-sdd pipeline execution. -->
<!-- The corresponding reverse-spec file (reverse-spec/domains/concerns/graceful-lifecycle.md) provides R1 detection. -->

> Server process lifecycle management: startup readiness, health checks, graceful shutdown, connection draining.

---

## S0. Signal Keywords

> See [`shared/domains/concerns/graceful-lifecycle.md`](../../../shared/domains/concerns/graceful-lifecycle.md) § Signal Keywords

---

## S1. SC Generation Rules

### Required SC Patterns
When this concern is active, every Feature that involves server process lifecycle MUST include SCs for:

| Pattern | SC Requirement |
|---------|---------------|
| **Health Check** | Liveness endpoint returns 200 when process is alive; readiness endpoint returns 200 only when all dependencies (DB, cache, message broker) are connected and warmed up; returns 503 during startup/shutdown |
| **Graceful Shutdown** | On SIGTERM: stop accepting new connections → drain in-flight requests (with timeout) → close DB/cache connections → exit 0. Verify no request returns 5xx during rolling restart |
| **Startup Readiness** | Server does NOT accept traffic until warm-up completes (cache priming, model loading, connection pool filling). Health check reflects this with readiness=false during startup |
| **Connection Draining** | During shutdown, existing connections complete within drain timeout; connections exceeding timeout are forcefully closed. New connections receive 503 or connection refused |
| **Idle Timeout** | Long-idle connections are reaped after configurable timeout. Client reconnects transparently |

### SC Anti-Patterns (reject if seen)
- "Server shuts down cleanly" — must specify SIGTERM handling, drain timeout, in-flight request behavior, and exit code
- "Health check endpoint exists" — must specify what dependencies are checked, what constitutes "ready" vs "alive", and response codes for each state
- "Server starts up" — must specify readiness gate (what must complete before traffic is accepted)

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|-----------------|
| **Health Model** | Separate liveness/readiness? What dependencies does readiness check? Startup probe needed (slow init)? |
| **Shutdown Sequence** | What is the drain timeout? What happens to WebSocket/streaming connections? Pre-stop hook needed (K8s)? |
| **Warm-up** | Cache priming? Connection pool filling? Model loading? How long does warm-up take? |
| **Process Signals** | SIGTERM only or also SIGINT/SIGHUP? Reload on SIGHUP? |
| **Zero-Downtime** | Rolling restart strategy? Multiple instances behind LB? Blue-green or canary? |

---

## S7. Bug Prevention

| ID | Pattern | Detection | Prevention |
|----|---------|-----------|------------|
| GL-001 | Premature traffic acceptance | Server accepts requests before DB connection pool is ready → first requests fail with connection errors | Gate readiness endpoint behind dependency checks; do not bind listener until warm-up completes |
| GL-002 | Hard shutdown data loss | SIGTERM → immediate process.exit() drops in-flight writes → data corruption or partial responses | Implement drain timeout: stop accepting new requests, wait for in-flight to complete (up to N seconds), then force-close |
| GL-003 | Zombie connections after shutdown | Server closes listener but long-lived connections (WebSocket, gRPC streaming) are never closed → process hangs indefinitely | Track active connections; on shutdown, send close frame / goaway; force-close after drain timeout |
| GL-004 | Health check false positive | Liveness returns 200 but readiness also returns 200 before DB is connected → LB routes traffic to unready instance | Separate liveness (process alive) from readiness (dependencies connected + warmed up); readiness=503 during startup |
| GL-005 | Cascading restart storm | All instances restart simultaneously → zero capacity → 100% downtime | Use rolling restart with maxUnavailable constraint; stagger startup with jitter |
