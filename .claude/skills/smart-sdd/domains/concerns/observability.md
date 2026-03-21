# Concern: observability

<!-- Format defined in smart-sdd/domains/_schema.md § Concern Section Schema. -->
<!-- This file provides S0/S1/S5/S7 for smart-sdd pipeline execution. -->
<!-- The corresponding reverse-spec file (reverse-spec/domains/concerns/observability.md) provides R1 detection. -->

> Structured logging, metrics emission, distributed tracing. Cross-cutting operational visibility.

---

## S0. Signal Keywords

> See [`shared/domains/concerns/observability.md`](../../../shared/domains/concerns/observability.md) § Signal Keywords

---

## S1. SC Generation Rules

### Required SC Patterns
When this concern is active, every Feature MUST include SCs for:

| Pattern | SC Requirement |
|---------|---------------|
| **Structured Logging** | Log entries include: timestamp (ISO 8601), level, message, correlation/trace ID, and context-specific fields (user ID, request ID, operation). No unstructured string concatenation in production logs |
| **Request Tracing** | Every inbound request generates or propagates a trace ID (W3C Trace Context or B3). The trace ID appears in all log entries and downstream service calls for that request |
| **Metrics Emission** | Key operational metrics exposed: request count (by endpoint, status code), request latency (histogram), error rate, active connections, queue depth (if applicable). Metrics follow naming conventions (e.g., `http_requests_total`, `http_request_duration_seconds`) |
| **Error Reporting** | Errors include: stack trace (non-production detail), error code/type, operation context, severity. Sensitive data (passwords, tokens, PII) is NEVER logged |

### SC Anti-Patterns (reject if seen)
- "Logging is implemented" — must specify log format (structured JSON vs text), required fields, and log levels per operation type
- "Metrics are collected" — must specify which metrics, their types (counter/gauge/histogram), and label dimensions
- "Errors are tracked" — must specify what constitutes a reportable error vs expected failure, and what context is attached

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|-----------------|
| **Logging** | Structured JSON? Log aggregation target (ELK, CloudWatch, Datadog)? Sampling for high-volume logs? |
| **Tracing** | OpenTelemetry? Jaeger? Datadog APM? Trace sampling rate? Cross-service propagation format? |
| **Metrics** | Prometheus pull? StatsD push? Custom dashboard? What SLIs/SLOs are defined? |
| **Alerting** | What conditions trigger alerts? Notification channels? Runbook links in alerts? |
| **Sensitive Data** | PII scrubbing in logs? Token redaction? GDPR compliance for log retention? |

---

## S7. Bug Prevention

| ID | Pattern | Detection | Prevention |
|----|---------|-----------|------------|
| OB-001 | PII in logs | User passwords, tokens, or personal data appear in log output → compliance violation | Implement log sanitizer middleware; redact fields matching sensitive patterns before emission |
| OB-002 | Missing correlation ID | Logs from same request have no shared identifier → impossible to trace request flow across services | Generate or propagate trace/correlation ID at ingress; inject into logging context (MDC, AsyncLocalStorage, context.Context) |
| OB-003 | Metric cardinality explosion | Unbounded label values (e.g., user ID as metric label) → metrics storage OOM, dashboard timeout | Validate label cardinality; use bounded dimensions only (endpoint, status code, method); never use IDs as labels |
| OB-004 | Silent error swallowing | `catch (e) {}` or `except: pass` → errors invisible in logs and metrics → undetected failures | Every catch block must either re-throw, log with error level, or increment error counter |
| OB-005 | Log volume flood | Debug-level logging in production → storage costs explode, log aggregator overwhelmed | Configure log level per environment; use sampling for high-frequency operations; rate-limit repeated log messages |
