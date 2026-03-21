# Concern: observability (reverse-spec)

> Observability stack detection. Identifies logging, metrics, and tracing patterns.

## R1. Detection Signals

> See [`shared/domains/concerns/observability.md`](../../../shared/domains/concerns/observability.md) § Code Patterns

## R3. Analysis Depth Modifiers

When detected, include in analysis:
- Logging framework and format (structured JSON vs text)
- Metrics library and exposition format (Prometheus, StatsD)
- Tracing implementation and propagation format (W3C, B3)
- Log levels and their usage patterns across the codebase
- Correlation/trace ID propagation through the request lifecycle
- Sensitive data handling in logs (redaction, scrubbing)
