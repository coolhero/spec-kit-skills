# Archetype: microservice (reverse-spec)

> Microservice / distributed system analysis. Loaded when project uses service decomposition, message queues, or container orchestration patterns.
> Module type: archetype (reverse-spec analysis)

---

## A0. Signal Keywords

> See [`shared/domains/archetypes/microservice.md`](../../../shared/domains/archetypes/microservice.md) § Signal Keywords

---

## A1. Analysis Axes — Philosophy Extraction

For each detected microservice pattern, extract:

| Principle | Extraction Targets | Output Format |
|-----------|--------------------|---------------|
| **Service Autonomy** | Service boundaries, independent deployment capability, database-per-service, shared state | Service isolation level; shared dependency map |
| **Failure Isolation** | Circuit breaker implementation, timeout/retry policies, bulkhead patterns, fallback strategies | Resilience patterns in use; failure propagation paths |
| **Eventual Consistency** | Event-driven communication, saga patterns, compensating transactions, idempotency guarantees | Consistency model; event flow diagram |
| **Observable by Default** | Distributed tracing, correlation IDs, centralized logging, metrics collection, health endpoints | Observability stack; trace propagation method |
| **Communication Patterns** | Sync (HTTP/gRPC) vs async (message queue/events), protocol choices, serialization format | Communication topology; sync/async ratio |
