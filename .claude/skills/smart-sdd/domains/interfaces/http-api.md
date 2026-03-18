# Interface: http-api

> REST/GraphQL API endpoints. Applies when the project exposes HTTP-based interfaces.
> Module type: interface

---

## S0. Signal Keywords

> See [`shared/domains/interfaces/http-api.md`](../../../shared/domains/interfaces/http-api.md) § Signal Keywords

---

## S1. SC Generation Rules

### Required SC Patterns

**Per endpoint (MANDATORY for every API endpoint in spec):**
- Status code + response body shape: `GET /users → 200 + {id, name, email}[]`
- Error response format: `GET /users/999 → 404 + {error: "User not found", code: "NOT_FOUND"}`

**Auth-protected endpoints:**
- Unauthenticated request → 401 with actionable message ("Authentication required. Include Bearer token in Authorization header")
- Forbidden request (wrong role) → 403 with explanation
- Token expired → 401 with refresh hint

**List endpoints:**
- Pagination: page/limit/offset parameters + total count in response
- Empty list: `200 + {data: [], total: 0}` (NOT 404)
- Filtering/sorting: parameter names + expected behavior

**Mutation endpoints (POST/PUT/PATCH/DELETE):**
- Input validation: `400/422 + {errors: [{field, message}]}` format
- Duplicate prevention: `409 + {error: "Already exists"}`
- Successful mutation: return created/updated resource (not just `{ok: true}`)
- DELETE: `204 No Content` or `200 + deleted resource`

**CRUD round-trip (if entity has full CRUD):**
- POST → GET (verify created) → PUT (verify updated) → DELETE → GET (verify 404)
- SC must cover the FULL round-trip, not just individual operations

### SC Anti-Patterns (reject)
- "API responds correctly" — must specify status code + body shape
- "Error is handled" — must specify error code + message format + actionable guidance
- "Data is returned" — must specify response schema or key fields
- "User can create a resource" — must include validation errors + duplicate handling
- "Authentication works" — must specify token format, expiry behavior, refresh flow

### SC Measurability Criteria
- Response time threshold (if specified in requirements)
- Rate limit enforcement (count + window + 429 response with `Retry-After` header)
- Payload size limits (413 response)

---

## S2. Parity Dimensions (additions)

| Category | What to Compare |
|----------|----------------|
| API endpoints | Route definitions, controllers — match original routes |
| Response schemas | JSON structure per endpoint — match original shapes |
| Error response format | Consistent error envelope across all endpoints |
| Auth flow | Token issuance, validation, refresh — match original behavior |

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| **REST conventions** | Resource naming? HTTP methods? Status codes? Versioning strategy (URL path vs header)? |
| **Authentication** | Auth strategy (JWT, session, API key)? Token lifetime? Refresh mechanism? Multi-tenant? |
| **Validation** | Input validation library? Error response format? Nested object validation? |
| **Database** | ORM or raw SQL? Migration strategy? Seed data? Connection pooling? |
| **Real-time** | WebSocket/SSE needed? What events? Reconnection handling? |
| **API documentation** | OpenAPI/Swagger? Auto-generated or manual? Client SDK generation? |
| **Rate limiting** | Per-user? Per-IP? Per-endpoint? Window size? Response when exceeded? |
| **CORS** | Allowed origins? Credentials? Preflight caching? |

---

## S6. API Testing Strategy

> Equivalent to GUI's S6 UI Testing Strategy, but for HTTP endpoints.

### Automated Endpoint Testing

Every API Feature MUST have automated endpoint tests that:
1. **Start the server** (background process or in-process)
2. **Send actual HTTP requests** to each endpoint
3. **Verify response**: status code + body shape + key field values
4. **Verify side effects**: database state, event emissions, file creation
5. **Clean up**: reset database/state to known state

### Test Categories

| Category | What It Tests | Tool |
|----------|--------------|------|
| **Route existence** | Endpoint responds (not 404) | curl / supertest |
| **Auth enforcement** | Protected endpoints reject unauthenticated requests | curl with/without token |
| **Input validation** | Invalid inputs return structured errors | curl with bad payloads |
| **CRUD round-trip** | Create → Read → Update → Delete → Verify deleted | sequential HTTP calls |
| **Error responses** | Error format is consistent and actionable | curl triggering error paths |
| **Database state** | Mutations actually persist | read DB after mutation |

### Integration Contract Verification

When an API endpoint serves as an interface to other Features (plan.md "Provides →"):
- Call the endpoint from the downstream Feature's perspective
- Verify the response contains what the downstream Feature expects
- This is NOT just "endpoint returns 200" — it's "response contains fields X, Y, Z that Feature B needs"

---

## S7. Bug Prevention Rules

When this interface is active, enforce:

### B-1 (Plan phase)
- **Route registration verification**: Every endpoint in spec must map to a controller/handler in the architecture
- **Middleware order**: Auth middleware before business logic, error handler at the end
- **Database connection lifecycle**: Connection pooling, graceful shutdown, health check endpoint

### B-3 (Implement phase)
- **API Compatibility Matrix check**: see `injection/implement.md` § API Compatibility Matrix Injection
- **Response envelope consistency**: All endpoints must use the same response format (e.g., `{data, error, meta}`)
- **Error handler completeness**: Uncaught exceptions must return structured error (not raw stack trace)
- **Validation before business logic**: Input validation must happen before any DB/service call
- **SQL injection prevention**: Parameterized queries or ORM — no string concatenation in SQL
- **Missing Content-Type**: All responses must set appropriate Content-Type header

### B-4 (Verify phase)
- **Cross-Feature API contract consistency**: see `injection/verify.md` § Phase 2
- **Orphan routes**: Routes defined but no handler → dead endpoint
- **Missing error handling**: Handler without try/catch or error middleware

---

## S8. Runtime Verification Strategy

> Cross-references [reference/runtime-verification.md](../../reference/runtime-verification.md) § 6b.

| Field | Value |
|-------|-------|
| **Start method** | Server process (`npm start`, `uvicorn`, `rails server`, `go run`, etc.) |
| **Health check** | `GET /health` or `GET /` → 200 (verify server is ready before testing) |
| **Verify method** | Send HTTP requests → verify status codes + response bodies + side effects |
| **Stop method** | Kill server process (graceful shutdown signal first, force after timeout) |
| **SC classification** | `api-auto` — endpoint SCs verifiable via HTTP client without external dependencies |

### HTTP-API Verify Phase 3 Protocol

Unlike GUI verification (Playwright + visual inspection), API verification is **fully automatable**:

```
Phase 3 for API Features:
1. Start server (background)
2. Wait for health check (GET /health → 200, max 30s)
3. For EACH endpoint SC:
   a. Construct request (method, path, headers, body)
   b. Send request
   c. Verify: status code matches SC
   d. Verify: response body shape matches SC
   e. Verify: side effects (DB state, events) if SC specifies them
4. Auth tests: repeat key endpoints without token → verify 401
5. Validation tests: send invalid payloads → verify 400/422 + error format
6. CRUD round-trip: POST → GET → PUT → DELETE → GET(404)
7. Stop server
```

**Every step produces verifiable evidence** (HTTP status code, response body). This is NOT subjective like GUI visual verification — it's deterministic.

```
❌ WRONG: "API tests pass" (agent's claim without evidence)
✅ RIGHT: "GET /api/users → 200 [{id:1,name:'test'}] (42ms)
          POST /api/users {invalid} → 422 {errors:[{field:'email',message:'required'}]}
          GET /api/users/999 → 404 {error:'Not found'}"
```

### Test Environment for API

- **Database**: Use test database (separate from dev). Create + migrate + seed before tests, drop after.
- **External services**: Mock or use test credentials. If real credentials needed → `user-assisted` classification.
- **Port conflicts**: Use random port or configurable port for test server.
- **Process cleanup**: Kill server process in finally block (prevent port lock).

---

## S9. Brief Completion Criteria

| Required Element | Completion Signal |
|-----------------|-------------------|
| At least one endpoint | Method (GET/POST/PUT/DELETE) + path + purpose stated |
| API consumer or provider role | Direction clear: "provides API for X" or "consumes API from Y" |
| Authentication requirement | Stated whether endpoints are public or auth-protected |
| Error response strategy | How errors are formatted and what actionable info they include |
| Database/persistence | What data is persisted and how (ORM, raw SQL, file) |
| Validation approach | How input is validated and how errors are reported |
