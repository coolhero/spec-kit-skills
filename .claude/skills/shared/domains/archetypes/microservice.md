# Archetype: microservice

> Distributed service architecture — service mesh, message queues, container orchestration.

---

## Signal Keywords

### Semantic (A0 — for init inference)

**Primary**: microservice, service mesh, gRPC, message queue, event-driven architecture, distributed system, service discovery, API gateway, container orchestration, Kubernetes, Docker Compose (multi-service)

**Secondary**: circuit breaker, saga pattern, eventual consistency, distributed tracing, sidecar, service registry, CQRS, event sourcing, correlation ID

### Code Patterns (A0 — for source analysis)

- **Libraries**: `@grpc/grpc-js`, `protobufjs`, `amqplib` (RabbitMQ), `kafkajs`, `@nestjs/microservices`, `bull` / `bullmq`, `ioredis` (pub/sub), `nats`, `@aws-sdk/client-sqs`
- **Code patterns**: gRPC service definitions (`.proto` files), message queue producers/consumers, service-to-service HTTP calls, circuit breaker patterns, distributed tracing (correlation IDs, trace headers), health check endpoints (`/health`, `/ready`, `/live`)
- **Config files**: `docker-compose.yml` with multiple services, `Dockerfile`, Kubernetes manifests (`k8s/`, `helm/`), service mesh configs, `.proto` files, API gateway configs

### Spring Cloud Patterns (Java/Kotlin)
- `@EnableEurekaClient` / `@EnableDiscoveryClient` — service registry registration
- `@FeignClient(name = "service-name")` — declarative inter-service HTTP client
- Spring Cloud Gateway route definitions (`RouteLocatorBuilder`, `application.yml` routes)
- `@EnableConfigServer` / `spring.cloud.config.*` — centralized configuration
- `@CircuitBreaker` / `@Retry` (Resilience4j) / `@HystrixCommand` (legacy) — resilience patterns
- `spring-cloud-starter-*` dependencies in `pom.xml`/`build.gradle`
- `bootstrap.yml` / `bootstrap.properties` — Spring Cloud bootstrap config
- `@RefreshScope` — runtime config refresh

---

## Module Metadata

- **Axis**: Archetype
- **Typical interfaces**: http-api
- **Common pairings**: message-queue, task-worker
