# Foundation: ASP.NET Core

> Server framework Foundation for C# projects using ASP.NET Core (.NET 6+).
> Convention-based framework with built-in DI, middleware pipeline, and strongly-typed configuration.

---

## F0. Detection Signals

| Signal | Confidence |
|--------|-----------|
| `*.csproj` with `Microsoft.AspNetCore.*` package references | HIGH |
| `Program.cs` with `WebApplication.CreateBuilder()` | HIGH |
| `appsettings.json` in project root | HIGH |
| `*.sln` solution file + ASP.NET project references | MEDIUM |
| `Startup.cs` with `Configure` / `ConfigureServices` (older pattern) | MEDIUM |

---

## F1. Categories

| Code | Category | Description |
|------|----------|-------------|
| BST | App Bootstrap | Minimal API vs controllers, Program.cs, DI container |
| SEC | Security | ASP.NET Identity, JWT Bearer, OAuth2/OIDC, authorization policies |
| MID | Middleware | Middleware pipeline ordering, custom middleware |
| API | API Design | Controllers vs Minimal API, Swagger/Swashbuckle, model binding, versioning |
| DBS | Database | Entity Framework Core, Dapper, migrations, connection management |
| PRC | Process Management | Kestrel config, IHostedService, BackgroundService |
| HLT | Health Check | AddHealthChecks, MapHealthChecks, custom health checks |
| ERR | Error Handling | Exception middleware, ProblemDetails RFC 7807, global handler |
| LOG | Logging | ILogger, Serilog vs NLog, structured logging |
| TST | Testing | xUnit vs NUnit, WebApplicationFactory, Testcontainers |
| BLD | Build & Deploy | dotnet publish, Docker, self-contained vs framework-dependent |
| ENV | Environment Config | appsettings.{Environment}.json, IOptions<T>, user secrets |
| DXP | Developer Experience | Hot Reload, dotnet watch, source generators |

---

## F2. Decision Items

### BST — App Bootstrap
| ID | Item | Priority | Question |
|----|------|----------|----------|
| DN-BST-01 | API style | Critical | Minimal API or Controller-based? |
| DN-BST-02 | .NET version | Critical | .NET 8/9/10? LTS or STS? |
| DN-BST-03 | DI registration | Important | Manual registration or auto-discovery (Scrutor)? |

### SEC — Security
| ID | Item | Priority | Question |
|----|------|----------|----------|
| DN-SEC-01 | Auth strategy | Critical | ASP.NET Identity? JWT Bearer? External IdP (Duende IdentityServer)? |
| DN-SEC-02 | Authorization | Important | Policy-based? Role-based? Resource-based? |
| DN-SEC-03 | CORS | Important | `AddCors()` config? Allowed origins? |

### API — API Design
| ID | Item | Priority | Question |
|----|------|----------|----------|
| DN-API-01 | API docs | Important | Swashbuckle? Scalar? NSwag? |
| DN-API-02 | Versioning | Optional | Asp.Versioning? URL-based? Header-based? |
| DN-API-03 | Model validation | Important | DataAnnotations? FluentValidation? |

### DBS — Database
| ID | Item | Priority | Question |
|----|------|----------|----------|
| DN-DBS-01 | ORM | Critical | Entity Framework Core? Dapper? Both? |
| DN-DBS-02 | Migrations | Critical | EF Core migrations? Fluent Migrator? |
| DN-DBS-03 | DB provider | Critical | Npgsql (PostgreSQL)? SqlServer? MySQL? |

### TST — Testing
| ID | Item | Priority | Question |
|----|------|----------|----------|
| DN-TST-01 | Framework | Critical | xUnit (most common)? NUnit? MSTest? |
| DN-TST-02 | Integration | Important | WebApplicationFactory? Testcontainers? |

### BLD — Build & Deploy
| ID | Item | Priority | Question |
|----|------|----------|----------|
| DN-BLD-01 | Publish mode | Important | Self-contained? Framework-dependent? Single-file? |
| DN-BLD-02 | Docker | Important | Multi-stage Dockerfile? .NET SDK image + runtime image? |

---

## F7. Philosophy

| Principle | Description | Impact |
|-----------|-------------|--------|
| **Dependency Injection First** | Built-in DI container is the backbone; everything is a service | Register services in DI; avoid static classes and singletons outside DI |
| **Middleware Pipeline** | Request processing as an ordered pipeline of middleware | Order matters: auth before authorization, exception handler first |
| **Configuration Binding** | Strongly-typed options pattern (IOptions<T>) over string keys | Use `IOptions<T>` / `IOptionsSnapshot<T>`; never read raw config strings |
| **Convention-Based** | Naming conventions for controllers, actions, routes | Follow conventions (e.g., `[controller]Controller`, `Get`/`Post` prefixes) |

---

## F8. Toolchain Commands

| Field | Command |
|-------|---------|
| `build` | `dotnet build` |
| `test` | `dotnet test` |
| `lint` | `dotnet format --verify-no-changes` |
| `package_manager` | `dotnet` (NuGet) |

---

## F9. Scan Targets

#### Data Model
| Pattern | Description |
|---------|-------------|
| `DbSet<T>` properties in `DbContext` subclass | EF Core entity registration |
| Entity configuration in `OnModelCreating` or `IEntityTypeConfiguration<T>` | Fluent API entity config |
| `Migrations/` directory with EF Core migration files | Schema evolution |

#### API Endpoints
| Pattern | Description |
|---------|-------------|
| `[HttpGet]`, `[HttpPost]`, `[HttpPut]`, `[HttpDelete]` attributes on controller methods | Controller endpoint definitions |
| `app.MapGet()`, `app.MapPost()` in Program.cs | Minimal API endpoint definitions |
| `[Route("api/[controller]")]` attribute | Route template definitions |
