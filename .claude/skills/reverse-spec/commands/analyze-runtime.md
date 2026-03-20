> **Shared Runtime Modules**: This phase uses shared protocols from `shared/runtime/`:
> - [`playwright-detection.md`](../../shared/runtime/playwright-detection.md) — Playwright availability
> - [`data-storage-map.md`](../../shared/runtime/data-storage-map.md) — Storage detection + userData
> - [`user-assisted-setup.md`](../../shared/runtime/user-assisted-setup.md) — User configuration flow
> - [`app-launch.md`](../../shared/runtime/app-launch.md) — App launch + Playwright connection

## Phase 1.5 — Runtime Exploration (🚫 BLOCKING for rebuild, Optional for adopt)

> **Purpose**: Run the original application and explore it interactively before deep code analysis. This provides visual and behavioral context (UI layout, user flows, actual states) that code reading alone cannot capture. The observations enrich Phase 2 analysis and Phase 4 deliverables.
>
> **For rebuild mode**: This phase is **BLOCKING** — skipping it produces specs that miss UI control types (dropdown vs text input), interaction patterns (drag&drop, auto-fill, inline editing), data flow paths (citation rendering, file processing pipelines), and entry points (toolbar buttons, context menus, keyboard shortcuts). These gaps cause 70%+ of rebuild implementation failures (see lessons-learned.md L39).
>
> ```
> ❌ WRONG: Phase 1.5 skip → specify gets "FR: create KB" (one line)
>    → implement creates TextInput for model selection
>    → source app has Dropdown with auto-fill → UX mismatch
>
> ✅ RIGHT: Phase 1.5 runs source app → records "Dropdown(configured only), auto-fill Dimensions"
>    → spec-draft FR-003: "Select from Dropdown, Dimensions auto-fills"
>    → implement creates Dropdown with auto-fill → matches source
> ```
>
> **For adopt mode**: Skip entirely — adoption documents existing code in-place, no need to explore the app you're already running.
>
> **Rationale**: Code analysis reveals WHAT components exist. Runtime exploration reveals HOW they work — form field types, interaction patterns, visual feedback, error states, data flow through UI. Without runtime exploration, the agent must guess these details during implement, producing simplified versions that don't match the source app.

### 1.5-0. Playwright Availability Check + User Choice (HARD STOP)

**Step 1 — Detect Playwright CLI**:

Execute the two-phase CLI probe from [runtime-verification.md §3a](../../smart-sdd/reference/runtime-verification.md) (binary probe → library import probe → recovery).

- Success → set `playwright_cli = true`
- Failure → set `playwright_cli = false`, skip to Step 1b (MCP)

> **reverse-spec context**: The source project being analyzed typically does NOT have playwright as a dependency. The recovery step auto-installs `@playwright/test` in the output directory (CWD) — this is expected behavior, not an error.

**Step 1b — Detect Playwright MCP**:

Check your available tools list. Playwright MCP is available if you have ANY tool whose name contains `browser_navigate` (e.g., `browser_navigate`, `mcp__playwright__browser_navigate`, or any MCP-prefixed variant). This is the **only** reliable detection method — do NOT read MCP config files (config locations vary by installation method and Claude Code version).

Set `playwright_mcp = true` if such a tool exists, `false` otherwise.

**Step 1c — Electron apps: connection mode** (skip if both `playwright_cli = false` AND `playwright_mcp = false`, or non-Electron):

If the project was detected as an Electron app in Phase 1:

- **If `playwright_cli = true`**: No CDP needed — `_electron.launch()` connects directly to the Electron process via IPC. Set `electron_mode = cli_direct`.
- **If `playwright_cli = false` AND `playwright_mcp = true`**: Run existing CDP probe:
  1. Call `browser_snapshot` (accessibility tree snapshot, NOT screenshot)
  2. Examine the result:
     - If the snapshot shows content matching the Electron app (app-specific UI, window title, menus) → set `electron_mode = cdp`
     - If the snapshot shows an empty page, "about:blank", or a default browser new tab → set `electron_mode = cdp_not_configured`
     - If the tool call fails with an error → set `playwright_mcp = false` (MCP server issue)

**Step 2 — Present options based on detection result**:

**If Playwright is available (either `playwright_cli = true` OR `playwright_mcp = true`) AND non-Electron**:
```
🔍 Runtime Exploration Available

Playwright detected ([CLI / MCP / CLI + MCP]). You can run the original app and
explore it via browser to capture UI/UX details.

This step is optional — skipping it will not affect Phase 2 code analysis.
However, running it enables more accurate extraction of UI layout, user flows, and visual information.
```
Ask via AskUserQuestion:
- **"Run Runtime Exploration (Recommended)"** — launch app + browser exploration
- **"Skip — code analysis only"** — proceed directly to Phase 2

**If Playwright is available AND Electron AND `electron_mode = cli_direct`**:
(CLI connects directly via `_electron.launch()` — no CDP needed)
```
🔍 Runtime Exploration Available

Playwright CLI detected. Electron app will be connected directly via _electron.launch() — no CDP setup needed.
```
Ask via AskUserQuestion:
- **"Run Runtime Exploration (Recommended)"** — launch Electron app + CLI direct exploration
- **"Skip — code analysis only"** — proceed directly to Phase 2

**If Playwright is available AND Electron AND `electron_mode = cdp`**:
(MCP-only path with CDP already configured — standard flow)
```
🔍 Runtime Exploration Available

Playwright MCP + CDP connection detected. You can run the Electron app and
explore it via browser to capture UI/UX details.
```
Ask via AskUserQuestion:
- **"Run Runtime Exploration (Recommended)"** — launch Electron app + CDP exploration
- **"Skip — code analysis only"** — proceed directly to Phase 2

**If Playwright is available AND Electron AND `electron_mode = cdp_not_configured`**:
(MCP-only path, CDP not yet configured)
```
🔍 Runtime Exploration — CDP Configuration Required

Electron app detected, but Playwright MCP does not have a CDP endpoint configured.
Runtime Exploration for Electron apps via MCP requires CDP pre-configuration.

💡 Recommended: Install Playwright CLI instead — it connects to Electron directly
   without CDP via _electron.launch():
  npm i -D @playwright/test && npx playwright install

Alternative — CDP pre-configuration (before session start):
  1. Run the Electron app with a CDP port:
     [build-tool-specific command] --remote-debugging-port=9222
  2. Register Playwright MCP in CDP mode:
     claude mcp add --scope user playwright -- npx @playwright/mcp@latest --cdp-endpoint http://localhost:9222
  3. Restart Claude Code → re-run /reverse-spec

Details: see PLAYWRIGHT-GUIDE.md § CDP Pre-Configuration
```
Ask via AskUserQuestion:
- **"Install Playwright CLI (Recommended)"** — install CLI (`npm i -D @playwright/test && npx playwright install`) and retry
- **"Skip — code analysis only"** — proceed directly to Phase 2 (code analysis alone is sufficient for Feature extraction without CDP)
- **"Configure CDP mode (requires Claude Code restart)"** — reconfigure MCP + restart

If "Install Playwright CLI" is selected: Run `npm i -D @playwright/test && npx playwright install`, then retry detection from Step 1. If "Configure CDP mode" is selected: Auto-reconfigure MCP for CDP (run `claude mcp remove playwright` then `claude mcp add playwright -- npx @playwright/mcp@latest --cdp-endpoint http://localhost:9222`, preserving any `-e PATH=...` from the original config), display restart instructions, and record `Runtime Exploration: skipped (CDP reconfiguration — restart needed)`. Proceed to Phase 2.

**If Playwright is NOT available (both `playwright_cli = false` AND `playwright_mcp = false`)**:

**CDP Endpoint Diagnostic** (Electron projects only — skip for non-Electron):
Before showing the HARD STOP, run a quick diagnostic to provide specific guidance:
1. Run `curl -s http://localhost:9222/json/version` (timeout 3s)
2. **If curl succeeds** (returns JSON): CDP is active but Playwright tools are not loaded.
   - Diagnosis: "CDP endpoint is running at localhost:9222. Neither Playwright CLI nor MCP is available in this session."
   - Solution: "Install Playwright CLI (`npm i -D @playwright/test && npx playwright install`) or restart Claude Code with MCP configured."
3. **If curl fails** (connection refused / timeout): CDP endpoint is not running.
   - Diagnosis: "CDP endpoint not running. The Electron app must be started with `--remote-debugging-port=9222` before Playwright MCP can connect (not needed for CLI)."
   - Solution: "Install Playwright CLI (recommended — no CDP needed for Electron), or start the app with CDP and configure Playwright MCP."

Display the diagnostic result (if applicable), then show the HARD STOP:

```
🔍 Runtime Exploration

Playwright not detected (neither CLI nor MCP).
Runtime Exploration requires Playwright.

[If Electron + CDP diagnostic ran]:
  📋 CDP Diagnostic: [diagnosis from above]
  💡 Solution: [solution from above]

Option 1 — Playwright CLI (Recommended):
  npm i -D @playwright/test && npx playwright install

Option 2 — Playwright MCP:
  claude mcp add playwright -- npx @playwright/mcp@latest
  → Restart Claude Code

For Electron apps with MCP (CDP required):
  claude mcp add playwright -- npx @playwright/mcp@latest --cdp-endpoint http://localhost:9222
  → Start app with --remote-debugging-port=9222 BEFORE starting Claude Code

Installation guide: see PLAYWRIGHT-GUIDE.md (includes troubleshooting)
```
Ask via AskUserQuestion:
- **"Install Playwright CLI (Recommended)"** — install via `npm i -D @playwright/test && npx playwright install` and retry
- **"Configure Playwright MCP"** — user installs via `claude mcp add` and restarts session (see [runtime-verification.md §4](../../smart-sdd/reference/runtime-verification.md) for restart rules)
- **"Skip — code analysis only"** — proceed directly to Phase 2

**If response is empty → re-ask** (per MANDATORY RULE 1). If "Install Playwright CLI" is selected, run the installation command and retry detection from Step 1. If "Skip" is selected, record `Runtime Exploration: skipped (no Playwright)` and proceed to Phase 2.

### 1.5-0b. Data Storage Map Consumption (from Phase 1-6)

> Read the Data Storage Map generated in Phase 1-6. This determines:
> 1. **userData path** → used for Playwright `--user-data-dir` in Phase 1.5-5
> 2. **Lock analysis** → determines if user must close app before Playwright (LevelDB = yes)
> 3. **Config store location** → determines where API keys/settings are stored → drives 1.5-4b guidance
> 4. **BLOCKING classification** → if config store contains API keys, they're automatically 🚫 BLOCKING

**Auto-derive from Data Storage Map**:

```
From Phase 1-6 Storage Map:
  userData path: [detected] → PLAYWRIGHT_USER_DATA_DIR
  Has LevelDB stores: [yes/no] → REQUIRE_APP_CLOSE = true if yes
  Config store type: [electron-store/env/db] → SETUP_METHOD
  Config contains: [API keys, credentials] → AUTO_BLOCKING_ITEMS
```

These variables are used throughout Phase 1.5 — do NOT re-detect them.

### 1.5-1. Environment Assessment (Automated)

Diagnose what the app needs to run, based on Phase 1 results. The agent performs this assessment **automatically before asking the user**:

| Assessment Item | Method |
|-----------------|--------|
| **Package manager + dependency state** | Detect from lock files (`package-lock.json` → npm, `yarn.lock` → yarn, `pnpm-lock.yaml` → pnpm, `bun.lockb` → bun). Check if dependency directory (`node_modules/`, `.venv/`, `vendor/`) exists |
| **Environment variables** | Read `.env.example` (or `.env.development`, `.env.template`). Classify each variable: `config` (PORT, NODE_ENV, BASE_URL — agent can set defaults), `secret` (API keys, passwords, tokens — user must provide), `feature-flag` (ENABLE_XXX — agent can set defaults). Check if `.env` already exists |
| **Database dependency** | Detect DB type from ORM config/dependencies (Prisma → `schema.prisma`, Sequelize, TypeORM, Django `settings.py`, etc.). SQLite = no setup needed. External DB (PostgreSQL, MySQL, MongoDB) = user action needed |
| **Docker Compose availability** | Check for `docker-compose.yml` or `compose.yml`. List defined services (DB, Redis, etc.) |
| **Dev server start command** | Parse `package.json` scripts for `dev`, `start`, `serve`, `dev:web`, `electron:dev`, `tauri dev`, etc. For Python: detect `manage.py runserver`, `uvicorn`, `flask run`, etc. For Go: detect `go run` or `air` |
| **Build prerequisites** | Detect if a build step is needed before dev server (TypeScript compilation, monorepo workspace builds, native module compilation) |
| **Platform-specific requirements** | Electron: electron binary, native dependencies (`node-gyp`). Tauri: Rust toolchain, system dependencies |

### 1.5-2. Environment Readiness Checklist (HARD STOP)

> 🚨 **API keys and service credentials are NEVER "Optional" for rebuild mode.**
> If the source app uses LLM APIs, database connections, or external services as core features,
> those credentials are **BLOCKING** — without them, Phase D captures error states instead of working flows.
>
> ```
> ❌ WRONG: "API_KEY — LLM API key (ℹ️ Optional — UI 구조 탐색에는 불필요)"
>    → Phase D captures empty dropdowns and error states → spec-draft describes broken UX
>
> ✅ RIGHT: "API_KEY — LLM API key (🚫 BLOCKING — chat, KB embedding, model selection all require this)"
>    → Phase D captures working flows → spec-draft describes actual UX
> ```

Present the assessment results in three tiers:

```
📋 Environment Readiness for Runtime Exploration

── ✅ Auto-resolvable (agent handles) ────────────────────
  □ [package manager] install ([dependency dir] not found)
  □ .env creation (from .env.example — set config variable defaults)

── 🚫 BLOCKING (must resolve for full exploration) ──────
  □ [VAR_NAME] — [description] ([category: secret])
    💡 [hint: "Settings → Model Provider → Enter API key"]
  □ [SERVICE] — [description]
    💡 [hint: "docker compose up -d postgres"]

── ℹ️ Optional (UI structure visible without) ────────────
  □ [VAR_NAME] — [description] (truly non-essential for ANY flow)
──────────────────────────────────────────────────────────

Dev Server: `[start command]` (port [N])
```

> **Classification rule**: If a secret/service is used by ANY Feature's core flow (chat, search, CRUD, auth),
> it is 🚫 BLOCKING, not ℹ️ Optional. "Optional" is ONLY for features that are genuinely peripheral
> (e.g., analytics tracking, crash reporting, premium badges).

Ask via AskUserQuestion:
- **"Start infrastructure via Docker Compose + proceed"** — run `docker compose up -d` then continue (only shown if `docker-compose.yml` exists with relevant services)
- **"Environment ready — proceed"** — user has already configured the environment manually
- **"Proceed without some services"** — partial exploration (some features may error)
- **"Skip Runtime Exploration"** — skip due to complex environment setup

**If response is empty → re-ask** (per MANDATORY RULE 1). If "Skip" is selected, record `Runtime Exploration: skipped (environment complexity)` and proceed to Phase 2.

**Rules**:
- ⚠️ NEVER write actual secret values to `.env`. For `secret` category variables, write a placeholder comment: `# REQUIRES: your-value-here`
- `config` category variables: use values from `.env.example` or sensible defaults (e.g., `PORT=3000`, `NODE_ENV=development`)
- `feature-flag` category variables: default to enabled (`true` or `1`) to maximize explorable features

### 1.5-3. Auto Setup

Execute auto-resolvable steps:

1. **Dependency installation**:
   Run the detected package manager install command (e.g., `npm install`, `pip install -r requirements.txt`)
   - If fails → display error message → HARD STOP: "Resolve and retry" / "Skip Runtime Exploration"

2. **`.env` creation** (if `.env` does not exist and `.env.example` exists):
   Copy `.env.example` → `.env`, apply defaults for `config` variables, leave `secret` variables as placeholders
   - If `.env` already exists → skip (do NOT overwrite user's existing `.env`)

3. **Docker Compose** (if user selected this option):
   Run `docker compose up -d`
   - Wait for services to be ready (up to 30 seconds)
   - If fails → display error → HARD STOP: "Retry" / "Continue after manual setup" / "Skip"

4. **Build step** (if detected as necessary):
   Run the build command (e.g., `npm run build`)
   - If fails → display error → HARD STOP (same options as above)

### 1.5-4. App Launch + Readiness Check

> **CDP pre-setup (Electron `electron_mode = cdp`)**: If `electron_mode = cdp` was set in Step 1.5-0 (the browser_snapshot probe already showed Electron app content), the app is already running and CDP is connected. **Skip this entire section (1.5-4)** and proceed directly to 1.5-4b (App Initial Setup check) or 1.5-5 (Exploration).
>
> **CLI direct (Electron `electron_mode = cli_direct`)**: If `electron_mode = cli_direct` was set in Step 1.5-0 (Playwright CLI available), the Electron app will be launched directly via `_electron.launch()` in Phase 1.5-5. You still need to identify the start command and handle environment setup, but **skip Step 1b** (CDP launch command) as CDP is not needed.

**Step 1 — Identify the start command**:
Use the dev server command identified in 1.5-1.

> **Multiple start commands**: If multiple dev-related scripts exist (e.g., `dev`, `dev:web`, `electron:dev`), ask the user which one to run via AskUserQuestion. **If response is empty → re-ask** (per MANDATORY RULE 1).

**Step 1b — Electron apps: CDP launch command** (skip for non-Electron, skip if `electron_mode = cdp`, skip if `electron_mode = cli_direct`):

When `electron_mode = cli_direct` (Playwright CLI available), the app will be launched via `_electron.launch()` in the exploration step — no CDP flag is needed. Skip this step.

Otherwise (MCP-only path), replace the start command with the CDP-enabled version. Do NOT run the original command — Playwright MCP needs CDP to connect to Electron.

| Build Tool | CDP-Enabled Start Command | Alternative |
|-----------|--------------------------|-------------|
| **electron-vite** | `npx electron-vite dev -- --remote-debugging-port=9222` | `REMOTE_DEBUGGING_PORT=9222 npx electron-vite dev` |
| **electron-forge** | `ELECTRON_ARGS='--remote-debugging-port=9222' npm run start` | — |
| **electron-builder** | `ELECTRON_ARGS='--remote-debugging-port=9222' npm run dev` | — |
| **Direct electron** | `npx electron . --remote-debugging-port=9222` | — |
| **Other / Unknown** | Append ` -- --remote-debugging-port=9222` after the dev command | — |

⚠️ **electron-vite requires the `--` separator** before `--remote-debugging-port`. Alternatively, electron-vite 5.0+ supports `REMOTE_DEBUGGING_PORT` env var. Either method passes `--remote-debugging-port` to the Electron process (verify with `ps aux | grep remote-debugging`).

After launching, verify CDP is active: `lsof -i :9222`. If no result → the CDP flag was not picked up. Check the build tool and retry with the correct syntax.

**Step 2 — Run and wait for readiness**:
Run the start command (or CDP-modified command for Electron) as a background process, capturing stdout/stderr.
- Monitor stdout for readiness signals: `ready`, `listening on`, `started`, `compiled`, `Local:`, `http://localhost`
- Alternatively, poll the expected port with `lsof -i :[PORT]`
  - For Electron CDP: poll both the app port and port 9222
- Timeout: 120 seconds (see Electron CDP note below)

> **Electron CDP readiness — 3-phase polling**:
> Electron apps (especially with electron-vite) have a multi-stage startup: main process build (~18s) → preload build (~1s) → renderer dev server (~5s) → Electron launch → BrowserWindow creation → renderer load. CDP responds at different phases:
>
> | Phase | Check | Expected Timing |
> |-------|-------|-----------------|
> | 1. Port open | `lsof -i :9222` | Immediate ~ 5s after Electron starts |
> | 2. CDP HTTP API | `curl -m 5 http://127.0.0.1:9222/json/version` | After full build — 30-45s from command start |
> | 3. Targets available | `curl -m 5 http://127.0.0.1:9222/json` returns non-empty array | After BrowserWindow + renderer load — 45-60s |
>
> - Retry each phase at 5-second intervals. Total timeout: 120 seconds.
> - ⚠️ Phase 2 succeeding but Phase 3 returning `[]` is **normal** — BrowserWindow has not been created yet. Wait for renderer load.
> - ⚠️ Do NOT attempt to access the renderer dev server URL (e.g., `http://localhost:5173`) via a standalone browser. Electron preload bridge (`window.api`) is not available outside Electron, so the React app will fail to initialize (typically showing only a splash screen).
> - Only proceed to exploration (1.5-5) after Phase 3 confirms at least one target with `type: "page"`.

**Step 3 — Handle launch failure**:
If the app fails to start within the timeout:
1. Capture and analyze stderr/stdout error messages
2. Classify the error:
   - Missing environment variable → "`.env` requires `[VAR]` to be set"
   - DB connection refused → "Database connection failed — check if DB is running"
   - Port in use → "Port `[N]` is in use — terminate the existing process"
   - Module not found → "`[package]` not installed — re-run `npm install`"
   - Build error → "Build error — may be a source code issue"
3. Display error with suggestion → HARD STOP:
   - "Resolve and retry"
   - "Skip Runtime Exploration"

   **If response is empty → re-ask** (per MANDATORY RULE 1).

### 1.5-4b. User-Assisted Setup (HARD STOP — rebuild: BLOCKING for service-dependent features)

> **Principle: Delegate, Don't Skip** (CLAUDE.md P2 supplement)
> The agent cannot do everything. Some setup requires the user's hands, credentials, or judgment.
> When the agent hits something it can't automate, it MUST:
> 1. Tell the user **exactly what to do** (not just what's needed)
> 2. Provide **step-by-step commands** (not just descriptions)
> 3. **Wait for confirmation** before proceeding
> 4. **Never skip** because "the agent can't do it"

This step applies to ALL app types — not just Electron/GUI apps:

| App Type | What the user may need to configure | How |
|----------|-------------------------------------|-----|
| **Desktop (Electron/Tauri)** | API keys in Settings UI, provider selection, onboarding | Run app → navigate to Settings → configure |
| **Web app** | Admin account, OAuth setup, initial data seed | Open browser → go to http://localhost:PORT → configure |
| **API server** | Auth tokens, database seed, admin user creation | Run CLI commands or curl requests provided by the agent |
| **CLI tool** | Config file, credentials file, environment setup | Run specific commands provided by the agent |
| **Mobile app** | Device setup, emulator config | Follow agent's step-by-step instructions |

> **Why this matters for rebuild**: Without completing setup, Phase D can only observe **error states and empty UI** — not actual behavior. The resulting spec-drafts describe the broken experience, not the working app.

**Step 1 — Detect initial setup needs**:
Analyze the source code to identify likely first-run configuration requirements:

| Category | Detection Method | Example |
|----------|-----------------|---------|
| **API key / credentials** | Settings pages with key/token input fields, provider configuration UI | AI provider API key, payment gateway credentials, SMTP credentials |
| **Service connection** | Database connection config, external service URLs | PostgreSQL connection string, Redis URL, S3 bucket |
| **Account / auth** | Login page, registration flow, OAuth setup | Admin account creation, OAuth client ID/secret |
| **Provider selection** | Model/provider dropdown in settings | LLM model selection, embedding model, TTS provider |
| **Initial data** | Onboarding wizard, seed data, first-run detection | Default assistant creation, sample data import |

**Step 2 — Classify setup items by exploration impact**:

| Impact | Meaning | Action |
|--------|---------|--------|
| 🚫 **BLOCKING** | Without this, core Features cannot be explored at all (e.g., AI chat without API key → no message flow observable) | User MUST configure before Phase D |
| ⚠️ **PARTIAL** | Some Features work without this, but key flows are incomplete (e.g., no OAuth → login flow unobservable, but other pages work) | User SHOULD configure; document which flows are limited |
| ℹ️ **OPTIONAL** | Nice-to-have but UI structure is observable without it (e.g., premium features disabled) | Proceed without; note in runtime-exploration.md |

**Step 3 — Present setup guidance with impact classification**:

```
🔧 App Initial Setup (BLOCKING items must be completed for full exploration)

🚫 BLOCKING — Core features won't work without these:
  • Settings → Model Provider → Enter API key (e.g., OpenAI, Anthropic)
    Without this: chat sends fail, KB embedding fails, model dropdown empty
  • [Other blocking items]

⚠️ PARTIAL — Some flows limited without these:
  • Settings → OAuth → Configure GitHub login
    Without this: login flow unobservable, but all other pages accessible
  • [Other partial items]

ℹ️ OPTIONAL — UI structure visible without these:
  • Settings → Premium → Enter license key
    Without this: premium badge hidden, but UI layout observable

To configure BLOCKING items, follow these steps in a SEPARATE terminal:

[Generate EXACT commands based on detected app type from Phase 1]

── For Desktop apps (Electron/Tauri) ──
  1. Open a NEW terminal (keep this Claude Code session running)
  2. cd [target directory absolute path]
  3. [exact dev command from 1.5-1, e.g., "pnpm run dev"]
  4. The app window will open
  5. [exact navigation path, e.g., "Click ⚙️ Settings → Model Provider → Enter your OpenAI API key"]
  6. ⚠️ CLOSE THE APP completely (Cmd+Q or close window)
     → Settings are saved to disk (electron-store/sqlite/localStorage)
     → The agent's Playwright session will read the same saved settings
  7. Come back here and confirm

── For Web apps ──
  1. Open a NEW terminal
  2. cd [target directory absolute path]
  3. [exact dev command, e.g., "npm run dev"]
  4. Open browser: [URL, e.g., "http://localhost:3000"]
  5. [exact navigation, e.g., "Go to /admin → Create admin account → Set API keys"]
  6. You can leave the server running — Playwright will connect to the same server
  7. Come back here and confirm

── For API servers ──
  1. Start the server in a separate terminal: [exact command]
  2. Run these setup commands:
     [e.g., "curl -X POST http://localhost:8000/api/setup -d '{...}'"]
     [e.g., "node scripts/seed.js"]
  3. Leave the server running — the agent will test against it
  4. Confirm when done

── For CLI tools ──
  1. Run: [exact config command, e.g., "mytool config set api-key YOUR_KEY"]
  2. Verify: [exact verify command, e.g., "mytool config show"]
  3. Config is saved to file — the agent reads the same config
  4. Confirm when done
```

> 🚨 **User configures → data persisted to disk → agent's automated session reads the same data.**
>
> **Why the user must close Desktop apps**: Electron/Tauri apps lock their data files (SQLite, electron-store).
> If the user's instance is still running, Playwright's instance cannot read the same data.
> Web apps don't have this issue — the server is shared, browser sessions are independent.
>
> **Data persistence locations the agent should verify after user confirms**:
> - Electron: `~/Library/Application Support/[app-name]/` (macOS), `%APPDATA%/[app-name]/` (Windows)
> - Web: database (check with SQL query or API call)
> - CLI: config file (check with `cat ~/.config/[app]/config.json` or equivalent)

**HARD STOP** — Use AskUserQuestion:
- **"Setup complete and app closed — proceed"** (Recommended for Desktop) → User has configured, closed the app. Agent launches Playwright with same userData.
- **"Setup complete, server still running — proceed"** (Recommended for Web/API) → Server is running with configured data. Agent connects to it.
- **"Some BLOCKING items skipped — proceed with limited exploration"** → Record which items were skipped. Phase D will mark affected flows as `⚠️ LIMITED: [item] not configured — flow not fully observable`. These limitations propagate to spec-draft as `⚠️ UNVERIFIED` FRs.
- **"Skip all setup — UI structure only"** → Phase D captures only screen structure, not interaction flows. spec-draft quality will be significantly lower.

**If response is empty → re-ask** (per MANDATORY RULE 1).

**If response is empty → re-ask** (per MANDATORY RULE 1).

> **Note**: If no initial setup needs are detected from the code, skip this step and proceed directly to 1.5-5.

### 1.5-5. Runtime Exploration (Automated via Playwright)

With the app running, systematically explore using the available Playwright method. The exploration method is selected based on the detection results from Step 1.5-0:

---

#### When Playwright CLI is primary (`playwright_cli = true`):

Execute exploration via Playwright library mode (Node.js script):

**Pre-launch: Verify user configuration was persisted** (if 1.5-4b BLOCKING items were configured):

For each app type, verify the user's setup was saved BEFORE launching Playwright:

| App Type | Verification Method |
|----------|-------------------|
| **Electron** | Check userData dir exists and has config: `ls ~/Library/Application\ Support/[app-name]/` (macOS). Look for `config.json`, `*.db`, `electron-store` files with recent timestamps |
| **Web** | Query the database or API: `curl http://localhost:PORT/api/health` or check DB for admin user |
| **API** | Same as web — verify seed data exists |
| **CLI** | Check config file: `cat ~/.config/[app]/config.json` |

If verification fails → warn user: "Settings don't appear to be saved. Did you close the app after configuring? Try again."

**Phase A — Initial Landing**:
1. CLI library mode: `chromium.launch({ headless: false })` → `page.goto('http://localhost:[PORT]')` → `page.accessibility.snapshot()`
   - For Electron apps: use `_electron.launch({ executablePath: '[electron-binary-path]' })` instead of `chromium.launch()`
     - **userData sharing**: Pass the user's actual userData path via `--user-data-dir` so Playwright reads the same settings:
       ```javascript
       // 1. Detect the app's userData path from source code
       //    Look for: app.getPath('userData'), app.getName(), or electron-store config
       // 2. Common locations:
       //    macOS: ~/Library/Application Support/[app-name]/
       //    Linux: ~/.config/[app-name]/
       //    Windows: %APPDATA%/[app-name]/
       const app = await _electron.launch({
         args: ['out/main/index.js', '--user-data-dir=' + userDataPath]
       });
       ```
     - ⚠️ **User's app MUST be closed first** — two Electron instances cannot share the same userData simultaneously (LevelDB/SQLite lock)
     - After launch, verify settings loaded: check if provider/API key configuration is visible in the app UI
   - **Headful by default**: User sees the browser window during exploration (see runtime-verification.md §7)
2. Parse the snapshot JSON for page structure (roles, names, values, children)
3. Evaluate `page.evaluate(() => Array.from(document.querySelectorAll('script')).map(s => s.src))` → check for initial JS errors via console event listener

**Phase B — Navigation Discovery**:
1. From the accessibility tree snapshot, identify navigation elements (links, buttons with nav roles, elements with `role="navigation"`, `role="menubar"`, `role="tablist"`)
2. Collect internal link URLs via `page.evaluate(() => Array.from(document.querySelectorAll('a[href]')).map(a => ({ href: a.href, text: a.textContent.trim() })))`
3. Cross-reference with route definitions found in Phase 1 code scan (if available)

**Phase C — Screen-by-Screen Survey** (budget: max 20 screens):
For each discovered route (in navigation order):
1. CLI library mode: `page.goto(route)` → `page.accessibility.snapshot()`
2. Record per screen:
   - **Route path** and page title/heading
   - **Key UI elements**: buttons, forms, tables, lists, editors, charts (from accessibility tree roles)
   - **Layout pattern**: sidebar+content, full-width, centered-form, split-pane, etc.
   - **Data display type**: table, card grid, tree view, editor, empty state, etc.
   - **Interactive elements**: form inputs, dropdowns, toggles, drag targets
3. If console errors appear (via `page.on('console', ...)` listener) → record them (continue exploration)

**Phase D — Interactive Flow Execution** (rebuild: MANDATORY, adopt: skip):

> Code analysis tells you a dropdown exists. Runtime execution tells you what's IN the dropdown, what happens when you select an option, and what auto-fills afterward.

For each major Feature area discovered in Phase C, **execute the primary user flow**:

1. **CRUD flow** (if list + create UI exists):
   - Click "Create/Add/New" → record dialog/form structure
   - Record each form field: type (text/dropdown/slider/checkbox), options, validation, auto-fill behavior
   - Fill with test data → submit → record success feedback + where new item appears

2. **Configuration flow** (if settings UI exists):
   - Navigate to settings → record all sections and controls
   - For each dropdown: record available options
   - For API key inputs: record validation behavior

3. **Data pipeline flow** (if file upload/processing exists):
   - Upload test file → record formats, progress, status transitions
   - Track data through: upload → processing → stored → queryable → displayed

4. **Cross-feature interaction** (if features interact):
   - Execute flow spanning 2+ features → record the full chain

**Output**: Generate **UI Flow Spec** per flow (saved to pre-context):
```markdown
### Flow: [Flow Name]
| Step | User Action | UI Control | Response | State Change |
|------|------------|------------|----------|-------------|
| 1 | Click [+ Create] | Button | Dialog opens | — |
| 2 | Enter name | TextInput (required) | — | form.name |
| 3 | Select model | Dropdown (configured providers only) | Dimensions auto-fills | form.model |
| 4 | Click [Create] | Button (enabled when valid) | Dialog closes, item in list | list += new |

Error paths observed:
- Empty name → red border, Create disabled
- No providers → dropdown empty, helper "Configure a provider first"
```

Budget: Max 5 flows per Feature area, max 30 minutes total

---

#### When Playwright MCP is available (`playwright_mcp = true`, `playwright_cli = false`):

Execute exploration via Playwright MCP tools:

**Phase A — Initial Landing**:
1. `browser_navigate` → `http://localhost:[PORT]`
2. `browser_snapshot` → capture accessibility tree (page structure, elements, roles)
3. `browser_console_messages` → check for initial JS errors

**Phase B — Navigation Discovery**:
1. From the accessibility tree, identify navigation elements (`nav`, sidebar, menu, tabs, header links)
2. Collect all internal navigation links (URL + text)
3. Cross-reference with route definitions found in Phase 1 code scan (if available)

**Phase C — Screen-by-Screen Survey** (budget: max 20 screens):
For each discovered route (in navigation order):
1. `browser_navigate` → target URL
2. `browser_snapshot` → capture page structure
3. Record per screen:
   - **Route path** and page title/heading
   - **Key UI elements**: buttons, forms, tables, lists, editors, charts (from accessibility tree roles)
   - **Layout pattern**: sidebar+content, full-width, centered-form, split-pane, etc.
   - **Data display type**: table, card grid, tree view, editor, empty state, etc.
   - **Interactive elements**: form inputs, dropdowns, toggles, drag targets
4. If console errors appear → record them (continue exploration)

**Phase D — Interactive Flow Execution** (rebuild: MANDATORY, adopt: skip):

> Code analysis tells you a dropdown exists. Runtime execution tells you what's IN the dropdown, what happens when you select an option, and what auto-fills afterward.

For each major Feature area discovered in Phase C, **execute the primary user flow**:

1. **CRUD flow** (if list + create UI exists):
   - Click "Create/Add/New" → record dialog/form structure
   - Record each form field: type (text/dropdown/slider/checkbox), options, validation, auto-fill behavior
   - Fill with test data → submit → record success feedback + where new item appears

2. **Configuration flow** (if settings UI exists):
   - Navigate to settings → record all sections and controls
   - For each dropdown: record available options
   - For API key inputs: record validation behavior

3. **Data pipeline flow** (if file upload/processing exists):
   - Upload test file → record formats, progress, status transitions
   - Track data through: upload → processing → stored → queryable → displayed

4. **Cross-feature interaction** (if features interact):
   - Execute flow spanning 2+ features → record the full chain

**Output**: Generate **UI Flow Spec** per flow (saved to pre-context):
```markdown
### Flow: [Flow Name]
| Step | User Action | UI Control | Response | State Change |
|------|------------|------------|----------|-------------|
| 1 | Click [+ Create] | Button | Dialog opens | — |
| 2 | Enter name | TextInput (required) | — | form.name |
| 3 | Select model | Dropdown (configured providers only) | Dimensions auto-fills | form.model |
| 4 | Click [Create] | Button (enabled when valid) | Dialog closes, item in list | list += new |

Error paths observed:
- Empty name → red border, Create disabled
- No providers → dropdown empty, helper "Configure a provider first"
```

Budget: Max 5 flows per Feature area, max 30 minutes total

---

**Budget Control** (applies to both CLI and MCP paths):
- Maximum screens: 20 (if more routes exist, sample representative ones and note "N more similar pages")
- Per-screen time: 10 seconds max
- Total exploration budget: 5 minutes
- Repeated layout patterns: sample 3, then note "N more with same pattern"

**Crash Recovery**:
When app process termination or Playwright connection loss is detected during exploration:
1. Preserve already collected screen data (immediately write explored screens to runtime-exploration.md)
2. HARD STOP — **Use AskUserQuestion** with options:
   - "Restart app and continue exploration" — restart the app, skip already-explored screens, resume from remaining screens
   - "Proceed with data collected so far" — complete Phase 1.5 with only the collected data
   - "Skip Runtime Exploration" — skip Phase 1.5 entirely
   **If response is empty → re-ask** (per MANDATORY RULE 1)

### 1.5-6. Observation Recording + Cleanup

**Step 1 — Write `specs/_global/runtime-exploration.md`**:
Compile exploration results into a structured markdown file organized **by route/screen**. Each screen block contains all observed information (UI elements, user flows, behavior, errors) in one place. This file persists across phases and sessions — Phase 2 reads it for cross-referencing, Phase 4-2 distributes its contents to each Feature's `pre-context.md` using route-to-Feature mapping.

Write the file with the following structure:

```markdown
# Runtime Exploration Results

> Generated by `/reverse-spec` Phase 1.5 — [ISO timestamp]
> Mode: automated (Playwright)
> Target: [target directory path]

## App-Wide Observations

### Initial Setup Requirements
- **In-app configuration**: [Settings needed before full use — e.g., API provider setup, model selection, onboarding]
- **Setup completed**: [yes / partial / no — and what was configured]

### Navigation Structure
- **Top-level nav**: [item1, item2, item3, ...]
- **Sub-navigation patterns**: [tabs / sidebar tree / breadcrumb / ...]
- **Routing scheme**: [hash / history / file-based / ...]

### Global UI Patterns
- **Component library**: [detected from rendered DOM class names/attributes]
- **Theme/color scheme**: [dark/light, primary colors, etc.]
- **Responsive behavior**: [if observed]
- **Common layout patterns**: [patterns observed across screens]

---

## Screen: /route-path — [Page Title]

**Layout**: [sidebar+content / centered-form / full-width / split-pane / ...]

### UI Elements
- [Key elements: forms, tables, editors, modals, etc.]
- [Interactive elements: buttons, dropdowns, toggles, etc.]

### User Flows from This Screen
| Flow | Steps | Observations |
|------|-------|--------------|
| [Flow name] | `/this-route` → [action] → `/next-route` → ... | redirects, toasts, loading states |

### Runtime Behavior
- **Loading states**: [skeleton, spinner, progressive, optimistic updates]
- **Empty states**: [placeholder messages, illustrations, CTAs when no data]
- **Error handling**: [validation messages, toast notifications, error boundaries]
- **Console errors**: [JS errors observed on this screen, if any]

### Notes
- [Notable patterns, special interactions, accessibility observations, etc.]

---

## Screen: /another-route — [Page Title]

(... same structure per screen ...)
```

**Conventions**:
- One `## Screen:` section per explored route
- User flows that span multiple screens: record in the **starting screen's** section, with cross-references to destination screens
- Screens not reachable via navigation (discovered only in code): note in App-Wide Observations as "Code-only routes"

**Step 2 — Report summary to user**:
```
📊 Runtime Exploration Summary

Screens explored: [N]
Navigation items: [N]
User flows identified: [N]
Console errors: [N] ([critical count] critical)
Layout patterns: [list of patterns]

Key observations:
  - [Notable finding 1]
  - [Notable finding 2]
```

**Step 2b — MCP Interactive Supplement** (CLI+MCP complementary mode):

> **When**: `playwright_cli = true` AND `playwright_mcp = true` (MCP tools available in session).
> **Skip if**: MCP unavailable, or CLI exploration already covered all screens comprehensively.

After CLI automated exploration (Phase A-D), use MCP tools to supplement with interactive inspection:

1. **Navigate to the app** via MCP (`browser_navigate` to the app URL)
2. **Interactive exploration** for areas where CLI scripts were limited:
   - Complex UI interactions that require multi-step state (drag-and-drop, hover menus, modals)
   - Dynamic content that loads lazily or requires scroll-triggered rendering
   - Real-time features (WebSocket updates, live search, auto-complete suggestions)
3. **Browser console check**: Read MCP browser console for runtime errors not visible in CLI snapshots
4. Record any additional findings in `runtime-exploration.md` under a `## MCP Supplement` section

> **Note**: This step enriches CLI results, it does NOT replace them. CLI remains the primary data source for structured snapshots and screenshots. MCP adds interactive/real-time observations.

**Step 3 — Dev server cleanup**:
1. Terminate the dev server process
2. If Docker Compose was started: leave services running (user may need them for `smart-sdd`)
   - Display: "ℹ️ Docker Compose services are still running. To stop: `docker compose down`"
3. `.env` file created during setup: leave in place (reusable for `smart-sdd`)

**Step 4 — Visual Reference Capture** (rebuild mode only):

After runtime exploration, capture screenshots of key screens as **visual reference artifacts** for the rebuild pipeline. These screenshots serve as the target UI that the rebuilt app should match.

**When to capture**: Always attempt when Playwright is available (CLI or MCP) AND app was explored in Step 3. Skip if exploration was skipped or Playwright is unavailable.

**Procedure**:

When Playwright CLI is primary (`playwright_cli = true`):
1. For each screen explored in Step 3 (from the navigation log):
   - CLI library mode: `page.goto(route)` → `page.waitForTimeout(3000)` → `page.screenshot({ path: 'specs/_global/visual-references/{screen-name}.png', fullPage: true })`
   - For Electron apps: use `_electron.launch()` → `firstWindow()` to obtain the page object
2. Generate `specs/_global/visual-references/manifest.md` (same format as below)
3. Display: `📸 Visual references captured: [N] screens → specs/_global/visual-references/`

When Playwright MCP is the only option (`playwright_mcp = true`, `playwright_cli = false`):
1. For each screen explored in Step 3 (from the navigation log):
   - Navigate to the screen URL/route
   - Wait for content to stabilize (~3 seconds)
   - Take a screenshot via MCP → save to `specs/_global/visual-references/{screen-name}.png`
2. Generate `specs/_global/visual-references/manifest.md`:
   ```markdown
   # Visual Reference Manifest

   | Screen | Route/URL | Screenshot | Key UI Elements |
   |--------|-----------|------------|-----------------|
   | [name] | [route]   | {screen-name}.png | [notable elements: sidebar, nav, form, list...] |
   ```
3. Display: `📸 Visual references captured: [N] screens → specs/_global/visual-references/`

**Manifest Verification (after capture)**:
After generating `manifest.md`, verify completeness:
1. List all `.png` files in `specs/_global/visual-references/`
2. Check each `.png` file has a corresponding row in `manifest.md`
3. If any file is missing from the manifest, add it with inferred screen name and `[TBD]` elements
4. Display: `✅ Manifest verified: [N] screenshots, [N] manifest entries (matched)`

**When Playwright unavailable or app cannot be launched**:
- Display: `⚠️ Visual reference capture skipped (Playwright/app not available). You can provide screenshots manually at: specs/_global/visual-references/`
- Create the `visual-references/` directory and an empty `manifest.md` with the template header

**Usage downstream**:
- `plan` step: Visual references injected as context for UI architecture decisions
- `implement` step: References displayed during Review for visual fidelity awareness
- `verify` step: Phase 3 Visual Fidelity Check compares rebuilt UI against reference screenshots

**Step 4b — Style Token Extraction** (rebuild mode only, Playwright available):

After visual reference screenshots, extract concrete CSS values from the running app for implementation-time reference. Code-reading alone cannot capture computed styles, and agents guessing colors/spacing leads to visual divergence.

When Playwright CLI is primary (`playwright_cli = true`):
1. Navigate to the app's main screen: `page.goto('http://localhost:[PORT]')`
2. Use `page.evaluate()` to extract:
   - CSS custom properties from `:root` (e.g., `--color-primary`, `--spacing-md`, `--font-family`)
   - Computed styles from landmark elements: `header`, `nav`, `main`, `aside`, `footer` (background, color, padding, font)
   - Body typography: `fontFamily`, `fontSize`, `lineHeight`, `color`, `backgroundColor`

When Playwright MCP is the only option (`playwright_mcp = true`, `playwright_cli = false`):
1. Navigate to the app's main screen (or the most representative screen explored in Step 3)
2. Use `browser_evaluate` to extract:
   - CSS custom properties from `:root` (e.g., `--color-primary`, `--spacing-md`, `--font-family`)
   - Computed styles from landmark elements: `header`, `nav`, `main`, `aside`, `footer` (background, color, padding, font)
   - Body typography: `fontFamily`, `fontSize`, `lineHeight`, `color`, `backgroundColor`
3. Save to `specs/_global/visual-references/style-tokens.md`:
   ```markdown
   # Style Tokens

   ## CSS Custom Properties
   | Property | Value |
   |----------|-------|
   | `--color-primary` | `#3b82f6` |
   | ... | ... |

   ## Landmark Styles
   | Element | Property | Value |
   |---------|----------|-------|
   | `header` | `background` | `#1e1e2e` |
   | `header` | `height` | `48px` |
   | ... | ... | ... |

   ## Typography
   | Property | Value |
   |----------|-------|
   | `font-family` | `'Inter', sans-serif` |
   | `font-size` | `14px` |
   | ... | ... |
   ```
4. Display: `🎨 Style tokens extracted → specs/_global/visual-references/style-tokens.md`
5. If extraction fails (cross-origin restrictions, SPA not rendered, or app is server-rendered without client JS):
   - Display: `⚠️ Style token extraction skipped — [reason]. You can add tokens manually.`
   - Create an empty `style-tokens.md` with the template header only

**Step 5 — Runtime Default Verification** (MANDATORY when Playwright was used in Steps 1-4):

> **Purpose**: Verify that settings/configuration defaults extracted from code analysis match the app's actual runtime state. Static code analysis can misidentify defaults (e.g., reading a `'left'` sidebar constant while the app's runtime default is `'top'` tab mode). Runtime values take precedence.

> ⚠️ **This step is MANDATORY if Playwright was successfully used in any of Steps 1-4 above.** You MUST NOT skip it when Playwright is available. If you performed runtime exploration with Playwright, you MUST also perform runtime default verification.

1. **Identify settings-related SBI entries**: From `runtime-exploration.md` and code analysis, list SBI entries that involve:
   - Layout modes (sidebar position, panel arrangement, tab vs. sidebar)
   - Theme defaults (dark/light mode)
   - UI configuration (visible items, default selections, window dimensions)
   - Feature toggles (enabled/disabled by default)

2. **Verify against runtime state**: If the source app is still running (or can be relaunched), use Playwright to check:
   - Read DOM attributes that reflect settings (e.g., `navbar-position`, `data-theme`, `class` on root elements)
   - Check computed layout (element positions, visibility of sidebars/panels/tabs)
   - Read application state if accessible (e.g., Zustand/Redux store via `window.__STORE__` or `evaluate()`)

3. **Compare and reconcile**:
   - If runtime value matches code analysis → ✅ Confirmed
   - If runtime value differs from code analysis → ⚠️ **Update the SBI entry and observations to use the runtime value**
   - Display discrepancies:
     ```
     🔍 Runtime Default Verification:
       ✅ theme: 'dark' (matches code analysis)
       ⚠️ navbarPosition: runtime='top', code analysis='left' → CORRECTED to 'top'
       ✅ sidebarWidth: 260px (matches code analysis)
     ```

4. **Update artifacts**: If any corrections were made:
   - Update `runtime-exploration.md` with corrected defaults
   - Add note: `⚠️ Corrected from code analysis — runtime verification showed different default`

5. **Record in runtime-exploration.md**: Append a `## Runtime Default Verification` section to `runtime-exploration.md` with the full verification results table. This section MUST exist when Playwright was used — its absence indicates the step was skipped.

6. **If Playwright was not available or app cannot be relaunched**: Skip this step and display:
   `ℹ️ Runtime Default Verification skipped — Playwright not available. Settings defaults are from code analysis only (may differ from actual runtime).`

**Step 6 — Proceed to Phase 2** (BLOCKING gate):

**Pre-flight check before proceeding:**
If Playwright was successfully used in any of Steps 1-4 above, verify that `runtime-exploration.md` contains a `## Runtime Default Verification` section. If the section is missing, you MUST go back and execute Step 5 NOW — do NOT proceed to Phase 2 without it. This is a BLOCKING gate.

```
✅ Phase 1.5 Pre-flight: Runtime Default Verification section found in runtime-exploration.md
```
or
```
❌ Phase 1.5 Pre-flight FAILED: Playwright was used but Runtime Default Verification section is missing
   → Executing Step 5 now...
```

Runtime exploration results are saved in `specs/_global/runtime-exploration.md`. Visual references (if captured) are saved in `specs/_global/visual-references/`. Style tokens (if extracted) are saved in `specs/_global/visual-references/style-tokens.md`. Phase 2 will read these to cross-reference code analysis with runtime observations.

📝 **Case Study Recording**: Append milestone entry to `./case-study-log.md` (CWD root) per [recording-protocol.md](../../case-study/reference/recording-protocol.md):
```
### M1.5 — Runtime Exploration
- **Timestamp**: [ISO timestamp]
- **Mode**: [automated (Playwright) | skipped]
- **Screens explored**: [N]
- **Visual references captured**: [N screenshots | skipped]
- **Key findings**: [1-2 sentence summary]
```

---

