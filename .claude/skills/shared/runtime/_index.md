# Shared Runtime Modules

> Cross-skill runtime protocols for app launch, data storage detection, user setup, and Playwright connection.
> Used by: reverse-spec, smart-sdd, code-explore.

---

## Module Index

| Module | Purpose | Domain Profile Connection |
|--------|---------|--------------------------|
| [`playwright-detection.md`](playwright-detection.md) | Detect available Playwright backend | Interface (Axis 1) determines connection mode |
| [`data-storage-map.md`](data-storage-map.md) | Detect storage locations + userData path | Foundation (Axis 4) determines storage patterns |
| [`user-assisted-setup.md`](user-assisted-setup.md) | Guide user through app configuration | Interface (Axis 1) determines setup UX |
| [`app-launch.md`](app-launch.md) | Launch app + connect Playwright | Interface (Axis 1) S8 Runtime Verification Strategy |
| [`observation-protocol.md`](observation-protocol.md) | **What to observe** per Domain Profile axis (3-layer: Common + Domain-Aware + Skill-Specific) | ALL axes — Interface(UI structure), Concern(auth/realtime), Archetype(AI/SDK), Foundation(lib/theme), Scale(UX quality) |

---

## Domain Profile Integration

These modules are **Interface-aware** — the behavior changes based on Axis 1 (Interface):

| Interface | Launch Method | Storage Detection | Setup UX |
|-----------|-------------|-------------------|----------|
| `gui` (Electron) | `_electron.launch()` | electron-store, SQLite, LevelDB | Run app → Settings UI → close |
| `gui` (Web) | `chromium.launch()` → localhost | Database, .env | Start server → browser → configure |
| `gui` (Tauri) | Tauri CLI launch | tauri-store, SQLite | Run app → Settings UI → close |
| `http-api` | Start server process | Database, .env, config files | curl commands, seed scripts |
| `cli` | Execute binary | Config file (~/.config/) | CLI config commands |
| `data-io` | Run pipeline | Input/output files | Prepare test data files |
| `tui` | Execute in terminal | Config file | CLI config commands |

Each skill's S8 section (Runtime Verification Strategy) defines the **specific** start/verify/stop methods. These shared modules provide the **common protocol** that S8 implementations follow.

---

## Flow

```
Phase 1 (any skill): Detect Interface → Load S8 from Domain Profile
                                          ↓
                      shared/runtime/playwright-detection.md → RUNTIME_BACKEND
                      shared/runtime/data-storage-map.md → PLAYWRIGHT_USER_DATA_DIR
                                          ↓
Phase 1.5 / verify:  shared/runtime/user-assisted-setup.md → user configures
                      shared/runtime/app-launch.md → Playwright connects with userData
                                          ↓
                      S8-specific verification runs on the connected app
```
