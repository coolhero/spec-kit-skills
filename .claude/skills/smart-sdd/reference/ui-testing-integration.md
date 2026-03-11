# UI Testing Integration Guide

> Reference: Browser automation integration for UI-heavy Features.
> Applicable when Playwright (CLI or MCP) or similar browser automation tool is available in the Claude Code environment.
> Referenced by: `domains/app.md` § 6, `commands/verify-phases.md` Phase 3.

---

## 1. Overview

spec-kit-skills is designed to work with browser automation tools like **Playwright** (CLI or MCP) for UI testing, visual verification, and demo validation. This guide documents the integration points, current capabilities, and future roadmap.

### What is Playwright?

Playwright is a browser automation framework that can be used in multiple modes:

- **CLI / Library mode**: Install via `npm install -D @playwright/test`. Write and run test scripts directly (`npx playwright test`). Best for headless CI pipelines and scripted verifications.
- **Test Runner mode**: Playwright's built-in test runner with fixtures, assertions, and parallel execution. Ideal for structured test suites.
- **MCP Server mode**: A Model Context Protocol server (`@playwright/mcp`) that gives Claude Code interactive browser control — navigate pages, click elements, fill forms, take screenshots. Provides tools like `browser_navigate`, `browser_click`, `browser_screenshot`, etc.

All three modes share the same underlying browser engine. spec-kit-skills works with any of them — CLI mode is the default; MCP mode adds interactive tool-call capabilities when configured.

### App Session Management

The agent manages the entire app lifecycle during UI verification — it starts the app, runs all SC verifications in a single session, then shuts down the app when done. The user is never asked to manually start, restart, or stop the app.

For **Electron apps with CDP**: The agent appends `--remote-debugging-port=9222` to the dev start command and launches the app in background via Bash. After all SC verifications complete, the agent terminates the process.

See `commands/verify-phases.md` Phase 3 Step 3 for the full procedure.

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

Phase A adds integration points to the existing workflow without changing core logic. These hooks are activated **only when Playwright (CLI or MCP) is available** in the Claude Code session.

### 2a. verify Phase 3 — Demo UI Validation

**Where**: `commands/verify-phases.md` Phase 3, Step 2

When verifying a Feature's demo script:

1. Demo script starts the server (existing behavior)
2. **Hook**: If Playwright is available, after the server starts:
   - Navigate to the demo URL (from the demo script's "Try it" output)
   - Take a screenshot to verify the page loads correctly
   - Check for critical UI elements (page title, navigation, key components)
   - Report: "UI verification: ✅ Page loads, [N] key elements found"
3. Demo script continues with `--ci` health check (existing behavior)

**This is additive** — if Playwright is not available, the demo verification works exactly as before (health endpoint check only).

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

This section is informational when Playwright is not available. When available, the verify Phase 3 hook reads these assertions and validates them.

### 2c. Domain Profile Hook

**Where**: `domains/interfaces/gui.md` § S6

The domain profile specifies which UI verification patterns apply (only when `gui` is in active Interfaces):

- **Has UI**: Full UI verification (navigate, screenshot, element checks)
- **Backend/API**: Skip UI verification (API-only Features have no UI to check)
- **CLI/Library**: Skip UI verification

---

## 3. How to Use (Current Phase A)

### Prerequisites

1. **Install Playwright CLI**:
   ```bash
   npm install -D @playwright/test && npx playwright install
   ```

2. **(Optional) Install Playwright MCP** for interactive tool calls:
   ```bash
   claude mcp add playwright -- npx @playwright/mcp@latest
   ```

3. **Ensure demo scripts follow the standard**: Demo scripts must print "Try it" instructions with real URLs (see `reference/demo-standard.md`)

### During verify

When you run `/smart-sdd verify F001`:

1. Phase 1 (test/build/lint) runs as usual
2. Phase 2 (cross-Feature consistency) runs as usual
3. Phase 3 (demo verification):
   - Demo script starts the server
   - If Playwright available → automated UI check against demo URLs
   - If not available → health endpoint check only (existing behavior)
4. Phase 4 (global update) runs as usual

### What You Get

With Playwright enabled:
- **Automated visual smoke test**: Confirms the demo page actually renders, not just that the server responds
- **Element presence check**: Verifies key UI components exist on the page
- **Screenshot evidence**: Captures screenshots during verification for review

Without Playwright:
- Everything works as before — no degradation

---

## 4. Troubleshooting

### Electron Apps Require CDP Mode

> **Note:** CDP is only required for MCP mode. CLI mode uses `_electron.launch()` which connects directly to Electron without CDP.

Playwright MCP in standard mode opens a separate Chromium browser — it cannot interact with Electron app windows. Electron apps require CDP (Chrome DevTools Protocol) when using MCP mode:

1. Start the Electron app with `--remote-debugging-port=9222`
2. Configure Playwright MCP with `--cdp-endpoint http://localhost:9222`
3. Restart Claude Code

If `/reverse-spec` was run with CDP for the same Electron project, Playwright MCP may already be in CDP mode. Just start the new app on the same port.

See [PLAYWRIGHT-GUIDE.md](../../../../PLAYWRIGHT-GUIDE.md) for detailed CDP setup instructions.

### Playwright Not Detected

If verify Phase 3 falls back to health-check-only mode:
- Check CLI installation first: `npx playwright --version`
- If using MCP mode, check that Playwright MCP server is running and connected
- Verify MCP configuration in Claude Code settings (if applicable)
- The hook checks for Playwright availability at runtime — no pre-configuration needed in smart-sdd

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
