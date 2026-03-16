# Foundation: {Framework Name}

<!-- Format defined in _foundation-core.md. Copy this template when adding a new Foundation. -->
<!-- Delete this comment block after filling in the template. -->
<!-- Choose between Full format (40+ items, F3/F4 included) or Compact format (key items only). -->
<!-- See ARCHITECTURE-EXTENSIBILITY.md § "Foundation Format Variants" for format guidance. -->

> Server/Desktop/Frontend framework Foundation for {Language} projects using {Framework}.
> {One-line description of the framework's key characteristics.}

---

## F0. Detection Signals

| Signal | Confidence |
|--------|-----------|
| `{package-name}` in `{config-file}` | HIGH |
| `{entry-point-pattern}` in source | HIGH |
| `{secondary-signal}` | MEDIUM |

---

## F1. Categories

| Code | Category | Description |
|------|----------|-------------|
| BST | App Bootstrap | {How the app starts} |
| SEC | Security | {Auth, authorization, CORS} |
| ... | ... | ... |

---

## F2. Decision Items

### BST — App Bootstrap
| ID | Item | Priority | Question |
|----|------|----------|----------|
| {FW}-BST-01 | {Item name} | Critical | {Decision question} |

<!-- ID format: {FW}-{CAT}-{NN} where FW is the 2-3 letter framework code from _foundation-core.md § F4 -->

---

## F7. Philosophy

| Principle | Description | Impact |
|-----------|-------------|--------|
| **{Principle Name}** | {What this principle means} | {How it affects architecture decisions} |

---

## F8. Toolchain Commands

| Field | Command |
|-------|---------|
| `build` | `{build command}` |
| `test` | `{test command}` |
| `lint` | `{lint command}` |
| `package_manager` | `{package manager}` |
| `install` | `{install command}` |

---

## F9. Scan Targets

#### Data Model
| Pattern | Description |
|---------|-------------|
| `{ORM pattern}` in `{file path}` | {What this pattern captures} |

#### API Endpoints
| Pattern | Description |
|---------|-------------|
| `{route pattern}` in `{file path}` | {What this pattern captures} |
