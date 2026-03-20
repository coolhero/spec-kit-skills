# App Launch & Playwright Connection

> **Shared module** — standardized app launch and Playwright connection for all skills.
> Consumes: `playwright-detection.md` results + `data-storage-map.md` results.

---

## Launch by App Type

### Electron (cli_direct mode)

```javascript
const { _electron } = require('playwright');

// Use userData from Data Storage Map
const userDataDir = PLAYWRIGHT_USER_DATA_DIR; // from data-storage-map.md

const app = await _electron.launch({
  executablePath: 'node_modules/.bin/electron',
  args: [
    'out/main/index.js',  // or detected entry point
    '--user-data-dir=' + userDataDir  // share user's settings
  ]
});

const window = await app.firstWindow();
await window.waitForLoadState('domcontentloaded');
```

> **userData sharing**: Pass `--user-data-dir` pointing to user's actual data directory.
> User MUST have closed their app first (LevelDB lock).
> Without `--user-data-dir`, Playwright gets empty/default settings.

### Web App (cli_browser mode)

```javascript
const { chromium } = require('playwright');

// Web apps share the server — no userData issue
const browser = await chromium.launch({ headless: false });
const page = await browser.newPage();
await page.goto('http://localhost:' + PORT);
```

> Server stays running. Playwright opens a new browser session.
> User's configured data is in the shared database.

### Electron (cdp mode — MCP only)

```
1. App must be running with --remote-debugging-port=9222
2. Playwright MCP connects via CDP
3. browser_snapshot to verify connection
```

---

## Readiness Check

After launch, verify the app is ready:

| Signal | Detection |
|--------|-----------|
| **DOM loaded** | `waitForLoadState('domcontentloaded')` |
| **Main content visible** | Accessibility snapshot has meaningful content (not blank/splash) |
| **Settings loaded** | If user configured API keys → verify they appear in UI (not empty) |
| **No crash** | Console has no fatal errors |

If settings verification fails:
```
⚠️ User settings not detected in the app.
Possible causes:
  - App was not closed before Playwright launch (LevelDB lock)
  - --user-data-dir path is incorrect
  - Dev mode uses different app name than production

Check: ls [userData path] — is config.json present and recent?
```

---

## Cleanup

After exploration/verification is complete:

```javascript
// Electron
await app.close();

// Browser
await browser.close();

// Web server (if agent started it)
serverProcess.kill('SIGTERM');
```

---

## Consumers

| Skill | Context | Notes |
|-------|---------|-------|
| **reverse-spec** | Phase 1.5-5 | Launch source app for UI exploration |
| **smart-sdd** | verify Phase 3 | Launch target app for SC verification |
| **smart-sdd** | implement smoke | Launch target app for post-implement check |
| **code-explore** | trace (runtime) | Launch source app for runtime observation |
