# Foundation: Python (Standalone)
<!-- Format: _foundation-core.md | ID prefix: PY (see § F4) -->

## F0. Detection Signals

- `pyproject.toml` or `setup.py` or `requirements.txt` in root
- `.py` source files present
- No Django, Flask, or FastAPI in dependencies (those have dedicated Foundations)
- Optional: `poetry.lock`, `uv.lock`, `Pipfile.lock` for package manager detection

---

## F1. Foundation Categories

| Category Code | Category Name | Item Count | Description |
|--------------|---------------|------------|-------------|
| BST | App Bootstrap | 3 | Virtual env, entry point pattern, package structure |
| SEC | Security | 3 | Secrets management, dependency audit, sandboxing |
| PKG | Package Management | 3 | Package manager, lock strategy, pyproject.toml |
| TST | Testing | 3 | Test framework, coverage, fixtures |
| TYP | Type Checking | 3 | Type checker, strictness, ignore policies |
| FMT | Formatting & Linting | 3 | Formatter, linter, import sorting |
| BLD | Build & Distribution | 3 | Build backend, wheel/sdist, publish target |
| ENV | Environment | 3 | Virtual env tool, .env handling, python version |
| LOG | Logging | 2 | Logging library, log format |
| ASY | Async | 2 | Async library, event loop policy |
| DXP | Developer Experience | 3 | Pre-commit, task runner, Makefile |

---

## F2. Foundation Items

### BST: App Bootstrap

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| PY-BST-01 | Entry point pattern | How the app is launched | choice (__main__.py / console_scripts / click-cli / typer-cli / script) | Critical |
| PY-BST-02 | Package structure | Source layout convention | choice (src-layout / flat-layout) | Critical |
| PY-BST-03 | Python version | Minimum supported Python version | config | Critical |

### SEC: Security

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| PY-SEC-01 | Secrets management | How secrets are loaded | choice (env-vars / dotenv / vault / keyring / none) | Critical |
| PY-SEC-02 | Dependency audit | Vulnerability scanning tool | choice (pip-audit / safety / trivy / none) | Important |
| PY-SEC-03 | Sandboxing | Restricting runtime capabilities | choice (seccomp / apparmor / none) | Important |

### PKG: Package Management

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| PY-PKG-01 | Package manager | Which tool manages dependencies | choice (pip / poetry / pdm / uv / hatch) | Critical |
| PY-PKG-02 | Lock strategy | How dependency versions are pinned | choice (lockfile / pinned-requirements / hash-checking) | Critical |
| PY-PKG-03 | Config file | Project metadata format | choice (pyproject.toml / setup.py / setup.cfg) | Important |

### TST: Testing

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| PY-TST-01 | Test framework | Primary testing framework | choice (pytest / unittest / doctest) | Critical |
| PY-TST-02 | Coverage tool | Code coverage measurement | choice (coverage.py / pytest-cov / none) | Important |
| PY-TST-03 | Fixture strategy | Test data and fixture management | choice (pytest-fixtures / factories / conftest-hierarchy) | Important |

### TYP: Type Checking

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| PY-TYP-01 | Type checker | Static type checking tool | choice (mypy / pyright / pytype / none) | Important |
| PY-TYP-02 | Strictness level | Type checking strictness | choice (strict / basic / gradual) | Important |
| PY-TYP-03 | Ignore policy | When type: ignore is permitted | config | Important |

### FMT: Formatting & Linting

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| PY-FMT-01 | Formatter | Code formatting tool | choice (ruff-format / black / autopep8 / yapf) | Important |
| PY-FMT-02 | Linter | Code linting tool | choice (ruff / flake8 / pylint) | Important |
| PY-FMT-03 | Import sorting | Import ordering tool | choice (ruff-isort / isort / none) | Important |

### BLD: Build & Distribution

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| PY-BLD-01 | Build backend | Build system for packages | choice (setuptools / poetry-core / hatchling / flit-core / maturin) | Important |
| PY-BLD-02 | Distribution formats | Artifact types produced | choice (wheel+sdist / wheel-only / sdist-only) | Important |
| PY-BLD-03 | Publish target | Package registry | choice (pypi / private-index / none) | Important |

### ENV: Environment

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| PY-ENV-01 | Virtual env tool | Virtual environment manager | choice (venv / conda / pyenv-virtualenv / uv-venv) | Critical |
| PY-ENV-02 | Dotenv handling | How .env files are loaded | choice (python-dotenv / pydantic-settings / environs / none) | Important |
| PY-ENV-03 | Python version management | How Python versions are managed | choice (pyenv / asdf / system / uv) | Important |

### LOG: Logging

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| PY-LOG-01 | Logging library | Application logging approach | choice (stdlib-logging / structlog / loguru) | Important |
| PY-LOG-02 | Log format | Log output format | choice (json / text / key-value) | Important |

### ASY: Async

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| PY-ASY-01 | Async library | Async runtime | choice (asyncio / trio / anyio / none) | Important |
| PY-ASY-02 | Event loop policy | Event loop configuration | choice (default / uvloop / winloop / none) | Important |

### DXP: Developer Experience

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| PY-DXP-01 | Pre-commit hooks | Git hook management | choice (pre-commit / lefthook / none) | Important |
| PY-DXP-02 | Task runner | Automation for common tasks | choice (tox / nox / just / make / none) | Important |
| PY-DXP-03 | Makefile | Whether Makefile is used for dev commands | binary | Important |

---

## F3. Extraction Rules (reverse-spec)

| Category | Extraction Method |
|----------|------------------|
| BST | Check for `__main__.py`, `console_scripts` in pyproject.toml, Click/Typer imports. Check src/ vs flat layout. |
| SEC | Search for dotenv, vault, keyring imports. Check for pip-audit in CI config. |
| PKG | Detect lockfile type (poetry.lock, uv.lock, requirements.txt). Read pyproject.toml build-system. |
| TST | Check for conftest.py, pytest.ini, pyproject.toml [tool.pytest]. Search for coverage config. |
| TYP | Look for mypy.ini, pyrightconfig.json, pyproject.toml [tool.mypy]. Check strictness settings. |
| FMT | Search for ruff.toml, .flake8, pyproject.toml [tool.black]. Check for isort config. |
| BLD | Read pyproject.toml [build-system]. Check for build scripts in CI. |
| ENV | Detect venv/conda from CI or Makefile. Search for python-dotenv or pydantic-settings imports. |
| LOG | Search for logging.getLogger, structlog, loguru imports. Check log format in config. |
| ASY | Search for asyncio, trio, anyio imports. Check for uvloop in entry point. |
| DXP | Look for .pre-commit-config.yaml, tox.ini, noxfile.py, Makefile. |

---

## F4. T0 Feature Grouping

| T0 Feature | Foundation Categories | Items |
|------------|----------------------|-------|
| F000-python-bootstrap-env | BST + ENV + PKG | 9 |
| F000-security-audit | SEC | 3 |
| F000-testing-types | TST + TYP | 6 |
| F000-code-quality | FMT + LOG | 5 |
| F000-build-async | BLD + ASY | 5 |
| F000-dev-experience | DXP | 3 |

---

## F7. Framework Philosophy

| Principle | Description | Implication |
|-----------|-------------|-------------|
| **Explicit is better than implicit** | Python values clarity over magic — every import, dependency, and configuration choice should be visible and traceable | No hidden auto-imports; dependencies declared in pyproject.toml; config loaded explicitly (not magically resolved); type hints preferred over duck typing |
| **Batteries included** | Python stdlib covers logging, testing, async, HTTP — use it before reaching for third-party | Prefer stdlib logging over loguru for simple cases; use unittest if pytest is overkill; asyncio before trio unless cancellation semantics matter |
| **One obvious way to do it** | Avoid multiple tools doing the same thing — converge on one formatter, one linter, one test runner | ruff replaces flake8+isort+pyflakes; pick one package manager and stick with it; don't mix pytest and unittest in the same project |
