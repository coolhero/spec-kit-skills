# Foundation: Hono
<!-- Format: _foundation-core.md | ID prefix: HO (see § F4) -->

> Web framework Foundation for projects using Hono.
> Lightweight, multi-runtime web framework (Bun, Deno, Cloudflare Workers, Node.js).

---

## F0. Detection Signals

| Signal | Confidence |
|--------|-----------|
| `hono` in package.json dependencies | HIGH |
| `new Hono()` or `import { Hono } from 'hono'` | HIGH |
| `app.get()`, `app.post()` with Hono patterns | MEDIUM |

---

## F1. Categories

| Code | Category | Description |
|------|----------|-------------|
| BST | App Bootstrap | Hono app creation, runtime adapter (Bun/Node/Deno/Workers) |
| MID | Middleware | Built-in middleware, custom middleware, middleware ordering |
| API | API Design | Route organization, parameter handling, validation |
| SEC | Security | CORS, CSRF, rate limiting, authentication middleware |
| ERR | Error Handling | Error handler, `HTTPException`, not-found handler |
| DBS | Database | ORM integration, connection management |
| TST | Testing | Hono test client, request/response testing |
| BLD | Build & Deploy | Multi-runtime build, adapter configuration |

---

## F2. Decision Items

### BST — App Bootstrap
| ID | Item | Priority | Question |
|----|------|----------|----------|
| HO-BST-01 | Runtime adapter | Critical | Bun (`Bun.serve`) vs Node.js (`@hono/node-server`) vs Workers? |
| HO-BST-02 | App factory | Important | Single `new Hono()` vs `createApp()` factory? |

### MID — Middleware
| ID | Item | Priority | Question |
|----|------|----------|----------|
| HO-MID-01 | Middleware chain | Critical | Which built-in middleware? (logger, cors, compress, etag, etc.) |
| HO-MID-02 | Custom middleware | Important | Middleware pattern: `async (c, next) => {}` conventions? |

### API — API Design
| ID | Item | Priority | Question |
|----|------|----------|----------|
| HO-API-01 | Route organization | Critical | Flat routes vs grouped (`app.route()`) vs file-based? |
| HO-API-02 | Validation | Important | Zod validator middleware? `@hono/zod-validator`? |
| HO-API-03 | OpenAPI | Optional | `@hono/zod-openapi` for auto-generated OpenAPI specs? |

### ERR — Error Handling
| ID | Item | Priority | Question |
|----|------|----------|----------|
| HO-ERR-01 | Error handler | Critical | `app.onError()` global handler? Error response format? |
| HO-ERR-02 | Not found | Important | `app.notFound()` handler? |

---

## F7. Philosophy

| Principle | Description | Impact |
|-----------|-------------|--------|
| **Multi-Runtime** | Hono runs on Bun, Deno, Node.js, Cloudflare Workers with the same code | Avoid runtime-specific APIs in route handlers — use Hono's abstraction layer |
| **Web Standards** | Hono uses Web Standard APIs (Request, Response, fetch) — no Express-specific patterns | Don't assume `req.body` (Express) — use `c.req.json()` (Hono) |
| **Middleware Composition** | Small, composable middleware over large frameworks | Prefer Hono built-in middleware over full framework replacements |

---

## F8. Toolchain Commands

| Field | Command |
|-------|---------|
| `build` | `bun run build` OR `npm run build` (depends on runtime) |
| `test` | `bun test` OR `vitest` |

---

## F9. Scan Targets

#### API Endpoints
| Pattern | Description |
|---------|-------------|
| `app.get()`, `app.post()`, `app.put()`, `app.delete()`, `app.patch()` | Hono route handlers |
| `app.route('/prefix', subRouter)` | Grouped route mounting |
| `createRoute()` from `@hono/zod-openapi` | OpenAPI-compatible route definitions |
| `app.use('*', middleware)` | Middleware registration |
