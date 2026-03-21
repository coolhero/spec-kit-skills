# Archetype: Network Server (reverse-spec)

> Network server/proxy detection

## R1. Detection Signals

> See [`shared/domains/archetypes/network-server.md`](../../../shared/domains/archetypes/network-server.md) § Code Patterns

## R2. Classification Guide

When detected, classify the sub-type:
- **L7 Proxy** — Application-layer reverse proxy, TLS termination, HTTP routing (Nginx, Envoy)
- **L4 Load Balancer** — Transport-layer load balancing, connection-level routing (HAProxy)
- **API Gateway** — API management, authentication/rate-limiting, plugin architecture (Kong)
- **Custom protocol server** — Bespoke protocol implementation, custom framing, domain-specific wire format

## R3. Analysis Depth Modifiers

When detected, include in analysis:
- Connection handling (accept loop, connection pooling, keep-alive, backpressure, graceful shutdown)
- Filter/middleware chain (request/response pipeline, filter ordering, dynamic filter loading)
- Routing rules (path matching, header-based routing, weighted routing, traffic splitting)
- Upstream health checking (active/passive health checks, circuit breaking, ejection/recovery)
- Protocol support (HTTP/1.1, HTTP/2, HTTP/3/QUIC, gRPC, TCP, UDP, WebSocket)
- Config format (static config, dynamic xDS, hot-reload, admin API)
