# Playwright Setup Guide

> Runtime verification for spec-kit-skills uses Playwright for browser automation.
> **CLI is the primary backend.** MCP is an optional accelerator for interactive sessions.

---

## Quick Start (CLI — Primary)

### Installation

```bash
npm install -D @playwright/test
npx playwright install
```

### Verify Installation

```bash
npx playwright --version
# Expected: Version 1.x.x
```

### Verify Library Mode

```bash
node -e "require('playwright'); console.log('Library mode OK')"
# Expected: Library mode OK
```

This confirms that `require('playwright')` works from the current directory — required for library mode scripts used during implement and verify phases. If this fails while `npx playwright --version` succeeds, see [Troubleshooting: ERR_MODULE_NOT_FOUND](#err_module_not_found-playwright) below.

This single installation enables:
- **Library mode** (`node -e "..."`) for implement-phase ad-hoc checks
- **Test runner mode** (`npx playwright test`) for verify-phase SC verification
- **Electron support** via `_electron.launch()` — no CDP configuration needed

---

## Dev Server Configuration (Claude Preview)

Dev server lifecycle management uses Claude Preview. Create `.claude/launch.json` in the project root:

```json
{
  "version": "0.0.1",
  "configurations": [
    {
      "name": "dev",
      "runtimeExecutable": "npm",
      "runtimeArgs": ["run", "dev"],
      "port": 3000
    }
  ]
}
```

### Framework Examples

**Next.js:**
```json
{ "name": "dev", "runtimeExecutable": "npm", "runtimeArgs": ["run", "dev"], "port": 3000 }
```

**Vite (React/Vue/Svelte):**
```json
{ "name": "dev", "runtimeExecutable": "npm", "runtimeArgs": ["run", "dev"], "port": 5173 }
```

**Create React App:**
```json
{ "name": "dev", "runtimeExecutable": "npm", "runtimeArgs": ["start"], "port": 3000 }
```

---

## Web App Setup

### CLI Usage (Primary)

The agent uses Playwright in two modes depending on the pipeline phase:

**Library mode** (implement — ad-hoc checks):
```
1. Start dev server (Claude Preview: preview_start)
2. node -e "..." → Playwright script for snapshot / CSS extraction / element check
3. Agent reads output → uses as reference for implementation
```

**Test runner mode** (verify — structured SC verification):
```
1. Start dev server (Claude Preview: preview_start)
2. npx playwright test demos/verify/F00N-name.spec.ts --reporter=list
3. Agent parses test results → maps to SC pass/fail
```

See [runtime-verification.md](.claude/skills/smart-sdd/reference/runtime-verification.md) §7 for CLI Script Patterns.

### MCP Usage (Optional Accelerator)

```bash
claude mcp add --scope user playwright -- npx @playwright/mcp@latest
```

After installation, restart Claude Code. MCP provides session-persistent browser context for interactive verification via tool calls (`browser_snapshot`, `browser_click`, etc.).

**When to prefer MCP over CLI**:
- Interactive exploration during reverse-spec Phase 1.5 (faster iteration)
- Rapid debugging when snapshot → decide → click → re-snapshot loop is needed
- When CLI process-spawn overhead per call is unacceptable

---

## Electron Setup

### Primary: `_electron.launch()` via CLI

Playwright CLI connects directly to Electron apps — **no CDP port, no session restart needed**.

```js
const { _electron } = require('playwright');
const app = await _electron.launch({ args: ['./out/main/index.js'] });
const window = await app.firstWindow();
// interact with window...
await app.close();
```

**Prerequisites**:
- `@playwright/test` installed (`npm install -D @playwright/test`)
- App built (`npm run build` or equivalent)

**Electron-specific options** for `_electron.launch()`:

| Option | Description |
|--------|------------|
| `args` | Command-line arguments (app entry point + flags) |
| `cwd` | Working directory for the Electron process |
| `executablePath` | Path to Electron binary (defaults to node_modules) |
| `env` | Environment variables for the Electron process |
| `timeout` | Launch timeout in milliseconds |

### Alternative: MCP with `--electron-app` Flag

Electron support has been officially merged in Playwright MCP PR [#1291](https://github.com/microsoft/playwright-mcp/pull/1291).

> **Note**: Merged but may not be included in the latest stable release. Check `@next` tag.

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": [
        "@playwright/mcp@latest",
        "--electron-app", "./path/to/electron-app",
        "--caps=electron"
      ]
    }
  }
}
```

| Option | Description |
|--------|------------|
| `--electron-app` | Electron app entry point path |
| `--electron-cwd` | Working directory for Electron |
| `--electron-executable` | Electron binary path |
| `--electron-timeout` | App start timeout |
| `--caps=electron` | Enable Electron-specific capabilities |

### Alternative: MCP with CDP (Legacy)

For MCP without `--electron-app` support, use CDP connection:

```bash
# 1. Launch Electron with remote debugging port
./your-electron-app --remote-debugging-port=9222

# 2. Register MCP with CDP endpoint
claude mcp add --scope user playwright -- npx @playwright/mcp@latest --cdp-endpoint http://localhost:9222
```

**Build tool commands for CDP**:

| Build Tool | CDP Launch Command |
|-----------|-------------------|
| **electron-vite** | `npx electron-vite dev -- --remote-debugging-port=9222` |
| **electron-forge** | `ELECTRON_ARGS='--remote-debugging-port=9222' npm run start` |
| **electron-builder** | `ELECTRON_ARGS='--remote-debugging-port=9222' npm run dev` |
| **Direct electron** | `npx electron . --remote-debugging-port=9222` |

> ⚠️ **electron-vite requires `--` separator**. `ELECTRON_ARGS` is not supported.

**CDP connection order** (MCP only):
```
1. npm run build                                  ← Build app
2. npx electron out/main/index.js \
     --remote-debugging-port=9222                 ← Launch with CDP
3. curl localhost:9222/json/version               ← Verify CDP
4. Start Claude Code session                      ← MCP loads tools
```

Session start order matters for CDP — app must be running BEFORE the Claude Code session starts.

**CDP Troubleshooting**:

| Symptom | Cause | Fix |
|---------|-------|-----|
| No playwright tools in session | CDP endpoint not running | Launch app with CDP, restart session |
| `mcp get` Connected but no tools | MCP process OK, browser not connected | `curl localhost:9222/json/version` |
| curl OK but no tools | App launched after session start | Restart session |
| browser_snapshot shows Chrome tab | CDP not configured | Add `--cdp-endpoint` to MCP args |

---

## Runtime Capability Map

> Maps capabilities to concrete invocation methods per backend.
> Agent instructions reference **Capability names** — the agent resolves to the appropriate method based on RUNTIME_BACKEND.

| Capability | CLI Library (`node -e`) | CLI Test (`.spec.ts`) | Playwright MCP |
|-----------|------------------------|----------------------|----------------|
| **Detect** | `npx playwright --version` exit 0 | same | `browser_navigate` tool exists |
| **Navigate** | `page.goto(url)` | `page.goto(url)` | `browser_navigate` |
| **Snapshot** | `page.accessibility.snapshot()` | `expect(locator)` assertions | `browser_snapshot` |
| **Click** | `page.click(selector)` | `locator.click()` | `browser_click` |
| **Type** | `page.fill(selector, text)` | `locator.fill(text)` | `browser_type` |
| **Select** | `page.selectOption(sel, val)` | `locator.selectOption(val)` | `browser_select_option` |
| **Press** | `page.keyboard.press(key)` | `page.keyboard.press(key)` | `browser_press_key` |
| **Wait** | `page.waitForSelector(sel)` | `locator.waitFor()` | `browser_wait_for` |
| **Console** | `page.on('console', ...)` | `page.on('console', ...)` | `browser_console_messages` |
| **Evaluate** | `page.evaluate(fn)` | `page.evaluate(fn)` | `browser_evaluate` |
| **CSS** | `page.evaluate(getComputedStyle)` | `expect(locator).toHaveCSS()` | `browser_evaluate` |
| **Electron** | `_electron.launch()` | `_electron.launch()` | `--electron-app` or CDP |

### Usage by Pipeline Phase

| Phase | Mode | Primary Backend | When MCP Preferred |
|-------|------|----------------|-------------------|
| **reverse-spec Phase 1.5** (source app exploration) | Library | CLI | Faster interactive exploration loop |
| **implement** (per-task verification) | Library | CLI | Rapid snapshot→fix iteration |
| **implement** (source app reference, rebuild) | Library | CLI | — (CLI only) |
| **verify** (SC verification) | Test runner | CLI | Full interactive SC verification |

### App Session Management

Playwright sessions are expensive to start. Minimize restarts:

- **implement**: Start app at first task verification → use `page.goto()` for screen switching → stop after Review complete
- **verify**: Start app once → verify all SCs in same session → stop after Phase 3 complete
- **reverse-spec**: Start app at Phase 1.5 begin → explore all screens → stop at Phase 1.5 end
- **rebuild mode**: Source app runs throughout implement; built app started per-task for verification

> ⚠️ Do NOT restart the app per-task. Use `page.goto(newRoute)` to switch screens.

### Snapshot-Based Exploration Strategy

**Snapshot (accessibility tree) over screenshot**:

| Tool | Returns | Feature Extraction Value | Context Cost |
|------|---------|------------------------|-------------|
| `accessibility.snapshot()` | Component tree (roles, names, states, interactive elements) | **High** — structural information | Low (text) |
| Screenshot | Visual appearance (colors, layout, icons) | **Low** — not directly usable for Feature extraction | High (image) |

Use accessibility snapshots for structural analysis. Screenshots are only useful for pixel-level visual comparison (rebuild `preservation_level: exact`).

---

## CLI Script Patterns

See [runtime-verification.md](.claude/skills/smart-sdd/reference/runtime-verification.md) §7 for complete patterns:

- **snapshot(url)** — accessibility tree capture
- **css-extract(url, selector, props[])** — computed style values
- **element-check(url, selector)** — existence + attributes
- **compare(sourceUrl, builtUrl)** — structural diff of two pages

Each pattern is a self-contained `node -e "..."` script that launches Playwright, performs one operation, outputs JSON, and exits.

---

## MCP Accelerator (Optional)

> All functionality is available via CLI. MCP provides session-persistent browser context
> and interactive tool calls for faster iteration in exploratory scenarios.

### When MCP Adds Value

- **reverse-spec Phase 1.5**: Interactive exploration loop (snapshot → judge → click → re-snapshot) is 3-5x faster than CLI library mode scripting
- **verify debugging**: When a test fails and you need to interactively investigate the page state
- **Complex interactions**: Multi-step form flows, drag-and-drop, dialogs — faster via MCP tools than scripted

### Setup

```bash
# Web app
claude mcp add --scope user playwright -- npx @playwright/mcp@latest

# Electron (with --electron-app support)
# See Electron section above for configuration

# Verify
claude mcp get playwright
# Expected: Status: ✓ Connected
```

> **Scope tip**: `--scope user` registers globally. `--scope project` registers for current project only.

### "Connected" Status Clarification

`Status: ✓ Connected` means the MCP server process is running. It does NOT mean a browser is connected.

| Display | Meaning | How to Verify |
|---------|---------|--------------|
| `Status: ✓ Connected` | MCP server process running | `claude mcp get playwright` |
| Browser connected | Playwright tools loaded in session | `browser_snapshot` call succeeds |

### Troubleshooting

**`Failed to connect` — npx/node not found**:

MCP server processes don't read `.zshrc`/`.bashrc`. If using nvm/fnm, Node.js may not be in the system PATH.

```bash
which npx
# ✓ /opt/homebrew/bin/npx or /usr/local/bin/npx → OK
# ✗ ~/.nvm/... or ~/.fnm/... → system PATH install needed
```

**Fix**: Install Node.js via system PATH method:
- [nodejs.org](https://nodejs.org/) → `/usr/local/bin`
- Homebrew: `brew install node` → `/opt/homebrew/bin`

### ERR_MODULE_NOT_FOUND: playwright

**Symptom**: Library mode scripts (`node -e "const { chromium } = require('playwright'); ..."`) fail with:
```
Error [ERR_MODULE_NOT_FOUND]: Cannot find package 'playwright'
```

**Cause**: `require('playwright')` resolves from the script's working directory via Node.js module resolution, not from where the playwright binary is installed globally via npx. `npx playwright --version` can succeed while `require('playwright')` fails — they use different resolution mechanisms.

| Scenario | Diagnosis | Fix |
|----------|-----------|-----|
| Script runs from `/tmp/` or non-project directory | CWD is not the project root | Run scripts from the project root: `cd /path/to/project && node -e "..."` |
| Source project (reverse-spec) doesn't have playwright | Playwright is a dev tool, not a source project dependency | Install in the output directory: `npm i -D @playwright/test` |
| Playwright removed after `npm ci` or `npm prune` | Clean install dropped devDependencies | Re-install: `npm i -D @playwright/test` |

**Verification**: Check if library mode will work from a given directory:
```bash
cd /path/to/project && node -e "require('playwright'); console.log('OK')"
```

**Note**: The pre-flight probe checks both `npx playwright --version` (binary) AND `node -e "require('playwright')"` (library import) to ensure library mode scripts will work. If only the binary probe passes, the pre-flight attempts auto-recovery (install) before classifying CLI as unavailable.

---

## Claude Preview Auxiliary Features

Dev server management and precision inspection (built-in, no installation needed):

| Feature | Tool | Purpose |
|---------|------|---------|
| Server start/stop | `preview_start`, `preview_stop` | Dev server lifecycle |
| Server logs | `preview_logs` | stdout/stderr (build error detection) |
| CSS inspection | `preview_inspect` | Computed style, bounding box |
| Network body | `preview_network` | API response body inspection |
| Responsive test | `preview_resize` | mobile/tablet/desktop presets + dark mode |

---

## CLI Options Reference

Key Playwright CLI options for test execution:

| Option | Description | Example |
|--------|------------|---------|
| `--browser` | Browser type | `chromium`, `firefox`, `webkit` |
| `--headed` | Show browser window | (flag only) |
| `--reporter` | Output format | `list`, `json`, `html` |
| `--timeout` | Test timeout (ms) | `30000` |
| `--retries` | Retry failed tests | `2` |
| `--workers` | Parallel workers | `1` (sequential for UI tests) |

Key Playwright MCP options:

| Option | Description | Example |
|--------|------------|---------|
| `--cdp-endpoint` | CDP connection (Electron) | `"http://localhost:9222"` |
| `--headless` | Headless mode | (flag only) |
| `--viewport-size` | Viewport dimensions | `"1280x720"` |
| `--caps` | Extra capabilities | `tabs`, `pdf`, `electron` |

---

## Without Playwright (Manual Fallback)

When Playwright cannot be installed, spec-kit-skills still works. Runtime verification steps prompt the user for manual verification:

```
📋 UI Manual Verification
App running at http://localhost:3000.

Please verify the following:
□ SC-001: Navigate to /login → login form visible?
□ SC-002: Enter email/password → submit → redirects to dashboard?
□ SC-003: /dashboard → data table renders?

Report results (all pass / failed item numbers).
```

---

## Future Extensions

### Tauri v2 — Tauri MCP

- GitHub: [hypothesi/mcp-server-tauri](https://github.com/hypothesi/mcp-server-tauri)
- Currently beta (v0.9.0), guide will be added after stabilization
- Requires Bridge Plugin installation in app (Rust build)
- Provides Tauri-specific features: IPC boundary inspection, WebView DOM access, system log collection
