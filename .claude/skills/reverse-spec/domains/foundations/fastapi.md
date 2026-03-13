# FastAPI Foundation

## F0. Detection Signals

- `fastapi` in pyproject.toml `dependencies` or requirements.txt
- `uvicorn` or `gunicorn` in dependencies
- `@app.get()`, `@app.post()` decorator patterns
- `from fastapi import FastAPI` imports
- `main.py` or `app.py` with FastAPI app instantiation

---

## F1. Foundation Categories

| Category Code | Category Name | Item Count | Description |
|--------------|---------------|------------|-------------|
| BST | App Bootstrap | 3 | App factory pattern, project structure, lifespan events |
| SEC | Security | 4 | Auth strategy, auth dependency, JWT config, password hashing |
| MID | Middleware | 3 | Middleware stack, CORS, trusted host |
| API | API Design | 5 | Versioning, router organization, OpenAPI, pagination, file uploads |
| DBS | Database | 5 | ORM, async SQLAlchemy, connection pool, Alembic migrations |
| PRC | Process Management | 3 | ASGI server, worker count, background tasks |
| HLT | Health Check | 2 | Health endpoint, request ID/correlation |
| ERR | Error Handling | 3 | Error handling strategy, custom exceptions, response model |
| LOG | Logging & Monitoring | 2 | Logging configuration, log format |
| TST | Testing | 4 | Testing framework, fixtures, test client, test database |
| BLD | Build & Deploy | 3 | HTTPS/TLS, GZip compression, rate limiting |
| ENV | Environment Config | 4 | Settings management, settings validation, Pydantic model strategy, environment config |

<!-- TODO: Full itemization — 41 items across 12 categories -->
<!-- See _foundation-core.md for Foundation file format specification -->
<!-- Refer to research data for complete FastAPI Foundation item enumeration -->
