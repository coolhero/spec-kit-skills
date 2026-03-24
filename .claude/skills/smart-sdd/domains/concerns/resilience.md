# Concern: resilience

<!-- Format defined in smart-sdd/domains/_schema.md § Concern Section Schema. -->
<!-- This file provides S0/S1/S5/S7 for smart-sdd pipeline execution. -->
<!-- The corresponding reverse-spec file (reverse-spec/domains/concerns/resilience.md) provides R1 detection. -->

> Failure handling patterns: retry strategies, circuit breakers, backpressure, timeout management, fallback behavior.

---

## S0. Signal Keywords

> See [`shared/domains/concerns/resilience.md`](../../../shared/domains/concerns/resilience.md) § Signal Keywords

---

## S1. SC Generation Rules

### Required SC Patterns
When this concern is active, every Feature involving external calls or failure-prone operations MUST include SCs for:

| Pattern | SC Requirement |
|---------|---------------|
| **Retry Strategy** | Specify: max retries, backoff algorithm (exponential with jitter recommended), retryable vs non-retryable errors, idempotency requirement for retried operations |
| **Timeout** | Every external call has an explicit timeout. Specify: connect timeout, read timeout, overall deadline. Deadline propagates to downstream calls (remaining time, not full timeout) |
| **Circuit Breaker** | Specify: failure threshold to open, half-open probe interval, success threshold to close. When open: fail-fast with clear error (not hang). Specify fallback behavior (cached result, degraded response, error) |
| **Backpressure** | When downstream is slow: specify response (reject with 429/503, queue with bounded size, shed load by priority). Never unbounded queue |
| **Fallback** | When primary path fails: specify fallback behavior (cached data, degraded feature, alternative provider, graceful error message). Fallback must not mask persistent failures |

### SC Anti-Patterns (reject if seen)
- "Retries on failure" — must specify max retries, backoff, and which errors are retryable
- "Handles timeout" — must specify timeout values and what happens when timeout fires (retry? fallback? error?)
- "Circuit breaker protects the system" — must specify thresholds, states, and fallback behavior for each state

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|-----------------|
| **Retry** | Exponential backoff? With jitter? Max retries? Which errors are retryable (network vs application)? |
| **Timeout** | Per-call timeout or deadline-based? Timeout for connect vs read vs total? Propagated to downstream? |
| **Circuit Breaker** | Per-endpoint or per-service? Failure rate threshold? Half-open probe count? |
| **Backpressure** | Queue-based or rejection-based? Max queue size? Priority-based shedding? |
| **Observability** | Circuit breaker state changes logged/alerted? Retry counts in metrics? Timeout counts tracked? |

---

## S7. Bug Prevention

| ID | Pattern | Detection | Prevention |
|----|---------|-----------|------------|
| RS-001 | Retry storm amplification | Service A retries → Service B retries → exponential request multiplication → cascade failure | Implement retry budget (max % of requests that are retries); propagate deadline so downstream does not retry past parent timeout |
| RS-002 | Missing idempotency on retry | POST request retried → duplicate records created → data inconsistency | All retryable mutations require idempotency key; server deduplicates by key within retry window |
| RS-003 | Timeout without cleanup | Request times out but server-side operation continues → resource leak, orphaned work | Implement cancellation propagation (AbortController, context.Context, CancellationToken); server checks cancellation and cleans up |
| RS-004 | Circuit breaker too sensitive | Single transient error opens circuit → healthy service gets cut off → unnecessary downtime | Use sliding window (not single-failure); require N failures in M seconds; half-open probes resume traffic gradually |
| RS-005 | Unbounded retry backoff | Backoff grows to minutes/hours → requests stuck in retry queue → memory exhaustion | Cap max backoff interval (e.g., 30s); add jitter; give up after max retries with clear error |

---

## S9. Brief Completion Criteria

| Required Element | Completion Signal |
|-----------------|-------------------|
| **Retry strategy** | Max retries, backoff algorithm, and retryable error categories stated |
| **Timeout values** | Connect/read/overall timeout values specified for each external dependency |
| **Circuit breaker scope** | Per-endpoint or per-service decision made; failure thresholds stated |
| **Fallback behavior** | At least one fallback path defined for primary failure scenarios |
