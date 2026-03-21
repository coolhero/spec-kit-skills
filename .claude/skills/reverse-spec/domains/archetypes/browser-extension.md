# Archetype: Browser Extension (reverse-spec)

> Browser extension/add-on detection

## R1. Detection Signals

> See [`shared/domains/archetypes/browser-extension.md`](../../../shared/domains/archetypes/browser-extension.md) § Code Patterns

## R2. Classification Guide

When detected, classify the sub-type:
- **Chrome Extension (Manifest V3)** — `manifest.json` with `manifest_version: 3`, service worker background, Chrome APIs
- **Firefox Add-on** — `manifest.json` with Firefox-specific keys (`browser_specific_settings`), WebExtension APIs
- **Safari Web Extension** — Xcode project wrapper, `SFSafariExtension` bridging, App Extension target
- **Cross-browser** — WebExtension polyfill (`webextension-polyfill`), abstraction layers for multi-browser support

## R3. Analysis Depth Modifiers

When detected, include in analysis:
- Manifest structure (permissions, host permissions, content security policy)
- Content script patterns (injection targets, run timing, isolated world communication)
- Background worker lifecycle (service worker registration, idle timeout handling, persistent state)
- Storage APIs (chrome.storage.local/sync/session, IndexedDB usage, quota management)
- Popup/sidebar UI (popup dimensions, sidebar panel registration, options page)
- Cross-origin messaging (runtime.sendMessage, port-based long-lived connections, externally_connectable)
