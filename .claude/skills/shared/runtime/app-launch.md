# App Launch & Playwright Connection

> **Shared module** — standardized app launch and Playwright connection for all skills.
> Consumes: `playwright-detection.md` results + `data-storage-map.md` results.

---

## Launch by App Type

### Electron (cli_direct mode)

> **🚨 CRITICAL: `app.setPath()` Override Detection**
>
> Many Electron apps override the userData path in code (`app.setPath('userData', ...)`).
> When this happens, `--user-data-dir` is IGNORED — the code override takes precedence.
>
> **BEFORE launching**, grep the source for `setPath`:
> ```bash
> grep -rn "setPath.*userData\|app\.setPath" src/main/ --include="*.ts" --include="*.js"
> ```
>
> **Common patterns**:
> - `app.setPath('userData', app.getPath('userData') + 'Dev')` → dev mode adds "Dev" suffix
> - `app.setPath('userData', customPath)` → app uses custom path entirely
> - `app.setPath('userData', portableDir)` → portable mode
>
> **If `setPath` override exists**: `--user-data-dir` will NOT work. Instead:
> 1. Check if the override is **conditional on dev mode** (`if (isDev)`)
> 2. If yes: launch in dev mode (see "Dev Mode Launch" below)
> 3. If unconditional: the app always uses a custom path — use THAT path

#### Standard Launch (no setPath override)

```javascript
const { _electron } = require('playwright');
const userDataDir = PLAYWRIGHT_USER_DATA_DIR; // from data-storage-map.md

const app = await _electron.launch({
  executablePath: 'node_modules/.bin/electron',
  args: [
    'out/main/index.js',
    '--user-data-dir=' + userDataDir
  ]
});
```

#### Dev Mode Launch (when setPath override is conditional on isDev)

When the app has `if (isDev) { app.setPath('userData', ... + 'Dev') }`,
the production build (`out/main/index.js`) will use the PRODUCTION userData path,
not the dev path where the user configured their settings.

**Solution**: Launch in dev mode so `isDev = true` and the same setPath logic runs:

```javascript
const { _electron } = require('playwright');

// Option A: Launch via electron-vite dev entry
const app = await _electron.launch({
  executablePath: 'node_modules/.bin/electron',
  args: ['.'],  // electron-vite detects dev mode from project root
  cwd: SOURCE_DIR,
  env: { ...process.env, NODE_ENV: 'development' }
});

// Option B: Launch build but force dev environment
const app = await _electron.launch({
  executablePath: 'node_modules/.bin/electron',
  args: ['out/main/index.js'],
  cwd: SOURCE_DIR,
  env: { ...process.env, NODE_ENV: 'development' }
});
```

> **Which option?** Check how `isDev` is defined in the source:
> - `import.meta.env.DEV` or `process.env.NODE_ENV !== 'production'` → Option B works
> - Hardcoded in electron-vite build config → Option A (must use actual dev server)

#### Decision Flow

```
1. grep for app.setPath('userData', ...) in source
2. Found?
   NO  → Standard Launch (--user-data-dir works)
   YES → Is it conditional on isDev?
         YES → Dev Mode Launch (Option A or B)
         NO  → Read the custom path from code, use that as PLAYWRIGHT_USER_DATA_DIR
3. After launch, verify: navigate to Settings → check if user's API keys are visible
4. If keys missing → STOP, report userData mismatch, ask user to verify
```

> **userData sharing**: User MUST have closed their app first (LevelDB lock).
> Without correct userData, Playwright sees an unconfigured app — no API keys, no models, no data.

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
