# Concern: graceful-lifecycle

> Server process lifecycle management: startup readiness, health checks, graceful shutdown, connection draining.

---

## Signal Keywords

### Semantic (S0 — for init inference)

**Primary**: graceful shutdown, health check, liveness probe, readiness probe, connection draining, SIGTERM, startup probe, pre-stop hook

**Secondary**: drain, warm-up, rolling restart, zero-downtime, hot reload, keepalive, idle timeout, shutdown hook, process lifecycle

### Code Patterns (R1 — for source analysis)

- Signal handlers: `process.on('SIGTERM')`, `signal.signal(signal.SIGTERM)`, `signal::ctrl_c()`, `os.signal.Notify`
- Health endpoints: `/health`, `/healthz`, `/ready`, `/livez`, `/startupz`, `GET /status`
- Frameworks: `@nestjs/terminus`, `grpc-health-probe`, `kubernetes.io/liveness-probe`, Flask `before_first_request`
- Shutdown: `server.close()`, `app.shutdown()`, `gracefulShutdown`, `drainConnections`, `GracefulStop()`
- Go: `http.Server.Shutdown(ctx)`, `os.Interrupt`, `syscall.SIGTERM`
- Java/Spring: `@PreDestroy`, `SmartLifecycle`, `GracefulShutdown`, `HealthIndicator`
- Rust: `tokio::signal`, `hyper::Server::with_graceful_shutdown`

---

## Module Metadata

- **Axis**: Concern
- **Common pairings**: http-api, network-server, microservice, message-broker
- **Profiles**: Any server application
