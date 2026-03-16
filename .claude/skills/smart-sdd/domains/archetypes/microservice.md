# Archetype: microservice

> Microservice / distributed system architecture. Applies when the project decomposes into independently deployable services communicating via network protocols.
> Module type: archetype

---

## A0. Signal Keywords

> See [`shared/domains/archetypes/microservice.md`](../../../shared/domains/archetypes/microservice.md) § Signal Keywords

---

## A1. Philosophy Principles

| Principle | Description | Implication |
|-----------|-------------|-------------|
| **Service Autonomy** | Each service owns its data and logic — no shared databases, no direct coupling between service internals | Service boundaries must be explicit; cross-service data access only through defined APIs/events |
| **Failure Isolation** | One service's failure must not cascade to others — design for partial degradation | Circuit breakers, timeouts, retries, and fallbacks are mandatory for every cross-service call |
| **Eventual Consistency** | Accept that data will be temporarily inconsistent across services — design for convergence | Saga patterns or event-driven reconciliation for cross-service transactions; no distributed locks |
| **Observable by Default** | Every service must emit structured logs, metrics, and traces from day one | Distributed tracing (correlation IDs) in every cross-service call; centralized logging mandatory |
| **Independent Deployment** | Each service must be deployable without requiring coordination with other services | Backward-compatible APIs; feature flags for cross-service feature rollouts; contract testing |

---

## A2. SC Generation Extensions

### Required SC Patterns
- **Service boundary**: SCs must specify which service owns the behavior and what cross-service calls are involved
- **Failure handling**: Every SC involving cross-service communication must specify timeout, retry policy, circuit breaker behavior, and fallback
- **Consistency model**: SCs involving data that spans services must specify the consistency guarantee (strong/eventual) and reconciliation mechanism
- **Observability**: SCs must specify what traces/metrics/logs are emitted for the behavior being specified

### SC Anti-Patterns (reject)
- "Service communicates with other service" — must specify protocol (HTTP/gRPC/event), serialization format, timeout, retry, and failure behavior
- "Data is consistent across services" — must specify consistency model, event flow, and eventual consistency window
- "System handles failure" — must specify which failures, detection method, circuit breaker thresholds, and degraded behavior

---

## A3. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| **Service boundaries** | What services exist? What data does each own? How are boundaries defined? |
| **Communication** | Sync (HTTP/gRPC) or async (events/queues)? Protocol for each service pair? Serialization format? |
| **Resilience** | Circuit breaker library? Timeout/retry policies? Bulkhead pattern? Fallback strategies? |
| **Data consistency** | Saga pattern? Event sourcing? Outbox pattern? Compensating transactions? |
| **Observability** | Distributed tracing (Jaeger/Zipkin/OpenTelemetry)? Centralized logging? Metrics (Prometheus/Datadog)? |
| **Deployment** | Container orchestration (K8s/ECS/Docker Compose)? Service mesh? CI/CD per service? |

---

## A4. Constitution Injection

Principles to inject into constitution-seed when this archetype is active:

| Principle | Rationale |
|-----------|-----------|
| Each service must own its data store — no shared databases between services | Shared databases create hidden coupling that prevents independent deployment and scaling |
| Every cross-service call must have explicit timeout, retry, and circuit breaker configuration | Network is unreliable; unprotected cross-service calls are the #1 cause of cascading failures |
| Cross-service data consistency uses eventual consistency patterns (events/sagas) — never distributed transactions | Distributed transactions don't scale and create tight coupling; eventual consistency preserves autonomy |
| All cross-service requests must propagate correlation IDs for distributed tracing | Without trace propagation, debugging production issues across services is effectively impossible |
| Services must be independently deployable with backward-compatible API changes | Coordinated deployments negate the primary benefit of microservices (independent release cycles) |
