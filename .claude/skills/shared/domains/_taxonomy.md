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
| data-io | `interfaces/data-io.md` | Data pipelines, ETL, batch/stream processing | — |
| tui | `interfaces/tui.md` | Terminal UI (Ink, bubbletea, Ratatui) | — |

## Concerns

| Module | File | Description | Common Pairings |
|--------|------|-------------|-----------------|
| async-state | `concerns/async-state.md` | Reactive state management patterns | gui |
| auth | `concerns/auth.md` | Authentication flows (JWT, OAuth, session) | http-api |
| authorization | `concerns/authorization.md` | Permission models (RBAC, ABAC, ACL) | auth |
| codegen | `concerns/codegen.md` | Generated/templated code from IDL, schema, or template | polyglot |
| external-sdk | `concerns/external-sdk.md` | Third-party API/SDK integrations | ai-assistant (archetype) |
| i18n | `concerns/i18n.md` | Internationalization and localization | gui |
| infra-as-code | `concerns/infra-as-code.md` | Infrastructure definitions as first-class components (Terraform, Helm, K8s) | — |
| ipc | `concerns/ipc.md` | Inter-process communication (Electron, Workers) | gui (desktop-app) |
| message-queue | `concerns/message-queue.md` | Async messaging (RabbitMQ, Kafka, BullMQ) | microservice (archetype) |
| multi-tenancy | `concerns/multi-tenancy.md` | Tenant isolation, per-tenant config, cross-tenant protection | auth, authorization |
| plugin-system | `concerns/plugin-system.md` | Dynamic loading, extension points | sdk-framework (archetype) |
| polyglot | `concerns/polyglot.md` | Multi-language codebases with cross-language bridges (FFI, Protobuf, gRPC) | codegen |
| protocol-integration | `concerns/protocol-integration.md` | Bidirectional protocols (LSP, MCP) | — |
| realtime | `concerns/realtime.md` | WebSocket, SSE, live updates | gui, http-api |
| task-worker | `concerns/task-worker.md` | Background jobs, scheduled tasks | message-queue |

## Archetypes

| Module | File | Description | Typical Interfaces |
|--------|------|-------------|--------------------|
| ai-assistant | `archetypes/ai-assistant.md` | LLM-powered applications | gui or http-api |
| public-api | `archetypes/public-api.md` | External-facing API platforms | http-api |
| microservice | `archetypes/microservice.md` | Distributed service architecture | http-api |
| sdk-framework | `archetypes/sdk-framework.md` | Libraries, SDKs, and frameworks consumed by other developers | cli, http-api |

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

Skill-specific sections remain in their respective skill directories:
- **smart-sdd**: `S1` (SC Rules), `S5` (Probes), `S7` (Bug Prevention), etc.
- **reverse-spec**: `R3` (Analysis Axes), `R4` (Extraction Patterns), etc.
