# Archetype: microservice (reverse-spec)

> Microservice / distributed system analysis. Loaded when project uses service decomposition, message queues, or container orchestration patterns.
> Module type: archetype (reverse-spec analysis)

---

## A0. Signal Keywords

- **Libraries**: `@grpc/grpc-js`, `protobufjs`, `amqplib` (RabbitMQ), `kafkajs`, `@nestjs/microservices`, `bull` / `bullmq`, `ioredis` (pub/sub), `nats`, `@aws-sdk/client-sqs`
- **Code patterns**: gRPC service definitions (`.proto` files), message queue producers/consumers, service-to-service HTTP calls, circuit breaker patterns, distributed tracing (correlation IDs, trace headers), health check endpoints (`/health`, `/ready`, `/live`)
- **Config files**: `docker-compose.yml` with multiple services, `Dockerfile`, Kubernetes manifests (`k8s/`, `helm/`), service mesh configs, `.proto` files, API gateway configs

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
