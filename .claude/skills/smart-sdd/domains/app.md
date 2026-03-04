# Domain Profile: app (smart-sdd)

> Default domain. For reverse-spec analysis profiles, see `../reverse-spec/domains/app.md`.
> This file covers smart-sdd-specific domain behavior: demo, parity, and verification.

---

## 1. Demo Pattern

- **Type**: Server-based
- **Default mode**: Launch dev server with demo data -> print "Try it" instructions (URLs to open, curl commands to run, CLI invocations -- at least 2 concrete instructions) -> keep running until Ctrl+C
- **CI mode**: Quick health check (start server, verify health endpoint, exit with status code)
- **Script location**: `demos/F00N-name.sh` (or `.ts`/`.py`/etc.)
- **"Try it" instructions**: URLs to browse, API endpoints to call, CLI commands to run

### Demo Anti-Patterns (REJECT these)

- A script that runs curl assertions, prints "3/3 passed", and exits -- that's a test suite, not a demo
- A markdown file with "## Demo Steps" and manual instructions
- Showing demo steps as text in the chat instead of writing a script file
- A script that only runs tests without starting the actual Feature

### Demo Code Markers

| Marker | Meaning |
|--------|---------|
| `@demo-only` | Remove after demo -- throwaway scaffolding |
| `@demo-scaffold` | Extend later -- promotable to production code |

### Demo Script Requirements

- Header comment mapping FR-###/SC-### coverage
- Demo Components header listing component status
- Default mode: interactive (keep running)
- `--ci` flag: health check -> exit

---

## 2. Parity Dimensions

### Structural Parity

| Category | What to Compare |
|----------|----------------|
| API endpoints | Route definitions, controllers, endpoint decorators -- match original routes |
| DB entities | Schema definitions, model classes -- match original table/collection structure |
| Test files | Test file presence and coverage scope -- match original test coverage |
| UI components | Component tree structure, page routes -- match original frontend structure (frontend/fullstack only) |
| Source behaviors | Exported functions, public methods, handlers -- match P1/P2 behaviors from Source Behavior Inventory |

### Logic Parity

| Category | What to Compare |
|----------|----------------|
| Business rules | State transitions, validation rules, authorization checks -- match original business logic |
| Test cases | Test scenario coverage -- original test cases should have equivalents |

---

## 3. Verify Steps

| Step | Required | Detection | Description |
|------|----------|-----------|-------------|
| **Test** | Yes (BLOCKING) | Detect from `package.json` scripts, `pyproject.toml`, `Makefile`, `Cargo.toml` | Run unit + integration tests. Failure blocks pipeline |
| **Build** | Yes (BLOCKING) | Detect build command from project config | Run project build. Failure blocks pipeline |
| **Lint** | Yes (BLOCKING) | Detect lint tool from project config | Run lint check. Failure blocks pipeline |
| **Demo-Ready** | Conditional (if constitution VI active) | Check `demos/F00N-name.sh` exists | Execute demo script with `--ci` flag. Verify health check passes |

### Limited Verification

When external dependencies (third-party APIs, paid services, hardware) block test/demo execution:
- User can select "Acknowledge limited verification" at the verify Checkpoint
- Status recorded as `limited` instead of `success`
- Merge step accepts `limited` status with warning
