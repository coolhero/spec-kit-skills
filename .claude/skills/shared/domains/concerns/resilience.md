# Concern: resilience

> Failure handling patterns: retry strategies, circuit breakers, backpressure, timeout management, fallback behavior.

---

## Signal Keywords

### Semantic (S0 — for init inference)

**Primary**: circuit breaker, retry, backpressure, timeout, fallback, bulkhead, rate limiter, fault tolerance, resilience

**Secondary**: exponential backoff, jitter, half-open, fail-fast, degraded mode, throttle, load shedding, deadline propagation, idempotency key

### Code Patterns (R1 — for source analysis)

- Libraries: `cockatiel`, `opossum`, `polly` (.NET), `resilience4j`, `hystrix`, `tenacity` (Python), `backoff` (Python), `retry` (Go)
- Patterns: `CircuitBreaker`, `RetryPolicy`, `Timeout`, `Bulkhead`, `RateLimiter`, `FallbackAction`
- Go: `golang.org/x/time/rate`, `sony/gobreaker`, `cenkalti/backoff`
- Rust: `tower::retry`, `tower::timeout`, `tower::load_shed`, `backoff` crate
- gRPC: `grpc.service_config`, `retryPolicy`, `maxAttempts`, `waitForReady`
- K8s: `retries`, `timeout`, `circuitBreaker` (Istio), `outlierDetection`

---

## Module Metadata

- **Axis**: Concern
- **Common pairings**: http-api, microservice, external-sdk, message-queue
- **Profiles**: Any distributed system or service-to-service communication
