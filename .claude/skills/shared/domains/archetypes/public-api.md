# Archetype: public-api

> External-facing API platforms — developer portals, SDK generation, rate limiting.

---

## Signal Keywords

### Semantic (A0 — for init inference)

**Primary**: public API, API platform, developer portal, API versioning, rate limiting, API key, OpenAPI, Swagger, API gateway, developer experience, DX, SDK generation

**Secondary**: webhook, API documentation, deprecation policy, API consumer, third-party integration, API marketplace, developer onboarding

### Code Patterns (A0 — for source analysis)

- **Libraries**: `swagger-ui-express`, `@nestjs/swagger`, `express-rate-limit`, `@nestjs/throttler`, `rate-limiter-flexible`, `express-openapi-validator`, `fastapi` (with OpenAPI auto-gen), `drf-spectacular`
- **Code patterns**: API versioning (`/v1/`, `/v2/` route patterns), rate limit middleware, API key validation, webhook dispatch, CORS configuration for external consumers, OpenAPI/Swagger annotations
- **Config files**: `openapi.yaml`, `swagger.json`, API gateway configs, rate limit configuration, API key management

---

## Module Metadata

- **Axis**: Archetype
- **Typical interfaces**: http-api
- **Common pairings**: auth, authorization
