# Foundation: Bun
<!-- Format: _foundation-core.md | ID prefix: BU (see § F4) -->

> Runtime and toolkit Foundation for projects using Bun as primary runtime.
> Covers Bun-specific decisions that differ from Node.js defaults.

---

## F0. Detection Signals

| Signal | Confidence |
|--------|-----------|
| `bun.lockb` in project root | HIGH |
| `bunfig.toml` present | HIGH |
| `"packageManager": "bun@..."` in package.json | HIGH |
| `bun` binary used in scripts (package.json scripts reference `bun`) | MEDIUM |

---

## F1. Categories

| Code | Category | Description |
|------|----------|-------------|
| BST | App Bootstrap | Entry point, Bun-specific APIs (Bun.serve, Bun.file), lifecycle |
| BLD | Build & Bundle | Bun bundler vs external bundler, target configuration, macros |
| TST | Testing | Bun test runner, snapshot testing, test configuration |
| PKG | Package Management | Workspace configuration, dependency resolution, overrides |
| CMP | Node.js Compatibility | Node.js API compatibility gaps, polyfills needed, native module support |
| PTY | Process & PTY | Child process spawning, PTY management (bun-pty), IPC patterns |
| ENV | Environment | Environment variables, `.env` loading (built-in), runtime detection |
| DXP | Developer Experience | Hot reload (--hot), watch mode (--watch), debugger, path aliases |

---

## F2. Decision Items

### BST — App Bootstrap
| ID | Item | Priority | Question |
|----|------|----------|----------|
| BST-01 | Entry point strategy | Critical | Direct `bun run` vs compiled binary? |
| BST-02 | Bun.serve usage | Important | Use Bun.serve for HTTP or external framework (Hono, Express)? |
| BST-03 | Bun.file API | Optional | Use Bun.file for file I/O or Node.js fs API? |

### BLD — Build & Bundle
| ID | Item | Priority | Question |
|----|------|----------|----------|
| BLD-01 | Bundler choice | Critical | Bun bundler vs esbuild vs custom? |
| BLD-02 | Build target | Critical | `bun` target vs `node` target vs `browser` target? |
| BLD-03 | Macros | Optional | Use Bun macros for compile-time code generation? |
| BLD-04 | Binary compilation | Optional | Compile to standalone binary with `bun build --compile`? |

### TST — Testing
| ID | Item | Priority | Question |
|----|------|----------|----------|
| TST-01 | Test runner | Critical | `bun test` (built-in) vs Jest vs Vitest? |
| TST-02 | Test timeout | Important | Default timeout (5s) vs custom? |
| TST-03 | Snapshot testing | Optional | Bun snapshot format vs Jest-compatible? |

### PKG — Package Management
| ID | Item | Priority | Question |
|----|------|----------|----------|
| PKG-01 | Workspace setup | Critical | Bun workspaces vs Turborepo vs Nx? |
| PKG-02 | Lockfile format | Important | `bun.lockb` (binary) — team tooling compatibility? |
| PKG-03 | Overrides/patches | Optional | `overrides` vs `resolutions` for dependency patching? |

### CMP — Node.js Compatibility
| ID | Item | Priority | Question |
|----|------|----------|----------|
| CMP-01 | Node.js API gaps | Critical | Which Node.js APIs are used that Bun doesn't support? (check Bun compatibility table) |
| CMP-02 | Native modules | Important | Any native addons (node-gyp)? Bun native module support? |
| CMP-03 | npm ecosystem | Important | Packages with Node.js-specific postinstall scripts? |

### PTY — Process & PTY
| ID | Item | Priority | Question |
|----|------|----------|----------|
| PTY-01 | Subprocess spawning | Important | `Bun.spawn` vs Node.js child_process? |
| PTY-02 | PTY management | Important | `bun-pty` for terminal interaction? |
| PTY-03 | IPC | Optional | Bun IPC vs Node.js IPC? |

### ENV — Environment
| ID | Item | Priority | Question |
|----|------|----------|----------|
| ENV-01 | .env loading | Important | Bun built-in .env vs dotenv package? |
| ENV-02 | Runtime detection | Important | `Bun.env` vs `process.env`? Runtime detection pattern? |

### DXP — Developer Experience
| ID | Item | Priority | Question |
|----|------|----------|----------|
| DXP-01 | Hot reload | Important | `bun --hot` vs `bun --watch`? Difference and use case? |
| DXP-02 | Debugger | Optional | Bun debugger (`bun --inspect`) vs VS Code integration? |
| DXP-03 | Path aliases | Optional | tsconfig paths vs bunfig.toml paths? |

---

## F7. Philosophy

| Principle | Description | Impact |
|-----------|-------------|--------|
| **Speed as Default** | Bun is designed for speed — prefer Bun-native APIs over Node.js polyfills when equivalent | Choose `Bun.serve` over Express when possible; use `bun test` over Jest |
| **All-in-One Toolkit** | Bun bundles runtime + bundler + test runner + package manager — minimize external tools | Evaluate if external tools (esbuild, Jest, npm) can be replaced by Bun equivalents |
| **Node.js Compatibility Bridge** | Bun aims for Node.js compatibility but gaps exist — identify and document early | Audit `node:*` imports for Bun support before choosing stack |

---

## F8. Toolchain Commands

| Field | Command |
|-------|---------|
| `build` | `bun run build` |
| `test` | `bun test` |
| `lint` | `bunx biome check .` OR `bunx eslint .` |
| `typecheck` | `bunx tsc --noEmit` |
| `package_manager` | `bun` |
| `install` | `bun install` |

---

## F9. Scan Targets

#### Data Model
| Pattern | Description |
|---------|-------------|
| `Bun.file()` with structured data | Bun-native file I/O patterns |

#### API Endpoints
| Pattern | Description |
|---------|-------------|
| `Bun.serve({ fetch(req) {} })` | Bun native HTTP server |
