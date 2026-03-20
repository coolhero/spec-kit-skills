# Data Storage Map Detection

> **Shared module** — used by reverse-spec (Phase 1-6), smart-sdd (verify), code-explore (orient).
> Identifies WHERE the app stores persistent data and derives runtime configuration.

---

## Detection

Scan source code for storage patterns:

| Storage Type | Detection Signals | Example |
|-------------|------------------|---------|
| **Config store** | `electron-store`, `conf`, `configstore`, `dotenv` | API keys, preferences |
| **SQL database** | `better-sqlite3`, `prisma`, `drizzle`, `typeorm`, `sequelize` | Entities, sessions |
| **Document DB** | `dexie`, `indexedDB`, `pouchdb`, `lowdb` | Messages, documents |
| **Key-value** | `localStorage`, `redux-persist`, `zustand/persist` | App state, UI prefs |
| **File storage** | `app.getPath('userData')`, custom data dirs | Uploads, vector DBs |
| **External service** | `redis`, `mongodb`, `postgres` connection strings | Server-side data |

---

## Output Format

```markdown
📦 Data Storage Map

| Storage | Type | Location | Lock? | Contains |
|---------|------|----------|-------|----------|
| [name] | [type] | [path] | [Yes/No] | [what's stored] |

userData path: [resolved path]
App name: [from package.json name/productName]
```

---

## userData Path Resolution

### Electron/Tauri (Desktop)

1. Read `package.json` → `name` field
2. Read `electron-builder.yml` or equivalent → `productName` field
3. **Dev vs prod userData paths differ** — this is the #1 cause of "my settings aren't visible":
   - **Production build**: uses `productName` → `~/Library/Application Support/[productName]/`
   - **Dev mode**: uses `name` → `~/Library/Application Support/[name]/`
   - **electron-vite dev mode**: appends `Dev` suffix → `~/Library/Application Support/[productName]Dev/`
4. **ALWAYS check ALL possible paths** — list `~/Library/Application Support/` and grep for the app name:
   ```bash
   ls "/Users/[user]/Library/Application Support/" | grep -i [app-name]
   ```
5. **Use the MOST RECENT config.json** — compare timestamps across all matching directories:
   ```bash
   stat -f "%Sm" "/Users/[user]/Library/Application Support/[dir]/config.json"
   ```
   The most recently modified is the one the user has been using.
6. Record the correct path as `PLAYWRIGHT_USER_DATA_DIR`

**Common mistake**: Using productName path (`Cherry Studio`) when user configured via `pnpm run dev` (which uses `Cherry StudioDev`). The API keys, model settings, and KB data are in the dev path.

### Web / API Server

| Storage | Location |
|---------|----------|
| Database | Connection string from `.env` or ORM config |
| Session | Redis URL or in-memory |
| Uploads | `uploads/` dir or cloud storage config |

### CLI Tool

Config locations: `~/.config/[app]/`, `~/.local/share/[app]/`, `~/.[app]rc`

---

## Lock Analysis

| Storage Technology | Concurrent Access | Implication |
|-------------------|-------------------|-------------|
| LevelDB (localStorage, IndexedDB) | ❌ Single process | App MUST be closed before Playwright |
| SQLite (WAL mode) | ⚠️ Concurrent reads OK | App SHOULD be closed for writes |
| SQLite (non-WAL) | ❌ Single writer | App MUST be closed |
| electron-store (JSON) | ✅ File-based | Can coexist (last-write-wins) |
| Redis / MongoDB | ✅ Multi-client | No issue |
| .env / config files | ✅ File-based | Can coexist |

---

## Derived Variables (consumed by other modules)

```
PLAYWRIGHT_USER_DATA_DIR = [resolved userData path]
REQUIRE_APP_CLOSE = true if any LevelDB store detected
SETUP_METHOD = "in-app-ui" | "env-file" | "cli-command" | "database-seed"
AUTO_BLOCKING_ITEMS = [list of items stored in config store that need user setup]
```

---

## Consumers

| Skill | Step | What It Uses |
|-------|------|-------------|
| **reverse-spec** | Phase 1-6 (detect) → Phase 1.5 (consume) | Full map + userData + lock analysis |
| **smart-sdd** | verify pre-flight | userData path + lock for test isolation decision |
| **code-explore** | orient (detect) | userData path for optional runtime trace |
