# User-Assisted Setup Protocol

> **Shared module** — used when the app needs user configuration before automated exploration/verification.
> Principle: **Delegate, Don't Skip** — provide EXACT commands, wait for confirmation, never skip.

---

## When to Trigger

Trigger when Data Storage Map (see `data-storage-map.md`) identifies items that:
1. Require secrets the agent cannot generate (API keys, passwords, OAuth tokens)
2. Require in-app UI interaction (provider selection, onboarding wizards)
3. Require external service setup (database, Redis, message queue)

---

## Impact Classification

| Impact | Meaning | Action |
|--------|---------|--------|
| 🚫 **BLOCKING** | Core Features cannot function without this | User MUST configure before proceeding |
| ⚠️ **PARTIAL** | Some flows limited but others work | User SHOULD configure; document limitations |
| ℹ️ **OPTIONAL** | Peripheral features only | Proceed without; note in results |

> **Rule**: If a credential is used by ANY Feature's core flow, it is 🚫 BLOCKING, not ℹ️ Optional.

---

## Setup Instructions (by app type)

Generate EXACT commands based on Data Storage Map results:

### Desktop (Electron/Tauri)

```
🔧 Setup Required (BLOCKING items)

1. Open a NEW terminal (keep this Claude Code session running)
2. cd [target directory absolute path]
3. [exact dev command, e.g., "pnpm run dev"]
4. The app window will open
5. [exact navigation path, e.g., "Settings → Model Provider → Enter API key"]
6. ⚠️ CLOSE THE APP completely (Cmd+Q or close window)
   → Settings saved to disk → Playwright reads same data
7. Come back here and confirm
```

### Web App

```
🔧 Setup Required

1. Open a NEW terminal
2. cd [target directory absolute path]
3. [exact dev command, e.g., "npm run dev"]
4. Open browser: [URL, e.g., "http://localhost:3000"]
5. [exact navigation, e.g., "/admin → Create account → Set API keys"]
6. Leave server running — Playwright connects to same server
7. Come back here and confirm
```

### API Server

```
🔧 Setup Required

1. Start server: [exact command]
2. Run setup commands:
   [e.g., "curl -X POST http://localhost:8000/api/setup -d '{...}'"]
   [e.g., "node scripts/seed.js"]
3. Leave server running
4. Confirm when done
```

### CLI Tool

```
🔧 Setup Required

1. Run: [exact config command, e.g., "mytool config set api-key YOUR_KEY"]
2. Verify: [exact verify command, e.g., "mytool config show"]
3. Config saved to file — Playwright/agent reads same config
4. Confirm when done
```

---

## Post-Setup Verification

Before proceeding to automated exploration, verify the user's setup persisted:

| App Type | Verification Method |
|----------|-------------------|
| **Electron** | `ls [userData path]` — check config.json timestamp is recent |
| **Web** | `curl [health endpoint]` or check DB for admin user |
| **API** | Same as web |
| **CLI** | `cat [config file path]` — verify key fields present |

If verification fails → warn: "Settings don't appear saved. Did you close the app? Try again."

---

## HARD STOP Options

| Option | For | Meaning |
|--------|-----|---------|
| "Setup complete and app closed" | Desktop | User configured + closed. Playwright uses same userData |
| "Setup complete, server running" | Web/API | Server has data. Playwright connects to it |
| "Some items skipped — limited mode" | Any | Record skipped items. Affected flows marked LIMITED |
| "Skip all setup — structure only" | Any | UI structure only. No interaction flows captured |

---

## App Close Requirement

> **Why desktop apps must close**: Electron/Tauri use LevelDB for localStorage and IndexedDB.
> LevelDB is single-process — two instances cannot share the same data directory.
> If the user's app is running, Playwright's instance gets an empty/locked database.
>
> **Web/API apps don't need to close**: The server is shared. Playwright opens a new browser
> session against the same server — no file lock issues.

---

## Consumers

| Skill | When | Purpose |
|-------|------|---------|
| **reverse-spec** | Phase 1.5-4b | Configure source app before exploration |
| **smart-sdd** | verify (user-assisted SCs) | Configure target app for credential-dependent tests |
| **code-explore** | trace (optional) | Configure source app for runtime-assisted trace |
