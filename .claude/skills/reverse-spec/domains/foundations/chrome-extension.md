# Foundation: Chrome Extension (Manifest V3)

> **Status**: Detection stub. Full F1-F8 sections TODO.

## F0: Detection Signals
- `manifest.json` with `"manifest_version": 3` (or 2)
- Keywords: `chrome.runtime`, `chrome.tabs`, `chrome.storage`, `chrome.action`
- Directory patterns: `background/`, `content/`, `popup/`, `sidepanel/`
- Build: webpack/vite with `@crxjs/vite-plugin` or manual bundling

## Architecture Notes (for SBI extraction)
- **Service Worker** (background.js): Long-lived event handler, Chrome API orchestrator
- **Content Scripts**: Injected into web pages, DOM manipulation, message passing to background
- **Popup/SidePanel UI**: Small React/Svelte/vanilla UI, communicates via `chrome.runtime.sendMessage`
- **Message Passing**: `chrome.runtime.onMessage` / `chrome.tabs.sendMessage` — treat as IPC-equivalent for SBI
- **Permissions**: `manifest.json` permissions define capability boundaries — map to Feature scopes

## Runtime Exploration
- Cannot launch standalone — must be loaded into Chrome via `chrome://extensions`
- For code-explore/reverse-spec: ask user to load extension, then use Chrome DevTools Protocol or manual observation
- Playwright can automate Chrome with extensions loaded: `--load-extension=path/to/ext`
