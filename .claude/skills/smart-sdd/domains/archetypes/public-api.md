# Archetype: public-api

> Public-facing API service. Applies when the project exposes APIs consumed by external developers, third-party apps, or partner integrations.
> Module type: archetype

---

## A0. Signal Keywords

> Keywords that indicate this archetype should be activated. Used by Clarity Index signal extraction.

**Primary**: public API, API platform, developer portal, API versioning, rate limiting, API key, OpenAPI, Swagger, API gateway, developer experience, DX, SDK generation
**Secondary**: webhook, API documentation, deprecation policy, API consumer, third-party integration, API marketplace, developer onboarding

---

## A1. Philosophy Principles

| Principle | Description | Implication |
|-----------|-------------|-------------|
| **Contract Stability** | Once published, API contracts are promises to consumers — breaking changes require versioning | Every endpoint must have a versioning strategy; schema changes must be classified as breaking/non-breaking |
| **Rate Limit Transparency** | Consumers must always know their rate limit status through standard headers | Rate limit headers (`X-RateLimit-*`) are mandatory on every response; tier-based limits must be documented |
| **Backward Compatibility** | New versions must not break existing consumers — old versions must have documented sunset timelines | Default to additive changes; removal requires deprecation period + migration guide |
| **Documentation as Code** | API documentation is generated from code annotations — never manually maintained | OpenAPI/Swagger specs are auto-generated; examples are validated against actual responses |
| **Consumer Trust** | Consistent error formats, predictable pagination, and idempotency build developer trust | Error response schema is standardized project-wide; idempotency keys supported for write operations |

---

## A2. SC Generation Extensions

### Required SC Patterns
- **Version specification**: Every API endpoint SC must specify which API version it belongs to and how version routing works
- **Rate limit behavior**: SCs must specify rate limit response (429 status, `Retry-After` header, limit headers) and tier behavior if applicable
- **Error response format**: SCs must use the project's standardized error response schema — never ad-hoc error structures
- **Deprecation handling**: SCs for deprecated endpoints must specify sunset header, warning response, and migration path

### SC Anti-Patterns (reject)
- "API returns data" — must specify response schema, status codes, pagination, and rate limit headers
- "Authentication works" — must specify API key validation, OAuth flow, token refresh, and error responses per auth failure type
- "Endpoint is versioned" — must specify version routing mechanism, backward compatibility rules, and sunset policy

---

## A3. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| **Versioning** | URL-based (`/v1/`) or header-based versioning? How many concurrent versions supported? Sunset policy? |
| **Rate limiting** | Global or per-endpoint limits? Tier-based (free/pro/enterprise)? Burst allowance? |
| **Authentication** | API key, OAuth2, JWT? Multiple auth methods? Developer self-service key management? |
| **Documentation** | Auto-generated from code? Interactive playground (Swagger UI)? SDK generation? |
| **Webhooks** | Webhook delivery? Retry policy? Signature verification? Event types? |
| **Consumer management** | Developer portal? Usage analytics? API key rotation? Quota management? |

---

## A4. Constitution Injection

Principles to inject into constitution-seed when this archetype is active:

| Principle | Rationale |
|-----------|-----------|
| Every API response must include standard rate limit headers (`X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`) | External consumers need to implement client-side throttling; hidden limits erode trust |
| API error responses must follow a single standardized schema across all endpoints | Consumers build client libraries based on error format consistency; inconsistency multiplies integration effort |
| Breaking changes require a new API version — additive changes (new fields, new endpoints) do not | Consumer code must not break on deploy; versioning strategy must be defined before first release |
| OpenAPI specification must be auto-generated from code and validated in CI | Manual documentation drifts from implementation; auto-generation ensures accuracy |
| All write operations on public endpoints must support idempotency keys | Network retries are inevitable for external consumers; duplicate operations must be safely handled |
