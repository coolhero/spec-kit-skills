# Express.js Foundation
<!-- Format: _foundation-core.md | ID prefix: EX (see § F4) -->

## F0. Detection Signals

- `express` in package.json `dependencies`
- `app.listen()` or `createServer` pattern in entry files
- `app.use()` middleware chain pattern
- Route definitions using `app.get()`, `app.post()`, `router.get()`, etc.
- `express()` factory call in source

---

## F1. Foundation Categories

| Category Code | Category Name | Item Count | Description |
|--------------|---------------|------------|-------------|
| BST | App Bootstrap | 2 | Server bootstrap pattern, TypeScript setup |
| SEC | Security | 5 | CORS, auth strategy, security headers, cookie config, trust proxy |
| MID | Middleware | 4 | Middleware chain, body parsing, compression, rate limiting |
| API | API Design | 5 | Versioning, route organization, pagination, validation, API docs |
| DBS | Database | 3 | ORM/query builder, connection pool, request ID/tracing |
| PRC | Process Management | 4 | Graceful shutdown, clustering, process manager, WebSocket |
| HLT | Health Check | 2 | Health endpoint, readiness/liveness |
| ERR | Error Handling | 2 | Error handling strategy, error response format |
| LOG | Logging & Monitoring | 3 | Request logging, app logging, log format |
| TST | Testing | 2 | Testing setup, linting/formatting |
| BLD | Build & Deploy | 3 | Static files, file uploads, HTTPS/TLS |
| ENV | Environment Config | 3 | Environment config, response caching, timeout handling |
| DXP | Developer Experience | 5 | Express version, session management, Helmet config, rate limit config, WebSocket |

---

## F2. Foundation Items

### BST: App Bootstrap

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| EX-BST-01 | Server bootstrap pattern | How to initialize the Express app | choice (direct / factory) | Critical |
| EX-BST-02 | TypeScript setup | Whether to use TypeScript and compilation strategy | choice (javascript / typescript-tsc / typescript-swc / typescript-tsx) | Critical |

### SEC: Security

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| EX-SEC-01 | CORS policy | Cross-Origin Resource Sharing configuration | config | Critical |
| EX-SEC-02 | Authentication strategy | Which authentication mechanism to implement | choice (JWT / session-cookie / OAuth2 / API-key / passport / none) | Critical |
| EX-SEC-03 | Security headers | Whether to use Helmet.js for secure HTTP headers | binary | Critical |
| EX-SEC-04 | Cookie configuration | Cookie security settings (httpOnly, secure, sameSite, signed, maxAge) | config | Important |
| EX-SEC-05 | Trust proxy | Whether to set `trust proxy` for apps behind reverse proxy | config | Important |

### MID: Middleware

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| EX-MID-01 | Middleware chain order | Order of global middleware (logging, security, parsing, auth) | config | Critical |
| EX-MID-02 | Body parsing | Body parsing middleware configuration (express.json, urlencoded, multer) | config | Critical |
| EX-MID-03 | Compression | Whether to enable response compression middleware | choice (compression / none) | Important |
| EX-MID-04 | Rate limiting | Rate limiting strategy | choice (express-rate-limit / custom / none) | Important |

### API: API Design

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| EX-API-01 | API versioning | Strategy for API versioning | choice (url-path / header / query / content-type / none) | Important |
| EX-API-02 | Route organization | How routes are organized | choice (resource-based / feature-based / version-based) | Important |
| EX-API-03 | Pagination strategy | Default pagination pattern for list endpoints | choice (offset / cursor / keyset / none) | Important |
| EX-API-04 | Request validation | Input validation library and strategy | choice (joi / zod / express-validator / class-validator / ajv / none) | Important |
| EX-API-05 | API documentation | Whether to generate API docs (Swagger/OpenAPI) | choice (swagger-ui-express / swagger-jsdoc / none) | Important |

### DBS: Database

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| EX-DBS-01 | Database / ORM | Database access layer | choice (prisma / typeorm / sequelize / knex / drizzle / mongoose / raw / none) | Critical |
| EX-DBS-02 | Connection pool | Connection pool size and configuration | config | Important |
| EX-DBS-03 | Request ID / tracing | Whether to assign unique ID to each request for distributed tracing | binary | Important |

### PRC: Process Management

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| EX-PRC-01 | Graceful shutdown | Whether to implement graceful shutdown for SIGTERM/SIGINT | binary | Critical |
| EX-PRC-02 | Graceful shutdown library | Tool for graceful shutdown | choice (http-terminator / lightship / terminus / custom) | Important |
| EX-PRC-03 | Clustering | Whether to use Node.js cluster for multi-core utilization | binary | Important |
| EX-PRC-04 | Process management | Production process manager | choice (pm2 / systemd / docker / kubernetes / none) | Important |

### HLT: Health Check

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| EX-HLT-01 | Health check endpoint | Whether to expose `/health` or `/healthz` | binary | Important |
| EX-HLT-02 | Readiness/liveness endpoints | Separate readiness and liveness check endpoints | binary | Important |

### ERR: Error Handling

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| EX-ERR-01 | Error handling strategy | Centralized error handling middleware pattern | config | Critical |
| EX-ERR-02 | Error response format | Standard error response shape (JSON structure, error codes) | config | Critical |

### LOG: Logging & Monitoring

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| EX-LOG-01 | Request logging | HTTP request logging library | choice (morgan / pino-http / winston-express / custom) | Important |
| EX-LOG-02 | Application logging | Application-level logging library | choice (winston / pino / bunyan / console) | Important |
| EX-LOG-03 | Log format | Log output format | choice (json / text / combined) | Important |

### TST: Testing

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| EX-TST-01 | Testing setup | Testing framework and strategy | choice (jest / mocha / vitest / supertest) | Important |
| EX-TST-02 | Linting / formatting | Code quality tooling | choice (eslint+prettier / biome / oxlint) | Important |

### BLD: Build & Deploy

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| EX-BLD-01 | Static file serving | Whether and how to serve static files | choice (express-static / cdn / none) | Important |
| EX-BLD-02 | File upload handling | How to handle file uploads | choice (multer / busboy / formidable / none) | Important |
| EX-BLD-03 | HTTPS / TLS | Whether Express serves HTTPS directly or via reverse proxy | choice (direct-https / reverse-proxy / both) | Important |

### ENV: Environment Config

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| EX-ENV-01 | Environment config | How to manage environment-specific configuration | choice (dotenv / node-config / convict / custom / native-env) | Critical |
| EX-ENV-02 | Response caching | Response caching strategy (ETags, Cache-Control, in-memory cache) | config | Important |
| EX-ENV-03 | Timeout handling | Request timeout configuration | config | Important |

### DXP: Developer Experience

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| EX-DXP-01 | Express version | Choose between Express 4 or Express 5 | choice (v4 / v5) | Important |
| EX-DXP-02 | Session management | If using sessions, the session store and configuration | choice (memory / redis / postgres / mongodb / none) | Important |
| EX-DXP-03 | Helmet configuration | Which Helmet protections to enable/customize | config | Important |
| EX-DXP-04 | Rate limit configuration | Window size, max requests, per-route overrides | config | Important |
| EX-DXP-05 | WebSocket integration | Whether to integrate WebSocket support | choice (ws / socket.io / none) | Important |

---

## F3. Extraction Rules (reverse-spec)

| Category | Extraction Method |
|----------|------------------|
| BST | Check entry point for `express()` call pattern (direct vs factory). Check for TypeScript config files (tsconfig.json) and compilation scripts. |
| SEC | Search for `cors()` middleware, `helmet()` usage, passport/JWT imports. Read cookie-parser config. Check for `trust proxy` setting. |
| MID | Read middleware registration order in app setup. Check for `express.json()`, `express.urlencoded()`, `compression()` usage. Search for rate-limit middleware. |
| API | Look for URL versioning patterns (`/api/v1/`). Check route file organization. Search for swagger-ui-express or swagger-jsdoc. Check for validation library imports. |
| DBS | Search for ORM imports (prisma, typeorm, sequelize, mongoose). Read database connection configuration. Look for request ID middleware. |
| PRC | Search for `process.on('SIGTERM')` handlers. Check for cluster module usage. Look for PM2 ecosystem config. |
| HLT | Search for `/health` or `/healthz` route definitions. |
| ERR | Look for error-handling middleware (4 params: err, req, res, next). Check error response structures in catch blocks. |
| LOG | Search for morgan, pino, winston imports. Check log format configuration. |
| TST | Read test configuration (jest.config, .mocharc). Check for supertest in dev dependencies. |
| BLD | Check for `express.static()` usage. Search for multer/busboy config. Look for HTTPS server creation. |
| ENV | Search for dotenv, node-config, convict imports. Check `.env` file patterns. |
| DXP | Check package.json for express version. Look for express-session config. |

---

## F4. T0 Feature Grouping

| T0 Feature | Foundation Categories | Items |
|------------|----------------------|-------|
| F000-app-bootstrap-security | BST + SEC + ENV | 10 |
| F000-request-pipeline | MID + ERR | 6 |
| F000-api-design | API | 5 |
| F000-database-layer | DBS | 3 |
| F000-process-health | PRC + HLT | 6 |
| F000-logging-testing | LOG + TST | 5 |
| F000-build-devexp | BLD + DXP | 8 |

---

## F7. Framework Philosophy

| Principle | Description | Implication |
|-----------|-------------|-------------|
| **Middleware Composition** | Everything in Express is middleware — request processing is an explicit, ordered pipeline | Middleware registration order is a first-class architectural decision; every cross-cutting concern (auth, logging, rate limiting, error handling) is a middleware; the pipeline must be documented and intentional |
| **Minimal Core** | Express provides routing and middleware — everything else is a deliberate choice | There is no "default" ORM, validator, or template engine; every dependency is an explicit architectural decision that must be justified and documented |
| **Error-First Conventions** | Error handling follows Node.js error-first conventions — centralized error middleware is the catch-all | Error middleware (4 params) must be the last middleware registered; domain errors must be converted to HTTP errors in a single, centralized location; async errors must be properly caught and forwarded |
| **Stateless Requests** | Each request is independent — server-side state requires explicit external stores | Session data goes to Redis/DB, not in-memory; no request-scoped global state; horizontal scaling is possible without sticky sessions |
