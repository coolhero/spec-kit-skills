# Archetype: public-api (reverse-spec)

> Public-facing API service analysis. Loaded when project exposes APIs for external consumers with versioning, rate limiting, or SDK generation patterns.
> Module type: archetype (reverse-spec analysis)

---

## A0. Signal Keywords

> See [`shared/domains/archetypes/public-api.md`](../../../shared/domains/archetypes/public-api.md) § Signal Keywords

---

## A1. Analysis Axes — Philosophy Extraction

For each detected public API pattern, extract:

| Principle | Extraction Targets | Output Format |
|-----------|--------------------|---------------|
| **Contract Stability** | API versioning strategy, breaking change handling, deprecation notices, schema validation | Versioning scheme (URL/header/query); deprecation policy |
| **Rate Limit Transparency** | Rate limiting implementation, limit headers (`X-RateLimit-*`), throttling tiers, burst handling | Rate limit strategy; header exposure; tier structure |
| **Backward Compatibility** | Old version maintenance, migration guides, sunset timelines, backward-compatible changes | Compatibility guarantee level; sunset policy |
| **Documentation as Code** | OpenAPI/Swagger generation, auto-generated docs, example responses, SDK generation | Documentation generation approach; coverage |
| **Consumer Trust** | Error response consistency, status code usage, pagination patterns, idempotency keys | API design maturity indicators |
