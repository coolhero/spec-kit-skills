# Foundation: Go HTTP (Chi / Gin / stdlib)

> Server framework Foundation for Go projects using Chi, Gin, Fiber, or stdlib net/http.
> Covers the Go HTTP server ecosystem with emphasis on simplicity, explicit error handling, and composition.

---

## F0. Detection Signals

| Signal | Confidence |
|--------|-----------|
| `go-chi/chi` in `go.mod` | HIGH |
| `gin-gonic/gin` in `go.mod` | HIGH |
| `gofiber/fiber` in `go.mod` | HIGH |
| `net/http` usage with `http.ListenAndServe` or `http.Server` | MEDIUM |
| `chi.NewRouter()` or `gin.Default()` or `fiber.New()` | HIGH |

---

## F1. Categories

| Code | Category | Description |
|------|----------|-------------|
| BST | App Bootstrap | main.go server setup, router initialization, dependency injection (wire/fx) |
| SEC | Security | JWT middleware, OAuth2, CORS, CSRF |
| MID | Middleware | Chi Use/With chain, Gin middleware, stdlib Handler wrapping |
| API | API Design | RESTful routing, URL params, response helpers, OpenAPI (swaggo) |
| DBS | Database | sqlx vs GORM vs ent vs sqlc, connection pool, migrations |
| PRC | Process Management | Graceful shutdown (context.Context), signal handling, goroutines |
| HLT | Health Check | Health/readiness/liveness endpoints |
| ERR | Error Handling | Error return patterns, HTTP error responses, middleware recovery |
| LOG | Logging | zerolog vs zap vs slog (stdlib), structured logging, request ID |
| TST | Testing | go test, httptest, testify, table-driven tests |
| BLD | Build & Deploy | go build, Docker multi-stage, Makefile, CGO considerations |
| ENV | Environment Config | envconfig, viper, godotenv, config structs with tags |

---

## F2. Decision Items

### BST — App Bootstrap
| ID | Item | Priority | Question |
|----|------|----------|----------|
| GC-BST-01 | Router | Critical | Chi? Gin? Fiber? stdlib ServeMux? |
| GC-BST-02 | DI approach | Important | Manual wiring? Wire? Fx? |
| GC-BST-03 | Project layout | Important | Standard Go project layout? Flat? Domain-driven? |

### SEC — Security
| ID | Item | Priority | Question |
|----|------|----------|----------|
| GC-SEC-01 | Auth middleware | Critical | JWT? Session? OAuth2? Custom middleware? |
| GC-SEC-02 | CORS | Important | Chi cors middleware? rs/cors? |

### API — API Design
| ID | Item | Priority | Question |
|----|------|----------|----------|
| GC-API-01 | Route style | Critical | RESTful resource grouping? Versioned routes? |
| GC-API-02 | Response format | Important | Custom response wrapper? Standard JSON? |
| GC-API-03 | OpenAPI | Optional | swaggo/swag for auto-generated docs? |

### DBS — Database
| ID | Item | Priority | Question |
|----|------|----------|----------|
| GC-DBS-01 | DB library | Critical | GORM (ORM)? sqlx (semi-ORM)? ent (graph ORM)? sqlc (code-gen)? |
| GC-DBS-02 | Migrations | Critical | golang-migrate? goose? atlas? |
| GC-DBS-03 | Connection pool | Important | sql.DB pool settings? Max open/idle connections? |

### TST — Testing
| ID | Item | Priority | Question |
|----|------|----------|----------|
| GC-TST-01 | Test style | Critical | stdlib testing + testify? Table-driven tests? |
| GC-TST-02 | HTTP tests | Important | httptest.NewRecorder? httptest.NewServer? |

### BLD — Build & Deploy
| ID | Item | Priority | Question |
|----|------|----------|----------|
| GC-BLD-01 | Build | Critical | `go build` with ldflags (version injection)? Makefile? |
| GC-BLD-02 | Docker | Important | Multi-stage (builder + scratch/alpine)? CGO_ENABLED=0? |

---

## F7. Philosophy

| Principle | Description | Impact |
|-----------|-------------|--------|
| **Simplicity** | Prefer stdlib-adjacent patterns; avoid framework magic | Choose minimal libraries; wrap stdlib types instead of replacing them |
| **Explicit Error Handling** | No exceptions; every error is a returned value | Always check error returns; use sentinel errors or custom error types |
| **Composition over Inheritance** | Interfaces and struct embedding instead of class hierarchies | Define small interfaces; compose via embedding; avoid deep nesting |
| **Goroutine Discipline** | Structured concurrency via context, WaitGroup, errgroup | Always pass context; use errgroup for parallel work; avoid goroutine leaks |

---

## F8. Toolchain Commands

| Field | Command |
|-------|---------|
| `build` | `go build ./...` |
| `test` | `go test ./...` |
| `lint` | `golangci-lint run` |
| `package_manager` | `go mod` |

---

## F9. Scan Targets

#### Data Model
| Pattern | Description |
|---------|-------------|
| GORM model structs with `gorm:"..."` tags | ORM entity definitions |
| ent schema files in `ent/schema/` | Graph ORM schemas |
| sqlc query files (`.sql`) with `-- name:` annotations | SQL query definitions |
| Migration files in `migrations/` or `db/migrations/` | Schema evolution |

#### API Endpoints
| Pattern | Description |
|---------|-------------|
| `r.Get("...")`, `r.Post("...")`, `r.Route("...")` (Chi) | Chi route definitions |
| `r.GET("...")`, `r.POST("...")` (Gin) | Gin route definitions |
| `app.Get("...")`, `app.Post("...")` (Fiber) | Fiber route definitions |
| `http.HandleFunc("...")` (stdlib) | Standard library routes |
