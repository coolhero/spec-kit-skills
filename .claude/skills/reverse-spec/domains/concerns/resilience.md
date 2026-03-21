# Concern: resilience (reverse-spec)

> Failure handling pattern detection. Identifies retry, circuit breaker, backpressure, and timeout implementations.

## R1. Detection Signals

> See [`shared/domains/concerns/resilience.md`](../../../shared/domains/concerns/resilience.md) § Code Patterns

## R3. Analysis Depth Modifiers

When detected, include in analysis:
- Retry implementation and configuration (max retries, backoff algorithm)
- Circuit breaker library and configuration (thresholds, states)
- Timeout values and propagation patterns
- Backpressure mechanisms (queue size limits, load shedding)
- Fallback behavior for each failure mode
- Idempotency key implementation for retryable mutations
