# Foundation: Flask
<!-- Format: _foundation-core.md | ID prefix: FK (see § F4) -->

> Server framework Foundation for Python projects using Flask.
> Micro-framework with explicit extension ecosystem and app factory pattern.

---

## F0. Detection Signals

| Signal | Confidence |
|--------|-----------|
| `flask` in `requirements.txt` / `pyproject.toml` / `Pipfile` | HIGH |
| `Flask(__name__)` or `create_app()` factory pattern | HIGH |
| `@app.route()` or `@blueprint.route()` decorators | HIGH |
| `from flask import Flask` import | MEDIUM |

---

## F1. Categories

| Code | Category | Description |
|------|----------|-------------|
| BST | App Bootstrap | App factory pattern, blueprints, extension loading order |
| SEC | Security | Flask-Login, Flask-JWT-Extended, Flask-WTF CSRF, Flask-Talisman |
| MID | Middleware | before_request/after_request, error handlers, WSGI middleware |
| API | API Design | Flask-RESTful vs Flask-RESTX vs Marshmallow, blueprint organization |
| DBS | Database | Flask-SQLAlchemy, Flask-Migrate/Alembic, connection management |
| PRC | Process Management | Gunicorn, uWSGI, Celery integration |
| HLT | Health Check | Health blueprint, readiness checks |
| ERR | Error Handling | @app.errorhandler, custom exception classes, error response format |
| LOG | Logging | Flask app.logger, structlog, request logging |
| TST | Testing | pytest, Flask test client, conftest fixtures |
| BLD | Build & Deploy | WSGI deployment, Docker, static files |
| ENV | Environment Config | Flask config from env, python-dotenv, instance folder |

---

## F2. Decision Items

### BST — App Bootstrap
| ID | Item | Priority | Question |
|----|------|----------|----------|
| FK-BST-01 | App factory | Critical | `create_app()` factory pattern or global `app = Flask(__name__)`? |
| FK-BST-02 | Blueprints | Critical | Blueprint-per-domain? Registration order? |
| FK-BST-03 | Extensions | Important | Which Flask-* extensions? Initialization order? |

### SEC — Security
| ID | Item | Priority | Question |
|----|------|----------|----------|
| FK-SEC-01 | Auth extension | Critical | Flask-Login? Flask-JWT-Extended? Flask-Security? |
| FK-SEC-02 | CSRF | Important | Flask-WTF CSRF for forms? Exempt for API endpoints? |

### API — API Design
| ID | Item | Priority | Question |
|----|------|----------|----------|
| FK-API-01 | API style | Critical | Flask-RESTful? Flask-RESTX (with Swagger)? Plain Flask views? Marshmallow? |
| FK-API-02 | Serialization | Important | Marshmallow schemas? Manual dict construction? |
| FK-API-03 | Documentation | Optional | Flask-RESTX auto-Swagger? Flasgger? |

### DBS — Database
| ID | Item | Priority | Question |
|----|------|----------|----------|
| FK-DBS-01 | ORM | Critical | Flask-SQLAlchemy? Raw SQLAlchemy? Other? |
| FK-DBS-02 | Migrations | Critical | Flask-Migrate (Alembic)? Manual? |

### TST — Testing
| ID | Item | Priority | Question |
|----|------|----------|----------|
| FK-TST-01 | Framework | Critical | pytest with Flask test client? |
| FK-TST-02 | Fixtures | Important | conftest.py app/client fixtures? factory_boy? |

---

## F7. Philosophy

| Principle | Description | Impact |
|-----------|-------------|--------|
| **Micro-Framework** | Flask provides the minimum; everything else is an explicit choice | Every extension (ORM, auth, mail) must be explicitly chosen and justified |
| **Extension Ecosystem** | Flask-* packages provide structured extensibility | Prefer established Flask-* extensions over custom implementations |
| **Explicit App Factory** | `create_app()` pattern for testability and configuration | Always use app factory; avoid global app object |
| **Blueprint Modularity** | Composable app structure via blueprints | One blueprint per domain; register in factory |

---

## F8. Toolchain Commands

| Field | Command |
|-------|---------|
| `test` | `pytest` |
| `lint` | See S3b Python section in `smart-sdd/domains/_core.md` |
| `package_manager` | `pip` / `uv` / `poetry` |

---

## F9. Scan Targets

#### Data Model
| Pattern | Description |
|---------|-------------|
| `class X(db.Model)` (Flask-SQLAlchemy) | Model definitions |
| `alembic/versions/` migration files | Schema evolution |
| `db.Column`, `db.relationship`, `db.ForeignKey` | Field and relationship declarations |

#### API Endpoints
| Pattern | Description |
|---------|-------------|
| `@app.route()`, `@blueprint.route()` decorators | Route definitions |
| Flask-RESTful `Resource` class methods (`get`, `post`, `put`, `delete`) | REST endpoint methods |
| Flask-RESTX `@ns.route()` | Namespace-scoped routes |
