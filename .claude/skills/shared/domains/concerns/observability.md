# Concern: observability

> Structured logging, metrics emission, distributed tracing. Cross-cutting operational visibility.

---

## Signal Keywords

### Semantic (S0 — for init inference)

**Primary**: observability, structured logging, metrics, tracing, OpenTelemetry, Prometheus, distributed tracing, log aggregation

**Secondary**: span, trace ID, correlation ID, log level, histogram, counter, gauge, alert, dashboard, SLI, SLO, APM, Datadog, Grafana, Jaeger

### Code Patterns (R1 — for source analysis)

- OpenTelemetry: `@opentelemetry/sdk-node`, `opentelemetry-api`, `tracing` (Rust), `go.opentelemetry.io/otel`
- Logging: `winston`, `pino`, `structlog`, `slog` (Go), `tracing` (Rust), `log4j`, `logback`, `zerolog`
- Metrics: `prom-client`, `prometheus_client`, `prometheus/client_golang`, `micrometer`, `statsd`
- Tracing: `@opentelemetry/sdk-trace-node`, `jaeger-client`, `dd-trace`, `opentracing`
- Patterns: `logger.info({...})`, `span.set_attribute()`, `counter.add()`, `histogram.record()`
- Middleware: `express-pino-logger`, `morgan`, `actix-web-opentelemetry`, `otelhttp`

---

## Module Metadata

- **Axis**: Concern
- **Common pairings**: http-api, microservice, message-queue, task-worker
- **Profiles**: Any server or distributed system
