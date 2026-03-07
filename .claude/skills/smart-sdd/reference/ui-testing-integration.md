# UI Testing Integration Guide

> Reference: Browser automation integration for UI-heavy Features.
> Applicable when Playwright MCP (or similar browser automation tool) is available in the Claude Code environment.
> Referenced by: `domains/app.md` § 6, `commands/verify-phases.md` Phase 3.

---

## 1. Overview

spec-kit-skills is designed to work with browser automation tools like **Playwright MCP** for UI testing, visual verification, and demo validation. This guide documents the integration points, current capabilities, and future roadmap.

### What is Playwright MCP?

Playwright MCP is a Model Context Protocol server that gives Claude Code the ability to control a browser — navigate pages, click elements, fill forms, take screenshots, and run visual assertions. When installed, it provides tools like `browser_navigate`, `browser_click`, `browser_screenshot`, etc.

### Integration Architecture

```
                     Current (Phase A)              Future (Phase B/C)
                     ──────────────────             ──────────────────
verify Phase 3       Demo script → start server     Visual regression
                     → Playwright navigates          against baseline
                     → Screenshot verification       screenshots

Demo validation      Demo script --ci               Automated user
                     → Playwright clicks through     journey recording
                     → Verify UI elements present    (GIF/video)

reverse-spec         (not integrated)               UI SBI extraction
                                                    → browser actions
                                                    → component tree
```

---

## 2. Phase A: Hook Points (Current)

Phase A adds integration points to the existing workflow without changing core logic. These hooks are activated **only when Playwright MCP tools are available** in the Claude Code session.

### 2a. verify Phase 3 — Demo UI Validation

**Where**: `commands/verify-phases.md` Phase 3, Step 2

When verifying a Feature's demo script:

1. Demo script starts the server (existing behavior)
2. **Hook**: If Playwright MCP is available, after the server starts:
   - Navigate to the demo URL (from the demo script's "Try it" output)
   - Take a screenshot to verify the page loads correctly
   - Check for critical UI elements (page title, navigation, key components)
   - Report: "UI verification: ✅ Page loads, [N] key elements found"
3. Demo script continues with `--ci` health check (existing behavior)

**This is additive** — if Playwright MCP is not available, the demo verification works exactly as before (health endpoint check only).

### 2b. Demo Script Enhancement

**Where**: `reference/demo-standard.md` § 4

Demo scripts can include an optional `# Playwright` section in the header comment:

```bash
# Playwright (optional — for automated UI verification):
#   URL: http://localhost:3000/dashboard
#   Verify: page title contains "Dashboard"
#   Verify: element [data-testid="user-list"] exists
#   Verify: element [data-testid="create-button"] is clickable
```

This section is informational when Playwright MCP is not available. When available, the verify Phase 3 hook reads these assertions and validates them.

### 2c. Domain Profile Hook

**Where**: `domains/app.md` § 6

The domain profile specifies which UI verification patterns apply:

- **Has UI**: Full UI verification (navigate, screenshot, element checks)
- **Backend/API**: Skip UI verification (API-only Features have no UI to check)
- **CLI/Library**: Skip UI verification

---

## 3. How to Use (Current Phase A)

### Prerequisites

1. **Install Playwright MCP** in your Claude Code environment:
   ```bash
   # Add to your Claude Code MCP configuration
   # See: https://github.com/anthropics/anthropic-quickstarts/tree/main/mcp-playwright
   ```

2. **Ensure demo scripts follow the standard**: Demo scripts must print "Try it" instructions with real URLs (see `reference/demo-standard.md`)

### During verify

When you run `/smart-sdd verify F001`:

1. Phase 1 (test/build/lint) runs as usual
2. Phase 2 (cross-Feature consistency) runs as usual
3. Phase 3 (demo verification):
   - Demo script starts the server
   - If Playwright MCP available → automated UI check against demo URLs
   - If not available → health endpoint check only (existing behavior)
4. Phase 4 (global update) runs as usual

### What You Get

With Playwright MCP enabled:
- **Automated visual smoke test**: Confirms the demo page actually renders, not just that the server responds
- **Element presence check**: Verifies key UI components exist on the page
- **Screenshot evidence**: Captures screenshots during verification for review

Without Playwright MCP:
- Everything works as before — no degradation

---

## 4. Future Phases (Roadmap)

### Phase B: Visual Parity (MEDIUM effort)

**Goal**: Compare UI screenshots between original source and new implementation.

**How it would work**:
1. During `/smart-sdd parity`, if both original and new implementations can be run:
   - Start original source → screenshot key pages
   - Start new implementation → screenshot same pages
   - Compare screenshots (layout, key elements, color scheme)
2. Visual gaps added to `parity-report.md` as a new "Visual Parity" category

**Prerequisites**:
- Original source must be runnable (server can start, pages load)
- Source Runnability Check needed in `/reverse-spec` Pre-Phase:
  - Detect start command (from `package.json scripts.start`, `Makefile`, etc.)
  - Attempt to start the server and verify health endpoint
  - Record runnability status: `runnable` / `not-runnable` / `requires-setup`
  - If `not-runnable`: display notice, skip visual parity (static analysis continues)
  - Store result in `sdd-state.md` for parity to reference later

**New artifacts**:
- `specs/reverse-spec/visual-baseline/` — Screenshots of original UI pages
- `parity-report.md` Visual Parity section

### Phase C: UI SBI Extraction (HIGH effort)

**Goal**: Extract user-visible behaviors from the original UI via browser automation.

**How it would work**:
1. During `/reverse-spec` Phase 2, if original source is runnable:
   - Navigate to each page/route discovered in Phase 1
   - Extract: page title, navigation items, interactive elements, form fields
   - Map to SBI entries: "Page /dashboard has 3 action buttons, 2 data tables"
2. These UI-sourced SBI entries complement code-level SBI extraction

**Prerequisites**:
- Same as Phase B — original source must be runnable
- Additional: may need login credentials / test accounts for authenticated pages
- Additional: need to map URL routes to source files (from Phase 1 scan)

**New artifacts**:
- SBI entries with Origin=`ui-extracted` (distinct from `extracted` and `new`)
- UI component tree snapshots

### Phase B/C Shared Prerequisites

Both Phase B and C require the original source to be running. The **Source Runnability Check** should be implemented as follows:

```
── /reverse-spec Pre-Phase ──────────────────
  Existing: Git repository setup
  NEW: Source Runnability Check
    1. Detect start command (package.json, Makefile, docker-compose, etc.)
    2. Check dependencies (node_modules, venv, etc.)
    3. Attempt server start (with timeout)
    4. Verify health endpoint or page load
    5. Record result:
       - runnable → enable visual analysis features
       - not-runnable → display notice, continue with static-only analysis
       - requires-setup → list missing dependencies, suggest fix
    6. Store runnability status in sdd-state.md
```

---

## 5. Integration Decision Matrix

| Feature Type | Phase A (Current) | Phase B (Visual Parity) | Phase C (UI SBI) |
|-------------|-------------------|------------------------|-----------------|
| Has UI (frontend/fullstack) | ✅ Demo UI check | ✅ Screenshot compare | ✅ UI behavior extract |
| Backend/API only | ⬜ Skip (no UI) | ⬜ Skip | ⬜ Skip |
| CLI/Library | ⬜ Skip | ⬜ Skip | ⬜ Skip |
| Mobile app | ⬜ Skip (needs emulator) | ⬜ Skip | ⬜ Skip |

---

## 6. Troubleshooting

### Playwright MCP Not Detected

If verify Phase 3 falls back to health-check-only mode:
- Check that Playwright MCP server is running and connected
- Verify MCP configuration in Claude Code settings
- The hook checks for Playwright tool availability at runtime — no pre-configuration needed in smart-sdd

### Demo URL Not Found

If the automated UI check can't find a URL:
- Ensure the demo script prints URLs in the "Try it" section
- Format: `http://localhost:PORT/path` (the hook scans stdout for URL patterns)
- Add explicit URLs in the demo script's `# Playwright` header comment

### Server Start Timeout

If the demo server takes too long to start:
- The hook waits for the health check to pass before attempting UI navigation
- Default timeout follows the demo script's own health check timeout
- If the health check passes but UI navigation fails: report as "UI verification: ⚠️ Server healthy but page did not load"
