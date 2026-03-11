# Interface: gui

> Desktop or Web GUI with user-facing UI. Applies when the project has visual interfaces.
> Module type: interface

---

## S0. Signal Keywords

> Keywords that indicate this module should be activated. Used by Clarity Index signal extraction.

**Primary**: React, Vue, Svelte, Angular, Next.js, Nuxt, SvelteKit, Remix, Electron, Tauri, desktop app, web app, dashboard, frontend, UI, browser extension, Chrome extension, pages, components, widgets
**Secondary**: responsive, dark mode, sidebar, layout, forms, drag-drop, modal, tooltip, toast, navigation, menu

---

## S1. SC Generation Rules

### Required SC Patterns
- UI interactions: specify element selector + user action + expected visible result
- Navigation: specify trigger + destination route/page + visible confirmation
- Form submissions: specify input values + submit action + success/error feedback
- Loading states: specify trigger + loading indicator + completion state

### SC Anti-Patterns (reject)
- "UI displays correctly" — must specify which elements are visible and their state
- "User can interact" — must specify the interaction sequence and outcome
- "Page loads" — must specify key elements that confirm successful load

### SC Measurability Criteria
- Element visibility within timeout (e.g., "toast visible within 2s")
- No console errors during interaction sequence

---

## S2. Parity Dimensions (additions)

| Category | What to Compare |
|----------|----------------|
| UI components | Component tree structure, page routes — match original frontend structure |
| Visual layout | Key layout patterns (sidebar, header, split-pane) — match original |

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| **Frontend routing** | New pages/routes? Navigation integration? Protected routes? |
| **UI Completeness** | Does this Feature manage data users will configure/view? If yes, should a minimal management UI be included? |
| **Responsive design** | Mobile/tablet support? Breakpoints? |

---

## S6. UI Testing Integration

> Browser automation hook points for Features with user-facing UI.
> Full guide: [reference/ui-testing-integration.md](../../reference/ui-testing-integration.md)

| Feature Type | UI Verification | Condition |
|-------------|----------------|-----------|
| Has UI (frontend/fullstack) | Demo URL navigation + Snapshot + element check | Playwright MCP available |
| Backend/API only | Skip (API health check only) | — |
| CLI/Library | Skip | — |

When Playwright MCP is available during `verify` Phase 3:
- Demo script starts the server -> Playwright navigates to demo URL -> verifies page loads and key elements exist
- SC-level UI verification: Automatically execute UI Action sequences from Coverage header via MCP
- If not available: HARD STOP — MCP install guide or UI verification Skip

---

## S7. Bug Prevention Rules

When this interface is active, enforce:
- Platform CSS Rendering Constraints: see `injection/implement.md` § Bug Prevention B-3
- UI Interaction Surface Audit: see `injection/implement.md` § Bug Prevention B-3
- CSS Value Map Generation (rebuild mode): see `injection/implement.md` § CSS Value Map

---

## S8. Runtime Verification Strategy

> Cross-references [reference/runtime-verification.md](../../reference/runtime-verification.md) § 6a.

| Field | Value |
|-------|-------|
| **Start method** | Dev server (`npm run dev`, `vite`, etc.) or Electron app with CDP (`--remote-debugging-port=9222`) |
| **Verify method** | Navigate pages + SC interaction verification + console error scan. Backend: Playwright MCP or Playwright CLI (see runtime-verification.md § 3 for detection) |
| **Stop method** | Kill dev server process / close Electron app |
| **SC classification extensions** | `cdp-auto` — UI interaction SCs automatable via browser automation |

**GUI-specific verification steps**:
- Step 3c Navigation Transition Sanity Check (verify-phases.md): compare shared layout elements across Feature page transitions
- Step 3d Interactive Runtime Verification: group `cdp-auto` SCs by user flow → execute complete interaction sequences → verify state changes and side effects
