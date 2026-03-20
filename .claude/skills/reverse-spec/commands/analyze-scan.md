## Phase 1 — Project Scan

Identify the overall structure and tech stack of the target directory.

### 1-1. Directory Structure Exploration
- Use Glob to search for major file patterns: `**/*.{py,js,ts,jsx,tsx,java,go,rs,rb,php,cs,kt,swift}` etc.
- Identify the top-level directory structure
- Identify exclusion targets such as `.gitignore`, `node_modules/`, `venv/`, etc.

### 1-2. Tech Stack Detection
Read configuration files to identify the tech stack. See `domains/_core.md` § R3 (Tech Stack Detection) for the detection-target-to-file mapping.

### 1-2b. Framework Identification

From Phase 1-2 tech stack results, identify the primary framework(s):

1. Match detected tech against Foundation Detection Signals
   (See `domains/foundations/_foundation-core.md` § F0)
2. Record: `Framework: {name}` (comma-separated if multiple, e.g., `electron`, `express,nextjs`)
3. If no match: `Framework: custom` (no Foundation loaded)

This determination feeds into Phase 2-8 (Foundation Decision Extraction) and into `smart-sdd init` Step 3b for greenfield projects.

Also update `./case-study-log.md` (CWD root) header `**Framework**:` field with the detected framework name(s) (e.g., `electron`). If no match (`custom`), leave as `none`.

### 1-3. Project Type Classification
Classify the project type based on the collected information. Use the project types defined in `domains/_core.md` § R2 (Project Type Classification).

### 1-4. Module/Package Boundary Identification
- Identify logical module boundaries from the directory structure
- For monorepos, identify workspace/package boundaries
- Estimate the role of each module

### 1-5. Static Resource Inventory
Identify non-code resource files used by the project. In **rebuild mode**, these must be **copied as-is** to the new project. In **adoption mode** (`--adopt`), these already exist in-place and are documented for reference only.

| Resource Type | Search Patterns |
|---------------|-----------------|
| Images | `**/*.{png,jpg,jpeg,gif,svg,ico,webp,avif}` |
| Fonts | `**/*.{woff,woff2,ttf,otf,eot}` |
| Media | `**/*.{mp4,mp3,wav,ogg,webm}` |
| Documents | `**/*.{pdf,doc,docx}` (if used as app assets) |
| Localization | `**/*.{json,yaml,yml}` in `locales/`, `i18n/`, `translations/` directories |
| Configuration | Environment templates (`.env.example`), deployment configs used at runtime |
| Other static | Files in `public/`, `static/`, `assets/`, `resources/` directories |

For each discovered resource directory/group, record:
- **Directory path** and approximate file count
- **Usage context**: Where/how these resources are referenced in the code (e.g., imported in components, served statically, bundled by build tool)
- **Feature association**: Which Feature(s) use these resources

Exclude: `node_modules/`, build output (`dist/`, `build/`), generated files, test fixtures.

Upon completing Phase 1, report a summary of the detected tech stack, project structure, and static resource inventory to the user.

📝 **Case Study Recording**: Append milestone entry to `./case-study-log.md` (CWD root) per [recording-protocol.md](../../case-study/reference/recording-protocol.md) § M2.

### 1-6. Stack Strategy Details (Only if "New Stack" was selected in Phase 0)

This step determines the concrete new tech stack **immediately after detecting the current stack**, so the user has a clear direction before deep analysis begins. Skip entirely if "Same Stack" was selected.

**Step 1 — Current Stack Summary**:
Present the current stack detected in Phase 1 as a categorized table:

| Category | Current Technology | Version | Usage Context |
|----------|--------------------|---------|---------------|
| Language | e.g., Python | 3.10 | Backend |
| Framework | e.g., Django | 4.2 | Web framework |
| ORM/DB | e.g., PostgreSQL + Django ORM | 14 | Data layer |
| Frontend | e.g., React | 18 | SPA |
| Testing | e.g., pytest | 7.x | Unit/Integration |
| Build/Deploy | e.g., Docker + GitHub Actions | — | CI/CD |

Adapt the categories to match the actual project. Add or remove rows as needed (e.g., add "State Management", "Editor", "AI/ML SDK" if relevant; remove "Frontend" if the project is backend-only).

**Step 2 — Per-Category Stack Negotiation (HARD STOP per category)**:

You MUST iterate through **every single category** from Step 1's table, **one at a time**, and call AskUserQuestion for each. There is no exception to this rule.

**PROHIBITED**: Batching categories, pre-filling "Keep" for unconfirmed categories, skipping categories, or deciding on the user's behalf. The ONLY way to skip is when the user selects "Accept all remaining recommendations".

For each category (one at a time, in dependency order):
1. Show the current technology, 1~2 alternatives, AND "Keep Current" with rationale for each:
   ```
   📋 [Category]: [Current Technology] → ? (constrained by: [confirmed choices])

   | Option | Technology | Rationale |
   |--------|-----------|-----------|
   | Recommended | [Tech A] | [Why this fits, migration complexity] |
   | Alternative | [Tech B] | [Trade-offs vs recommended] |
   | Keep Current (Recommended) | [Current] | [Why keeping makes sense — mark as Recommended if current is optimal] |
   ```
   When the current technology IS the best choice, mark "Keep Current" as "(Recommended)" and still provide 1~2 alternatives so the user can see what other options exist.
2. Call AskUserQuestion with options:
   - "[Recommended option] (Recommended)" — could be a new tech OR "Keep [Current]" if current is best
   - "[Alternative Tech]"
   - "[Keep/Change option]" — whichever wasn't already listed as Recommended
   - "Accept all remaining recommendations" — skip subsequent categories and auto-apply recommended for each
3. **STOP and WAIT** for the user's response before moving to the next category. **If response is empty → re-ask.**
4. If the user selects "Other", accept their custom input and record it.
5. If the user selects "Accept all remaining recommendations", stop the per-category loop. Apply the recommended option for every remaining category and proceed directly to Step 3 (Final Summary and Confirmation), where the user can still review and revise if needed.

**Category dependency chain** — process in this order (each choice constrains subsequent options):

```
Language ──→ Framework ──→ ORM/DB ──→ Testing
                │                       │
                ├──→ State Mgmt         │
                ├──→ UI Library         │
                └──→ Build/Deploy ──────┘
```

Only propose technologies compatible with all previously confirmed choices. If "Keep Current" is incompatible with confirmed choices, mark it: "⚠️ Keep [Current] — **Incompatible** with [confirmed choice]."

**Step 3 — Final Summary and Confirmation**:
After all categories are decided, present the complete migration table:

| Category | Current | New | Migration Complexity |
|----------|---------|-----|---------------------|
| Language | Python 3.10 | TypeScript 5.x | Medium |
| Framework | Django 4.2 | Next.js 14 | High |
| ... | ... | ... | ... |

Ask via AskUserQuestion: "Confirm the final stack decisions?"
- "Confirm and proceed"
- "Revise some choices"

**If response is empty → re-ask.** If "Revise some choices", ask which categories to revisit and re-run Step 2 for those categories only.

**Step 4 — Finalize**:
Record the finalized stack decisions. These will be used in:
- Phase 4: `stack-migration.md` generation
- Phase 4: `constitution-seed.md` (New Stack Strategy section)
- Phase 4: Each Feature's `pre-context.md` (New Stack reference sections)

**Decision History Recording — Stack Choices**:
After Step 4 completes, **append** to `specs/history.md` under the current session's section:

```markdown
### Per-Category Stack Choices (New Stack)

| Category | Original | Chosen | Reason |
|----------|----------|--------|--------|
| [Category] | [current tech] | [chosen tech] | [user's reason or "—"] |
```

One row per category decided in Step 2. Record the user's reasoning for each choice if stated.

---

### 1-6. Data Storage Map (all app types)

> **🚨 MANDATORY**: READ [`~/.claude/skills/shared/runtime/data-storage-map.md`](../../shared/runtime/data-storage-map.md) for the full detection protocol, lock analysis, and platform-agnostic resolution. This section applies the shared protocol to the current project.

> **Purpose**: Identify WHERE the app stores persistent data (settings, user content, databases, caches).
> This map is consumed by Phase 1.5 for: userData path resolution, app-close requirements, setup guidance.
> Without this, Phase 1.5 cannot share user-configured data with the Playwright session.

**Detection method** — scan source code for storage patterns:

| Storage Type | Detection Signals | Example |
|-------------|------------------|---------|
| **Config store** | `electron-store`, `conf`, `configstore`, `dotenv`, `fs.writeFile('config')` | API keys, user preferences |
| **SQL database** | `better-sqlite3`, `prisma`, `drizzle`, `typeorm`, `sequelize`, `knex` | Structured data (entities, sessions) |
| **Document DB** | `dexie`, `indexedDB`, `pouchdb`, `lowdb`, `realm` | Messages, documents |
| **Key-value** | `localStorage`, `redux-persist`, `zustand/persist`, `electron-store` | App state, UI preferences |
| **File storage** | `app.getPath('userData')`, `getDataPath()`, `fs.mkdir`, `fs.writeFile` | Uploaded files, generated content, vector DBs |
| **External service** | `redis`, `mongodb`, `postgres` connection strings | Server-side data |

**Output**: Generate a Data Storage Map table (saved to Phase 1 results, consumed by Phase 1.5):

```
📦 Data Storage Map

| Storage | Type | Location | Lock? | Contains |
|---------|------|----------|-------|----------|
| electron-store | config | userData/config.json | No | API keys, settings |
| KnowledgeBase | file+sqlite | userData/Data/KnowledgeBase/ | SQLite WAL | Vector embeddings, uploaded files |
| Redux persist | key-value | userData/Local Storage/leveldb/ | ⚠️ LevelDB | App state (assistants, topics) |
| Dexie/IndexedDB | document | userData/IndexedDB/ | ⚠️ LevelDB | Messages, conversations |
| Memory DB | sqlite | userData/Data/Memory/memories.db | SQLite | Extracted memories |

userData path: ~/Library/Application Support/[app-name]/ (macOS)
               ~/.config/[app-name]/ (Linux)
               %APPDATA%/[app-name]/ (Windows)

App name detection: [from package.json "name" or "productName" field]

⚠️ Lock analysis:
  - LevelDB stores (localStorage, IndexedDB): single-process only → app must be CLOSED before Playwright
  - SQLite stores (WAL mode): concurrent reads OK, but writes lock → app should be closed
  - File stores (config.json, uploaded files): no lock → can coexist
```

**app-name resolution** (critical for userData path):
1. Read `package.json` → `productName` field (used by packaged app)
2. If no `productName` → `name` field (used by dev mode)
3. **Dev mode vs prod may differ**: dev uses `name`, prod uses `productName` — record BOTH
4. Verify by checking: `ls ~/Library/Application\ Support/[name]/` and `ls ~/Library/Application\ Support/[productName]/`

**Platform-agnostic detection**: For non-Electron apps:

| App Type | userData equivalent | Detection |
|----------|-------------------|-----------|
| **Web app** | Database (server-side) | Check DB connection config |
| **API server** | Database + .env | Check ORM config, migration files |
| **CLI tool** | Config file | Check `~/.config/[app]/`, `~/.local/share/[app]/` |
| **Tauri** | `tauri.conf.json` → `identifier` field | `~/Library/Application Support/[identifier]/` |
| **React Native** | AsyncStorage | Check `@react-native-async-storage` imports |

> This map feeds directly into Phase 1.5:
> - **1.5-2**: Auto-classify BLOCKING items (API keys stored in config store → must configure before explore)
> - **1.5-4**: App launch with correct userData path
> - **1.5-4b**: Setup guidance knows WHERE settings are stored
> - **1.5-5**: Playwright launch with `--user-data-dir` pointing to detected path

