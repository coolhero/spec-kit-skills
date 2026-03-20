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

### Additional SC Pattern Categories (activated by Scale modifier)

When the project's Scale modifier indicates these categories should be active, apply them during SC generation:

| Category | When to Activate | Pattern Template | Anti-pattern |
|----------|-----------------|------------------|-------------|
| **Performance** | `production` maturity OR explicit performance FR | `SC-xxx: [operation] completes within [N]ms/s for [load profile]` | `SC: system is fast` (unmeasurable) |
| **Resource** | `production` maturity AND server/infra Feature | `SC-xxx: [resource] usage stays below [threshold] under [concurrent load]` | `SC: memory usage is reasonable` (vague) |
| **Build** | Foundation axis active AND build-affecting FR | `SC-xxx: [build target] compiles/bundles in < [N]s on [reference hardware]` | `SC: build works` (binary, no target) |
| **Reliability** | `production` maturity AND distributed/async Feature | `SC-xxx: [operation] succeeds ≥[N]% under [failure condition]` | `SC: system is reliable` (unmeasurable) |

**Scale guard**: `prototype` → these categories disabled (focus on functional correctness). `mvp` → Performance only for user-facing latency. `production` → all categories active based on Feature characteristics.

These are **universal patterns** — framework-independent. The specific metrics and thresholds are determined during specify based on the Feature's FR requirements.

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

**Java** (detected by `pom.xml` / `build.gradle` / `build.gradle.kts` presence):

| Priority | Check | Command |
|----------|-------|---------|
| 1 | `pom.xml` with `maven-checkstyle-plugin` or `checkstyle.xml` exists | `./mvnw checkstyle:check` (or `mvn checkstyle:check`) |
| 2 | `build.gradle` with `checkstyle` plugin or `checkstyle.xml` exists | `./gradlew checkstyleMain` |
| 3 | `spotbugs` plugin in build file | `./gradlew spotbugsMain` or `mvn spotbugs:check` |
| 4 | None of the above | `not configured` |

**Kotlin** (detected by `build.gradle.kts` with `kotlin` plugin):

| Priority | Check | Command |
|----------|-------|---------|
| 1 | `.editorconfig` with ktlint rules or `ktlint` in build plugins | `./gradlew ktlintCheck` |
| 2 | `detekt.yml` exists or `detekt` plugin in `build.gradle.kts` | `./gradlew detekt` |
| 3 | None of the above | `not configured` |

**Ruby** (detected by `Gemfile` presence):

| Priority | Check | Command |
|----------|-------|---------|
| 1 | `.rubocop.yml` exists or `rubocop` in Gemfile | `bundle exec rubocop` |
| 2 | `standard` in Gemfile | `bundle exec standardrb` |
| 3 | None of the above | `not configured` |

**PHP** (detected by `composer.json` presence):

| Priority | Check | Command |
|----------|-------|---------|
| 1 | `phpstan.neon` or `phpstan.neon.dist` exists | `vendor/bin/phpstan analyse` |
| 2 | `phpcs.xml` or `.phpcs.xml` exists | `vendor/bin/phpcs` |
| 3 | `pint.json` exists or `laravel/pint` in composer.json | `vendor/bin/pint --test` |
| 4 | None of the above | `not configured` |

**Elixir** (detected by `mix.exs` presence):

| Priority | Check | Command |
|----------|-------|---------|
| 1 | `.credo.exs` exists or `:credo` in deps | `mix credo --strict` |
| 2 | `:dialyxir` in deps | `mix dialyzer` |
| 3 | None of the above | `not configured` |

**C# / .NET** (detected by `*.csproj` / `*.sln` presence):

| Priority | Check | Command |
|----------|-------|---------|
| 1 | `.editorconfig` with C# rules or `Directory.Build.props` with analyzers | `dotnet format --verify-no-changes` |
| 2 | Roslyn analyzers in `.csproj` (`PackageReference` for `Microsoft.CodeAnalysis.*`) | `dotnet build /p:TreatWarningsAsErrors=true` |
| 3 | None of the above | `dotnet format --verify-no-changes` (built-in with .NET SDK 6+) |

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
| Checkstyle | (Maven/Gradle plugin — configured in build file) |
| ktlint | (Gradle plugin — configured in build file) |
| detekt | (Gradle plugin — configured in build file) |
| RuboCop | `gem install rubocop` or add to Gemfile |
| PHPStan | `composer require --dev phpstan/phpstan` |
| PHP_CodeSniffer | `composer require --dev squizlabs/php_codesniffer` |
| Laravel Pint | `composer require --dev laravel/pint` |
| Credo | Add `{:credo, "~> 1.7", only: [:dev, :test]}` to mix.exs |
| dialyxir | Add `{:dialyxir, "~> 1.4", only: [:dev], runtime: false}` to mix.exs |
| dotnet format | Built-in with .NET SDK 6+ |

### Limited Verification

When external dependencies (third-party APIs, paid services, hardware) block test/demo execution:
- User can select "Acknowledge limited verification" at the verify Checkpoint
- Status recorded as `limited` instead of `success`
- Merge step accepts `limited` status with warning

**S3d. Foundation Compliance** (T0 Features only):
- For each decided Foundation item with `Priority: Critical`:
  - Verify implementation matches recorded decision
  - Check: config file value, code pattern, dependency presence
- Result: PASS (all match) / WARN (minor drift) / FAIL (critical mismatch)
- FAIL → Source Modification Gate applies

---

## S4. Data Integrity Principles (Universal)

> These principles apply to ALL projects regardless of interface, concern, or scenario.
> They are checked at multiple pipeline stages: specify (FR coverage), plan (architecture), implement (code), verify (runtime).

### S4a. Data Authority (Single Source of Truth)

Every piece of persistent data must have exactly ONE authoritative source. All other copies are caches with explicit invalidation strategies.

**Pipeline impact**:
- **plan**: data-model.md must designate authority per entity (e.g., "server-owned", "client-owned", "shared with conflict resolution")
- **implement**: if authority is server/main-process, client-side persistence (localStorage, Zustand persist) must NOT include authority-owned fields — or must have explicit sync/invalidation
- **verify**: data round-trip test must confirm authority source is consistent after restart

```
❌ WRONG: Main process owns KB list, but Zustand persist stores bases[] in localStorage
   → App restart: localStorage has stale KB list, main process has fresh one → conflict
✅ RIGHT: Main process owns KB list, renderer calls hydrate() on mount → always fresh
```

### S4b. Empty/Invalid Input Handling

No pipeline stage should treat empty or invalid input as success.

**Pipeline impact**:
- **specify**: Each data-processing FR must have an SC for "empty input → explicit error, not silent success"
- **implement**: Every processing function must check input validity before marking status as "completed"
- **verify**: Sanity check with empty/minimal input must produce error or skip, never "success with 0 results"

```
❌ WRONG: File has 0 extractable text → 0 chunks → embedding skipped → status: "completed" ✅
✅ RIGHT: File has 0 extractable text → status: "failed" with reason "No text extracted"
```

### S4c. Data Pipeline Traceability

For any Feature that processes data through multiple stages, every stage must be identifiable and verifiable independently.

**Pipeline impact**:
- **specify**: FRs must cover each pipeline stage, not just the end result. "File embedding" is not one FR — it's input→extract→chunk→embed→store→search→display, each a verifiable step.
- **plan**: Architecture must show the data flow with each transformation stage named.
- **implement**: Each stage should produce observable output (logs, status, intermediate results).
- **verify**: E2E verification traces data through all stages, not just "input → final output OK".

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
| **verify (B-4)** | Process Lifecycle Protocol, Dev Mode Stability Probe, Empty State Smoke Test, Smoke Launch Criteria | `verify-phases.md` § Process Lifecycle, Phase 0-2c, Phase 3b |

### Universal B-3 Rules (always active)

- **Cross-Feature Integration**: Data shape contracts between provider and consumer Features
- **Data Persistence Safety**: Verify data survives restart, check storage paths
- **Module-scope Lifecycle Dependency**: Code that executes at module import time must not depend on runtime lifecycle state (app ready, DOM ready, server initialized, config loaded). Common anti-pattern: `export const service = new Service()` where the constructor calls APIs that require prior initialization (e.g., filesystem paths, window dimensions, database connections, environment variables loaded at startup). These work when the module happens to load after initialization but crash when import order changes — which differs between dev mode (native ESM, HMR) and production builds (bundled, tree-shaken). Fix: lazy initialization (`getInstance()` pattern) or deferred setup (`init()` called explicitly after lifecycle gate). Detect during implement by scanning for `export const|let` combined with `new` + constructor side effects

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
| MQ Message Loss on Crash | `concerns/message-queue` | `concerns/message-queue.md` § S7 MQ-001 |
| MQ Poison Message Loop | `concerns/message-queue` | `concerns/message-queue.md` § S7 MQ-003 |
| TW Zombie Task Detection | `concerns/task-worker` | `concerns/task-worker.md` § S7 TW-002 |
| TW Schedule Overlap | `concerns/task-worker` | `concerns/task-worker.md` § S7 TW-004 |

---

## S9. Brief Completion Criteria (Universal)

> Base Brief completion criteria that apply to ALL projects. Interface, concern, and archetype modules append domain-specific criteria.
> Checked during `/smart-sdd add` Phase 1 (Briefing) after the six-perspective framework evaluation.

| Required Element | Completion Signal |
|-----------------|-------------------|
| Feature name and description | 1-2 sentence description that a new team member could understand |
| At least one user-facing capability | Concrete verb: "user can create/search/configure/export X" |
| Owned entity identification | At least one entity this Feature is responsible for (CRUD authority) |
| Dependency direction | Clear statement of what this Feature depends on and what depends on it (or "standalone") |

> These are the **minimum universal** criteria. Domain modules add project-type-specific criteria via their own S9/A5 sections.
