# Domain Profile: app (smart-sdd)

> Default domain. For reverse-spec analysis profiles, see `../reverse-spec/domains/app.md`.
> This file covers smart-sdd-specific domain behavior: demo, parity, and verification.

---

## 1. Demo Pattern

- **Type**: Server-based
- **Default mode**: Launch dev server with demo data -> print "Try it" instructions (URLs to open, curl commands to run, CLI invocations -- at least 2 concrete instructions) -> keep running until Ctrl+C
- **CI mode**: Quick health check (start server, verify health endpoint, exit with status code)
- **Script location**: `demos/F00N-name.sh` (or `.ts`/`.py`/etc.)
- **"Try it" instructions**: URLs to browse, API endpoints to call, CLI commands to run

> Anti-patterns, code markers, script template, and detailed requirements: see [reference/demo-standard.md](../reference/demo-standard.md).

---

## 2. Parity Dimensions

### Structural Parity

| Category | What to Compare |
|----------|----------------|
| API endpoints | Route definitions, controllers, endpoint decorators -- match original routes |
| DB entities | Schema definitions, model classes -- match original table/collection structure |
| Test files | Test file presence and coverage scope -- match original test coverage |
| UI components | Component tree structure, page routes -- match original frontend structure (frontend/fullstack only) |
| Source behaviors | Exported functions, public methods, handlers -- match P1/P2 behaviors from Source Behavior Inventory |

### Logic Parity

| Category | What to Compare |
|----------|----------------|
| Business rules | State transitions, validation rules, authorization checks -- match original business logic |
| Test cases | Test scenario coverage -- original test cases should have equivalents |

---

## 3. Verify Steps

| Step | Required | Detection | Description |
|------|----------|-----------|-------------|
| **Test** | Yes (BLOCKING) | Detect from `package.json` scripts, `pyproject.toml`, `Makefile`, `Cargo.toml` | Run unit + integration tests. Failure blocks pipeline |
| **Build** | Yes (BLOCKING) | Detect build command from project config | Run project build. Failure blocks pipeline |
| **Lint** | Yes (BLOCKING) | Detect lint tool from project config | Run lint check. Failure blocks pipeline |
| **Demo-Ready** | Conditional (if constitution VI active) | Check `demos/F00N-name.sh` exists | Execute demo script with `--ci` flag. Verify health check passes |

### Limited Verification

When external dependencies (third-party APIs, paid services, hardware) block test/demo execution:
- User can select "Acknowledge limited verification" at the verify Checkpoint
- Status recorded as `limited` instead of `success`
- Merge step accepts `limited` status with warning

---

## 4. Adoption-Specific Behavior

> Defined in `commands/adopt.md` (pipeline flow) and `reference/injection/adopt-verify.md` (non-blocking verify).
> Key differences: test/build/lint failures are non-blocking (recorded as baseline), demo is optional, Feature status is `adopted` (not `completed`).

---

## 5. Feature Elaboration Probes

> Domain-specific additions to the base [Feature Elaboration Framework](../reference/feature-elaboration-framework.md).
> These probes extend the six base perspectives with app-domain concerns.

### Perspective 2 (Capabilities) — Additional Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| **Authentication & Authorization** | Who can access this? Role-based? Token-based? Session management needed? |
| **CRUD lifecycle** | What are the create/read/update/delete operations? Soft delete or hard delete? Audit trail? |
| **Validation** | Input validation rules? Server-side vs client-side? Error message format? |
| **Pagination & Search** | List views need pagination? Search/filter capabilities? Sort options? |
| **File handling** | File upload/download? Size limits? Allowed formats? Storage location? |

### Perspective 4 (Interfaces) — Additional Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| **REST conventions** | Resource naming? HTTP methods? Status codes? Versioning strategy? |
| **Real-time** | WebSocket/SSE needed? What events? Reconnection handling? |
| **Frontend routing** | New pages/routes? Navigation integration? Protected routes? |
| **Middleware** | Request middleware needed? (auth, logging, rate limiting, CORS) |

### Perspective 5 (Quality) — Additional Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| **Concurrency** | Race conditions possible? Optimistic locking? Idempotency keys? |
| **Caching** | Cache strategy? Invalidation? TTL? |
| **Observability** | Logging requirements? Metrics? Health check endpoint? |
| **Data migration** | Schema changes needed? Migration strategy? Backward compatibility? |

---

## 6. UI Testing Integration

> Browser automation hook points for Features with user-facing UI.
> Full guide: [reference/ui-testing-integration.md](../reference/ui-testing-integration.md)

| Feature Type | UI Verification | Condition |
|-------------|----------------|-----------|
| Has UI (frontend/fullstack) | Demo URL navigation + Snapshot + element check | Playwright MCP available |
| Backend/API only | Skip (API health check only) | — |
| CLI/Library | Skip | — |

When Playwright MCP is available during `verify` Phase 3:
- Demo script starts the server → Playwright navigates to demo URL → verifies page loads and key elements exist
- SC-level UI verification: Automatically execute UI Action sequences from Coverage header via MCP
- If not available: HARD STOP — MCP install guide or UI verification Skip

---

## 7. Bug Prevention Rules

> Per-stage bug prevention rules. See each stage's injection file for details.

| Stage | Checks | Reference |
|------|----------|------|
| **plan (B-1)** | Runtime Compatibility, State Management Anti-patterns, Async & Concurrency, Dependency Safety | `injection/plan.md` § Bug Prevention |
| **analyze (B-2)** | Cross-Feature Data Flow, Nullable Field Tracking | `injection/analyze.md` § Bug Prevention |
| **implement (B-3)** | IPC Boundary Safety, Platform CSS Constraints, Cross-Feature Integration, Data Persistence Safety | `injection/implement.md` § Bug Prevention |
| **verify (B-4)** | Empty State Smoke Test, Smoke Launch Criteria | `verify-phases.md` § Phase 3b |
