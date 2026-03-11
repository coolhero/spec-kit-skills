# Interface: http-api

> REST/GraphQL API endpoints. Applies when the project exposes HTTP-based interfaces.
> Module type: interface

---

## S0. Signal Keywords

> Keywords that indicate this module should be activated. Used by Clarity Index signal extraction.

**Primary**: REST, GraphQL, API, endpoints, backend, server, Express, FastAPI, Hono, Koa, NestJS, Django, Flask, Spring Boot, Rails, HTTP, microservice
**Secondary**: CORS, rate limiting, middleware, webhook, versioning, OpenAPI, Swagger

---

## S1. SC Generation Rules

### Required SC Patterns
- Every endpoint: status code + response body shape verification
- Auth-protected endpoints: unauthorized (401) + forbidden (403) SCs required
- List endpoints: pagination behavior SC required
- Mutation endpoints: input validation error SC required (400/422 with error format)

### SC Anti-Patterns (reject)
- "API responds correctly" — must specify status code + body shape
- "Error is handled" — must specify error code + message format
- "Data is returned" — must specify response schema or key fields

### SC Measurability Criteria
- Response time threshold (if specified in requirements)
- Rate limit enforcement (count + window + 429 response)

---

## S2. Parity Dimensions (additions)

| Category | What to Compare |
|----------|----------------|
| API endpoints | Route definitions, controllers — match original routes |
| Response schemas | JSON structure per endpoint — match original shapes |

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| **REST conventions** | Resource naming? HTTP methods? Status codes? Versioning strategy? |
| **Real-time** | WebSocket/SSE needed? What events? Reconnection handling? |
| **API documentation** | OpenAPI/Swagger? Auto-generated or manual? |

---

## S7. Bug Prevention Rules

When this interface is active, enforce:
- API Compatibility Matrix check: see `injection/implement.md` § API Compatibility Matrix Injection
- Cross-Feature API contract consistency: see `injection/verify.md` § Phase 2

---

## S8. Runtime Verification Strategy

> Cross-references [reference/runtime-verification.md](../../reference/runtime-verification.md) § 6b.

| Field | Value |
|-------|-------|
| **Start method** | Server process (`npm start`, `uvicorn`, `rails server`, etc.) |
| **Verify method** | Send HTTP requests to endpoints → verify status codes + response bodies + mutation side effects. Backend: HTTP client (`curl`, `supertest`, or language-native HTTP calls) |
| **Stop method** | Kill server process |
| **SC classification extensions** | `api-auto` — endpoint SCs verifiable via HTTP client without external dependencies |

**HTTP-API-specific verification**:
- Step 3d Interactive Runtime Verification: group `api-auto` SCs by endpoint → send requests → verify status + body + mutations
- Auth-protected endpoints: test both authenticated and unauthenticated requests
- Mutation endpoints: verify side effects (database state, event emission) after request
