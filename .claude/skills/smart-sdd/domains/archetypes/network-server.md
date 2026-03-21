# Archetype: network-server

> Proxies, load balancers, API gateways, and network infrastructure — L4/L7 traffic handling.
> Module type: archetype

---

## A0. Signal Keywords

> See [`shared/domains/archetypes/network-server.md`](../../../shared/domains/archetypes/network-server.md) § Signal Keywords

---

## A1. Philosophy Principles

| Principle | Description | Implication |
|-----------|-------------|-------------|
| **Connection Lifecycle Management** | Accept → authenticate → process → drain → close. Every connection state must be tracked and cleanly terminated. | SCs must specify full connection lifecycle. Verify tests graceful shutdown (in-flight requests drained, not dropped). |
| **Filter/Middleware Chain** | Request processing is a composable pipeline of filters. Each filter is independent and order-configurable. | Features adding processing logic must be implemented as filters. SCs specify filter position in the chain and ordering constraints. |
| **Protocol State Machine** | Each supported protocol has an explicit state machine. Invalid state transitions are rejected, not silently ignored. | SCs for protocol features must reference the state machine. Verify includes invalid state transition testing. |
| **Hot-Reload Without Connection Drop** | Configuration changes apply to new connections without disrupting existing ones. Graceful drain before shutdown. | Features touching config must support hot-reload. Verify confirms zero-downtime config changes. |
| **Backpressure** | When downstream is slow, propagate pressure upstream rather than buffering unboundedly. Flow control at every layer. | SCs must specify backpressure behavior. Verify includes slow-upstream/downstream testing. |

---

## A2. SC Generation Extensions

### Required SC Patterns (append to S1)
- **Connection lifecycle**: SC specifies behavior at each connection state (accept, active, draining, closed) and transition triggers
- **Filter chain position**: SC specifies where in the filter chain the feature executes and what data it reads/modifies
- **Protocol handling**: SC specifies which protocol(s) are affected and references the protocol state machine
- **Resource limits**: SC specifies connection limits, buffer sizes, and timeout values for the feature

### SC Anti-Patterns (reject)
- "Request is processed" — must specify which filter(s), in what order, and what transformation is applied
- "Server handles connections" — must specify accept behavior, connection limits, drain policy, and close cleanup
- "Config is reloaded" — must specify which config changes are hot-reloadable vs require restart

---

## A3. Elaboration Probes (append to S5)

| Sub-domain | Probe Questions |
|------------|----------------|
| **Protocol support** | HTTP/1.1? HTTP/2? HTTP/3? gRPC? Raw TCP? UDP? WebSocket upgrade? |
| **Load balancing** | Round-robin? Least connections? Consistent hashing? Weighted? Health-check-aware? |
| **Filter chain** | What filters exist (auth, rate-limit, logging, transform)? Order configurable? |
| **TLS** | TLS termination? mTLS? Certificate rotation? SNI-based routing? |
| **Config** | Static file? xDS API? Control plane? Hot-reload mechanism? |
| **Observability** | Access logs? Connection metrics? Per-upstream health? Distributed tracing propagation? |

---

## A4. Constitution Injection

| Principle | Rationale |
|-----------|-----------|
| Every connection must have explicit timeout, buffer limit, and drain policy — no unbounded connections | Leaked connections exhaust file descriptors and memory; explicit limits prevent resource exhaustion |
| Request processing must be a composable filter chain — no monolithic request handlers | Monolithic handlers are untestable and unconfigurable; filter chains enable per-deployment customization |
| Configuration changes must apply without dropping existing connections — graceful drain is mandatory | Connection drops during config reload cause user-visible errors; hot-reload is a reliability requirement |
| Every protocol has an explicit state machine — invalid transitions produce protocol errors, not undefined behavior | Silent state violations cause data corruption and security vulnerabilities; explicit rejection is safe |
| Backpressure must propagate from downstream to upstream — never buffer unboundedly at any layer | Unbounded buffering causes OOM under load; backpressure preserves system stability at the cost of latency |

---

## A5. Brief Completion Criteria

| Required Element | Completion Signal |
|-----------------|-------------------|
| Protocol(s) | Which L4/L7 protocols are handled |
| Routing model | How traffic is routed to upstreams (load balancing algorithm, health checks) |
| Filter/middleware | What processing pipeline exists for requests |
| Config model | How configuration is loaded and whether hot-reload is supported |
