# Software Catalog — Target Project Types for spec-kit-skills

> Systematic catalog of software types with code-explore simulation results.
> Purpose: identify gaps in code-explore's user-facing capabilities across diverse project types.

---

## How to Read This Catalog

Each entry simulates a user running `code-explore` on a representative codebase. The simulation evaluates:

- **Orient**: Can the tool correctly detect project type, entry points, modules, and Domain Profile?
- **Trace**: Can a user effectively trace flows they care about? What questions go unanswered?
- **Synthesis**: Does the aggregation produce actionable Feature candidates?
- **User Pain Point**: What frustrates the user — from a practical, "I'm trying to understand this code" perspective?

---

## A. Server / Network (10 types)

### A01. TCP Server (Rust/Go)
**Example**: Custom database wire protocol server (like Redis protocol)

| Axis | Value |
|------|-------|
| Interface | `grpc` or custom protocol (neither `http-api` nor `cli`) |
| Concern | `resilience`, `connection-pool`, `graceful-lifecycle` |
| Archetype | `network-server` or `cache-server` |
| Foundation | `rust-cargo` or `go` |

**Orient Simulation**:
- Entry point detection: `main.go` found, but the *real* entry point is `listener.Accept()` loop — orient calls it "main" without recognizing the accept loop pattern
- Module map: `protocol/`, `handler/`, `storage/` correctly identified, but `connection pool` logic scattered across files isn't grouped
- Interface: Misclassified as `cli` (has a CLI for management) — the primary interface is a custom TCP protocol with no HTTP

**Trace Simulation** — User asks: *"How does a client command get parsed and executed?"*
- Entry point: Agent finds the command parser but not the network read loop that feeds it
- The flow is: `accept()` → `read bytes` → `parse protocol` → `dispatch command` → `execute` → `write response` → loop
- Agent traces from `parseCommand()` onward but misses the byte-level protocol framing
- **User pain**: "I wanted to see the full lifecycle from TCP connection to response, not just the business logic part"

**Trace Simulation** — User asks: *"How does connection pooling work?"*
- No clear entry point — pooling is cross-cutting (init, borrow, return, evict, health-check)
- Agent finds `pool.Get()` but misses the background eviction goroutine
- **User pain**: "The trace shows me one path but this is actually a state machine with multiple concurrent paths"

**Gap Summary**:
| Gap | Category |
|-----|----------|
| No "connection lifecycle" trace pattern | Trace |
| Accept loop not recognized as entry point | Orient |
| Background goroutines/tasks not surfaced | Trace |
| Custom protocol not an Interface option | Orient |
| Concurrent state machine flows untraceable linearly | Trace |

---

### A02. HTTP Reverse Proxy (nginx-like, Go)
**Example**: Layer 7 proxy with routing rules, TLS termination, health checks

| Axis | Value |
|------|-------|
| Interface | `http-api` (but it's a proxy, not an API) |
| Concern | `resilience`, `tls-management`, `observability` |
| Archetype | `network-server` |
| Foundation | `go` |

**Orient Simulation**:
- Correctly detects Go + HTTP patterns
- But misclassifies as "API server" — it's a proxy (forwards requests, doesn't handle them)
- Module map: `proxy/`, `upstream/`, `config/`, `health/` — reasonable but "proxy" vs "API" distinction lost

**Trace Simulation** — User asks: *"How does request routing work?"*
- Agent finds the router, but the "response" is from upstream, not from this server
- The flow crosses a network boundary (this server → upstream server) that the trace can't follow
- **User pain**: "The trace stops at `proxy.Forward()` but that's where the interesting part begins — how does it select the upstream, handle timeouts, retry?"

**Trace Simulation** — User asks: *"How does TLS termination work?"*
- TLS is handled at the listener level, before any application code
- Agent can't trace into `tls.Config` setup meaningfully — it's configuration, not flow
- **User pain**: "I want to understand the cert loading, SNI matching, and cipher selection, but the trace just says 'TLS configured here'"

**Gap Summary**:
| Gap | Category |
|-----|----------|
| Proxy vs API server distinction | Orient |
| Cross-network-boundary tracing | Trace |
| Configuration-as-flow (TLS, routing rules) not traceable | Trace |
| No "request forwarding lifecycle" pattern | Trace |

---

### A03. gRPC Microservice (Go + protobuf)
**Example**: Order service in a microservices architecture

| Axis | Value |
|------|-------|
| Interface | `grpc` |
| Concern | `auth`, `observability`, `resilience` |
| Archetype | `microservice` |
| Foundation | `go` |

**Orient Simulation**:
- `.proto` files detected but treated as "config" not as primary interface definition
- Entry points: `main.go` → `grpc.NewServer()` found, but individual RPC handlers not listed as entry points
- Interceptor chain (auth, logging, tracing) not recognized as middleware equivalent
- **Missing**: Service dependency graph (this service calls UserService, PaymentService)

**Trace Simulation** — User asks: *"How does CreateOrder RPC work?"*
- Agent finds `CreateOrder()` handler — good
- But the handler calls `userClient.GetUser()` (another gRPC service) — trace stops at the client call
- **User pain**: "I can see *this* service's logic but not how it interacts with the 3 other services it depends on. Where's the big picture?"

**Gap Summary**:
| Gap | Category |
|-----|----------|
| Proto files not treated as interface definitions | Orient |
| gRPC interceptor chain not mapped as middleware | Orient |
| Cross-service calls can't be traced | Trace |
| Service dependency graph not generated | Synthesis |

---

### A04. WebSocket Server (Node.js/Rust)
**Example**: Real-time chat server with rooms, presence, message history

| Axis | Value |
|------|-------|
| Interface | `http-api` + custom WebSocket protocol |
| Concern | `realtime`, `auth`, `async-state` |
| Archetype | `network-server` |
| Foundation | `express` or `rust-cargo` |

**Orient Simulation**:
- HTTP server detected, WebSocket upgrade path found
- But the dual nature (HTTP for REST + WS for real-time) creates confusion in module mapping
- `realtime` concern detected from WS imports — good

**Trace Simulation** — User asks: *"How does a chat message flow from sender to all room members?"*
- Entry: `ws.on('message')` handler found
- Flow: parse → validate → store → broadcast
- But "broadcast" is the tricky part — it's a fan-out to N connections
- Agent traces the happy path (1 sender → 1 receiver) but doesn't capture the fan-out pattern or what happens when a receiver is slow/disconnected
- **User pain**: "The trace shows one message going to one person. I need to understand the broadcast mechanics, back-pressure, and disconnection handling"

**Trace Simulation** — User asks: *"How does presence (online/offline) work?"*
- No single entry point — presence is an *event-driven state machine* (connect → online, disconnect → offline, timeout → away)
- Agent picks `onConnect` as entry but misses the heartbeat timer, the reconnection window, and the state transitions
- **User pain**: "This isn't a flow, it's a state machine. I need a state diagram, not a sequence diagram"

**Gap Summary**:
| Gap | Category |
|-----|----------|
| Fan-out/broadcast patterns not captured | Trace |
| State machine topics need state diagrams, not sequence diagrams | Trace |
| Dual-protocol servers (HTTP + WS) confuse module mapping | Orient |
| Back-pressure and slow-consumer handling invisible | Trace |

---

### A05. Message Broker (Rust/Erlang)
**Example**: Lightweight message queue like NATS or a mini-Kafka

| Axis | Value |
|------|-------|
| Interface | Custom TCP protocol |
| Concern | `message-queue`, `resilience`, `graceful-lifecycle` |
| Archetype | `message-broker` |
| Foundation | `rust-cargo` or `erlang-otp` |

**Orient Simulation**:
- No HTTP, no CLI (management is via the protocol itself) — orient struggles with Interface
- Entry point: accept loop, but also a separate topic/partition manager running concurrently
- Module map: `protocol/`, `topic/`, `consumer/`, `storage/`, `cluster/` — but relationships are event-driven, not import-based

**Trace Simulation** — User asks: *"How does a message get published and delivered to consumers?"*
- The flow spans: publisher connection → parse PUBLISH → topic lookup → append to log → notify consumers → consumer poll/push → ACK
- This is a multi-actor flow — publisher and consumer are separate connections acting concurrently
- Agent can trace the publish side OR the consume side, but not the full end-to-end in one trace
- **User pain**: "I need to see the full pub-sub cycle but the trace only shows half"

**Gap Summary**:
| Gap | Category |
|-----|----------|
| Multi-actor concurrent flows can't be captured in single trace | Trace |
| No "pub-sub lifecycle" trace pattern | Trace |
| Event-driven module relationships not captured by import analysis | Orient |
| Durability/persistence path not distinct from hot path | Trace |

---

### A06. DNS Server (C/Rust)
**Example**: Recursive DNS resolver with caching

| Axis | Value |
|------|-------|
| Interface | UDP + TCP (custom protocol, DNS wire format) |
| Concern | `caching`, `resilience` |
| Archetype | `network-server` |
| Foundation | `rust-cargo` or `cmake` |

**Orient Simulation**:
- Completely non-HTTP — orient's Interface detection fails
- UDP-based: no "connections" in the TCP sense — request/response is stateless
- Binary protocol (DNS wire format) — no JSON, no REST
- **User pain**: "orient says 'library' because there's no HTTP server or CLI. It's a network server!"

**Trace Simulation** — User asks: *"How does a DNS query get resolved?"*
- Flow: receive UDP packet → parse DNS message → check cache → if miss: recursive lookup → cache result → send response
- Recursive lookup involves multiple external network calls (root → TLD → authoritative)
- Agent can trace the parsing and caching but the recursive resolution crosses network boundaries
- **User pain**: "The interesting part — recursive resolution with multiple external queries — is exactly where the trace stops"

**Gap Summary**:
| Gap | Category |
|-----|----------|
| UDP-based servers not recognized | Orient |
| Binary protocol parsing needs byte-level trace support | Trace |
| Recursive/iterative external queries can't be traced | Trace |
| Stateless request-response (no connection) breaks connection lifecycle model | Trace |

---

### A07. API Gateway (Go/Java)
**Example**: Kong/Zuul-like gateway with plugin system

| Axis | Value |
|------|-------|
| Interface | `http-api` |
| Concern | `auth`, `resilience`, `plugin-system`, `observability` |
| Archetype | `network-server`, `public-api` |
| Foundation | `go` or `spring-boot` |

**Orient Simulation**:
- HTTP detected correctly
- But: request handling is entirely plugin-driven — the gateway itself has minimal business logic
- Plugin loading is dynamic (directory scan at startup) — import analysis misses plugins
- **User pain**: "The module map shows the gateway core but none of the plugins. The plugins ARE the functionality"

**Trace Simulation** — User asks: *"How does rate limiting work?"*
- Rate limiting is a plugin, loaded dynamically
- Agent finds the plugin interface but not the specific implementation (it's in a separate directory/package)
- The plugin chain (auth → rate-limit → transform → proxy) is configured at runtime, not visible in imports
- **User pain**: "I can see the plugin interface but not how plugins are discovered, loaded, ordered, and executed"

**Gap Summary**:
| Gap | Category |
|-----|----------|
| Dynamic plugin loading invisible to static analysis | Orient |
| Plugin execution chain (middleware ordering) is runtime config | Trace |
| Gateway vs backend API distinction not captured | Orient |
| Cross-cutting plugin concerns (each plugin = mini Feature) | Synthesis |

---

### A08. Event-Driven Consumer (Kafka + Spring)
**Example**: Order processor consuming from Kafka, writing to database

| Axis | Value |
|------|-------|
| Interface | None traditional — `message-queue` consumer |
| Concern | `message-queue`, `resilience`, `async-state` |
| Archetype | `microservice` |
| Foundation | `spring-boot` |

**Orient Simulation**:
- `@KafkaListener` annotations found, but orient doesn't recognize these as entry points
- No HTTP server, no CLI — orient classifies as "library"
- Spring Boot auto-configuration makes the actual wiring invisible
- **User pain**: "orient says this is a library. It's a running service that processes millions of messages per day!"

**Trace Simulation** — User asks: *"How is an order event processed?"*
- Entry point: `@KafkaListener` on `processOrder(OrderEvent event)` — but agent doesn't recognize annotation-driven entry points
- The flow: deserialize → validate → enrich (call external service) → persist → publish result
- Error handling: DLQ (dead letter queue), retry with backoff, idempotency check
- Agent misses the error/retry paths — only traces the happy path
- **User pain**: "The happy path is obvious. I need to understand the error handling, retry logic, and DLQ flow — that's where the complexity lives"

**Gap Summary**:
| Gap | Category |
|-----|----------|
| Annotation-driven entry points (`@KafkaListener`, `@EventHandler`) not detected | Orient |
| No Interface option for "message consumer" | Orient |
| Error/retry/DLQ paths not systematically traced | Trace |
| Spring Boot auto-configuration invisible | Orient |
| Idempotency and exactly-once semantics not captured | Trace |

---

### A09. VPN/Tunnel Server (WireGuard-like, Rust)
**Example**: Encrypted tunnel with peer management

| Axis | Value |
|------|-------|
| Interface | Kernel/network interface (tun/tap device) |
| Concern | `cryptography`, `hardware-io`, `graceful-lifecycle` |
| Archetype | `network-server` |
| Foundation | `rust-cargo` |

**Orient Simulation**:
- No HTTP, no CLI (management via config file or separate tool)
- Entry point involves kernel interaction (tun device creation) — not a typical function call
- Crypto libraries detected but classified as "external dependency" not a core concern
- **User pain**: "orient found the Rust project but couldn't classify it at all. It said 'library' again"

**Trace Simulation** — User asks: *"How does a packet get encrypted and tunneled?"*
- Flow: read from tun device → lookup peer → encrypt (Noise protocol) → encapsulate in UDP → send
- Involves: system calls (read/write tun), crypto operations, UDP socket operations
- All of these are "boundaries" where the trace would normally stop
- **User pain**: "Every interesting step is at a 'boundary'. The trace is just a list of system call wrappers"

**Gap Summary**:
| Gap | Category |
|-----|----------|
| Kernel/system-level entry points not recognized | Orient |
| System call boundaries are too aggressive — they're core logic here | Trace |
| Crypto protocol handshake is a stateful exchange, not a single flow | Trace |
| No way to trace packet transformation pipeline (read → transform → write) | Trace |

---

### A10. Service Mesh Sidecar (Envoy-like, C++)
**Example**: L4/L7 proxy with traffic management, observability

| Axis | Value |
|------|-------|
| Interface | Multiple: L4 TCP proxy + L7 HTTP proxy + admin API |
| Concern | `resilience`, `observability`, `tls-management` |
| Archetype | `network-server` |
| Foundation | `cmake` (C++) |

**Orient Simulation**:
- C++ with CMake detected, but code-explore has minimal C++ heuristics
- Multiple listener types (TCP, HTTP, admin) each act as separate "interfaces"
- Filter chain architecture (similar to middleware) is the core abstraction
- **User pain**: "orient barely works — it found C++ but couldn't map the module structure because there are no package.json or go.mod equivalents"

**Trace Simulation** — User asks: *"How does an HTTP request flow through the filter chain?"*
- Filter chain is configured at runtime (YAML/xDS API)
- Static analysis sees filter interfaces but not which filters are active
- Each filter can modify, forward, or terminate the request — complex branching
- **User pain**: "I can see the filter interface definition but not how filters are composed. The composition is all in YAML"

**Gap Summary**:
| Gap | Category |
|-----|----------|
| C++ project structure poorly supported | Orient |
| Runtime-configured filter/middleware chains invisible | Trace |
| Multiple simultaneous listeners (L4 + L7 + admin) | Orient |
| Configuration-driven behavior (YAML/xDS) needs a different trace approach | Trace |

---

## B. Web / Full-stack (3 types)

### B01. REST API Server (FastAPI/Express)
**Well-covered baseline** — minimal gaps expected.

**Orient**: Correctly detects HTTP server, framework, routes. Module map reasonable.
**Trace**: Route → handler → service → repository pattern traces well.
**Remaining gap**: Middleware ordering, error handling middleware, request validation pipeline often glossed over.

### B02. SSR Full-stack (Next.js)
**Orient**: Detects Next.js, but `app/` vs `pages/` router confusion.
**Trace gap**: Server component vs client component boundary — "where does this code run?" is the key user question.
**User pain**: "I can't tell from the trace which code runs on the server and which on the client"

### B03. GraphQL Server (Apollo)
**Orient**: Detects Apollo, but schema.graphql treated as config not interface definition.
**Trace gap**: Resolver chain (query → field resolver → data loader → database) is multi-level, agent may flatten it.
**User pain**: "N+1 query patterns — how does the DataLoader batch? The trace doesn't show the batching boundary"

---

## C. Desktop / Mobile (3 types)

### C01. Electron App
**Well-covered** — existing IPC concern and Playwright support handle this.
**Remaining gap**: Main process vs renderer process boundary in traces.

### C02. Tauri App
**Orient gap**: Rust backend + Web frontend — two languages, two module maps needed.
**Trace gap**: Tauri command bridge (Rust ↔ JS) is the critical boundary. Agent needs to trace across it.

### C03. Native Mobile (Flutter)
**Orient**: Detects Flutter/Dart.
**Trace gap**: Widget tree is declarative — "how does state flow to UI?" requires a different mental model than imperative traces.
**User pain**: "I want to see how a state change propagates through the widget tree, not a linear function call chain"

---

## D. Data / ML (3 types)

### D01. Data Pipeline (dbt + Airflow)
**Orient**: No code entry point — DAG defined in Python, transformations in SQL.
**Trace**: SQL transformations are the "business logic" but agent treats SQL as a boundary.
**User pain**: "The whole point is the SQL transformations and their ordering. The Python is just orchestration"

### D02. ML Training Pipeline (PyTorch)
**Orient**: Python detected, but model definition vs training loop vs data loading are distinct concerns not captured.
**Trace**: Training loop is iterative (epoch → batch → forward → loss → backward → optimize) — not a single flow.
**User pain**: "How does data flow from raw dataset to trained model? The trace doesn't capture the iterative nature"

### D03. LLM Application (LangChain)
**Orient**: ai-assistant archetype detected.
**Trace**: Chain/agent execution is dynamic — tool calls, memory lookups, prompt assembly happen at runtime.
**User pain**: "The prompt template composition and tool routing are where the magic happens, but they're runtime-dynamic"

---

## E. Infrastructure (2 types)

### E01. Kubernetes Operator (Go)
**Orient**: Go detected, but reconciler pattern (watch → reconcile → update status) is the key abstraction not recognized.
**Trace**: Reconciler is event-driven — no single entry point, no single flow.
**User pain**: "How does the operator react to a CRD change? It's a reactive loop, not a request-response"

### E02. Terraform Monorepo
**Orient**: No traditional code — HCL files, no functions, no imports.
**Trace**: "Flow" doesn't apply — it's declarative infrastructure.
**User pain**: "orient says 'unknown project type'. Terraform is one of the most common tools in DevOps"

---

## F. Embedded / IoT (2 types)

### F01. Embedded Firmware (C + RTOS)
**Orient**: C with Makefile/CMake detected, but ISR (interrupt service routine) pattern not recognized.
**Trace**: ISR → deferred handler → task queue is the common pattern, but agent traces synchronous paths only.
**User pain**: "The firmware is interrupt-driven. Every trace should start from an interrupt, not from main()"

### F02. IoT Gateway (Rust + MQTT)
**Orient**: Rust detected, MQTT library found.
**Trace**: Device → gateway → cloud is a 3-party flow that spans network boundaries.
**User pain**: "How does a sensor reading get from the device to the cloud? The trace covers only the gateway's internal processing"

---

## G. SDK / Library (1 type)

### G01. Network SDK (TypeScript/Go)
**Orient**: Library interface detected — good.
**Trace**: Public API → internal implementation traces well.
**Remaining gap**: Retry/timeout/circuit-breaker patterns are cross-cutting — hard to trace as a single flow.
**User pain**: "How does the retry logic interact with the timeout logic and the circuit breaker? These are 3 separate concerns that compose"

---

## Cross-Cutting Gap Analysis

### Gap Pattern 1: Non-Linear Flows
**Affected**: A01, A04, A05, A08, A09, E01, F01
**Problem**: code-explore's trace assumes linear flow (entry → steps → exit). Many server/network systems are:
- Event-driven loops (accept → handle → loop)
- State machines (connected → authenticated → subscribed → disconnected)
- Concurrent actors (publisher + consumer + monitor running simultaneously)
- Reactive (reconciler watches for changes, reacts)

**Enhancement needed**: Support for **state diagram traces** and **concurrent flow traces** alongside sequential traces.

### Gap Pattern 2: Protocol/Network Boundaries
**Affected**: A01, A02, A03, A06, A09, A10, F02
**Problem**: Trace stops at "external API call" boundaries, but for network programs, the network IS the core concern. Stopping at `socket.write()` is like stopping at `repository.save()` in a web app — the user wants to see what happens next.

**Enhancement needed**: **Protocol-aware tracing** that understands the request goes out and a response comes back, documenting the expected protocol exchange.

### Gap Pattern 3: Configuration-as-Logic
**Affected**: A02, A07, A10, E02
**Problem**: In proxies, gateways, and IaC, the "business logic" lives in configuration (YAML, HCL, routing rules), not in code. Static code analysis sees the config-loading code but not the config content.

**Enhancement needed**: **Config-aware orient** that reads and maps configuration files as part of module mapping.

### Gap Pattern 4: Missing Server-Specific Interface Types
**Affected**: A01, A05, A06, A08, A09
**Problem**: orient's Interface detection only recognizes `gui`, `http-api`, `cli`, `library`. TCP servers, UDP servers, message consumers, and kernel-interface programs are misclassified.

**Enhancement needed**: Expand orient's Interface detection to include `tcp-server`, `udp-server`, `message-consumer`, `grpc-server`, `websocket-server`.

### Gap Pattern 5: Concurrency Model Blindness
**Affected**: A01, A04, A05, A10, F01
**Problem**: Server programs are fundamentally concurrent. The trace format captures one execution path, but the user needs to understand:
- How many concurrent connections/tasks?
- What's shared state vs per-connection state?
- Where are the synchronization points?
- What happens under contention?

**Enhancement needed**: **Concurrency annotation** in traces — mark shared state, synchronization primitives, per-connection vs global scope.

### Gap Pattern 6: User Questions That Don't Map to "Flows"
**Affected**: All server types
**Problem**: Users often ask questions that aren't traceable as flows:
- "What's the threading model?" → architectural question, not a flow
- "How does the server handle backpressure?" → emergent behavior from multiple flows
- "What happens when a client disconnects mid-request?" → error/edge case, not happy path
- "What's the maximum number of concurrent connections?" → configuration + resource analysis

**Enhancement needed**: Support for **architectural questions** and **scenario-based traces** (what-if scenarios, error paths, resource limits).
