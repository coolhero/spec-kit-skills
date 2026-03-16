# Foundation: Django

> Server framework Foundation for Python projects using Django.
> Batteries-included framework with built-in ORM, admin, auth, and convention-based app structure.

---

## F0. Detection Signals

| Signal | Confidence |
|--------|-----------|
| `django` in `requirements.txt` / `pyproject.toml` / `Pipfile` | HIGH |
| `manage.py` + `settings.py` with `INSTALLED_APPS` | HIGH |
| `urls.py` with `urlpatterns` | HIGH |
| `wsgi.py` or `asgi.py` application entry | MEDIUM |

---

## F1. Categories

| Code | Category | Description |
|------|----------|-------------|
| BST | App Bootstrap | Project/app structure, INSTALLED_APPS, ASGI/WSGI, middleware loading |
| SEC | Security | Auth backends, CSRF, session engine, password hashers, Allowed Hosts |
| MID | Middleware | MIDDLEWARE list ordering, custom middleware classes |
| API | API Design | DRF vs Django Ninja, serializers, viewsets, URL router, throttling |
| DBS | Database | Django ORM, multi-DB routing, migration strategy, custom managers/querysets |
| PRC | Process Management | Gunicorn/uvicorn workers, Celery integration, management commands |
| HLT | Health Check | Health endpoint, django-health-check, readiness probes |
| ERR | Error Handling | DRF exception handler, custom middleware, error templates |
| LOG | Logging | Django LOGGING dict config, structured logging, request logging |
| TST | Testing | pytest-django, TestCase, factory_boy, fixtures, coverage |
| BLD | Build & Deploy | collectstatic, whitenoise, Docker, ALLOWED_HOSTS |
| ENV | Environment Config | django-environ / environs, settings split dev/prod, SECRET_KEY management |

---

## F2. Decision Items

### BST — App Bootstrap
| ID | Item | Priority | Question |
|----|------|----------|----------|
| DJ-BST-01 | App structure | Critical | Single app or multiple Django apps? App naming convention? |
| DJ-BST-02 | ASGI vs WSGI | Critical | ASGI (async support) or WSGI (traditional)? |
| DJ-BST-03 | Settings module | Important | Single settings.py or split (base/dev/prod)? |

### SEC — Security
| ID | Item | Priority | Question |
|----|------|----------|----------|
| DJ-SEC-01 | Auth backend | Critical | Django built-in? django-allauth? Social auth? JWT (djangorestframework-simplejwt)? |
| DJ-SEC-02 | CSRF strategy | Important | CSRF middleware for forms? Exempt for API? |
| DJ-SEC-03 | Password policy | Important | AUTH_PASSWORD_VALIDATORS config? |

### API — API Design
| ID | Item | Priority | Question |
|----|------|----------|----------|
| DJ-API-01 | API framework | Critical | Django REST Framework? Django Ninja? Plain Django views? |
| DJ-API-02 | Serialization | Critical | DRF ModelSerializer? Pydantic (Ninja)? Manual serialization? |
| DJ-API-03 | URL routing | Important | DRF DefaultRouter? Namespace-based URL organization? |
| DJ-API-04 | Pagination | Important | DRF PageNumberPagination? CursorPagination? LimitOffsetPagination? |

### DBS — Database
| ID | Item | Priority | Question |
|----|------|----------|----------|
| DJ-DBS-01 | Database engine | Critical | PostgreSQL? MySQL? SQLite (dev only)? |
| DJ-DBS-02 | Migration strategy | Critical | Auto-generated migrations? Squash policy? |
| DJ-DBS-03 | Custom managers | Important | Custom QuerySet/Manager for common queries? |

### ERR — Error Handling
| ID | Item | Priority | Question |
|----|------|----------|----------|
| DJ-ERR-01 | API errors | Critical | DRF custom exception handler? Error response format? |

### LOG — Logging
| ID | Item | Priority | Question |
|----|------|----------|----------|
| DJ-LOG-01 | Config style | Important | Django LOGGING dict? structlog? |

### TST — Testing
| ID | Item | Priority | Question |
|----|------|----------|----------|
| DJ-TST-01 | Framework | Critical | pytest-django or Django TestCase? |
| DJ-TST-02 | Fixtures | Important | factory_boy? Django fixtures? pytest fixtures? |

### BLD — Build & Deploy
| ID | Item | Priority | Question |
|----|------|----------|----------|
| DJ-BLD-01 | Static files | Important | whitenoise? S3/CDN? collectstatic in Docker build? |
| DJ-BLD-02 | WSGI server | Critical | Gunicorn? uvicorn (ASGI)? Worker count strategy? |

---

## F7. Philosophy

| Principle | Description | Impact |
|-----------|-------------|--------|
| **Batteries Included** | Admin, ORM, auth, forms, migrations built-in — use them before reaching for third-party | Don't replace Django ORM with SQLAlchemy unless there's a strong reason |
| **Don't Repeat Yourself (DRY)** | Single source of truth for every piece of knowledge | Model fields define DB schema + validation + serialization; don't duplicate |
| **Explicit over Implicit** | Settings are explicit; middleware order matters; URL patterns are declared | Always declare ALLOWED_HOSTS, CSRF settings, CORS origins explicitly |
| **Loose Coupling** | Apps are self-contained units with clear boundaries | Each Django app should be independently testable; avoid circular app imports |

---

## F8. Toolchain Commands

| Field | Command |
|-------|---------|
| `build` | `python manage.py collectstatic --noinput` |
| `test` | `pytest` or `python manage.py test` |
| `lint` | See S3b Python section in `smart-sdd/domains/_core.md` |
| `package_manager` | `pip` / `uv` / `poetry` |

---

## F9. Scan Targets

#### Data Model
| Pattern | Description |
|---------|-------------|
| `class X(models.Model)` in `**/models.py` or `**/models/*.py` | Django model definitions |
| `db/migrations/` numbered migration files | Schema evolution history |
| `ForeignKey`, `ManyToManyField`, `OneToOneField` | Relationship declarations |

#### API Endpoints
| Pattern | Description |
|---------|-------------|
| `urlpatterns` in `**/urls.py` with `path()` / `re_path()` | URL route definitions |
| DRF `@action`, `ViewSet`, `APIView` classes | REST endpoint definitions |
| Django Ninja `@router.get()`, `@router.post()` | Ninja-style endpoint definitions |
