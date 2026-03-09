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
| **Lint** | Yes (BLOCKING) | Detect per § 3b Lint Tool Detection Rules | Run lint check. Failure blocks pipeline. Tool-not-found is a toolchain issue (non-blocking), not a code quality issue |
| **Demo-Ready** | Conditional (if constitution VI active) | Check `demos/F00N-name.sh` exists | Execute demo script with `--ci` flag. Verify health check passes |

### 3b. Lint Tool Detection Rules

> Used by Foundation Gate (Toolchain Pre-flight) and verify Phase 1.
> Detection follows a priority order — the first match wins.

**Node.js / TypeScript** (detected by `package.json` presence):

| Priority | Check | Command |
|----------|-------|---------|
| 1 | `package.json` → `scripts.lint` field exists | `npm run lint` (or `pnpm run lint` / `yarn lint` per lockfile) |
| 2 | Flat config: `eslint.config.{js,mjs,cjs}` exists | `npx eslint .` |
| 3 | Legacy config: `.eslintrc{,.js,.json,.yml,.yaml}` exists | `npx eslint .` |
| 4 | `biome.json` or `biome.jsonc` exists | `npx biome check .` |
| 5 | None of the above | `ℹ️ not configured` |

**Python** (detected by `pyproject.toml` / `setup.py` / `requirements.txt` presence):

| Priority | Check | Command |
|----------|-------|---------|
| 1 | `pyproject.toml` → `[tool.ruff]` section exists, or `ruff.toml` / `.ruff.toml` exists | `ruff check .` |
| 2 | `.flake8` exists, or `setup.cfg` with `[flake8]` section | `flake8 .` |
| 3 | None of the above | `ℹ️ not configured` |

**Go** (detected by `go.mod` presence):
- `.golangci.yml` / `.golangci.yaml` exists → `golangci-lint run`
- Fallback: `go vet ./...` (built-in, always available)

**Rust** (detected by `Cargo.toml` presence):
- `cargo clippy -- -D warnings` (clippy is a standard rustup component)
- If not installed: `⚠️ not installed — run: rustup component add clippy`

**Executable verification**: After detecting the lint command, verify the tool is actually runnable:
- Run `[tool] --version` (e.g., `npx eslint --version`, `ruff --version`) → exit 0 = `✅ available`
- Exit ≠ 0 or "command not found" → `⚠️ not installed`

**Install guidance** (displayed when tool is configured but not installed):

| Tool | Install Command |
|------|----------------|
| ESLint | `npm install --save-dev eslint` |
| Biome | `npm install --save-dev @biomejs/biome` |
| ruff | `pip install ruff` (or `uv pip install ruff`) |
| flake8 | `pip install flake8` |
| golangci-lint | `go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest` |
| clippy | `rustup component add clippy` |

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
| **UI Completeness** | Does this Feature manage data users will configure/view? If yes, should a minimal management UI (settings page, list view, config panel) be included in this Feature's scope? |

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
