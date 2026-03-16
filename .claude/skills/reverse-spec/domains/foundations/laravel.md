# Foundation: Laravel
<!-- Format: _foundation-core.md | ID prefix: LV (see § F4) -->

> Server framework Foundation for PHP projects using Laravel.
> Elegant framework with Eloquent ORM, Artisan CLI, and rich ecosystem (Horizon, Sanctum, Sail).

---

## F0. Detection Signals

| Signal | Confidence |
|--------|-----------|
| `laravel/framework` in `composer.json` | HIGH |
| `artisan` file in project root | HIGH |
| `config/app.php` with `'providers'` array | HIGH |
| `routes/web.php` or `routes/api.php` | MEDIUM |

---

## F1. Categories

| Code | Category | Description |
|------|----------|-------------|
| BST | App Bootstrap | Service providers, app.php config, bootstrappers |
| SEC | Security | Sanctum vs Passport, gates/policies, CSRF, encryption |
| MID | Middleware | HTTP kernel middleware stack, route middleware, groups |
| API | API Design | API resources, route model binding, FormRequest validation |
| DBS | Database | Eloquent ORM, query builder, migrations, seeders/factories |
| PRC | Process Management | Queues (Horizon), scheduler, Octane/Swoole |
| HLT | Health Check | Health route, up command |
| ERR | Error Handling | Exception handler, renderable exceptions |
| LOG | Logging | Monolog channels, stack driver, Slack/Papertrail |
| TST | Testing | PHPUnit/Pest, feature tests, RefreshDatabase |
| BLD | Build & Deploy | Vite asset compilation, Docker/Sail, Forge/Vapor |
| ENV | Environment Config | .env file, config caching, environment detection |
| DXP | Developer Experience | Artisan commands, Tinker REPL, Telescope, Sail |

---

## F2. Decision Items

### BST — App Bootstrap
| ID | Item | Priority | Question |
|----|------|----------|----------|
| LV-BST-01 | Service providers | Critical | Custom service providers? Registration vs boot order? |
| LV-BST-02 | PHP version | Critical | PHP 8.2/8.3+? Type declarations enforced? |

### SEC — Security
| ID | Item | Priority | Question |
|----|------|----------|----------|
| LV-SEC-01 | API auth | Critical | Sanctum (SPA + token)? Passport (OAuth2)? |
| LV-SEC-02 | Authorization | Important | Gates? Policies per model? |
| LV-SEC-03 | CSRF | Important | Standard CSRF for web routes? Excluded for API? |

### API — API Design
| ID | Item | Priority | Question |
|----|------|----------|----------|
| LV-API-01 | Route style | Critical | `Route::apiResource()`? Manual route definitions? Versioning? |
| LV-API-02 | Validation | Critical | FormRequest classes? Inline validation? |
| LV-API-03 | Serialization | Important | API Resources (JsonResource)? Fractal? |

### DBS — Database
| ID | Item | Priority | Question |
|----|------|----------|----------|
| LV-DBS-01 | Database | Critical | MySQL? PostgreSQL? SQLite? |
| LV-DBS-02 | Eloquent patterns | Important | Repository pattern over Eloquent? Scopes? Accessors/mutators? |
| LV-DBS-03 | Factories & seeders | Important | Model factories for testing? Database seeders? |

### TST — Testing
| ID | Item | Priority | Question |
|----|------|----------|----------|
| LV-TST-01 | Framework | Critical | PHPUnit or Pest? |
| LV-TST-02 | DB testing | Important | RefreshDatabase? DatabaseTransactions? |

### BLD — Build & Deploy
| ID | Item | Priority | Question |
|----|------|----------|----------|
| LV-BLD-01 | Asset build | Important | Vite (default)? Webpack Mix (legacy)? |
| LV-BLD-02 | Deploy | Important | Forge? Vapor (serverless)? Docker? Kamal? |

---

## F7. Philosophy

| Principle | Description | Impact |
|-----------|-------------|--------|
| **Elegant Syntax** | Expressive, readable API over verbose configuration | Use Eloquent fluent API, collection pipelines, helper functions |
| **Service Container** | IoC container is the foundation of the framework | Bind interfaces to implementations; use constructor injection |
| **Facades** | Static-like access to container services for convenience | Use facades in application code; use DI in libraries/packages |
| **Convention over Configuration** | Artisan generators, naming conventions, directory structure | Follow Laravel conventions (model = singular, table = plural, etc.) |

---

## F8. Toolchain Commands

| Field | Command |
|-------|---------|
| `build` | `php artisan optimize` + `npm run build` |
| `test` | `php artisan test` or `vendor/bin/pest` |
| `lint` | `vendor/bin/phpstan analyse` or `vendor/bin/pint --test` |
| `package_manager` | `composer` |
| `install` | `composer install` |

---

## F9. Scan Targets

#### Data Model
| Pattern | Description |
|---------|-------------|
| `class X extends Model` in `app/Models/*.php` | Eloquent model definitions |
| `$fillable`, `$casts`, `$hidden` properties | Model field configuration |
| `database/migrations/*.php` with `Schema::create` / `Schema::table` | Migration files |
| `belongsTo`, `hasMany`, `hasOne`, `belongsToMany` | Relationship declarations |

#### API Endpoints
| Pattern | Description |
|---------|-------------|
| `Route::get()`, `Route::post()`, etc. in `routes/api.php` | API route definitions |
| `Route::apiResource()`, `Route::resource()` | RESTful resource routes |
| `Route::middleware()->group()` | Middleware-grouped route sets |
