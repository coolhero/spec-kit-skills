# Domain Core — Universal Rules

> Loaded for ALL projects regardless of interface, concern, or scenario.
> Contains rules that apply universally across app types.

---

## S1. Demo Pattern

- **Type**: Server-based (default; interfaces may override)
- **Default mode**: Launch dev server with demo data -> print "Try it" instructions (URLs to open, curl commands to run, CLI invocations -- at least 2 concrete instructions) -> keep running until Ctrl+C
- **CI mode**: Quick health check (start server, verify health endpoint, exit with status code)
- **Script location**: `demos/F00N-name.sh` (or `.ts`/`.py`/etc.)
- **"Try it" instructions**: URLs to browse, API endpoints to call, CLI commands to run

> Anti-patterns, code markers, script template, and detailed requirements: see [reference/demo-standard.md](../reference/demo-standard.md).

---

## S2. Parity Dimensions

### Structural Parity

| Category | What to Compare |
|----------|----------------|
| API endpoints | Route definitions, controllers, endpoint decorators -- match original routes |
| DB entities | Schema definitions, model classes -- match original table/collection structure |
| Test files | Test file presence and coverage scope -- match original test coverage |
| Source behaviors | Exported functions, public methods, handlers -- match P1/P2 behaviors from Source Behavior Inventory |

> Interfaces may add dimensions (e.g., gui adds "UI components" parity).

### Logic Parity

| Category | What to Compare |
|----------|----------------|
| Business rules | State transitions, validation rules, authorization checks -- match original business logic |
| Test cases | Test scenario coverage -- original test cases should have equivalents |

---

## S3. Verify Steps

| Step | Required | Detection | Description |
|------|----------|-----------|-------------|
| **Test** | Yes (BLOCKING) | Detect from `package.json` scripts, `pyproject.toml`, `Makefile`, `Cargo.toml` | Run unit + integration tests. Failure blocks pipeline |
| **Build** | Yes (BLOCKING) | Detect build command from project config | Run project build. Failure blocks pipeline |
| **Lint** | Yes (BLOCKING) | Detect per § S3b Lint Tool Detection Rules | Run lint check. Failure blocks pipeline. Tool-not-found is a toolchain issue (non-blocking), not a code quality issue |
| **Demo-Ready** | Conditional (if constitution VI active) | Check `demos/F00N-name.sh` exists | Execute demo script with `--ci` flag. Verify health check passes |

> Concerns may add steps (e.g., i18n adds i18n coverage check).

### S3b. Lint Tool Detection Rules

> Used by Foundation Gate (Toolchain Pre-flight) and verify Phase 1.
> Detection follows a priority order -- the first match wins.

**Node.js / TypeScript** (detected by `package.json` presence):

| Priority | Check | Command |
|----------|-------|---------|
| 1 | `package.json` -> `scripts.lint` field exists | `npm run lint` (or `pnpm run lint` / `yarn lint` per lockfile) |
| 2 | Flat config: `eslint.config.{js,mjs,cjs}` exists | `npx eslint .` |
| 3 | Legacy config: `.eslintrc{,.js,.json,.yml,.yaml}` exists | `npx eslint .` |
| 4 | `biome.json` or `biome.jsonc` exists | `npx biome check .` |
| 5 | None of the above | `not configured` |

**Python** (detected by `pyproject.toml` / `setup.py` / `requirements.txt` presence):

| Priority | Check | Command |
|----------|-------|---------|
| 1 | `pyproject.toml` -> `[tool.ruff]` section exists, or `ruff.toml` / `.ruff.toml` exists | `ruff check .` |
| 2 | `.flake8` exists, or `setup.cfg` with `[flake8]` section | `flake8 .` |
| 3 | None of the above | `not configured` |

**Go** (detected by `go.mod` presence):
- `.golangci.yml` / `.golangci.yaml` exists -> `golangci-lint run`
- Fallback: `go vet ./...` (built-in, always available)

**Rust** (detected by `Cargo.toml` presence):
- `cargo clippy -- -D warnings` (clippy is a standard rustup component)
- If not installed: `not installed -- run: rustup component add clippy`

**Executable verification**: After detecting the lint command, verify the tool is actually runnable:
- Run `[tool] --version` (e.g., `npx eslint --version`, `ruff --version`) -> exit 0 = available
- Exit != 0 or "command not found" -> not installed

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

## S5. Feature Elaboration Probes (Universal)

> Domain-specific additions to the base [Feature Elaboration Framework](../reference/feature-elaboration-framework.md).
> These probes are always asked regardless of interface or concern.
> Interface and concern modules append their own probes.

### Perspective 2 (Capabilities) -- Universal Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| **Authentication & Authorization** | Who can access this? Role-based? Token-based? Session management needed? |
| **CRUD lifecycle** | What are the create/read/update/delete operations? Soft delete or hard delete? Audit trail? |
| **Validation** | Input validation rules? Server-side vs client-side? Error message format? |
| **Pagination & Search** | List views need pagination? Search/filter capabilities? Sort options? |
| **File handling** | File upload/download? Size limits? Allowed formats? Storage location? |

### Perspective 4 (Interfaces) -- Universal Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| **Middleware** | Request middleware needed? (auth, logging, rate limiting, CORS) |

> Interface modules add their own Perspective 4 probes (REST, Routing, UI, etc.)

### Perspective 5 (Quality) -- Universal Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| **Concurrency** | Race conditions possible? Optimistic locking? Idempotency keys? |
| **Caching** | Cache strategy? Invalidation? TTL? |
| **Observability** | Logging requirements? Metrics? Health check endpoint? |
| **Data migration** | Schema changes needed? Migration strategy? Backward compatibility? |

---

## S7. Bug Prevention Rules (Index)

> Per-stage bug prevention rules. See each stage's injection file for details.
> Concerns and interfaces add activation conditions to these rules.

| Stage | Checks | Reference |
|-------|--------|-----------|
| **plan (B-1)** | Runtime Compatibility, State Management Anti-patterns, Async & Concurrency, Dependency Safety | `injection/plan.md` § Bug Prevention |
| **analyze (B-2)** | Cross-Feature Data Flow, Nullable Field Tracking | `injection/analyze.md` § Bug Prevention |
| **implement (B-3)** | See active interface/concern modules for applicable rules | `injection/implement.md` § Bug Prevention |
| **verify (B-4)** | Empty State Smoke Test, Smoke Launch Criteria | `verify-phases.md` § Phase 3b |

### Universal B-3 Rules (always active)

- **Cross-Feature Integration**: Data shape contracts between provider and consumer Features
- **Data Persistence Safety**: Verify data survives restart, check storage paths

### Conditional B-3 Rules (active only when corresponding module is loaded)

| Rule | Activating Module | Reference |
|------|-------------------|-----------|
| IPC Boundary Safety | `concerns/ipc` | `injection/implement.md` § Bug Prevention B-3 |
| IPC Return Value Defense | `concerns/ipc` | `injection/implement.md` § Bug Prevention B-3 |
| Platform CSS Rendering | `interfaces/gui` | `injection/implement.md` § Bug Prevention B-3 |
| UI Interaction Surface Audit | `interfaces/gui` | `injection/implement.md` § Bug Prevention B-3 |
| SDK Type Trust Classification | `concerns/external-sdk` | `injection/implement.md` § Bug Prevention B-3 |
| SDK API Contract Gap | `concerns/external-sdk` | `injection/implement.md` § Bug Prevention B-3 |
| i18n Completeness Check | `concerns/i18n` | `injection/implement.md` § Step 1b |
