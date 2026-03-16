# Interface: gui

> GUI windows, web pages, visual UI — browser-based or desktop.

---

## Signal Keywords

### Semantic (S0 — for init inference)

**Primary**: React, Vue, Svelte, Angular, Next.js, Nuxt, SvelteKit, Remix, Electron, Tauri, desktop app, web app, dashboard, frontend, UI, browser extension, Chrome extension, pages, components, widgets

**Secondary**: responsive, dark mode, sidebar, layout, forms, drag-drop, modal, tooltip, toast, navigation, menu

### Code Patterns (R1 — for source analysis)

> gui does not define per-module R1 signals. Interface detection uses generic heuristics in `reverse-spec/domains/_core.md § R1` (e.g., `package.json` + `src/components/` → frontend).

---

## Module Metadata

- **Axis**: Interface
- **Common pairings**: async-state, ipc (Electron/Tauri)
- **Profiles**: desktop-app, fullstack-web
