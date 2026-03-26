# Foundation: NestJS
<!-- Format: _foundation-core.md | ID prefix: NE (see § F4) -->

> Server framework Foundation for TypeScript projects using NestJS.
> Angular-inspired framework with decorators, modules, DI container, and opinionated architecture.

---

## F0. Detection Signals

| Signal | Confidence |
|--------|-----------|
| `@nestjs/core` in `package.json` dependencies | HIGH |
| `NestFactory.create()` in `main.ts` | HIGH |
| `nest-cli.json` in project root | HIGH |
| `@Module`, `@Controller`, `@Injectable` decorators | MEDIUM |
| `@nestjs/*` scoped packages in dependencies | MEDIUM |

---

## F1. Categories

| Code | Category | Description |
|------|----------|-------------|
| BST | App Bootstrap | Module structure, platform adapter, global prefix, monorepo mode |
| SEC | Security | Guards, Passport strategies, JWT, RBAC, CORS, Helmet |
| MID | Middleware | Interceptors, pipes, exception filters, middleware, execution order |
| API | API Design | Controllers, versioning, Swagger/OpenAPI, serialization, WebSocket |
| DBS | Database | TypeORM/Prisma/MikroORM, database module, migrations |
| PRC | Process Management | Microservices transport, scheduling (@nestjs/schedule), queues (Bull) |
| HLT | Health Check | @nestjs/terminus, health indicators, readiness/liveness |
| ERR | Error Handling | Exception filters, HttpException hierarchy, custom exceptions |
| LOG | Logging | Built-in Logger, Pino/Winston integration, log levels |
| TST | Testing | Jest, Testing module, e2e with supertest, mock providers |
| BLD | Build & Deploy | SWC compiler, webpack, Docker, monorepo builds |
| ENV | Environment Config | @nestjs/config, ConfigModule, validation (Joi/class-validator) |
| DXP | Developer Experience | CLI generators, REPL, hot reload, Compodoc docs |

---

## F2. Decision Items

### BST — App Bootstrap
| ID | Item | Priority | Question |
|----|------|----------|----------|
| NJ-BST-01 | Module architecture | Critical | Feature modules? Shared modules? Dynamic modules? |
| NJ-BST-02 | Platform | Critical | Express (default) or Fastify adapter? |
| NJ-BST-03 | Monorepo | Important | Nest monorepo mode? Nx workspace? Turborepo? |

### SEC — Security
| ID | Item | Priority | Question |
|----|------|----------|----------|
| NJ-SEC-01 | Auth strategy | Critical | Passport + JWT? Passport + session? Custom guard? |
| NJ-SEC-02 | Authorization | Important | RBAC guard? CASL integration? Custom decorators? |
| NJ-SEC-03 | CORS | Important | `app.enableCors()` config? Allowed origins? |

### API — API Design
| ID | Item | Priority | Question |
|----|------|----------|----------|
| NJ-API-01 | API docs | Important | @nestjs/swagger? Auto-generated from decorators? |
| NJ-API-02 | Versioning | Optional | URI versioning? Header? Media type? |
| NJ-API-03 | Validation | Critical | class-validator + class-transformer? Zod? |
| NJ-API-04 | Serialization | Important | ClassSerializerInterceptor? Custom interceptor? |

### DBS — Database
| ID | Item | Priority | Question |
|----|------|----------|----------|
| NJ-DBS-01 | ORM | Critical | TypeORM? Prisma? MikroORM? Drizzle? |
| NJ-DBS-02 | Migrations | Critical | TypeORM migrations? Prisma migrate? |
| NJ-DBS-03 | Connection | Important | `TypeOrmModule.forRootAsync()`? Connection pooling? |

### TST — Testing
| ID | Item | Priority | Question |
|----|------|----------|----------|
| NJ-TST-01 | Framework | Critical | Jest (default)? Vitest? |
| NJ-TST-02 | E2E testing | Important | Supertest? Pactum? Test database strategy? |

### BLD — Build & Deploy
| ID | Item | Priority | Question |
|----|------|----------|----------|
| NJ-BLD-01 | Compiler | Important | tsc (default)? SWC (faster)? Webpack? |
| NJ-BLD-02 | Docker | Important | Multi-stage Dockerfile? Node.js alpine image? |

---

## F7. Philosophy

| Principle | Description | Impact |
|-----------|-------------|--------|
| **Modular Architecture** | Everything lives in a module; modules declare providers, controllers, imports, exports | One module per domain; shared services via SharedModule exports |
| **Decorator-Driven** | TypeScript decorators define routes, DI, validation, auth | Use decorators (`@Get`, `@Body`, `@UseGuards`) over manual wiring |
| **Dependency Injection** | Built-in IoC container manages all providers | Register services as `@Injectable()`; inject via constructor; avoid `new` |
| **Opinionated Structure** | Prescribed patterns for controllers, services, modules, DTOs | Follow Nest conventions: `*.controller.ts`, `*.service.ts`, `*.module.ts` |

---

## F8. Toolchain Commands

| Field | Command |
|-------|---------|
| `build` | `nest build` or `npm run build` |
| `test` | `npm run test` (unit) + `npm run test:e2e` (e2e) |
| `lint` | `npm run lint` (ESLint with @typescript-eslint) |
| `package_manager` | `npm` / `yarn` / `pnpm` |
| `install` | `npm install` |

---

## F8b. Runtime Environment

| Field | Command |
|-------|---------|
| `server_start` | `npm run start:dev` |
| `server_port` | `3000` |
| `health_check` | `curl -sf http://localhost:3000/health` |
| `env_loading` | `dotenv` (@nestjs/config + ConfigModule) |
| `prerequisites` | `docker compose up -d` (if DB/Redis used) |
| `seed_data` | `npm run seed` (if SeedService exists) |
| `cleanup` | `docker compose down` |

> **Note**: NestJS uses `@nestjs/config` which reads `.env` via `dotenv`. Bash demo/verify scripts must `source .env` with `set -a` explicitly — the NestJS process reads it but child bash commands do not.

---

## F9. Scan Targets

#### Data Model
| Pattern | Description |
|---------|-------------|
| `@Entity()` decorated classes (TypeORM) | Entity definitions |
| `model X { ... }` in `schema.prisma` (Prisma) | Prisma schema models |
| `@Entity()` with `@MikroORM` decorators | MikroORM entity definitions |
| Migration files in `migrations/` or `prisma/migrations/` | Schema evolution |

#### API Endpoints
| Pattern | Description |
|---------|-------------|
| `@Get()`, `@Post()`, `@Put()`, `@Delete()`, `@Patch()` in `*.controller.ts` | Controller endpoint definitions |
| `@Controller('prefix')` class decorator | Route prefix definitions |
| `@ApiTags()`, `@ApiOperation()` decorators | Swagger metadata |
| `RouterModule.forRoutes()` or `app.connectMicroservice()` | Advanced routing / microservice transport |
