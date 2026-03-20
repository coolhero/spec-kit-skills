# Data Storage Map Detection

> **Shared module** — used by reverse-spec (Phase 1-6), smart-sdd (verify), code-explore (orient).
> Identifies WHERE the app stores persistent data and derives runtime configuration.
>
> **Core problem this solves**: Dev mode and production mode often use DIFFERENT data directories.
> If the user configured API keys via `pnpm run dev`, those keys are in the dev directory.
> If Playwright launches the production build, it reads the production directory — and finds nothing.
> This module resolves the correct path so Playwright sees the user's actual configuration.

---

## Detection

Scan source code for storage patterns:

| Storage Type | Detection Signals | Example |
|-------------|------------------|---------|
| **Config store** | `electron-store`, `conf`, `configstore`, `dotenv` | API keys, preferences |
| **SQL database** | `better-sqlite3`, `prisma`, `drizzle`, `typeorm`, `sequelize`, `libsql` | Entities, sessions |
| **Document DB** | `dexie`, `indexedDB`, `pouchdb`, `lowdb` | Messages, documents |
| **Key-value** | `localStorage`, `redux-persist`, `zustand/persist` | App state, UI prefs |
| **File storage** | `app.getPath('userData')`, custom data dirs | Uploads, vector DBs |
| **Encrypted** | `safeStorage`, OS keychain, credential manager | API keys, tokens |
| **External service** | `redis`, `mongodb`, `postgres` connection strings | Server-side data |

---

## Output Format

```markdown
📦 Data Storage Map

| Storage | Type | Location | Lock? | Contains |
|---------|------|----------|-------|----------|
| [name] | [type] | [path] | [Yes/No] | [what's stored] |

Dev userData: [resolved dev path]
Prod userData: [resolved prod path]
Active userData: [most recent = user's actual config] ← PLAYWRIGHT_USER_DATA_DIR
```

---

## userData Path Resolution — Universal Algorithm

### Step 0: Check for userData Override in Source Code

**🚨 DO THIS FIRST** — before any path resolution. Many apps override userData in code:

```bash
grep -rn "setPath.*userData\|app\.setPath" src/main/ --include="*.ts" --include="*.js"
```

If found: the app **ignores** `--user-data-dir`. The code determines the actual path.
Read the override logic to understand which path is used in dev vs prod mode.

Common pattern: `if (isDev) { app.setPath('userData', path + 'Dev') }`
→ Dev mode userData ≠ prod mode userData, AND `--user-data-dir` is overridden.

### Step 1: Extract App Identity from Source

| App Type | Where to find identity |
|----------|----------------------|
| **Electron** | `package.json` → `name` (dev), `electron-builder.yml` → `productName` (prod) |
| **Electron (electron-vite)** | Same + `Dev` suffix appended in dev mode. **Also check `app.setPath()` in source** |
| **Electron (electron-forge)** | `forge.config.js` → `packagerConfig.name` (prod) |
| **Tauri** | `tauri.conf.json` → `productName` (both modes usually same) |
| **NW.js** | `package.json` → `name` |
| **Web app** | `.env` → `DATABASE_URL`, `SESSION_STORE` |
| **CLI tool** | `package.json` → `name` or `bin` key |

### Step 2: Resolve Platform Base Path

| Platform | Base path |
|----------|-----------|
| **macOS** | `~/Library/Application Support/` |
| **Linux** | `~/.config/` |
| **Windows** | `%APPDATA%/` |
| **Web DB** | Connection string from `.env` or ORM config |
| **CLI config** | `~/.config/[name]/` or `~/.[name]rc` |

### Step 3: Discover ALL Matching Directories

**🚨 CRITICAL**: Do NOT assume a single directory. Dev/prod/test modes create DIFFERENT directories.

```bash
# macOS example — find ALL directories matching the app name
ls "/Users/$(whoami)/Library/Application Support/" | grep -i "[app-name-fragment]"
```

**Known patterns that create multiple directories**:

| Build Tool | Dev Directory | Prod Directory |
|-----------|--------------|---------------|
| **electron-vite** | `[productName]Dev` | `[productName]` |
| **electron-builder** | `[name]` (package.json) | `[productName]` (builder config) |
| **electron-forge** | `[name]` | `[packagerConfig.name]` |
| **Tauri** | Same as prod (usually) | `[productName]` |

**Real-world example (Cherry Studio)**:
```
~/Library/Application Support/
  Cherry Studio/        ← installed app (productName)
  Cherry StudioDev/     ← electron-vite dev mode (productName + "Dev")
  CherryStudio/         ← older version (package.json name)
  CherryStudioDev/      ← older dev mode
```

### Step 4: Determine Active Directory

Compare config file timestamps across ALL discovered directories:

```bash
for dir in [each discovered directory]; do
  stat -f "%Sm" "$dir/config.json" 2>/dev/null
done
```

**The most recently modified = the one the user is actively using.**

Record as `PLAYWRIGHT_USER_DATA_DIR`.

### Step 5: Verify Settings Exist

After determining the active directory, verify it contains the expected settings:

```bash
# Check config store exists and has content
cat "[active-dir]/config.json" | head -5

# Check database files exist
ls "[active-dir]/Data/" 2>/dev/null

# Check for encrypted storage markers
ls "[active-dir]/SafeStorage/" 2>/dev/null
```

If the active directory is empty or missing expected files → warn the user:
```
⚠️ Active userData directory exists but appears empty.
The user may not have configured the app yet.
```

---

## Web / API Server Environment Resolution

Web apps don't have userData directories, but they have **environment-specific configuration**:

### Step 1: Detect Environment Files

```bash
ls -la .env .env.local .env.development .env.production .env.test 2>/dev/null
```

| File | Priority | Typical Content |
|------|----------|-----------------|
| `.env.local` | Highest (user-specific) | API keys, local overrides |
| `.env.development` | Dev mode only | Dev database URL, debug flags |
| `.env.production` | Prod mode only | Prod database URL, prod API keys |
| `.env` | Default fallback | Shared settings |

### Step 2: Determine Active Database

```bash
# From .env or ORM config
grep DATABASE_URL .env .env.local .env.development 2>/dev/null
```

**Dev vs prod may use different databases**:
- Dev: `sqlite:./dev.db` or `postgres://localhost/myapp_dev`
- Prod: `postgres://prod-server/myapp`

### Step 3: Verify Server is Running

```bash
# Check if dev server is already running
lsof -i :[expected-port] 2>/dev/null
curl -s http://localhost:[port]/health 2>/dev/null
```

If server is running → Playwright connects to it (no new server needed).
If server is NOT running → start it, wait for health check, then proceed.

---

## CLI Tool Config Resolution

```bash
# Check standard config locations
for path in \
  "$HOME/.config/[app-name]/" \
  "$HOME/.[app-name]rc" \
  "$HOME/.[app-name]/config" \
  "$HOME/.local/share/[app-name]/"; do
  [ -e "$path" ] && echo "FOUND: $path" && stat -f "%Sm" "$path"
done
```

---

## Lock Analysis

| Storage Technology | Concurrent Access | Implication |
|-------------------|-------------------|-------------|
| LevelDB (localStorage, IndexedDB) | ❌ Single process | App MUST be closed before Playwright |
| SQLite (WAL mode) | ⚠️ Concurrent reads OK | App SHOULD be closed for writes |
| SQLite (non-WAL) | ❌ Single writer | App MUST be closed |
| electron-store (JSON) | ✅ File-based | Can coexist (last-write-wins) |
| Redis / MongoDB | ✅ Multi-client | No issue |
| PostgreSQL | ✅ Multi-client | No issue |
| .env / config files | ✅ File-based | Can coexist |
| OS Keychain (safeStorage) | ✅ OS-managed | Can coexist |

---

## Derived Variables (consumed by other modules)

```
PLAYWRIGHT_USER_DATA_DIR = [resolved active userData path — Step 4 result]
REQUIRE_APP_CLOSE = true if any LevelDB/single-process store detected
SETUP_METHOD = "in-app-ui" | "env-file" | "cli-command" | "database-seed"
AUTO_BLOCKING_ITEMS = [list of items stored in config store that need user setup]
DEV_VS_PROD_WARNING = true if dev and prod directories both exist and differ
```

---

## Consumers

| Skill | Step | What It Uses |
|-------|------|-------------|
| **reverse-spec** | Phase 1-6 (detect) → Phase 1.5 (consume) | Full map + active userData + lock analysis |
| **smart-sdd** | verify pre-flight | userData path + lock for test isolation decision |
| **code-explore** | orient (detect) | userData path for runtime trace |
