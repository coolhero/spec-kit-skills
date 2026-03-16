# Interface: gui

> Desktop or Web GUI with user-facing UI. Applies when the project has visual interfaces.
> Module type: interface

---

## S0. Signal Keywords

> See [`shared/domains/interfaces/gui.md`](../../../shared/domains/interfaces/gui.md) § Signal Keywords

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
| Has UI (frontend/fullstack) | Demo URL navigation + Snapshot + element check | Playwright CLI or MCP available |
| Backend/API only | Skip (API health check only) | — |
| CLI/Library | Skip | — |

**🚫 GUI Features require Playwright runtime verification.** Static checks (build, tsc, lint) alone are NEVER sufficient to complete verify for a GUI Feature. Playwright SC verification is equal in priority to build/lint/tsc — not optional. See `verify-phases.md` § Phase 3 "GUI MANDATORY PLAYWRIGHT GATE" for enforcement details.

When Playwright (CLI or MCP) is available during `verify` Phase 3:
- Demo script starts the server -> Playwright navigates to demo URL -> verifies page loads and key elements exist
- SC-level UI verification: Automatically execute UI Action sequences from Coverage header via CLI test runner or MCP tools
- If not available: Attempt installation (`npx playwright install chromium`). If installation fails: HARD STOP — display failure reason and ask user for resolution. Do NOT silently skip.

---

## S7. Bug Prevention Rules

When this interface is active, enforce:
- Platform CSS Rendering Constraints: see `injection/implement.md` § Bug Prevention B-3
- UI Interaction Surface Audit: see `injection/implement.md` § Bug Prevention B-3
- CSS Value Map Generation (rebuild mode): see `injection/implement.md` § CSS Value Map
- CSS Theme Token Rendering: see `injection/implement.md` § Build Toolchain Integration Verification (step 4) — when adding components that use CSS variable tokens, verify theme mapping exists (e.g., `@theme` for Tailwind CSS 4). See also `verify-phases.md` § Step 3 CSS Theme Token Rendering Check for runtime verification

---

## S8. Runtime Verification Strategy

> Cross-references [reference/runtime-verification.md](../../reference/runtime-verification.md) § 6a.

| Field | Value |
|-------|-------|
| **Start method** | Dev server (`npm run dev`, `vite`, etc.) or Electron app via `_electron.launch()` (CLI) / CDP (MCP only) |
| **Verify method** | Navigate pages + SC interaction verification + console error scan. Backend: Playwright CLI (primary) or Playwright MCP (accelerator). See runtime-verification.md § 3 for detection |
| **Stop method** | Kill dev server process / `app.close()` (CLI Electron) / kill process (MCP) |
| **SC classification extensions** | `cdp-auto` — UI interaction SCs automatable via browser automation |

**GUI-specific verification steps**:
- Step 3c Navigation Transition Sanity Check (verify-phases.md): compare shared layout elements across Feature page transitions
- Step 3d Interactive Runtime Verification: group `cdp-auto` SCs by user flow → execute complete interaction sequences → verify state changes and side effects
