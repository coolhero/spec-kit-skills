# Tauri Foundation
<!-- Format: _foundation-core.md | ID prefix: TA (see § F4) -->

## F0. Detection Signals

- `tauri.conf.json` present in project root or `src-tauri/`
- `Cargo.toml` with `tauri` dependency in `src-tauri/`
- `tauri` in package.json devDependencies
- `src-tauri/` directory structure
- `@tauri-apps/api` in package.json dependencies

---

## F1. Foundation Categories

| Category Code | Category Name | Item Count | Description |
|--------------|---------------|------------|-------------|
| WIN | Window Management | 6 | Window config, decorations, multi-window, inter-window comms |
| SEC | Security | 3 | CSP, allowlist/permissions, capabilities |
| IPC | Inter-Process Communication | 2 | Command architecture, capabilities configuration |
| NAT | Native Integration | 9 | Tray, dialogs, notifications, shortcuts, clipboard, drag-drop |
| UPD | Auto-update | 3 | Updater plugin, signing key, update server |
| DLK | Deep Linking & File Associations | 3 | URL schemes, file associations, sidecar binaries |
| BLD | Build & Deploy | 5 | Bundle targets, code signing, build profile, app icon |
| LOG | Logging & Monitoring | 2 | Logging strategy, error handling |
| STR | Storage | 3 | Database, persistent storage, filesystem scope |
| BST | App Bootstrap | 3 | Frontend framework, Tauri version, splash screen |
| DXP | Developer Experience | 2 | Shell command access, HTTP client access |
| ENV | Environment Config | 3 | Embedded server, mobile support, process isolation |

---

## F2. Foundation Items

### WIN: Window Management

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| TA-WIN-01 | Window configuration | Default window size, title, resizable, position in `tauri.conf.json` | config | Critical |
| TA-WIN-02 | Window decorations | Native OS decorations or custom titlebar | choice (native / custom / none) | Critical |
| TA-WIN-03 | Multi-window support | Single or multiple windows (static config or dynamic) | choice (single / multi-static / multi-dynamic) | Important |
| TA-WIN-04 | Inter-window communication | How windows communicate via Tauri event system (`emit_to`/`listen`) | config | Important |
| TA-WIN-05 | Splash screen | Whether to show splash screen during initialization | binary | Important |
| TA-WIN-06 | Splash screen implementation | How splash is implemented | choice (separate-window / overlay) | Important |

### SEC: Security

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| TA-SEC-01 | Content Security Policy | CSP headers; Tauri auto-injects nonces at compile time | config | Critical |
| TA-SEC-02 | Allowlist / Permission scoping | Restrict access to filesystem paths, shell commands, HTTP endpoints | config | Critical |
| TA-SEC-03 | Plugin permissions | Configure which Tauri plugins are enabled and their permission scopes | config | Critical |

### IPC: Inter-Process Communication

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| TA-IPC-01 | IPC command architecture | How Rust backend commands are structured and invoked from frontend | config | Critical |
| TA-IPC-02 | Capabilities configuration | Define which windows/webviews have access to which IPC commands | config | Critical |

### NAT: Native Integration

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| TA-NAT-01 | System tray | Whether to add a system tray icon with menu via tray plugin | binary | Important |
| TA-NAT-02 | Tray icon format | Tray icon image format and sizes per platform | config | Important |
| TA-NAT-03 | Window menu | Whether to use native or custom window menus | choice (native / custom / none) | Important |
| TA-NAT-04 | Notification support | Whether to send native OS notifications via plugin | binary | Important |
| TA-NAT-05 | Dialog support | Whether to use native file/message dialogs via plugin | binary | Important |
| TA-NAT-06 | Global shortcuts | Whether to register global keyboard shortcuts | binary | Important |
| TA-NAT-07 | Clipboard access | Whether the app accesses system clipboard | binary | Important |
| TA-NAT-08 | Drag-and-drop | Whether to support file drag-and-drop into the app | binary | Important |
| TA-NAT-09 | Sidecar binaries | Whether to bundle external binaries alongside the app | binary | Important |

### UPD: Auto-update

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| TA-UPD-01 | Auto-update strategy | Whether to enable the updater plugin and how updates are delivered | choice (tauri-updater / custom / disabled) | Critical |
| TA-UPD-02 | Update signing key | Generate and configure update signature key pair | config | Important |
| TA-UPD-03 | Update server | Where to host update manifest and artifacts | choice (github / crabnebula / custom) | Important |

### DLK: Deep Linking & File Associations

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| TA-DLK-01 | Deep linking / URL scheme | Register custom URL schemes via deep-link plugin | binary | Important |
| TA-DLK-02 | Deep link schemes | The custom protocol schemes to register | config | Important |
| TA-DLK-03 | File associations | Whether to register as handler for specific file types | binary | Important |

### BLD: Build & Deploy

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| TA-BLD-01 | Bundle targets | Which installer formats to generate (DMG, MSI, NSIS, AppImage, deb, rpm) | config | Critical |
| TA-BLD-02 | Code signing (macOS) | Signing identity and notarization configuration | config | Important |
| TA-BLD-03 | Code signing (Windows) | Code signing certificate configuration | config | Important |
| TA-BLD-04 | Build profile | Release build optimizations (Rust release profile, LTO, strip, codegen-units) | config | Important |
| TA-BLD-05 | App icon | Application icon assets per platform | config | Important |

### LOG: Logging & Monitoring

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| TA-LOG-01 | Logging strategy | Logging via tauri-plugin-log or tracing crate | choice (tauri-plugin-log / tracing / custom) | Important |
| TA-LOG-02 | Error handling strategy | How Rust errors propagate to the frontend (Result types, custom error enums) | config | Important |

### STR: Storage

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| TA-STR-01 | Database integration | Local database strategy | choice (sqlite-plugin / custom-rust / indexeddb / none) | Important |
| TA-STR-02 | Persistent storage | Key-value storage strategy | choice (plugin-store / custom-rust / none) | Important |
| TA-STR-03 | Filesystem access scope | Which directories the app can read/write (scoped by capabilities) | config | Important |

### BST: App Bootstrap

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| TA-BST-01 | Tauri version | Choose between Tauri v1 (legacy) or Tauri v2 (current) | choice (v1 / v2) | Critical |
| TA-BST-02 | Frontend framework | Which web framework for the UI | choice (react / vue / svelte / solidjs / vanilla) | Critical |
| TA-BST-03 | Sidecar configuration | Path, target triple, and invocation method for sidecar binaries | config | Important |

### DXP: Developer Experience

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| TA-DXP-01 | Shell command access | Whether the app can execute shell commands and which ones | config | Important |
| TA-DXP-02 | HTTP client access | Whether the frontend can make HTTP requests and to which domains | config | Important |

### ENV: Environment Config

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| TA-ENV-01 | Embedded server | Whether to run a localhost server inside the app | binary | Optional |
| TA-ENV-02 | Mobile support | Whether to target iOS/Android in addition to desktop | binary | Optional |
| TA-ENV-03 | Process isolation | Async runtime and thread pool configuration in Rust backend | config | Optional |

---

## F3. Extraction Rules (reverse-spec)

| Category | Extraction Method |
|----------|------------------|
| WIN | Read `tauri.conf.json` window configuration (width, height, decorations, title). Count window definitions. Check for `WebviewWindow::new()` calls in Rust. |
| SEC | Read `tauri.conf.json` CSP field. Check `capabilities/` directory for permission definitions. Read plugin permission scopes. |
| IPC | Search for `#[tauri::command]` attribute macros in Rust source. Read `capabilities/*.json` for command-to-window mappings. |
| NAT | Check for tray plugin usage, dialog plugin, notification plugin in `Cargo.toml` and `tauri.conf.json` plugins section. |
| UPD | Check for `tauri-plugin-updater` in dependencies. Read updater config in `tauri.conf.json`. Look for signing key configuration. |
| DLK | Check for `tauri-plugin-deep-link` in dependencies. Read `tauri.conf.json` for registered URL schemes. Check for file association config. |
| BLD | Read `tauri.conf.json` bundle configuration for targets, identifier, icons. Check CI scripts for signing configuration. |
| LOG | Check for `tauri-plugin-log` or `tracing` in Cargo.toml. Read log initialization in main.rs. |
| STR | Check for `tauri-plugin-sql`, `tauri-plugin-store` in dependencies. Read filesystem scope in capabilities. |
| BST | Check `tauri.conf.json` for version info. Read `package.json` for frontend framework dependencies. |
| DXP | Read capabilities for shell and HTTP scope restrictions. |
| ENV | Check for `localhost` server configuration. Check `tauri.conf.json` for mobile target support. |

---

## F4. T0 Feature Grouping

| T0 Feature | Foundation Categories | Items |
|------------|----------------------|-------|
| F000-core-window-ipc | WIN + IPC | 8 |
| F000-security-bootstrap | SEC + BST | 6 |
| F000-native-integration | NAT | 9 |
| F000-update-deeplink | UPD + DLK | 6 |
| F000-build-deploy | BLD | 5 |
| F000-error-logging-storage | LOG + STR | 5 |
| F000-devexp-env | DXP + ENV | 5 |
