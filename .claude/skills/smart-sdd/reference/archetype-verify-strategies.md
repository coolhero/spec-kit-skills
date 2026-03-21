# Archetype-Specific Verify Strategies

> Defines per-archetype runtime verification extensions.
> S8 lives in interface modules (how to verify). This file adds archetype-specific PRE-CONDITIONS and POST-CONDITIONS that modify the verify behavior.
> Referenced by: `commands/verify-phases.md` Phase 0 (archetype-aware startup), `commands/verify-sc-verification.md` Step 3 (SC classification extensions).
> Lazy-loaded: read ONLY when the active archetype matches a row in the table below.

---

## Archetype Verify Extension Table

| Archetype | Start Pre-condition | Health Check Override | SC Category Extensions | Post-verify Check |
|-----------|--------------------|-----------------------|-----------------------|-------------------|
| **ai-assistant** | Model/API key must be configured (→ 0-2b gate) | `GET /health` + model availability check (e.g., `GET /v1/models` returns ≥1) | `llm-output` — non-deterministic LLM responses: verify structure/format, not exact content | Verify token streaming doesn't hang (send request, verify first token < 5s) |
| **browser-extension** | Build extension (`npm run build`), load unpacked in Chromium via `--load-extension=path` | Extension popup loads, content script injected on test page | `extension-auto` — verify via Playwright on test page with extension loaded | Check no `chrome.runtime.lastError` in background console |
| **cache-server** | Start server process, wait for port ready | `redis-cli -p PORT ping` → PONG (or protocol-specific) | `resp-auto` — key ops via redis-cli; `eviction-auto` — fill memory → verify eviction policy | Verify clean shutdown: no data loss on `SHUTDOWN SAVE` |
| **compiler** | N/A (per-invocation) | N/A | `compile-auto` — input source → compile → verify output/AST/errors | Verify error messages include source location (line:col) |
| **database-engine** | Start DB server (or open embedded file). Seed test schema | Server: `pg_isready` or TCP connect. Embedded: file opens without error | `sql-auto` — execute SQL → verify result set; `txn-auto` — BEGIN/COMMIT/ROLLBACK sequence | Verify WAL/journal integrity after crash simulation (kill -9 → restart → verify data) |
| **game-engine** | Build game binary. Requires display (or `--headless` flag) | Process alive + window created (headless: stdout "ready") | `render-auto` — screenshot comparison; `sim-auto` — tick N frames → verify state | Verify no physics/state drift after 1000 ticks |
| **inference-server** | Start server + wait for model load (can take minutes: extend health timeout to 300s) | `GET /health` or `GET /v1/models` → model loaded | `inference-auto` — send prompt → verify response structure (not content); `stream-auto` — SSE/chunked response delivers tokens | Verify GPU memory released after model unload |
| **infra-tool** | N/A (per-invocation like CLI, but may need cloud credentials) | N/A | `plan-auto` — run plan → verify plan output; `apply-auto` — run apply on test infra → verify state | Verify `destroy` cleans up all resources (no leaks) |
| **media-server** | Start server, open media ports (UDP range). May need STUN/TURN | HTTP signaling endpoint responds. Media port range bound | `signaling-auto` — HTTP/WS signaling exchange; `media-manual` — actual media requires WebRTC client (user-assisted) | Verify room cleanup after all participants leave |
| **message-broker** | Start broker, wait for protocol port + management port | Management API health (HTTP) + protocol port accepts connection | `broker-auto` — pub/sub via CLI; `queue-auto` — create/inspect/delete queue | Verify no message loss: publish N → consume N → count match |
| **microservice** | Start service + dependent services (docker-compose or mock) | `GET /health` per service | Same as http-api, plus `integration-auto` — cross-service call chain verification | Verify circuit breaker triggers on dependency failure |
| **network-server** | Start proxy/LB, start upstream backends (at least 2 for LB testing) | Admin API health or TCP connect on listener port | `proxy-auto` — curl through proxy → verify upstream response; `route-auto` — verify routing rules | Verify graceful reload: sustained connections survive config reload |
| **public-api** | Start API server. May need API key provisioning for test client | `GET /health` or `GET /v1/status` | Same as http-api, plus `rate-limit-auto` — burst N requests → verify 429 after threshold | Verify API versioning: `/v1/` and `/v2/` coexist |
| **sdk-framework** | N/A (import as library) | Import succeeds without error | `api-auto` — call public API → verify return value matches docs; `type-auto` — TypeScript/type check passes | Verify backward compatibility: old test suite still passes |
| **workflow-engine** | Start server (Temporal) + start worker. Or: start worker connected to existing server | Server: gRPC health or HTTP API. Worker: registered in server | `workflow-auto` — start workflow via CLI → verify completion; `saga-auto` — fail step → verify compensation | Verify workflow replay: kill worker mid-execution → restart → verify workflow resumes |

---

## Usage Pattern

During verify Phase 0, after determining the archetype from sdd-state.md:

1. Look up the archetype in the table above
2. Apply **Start Pre-condition**: adjust Phase 0 startup accordingly (e.g., extend timeout for inference-server model loading)
3. Apply **Health Check Override**: use archetype-specific health check instead of generic HTTP GET
4. During SC classification (verify-sc-verification.md Step 0): add **SC Category Extensions** to the classification vocabulary
5. After all SCs verified: run **Post-verify Check** as a final validation

If the archetype is not in this table, use the default behavior from the interface module's S8 section.

---

## Non-Server Archetypes (No Listen Port)

Some archetypes don't follow the "start → listen → health check" pattern:

| Archetype | Pattern | Verify Approach |
|-----------|---------|----------------|
| **compiler** | Per-invocation (input → process → output) | Run with test input, verify output/error. No server lifecycle |
| **infra-tool** | Per-invocation (plan → apply → destroy) | Run commands, verify state changes. May need cloud/mock infra |
| **sdk-framework** | Import as library | Import in test script, call API, verify return values |
| **game-engine** | Continuous loop (may need headless mode) | Start in headless, run N ticks, verify state. Or: screenshot comparison |

For these, Phase 0 startup (0-2/0-2alt) is skipped. Verification uses `cli-auto` or `pipeline-auto` backends directly.
