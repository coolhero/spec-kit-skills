# Interface: http-api

> REST/GraphQL endpoints, HTTP servers, API backends.

---

## Signal Keywords

### Semantic (S0 — for init inference)

**Primary**: REST, GraphQL, API, endpoints, backend, server, Express, FastAPI, Hono, Koa, NestJS, Django, Flask, Spring Boot, Rails, HTTP, microservice

**Secondary**: CORS, rate limiting, middleware, webhook, versioning, OpenAPI, Swagger

### Code Patterns (R1 — for source analysis)

> http-api does not define per-module R1 signals. Interface detection uses generic heuristics in `reverse-spec/domains/_core.md § R1` (e.g., route handler patterns, `app.get()`, `@Controller` decorators).

---

## Module Metadata

- **Axis**: Interface
- **Common pairings**: auth, authorization
- **Profiles**: web-api, fullstack-web
