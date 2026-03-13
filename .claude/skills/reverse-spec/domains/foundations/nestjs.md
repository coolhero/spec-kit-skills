# NestJS Foundation

## F0. Detection Signals

- `@nestjs/core` in package.json `dependencies`
- `nest-cli.json` or `nest.config.js` present
- Module/Controller/Service decorator patterns (`@Module`, `@Controller`, `@Injectable`)
- `main.ts` with `NestFactory.create()` call
- `@nestjs/*` scoped packages in dependencies

---

## F1. Foundation Categories

| Category Code | Category Name | Item Count | Description |
|--------------|---------------|------------|-------------|
| BST | App Bootstrap | 4 | Module structure, monorepo mode, platform adapter, global prefix |
| SEC | Security | 4 | Guards, auth implementation, RBAC, CORS |
| MID | Middleware | 6 | Interceptors, pipes, validation, exception filters, middleware |
| API | API Design | 5 | Versioning, Swagger, serialization, WebSocket, microservices |
| DBS | Database | 4 | ORM, database module, migrations, queue integration |
| PRC | Process Management | 3 | Graceful shutdown, request context, scheduling |
| HLT | Health Check | 3 | Health endpoints, health indicators, Swagger auth |
| ERR | Error Handling | 2 | HTTP exception format, custom exception filters |
| LOG | Logging & Monitoring | 3 | Logging library, log levels, config validation |
| TST | Testing | 3 | Testing strategy, test database, CLI generation |
| BLD | Build & Deploy | 3 | Compression, caching, rate limiting |
| ENV | Environment Config | 4 | Config module, DI scope, CQRS, event handling |
| DXP | Developer Experience | 7 | Response transformation, file uploads, hybrid app, queue strategy, cache interceptor, rate limit strategy, request context |

<!-- TODO: Full itemization — 51 items across 13 categories -->
<!-- See _foundation-core.md for Foundation file format specification -->
<!-- Refer to research data for complete NestJS Foundation item enumeration -->
