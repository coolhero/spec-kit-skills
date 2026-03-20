# Foundation: Python (Standalone)

> **Status**: Detection stub. Full F1-F8 sections TODO.
> Projects matching this Foundation use Case B (Generic Foundation) with these architecture notes.

## F0: Detection Signals
- `pyproject.toml` or `setup.py` or `requirements.txt` in root
- `.py` source files present
- No Django, Flask, or FastAPI in dependencies (those have dedicated Foundations)
- Optional: `poetry.lock`, `uv.lock`, `Pipfile.lock` for package manager detection

## Architecture Notes (for SBI extraction)
- **Package managers**: pip, poetry, uv, hatch, pdm — detect from lockfile
- **Type checking**: mypy (`mypy.ini`, `pyproject.toml [tool.mypy]`), pyright (`pyrightconfig.json`)
- **Async**: asyncio (stdlib), trio, anyio — detect from imports
- **Testing**: pytest (`conftest.py`, `pytest.ini`), unittest
- **Formatting**: black, ruff format — detect from config
- **Entry points**: `console_scripts` in pyproject.toml, `__main__.py`, Click/Typer CLI
