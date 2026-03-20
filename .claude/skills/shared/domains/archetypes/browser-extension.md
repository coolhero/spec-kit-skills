# Archetype: browser-extension

> Browser extensions and add-ons — Chrome, Firefox, Safari, Edge extensions.

---

## Signal Keywords

### Semantic (A0 — for init inference)

**Primary**: manifest.json (with browser_action or action), chrome.runtime, browser.runtime, content_scripts, background, service_worker, permissions, host_permissions, chrome.storage, browser extension, web extension

**Secondary**: popup, options page, devtools panel, side panel, content script injection, message passing, web accessible resources, declarativeNetRequest, chrome.tabs, browser.tabs

### Code Patterns (A0 — for source analysis)

- **Manifest**: `manifest.json` with `manifest_version` (2 or 3), `permissions`, `content_scripts`, `background.service_worker` (MV3) or `background.scripts` (MV2)
- **Message passing**: `chrome.runtime.sendMessage`, `chrome.runtime.onMessage`, `chrome.tabs.sendMessage`, port-based long-lived connections
- **Storage**: `chrome.storage.local`, `chrome.storage.sync`, `chrome.storage.session`
- **Content scripts**: DOM manipulation in page context, `matches` patterns, CSS injection
- **Background**: Service worker (MV3) with event-driven lifecycle, no persistent state in memory
- **Build**: webpack/vite with multiple entry points (background, content, popup, options)

---

## A1: Core Principles

| Principle | Description |
|-----------|-------------|
| **Minimal Permissions** | Request only the permissions actually needed. Prefer `activeTab` over broad host permissions. Optional permissions for non-core features. |
| **Content Script Isolation** | Content scripts run in an isolated world. Communication with the page requires explicit message passing. Never trust page-injected data. |
| **Background Lifecycle Awareness** | MV3 service workers are ephemeral — they can be terminated at any time. All state must be persisted to storage, not held in memory. |
| **Storage-First State** | Extension state lives in `chrome.storage`, not in-memory variables. Every state change is persisted before acknowledging success. |
| **Cross-Browser Compatibility** | Use WebExtension APIs (`browser.*`) where possible. Abstract browser-specific APIs behind a compatibility layer. |

---

## Module Metadata

- **Axis**: Archetype
- **Typical interfaces**: gui
- **Common pairings**: auth, async-state
