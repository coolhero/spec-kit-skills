# Foundation: Phoenix

> Server framework Foundation for Elixir projects using Phoenix Framework.
> Functional framework built on OTP with real-time capabilities (Channels/LiveView) and fault-tolerant supervision.

---

## F0. Detection Signals

| Signal | Confidence |
|--------|-----------|
| `:phoenix` in `mix.exs` deps | HIGH |
| `lib/*_web/` directory structure | HIGH |
| `router.ex` with `scope` / `pipe_through` / `live` | HIGH |
| `endpoint.ex` with `Plug` pipeline | MEDIUM |

---

## F1. Categories

| Code | Category | Description |
|------|----------|-------------|
| BST | App Bootstrap | application.ex supervision tree, endpoint config, PubSub |
| SEC | Security | phx_gen_auth / Guardian, Plug-based auth, CSRF, CSP |
| MID | Middleware | Plug pipeline, router pipelines, custom plugs |
| API | API Design | Phoenix controllers, LiveView vs API, JSON rendering |
| DBS | Database | Ecto, Repo config, migrations, changesets, multi-tenancy |
| PRC | Process Management | OTP supervision, GenServer, Task.Supervisor, PubSub |
| HLT | Health Check | Health plug, Telemetry health metrics |
| ERR | Error Handling | Fallback controllers, error views, Plug.Exception protocol |
| LOG | Logging | Logger, Telemetry, structured logging, metadata |
| TST | Testing | ExUnit, ConnTest, DataCase, sandbox mode, Mox |
| BLD | Build & Deploy | Mix releases, Docker, fly.io, Distillery |
| ENV | Environment Config | runtime.exs, config/prod.exs, System.get_env at runtime |

---

## F2. Decision Items

### BST — App Bootstrap
| ID | Item | Priority | Question |
|----|------|----------|----------|
| PX-BST-01 | Supervision tree | Critical | Default supervision or custom children (GenServers, workers)? |
| PX-BST-02 | PubSub | Important | Phoenix.PubSub for inter-process messaging? |
| PX-BST-03 | Endpoint config | Important | Static asset serving? Watchers (esbuild/tailwind)? |

### SEC — Security
| ID | Item | Priority | Question |
|----|------|----------|----------|
| PX-SEC-01 | Auth strategy | Critical | phx.gen.auth (built-in)? Guardian (JWT)? Pow? |
| PX-SEC-02 | CSRF | Important | Standard CSRF plug? Exempt for API pipelines? |

### API — API Design
| ID | Item | Priority | Question |
|----|------|----------|----------|
| PX-API-01 | Rendering | Critical | LiveView (server-rendered real-time)? JSON API? Both? |
| PX-API-02 | JSON library | Important | Jason (default)? Custom encoder? |
| PX-API-03 | API pipeline | Important | Separate `:api` pipeline in router? |

### DBS — Database
| ID | Item | Priority | Question |
|----|------|----------|----------|
| PX-DBS-01 | Ecto adapters | Critical | PostgreSQL (default)? MySQL? SQLite? |
| PX-DBS-02 | Changeset patterns | Important | Embedded schemas? Custom validations? |
| PX-DBS-03 | Multi-tenancy | Optional | Schema-based? Foreign key-based? |

### TST — Testing
| ID | Item | Priority | Question |
|----|------|----------|----------|
| PX-TST-01 | Style | Critical | ExUnit (default)? Async tests? Sandbox mode for DB? |
| PX-TST-02 | Mocking | Important | Mox (behavior-based)? Mimic? |

### BLD — Build & Deploy
| ID | Item | Priority | Question |
|----|------|----------|----------|
| PX-BLD-01 | Release | Critical | Mix releases (default)? Docker? fly.io? |
| PX-BLD-02 | Assets | Important | esbuild + tailwind (default)? Separate frontend? |

---

## F7. Philosophy

| Principle | Description | Impact |
|-----------|-------------|--------|
| **Let It Crash** | OTP supervision for fault tolerance; processes restart automatically | Design for process isolation; don't catch all errors — let supervisors handle crashes |
| **Functional Core / Imperative Shell** | Pure functions for business logic, processes for side effects | Keep Ecto changesets and context functions pure; side effects in GenServers |
| **Immutable Data** | No in-place mutation; all data flows through transformations | Use pipe operator (`\|>`) for data transformation chains; avoid mutable state |
| **LiveView Real-Time** | Server-rendered real-time UI without client-side JavaScript frameworks | Default to LiveView for interactive features; avoid unnecessary JS |

---

## F8. Toolchain Commands

| Field | Command |
|-------|---------|
| `build` | `mix compile` |
| `test` | `mix test` |
| `lint` | `mix credo --strict` |
| `package_manager` | `mix` (Hex) |
| `install` | `mix deps.get` |

---

## F9. Scan Targets

#### Data Model
| Pattern | Description |
|---------|-------------|
| `schema "table_name"` in `lib/*/schemas/*.ex` or `lib/*/models/*.ex` | Ecto schema definitions |
| `field :name, :type` declarations | Schema field definitions |
| `has_many`, `belongs_to`, `has_one`, `many_to_many` | Relationship declarations |
| `priv/repo/migrations/*.exs` | Ecto migration files |

#### API Endpoints
| Pattern | Description |
|---------|-------------|
| `get`, `post`, `put`, `patch`, `delete` in `router.ex` | Route definitions |
| `resources "/path", Controller` | RESTful resource routes |
| `live "/path", LiveModule` | LiveView route definitions |
| `pipe_through [:api]` / `pipe_through [:browser]` | Pipeline assignments |
