# Domain Module Taxonomy

> Single source of truth for all available domain modules.
> Referenced by `smart-sdd/domains/_resolver.md` and `reverse-spec/commands/analyze.md`.

---

## Interfaces

| Module | File | Description | Common Pairings |
|--------|------|-------------|-----------------|
| gui | `interfaces/gui.md` | GUI windows, web pages, visual UI | async-state, ipc (Electron/Tauri) |
| http-api | `interfaces/http-api.md` | REST/GraphQL endpoints, HTTP servers | auth, authorization |
| cli | `interfaces/cli.md` | Command-line tools, shell commands | — |
| data-io | `interfaces/data-io.md` | Data pipelines, ETL, batch/stream processing | dag-orchestration |
| tui | `interfaces/tui.md` | Terminal UI (Ink, bubbletea, Ratatui) | — |
| mobile | `interfaces/mobile.md` | Mobile apps (iOS, Android, cross-platform) | auth, async-state, realtime |
| library | `interfaces/library.md` | Libraries/SDKs consumed via import/linking | plugin-system |
| embedded | `interfaces/embedded.md` | Embedded systems, firmware, IoT, RTOS | hardware-io, wire-protocol |
| grpc | `interfaces/grpc.md` | gRPC/RPC services (Protobuf, Connect, Twirp) | auth, resilience, observability |

## Concerns

| Module | File | Description | Common Pairings |
|--------|------|-------------|-----------------|
| async-state | `concerns/async-state.md` | Reactive state management patterns | gui |
| auth | `concerns/auth.md` | Authentication flows (JWT, OAuth, session) | http-api |
| authorization | `concerns/authorization.md` | Permission models (RBAC, ABAC, ACL) | auth |
| codegen | `concerns/codegen.md` | Generated/templated code from IDL, schema, or template | polyglot |
| cqrs-eventsourcing | `concerns/cqrs-eventsourcing.md` | CQRS + Event Sourcing (Axon, EventStoreDB, aggregates) | message-queue, database-engine (archetype) |
| dag-orchestration | `concerns/dag-orchestration.md` | DAG workflows (Airflow, Prefect, Dagster, dbt) | data-io |
| distributed-consensus | `concerns/distributed-consensus.md` | Raft, Paxos, gossip, leader election | database-engine (archetype), message-broker (archetype) |
| ecs | `concerns/ecs.md` | Entity-Component-System, data-oriented design | game-engine (archetype) |
| external-sdk | `concerns/external-sdk.md` | Third-party API/SDK integrations | ai-assistant (archetype) |
| hardware-io | `concerns/hardware-io.md` | Hardware I/O (ioctl, mmap, serial, USB, GPIO, KVM) | — |
| i18n | `concerns/i18n.md` | Internationalization and localization | gui |
| infra-as-code | `concerns/infra-as-code.md` | Infrastructure definitions as first-class components (Terraform, Helm, K8s) | infra-tool (archetype) |
| ipc | `concerns/ipc.md` | Inter-process communication (Electron, Workers) | gui (desktop-app) |
| k8s-operator | `concerns/k8s-operator.md` | Kubernetes reconciliation loop, CRD, controller-runtime | infra-as-code, infra-tool (archetype) |
| llm-agents | `concerns/llm-agents.md` | LLM-based agents, multi-agent coordination, non-deterministic outputs | ai-assistant, external-sdk |
| message-queue | `concerns/message-queue.md` | Async messaging (RabbitMQ, Kafka, BullMQ) | microservice (archetype) |
| multi-tenancy | `concerns/multi-tenancy.md` | Tenant isolation, per-tenant config, cross-tenant protection | auth, authorization |
| plugin-system | `concerns/plugin-system.md` | Dynamic loading, extension points | sdk-framework (archetype) |
| polyglot | `concerns/polyglot.md` | Multi-language codebases with cross-language bridges (FFI, Protobuf, gRPC) | codegen |
| protocol-integration | `concerns/protocol-integration.md` | Bidirectional protocols (LSP, MCP) | — |
| realtime | `concerns/realtime.md` | WebSocket, SSE, live updates | gui, http-api |
| task-worker | `concerns/task-worker.md` | Background jobs, scheduled tasks | message-queue |
| wire-protocol | `concerns/wire-protocol.md` | Binary protocols (MQTT, AMQP, RESP, WebRTC, RTMP) | network-server (archetype), message-broker (archetype) |
| graceful-lifecycle | `concerns/graceful-lifecycle.md` | Server lifecycle (health checks, graceful shutdown, connection draining) | http-api, microservice, network-server (archetype) |
| observability | `concerns/observability.md` | Structured logging, metrics, distributed tracing | http-api, microservice |
| gpu-compute | `concerns/gpu-compute.md` | GPU/accelerator programming (CUDA, inference, compute shaders) | data-io, network-server (archetype) |
| resilience | `concerns/resilience.md` | Retry, circuit breaker, backpressure, timeout management | http-api, microservice, external-sdk |
| connection-pool | `concerns/connection-pool.md` | Connection/resource pool management (DB, HTTP, gRPC pools) | http-api, database-engine (archetype) |
| webrtc | `concerns/webrtc.md` | WebRTC protocol suite (ICE, DTLS-SRTP, SDP, media tracks) | realtime, wire-protocol |
| tls-management | `concerns/tls-management.md` | TLS/mTLS certificate lifecycle (ACME, rotation, SNI) | network-server (archetype), http-api |
| schema-registry | `concerns/schema-registry.md` | Schema evolution and registry (Protobuf, Avro, JSON Schema) | message-queue, grpc, codegen |
| cryptography | `concerns/cryptography.md` | Cryptographic primitives (key exchange, encryption, signatures) | wire-protocol, tls-management, auth |
| udp-transport | `concerns/udp-transport.md` | UDP datagram networking (DNS, QUIC, game net, media) | wire-protocol, network-server (archetype) |
| media-streaming | `concerns/media-streaming.md` | HLS/DASH adaptive streaming, transcoding, RTMP ingest | realtime, gpu-compute |
| geospatial | `concerns/geospatial.md` | Spatial indexing, geo-fencing, map tiles, geocoding | http-api, data-io |
| compliance | `concerns/compliance.md` | Regulatory frameworks (HIPAA, PCI-DSS, GDPR, SOX) | auth, authorization, audit-logging |
| payment-processing | `concerns/payment-processing.md` | Payment gateway integration, idempotency, refunds | auth, cryptography, compliance |
| offline-sync | `concerns/offline-sync.md` | Offline-first storage, sync queues, conflict resolution | async-state, mobile |
| search-engine | `concerns/search-engine.md` | Full-text search, inverted indexes, relevance scoring | http-api, data-io |
| stream-processing | `concerns/stream-processing.md` | Windowing, watermarks, exactly-once, checkpointing | message-queue, data-io |
| audit-logging | `concerns/audit-logging.md` | Immutable audit trails, tamper-proof event logging | auth, compliance, observability |
| content-moderation | `concerns/content-moderation.md` | Text/image/video moderation, review queues, appeals | auth, llm-agents |
| push-notification | `concerns/push-notification.md` | FCM/APNS/WNS, topic subscription, delivery tracking | mobile, message-queue |
| iot-protocol | `concerns/iot-protocol.md` | MQTT/CoAP/LwM2M, device management, telemetry | wire-protocol, embedded |
| speech-processing | `concerns/speech-processing.md` | STT/TTS, VAD, speaker diarization | gpu-compute, external-sdk |
| simulation-engine | `concerns/simulation-engine.md` | Physics/DES, time-stepping, deterministic replay | gpu-compute, data-io |
| scheduling-algorithm | `concerns/scheduling-algorithm.md` | Task scheduling, resource allocation, constraint solving | task-worker, distributed-consensus |

## Archetypes

| Module | File | Description | Typical Interfaces |
|--------|------|-------------|--------------------|
| ai-assistant | `archetypes/ai-assistant.md` | LLM-powered applications | gui or http-api |
| browser-extension | `archetypes/browser-extension.md` | Browser extensions (manifest, content scripts, background workers) | gui |
| database-engine | `archetypes/database-engine.md` | Storage engines, query processors (B-tree, LSM, WAL) | — |
| game-engine | `archetypes/game-engine.md` | Game engines, ECS, render loops (Unity, Unreal, Godot) | gui |
| infra-tool | `archetypes/infra-tool.md` | IaC tools, reconciliation engines (Terraform, Pulumi) | cli |
| message-broker | `archetypes/message-broker.md` | Message brokers, event streaming (Kafka, RabbitMQ, NATS) | — |
| microservice | `archetypes/microservice.md` | Distributed service architecture | http-api |
| network-server | `archetypes/network-server.md` | Proxies, load balancers, L4/L7 servers | — |
| public-api | `archetypes/public-api.md` | External-facing API platforms | http-api |
| sdk-framework | `archetypes/sdk-framework.md` | Libraries, SDKs, and frameworks consumed by other developers | cli, http-api |
| compiler | `archetypes/compiler.md` | Compilers, interpreters, language servers, linters, formatters | cli, library |
| cache-server | `archetypes/cache-server.md` | In-memory stores, caching servers (Redis, Memcached, Dragonfly) | cli, library |
| workflow-engine | `archetypes/workflow-engine.md` | Durable execution engines (Temporal, Cadence, Step Functions) | http-api, cli |
| media-server | `archetypes/media-server.md` | SFU/MCU media servers, streaming, transcoding | http-api, grpc |
| inference-server | `archetypes/inference-server.md` | ML inference serving (vLLM, Triton, TGI, Ollama) | http-api, grpc |

## Contexts (Axis 5)

> Contexts differ from Concerns: Concerns describe what the app *does*. Contexts describe what you're *doing to* the app. Context is a composite axis with three components: **Mode** (pipeline structure), **Scale** (depth calibration), and **Modifiers** (situational overlays).

### Modes (4)

Pipeline structure — determines which steps run and how. Exactly ONE mode is active.

| Module | File | Description | Activated by |
|--------|------|-------------|-------------|
| greenfield | `contexts/modes/greenfield.md` | Building from scratch, no existing codebase | Origin = greenfield |
| rebuild | `contexts/modes/rebuild.md` | Rebuilding existing app with preservation rules | Origin = rebuild |
| incremental | `contexts/modes/incremental.md` | Adding Features to an existing SDD project | Subsequent `add` after initial setup |
| adoption | `contexts/modes/adoption.md` | Wrapping existing code with SDD documentation | Origin = adoption |

### Modifiers (1+)

Situational overlays — zero or more active simultaneously. Extensible via domain-extend.

| Module | File | Description | Activated by |
|--------|------|-------------|-------------|
| migration | `contexts/modifiers/migration.md` | Modernization, version upgrades, platform moves (M0-M4 framework) | `--migration` flag, migration signals in codebase |

## Profiles (smart-sdd only)

| Profile | Interfaces | Concerns | Archetype |
|---------|-----------|----------|-----------|
| fullstack-web | http-api, gui | async-state, auth, i18n | — |
| web-api | http-api | auth | — |
| desktop-app | gui | async-state, ipc | — |
| cli-tool | cli | — | — |
| ml-platform | http-api, cli, data-io | plugin-system, auth | — |
| sdk-library | cli | plugin-system | sdk-framework |
| mobile-app | mobile | auth, async-state, realtime | — |
| embedded-system | embedded | hardware-io | — |
| compiler-tool | cli | codegen, plugin-system | compiler |
| inference-server | http-api | gpu-compute, graceful-lifecycle, observability | inference-server |
| grpc-service | grpc | auth, resilience, observability | microservice |
| proxy-server | cli | graceful-lifecycle, tls-management | network-server |
| broker-server | cli | graceful-lifecycle, observability | message-broker |
| cache-service | cli | graceful-lifecycle, connection-pool | cache-server |
| media-service | http-api, grpc | webrtc, realtime, graceful-lifecycle | media-server |

## Module File Structure

Each shared module file contains:

```
## Signal Keywords
### Semantic (S0 — for init inference)     ← used by smart-sdd init
### Code Patterns (R1 — for source analysis) ← used by reverse-spec analyze

## Module Metadata
```

Context modules have a different structure:

```
## M0: Signal Detection     ← trigger conditions
## M1-M2: Classification    ← categorize the change
## M3: Impact Assessment    ← analyze affected scope
## M4: Pipeline Modifier    ← adjust pipeline depth

## Module Metadata
```

Skill-specific sections remain in their respective skill directories:
- **smart-sdd**: `S1` (SC Rules), `S5` (Probes), `S7` (Bug Prevention), etc.
- **reverse-spec**: `R3` (Analysis Axes), `R4` (Extraction Patterns), etc.
