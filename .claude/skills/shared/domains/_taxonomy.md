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

## Contexts

> Contexts differ from Concerns: Concerns describe what the app *does*. Contexts describe what you're *doing to* the app. Contexts modify pipeline depth and dynamically activate relevant Concern/Foundation modules.

| Module | File | Description | Activated by |
|--------|------|-------------|-------------|
| migration | `contexts/migration.md` | Modernization, version upgrades, platform moves (M0-M4 framework) | S6 scenario, `--migration` flag, migration signals in codebase |

## Profiles (smart-sdd only)

| Profile | Interfaces | Concerns | Archetype |
|---------|-----------|----------|-----------|
| fullstack-web | http-api, gui | async-state, auth, i18n | — |
| web-api | http-api | auth | — |
| desktop-app | gui | async-state, ipc | — |
| cli-tool | cli | — | — |
| ml-platform | http-api, cli, data-io | plugin-system, auth | — |
| sdk-library | cli | plugin-system | sdk-framework |

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
