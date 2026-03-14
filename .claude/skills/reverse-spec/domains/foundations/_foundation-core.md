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

**Multiple frameworks**: A project may use multiple frameworks (e.g., Express backend + React frontend). Detect all, load Foundation files for each. Comma-separate in `**Framework**` field.

**Priority**: If multiple signals conflict, prioritize by specificity (e.g., Next.js over plain React, NestJS over Express).

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

### Server-specific Categories (Express, NestJS, FastAPI)

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

When a framework is detected but has no Foundation file (e.g., Django, Spring Boot, Remix):

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
| FW | Framework code (2-3 chars) | EL (Electron), TA (Tauri), EX (Express), NX (Next.js), VR (Vite+React), NE (NestJS), FA (FastAPI), RN (React Native), FL (Flutter) |
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
| `nestjs.md` | NestJS | 51 | 13 | — | TODO scaffold |
| `fastapi.md` | FastAPI | 41 | 12 | — | TODO scaffold |
| `react-native.md` | React Native | 50 | 14 | — | TODO scaffold |
| `flutter.md` | Flutter | 50 | 14 | — | TODO scaffold |

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
