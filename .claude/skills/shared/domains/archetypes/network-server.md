# Archetype: network-server

> Proxies, load balancers, API gateways, and network infrastructure — L4/L7 traffic handling.

---

## Signal Keywords

### Semantic (A0 — for init inference)

**Primary**: listener, filter chain, upstream, downstream, connection pool, proxy, load balancer, L4, L7, xDS, control plane, protocol handler, API gateway, reverse proxy, service mesh

**Secondary**: sidecar, envoy, HAProxy, nginx, ingress, traffic management, circuit breaker, rate limiter, health check, TLS termination, mTLS, connection draining, hot restart

### Code Patterns (A0 — for source analysis)

- **Listener**: socket bind/listen, `SO_REUSEPORT`, acceptor loop, connection handler
- **Filter/middleware chain**: ordered filter pipeline, `FilterChain`, `HttpFilter`, `NetworkFilter`, request/response interception
- **Protocol handling**: HTTP/1.1 parser, HTTP/2 frame handler, gRPC codec, TCP proxy, UDP relay
- **Load balancing**: round-robin, least-connections, consistent hashing, weighted algorithms
- **Config**: xDS API (LDS/RDS/CDS/EDS), YAML-based listener/route/cluster config, hot-reload signals (SIGHUP)
- **Observability**: access logs, connection metrics, upstream health status

---

## A1: Core Principles

| Principle | Description |
|-----------|-------------|
| **Connection Lifecycle Management** | Accept → authenticate → process → drain → close. Every connection state must be tracked and cleanly terminated. |
| **Filter/Middleware Chain** | Request processing is a composable pipeline of filters. Each filter is independent and order-configurable. |
| **Protocol State Machine** | Each supported protocol has an explicit state machine. Invalid state transitions are rejected, not silently ignored. |
| **Hot-Reload Without Connection Drop** | Configuration changes apply to new connections without disrupting existing ones. Graceful drain before shutdown. |
| **Backpressure** | When downstream is slow, propagate pressure upstream rather than buffering unboundedly. Flow control at every layer. |

---

## Module Metadata

- **Axis**: Archetype
- **Typical interfaces**: cli, http-api
- **Common pairings**: wire-protocol, distributed-consensus
