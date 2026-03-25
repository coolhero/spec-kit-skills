# Foundation Resolution Protocol

The Platform Foundation layer ensures framework-specific infrastructure decisions are made **before** business Features begin. This file defines the shared protocol used by all Foundation files.

---

## F0. Framework Detection Signals

Identify the primary framework(s) from project files:

| Framework | Detection Signals |
|-----------|------------------|
| Electron | `electron` in package.json dependencies + `main` field pointing to .js + `BrowserWindow` imports |
| Tauri | `tauri.conf.json` present OR `Cargo.toml` with `tauri` dependency |
| Express | `express` in package.json dependencies + `app.listen()` or `createServer` pattern |
| Next.js | `next` in package.json dependencies + `next.config.*` file |
| Vite + React | `vite` + `react` in dependencies, NO `next` dependency |
| NestJS | `@nestjs/core` in package.json dependencies |
| FastAPI | `fastapi` in pyproject.toml or requirements.txt + `uvicorn` or `gunicorn` |
| React Native | `react-native` in package.json dependencies + `metro.config.*` or `app.json` with `expo` |
| Flutter | `pubspec.yaml` with `flutter` SDK dependency |
| Bun | `bun.lockb` present OR `bun` in `package.json` `packageManager` field OR `bunfig.toml` |
| Solid.js | `solid-js` in package.json dependencies + `.tsx`/`.jsx` files with `createSignal` imports |
| Hono | `hono` in package.json dependencies + route handler patterns (`app.get()`, `app.post()`) |
| Spring Boot | `spring-boot-starter-*` in `pom.xml`/`build.gradle` + `@SpringBootApplication` |
| Django | `django` in `requirements.txt`/`pyproject.toml` + `manage.py` + `settings.py` with `INSTALLED_APPS` |
| Rails | `rails` in Gemfile + `config/application.rb` + `bin/rails` |
| Flask | `flask` in `requirements.txt`/`pyproject.toml` + `Flask(__name__)` factory pattern |
| Actix-web | `actix-web` in `Cargo.toml` + `HttpServer::new` or `#[actix_web::main]` |
| Go Chi/Gin | `go-chi/chi` or `gin-gonic/gin` in `go.mod` + router initialization pattern |
| ASP.NET Core | `*.csproj` with `Microsoft.AspNetCore.*` + `WebApplication.CreateBuilder` in `Program.cs` |
| Laravel | `laravel/framework` in `composer.json` + `artisan` + `routes/api.php` |
| Phoenix | `:phoenix` in `mix.exs` deps + `lib/*_web/` + `router.ex` with `scope`/`pipe_through` |
| Chrome Extension | `manifest.json` with `"manifest_version": 3` (or 2) + `chrome.runtime`/`chrome.tabs` keywords |
| Rust (Cargo) | `Cargo.toml` in root + `.rs` source files (standalone — without actix-web/tauri-specific signals) |
| Svelte | `svelte` in dependencies + `.svelte` files + `svelte.config.*` |
| Spring Framework | `spring-context`/`spring-web` in `pom.xml`/`build.gradle` WITHOUT `spring-boot-starter-*` + XML config OR `@Configuration` with `@Bean` |
| Swift (SPM) | `Package.swift` in root + `.swift` source files |
| iOS (Xcode) | `.xcodeproj` or `.xcworkspace` + `Info.plist` |
| Android Native | `build.gradle` with `com.android.application`/`com.android.library` + `AndroidManifest.xml` |
| Nuxt | `nuxt` in package.json deps + `nuxt.config.*` |
| Angular | `@angular/core` in deps + `angular.json` |
| Remix | `@remix-run/react` in deps |
| Qwik | `@builder.io/qwik` in deps |
| Symfony | `symfony/framework-bundle` in `composer.json` + `config/bundles.php` |
| WordPress | `wp-config.php` + `wp-content/` directory |
| Erlang/OTP | `rebar.config` or `.app.src` + `-behaviour` declarations |
| Qt | `Q_OBJECT` macro or `qt_add_qml_module` in CMake + `.ui`/`.qml` files |
| GTK | `gtk_init` or `GtkApplication` + `.glade` files or `meson.build` with gtk dep |
| Bazel | `BUILD.bazel` + `WORKSPACE` or `MODULE.bazel` in root |
| SBT (Scala) | `build.sbt` + `.scala` source files |

**Multiple frameworks**: A project may use multiple frameworks (e.g., Express backend + React frontend). Detect all, load Foundation files for each. Comma-separate in `**Framework**` field.

**Priority**: If multiple signals conflict, prioritize by specificity (e.g., Next.js over plain React, NestJS over Express).

**Monorepo detection**: If root `package.json` contains `workspaces` field, OR `turbo.json`/`nx.json`/`lerna.json` exists, classify as monorepo. Scan each workspace package for individual framework detection. Record all detected frameworks comma-separated in `**Framework**` field.

**Python Monorepo Signals** (any 2+ = Python monorepo):
- Multiple `pyproject.toml` files in subdirectories
- `uv.lock` + `[tool.uv.workspace]` in root pyproject.toml
- `poetry.lock` with `[tool.poetry.packages]` referencing subdirs
- `hatch.toml` or `[tool.hatch.envs]` with multiple environments
- Pants/Bazel BUILD files with Python targets

**Rust Workspace Signals**:
- Root `Cargo.toml` with `[workspace]` section and `members = [...]`
- Multiple `Cargo.toml` files in subdirectories (crates)

**Go Workspace Signals**:
- `go.work` file in root (Go 1.18+ multi-module workspace)
- Multiple `go.mod` files in subdirectories

**Java/Maven Multi-Module Signals**:
- Parent `pom.xml` with `<modules>` section listing child modules
- Multiple `pom.xml` files in subdirectories with `<parent>` referencing root
- `<dependencyManagement>` in parent POM (BOM pattern)
- Root `pom.xml` with `<packaging>pom</packaging>`

**Java/Gradle Multi-Module Signals**:
- `settings.gradle` or `settings.gradle.kts` with `include` statements (e.g., `include ':module-a', ':module-b'`)
- Multiple `build.gradle` or `build.gradle.kts` files in subdirectories
- Root `build.gradle` with `subprojects {}` or `allprojects {}` blocks
- `buildSrc/` directory (custom plugin/convention code)

---

## F1. Foundation Category Taxonomy

### Universal Categories (all frameworks)

| Code | Category | Description |
|------|----------|-------------|
| BST | App Bootstrap | Application entry point, initialization sequence, lifecycle events |
| SEC | Security | Authentication, authorization, CSP, input sanitization, secrets management |
| ERR | Error Handling | Error capture, propagation, user-facing error strategy, crash recovery |
| LOG | Logging & Monitoring | Logging library, format, levels, crash reporting, APM integration |
| TST | Testing | Test framework, strategy (unit/integration/e2e), fixtures, coverage targets |
| BLD | Build & Deploy | Build tool, packaging, CI/CD, code signing, distribution |
| ENV | Environment Config | Environment variables, config management, secrets, multi-env strategy |
| DXP | Developer Experience | Linting, formatting, dev server, debugging tools, path aliases |

### Desktop-specific Categories (Electron, Tauri)

| Code | Category | Description |
|------|----------|-------------|
| WIN | Window Management | Window frame, multi-window, state persistence, process model |
| IPC | Inter-Process Communication | Main-renderer communication pattern, channel design, preload strategy |
| NAT | Native Integration | Menus, tray, notifications, drag-drop, clipboard, shortcuts, file dialogs |
| UPD | Auto-update | Update mechanism, server, UX (silent/prompt/forced), signing |
| DLK | Deep Linking & File Associations | Protocol handler, custom schemes, file type registration |
| STR | Storage | Persistent storage, session management, proxy settings |

### Server-specific Categories (Express, NestJS, FastAPI, Spring Boot, Django, Rails, Flask, Actix-web, Go Chi, ASP.NET Core, Laravel, Phoenix)

| Code | Category | Description |
|------|----------|-------------|
| MID | Middleware | Middleware chain order, global middleware, request processing pipeline |
| API | API Design | Versioning, route organization, pagination, documentation (OpenAPI/Swagger) |
| DBS | Database | ORM/query builder, connection pool, migrations, session management |
| PRC | Process Management | Graceful shutdown, clustering, process manager, worker configuration |
| HLT | Health Check | Health/readiness/liveness endpoints, health indicators |

### Frontend-specific Categories (Next.js, Vite+React)

| Code | Category | Description |
|------|----------|-------------|
| REN | Rendering Strategy | SSR/SSG/ISR/CSR strategy, caching, output mode |
| ROU | Routing | Router type, route organization, lazy loading, code splitting |
| STM | State Management | Client state library, server state/data fetching, form handling |
| STY | Styling | CSS strategy, component library, theme configuration |
| SEO | SEO & Metadata | Metadata strategy, sitemap, robots.txt, Open Graph |
| DTA | Data & Assets | Static assets, data fetching, image optimization, bundling strategy |

### Mobile-specific Categories (React Native, Flutter)

| Code | Category | Description |
|------|----------|-------------|
| PRM | Permissions | Device permission strategy, request timing, rationale UX |
| PSH | Push Notifications | Push service, local notifications, notification handling |
| STO | App Store & Distribution | Code signing, build automation, store submission, OTA updates |
| HWR | Hardware Access | Camera, maps, biometrics, file system, sensors |
| OFL | Offline & Background | Offline storage, background tasks, sync strategy |

---

## F2. Foundation Resolution Protocol

When a project's framework is identified, resolve the Foundation checklist:

```
1. Read **Framework** from sdd-state.md (or detect from code)
2. Check: Does `foundations/{framework}.md` exist?
   │
   ├─ YES → Case A: Load full Foundation (all F2 items)
   │
   ├─ NO + framework name known → Case B: Generic Foundation
   │  (universal categories only + agent probes)
   │
   └─ NO + framework unknown → Case D: Skip Foundation
      Record `Framework: custom` in sdd-state.md
```

### Case Matrix

| Case | Profile | Framework | Foundation Behavior |
|------|---------|-----------|-------------------|
| A | Matched | Foundation file exists | Full flow: load checklist, extract/present items, generate T0 Features |
| B | Matched | No Foundation file | Generic Foundation: universal categories (BST/SEC/ERR/LOG/TST/BLD/ENV/DXP). Agent supplements with framework knowledge. No auto-generated T0 Features |
| C | No match | Framework known | Create custom profile (existing flow). Apply Case A or B for Foundation |
| D | No match | Framework unknown | Create custom profile. Skip Foundation entirely. `Framework: custom` |

### Generic Foundation Protocol (Case B)

When a framework is detected but has no Foundation file (e.g., Remix, Svelte, Nuxt):

1. Load universal categories from this file (§ F1 Universal Categories)
2. For each universal category, present **generic probes** to user:

| Category | Probe Question |
|----------|---------------|
| BST | How does the app bootstrap? Entry point / factory pattern / framework CLI? |
| SEC | What security measures are needed? Auth strategy / CORS / CSP? |
| ERR | Error handling strategy? Global handler / crash reporting / error boundary? |
| LOG | Logging approach? Library / format / levels? |
| TST | Testing setup? Framework / strategy / fixtures? |
| BLD | Build & deploy? Packaging / CI-CD / code signing? |
| ENV | Environment config? .env / config files / secrets manager? |
| DXP | Developer tooling? Linter / formatter / dev server? |

3. Record responses in sdd-state.md Foundation Decisions (same format as Case A)
4. **No T0 Features auto-generated** — user chooses whether Foundation work needs dedicated Features
5. Display: `No Foundation checklist for {framework}. Universal categories applied. Consider contributing a Foundation file.`

---

### BST Verification Gate (verify Phase 1)

The following BST items are verified at verify Phase 1. If ANY fails, Phase 1 is INCOMPLETE:

| BST Item | Verify Check | If Missing |
|----------|-------------|------------|
| TypeScript strict | `npx tsc --noEmit` exits 0 | BLOCKING — return to implement |
| Linter installed + configured | `npm run lint` exits 0 (not "command not found") | ⚠️ WARNING — lint not installed means no style enforcement. Report in verify-report. If F001 (Foundation), this is a **spec gap** — lint should be in F001 spec. |
| Formatter configured | `.prettierrc` or equivalent exists | ⚠️ WARNING |
| Test runner configured | `npm test` runs (not "no tests found") | BLOCKING — return to implement |

> **Why lint is not BLOCKING for non-Foundation Features**: If F001 didn't set up lint, subsequent Features can't be blocked for it. But F001 itself SHOULD include lint — this is an F2 checklist item. The verify-report must note "Lint: skipped (not installed)" so the project owner is aware.

---

## F3. T0 Feature Grouping Rules

Foundation categories map to T0 Features in the pipeline. T0 Features are processed **before** T1.

### Grouping Rules

1. Each Foundation category with >= 1 Critical-priority item requiring code implementation becomes a **T0 Feature candidate**
2. Related categories may be merged into a single T0 Feature for manageability:
   - Desktop: WIN + IPC → "Core Window & IPC Architecture", NAT → "Native Integration", UPD + DLK → "Updates & Deep Linking"
   - Server: MID + API → "Request Pipeline & API Design", DBS → "Database Layer", PRC + HLT → "Process Management & Health"
   - Frontend: REN + ROU → "Rendering & Routing", STM → "State Management", STY + SEO → "Styling & SEO"
   - Mobile: PRM + PSH → "Permissions & Notifications", STO → "Distribution & Updates", HWR + OFL → "Hardware & Offline"
3. Universal categories (BST/SEC/ERR/LOG/TST/BLD/ENV/DXP) are grouped into 2 T0 Features:
   - "App Bootstrap & Security" (BST + SEC + ENV)
   - "Error Handling, Logging & Build" (ERR + LOG + BLD + TST + DXP)
4. Total T0 Features per project: typically 4-8 depending on framework

### T0 Feature ID Format

T0 Features use `F000-{slug}` prefix to sort before F001+ (T1):

```
F000-core-window-ipc          (desktop)
F000-native-integration        (desktop)
F000-request-pipeline-api      (server)
F000-database-layer            (server)
F000-rendering-routing         (frontend)
F000-app-bootstrap-security    (universal)
F000-error-logging-build       (universal)
```

### T0 Processing Order

Within T0, process Features by dependency:
1. BST + SEC + ENV (bootstrap must come first)
2. ERR + LOG (error/logging depends on bootstrap)
3. Framework-specific categories (depend on bootstrap + error handling)
4. BLD + TST + DXP (build/test configured after implementation decisions)

---

## F4. Foundation ID Format

Each Foundation item has a globally unique ID:

```
{FW}-{CAT}-{NN}
```

| Component | Description | Example |
|-----------|-------------|---------|
| FW | Framework code (2-3 chars) | EL (Electron), TA (Tauri), EX (Express), NX (Next.js), VR (Vite+React), NE (NestJS), FA (FastAPI), RN (React Native), FL (Flutter), BU (Bun), SO (Solid.js), HO (Hono), SB (Spring Boot), SF (Spring Framework), DJ (Django), RL (Rails), FK (Flask), AW (Actix-web), GC (Go Chi), DN (ASP.NET Core), LV (Laravel), PX (Phoenix), CE (Chrome Extension), RC (Rust/Cargo), SV (Svelte), SW (Swift/SPM), AG (Angular), NU (Nuxt), RX (Remix), QK (Qwik), SY (Symfony), WP (WordPress), ER (Erlang/OTP), QT (Qt), GK (GTK), BZ (Bazel) |
| CAT | Category code from § F1 | WIN, SEC, IPC, MID, REN, etc. |
| NN | Sequential number (01-99) | 01, 02, 03, ... |

**Examples**: `EL-WIN-01` (Electron single-instance lock), `EX-MID-04` (Express middleware chain order), `NX-REN-01` (Next.js router type)

---

## F5. Cross-Framework Carry-over Map

When a rebuild changes the framework (e.g., Express to NestJS), Foundation decisions must be evaluated for preservation.

### Migration Classifications

| Classification | Meaning | Action |
|---------------|---------|--------|
| **Carry-over** | Decision applies identically in new framework | Auto-migrate value (e.g., JWT auth strategy, CORS origins, log format) |
| **Equivalent** | Corresponding concept exists but different implementation | Map old to new, present to user for confirmation |
| **Irrelevant** | Decision doesn't apply to new framework | Mark as N/A |
| **New** | Decision needed in new framework but didn't exist in old | Present as new item for user to decide |

### Universal Category Carry-over

Universal categories (BST/SEC/ERR/LOG/TST/BLD/ENV/DXP) are **always carry-over candidates** across ANY framework pair:

| Category | Typical Carry-over Items |
|----------|------------------------|
| SEC | Auth strategy (JWT/session/OAuth), CORS policy, CSP headers |
| LOG | Log format (JSON/text), log levels, crash reporting service |
| ERR | Error response format, global error handler pattern |
| ENV | Environment variable naming, config management approach |
| TST | Test framework preference, coverage targets |
| BLD | CI/CD pipeline, code signing certificates |

### Common Framework Pair Mappings

**Express to NestJS**:

| Type | Items |
|------|-------|
| Carry-over | Auth strategy, CORS origins, log format, DB choice, rate limit config |
| Equivalent | Middleware chain → Guards/Interceptors, Route organization → Module structure, express-rate-limit → @nestjs/throttler |
| Irrelevant | Express-specific middleware packages (morgan → nestjs-pino) |

**React SPA (Vite) to Next.js**:

| Type | Items |
|------|-------|
| Carry-over | State management library, component library, CSS strategy, form handling |
| Equivalent | Client-side routing → File-based routing, Error boundary → error.tsx, SPA lazy loading → Route segments |
| Irrelevant | SPA fallback config, dev proxy setup, hash routing |
| New | Rendering strategy (SSR/SSG/ISR), Server Actions, Middleware, SEO/metadata |

**Electron to Tauri**:

| Type | Items |
|------|-------|
| Carry-over | Single-instance lock, deep linking behavior, tray behavior, window state persistence |
| Equivalent | IPC (contextBridge → Tauri commands), Auto-update (electron-updater → tauri-updater), App packaging (electron-builder → Tauri bundler) |
| Irrelevant | Node integration, preload scripts, asar packaging, context isolation (Tauri isolates by design) |
| New | Rust backend architecture, capabilities/permissions config, sidecar binaries |

### Migration Protocol

Applied during reverse-spec `analyze.md` Phase 2-4 when `change_scope = "framework"` or `"stack"`:

```
1. Load OLD framework Foundation (from pre-existing code extraction)
2. Load NEW framework Foundation (from target framework file)
3. For each OLD Foundation decision:
   a. Check: Does NEW framework have equivalent category?
      - YES → Classify as Carry-over or Equivalent
      - NO → Classify as Irrelevant
   b. For Carry-over: auto-populate NEW decision with OLD value
   c. For Equivalent: show OLD value + NEW options, ask user
4. For each NEW Foundation item not in OLD:
   - Classify as New, present to user
5. Output: Foundation Migration Table
   | OLD ID | OLD Decision | Migration | NEW ID | NEW Decision | Status |
   Status: auto-migrated / user-confirmed / new-decision / irrelevant
```

---

## F6. Framework Files

Each framework Foundation file in this directory follows the structure defined in the plan:

| File | Framework | Items | Categories | F7 Philosophy | Status |
|------|-----------|-------|-----------|---------------|--------|
| `electron.md` | Electron | 58 | 13 | ✅ | Implemented |
| `tauri.md` | Tauri | 44 | 12 | — | Implemented |
| `express.md` | Express.js | 43 | 13 | ✅ | Implemented |
| `nextjs.md` | Next.js | 44 | 13 | — | Implemented |
| `vite-react.md` | Vite + React | 43 | 12 | — | Implemented |
| `nestjs.md` | NestJS | ~20 | 13 | ✅ | Implemented |
| `fastapi.md` | FastAPI | ~20 | 12 | ✅ | Implemented |
| `react-native.md` | React Native | 50 | 14 | — | TODO scaffold |
| `flutter.md` | Flutter | 50 | 14 | — | TODO scaffold |
| `bun.md` | Bun | — | 8 | ✅ | Implemented |
| `solidjs.md` | Solid.js | — | 5 | ✅ | Implemented |
| `hono.md` | Hono | — | 8 | ✅ | Implemented |
| `spring-boot.md` | Spring Boot | ~35 | 13 | ✅ | Implemented |
| `spring-framework.md` | Spring Framework | — | — | — | Detection stub |
| `django.md` | Django | ~30 | 12 | ✅ | Implemented |
| `rails.md` | Rails | ~30 | 13 | ✅ | Implemented |
| `flask.md` | Flask | ~25 | 12 | ✅ | Implemented |
| `actix-web.md` | Actix-web | ~30 | 12 | ✅ | Implemented |
| `go-chi.md` | Go Chi/Gin | ~30 | 12 | ✅ | Implemented |
| `dotnet.md` | ASP.NET Core | ~30 | 13 | ✅ | Implemented |
| `laravel.md` | Laravel | ~30 | 13 | ✅ | Implemented |
| `phoenix.md` | Phoenix | ~25 | 12 | ✅ | Implemented |
| `chrome-extension.md` | Chrome Extension (MV3) | — | — | — | Detection stub |
| `rust-cargo.md` | Rust (Cargo) | — | — | — | Detection stub |
| `svelte.md` | Svelte | — | — | — | Detection stub |

---

## F7. Framework Philosophy

Optional section in each Foundation file. Defines the philosophical principles that the framework ecosystem advocates — the **opinions** and **values** that should guide architectural decisions when using this framework.

F7 is distinct from F0–F6: while F0–F6 capture **operational decisions** (what to configure, how to structure), F7 captures **guiding principles** (why certain patterns are preferred). F7 principles inform constitution-seed generation and serve as architectural guardrails during the SDD pipeline.

### Schema

| Field | Description |
|-------|-------------|
| **Principle name** | Short identifier (e.g., "Process Isolation", "Middleware Composition") |
| **Description** | What the principle means in practice |
| **Implication** | How this affects architectural decisions in projects using this framework |

### When to Add F7

- Add F7 when the framework has strong, opinionated principles that should guide project architecture
- Skip F7 for frameworks that are intentionally un-opinionated (e.g., Express is minimal but has clear conventions → F7 is warranted)
- Skip F7 for TODO scaffold files — add F7 when the Foundation is fully implemented

### Usage

- **reverse-spec**: F7 principles are extracted alongside F2 items and included in the constitution-seed § "Extracted Architecture Principles"
- **smart-sdd**: F7 principles are referenced during `specify` and `plan` steps to validate architectural decisions against framework conventions

---

## F8. Toolchain Commands

Foundation files MAY declare toolchain commands that the pipeline uses for build, test, and lint. When present, Foundation Gate and Verify Phase 1 use these commands instead of auto-detection.

| Field | Description | Example (Bun) | Example (npm) |
|-------|-------------|---------------|---------------|
| `build` | Build command | `bun run build` | `npm run build` |
| `test` | Test command | `bun test` | `npm test` |
| `lint` | Lint command | `bunx biome check .` | `npx eslint .` |
| `typecheck` | Type check command | `bun run typecheck` | `npx tsc --noEmit` |
| `package_manager` | Package manager binary | `bun` | `npm` |
| `install` | Dependency install command | `bun install` | `npm install` |

**Pipeline integration**:
- Foundation Gate Toolchain Pre-flight reads F8 to determine which commands to probe
- Verify Phase 1 reads F8 to execute build/test/lint
- If F8 is absent, pipeline falls back to auto-detection (npm/yarn/pnpm heuristics)

**Multiple frameworks**: When multiple Foundation files are loaded, F8 from the PRIMARY framework (first in `**Framework**` field) takes precedence for toolchain commands

---

## F9. Scan Targets

Foundation files MAY declare framework-specific scan targets for reverse-spec Phase 2 analysis. This allows new frameworks to participate in data model and API endpoint extraction without modifying `_core.md`.

### Format

```
### F9. Scan Targets

#### Data Model
| Pattern | Description |
|---------|-------------|
| `table()`, `sqliteTable()` in `**/schema.ts` | Drizzle ORM table definitions |
| `defineSchema()` calls | Schema builder pattern |

#### API Endpoints
| Pattern | Description |
|---------|-------------|
| `app.get()`, `app.post()` in route files | Hono/Express-style route handlers |
| `createRoute()` | OpenAPI-compatible route definitions |

#### Component Patterns
| Pattern | Description |
|---------|-------------|
| `createSignal()`, `createEffect()` | Solid.js reactive primitives |
```

**Pipeline integration**:
- reverse-spec Phase 2 (R2 Data Model, R3 API Endpoint extraction) reads F9 from active Foundation files
- F9 scan targets are MERGED with the universal scan targets in `_core.md`
- If F9 is absent, only universal scan targets apply (no loss of functionality)
