# Foundation: Rust (Cargo)

> **Status**: Detection stub. Full F1-F8 sections TODO.

## F0: Detection Signals
- `Cargo.toml` in root (with or without `[workspace]`)
- `.rs` source files
- Keywords: `fn main()`, `pub fn`, `mod`, `use`, `impl`, `trait`
- Build: `cargo build`, `cargo test`, `cargo clippy`

## Architecture Notes (for SBI extraction)
- **Crate = Module**: Each `Cargo.toml` defines a crate (library or binary)
- **Visibility**: `pub` keyword marks public API — primary SBI extraction target
- **Traits**: Define behavioral contracts — map to interface specifications in spec.md
- **unsafe blocks**: Flag for security/safety review in verify phase
- **Feature flags**: `[features]` in Cargo.toml — conditional compilation affects SBI scope
- **Integration tests**: `tests/` directory (separate compilation units)
- **Benchmarks**: `benches/` directory (criterion/divan)
