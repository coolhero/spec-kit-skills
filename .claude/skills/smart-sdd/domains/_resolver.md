# Domain Module Resolution Protocol

> Defines how the agent loads domain modules for the current project.
> Read this file once at skill invocation (referenced from SKILL.md § Domain Profile).
>
> **Architecture**: 5-axis model. See `_schema.md` § Domain Profile Model for the conceptual framework.

---

## Resolution Steps

### Step 1. Read Domain Profile from sdd-state.md

Look for the Domain Profile fields in `sdd-state.md` header:

```
# 5 Axes
**Domain Profile**: <profile-name>
**Interfaces**: <comma-separated list>              ← Axis 1
**Concerns**: <comma-separated list>                ← Axis 2
**Archetype**: <comma-separated list or "none">     ← Axis 3 (extends Concern rules with domain philosophy)
**Framework**: <name or "none">                     ← Axis 4 (Foundation — framework-specific rules)
**Context Mode**: <greenfield | rebuild | incremental | adoption>  ← Axis 5 (Mode)
**Context Scale**: <project_maturity × team_context, e.g., production × small-team>  ← Axis 5 (Scale — adjusts rule depth)
**Context Modifiers**: <comma-separated list, e.g., migration, compliance | "none">  ← Axis 5 (Modifiers — situational overlays)

# Optional overrides
**Custom**: <path to domain-custom.md or "none">
**Org Convention**: <path to org-convention.md or "none">
```

### Step 2. Resolve Profile (if needed)

- If `**Domain Profile**` is a profile name (e.g., `desktop-app`): read `domains/profiles/{name}.md` to expand into interfaces + concerns (+ archetype if profile specifies one, e.g., `sdk-library` → `sdk-framework`)
- If `**Interfaces**` and `**Concerns**` are already explicit: use directly
- **Context Mode** is determined by the `**Origin**` field in sdd-state.md:
  - `greenfield` → `contexts/modes/greenfield.md`
  - `rebuild` → `contexts/modes/rebuild.md`
  - `adoption` → `contexts/modes/adoption.md`
  - If Origin is `rebuild` or `greenfield` and project already has Features: `contexts/modes/incremental.md` for subsequent additions

### Step 2b. Resolve Foundation

1. Read `**Framework**` from sdd-state.md header
2. If framework is "custom" or "none" → skip Foundation loading
3. For each framework (comma-separated):
   - Load `../../reverse-spec/domains/foundations/{framework}.md` § F2 (items only)
   - Load `../../reverse-spec/domains/foundations/_foundation-core.md` § F3 (T0 rules)
4. Cache Foundation items for session

### Step 2c. Resolve Archetype

1. Read `**Archetype**` from sdd-state.md header (comma-separated list or `"none"`)
2. If `"none"` or field is missing → skip archetype loading
3. For each archetype name:
   - Load `domains/archetypes/{name}.md`
   - Validate: file must have at least A0 and A1 sections
4. Multiple archetypes are allowed (comma-separated) — merge by append

**When Archetype field is missing** (backward compatibility):
- Treat as `"none"` — no archetypes loaded
- Do NOT write the field retroactively (only set during init/pipeline Phase 0)

### Step 2d. Resolve Organization Conventions (optional)

Organization-level conventions provide shared rules that apply across all projects in an organization. Unlike `domain-custom.md` (project-specific), org conventions are reusable and versioned.

1. Read `**Org Convention**` from sdd-state.md header (path or `"none"`)
2. If `"none"` or field is missing → skip org convention loading
3. Resolution order:
   a. If path is absolute → load directly
   b. If path is relative → resolve from CWD
   c. If path starts with `~` → expand home directory (e.g., `~/.claude/domain-conventions/my-org.md`)
4. Validate: file must be valid markdown with at least one S-section or A-section
5. Org conventions are loaded AFTER archetypes but BEFORE context modes, allowing them to override archetype defaults while respecting context-mode-specific rules

**Typical org convention file structure**:
```markdown
# Org Convention: {org-name}

> Organization-specific coding standards and architectural patterns.
> Version: 1.0.0

## S1. SC Generation Rules (org overrides)
[Org-specific SC patterns — e.g., "all APIs must return standard error envelope"]

## S7. Bug Prevention Rules (org additions)
[Org-specific anti-patterns — e.g., "never use ORM lazy loading in API endpoints"]

## Custom Rules
[Any org-specific rules not covered by S-sections]
```

**When Org Convention field is missing** (backward compatibility):
- Treat as `"none"` — no org conventions loaded
- Do NOT write the field retroactively (only set during init)

### Step 3. Load Modules in Order (5 axes)

```
Axis 1 (Interface):     domains/interfaces/{interface}.md          (for EACH)
Axis 2 (Concern):       domains/concerns/{concern}.md              (for EACH)
Axis 3 (Archetype):     domains/archetypes/{archetype}.md          (for EACH)
Axis 4 (Foundation):    ../../reverse-spec/domains/foundations/{framework}.md § F2 + _foundation-core.md § F3
Axis 5 (Context):       domains/contexts/modes/{mode}.md           (ONE mode)
                        domains/contexts/modifiers/{modifier}.md   (ZERO or more modifiers)

Plus:
  Base:                 domains/_core.md                            (ALWAYS — universal rules)
  Org convention:       {path}/org-convention.md                    (if specified)
  Custom:               {path}/domain-custom.md                    (if specified)
```

**Loading order** (later modules extend earlier):
```
1. domains/_core.md                              (ALWAYS — universal rules)
2. domains/interfaces/{interface}.md              (Axis 1 — for EACH listed interface)
3. domains/concerns/{concern}.md                  (Axis 2 — for EACH listed concern)
4. domains/archetypes/{archetype}.md              (Axis 3 — for EACH listed archetype)
4b. ../../reverse-spec/domains/foundations/{framework}.md  (Axis 4 — Foundation F2 items + F3 T0 rules)
5. {Org convention path}/org-convention.md        (if specified and file exists)
6. domains/contexts/modes/{mode}.md               (Axis 5 — ONE mode: greenfield|rebuild|incremental|adoption)
7. domains/contexts/modifiers/{modifier}.md       (Axis 5 — ZERO or more: migration, compliance, etc.)
8. {Custom path}/domain-custom.md                 (if specified and file exists)
```

> **Signal Keywords resolution**: Each module's S0/A0 section references `shared/domains/` for signal keywords. During S0/A0 aggregation (init inference), read keywords from `../../shared/domains/{type}/{name}.md § Signal Keywords` instead of the skill-local module. See `shared/domains/_taxonomy.md` for the complete module registry.

**Merge rule**: Later modules extend earlier ones. For same-section content (summary — 5 of 15 rules):
- **S1 SC Rules**: Append (accumulate all rules)
- **S2 Parity Dimensions**: Append (add module-specific dimensions)
- **S3 Verify Steps**: Override only if module explicitly overrides (otherwise inherit _core)
- **S5 Elaboration Probes**: Append (accumulate all probes)
- **S7 Bug Prevention**: Append (accumulate all activation conditions)

> See `_schema.md` § Section Merge Rules for the complete merge rule table (15 rules covering S0–S9, A0–A5).

### Step 3.5. Apply Cross-Concern Integration Rules

After loading all individual modules (Step 3), apply integration rules for concern combinations that produce emergent patterns. Individual modules define independent rules; integration rules define **combined patterns** that arise only when specific modules are active together.

**Pre-check — Skip conditions**:
- If only 1 module is active (e.g., `gui` only, no concerns) → skip Step 3.5 entirely (no combinations possible)
- If 0 concern modules active → skip (archetypes alone don't produce cross-concern rules)
- If Scale = `prototype` + `solo` → load only rows tagged [CORE] below (top 10 most-used combinations). Full table for `mvp`/`production` or `small-team`/`large-team`.

> **Why conditional**: The 62-rule table below occupies ~1,200 lines of context. For a prototype with a single concern, loading all 62 rules wastes context budget on combinations that can never activate. The Pre-check ensures rules are loaded proportionally to project complexity.

| Active Combination | Integration Pattern | Injected Rule |
|-------------------|-------------------|---------------|
| `gui` + `realtime` | Real-time UI sync | S1: SC must cover optimistic update + conflict resolution + reconnection UI. S7: Add "stale UI after reconnect" prevention rule |
| `gui` + `async-state` + `realtime` | Live state synchronization | S5: Add probe "How does remote state sync with local store? Conflict resolution strategy?" |
| `microservice` + `message-queue` | Inter-service async communication | S1: SC must cover message contract versioning + dead-letter handling. S7: Add "cross-service message schema drift" prevention |
| `microservice` + `auth` | Distributed authentication | S5: Add probe "Token propagation strategy across service boundaries? Service-to-service auth vs user auth?" |
| `microservice` + `multi-tenancy` | Tenant-aware service mesh | S1: SC must cover tenant ID propagation across service calls. S7: Add "tenant context lost in async service call" prevention |
| `http-api` + `external-sdk` | Third-party API integration | S5: Add probe "SDK pagination strategy? Rate limit handling? Retry policy?" S7: Add "SDK version breaking change" prevention |
| `gui` + `i18n` + `async-state` | Localized reactive UI | S7: Add "locale change doesn't trigger state-dependent re-render" prevention |
| archetype:`ai-assistant` + `realtime` | Streaming AI responses | S1: SC must cover stream interruption + partial response display + token budget mid-stream. S5: Add probe "Stream backpressure when UI can't keep up?" |
| archetype:`ai-assistant` + `external-sdk` | Multi-provider LLM | S5: Add probe "Provider failover strategy? Response format normalization across providers?" |
| archetype:`microservice` + `task-worker` | Distributed job processing | S1: SC must cover cross-service job ownership + progress tracking. S7: Add "orphaned job after service restart" prevention |
| `llm-agents` + `gui` | AI-assisted UI workflows | S1: SC must cover loading states during LLM calls + streaming result display + error recovery in UI. S7: Add "UI frozen during sync LLM call" prevention |
| `llm-agents` + `http-api` | LLM-powered API endpoints | S1: SC must cover request timeout for LLM calls + streaming response format + cost tracking. S7: Add "unbounded LLM call without timeout" prevention |
| `llm-agents` + `persistence` | Agent state persistence | S1: SC must cover conversation history serialization + checkpoint recovery + cache invalidation. S5: Add probe "How is agent state persisted across sessions?" |
| `llm-agents` + `external-sdk` | Multi-provider LLM agents | S1: SC must cover provider failover + response format normalization + model capability detection. S7: Add "provider-specific code in business logic" prevention |
| `http-api` + `graceful-lifecycle` | Server lifecycle management | S1: SC must cover readiness gate (no traffic before warm-up) + drain timeout on SIGTERM + health check dependency verification. S7: Add "premature traffic acceptance before dependency ready" prevention |
| `microservice` + `graceful-lifecycle` | Distributed lifecycle coordination | S1: SC must cover rolling restart with zero-downtime + pre-stop hook for K8s + staggered startup. S5: Add probe "How are rolling restarts coordinated across instances?" |
| `microservice` + `observability` | Distributed observability | S1: SC must cover trace propagation across service boundaries (W3C Trace Context) + correlated logs across services. S7: Add "missing trace ID in cross-service call" prevention |
| `microservice` + `resilience` | Distributed fault tolerance | S1: SC must cover retry budget (max % retries) + deadline propagation + circuit breaker per downstream service. S7: Add "retry storm amplification across service chain" prevention |
| `http-api` + `connection-pool` | Server-side connection management | S1: SC must cover pool sizing based on expected concurrency + acquire timeout + health validation on borrow. S7: Add "connection pool exhaustion under load" prevention |
| `gpu-compute` + `graceful-lifecycle` | GPU server lifecycle | S1: SC must cover GPU memory cleanup on shutdown + in-flight inference drain + model unload sequence. S5: Add probe "How are in-flight GPU operations handled during shutdown?" |
| `gpu-compute` + `http-api` | ML inference API | S1: SC must cover inference timeout + batch request handling + GPU OOM error response (503, not 500). S7: Add "unbounded inference without timeout" prevention |
| `network-server` + `graceful-lifecycle` | Server process lifecycle | S1: SC must cover listener close → connection drain → resource cleanup sequence. S7: Add "zombie connections after shutdown" prevention |
| `network-server` + `resilience` | Server-side fault handling | S1: SC must cover upstream health checking + connection retry with backoff + load shedding under pressure. S7: Add "cascading failure from unhealthy upstream" prevention |
| `mobile` + `auth` | Mobile authentication | S1: SC must cover biometric auth + secure token storage (Keychain/Keystore) + session refresh in background. S7: Add "token stored in insecure storage" prevention |
| `mobile` + `realtime` | Mobile real-time | S1: SC must cover background/foreground connection lifecycle + reconnection after app wake + push notification fallback when WebSocket disconnected. S7: Add "WebSocket leak on app background" prevention |
| archetype:`compiler` + `plugin-system` | Extensible compiler | S1: SC must cover plugin API stability + AST access contract for plugins + plugin execution sandboxing. S5: Add probe "Plugin API versioning? Plugin-safe AST traversal?" |
| `network-server` + `observability` | Server observability | S1: SC must cover per-connection metrics (duration, bytes, errors) + access logging with trace ID + upstream latency histogram. S7: Add "unobserved connection failure" prevention |
| `realtime` + `graceful-lifecycle` | Live connection shutdown | S1: SC must cover WebSocket close frame before shutdown + reconnection guidance to clients + active subscription drain. S7: Add "WebSocket drop without close frame on SIGTERM" prevention |
| `message-broker` + `observability` | Broker observability | S1: SC must cover per-topic metrics (publish rate, consume rate, lag) + consumer group monitoring + partition-level tracing. S7: Add "silent consumer lag growth" prevention |
| `gpu-compute` + `realtime` | Streaming inference | S1: SC must cover token-by-token streaming emission + backpressure when client is slow + partial result display. S7: Add "GPU memory held during slow stream" prevention |
| `task-worker` + `observability` | Job observability | S1: SC must cover per-job metrics (duration, status, retries) + job queue depth monitoring + failed job alerting. S7: Add "silent job failure without alert" prevention |
| `grpc` + `schema-registry` | gRPC schema management | S1: SC must cover Protobuf backward compatibility validation + buf breaking check in CI + reserved field enforcement. S7: Add "breaking proto change without version bump" prevention |
| `grpc` + `resilience` | gRPC fault tolerance | S1: SC must cover per-method deadline + gRPC retry policy (via service config) + circuit breaker per upstream service. S7: Add "missing deadline on gRPC call" prevention |
| `grpc` + `observability` | gRPC observability | S1: SC must cover per-method latency histogram + gRPC status code counter + streaming message count. S7: Add "gRPC error code logged as HTTP status" prevention |
| archetype:`cache-server` + `graceful-lifecycle` | Cache server lifecycle | S1: SC must cover persistence flush before shutdown + client notification of impending shutdown + cluster rebalancing. S7: Add "data loss on cache server restart without persistence flush" prevention |
| archetype:`inference-server` + `graceful-lifecycle` | Inference server lifecycle | S1: SC must cover in-flight inference drain + model unload sequence + GPU memory cleanup. S7: Add "GPU memory leak after model hot-swap" prevention |
| archetype:`media-server` + `graceful-lifecycle` | Media server lifecycle | S1: SC must cover active room drain + media track cleanup + recording finalization before shutdown. S7: Add "recording corruption on abrupt shutdown" prevention |
| archetype:`workflow-engine` + `observability` | Workflow observability | S1: SC must cover per-workflow execution metrics (duration, status, activity count) + activity latency + workflow replay count. S7: Add "stuck workflow without alert" prevention |
| `payment-processing` + `compliance` | Compliant payments | S1: SC must cover PCI scope reduction verification + payment data never logged + tokenization of card data + audit trail for all transactions. S7: Add "raw card number in application logs" prevention |
| `payment-processing` + `auth` | Authenticated payments | S1: SC must cover payment intent tied to authenticated session + 3DS challenge flow + idempotency key per user session. S7: Add "payment submitted without valid auth session" prevention |
| `geospatial` + `search-engine` | Location-aware search | S1: SC must cover geo-filtered search results + distance sorting + bounding box queries + spatial index performance. S7: Add "full table scan on geo query" prevention |
| `media-streaming` + `gpu-compute` | Hardware-accelerated transcoding | S1: SC must cover GPU encoder selection + fallback to CPU + transcoding job queue + output format validation. S7: Add "GPU OOM during concurrent transcode" prevention |
| `media-streaming` + `realtime` | Live streaming | S1: SC must cover ingest → transcode → package → deliver latency budget + segment duration + DVR window. S7: Add "HLS segment gap causing player stall" prevention |
| `offline-sync` + `auth` | Authenticated offline sync | S1: SC must cover token refresh before sync + offline auth cache expiry + conflict resolution for auth-dependent data. S7: Add "sync after token expiry overwrites server data" prevention |
| `compliance` + `audit-logging` | Compliant audit trails | S1: SC must cover immutable log storage + log retention per regulation + access to audit logs restricted + tamper detection. S7: Add "audit log modified after write" prevention |
| `compliance` + `auth` | Compliant authentication | S1: SC must cover password policy enforcement + MFA requirement per regulation + session timeout + failed login lockout. S7: Add "compliance violation: missing MFA for regulated data access" prevention |
| `push-notification` + `offline-sync` | Offline notification handling | S1: SC must cover notification queue during offline + delivery on reconnect + dedup of queued notifications. S7: Add "duplicate notification burst on reconnect" prevention |
| `iot-protocol` + `wire-protocol` | IoT wire protocol | S1: SC must cover MQTT QoS levels + CoAP observe pattern + retained messages + last will testament. S7: Add "QoS 2 message delivered twice" prevention |
| `stream-processing` + `observability` | Stream pipeline observability | S1: SC must cover per-operator metrics + watermark lag + checkpoint duration + backpressure indicators. S7: Add "silent data loss from unmonitored late data" prevention |
| `content-moderation` + `llm-agents` | AI-assisted moderation | S1: SC must cover LLM classification confidence threshold + human review escalation + false positive rate monitoring. S7: Add "auto-ban from low-confidence LLM classification" prevention |
| `search-engine` + `observability` | Search observability | S1: SC must cover query latency histogram + zero-result rate + index freshness lag + popular queries tracking. S7: Add "stale index serving outdated results" prevention |
| `scheduling-algorithm` + `observability` | Scheduler observability | S1: SC must cover scheduling latency + resource utilization + queue depth + starvation detection. S7: Add "low-priority task starvation" prevention |
| `gui` + `async-state` | Optimistic UI state | S1: SC must cover optimistic update rollback on server rejection + loading state management + hydration state consistency. S7: Add "stale optimistic state after network error" prevention |
| `gui` + `ipc` | IPC-driven UI updates | S1: SC must cover IPC-triggered UI refresh + main→renderer state propagation + IPC error display in UI. S7: Add "UI frozen waiting for unresponsive IPC" prevention |
| `async-state` + `ipc` | Cross-process state sync | S1: SC must cover state store synchronization across IPC boundary + async IPC response updating reactive state. S5: Add probe "How are state changes propagated between main and renderer processes?" |
| `gui` + `async-state` + `ipc` | Desktop app data flow | S1: SC must cover full renderer↔main state lifecycle: user action → IPC call → main process → state update → renderer re-render. S7: Add "state desync between main and renderer after IPC timeout" prevention |
| `http-api` + `auth` | API authentication | S1: SC must cover route protection middleware + token refresh flow + session invalidation + CORS with credentials. S7: Add "expired token accepted after cache invalidation delay" prevention |
| `resilience` + `connection-pool` | Pool-aware resilience | S1: SC must cover retry behavior during pool exhaustion + circuit breaker interaction with pool health + connection validation as resilience signal. S7: Add "retry storm amplifying pool exhaustion" prevention |
| `k8s-operator` + `resilience` | Operator fault tolerance | S1: SC must cover reconcile retry vs circuit breaker (when to stop retrying failing reconciliation) + status condition degradation during prolonged external failures. S7: Add "operator retry loop overwhelming failing external resource" prevention |
| `k8s-operator` + `graceful-lifecycle` | Operator shutdown | S1: SC must cover finalizer completion during shutdown + watch cache drain + informer shutdown sequence. S7: Add "orphaned finalizer blocking namespace deletion" prevention |
| `dag-orchestration` + `observability` | DAG pipeline observability | S1: SC must cover per-DAG run metrics + task-level duration tracking + SLA monitoring + backfill progress. S7: Add "silent DAG failure without alerting" prevention |

**Application**: Integration rules are appended to the merged profile after Step 3 completes. They follow the same merge rules (S1 append, S5 append, S7 append). Only combinations where ALL listed modules are active trigger their rules.

**Extensibility**: To add new integration rules, append rows to this table. Each row must specify: the combination trigger, the emergent pattern name, and the concrete rules injected.

### Step 4. Apply Context Scale

Read the Context Scale from sdd-state.md (Axis 5, Scale component):
- `**Context Scale**`: `{project_maturity} × {team_context}` (default: `mvp × solo`)
  - Project maturity: `prototype` | `mvp` | `production`
  - Team context: `solo` | `small-team` | `large-team`

Context Scale does NOT produce rules — it **adjusts** rules from all 5 axes:

| Maturity | Effect on Rules |
|----------|----------------|
| `prototype` | S1: Functional SCs only, skip performance/edge-case SCs. S3: Tests optional (encourage but don't block). S7: Disable over-engineering guards |
| `mvp` | S1: Functional + key error-path SCs. S3: Tests required for critical paths. S7: Standard guards |
| `production` | S1: Full SC coverage (edge cases, performance, concurrency). S3: Comprehensive tests required. S7: All guards active + observability requirements |

| Team Context | Effect on Rules |
|-------------|----------------|
| `solo` | S5: Skip collaboration probes (code review, PR process). No branch protection requirements |
| `small-team` | S5: Add basic collaboration probes. Branch protection recommended |
| `large-team` | S5: Add code ownership probes. S7: Add "undocumented API contract change" prevention. Branch protection + PR review required |

**Application**: Context Scale is applied AFTER all 5 axes are loaded and merged. It acts as a filter that adjusts depth — NOT by removing rules, but by changing their enforcement level:
- `prototype` + S1 "IPC timeout handling": rule still visible in context, but marked `(optional for prototype)` in Checkpoint display
- `production` + S7 "observability": rule escalated from ⚠️ warning to 🚫 blocking

**Micro-project adjustment** (when Scale Detection = Micro):
- Maturity: force to `prototype` regardless of CI/CD signals (project too small for production classification to matter)
- Pipeline simplification: constitution is optional, registries minimal, single-Feature default
- Specify depth: minimal FR/SC count (avoid over-specifying trivial functionality)
- Plan depth: single-component architecture (no multi-layer decomposition)
- Verify depth: build + basic test only (no cross-Feature, no demo)

> **Where Scale is consumed**: See `contexts/modes/greenfield.md` § Configuration Parameters for the full parameter definitions and per-maturity SC depth rules. Scale is a component of the Context axis (Axis 5) — Mode defines the pipeline lifecycle, Scale defines the rigor level within that lifecycle.

### Step 5. Per-Command Lazy Loading (Context Optimization)

Not every pipeline command needs every S-section. To optimize context budget, load only the sections relevant to the current command:

| Command | Sections Needed | Sections Skippable |
|---------|----------------|-------------------|
| `specify` | S0, S1, S5, S9, A2, A3, A5 | S2, S3, S6, S7, S8 |
| `plan` | S7 (B-1 only), Foundation F2/F3 | S0, S1, S2, S3, S5, S6, S8, S9 |
| `tasks` | (minimal — plan.md is primary input) | S0–S9 (domain rules already embedded in spec/plan) |
| `implement` | S7 (B-3 only), S6, Foundation F8 | S0, S1, S2, S3, S5, S8, S9 |
| `verify` | S1 (for SC compliance check), S3, S7 (B-4), S8, Foundation F8 | S0, S2, S5, S6, S9 |
| `add` (Brief) | S5, S9, A3, A5 | S0, S1, S2, S3, S6, S7, S8 |

**Loading protocol**:
1. Full-load all module files (Step 3) — needed for merge
2. After merge, **extract only the sections needed for the current command** into working memory
3. Discard (do not retain) sections not in the "Needed" column
4. This reduces per-command domain context from ~1400-1800 lines to ~600-900 lines

**When to skip lazy loading**: If the agent's context window is large enough to hold all sections (>100K tokens available after project-specific content), lazy loading is unnecessary — load everything for maximum rule coverage.

> **Context budget heuristic**: If total assembled context (domain modules + project artifacts + injection rules) exceeds ~80% of usable context window, activate lazy loading. See `context-injection-rules.md` § Context Budget Protocol for overflow handling.

### Step 6. Cache in Working Memory

Once loaded (and optionally filtered by lazy loading), the merged domain profile is used for the entire command session. No need to re-read module files mid-command.

---

## Worked Example: `desktop-app` Rebuild with Electron

Traces the full resolution chain for a project with:
- **Domain Profile**: `desktop-app` | **Origin**: `rebuild` | **Framework**: `electron` | **Archetype**: `ai-assistant` | **Org Convention**: `none` | **Custom**: `none`

### Step 1 → 2: Profile Expansion

`domains/profiles/desktop-app.md` expands to:
- **Interfaces**: `[gui]`
- **Concerns**: `[async-state, ipc]`
- **Context Mode**: Origin `rebuild` → `contexts/modes/rebuild.md`

### Step 2b: Foundation

Framework `electron` → Load:
- `../../reverse-spec/domains/foundations/electron.md` § F2 (58 items across 13 categories)
- `../../reverse-spec/domains/foundations/_foundation-core.md` § F3 (T0 grouping rules)

### Step 2c: Archetype

Archetype `ai-assistant` → Load:
- `domains/archetypes/ai-assistant.md` (A0–A4: Streaming-First, Model Agnosticism, etc.)

### Step 3: Module Loading (6 files)

| # | File Loaded | Sections Contributed |
|---|-------------|----------------------|
| 1 | `domains/_core.md` | S1 base SC rules, S2 base parity, S3 verify steps (test/build/lint/demo), S5 universal probes (auth/CRUD/validation/pagination/file + middleware + concurrency/cache/observability), S7 base B-1/B-2/B-3 |
| 2 | `domains/interfaces/gui.md` | S1 +UI interaction SCs, S2 +UI component/layout parity, S5 +routing/UI completeness/responsive probes, S6 UI testing (new), S7 +CSS rendering/UI surface audit, S8 runtime verification strategy (new) |
| 3 | `domains/concerns/async-state.md` | S1 +state transition/async flow SCs, S5 +state library/async pattern/subscription probes, S7 +selector instability/unbatched updates/UX behavior contract |
| 4 | `domains/concerns/ipc.md` | S1 +IPC call/process lifecycle SCs, S5 +IPC channel/error/security probes, S7 +IPC boundary safety/return value defense |
| 5 | `domains/archetypes/ai-assistant.md` | A1 philosophy principles (Streaming-First, Model Agnosticism, etc.), A2 +AI-specific SC rules, A3 +model/streaming/prompt probes, A4 constitution principles |
| 6 | `domains/contexts/modes/rebuild.md` | S1 +preservation SCs, S3 extends (migration regression gate) + S3d Foundation Compliance, S5 +source comparison/preservation probes, S7 +migration-specific rules |

### Step 4: Merged Result

After merge, the cached profile contains:

| Section | Sources (merge order) |
|---------|----------------------|
| **S1** SC Rules | _core → gui → async-state → ipc → rebuild (appended) |
| **S2** Parity | _core structural+logic → gui +UI component/layout (appended) |
| **S3** Verify | _core test/build/lint/demo → rebuild migration gate + S3d Foundation (extended) |
| **S5** Probes | _core 5 perspectives → gui routing/UI → async-state state/async → ipc channels/security → ai-assistant model/streaming/prompt → rebuild source/preservation (appended) |
| **S6** UI Testing | gui only (new section) |
| **S7** Bug Prevention | _core B-3 base → gui CSS/UI audit → async-state selector/unbatched → ipc boundary/return → rebuild migration (appended) |
| **S8** Runtime | gui only (new section) |
| **A1** Philosophy | ai-assistant (Streaming-First, Model Agnosticism, Offline Resilience, Token Awareness, Prompt Versioning) |
| **A2** SC Extensions | ai-assistant (AI-specific SC rules — appended to S1) |
| **A3** Probes | ai-assistant (model/streaming/prompt probes — appended to S5) |
| **A4** Constitution | ai-assistant (AI-specific constitution principles) |

**Total reads at session start**: 6 domain modules + 2 Foundation files = 8 file reads, then cached.

---

## Backward Compatibility

### Legacy `**Domain**: app` format

If sdd-state.md contains `**Domain**: app` (old format) without `**Domain Profile**`:

1. Read `domains/app.md` — it is a backward-compatibility shim
2. The shim specifies the default expansion (equivalent to `fullstack-web` profile)
3. Write the expanded Domain Profile fields to sdd-state.md (one-time migration)
4. Proceed with Step 3 (module loading) as normal

### `--domain` argument

If user passes `--domain app`, treat it as `--profile fullstack-web` (default expansion).
If user passes `--profile <name>`, read the named profile from `domains/profiles/{name}.md`.

---

## When to Read This File

- At every smart-sdd command invocation (after argument parsing, before command execution)
- At every reverse-spec invocation (after argument parsing, before Phase 1)
- For reverse-spec: the same resolution applies, but modules are read from `reverse-spec/domains/` (which have R-sections for analysis)

---

## Profile Selection (during init or reverse-spec)

When no Domain Profile exists yet (first-time setup), the detection method depends on the context mode:

### Brownfield / Adoption (existing codebase)

1. **File-system scanning**: Scan project files for R1 code pattern signals:
   - `package.json` + `src/pages/` or `src/app/` → likely `fullstack-web`
   - `Cargo.toml` + `src/main.rs` without UI → likely `cli-tool` or `web-api`
   - Electron indicators (`electron`, `electron-builder` in dependencies) → likely `desktop-app`
2. **User confirmation**: Present detected profile via AskUserQuestion

### Greenfield (no existing code)

1. **S0/A0 keyword inference**: Extract signals from the user's text description (idea string or PRD) and match against S0/A0 signal keywords from `shared/domains/` modules. See § Greenfield Inference below for the full algorithm.
2. **User confirmation**: Present inferred profile via AskUserQuestion (HARD STOP)

### Common

- **User can specify** `--profile` argument to override auto-detection or inference
- Both paths produce the same Domain Profile format written to sdd-state.md

---

## Greenfield Inference (during init Proposal Mode)

When `init` is invoked with an idea string or PRD (Proposal Mode), Domain Profile is inferred from user input before any sdd-state.md exists. This extends Profile Selection with signal-based inference.

> Full specification: `reference/clarity-index.md`

### Inference Steps

```
1. Extract signals from user input (idea string / PRD text)
2. Read S0 Signal Keywords from ALL interface and concern modules
3. Match signals against S0 keywords:
   - Primary keyword match (≥ 1) → activate module
   - Secondary keyword match only → flag for confirmation
4. Build candidate Domain Profile:
   - Interfaces: all activated interface modules
   - Concerns: all activated concern modules
   - Flagged: modules needing confirmation
5. Calculate per-axis confidence (0–3)
6. Write to Proposal (displayed for user approval at HARD STOP)
```

### Merge with Profile Selection

- If user also passes `--profile`: profile takes precedence, inference results are used only to fill gaps
- If no `--profile` and inference yields high confidence: present inferred profile directly
- If inference yields low confidence: present as suggestions with "Other" option

### S0/A0 Aggregation

> Full matching algorithm, S0/A0 aggregation rules, and archetype inference: See `reference/clarity-index.md` § 3 (Matching Algorithm), § 5 (S0/A0 Aggregation Rules).

During inference, the agent reads signal keywords from `shared/domains/` to build the vocabulary:
- **S0**: `shared/domains/interfaces/*.md` + `shared/domains/concerns/*.md` → Interface/Concern signal maps
- **A0**: `shared/domains/archetypes/*.md` → Archetype signal map (runs in parallel with S0)

> **Module registry**: `shared/domains/_taxonomy.md` lists all available modules.

Both S0 and A0 are one-time scans at init start. Results are cached for the duration of the init command.
