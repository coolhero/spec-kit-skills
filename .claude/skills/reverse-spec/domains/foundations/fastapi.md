# Foundation: FastAPI
<!-- Format: _foundation-core.md | ID prefix: FA (see § F4) -->

> Server framework Foundation for Python projects using FastAPI.
> Modern, async-first framework with automatic OpenAPI docs, Pydantic validation, and dependency injection.

---

## F0. Detection Signals

| Signal | Confidence |
|--------|-----------|
| `fastapi` in `pyproject.toml` or `requirements.txt` | HIGH |
| `from fastapi import FastAPI` in source | HIGH |
| `uvicorn` or `gunicorn` in dependencies | HIGH |
| `@app.get()`, `@app.post()` decorator patterns | MEDIUM |
| `main.py` or `app.py` with `FastAPI()` instantiation | MEDIUM |

---

## F1. Categories

| Code | Category | Description |
|------|----------|-------------|
| BST | App Bootstrap | App factory, project structure, lifespan events, ASGI config |
| SEC | Security | OAuth2 with JWT, API key auth, dependency-based auth |
| MID | Middleware | CORS, trusted host, GZip, custom ASGI middleware |
| API | API Design | Router organization, versioning, OpenAPI customization, pagination |
| DBS | Database | SQLAlchemy (async/sync), Tortoise ORM, Alembic migrations |
| PRC | Process Management | Uvicorn/Gunicorn workers, BackgroundTasks, Celery integration |
| HLT | Health Check | Health endpoint, startup/shutdown events |
| ERR | Error Handling | HTTPException, custom exception handlers, validation error format |
| LOG | Logging | Structured logging, request ID correlation, Loguru/structlog |
| TST | Testing | pytest + httpx AsyncClient, TestClient, fixtures, test DB |
| BLD | Build & Deploy | Docker multi-stage, uvicorn production config, static files |
| ENV | Environment Config | Pydantic BaseSettings, .env files, settings validation |

---

## F2. Decision Items

### BST — App Bootstrap
| ID | Item | Priority | Question |
|----|------|----------|----------|
| FA-BST-01 | App factory | Critical | Single `app = FastAPI()` vs factory function pattern? |
| FA-BST-02 | Python version | Critical | Python 3.11/3.12/3.13? Type hints level? |
| FA-BST-03 | Project structure | Important | Flat module vs domain-driven package structure? |

### SEC — Security
| ID | Item | Priority | Question |
|----|------|----------|----------|
| FA-SEC-01 | Auth strategy | Critical | OAuth2 + JWT? API key? Session-based? |
| FA-SEC-02 | Auth dependency | Critical | `Depends(get_current_user)` pattern? Scopes? |

### API — API Design
| ID | Item | Priority | Question |
|----|------|----------|----------|
| FA-API-01 | Router organization | Critical | `APIRouter` per domain? Include vs mount? |
| FA-API-02 | Validation | Critical | Pydantic v2 models? Custom validators? |
| FA-API-03 | Serialization | Important | `response_model` on every endpoint? `response_model_exclude`? |
| FA-API-04 | Versioning | Optional | URL prefix (`/v1/`)? Header-based? |

### DBS — Database
| ID | Item | Priority | Question |
|----|------|----------|----------|
| FA-DBS-01 | ORM | Critical | SQLAlchemy 2.0 (async)? Tortoise ORM? SQLModel? |
| FA-DBS-02 | Migrations | Critical | Alembic? Auto-generate? |
| FA-DBS-03 | Session management | Important | `Depends(get_db)` yield pattern? Async session? |

### TST — Testing
| ID | Item | Priority | Question |
|----|------|----------|----------|
| FA-TST-01 | Test client | Critical | `httpx.AsyncClient` (async)? `TestClient` (sync)? |
| FA-TST-02 | Fixtures | Important | pytest fixtures? Factory Boy? |

### BLD — Build & Deploy
| ID | Item | Priority | Question |
|----|------|----------|----------|
| FA-BLD-01 | ASGI server | Important | Uvicorn? Gunicorn + Uvicorn workers? Hypercorn? |
| FA-BLD-02 | Docker | Important | Multi-stage Dockerfile? Poetry/pip/uv for dependency install? |

---

## F7. Philosophy

| Principle | Description | Impact |
|-----------|-------------|--------|
| **Type-Driven** | Pydantic models and type hints drive validation, serialization, and docs | Define schemas as Pydantic models; never use raw dicts for API I/O |
| **Dependency Injection** | `Depends()` for composable, testable service injection | Use DI for DB sessions, auth, config; avoid global state |
| **Async-First** | Native async/await support with ASGI | Use `async def` endpoints; use async DB drivers (asyncpg, aiosqlite) |
| **Auto-Documentation** | OpenAPI/Swagger generated from code annotations | Keep `response_model`, `summary`, `tags` on all endpoints |

---

## F8. Toolchain Commands

| Field | Command |
|-------|---------|
| `build` | `docker build` or `uvicorn app.main:app` |
| `test` | `pytest` or `python -m pytest` |
| `lint` | `ruff check .` or `flake8` + `mypy .` |
| `format` | `ruff format .` or `black .` |
| `package_manager` | `pip` / `poetry` / `uv` |
| `install` | `pip install -r requirements.txt` or `poetry install` or `uv sync` |

---

## F9. Scan Targets

#### Data Model
| Pattern | Description |
|---------|-------------|
| `class X(Base)` in `models/` or `models.py` | SQLAlchemy model definitions |
| `class X(SQLModel)` | SQLModel hybrid ORM/Pydantic models |
| `class X(BaseModel)` in `schemas/` | Pydantic request/response schemas |
| Alembic `versions/` directory | Migration files |

#### API Endpoints
| Pattern | Description |
|---------|-------------|
| `@router.get()`, `@router.post()`, etc. | APIRouter endpoint definitions |
| `@app.get()`, `@app.post()`, etc. | Direct app endpoint definitions |
| `app.include_router(router, prefix=...)` | Router mounting with prefix |
| `Depends(...)` in endpoint signatures | Dependency injection points |
