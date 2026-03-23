# Foundation: Go (Standalone)
<!-- Format: _foundation-core.md | ID prefix: GO (see § F4) -->

## F0. Detection Signals

- `go.mod` present in root
- No `go-chi/chi` or `gin-gonic/gin` in dependencies (those use `go-chi.md`)
- `.go` source files present

---

## F1. Foundation Categories

| Category Code | Category Name | Item Count | Description |
|--------------|---------------|------------|-------------|
| BST | App Bootstrap | 3 | Entry points, project structure, init pattern |
| SEC | Security | 2 | Vulnerability scanning, dependency audit |
| PKG | Module Management | 3 | go.mod, workspace, vendoring |
| TST | Testing | 3 | Test framework, table-driven tests, race detector |
| BLD | Build & Tooling | 3 | Build flags, cross-compilation, release |
| ERR | Error Handling | 3 | Wrapping, sentinel errors, error types |
| CON | Concurrency | 3 | Goroutines, context propagation, sync primitives |
| FMT | Formatting | 3 | gofmt, staticcheck, linter |
| LOG | Logging | 2 | Logging library, log level strategy |
| ENV | Configuration | 3 | Config library, .env handling, flags |
| DXP | Developer Experience | 3 | Makefile, go generate, DI tool |

---

## F2. Foundation Items

### BST: App Bootstrap

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| GO-BST-01 | Entry point structure | How binaries are organized | choice (cmd/ per binary / single main.go / monorepo workspace) | Critical |
| GO-BST-02 | Internal package convention | Whether internal/ is used for private packages | binary | Critical |
| GO-BST-03 | Init pattern | Application initialization approach | choice (functional / struct-based / fx-wire DI) | Important |

### SEC: Security

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| GO-SEC-01 | Vulnerability scanning | How vulnerabilities are detected | choice (govulncheck / trivy / snyk / none) | Critical |
| GO-SEC-02 | gosec analysis | Static security analysis | choice (gosec / semgrep / none) | Important |

### PKG: Module Management

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| GO-PKG-01 | Module strategy | go.mod module path and versioning | config | Critical |
| GO-PKG-02 | Workspace | Whether Go workspace is used for multi-module repos | binary | Important |
| GO-PKG-03 | Vendoring | Whether `vendor/` directory is committed | binary | Important |

### TST: Testing

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| GO-TST-01 | Test framework | Testing approach and helpers | choice (stdlib / testify / gocheck) | Critical |
| GO-TST-02 | Table-driven tests | Whether table-driven test pattern is standard | binary | Important |
| GO-TST-03 | Race detector | Whether `-race` flag is used in CI | binary | Important |

### BLD: Build & Tooling

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| GO-BLD-01 | Build flags | ldflags for version injection, CGO policy | config | Critical |
| GO-BLD-02 | Cross-compilation | Target OS/arch matrix | config | Important |
| GO-BLD-03 | Release tooling | Release automation | choice (goreleaser / ko / manual) | Important |

### ERR: Error Handling

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| GO-ERR-01 | Error wrapping | fmt.Errorf %w convention enforcement | config | Critical |
| GO-ERR-02 | Sentinel errors | Whether sentinel errors (var ErrNotFound) are used | binary | Critical |
| GO-ERR-03 | Custom error types | Whether typed errors with errors.Is/As are standard | binary | Important |

### CON: Concurrency

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| GO-CON-01 | Context propagation | context.Context passing convention | config | Critical |
| GO-CON-02 | Goroutine management | How goroutine lifecycles are managed | choice (errgroup / manual / conc) | Critical |
| GO-CON-03 | Sync primitives | Mutex vs channel preference | choice (channels-first / mutex-first / mixed) | Important |

### FMT: Formatting

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| GO-FMT-01 | Formatter | Code formatting tool | choice (gofmt / goimports) | Critical |
| GO-FMT-02 | Linter | Linting aggregator | choice (golangci-lint / staticcheck / revive) | Critical |
| GO-FMT-03 | Lint config | Custom lint rules and exclusions | config | Important |

### LOG: Logging

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| GO-LOG-01 | Logging library | Structured logging library | choice (slog / zap / zerolog) | Important |
| GO-LOG-02 | Log level strategy | How log levels are managed | choice (env-based / flag-based / config-file) | Important |

### ENV: Configuration

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| GO-ENV-01 | Config library | Configuration management | choice (viper / envconfig / koanf / stdlib-flags) | Important |
| GO-ENV-02 | Dotenv handling | Whether .env files are used in development | choice (godotenv / direnv / none) | Important |
| GO-ENV-03 | CLI flags | Flag parsing library | choice (pflag / cobra / stdlib-flag / kong) | Important |

### DXP: Developer Experience

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| GO-DXP-01 | Makefile | Whether Makefile is the task runner | binary | Important |
| GO-DXP-02 | Code generation | go generate usage and generators | config | Important |
| GO-DXP-03 | DI approach | Dependency injection strategy | choice (wire / fx / manual / none) | Important |

---

## F3. Extraction Rules (reverse-spec)

| Category | Extraction Method |
|----------|------------------|
| BST | Check for cmd/ directory structure. Count main packages. Look for wire/fx imports. |
| SEC | Search CI config for govulncheck/gosec. Check Makefile for security targets. |
| PKG | Read go.mod for module path and Go version. Check for go.work file. Look for vendor/ directory. |
| TST | Search for testify imports. Check CI for `-race` flag. Look for table-driven test patterns. |
| BLD | Check Makefile/CI for ldflags, GOOS/GOARCH, goreleaser config. |
| ERR | Search for `fmt.Errorf("%w"`, sentinel `var Err` declarations, custom error type `func (e *` patterns. |
| CON | Search for `context.Context` in function signatures. Look for errgroup, sync.Mutex, channel usage. |
| FMT | Check for .golangci.yml. Search CI for gofmt/goimports checks. |
| LOG | Search for slog, zap, zerolog imports. Check logger initialization patterns. |
| ENV | Search for viper, envconfig, godotenv imports. Check for .env files. |
| DXP | Look for Makefile, go generate directives, wire/fx in go.mod. |

---

## F4. T0 Feature Grouping

| T0 Feature | Foundation Categories | Items |
|------------|----------------------|-------|
| F000-go-bootstrap-modules | BST + PKG | 6 |
| F000-error-concurrency | ERR + CON | 6 |
| F000-security-build | SEC + BLD | 5 |
| F000-testing-quality | TST + FMT | 6 |
| F000-config-logging | ENV + LOG | 5 |
| F000-dev-experience | DXP | 3 |

---

## F7. Framework Philosophy

| Principle | Description | Implication |
|-----------|-------------|-------------|
| **Simplicity** | Go favors clear, readable code over clever abstractions — if it can be done simply, do it simply | Prefer stdlib over third-party when feasible; avoid deep inheritance-like embedding chains; one struct per file is fine; short variable names in small scopes |
| **Explicit error handling** | Errors are values returned explicitly — not thrown or caught | Every function that can fail returns error; callers check errors immediately; wrapping adds context; sentinel errors for known conditions; no panic for expected failures |
| **Composition over inheritance** | Go uses interfaces and embedding — not class hierarchies | Small interfaces (1-2 methods); accept interfaces, return structs; embed for reuse, don't over-abstract; dependency injection via constructor functions |
| **Share by communicating** | Prefer channels and message passing over shared memory with locks | Design concurrent systems around goroutine ownership; use channels for coordination; reserve mutexes for simple shared state; context.Context carries deadlines and cancellation |
