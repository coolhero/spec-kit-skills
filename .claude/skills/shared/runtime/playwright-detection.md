# Playwright Detection Protocol

> **Shared module** — used by reverse-spec (Phase 1.5), smart-sdd (verify), code-explore (runtime trace).
> Detects which Playwright backend is available and determines the connection method.

---

## Detection Steps

### Step 1 — Detect Playwright CLI

```bash
npx playwright --version 2>/dev/null
```

- Success → `playwright_cli = true`
- Failure → `playwright_cli = false`

If CLI not found, attempt library import:
```bash
node -e "require('playwright')" 2>/dev/null
```
- Success → `playwright_cli = true` (library mode)
- Failure → proceed to Step 2

### Step 2 — Detect Playwright MCP

Check available tools list. Playwright MCP is available if you have ANY tool whose name contains `browser_navigate`.

Set `playwright_mcp = true` if found, `false` otherwise.

### Step 3 — Determine Electron Connection Mode

If the target project is Electron:

| Condition | Mode | How |
|-----------|------|-----|
| `playwright_cli = true` | `cli_direct` | `_electron.launch()` — no CDP needed |
| `playwright_cli = false` AND `playwright_mcp = true` | `cdp` | Requires `--remote-debugging-port=9222` |
| Both false | `none` | No runtime exploration possible |

For non-Electron apps (web, API, CLI):

| Condition | Mode | How |
|-----------|------|-----|
| `playwright_cli = true` | `cli_browser` | `chromium.launch()` |
| `playwright_mcp = true` | `mcp_browser` | MCP `browser_navigate` |
| Both false | `none` | No runtime exploration |

### Step 4 — Result

Set `RUNTIME_BACKEND`:
- `cli_direct` — Electron via `_electron.launch()`
- `cli_browser` — Web/API via `chromium.launch()`
- `cdp` — Electron via CDP (MCP only)
- `mcp_browser` — Web/API via MCP
- `none` — No Playwright available

---

## Installation Guidance (when `none`)

```
Playwright not detected. Install for runtime exploration:

Option 1 — CLI (Recommended):
  npm install -D @playwright/test && npx playwright install

Option 2 — MCP:
  claude mcp add playwright -- npx @playwright/mcp@latest

For Electron apps, CLI is preferred — it connects directly via
_electron.launch() without CDP configuration.

See PLAYWRIGHT-GUIDE.md for detailed setup.
```

---

## Consumers

| Skill | When Used | Purpose |
|-------|-----------|---------|
| **reverse-spec** | Phase 1.5-0 | Runtime Exploration of source app |
| **smart-sdd** | verify Pre-flight | SC verification of target app |
| **code-explore** | orient/trace (optional) | Runtime observation during trace |
