# Foundation: CMake (C/C++ Build System)

> **Status**: Detection stub. Full F1-F8 sections TODO.

## F0: Detection Signals
- `CMakeLists.txt` in root directory
- `.cmake` module files in `cmake/` directory
- `conanfile.txt`/`conanfile.py` (Conan package manager) or `vcpkg.json` (vcpkg)
- `build/` directory with CMake-generated files

## Architecture Notes (for SBI extraction)
- **CMake targets** (`add_library`, `add_executable`) define logical build units — map to modules
- **PUBLIC/PRIVATE/INTERFACE** link visibility controls API surface (similar to `pub` in Rust)
- **find_package()** declares external dependencies — equivalent to package.json/requirements.txt
- **Preprocessor definitions** (`target_compile_definitions`, `#ifdef`) create conditional compilation branches — these affect SBI scope (some functions only exist when certain flags are enabled)
- **Header files** (`.h`/`.hpp`) define public API — primary SBI extraction target for libraries
- **Source files** (`.c`/`.cpp`) contain implementation — P2/P3 unless they export public symbols

## F8: Toolchain Commands
| Action | Command |
|--------|---------|
| Configure | `cmake -B build -S .` or `cmake -B build -DCMAKE_BUILD_TYPE=Release` |
| Build | `cmake --build build` or `make -C build` |
| Test | `ctest --test-dir build` or `cmake --build build --target test` |
| Install | `cmake --install build` |
