# Electron Foundation
<!-- Format: _foundation-core.md | ID prefix: EL (see § F4) -->

## F0. Detection Signals

- `electron` in package.json `dependencies` or `devDependencies`
- `main` field in package.json pointing to a `.js` or `.ts` file (main process entry)
- Imports from `electron` (`BrowserWindow`, `app`, `ipcMain`)
- `electron-builder.yml` or `forge.config.js` present
- `preload.js` or `preload.ts` files

---

## F1. Foundation Categories

| Category Code | Category Name | Item Count | Description |
|--------------|---------------|------------|-------------|
| WIN | Window Management | 10 | Window frame, multi-window, state persistence, process model |
| SEC | Security | 8 | Context isolation, node integration, sandbox, CSP |
| IPC | Inter-Process Communication | 3 | IPC pattern, preload strategy, channel naming |
| NAT | Native Integration | 12 | Menus, tray, notifications, drag-drop, clipboard, shortcuts |
| UPD | Auto-update | 4 | Update mechanism, server, UX, signing |
| DLK | Deep Linking & File Associations | 4 | Protocol handler, scheme, file associations |
| BLD | Build & Deploy | 8 | Packaging tool, distribution formats, code signing, notarization |
| LOG | Logging & Monitoring | 2 | Logging strategy, crash reporting |
| STR | Storage | 3 | Persistent storage, session management, proxy |
| ERR | Error Handling | 1 | Crash reporting endpoint |
| BST | App Bootstrap | 2 | App lifecycle events, background/foreground behavior |
| DXP | Developer Experience | 3 | Dev tools policy, webview vs BrowserView, native addons |
| ENV | Environment Config | 3 | GPU acceleration, spell checker, accessibility (cross-refs WIN/NAT) |

> **Item count note**: F2 contains 63 rows total. 5 items in BST/DXP/ENV are cross-references to overlapping items in WIN/SEC/NAT (marked with "see also"). Unique decisions = **58**.

---

## F2. Foundation Items

### WIN: Window Management

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| EL-WIN-01 | Single-instance lock | Whether to use `app.requestSingleInstanceLock()` to prevent multiple app instances | binary | Critical |
| EL-WIN-02 | Window frame type | Choose between frameless window (custom titlebar) or native OS frame | choice (frameless / native / hybrid-titlebar) | Critical |
| EL-WIN-03 | Process model | How to distribute work across main, renderer, and utility processes | choice (single-renderer / multi-renderer / utility-process-offload) | Critical |
| EL-WIN-04 | Custom titlebar | If frameless, implement a custom drag-region titlebar with window controls | binary | Important |
| EL-WIN-05 | Multi-window management | Whether the app supports multiple windows and data sync strategy | choice (single-window / multi-window-independent / multi-window-synchronized) | Important |
| EL-WIN-06 | Window state persistence | Save and restore window position, size, and state across restarts | binary | Important |
| EL-WIN-07 | Screen/display management | How to handle multi-monitor setups, display scaling, window placement | config | Important |
| EL-WIN-08 | Splash screen | Whether to show a splash/loading screen during initialization | binary | Important |
| EL-WIN-09 | GPU acceleration | Whether to enable/disable hardware GPU acceleration | binary | Optional |
| EL-WIN-10 | Background/foreground behavior | App behavior when all windows are closed (quit / background-tray / platform-dependent) | choice (quit / background-tray / platform-dependent) | Optional |

### SEC: Security

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| EL-SEC-01 | Context isolation | Enable `contextIsolation` to separate preload script context from renderer | binary (should be true) | Critical |
| EL-SEC-02 | Node integration | Whether to enable `nodeIntegration` in renderer processes | binary (should be false) | Critical |
| EL-SEC-03 | Sandbox mode | Whether to run renderer processes in Chromium's OS-level sandbox | binary | Critical |
| EL-SEC-04 | Content Security Policy | Define CSP headers to prevent XSS and script injection in renderer | config | Critical |
| EL-SEC-05 | Navigation restrictions | Restrict navigation to trusted URLs only via `will-navigate` handler | binary | Important |
| EL-SEC-06 | Dev tools policy | Whether to allow DevTools in production builds | choice (always-disabled / conditional / always-enabled) | Important |
| EL-SEC-07 | Permission handling | How to handle web permission requests (camera, mic, geolocation) | choice (deny-all / custom-handler / auto-approve) | Important |
| EL-SEC-08 | CSP report-only mode | Whether to start with CSP in report-only mode during development | binary | Optional |

### IPC: Inter-Process Communication

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| EL-IPC-01 | IPC architecture pattern | Communication pattern: invoke/handle (request-response) vs send/on (fire-and-forget) vs MessagePort | choice (invoke-handle / send-on / message-port / mixed) | Critical |
| EL-IPC-02 | Preload script strategy | How preload scripts expose APIs via `contextBridge.exposeInMainWorld()` | config | Critical |
| EL-IPC-03 | IPC channel naming | Naming convention for IPC channels (e.g., `namespace:action`) | config | Important |

### NAT: Native Integration

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| EL-NAT-01 | Native menus | Whether to use native OS menus or custom HTML-based menus | choice (native / custom-html / hybrid) | Critical |
| EL-NAT-02 | Context menu | Right-click context menu implementation | choice (native / custom / none) | Important |
| EL-NAT-03 | Tray icon | Whether to add a system tray icon with context menu | binary | Important |
| EL-NAT-04 | Tray behavior | Behavior when closing window (minimize to tray vs quit) | choice (minimize-to-tray / quit / ask) | Important |
| EL-NAT-05 | Notifications | Whether to use native OS notifications via Electron Notification API | binary | Important |
| EL-NAT-06 | Drag-and-drop | Support OS-native drag-and-drop of files into/out of the app | binary | Important |
| EL-NAT-07 | Clipboard access | Whether and how the app accesses system clipboard | config | Important |
| EL-NAT-08 | Global shortcuts | Register global keyboard shortcuts that work when app is unfocused | binary | Important |
| EL-NAT-09 | Spell checker | Whether to enable the built-in spell checker in text inputs | binary | Optional |
| EL-NAT-10 | Spell checker languages | Which languages to enable for spell checking | config | Optional |
| EL-NAT-11 | Print support | Whether to support printing content from the app | binary | Optional |
| EL-NAT-12 | Accessibility | Implement accessibility features (ARIA, screen reader, keyboard navigation) | binary | Optional |

### UPD: Auto-update

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| EL-UPD-01 | Auto-update strategy | Choose update mechanism | choice (electron-updater / autoUpdater-Squirrel / custom / none) | Critical |
| EL-UPD-02 | Update server | Where to host update artifacts | choice (github / s3 / custom-server / nuts / hazel) | Important |
| EL-UPD-03 | Update UX | How update availability is presented to user | choice (silent / prompt / forced / staged-rollout) | Important |
| EL-UPD-04 | Update signing | Signing configuration for update verification | config | Important |

### DLK: Deep Linking & File Associations

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| EL-DLK-01 | Deep linking | Register a custom URL scheme for deep linking | binary | Important |
| EL-DLK-02 | Protocol scheme name | The custom protocol scheme to register (e.g., `myapp://`) | config | Important |
| EL-DLK-03 | File associations | Register as handler for specific file types | binary | Important |
| EL-DLK-04 | Registered file types | Which file extensions and MIME types to associate | config | Important |

### BLD: Build & Deploy

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| EL-BLD-01 | App packaging tool | Choose the packaging/build tool | choice (electron-builder / electron-forge / custom) | Critical |
| EL-BLD-02 | Distribution formats | Installer/package formats per platform (DMG, NSIS, AppImage, deb, snap, MSI) | config | Critical |
| EL-BLD-03 | Code signing | Whether to code-sign the application | binary | Important |
| EL-BLD-04 | Code signing identity | Certificate identity for macOS and Windows signing | config | Important |
| EL-BLD-05 | macOS notarization | Whether to notarize the macOS build with Apple | binary | Important |
| EL-BLD-06 | Asar packaging | Whether to package app source into an asar archive | binary | Important |
| EL-BLD-07 | App icon | Application icon format and sizes for each platform | config | Important |
| EL-BLD-08 | Remote module | Whether to use or explicitly disable the deprecated `@electron/remote` | binary | Important |

### LOG: Logging & Monitoring

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| EL-LOG-01 | Logging strategy | Logging in main/renderer processes | choice (electron-log / winston / custom) | Important |
| EL-LOG-02 | Crash reporting | Crash reporting service | choice (electron-crashReporter / sentry / bugsplat / none) | Important |

### STR: Storage

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| EL-STR-01 | Persistent storage | Local data storage mechanism | choice (electron-store / sqlite / indexeddb / fs / leveldb) | Important |
| EL-STR-02 | Session/cookie management | How to manage session and cookie data | choice (persist / in-memory / partitioned) | Important |
| EL-STR-03 | Proxy settings | Whether to configure custom proxy settings | binary | Optional |

### ERR: Error Handling

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| EL-ERR-01 | Crash reporting endpoint | URL of the crash report collection server | config | Important |

### BST: App Bootstrap

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| EL-BST-01 | App lifecycle events | Which lifecycle events to handle (ready, window-all-closed, activate, before-quit, will-quit) | config | Critical |
| EL-BST-02 | Background/foreground behavior | App behavior when all windows are closed | choice (quit / background-tray / platform-dependent) | Important |

### DXP: Developer Experience

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| EL-DXP-01 | Dev tools policy (production) | DevTools availability in production builds | choice (always-disabled / conditional / always-enabled) | Important |
| EL-DXP-02 | webview vs BrowserView | If embedding external web content, choose approach | choice (webview / browserview / none) | Important |
| EL-DXP-03 | Native addons strategy | Whether the app uses native Node.js addons | choice (electron-rebuild / prebuild / postinstall / none) | Important |

### ENV: Environment Config

> Items in this category are intentionally scoped to app-level runtime configuration that overlaps with WIN/NAT categories. They provide a separate extraction axis for config-centric analysis.

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| EL-ENV-01 | GPU acceleration toggle | Whether to enable/disable hardware GPU acceleration (see also WIN-09) | binary | Optional |
| EL-ENV-02 | Spell checker config | Built-in spell checker configuration (see also NAT-09) | binary | Optional |
| EL-ENV-03 | Accessibility config | Accessibility feature configuration (ARIA, keyboard nav) (see also NAT-12) | binary | Optional |

---

## F3. Extraction Rules (reverse-spec)

How to determine each Foundation decision from existing Electron source code:

| Category | Extraction Method |
|----------|------------------|
| WIN | Check `BrowserWindow` constructor options in main process: `frame`, `titleBarStyle`, `titleBarOverlay`. Check for `app.requestSingleInstanceLock()`. Count `new BrowserWindow()` calls for multi-window. Check for `electron-window-state` or similar persistence library. |
| SEC | Check `BrowserWindow` webPreferences: `contextIsolation`, `nodeIntegration`, `sandbox`. Search for CSP meta tags or `session.defaultSession.webRequest.onHeadersReceived`. Check `will-navigate` event handlers. |
| IPC | Search for `ipcMain.handle`/`ipcMain.on` patterns to identify IPC style. Read preload scripts for `contextBridge.exposeInMainWorld()` API surface. Extract channel names from IPC registrations. |
| NAT | Check for `Menu.buildFromTemplate`, `Tray`, `Notification`, `globalShortcut.register`, `clipboard` imports. Look for drag-and-drop event handlers. |
| UPD | Search for `electron-updater` or `autoUpdater` imports. Check `electron-builder.yml` for publish config. Look for update event handlers. |
| DLK | Check `app.setAsDefaultProtocolClient()`. Look for `open-url` event handler (macOS) and deep link arg parsing. Check `electron-builder.yml` for `fileAssociations`. |
| BLD | Read `electron-builder.yml` or `forge.config.js` for packaging config. Check for code signing env vars (CSC_LINK, APPLE_ID). Look for `afterSign` notarization scripts. |
| LOG | Search for `electron-log`, `winston`, `sentry` imports. Check for `crashReporter.start()` calls. |
| STR | Search for `electron-store`, `better-sqlite3`, `IndexedDB` usage. Check session/cookie partition config. |
| ERR | Check `crashReporter.start()` configuration for `submitURL`. Look for unhandled rejection/exception handlers. |
| BST | Read main process entry point for `app.on('ready')`, `app.whenReady()`, `app.on('window-all-closed')` handlers. |
| DXP | Check if DevTools are conditionally opened. Look for native addon dependencies in package.json. |
| ENV | Check for `app.disableHardwareAcceleration()`. Look for spell checker and accessibility configuration. |

---

## F4. T0 Feature Grouping

| T0 Feature | Foundation Categories | Items |
|------------|----------------------|-------|
| F000-core-window-ipc | WIN + IPC | 13 |
| F000-security-bootstrap | SEC + BST | 10 |
| F000-native-integration | NAT | 12 |
| F000-update-deeplink | UPD + DLK | 8 |
| F000-build-deploy | BLD | 8 |
| F000-error-logging-storage | ERR + LOG + STR | 6 |
| F000-devexp-env | DXP + ENV | 6 |

---

## F7. Framework Philosophy

| Principle | Description | Implication |
|-----------|-------------|-------------|
| **Process Crash Isolation** | The main process must survive renderer process crashes — a crashed renderer should be recoverable without restarting the entire application | Renderer crash handlers are mandatory; critical state must be persisted outside renderer processes; main process should never hold state that only exists in a renderer |
| **Memory Budget Discipline** | Each BrowserWindow creates a full Chromium process — memory usage scales linearly with window count | Window count should be minimized; heavy computation offloaded to utility processes or worker threads; memory monitoring is a first-class architectural concern |
| **Native Feel** | Desktop applications should feel like native apps, not web pages in a frame — native menus, keyboard shortcuts, drag-and-drop, system tray integration | UI must follow platform conventions (title bar, context menus, shortcuts); web-only patterns (hover tooltips on mobile-first designs, browser-style navigation) are anti-patterns |
| **Secure by Default** | Context isolation and sandbox must be enabled; `nodeIntegration` in renderer is a security vulnerability | All renderer-to-main communication goes through `contextBridge`/`preload`; never expose Node.js APIs directly to renderer; CSP headers configured for all web content |
| **Auto-Update as First-Class** | Update mechanism must be designed from day one — retrofitting auto-update into a shipped app is error-prone and disruptive | Auto-update infrastructure (signing, update server, UX flow) is part of the initial architecture, not a post-launch feature |
