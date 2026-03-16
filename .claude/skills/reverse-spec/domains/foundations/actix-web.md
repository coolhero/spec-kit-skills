# Foundation: Actix-web

> Server framework Foundation for Rust projects using Actix-web.
> High-performance async web framework built on Tokio with type-safe extractors and actor model heritage.

---

## F0. Detection Signals

| Signal | Confidence |
|--------|-----------|
| `actix-web` in `Cargo.toml` `[dependencies]` | HIGH |
| `#[actix_web::main]` or `HttpServer::new` in main.rs | HIGH |
| `web::get()`, `web::resource()`, `web::scope()` | MEDIUM |
| `actix-rt` or `actix-service` in dependencies | MEDIUM |

---

## F1. Categories

| Code | Category | Description |
|------|----------|-------------|
| BST | App Bootstrap | HttpServer config, App factory, TLS, workers |
| SEC | Security | actix-identity, actix-session, JWT middleware, CORS |
| MID | Middleware | Transform/Service trait pattern, middleware ordering |
| API | API Design | Routing macros, extractors (Path/Query/Json), OpenAPI via utoipa |
| DBS | Database | Diesel vs SQLx vs SeaORM, connection pool (r2d2/deadpool), migrations |
| PRC | Process Management | Graceful shutdown, worker threads, Tokio runtime config |
| HLT | Health Check | Health endpoint, readiness check |
| ERR | Error Handling | ResponseError trait, custom error types, error response format |
| LOG | Logging | tracing + tracing-actix-web, env_logger, structured logging |
| TST | Testing | actix-web test utilities, TestApp, integration tests |
| BLD | Build & Deploy | cargo build --release, Docker multi-stage, cross-compilation |
| ENV | Environment Config | dotenvy, config crate, compile-time env (env!) |

---

## F2. Decision Items

### BST — App Bootstrap
| ID | Item | Priority | Question |
|----|------|----------|----------|
| AW-BST-01 | Worker count | Critical | `HttpServer::new().workers(N)` — CPU-bound or custom? |
| AW-BST-02 | TLS | Important | rustls? native-tls? Terminate at reverse proxy? |
| AW-BST-03 | App state | Critical | `web::Data<T>` shared state? Arc<Mutex<T>> or lock-free? |

### SEC — Security
| ID | Item | Priority | Question |
|----|------|----------|----------|
| AW-SEC-01 | Auth middleware | Critical | Custom JWT extractor? actix-identity? Session-based? |
| AW-SEC-02 | CORS | Important | `actix-cors` Cors::default() or custom config? |

### API — API Design
| ID | Item | Priority | Question |
|----|------|----------|----------|
| AW-API-01 | Route style | Critical | Macro-based (`#[get("/path")]`) or programmatic (`web::resource()`)? |
| AW-API-02 | Extractors | Critical | Which extractors? Custom extractor implementations? |
| AW-API-03 | OpenAPI | Optional | utoipa for auto-generated OpenAPI? paperclip? |

### DBS — Database
| ID | Item | Priority | Question |
|----|------|----------|----------|
| AW-DBS-01 | ORM/query | Critical | Diesel (sync)? SQLx (async)? SeaORM (async ORM)? |
| AW-DBS-02 | Connection pool | Critical | r2d2 (Diesel)? deadpool (SQLx)? bb8? |
| AW-DBS-03 | Migrations | Important | diesel_migrations? sqlx migrate? sea-orm-migration? |

### TST — Testing
| ID | Item | Priority | Question |
|----|------|----------|----------|
| AW-TST-01 | Test style | Critical | `actix_web::test::TestRequest`? TestApp with full server? |
| AW-TST-02 | DB testing | Important | Test database per run? Transaction rollback? |

### BLD — Build & Deploy
| ID | Item | Priority | Question |
|----|------|----------|----------|
| AW-BLD-01 | Release profile | Important | `--release` optimizations? LTO? strip? |
| AW-BLD-02 | Docker | Important | Multi-stage build (builder + runtime)? Alpine or Debian? |

---

## F7. Philosophy

| Principle | Description | Impact |
|-----------|-------------|--------|
| **Type-Safe Extractors** | Request data is validated at compile time via typed extractors | Use strongly-typed extractors; avoid manual parsing from raw request |
| **Actor Model Heritage** | Actix ecosystem provides actor primitives for concurrent state | Consider actors for stateful services; use `web::Data` for shared state |
| **Zero-Cost Abstractions** | Rust guarantees no runtime overhead for abstractions | Don't avoid abstractions for performance; the compiler optimizes them |
| **Async-First** | Built on Tokio; all handlers are async by default | Never block the async runtime; use `web::block()` for CPU-bound work |

---

## F8. Toolchain Commands

| Field | Command |
|-------|---------|
| `build` | `cargo build --release` |
| `test` | `cargo test` |
| `lint` | `cargo clippy -- -D warnings` |
| `package_manager` | `cargo` |

---

## F9. Scan Targets

#### Data Model
| Pattern | Description |
|---------|-------------|
| Diesel `table!` macro invocations | Table schema definitions |
| SQLx `#[derive(FromRow)]` structs | Query result mapping |
| SeaORM `#[derive(DeriveEntityModel)]` | Entity definitions |
| `migrations/` directory with SQL files | Schema evolution |

#### API Endpoints
| Pattern | Description |
|---------|-------------|
| `#[get("...")]`, `#[post("...")]`, `#[put("...")]`, `#[delete("...")]` | Route handler macros |
| `web::resource("...").route(web::get().to(handler))` | Programmatic route definitions |
| `web::scope("...").service(...)` | Scoped route groups |
