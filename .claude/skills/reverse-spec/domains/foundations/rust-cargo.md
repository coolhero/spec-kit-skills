# Foundation: Rust (Cargo)
<!-- Format: _foundation-core.md | ID prefix: RS (see § F4) -->

## F0. Detection Signals

- `Cargo.toml` in root (with or without `[workspace]`)
- `.rs` source files
- Keywords: `fn main()`, `pub fn`, `mod`, `use`, `impl`, `trait`
- Build: `cargo build`, `cargo test`, `cargo clippy`

---

## F1. Foundation Categories

| Category Code | Category Name | Item Count | Description |
|--------------|---------------|------------|-------------|
| BST | App Bootstrap | 3 | Crate type, workspace structure, entry point |
| SEC | Security | 3 | cargo-audit, unsafe policy, RUSTSEC |
| PKG | Cargo Management | 3 | Feature flags, workspace deps, dependency sources |
| TST | Testing | 3 | Unit tests, integration tests, benchmarks |
| BLD | Build & Tooling | 3 | Release profile, cross-compilation, task runner |
| MEM | Memory & Safety | 3 | Ownership patterns, Arc/Rc policy, Pin usage |
| ERR | Error Handling | 3 | Error library, ? operator, custom types |
| ASY | Async Runtime | 3 | Runtime choice, task spawning, async traits |
| FMT | Formatting | 3 | rustfmt, clippy lints, deny policy |
| LOG | Logging & Tracing | 2 | Tracing library, log facade |
| FFI | Foreign Function Interface | 2 | C bindings, cbindgen |
| DXP | Developer Experience | 3 | cargo watch, expand, xtask |

---

## F2. Foundation Items

### BST: App Bootstrap

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| RS-BST-01 | Crate type | Binary vs library crate | choice (bin / lib / both) | Critical |
| RS-BST-02 | Workspace structure | Whether Cargo workspace is used | choice (single-crate / workspace / virtual-workspace) | Critical |
| RS-BST-03 | Entry point | Main function organization | choice (main.rs-minimal / main.rs-full / lib+bin) | Important |

### SEC: Security

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| RS-SEC-01 | Dependency audit | Vulnerability scanning tool | choice (cargo-audit / cargo-deny / trivy) | Critical |
| RS-SEC-02 | Unsafe policy | Rules for unsafe block usage | choice (forbid / audit-required / allowed-in-ffi) | Critical |
| RS-SEC-03 | RUSTSEC advisories | How advisories are tracked in CI | config | Important |

### PKG: Cargo Management

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| RS-PKG-01 | Feature flags | How Cargo features are organized | config | Critical |
| RS-PKG-02 | Workspace dependencies | Whether [workspace.dependencies] is used for version unification | binary | Important |
| RS-PKG-03 | Dependency sources | Allowed dependency sources | choice (crates-io / git / path / registry) | Important |

### TST: Testing

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| RS-TST-01 | Unit test location | Where unit tests live | choice (inline-mod / separate-file) | Important |
| RS-TST-02 | Integration tests | tests/ directory organization | choice (per-file / common-mod / harness) | Important |
| RS-TST-03 | Benchmarks | Benchmarking approach | choice (criterion / divan / built-in / none) | Important |

### BLD: Build & Tooling

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| RS-BLD-01 | Release profile | Optimization and LTO settings for release | config | Critical |
| RS-BLD-02 | Cross-compilation | Target triples and cross tool | choice (cross / cargo-zigbuild / manual) | Important |
| RS-BLD-03 | Task runner | Build automation beyond cargo | choice (cargo-xtask / just / make / none) | Important |

### MEM: Memory & Safety

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| RS-MEM-01 | Smart pointer policy | When to use Arc vs Rc vs Box | config | Critical |
| RS-MEM-02 | Lifetime annotations | Explicit lifetime style conventions | config | Important |
| RS-MEM-03 | Pin usage | Pin<Box<T>> patterns for async/self-referential | config | Important |

### ERR: Error Handling

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| RS-ERR-01 | Error library | Error type derivation | choice (thiserror / derive_more / manual) | Critical |
| RS-ERR-02 | Application errors | Top-level error handling | choice (anyhow / eyre / custom) | Critical |
| RS-ERR-03 | Error conversion | How errors propagate between layers | choice (From-impl / map_err / context) | Important |

### ASY: Async Runtime

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| RS-ASY-01 | Async runtime | Primary async runtime | choice (tokio / async-std / smol / none) | Critical |
| RS-ASY-02 | Task spawning | How async tasks are spawned | choice (tokio-spawn / structured / scoped) | Important |
| RS-ASY-03 | Async traits | Async trait strategy | choice (native-async-trait / async-trait-crate / manual-pin) | Important |

### FMT: Formatting

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| RS-FMT-01 | Formatter | Code formatting tool | choice (rustfmt / default) | Critical |
| RS-FMT-02 | Clippy lints | Clippy lint level configuration | config | Critical |
| RS-FMT-03 | Deny policy | Whether `#![deny(warnings)]` or `#![deny(clippy::all)]` is used | config | Important |

### LOG: Logging & Tracing

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| RS-LOG-01 | Tracing library | Structured logging/tracing | choice (tracing / log / env_logger) | Important |
| RS-LOG-02 | Subscriber | Tracing subscriber configuration | choice (tracing-subscriber / fmt / json) | Important |

### FFI: Foreign Function Interface

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| RS-FFI-01 | C bindings | Whether C FFI is exposed | choice (cbindgen / manual / none) | Important |
| RS-FFI-02 | Binding generation | Bindings for consuming C libraries | choice (bindgen / manual / none) | Important |

### DXP: Developer Experience

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| RS-DXP-01 | Watch mode | Auto-rebuild on file changes | choice (cargo-watch / bacon / none) | Important |
| RS-DXP-02 | Macro debugging | Macro expansion tool | choice (cargo-expand / none) | Important |
| RS-DXP-03 | Xtask pattern | Whether cargo-xtask is used for project automation | binary | Important |

---

## F3. Extraction Rules (reverse-spec)

| Category | Extraction Method |
|----------|------------------|
| BST | Read Cargo.toml for `[lib]`/`[[bin]]` targets. Check for `[workspace]` section. |
| SEC | Search CI for cargo-audit/cargo-deny. Grep for `unsafe` blocks. Check deny.toml. |
| PKG | Read Cargo.toml `[features]`. Check for `[workspace.dependencies]`. Search for git/path deps. |
| TST | Look for `#[cfg(test)]` modules, `tests/` directory, `benches/` directory with criterion/divan. |
| BLD | Read `[profile.release]` in Cargo.toml. Check CI for cross-compilation targets. Look for xtask/. |
| MEM | Search for `Arc<`, `Rc<`, `Box<`, `Pin<` usage patterns. Check unsafe block frequency. |
| ERR | Search for thiserror/anyhow in Cargo.toml. Look for `impl From<` error conversions. |
| ASY | Check Cargo.toml for tokio/async-std. Search for `#[tokio::main]`, `async fn`. |
| FMT | Read rustfmt.toml. Check clippy.toml or Cargo.toml `[lints]`. Search for deny attributes. |
| LOG | Search for tracing/log imports. Read subscriber configuration in main. |
| FFI | Search for `extern "C"`, `#[no_mangle]`. Check for cbindgen.toml or build.rs with bindgen. |
| DXP | Check for cargo-watch in CI/Makefile. Look for xtask/ directory. |

---

## F4. T0 Feature Grouping

| T0 Feature | Foundation Categories | Items |
|------------|----------------------|-------|
| F000-rust-bootstrap-cargo | BST + PKG | 6 |
| F000-safety-security | SEC + MEM | 6 |
| F000-error-async | ERR + ASY | 6 |
| F000-testing-quality | TST + FMT | 6 |
| F000-build-ffi | BLD + FFI | 5 |
| F000-logging-devexp | LOG + DXP | 5 |

---

## F7. Framework Philosophy

| Principle | Description | Implication |
|-----------|-------------|-------------|
| **Zero-cost abstractions** | Abstractions compile away — you don't pay for what you don't use | Prefer generics over trait objects when monomorphization is beneficial; avoid Box<dyn> unless dynamic dispatch is required; iterators over manual loops |
| **Ownership guarantees correctness** | The borrow checker enforces memory safety at compile time — no GC, no runtime cost | Design data flow around ownership transfer; prefer borrowing over cloning; use lifetimes to express relationships; Clone is a conscious decision, not a default |
| **No null, no exceptions** | Option<T> replaces null, Result<T,E> replaces exceptions — all failure paths are explicit | Every fallible function returns Result; use ? for propagation; match on Option/Result exhaustively; unwrap() only in tests or with proof of invariant |
| **Fearless concurrency** | The type system prevents data races — Send/Sync traits enforce thread safety | Arc<Mutex<T>> for shared mutable state; channels for message passing; Rayon for data parallelism; the compiler catches races before runtime |
