# Foundation: Makefile / Autotools (C/C++ Build System)

> **Status**: Detection stub. Full F1-F8 sections TODO.

## F0: Detection Signals
- `Makefile` or `GNUmakefile` in root (plain Make)
- `configure.ac` + `Makefile.am` (GNU Autotools / autoconf+automake)
- `configure` script (pre-generated autotools output)
- `meson.build` (Meson build system — modern alternative)
- `BUILD` / `BUILD.bazel` + `WORKSPACE` (Bazel)

## Architecture Notes (for SBI extraction)
- **Makefile targets** define build units but are less structured than CMake — may need manual module identification
- **Autotools**: `configure.ac` defines feature checks (`AC_CHECK_LIB`, `AC_CHECK_FUNC`) that control conditional compilation
- **Header installation**: `include_HEADERS` in Makefile.am defines public API surface
- **pkg-config** (`.pc` files): Declares library's public interface for downstream consumers
- **Meson**: `meson.build` with `library()`, `executable()`, `dependency()` — similar structure to CMake but Python-like syntax
- **Bazel**: `cc_library`, `cc_binary`, `cc_test` rules with explicit `deps` and `hdrs` visibility

## F8: Toolchain Commands
| Action | Plain Make | Autotools | Meson | Bazel |
|--------|-----------|-----------|-------|-------|
| Configure | — | `./configure` | `meson setup build` | — |
| Build | `make` | `make` | `meson compile -C build` | `bazel build //...` |
| Test | `make test` | `make check` | `meson test -C build` | `bazel test //...` |
| Install | `make install` | `make install` | `meson install -C build` | — |
