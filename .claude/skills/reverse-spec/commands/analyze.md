# Reverse-Spec Workflow

Complete workflow for analyzing existing source code and generating the Global Evolution Layer.

---

## `--skip-to` Quick-Jump (DEV/TEST)

> **This section is only relevant when `--skip-to <phase>` is specified.** Otherwise, skip to Pre-Phase below.

When `--skip-to` is provided, bypass all preceding phases with minimal defaults to quickly reach and test a specific phase:

**`--skip-to 1.5`** (Runtime Exploration):
1. **Skip**: Pre-Phase, Phase 0, most of Phase 1
2. **Auto-resolve**: scope=`full`, stack=`same`, no rename, domain=`app`
3. **Minimal Phase 1**: Read only `package.json` (or equivalent) from the target directory to detect:
   - Tech stack (language, framework)
   - Dev server scripts (`dev`, `start`, `serve`, etc.)
   - Dependencies (for package manager detection)
   - `.env.example` existence
4. **Jump to**: Phase 1.5 Step 0 (Playwright Availability Check)

**`--skip-to 2`**: Auto-resolve Phase 0, execute full Phase 1, skip Phase 1.5, jump to Phase 2.
**`--skip-to 3`**: Auto-resolve Phase 0, execute Phase 1+2, skip Phase 1.5, jump to Phase 3.
**`--skip-to 4`**: Auto-resolve Phase 0, execute Phase 1+2+3, skip Phase 1.5, jump to Phase 4.

> ⚠️ `--skip-to` is for development/testing purposes only. Skipped phases produce no artifacts, so downstream phases may have missing context. Do NOT use in production runs.

---

## Pre-Phase — Git Repository Setup

Before starting analysis, ensure the CWD (output directory) has a git repository. This enables branch-based workflow management throughout the SDD pipeline.

**Step 1 — Check existing git repo**:
Run `git rev-parse --is-inside-work-tree` in CWD.

- **If git repo already exists**: Skip to Step 3 (branch option).
- **If no git repo**: Proceed to Step 2.

**Step 2 — Initialize git repo**:
1. Run `git init` in CWD
2. Create a `.gitignore` with sensible defaults for the detected tech stack:
   - Always include: `node_modules/`, `.env`, `.env.*`, `__pycache__/`, `*.pyc`, `.DS_Store`, `dist/`, `build/`, `.venv/`, `venv/`
   - Add stack-specific entries based on the target project's tech stack (detected from config files in the target directory):
     - Node.js: `node_modules/`, `coverage/`, `.next/`, `.nuxt/`
     - Python: `__pycache__/`, `*.egg-info/`, `.venv/`
     - Go: vendor/ (if not using modules)
     - Java: `target/`, `*.class`, `.gradle/`
     - Rust: `target/`
   - If tech stack is not yet known (target not analyzed), use the universal defaults only
3. Display: "✅ Git repository initialized with .gitignore"

**Step 3 — Branch option (HARD STOP)**:
Ask the user via AskUserQuestion whether to work on the current branch or create a dedicated branch:
- "Stay on current branch (Recommended)" — Continue on the current branch (usually `main`)
- "Create a new branch" — Create and checkout a new branch for the SDD work

**If response is empty → re-ask.** If the user selects "Create a new branch", ask for the branch name via "Other" input (suggest `sdd-setup` as default).
**Step 4 — Auto-initialize case study logging**:
Check if `case-study-log.md` exists at the target directory root:
- **If not exists**: Read [`case-study-log-template.md`](../../case-study/templates/case-study-log-template.md) and write it to `{target-directory}/case-study-log.md`. Display: `📝 Case study log initialized: case-study-log.md`
- **If already exists**: Skip silently (user may have manually initialized earlier)

📝 **Case Study Recording**: Append milestone entry to `case-study-log.md` per [recording-protocol.md](../../case-study/reference/recording-protocol.md) § M1.

---

## Phase 0 — Strategy Questions

Determine the direction of the deliverables. Each question can be answered via CLI arguments OR interactive prompt.

> **`--adopt` mode**: When `--adopt` is specified, this is SDD Adoption — documenting existing code in-place. Scope is forced to `full`, Stack is forced to `same`, and Question 3 (renaming) is skipped entirely. All three questions are auto-resolved.

### Question 1: Implementation Scope
- **If `--adopt` is specified**: Force `full`. Skip this question — adoption documents the entire codebase.
- If `--scope` argument is provided: use the specified value (`core` or `full`).
- Otherwise: Ask the user via AskUserQuestion:
  - **Core Only (Core)**: Redevelop only the core features that form the foundation of the project. For learning/prototyping purposes
  - **Full Implementation (Full)**: Redevelop the full set of features identical to the existing system

**If response is empty → re-ask.** Do NOT proceed without an explicit selection.

### Question 2: Tech Stack Strategy
- **If `--adopt` is specified**: Force `same`. Skip this question — adoption keeps existing code as-is.
- If `--stack` argument is provided: use the specified value (`same` or `new`).
- Otherwise: Ask the user via AskUserQuestion:
  - **Same Stack (Same)**: Use the same language, framework, and libraries as the existing project
  - **New Stack (New)**: Migrate to an optimal modern tech stack

**If response is empty → re-ask.** Do NOT proceed without an explicit selection.

Record both responses and reference them throughout all subsequent Phases.

### Question 3: Project Identity (rebuild only)

> **Skip entirely** when `--adopt` is specified. Adoption documents the existing project as-is — no renaming.

When analyzing existing source code for rebuild, the original project's naming (class names, service names, branding) will appear throughout the codebase. If the new project has a different identity, this must be captured early so artifacts use the correct naming.

Ask via AskUserQuestion:
- "Is the new project name different from the original?"
  - **Yes — new name**: User provides the new project name (e.g., "Cherry Studio" → "Angdu Studio")
  - **No — same name**: Keep the original project name as-is

**If response is empty → re-ask.** Do NOT proceed without an explicit selection.

If the user selects "Yes":
1. Record the **original project name** and **new project name**
2. Ask the user to provide **naming prefix mappings** if applicable (e.g., `Cherry` → `Angdu`, `CS` → `AS`). These are optional — the user can skip if they want to decide later.
3. Store these mappings for use in:
   - **Phase 4 artifacts**: Replace original project name references with the new name in `roadmap.md`, `constitution-seed.md`, and `pre-context.md` descriptions
   - **Phase 4-3 coverage baseline**: When classifying unmapped items, highlight items containing the original project name prefix (e.g., "CherryINOAuth") and suggest renamed versions (e.g., "AngduINOAuth" or "INOAuth")
   - **constitution-seed.md**: Include a "Naming Conventions" section documenting the old → new mapping

> **Note**: This question can be skipped via `--name <new-name>` argument.

### Decision History Recording — Strategy

After all Phase 0 questions are answered, **append** to `specs/history.md` (create if it doesn't exist with this header):

```markdown
# Decision History

> Auto-generated during `/reverse-spec` and `/smart-sdd` execution.
> Records key strategic and architectural decisions with rationale.
```

**Rebuild mode**: If this is a rebuild project (not adoption), add a Project Context block immediately after the header:

```markdown
## Project Context

| | Details |
|---|---------|
| **Mode** | Rebuild |
| **Original** | [original-project-name] (`[absolute-path-to-source]`) |
| **Target** | [new-project-name] (`[absolute-path-to-target]`) |
| **Stack** | [Same Stack / New Stack: old-stack → new-stack] |
| **Identity** | [original-name] → [new-name] (or "Same") |
| **What it does** | [1-2 sentence description of what the system does from a user's perspective — e.g., "AI-powered desktop chat application supporting multiple LLM providers with conversation management, knowledge base, and plugin system"] |
```

This block is written ONCE at creation time and never modified. It serves as a permanent record of what is being rebuilt from what.

**Adoption mode**: If this is an adoption project:

```markdown
## Project Context

| | Details |
|---|---------|
| **Mode** | Adoption |
| **Project** | [project-name] (`[absolute-path]`) |
| **Purpose** | Wrapping existing code with SDD documentation |
| **What it does** | [1-2 sentence description of what the system does from a user's perspective] |
```

Add a dated section after the Project Context:

```markdown
---

## [YYYY-MM-DD] /reverse-spec — Project Setup

### Strategy Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Scope | core / full | [user's reason if stated, otherwise "—"] |
| Stack | same / new | [user's reason if stated, otherwise "—"] |
| Project Identity | [original] → [new] / Same | [user's reason if stated, otherwise "—"] |
```

**Rules**: APPEND only — never overwrite existing entries. One row per decision. Record the user's reasoning if stated; write "—" if not.

---

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

📝 **Case Study Recording**: Append milestone entry to `case-study-log.md` per [recording-protocol.md](../../case-study/reference/recording-protocol.md) § M2.

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

## Phase 1.5 — Runtime Exploration (Optional)

> **Purpose**: Run the original application and explore it interactively before deep code analysis. This provides visual and behavioral context (UI layout, user flows, actual states) that code reading alone cannot capture. The observations enrich Phase 2 analysis and Phase 4 deliverables.
>
> **When to skip**: This phase is relevant only for **rebuild mode**. Skip entirely when `--adopt` is specified (adoption documents existing code in-place — no need to explore the app you're already running).

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

Present the assessment results in three tiers:

```
📋 Environment Readiness for Runtime Exploration

── ✅ Auto-resolvable (agent handles) ────────────────────
  □ [package manager] install ([dependency dir] not found)
  □ .env creation (from .env.example — set config variable defaults)

── ⚠️ Requires Your Action ─────────────────────────────
  □ [VAR_NAME] — [description] ([category: secret])
    💡 [hint: e.g., "postgres service defined in docker-compose.yml
       → start with docker compose up -d postgres"]
  □ [VAR_NAME] — [description] ([category: secret])

── ℹ️ Optional (basic exploration possible without) ─────
  □ [VAR_NAME] — [description] (not needed for exploration)
──────────────────────────────────────────────────────────

Dev Server: `[start command]` (port [N])
```

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

| Build Tool | CDP-Enabled Start Command |
|-----------|--------------------------|
| **electron-vite** | `npx electron-vite dev -- --remote-debugging-port=9222` |
| **electron-forge** | `ELECTRON_ARGS='--remote-debugging-port=9222' npm run start` |
| **electron-builder** | `ELECTRON_ARGS='--remote-debugging-port=9222' npm run dev` |
| **Direct electron** | `npx electron . --remote-debugging-port=9222` |
| **Other / Unknown** | Append ` -- --remote-debugging-port=9222` after the dev command |

⚠️ **electron-vite requires the `--` separator** before `--remote-debugging-port`. It does NOT pick up the `ELECTRON_ARGS` environment variable. This is the most common cause of CDP connection failure with electron-vite projects.

After launching, verify CDP is active: `lsof -i :9222`. If no result → the CDP flag was not picked up. Check the build tool and retry with the correct syntax.

**Step 2 — Run and wait for readiness**:
Run the start command (or CDP-modified command for Electron) as a background process, capturing stdout/stderr.
- Monitor stdout for readiness signals: `ready`, `listening on`, `started`, `compiled`, `Local:`, `http://localhost`
- Alternatively, poll the expected port with `lsof -i :[PORT]`
  - For Electron CDP: poll both the app port and port 9222
- Timeout: 60 seconds

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

### 1.5-4b. App Initial Setup (HARD STOP)

Many apps require **in-app configuration** before core features become usable — API keys entered through a settings UI, provider selection, onboarding wizards, initial account setup, etc. These are distinct from environment variables (`.env`) and cannot be automated by the agent (they often involve secrets entered through the app's own UI).

**Step 1 — Detect initial setup needs**:
Analyze the source code to identify likely first-run configuration requirements:
- Settings/preferences pages that configure external services (API providers, OAuth, SMTP, etc.)
- Onboarding flows or setup wizards (first-run detection in code)
- In-app credential storage (e.g., `localStorage`, IndexedDB, Electron Store, SQLite)
- Provider/model selection UI (common in AI apps)

**Step 2 — Present setup guidance**:

```
🔧 App Initial Setup

The app is running, but some in-app configuration may be needed to explore core features.

Setup items detected from code analysis:
  • [Item 1: e.g., Settings → Enter API Key in AI Provider]
  • [Item 2: e.g., Settings → Select Model]
  • [Item 3: e.g., Complete onboarding on first run]

Please complete the setup in the app, then select "Ready".
UI structure exploration is possible even without setup.
```

**HARD STOP** — Use AskUserQuestion:
- "Setup complete — proceed with full exploration" (Recommended)
- "Explore UI structure only (without setup)"
- "Skip Runtime Exploration"

**If response is empty → re-ask** (per MANDATORY RULE 1).

> **Note**: If no initial setup needs are detected from the code, skip this step and proceed directly to 1.5-5.

### 1.5-5. Runtime Exploration (Automated via Playwright)

With the app running, systematically explore using the available Playwright method. The exploration method is selected based on the detection results from Step 1.5-0:

---

#### When Playwright CLI is primary (`playwright_cli = true`):

Execute exploration via Playwright library mode (Node.js script):

**Phase A — Initial Landing**:
1. CLI library mode: `chromium.launch({ headless: false })` → `page.goto('http://localhost:[PORT]')` → `page.accessibility.snapshot()`
   - For Electron apps: use `_electron.launch({ executablePath: '[electron-binary-path]' })` instead of `chromium.launch()`
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

**Phase D — Key Flow Identification** (observation only):
Based on screens discovered, identify apparent user flows:
- Authentication flow (if login form exists)
- CRUD patterns (list → detail → edit)
- Wizard/multi-step flows
- Settings/configuration pages
- Record flows as route sequences, **without performing data entry or state-changing actions**

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

**Phase D — Key Flow Identification** (observation only):
Based on screens discovered, identify apparent user flows:
- Authentication flow (if login form exists)
- CRUD patterns (list → detail → edit)
- Wizard/multi-step flows
- Settings/configuration pages
- Record flows as route sequences, **without performing data entry or state-changing actions**

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

**Step 1 — Write `specs/reverse-spec/runtime-exploration.md`**:
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
   - CLI library mode: `page.goto(route)` → `page.waitForTimeout(3000)` → `page.screenshot({ path: 'specs/reverse-spec/visual-references/{screen-name}.png', fullPage: true })`
   - For Electron apps: use `_electron.launch()` → `firstWindow()` to obtain the page object
2. Generate `specs/reverse-spec/visual-references/manifest.md` (same format as below)
3. Display: `📸 Visual references captured: [N] screens → specs/reverse-spec/visual-references/`

When Playwright MCP is the only option (`playwright_mcp = true`, `playwright_cli = false`):
1. For each screen explored in Step 3 (from the navigation log):
   - Navigate to the screen URL/route
   - Wait for content to stabilize (~3 seconds)
   - Take a screenshot via MCP → save to `specs/reverse-spec/visual-references/{screen-name}.png`
2. Generate `specs/reverse-spec/visual-references/manifest.md`:
   ```markdown
   # Visual Reference Manifest

   | Screen | Route/URL | Screenshot | Key UI Elements |
   |--------|-----------|------------|-----------------|
   | [name] | [route]   | {screen-name}.png | [notable elements: sidebar, nav, form, list...] |
   ```
3. Display: `📸 Visual references captured: [N] screens → specs/reverse-spec/visual-references/`

**When Playwright unavailable or app cannot be launched**:
- Display: `⚠️ Visual reference capture skipped (Playwright/app not available). You can provide screenshots manually at: specs/reverse-spec/visual-references/`
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
3. Save to `specs/reverse-spec/visual-references/style-tokens.md`:
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
4. Display: `🎨 Style tokens extracted → specs/reverse-spec/visual-references/style-tokens.md`
5. If extraction fails (cross-origin restrictions, SPA not rendered, or app is server-rendered without client JS):
   - Display: `⚠️ Style token extraction skipped — [reason]. You can add tokens manually.`
   - Create an empty `style-tokens.md` with the template header only

**Step 5 — Proceed to Phase 2**:
Runtime exploration results are saved in `specs/reverse-spec/runtime-exploration.md`. Visual references (if captured) are saved in `specs/reverse-spec/visual-references/`. Style tokens (if extracted) are saved in `specs/reverse-spec/visual-references/style-tokens.md`. Phase 2 will read these to cross-reference code analysis with runtime observations.

📝 **Case Study Recording**: Append milestone entry to `case-study-log.md` per [recording-protocol.md](../../case-study/reference/recording-protocol.md):
```
### M1.5 — Runtime Exploration
- **Timestamp**: [ISO timestamp]
- **Mode**: [automated (Playwright) | skipped]
- **Screens explored**: [N]
- **Visual references captured**: [N screenshots | skipped]
- **Key findings**: [1-2 sentence summary]
```

---

## Phase 2 — Deep Analysis

> **Domain Profile**: Read `domains/_core.md` § R3 + active interface modules § R3 for the domain-specific extraction targets used throughout this Phase.

Perform deep analysis using patterns appropriate to the tech stack identified in Phase 1. For large codebases, leverage parallel sub-agents via the Task tool.

> **Phase 1.5 Cross-Reference**: If `specs/reverse-spec/runtime-exploration.md` exists, read the file and use the observations to enrich analysis:
> - Validate route definitions against actually observed screens (Screen Inventory)
> - Enrich entity extraction with observed data display patterns — tables, forms, card views (UI Patterns)
> - Cross-reference API endpoints with observed user interactions (User Flows Observed)
> - Note discrepancies between code structure and runtime behavior — e.g., routes defined in code but not reachable in UI (Screen Inventory vs code routes)

### 2-1. Data Model Extraction
Extract entities from appropriate sources depending on the tech stack identified in Phase 1. See `domains/_core.md` § R3 (Data Model Extraction) for the technology-to-search-target mapping and extraction details.

### 2-2. API Endpoint Extraction
Extract APIs from appropriate sources depending on the tech stack identified in Phase 1. See `domains/interfaces/http-api.md` § R3 (API Endpoint Extraction) for the technology-to-search-target mapping and extraction details. Note: only applies when http-api interface is active.

### 2-3. Business Logic Extraction
Extract business rules, validation, workflows, and external integrations from the service layer and domain logic. See `domains/_core.md` § R3 (Business Logic Extraction) for extraction categories.

### 2-4. Inter-Module Dependency Mapping
Analyze import/require statements, service call relationships, shared utilities, and event-based coupling. See `domains/_core.md` § R3 (Inter-Module Dependency Mapping) for details.

### 2-5. Environment Variable Extraction
Scan the codebase for environment variable usage to identify runtime configuration requirements. See `domains/_core.md` § R3 (Environment Variable Extraction) for the technology-to-search-pattern mapping and per-variable extraction details.

⚠️ NEVER read or record actual secret values from `.env` files. Only read `.env.example` or detect variable names from code patterns.

### 2-6. Source Behavior Inventory

For each source file identified in Phase 1, extract a **function-level inventory** of exported/public behaviors (P1 core / P2 important / P3 nice-to-have). This captures discrete units of functionality that structural extraction (entities, APIs) may miss. See `domains/_core.md` § R3 (Source Behavior Inventory) for extraction targets, priority classification, and scan patterns.

- Group by Feature association (determined in Phase 3 when Feature boundaries are identified)
- Skip internal/private helpers that are implementation details, not behaviors

This inventory feeds into each Feature's `pre-context.md` → "Source Behavior Inventory" section (Phase 4-2) and is used by `/smart-sdd verify` for Feature-level completeness checking.

> **SBI Generation Timing**: Phase 2-6 generates the project-wide global SBI. At this point, Feature classification has not yet been performed (done in Phase 3), so no per-Feature filtering is applied. Per-Feature filtering and B### ID assignment are performed in Phase 4-2.

### 2-7. UI Component Feature Extraction (Frontend/Fullstack Projects Only)

> Skip this step entirely for backend-only, library, or CLI projects.

Third-party UI libraries provide user-facing capabilities through **configuration and plugins**, not through exported functions — invisible to function-level analysis but significant functionality that must be reproduced. See `domains/interfaces/gui.md` § R3 (UI Component Feature Extraction) for the 3-step process (identify → extract → record) and library category mapping. Note: only applies when gui interface is active.

This inventory feeds into each Feature's `pre-context.md` → "UI Component Features" section (Phase 4-2) and is compared during `/smart-sdd parity` → UI Feature Parity.

### 2-7b. UI Micro-Interaction Pattern Extraction (Frontend/Fullstack Projects Only)

> Skip this step entirely for backend-only, library, or CLI projects.
> This step captures interaction-level behaviors (tooltips, hover states, keyboard shortcuts, animations, drag-and-drop, focus management, context menus) that are invisible to both function-level analysis (Phase 2-6) and library-level analysis (Phase 2-7). These behaviors are often implemented via CSS pseudo-classes, event listeners, or small utility components.

See `domains/interfaces/gui.md` § R4 (Micro-Interaction Pattern Extraction) for detection heuristics and extraction rules.

**Two-pronged approach**: Source code analysis (always) + Optional runtime probing (when Playwright is available).

#### A. Source Code Analysis (always executed)

Scan the project's source files for micro-interaction patterns in 7 categories:

**1. Hover Behaviors**:
- CSS: grep for `:hover` pseudo-class rules → record which elements have hover styles and what changes (color, background, opacity, transform, box-shadow)
- React/Vue: grep for `onMouseEnter`, `onMouseLeave`, `onMouseOver`, `@mouseenter`, `@mouseleave` → record handler target and behavior
- Tooltip components: grep for tooltip-related patterns:
  - Library usage: `<Tooltip`, `<Tippy`, `data-tooltip`, `data-tip`, `v-tooltip`
  - HTML native: `title=` attribute on interactive elements
  - Custom: components named `*Tooltip*`, `*Popover*`, `*HoverCard*`
- Record: `{ element, trigger, behavior, content (for tooltips), delay (if specified) }`

**2. Keyboard Shortcuts**:
- Event listeners: grep for `addEventListener('keydown')`, `addEventListener('keyup')`, `addEventListener('keypress')`
- React/Vue: grep for `onKeyDown`, `onKeyUp`, `@keydown`, `@keyup`
- Library usage: grep for keyboard shortcut libraries (hotkeys-js, mousetrap, react-hotkeys-hook, tinykeys, @mantine/hooks useHotkeys)
- Global shortcuts: grep for `Mod+`, `Ctrl+`, `Meta+`, `Alt+`, `Shift+` key combinations in string literals
- Record: `{ shortcut, scope (global/component), action, modifier keys }`

**3. Animations & Transitions**:
- CSS transitions: grep for `transition:` and `transition-*:` properties → record which properties animate, duration, easing
- CSS animations: grep for `animation:`, `animation-name:`, `@keyframes` → record animation names, duration, iteration
- JS animations: grep for `requestAnimationFrame`, `.animate()`, animation libraries (framer-motion, react-spring, GSAP, anime.js, motion)
- Tailwind: grep for `animate-`, `transition-`, `duration-`, `ease-` utility classes
- Record: `{ element/selector, type (transition/animation/JS), properties, duration, trigger }`

**4. Focus Management**:
- Focus styles: grep for `:focus`, `:focus-visible`, `:focus-within` CSS rules
- Focus control: grep for `.focus()`, `autoFocus`, `tabIndex`, `tabindex`
- Focus trapping: grep for focus trap libraries (focus-trap-react, @headlessui, react-focus-lock) or custom `keydown` handlers checking `Tab` key
- Skip links: grep for "skip to content", "skip navigation" patterns
- Record: `{ element, focus-style, focus-control (auto/programmatic/trapped), tab-order }`

**5. Drag-and-Drop**:
- Library detection: grep for drag-and-drop libraries (dnd-kit, react-beautiful-dnd, react-dnd, SortableJS, @hello-pangea/dnd, vuedraggable)
- Native HTML5: grep for `draggable=`, `onDragStart`, `onDragOver`, `onDrop`, `ondragstart`, `ondragover`, `ondrop`
- Custom: grep for `mousedown`+`mousemove`+`mouseup` handler patterns on the same element
- Record: `{ source-element, drop-targets, behavior (reorder/transfer/sort), feedback (placeholder/preview/ghost) }`

**6. Context Menus & Right-click**:
- grep for `onContextMenu`, `addEventListener('contextmenu')`, `@contextmenu`
- grep for context menu components or libraries (react-contexify, @radix-ui/context-menu)
- Record: `{ trigger-element, menu-items, behavior }`

**7. Scroll Behaviors**:
- Scroll events: grep for `onScroll`, `addEventListener('scroll')`, `@scroll`
- Scroll control: grep for `scrollIntoView`, `scrollTo`, `scrollTop`, `scroll-behavior: smooth`
- Infinite scroll: grep for `IntersectionObserver`, infinite scroll libraries
- Sticky elements: grep for `position: sticky`, `position: fixed` with scroll-dependent logic
- Scroll snap: grep for `scroll-snap-type`, `scroll-snap-align`
- Record: `{ element, behavior (infinite-scroll/scroll-snap/sticky/smooth-scroll), trigger }`

#### B. Runtime Probing (optional, when Playwright available)

> **When**: `playwright_cli = true` OR `playwright_mcp = true`, AND app was explored in Phase 1.5.
> **Skip if**: No Playwright available, or Phase 1.5 runtime exploration was skipped.
> **Budget**: Max 3 minutes, max 10 elements per category.

After source code extraction, selectively probe runtime to confirm key findings:

1. **Tooltip verification** (from source analysis results):
   - Hover over elements identified as having tooltips → wait 1s → snapshot → check for new tooltip element
   - Record: actual tooltip text content, position, delay

2. **Keyboard shortcut testing** (from source analysis results):
   - For each identified shortcut: press key combination → observe result
   - Record: confirmed working / not triggered / unexpected behavior

3. **Animation observation**:
   - Navigate between screens → observe if transitions occur
   - Interact with elements that have CSS transitions → observe visual changes
   - Record: confirmed animations, approximate timing

> **Note**: Runtime probing ENRICHES source analysis — it does not replace it. Source code analysis captures the full inventory; runtime probing adds confirmation and actual behavior details (tooltip text, animation timing, etc.).

#### C. Output

Write findings to `specs/reverse-spec/micro-interactions.md`.

**ID Format**: Use category-prefixed sequential IDs — `H001`/`H002` for Hover, `K001` for Keyboard, `A001` for Animation, `F001` for Focus, `D001` for Drag-and-Drop, `C001` for Context Menu, `S001` for Scroll. These IDs carry into per-Feature `pre-context.md` Interaction Behavior Inventory tables.

```markdown
# Micro-Interaction Inventory

> Generated by `/reverse-spec` Phase 2-7b — [ISO timestamp]
> Source analysis: [N] patterns detected across [M] files
> Runtime probing: [confirmed/skipped]

## Hover Behaviors
| ID | Element/Component | Trigger | Behavior | Content | Source File |
|----|-------------------|---------|----------|---------|-------------|

## Keyboard Shortcuts
| ID | Shortcut | Scope | Action | Source File |
|----|----------|-------|--------|-------------|

## Animations & Transitions
| ID | Element/Selector | Type | Properties | Duration | Trigger | Source File |
|----|------------------|------|------------|----------|---------|-------------|

## Focus Management
| ID | Element | Focus Style | Control | Tab Order | Source File |
|----|---------|-------------|---------|-----------|-------------|

## Drag-and-Drop
| ID | Source Element | Drop Targets | Behavior | Feedback | Source File |
|----|---------------|--------------|----------|----------|-------------|

## Context Menus
| ID | Trigger Element | Menu Items | Source File |
|----|-----------------|------------|-------------|

## Scroll Behaviors
| ID | Element | Behavior | Trigger | Source File |
|----|---------|----------|---------|-------------|
```

This inventory feeds into each Feature's `pre-context.md` → "Interaction Behavior Inventory" section (Phase 4-2) and is used by `/smart-sdd verify` for micro-interaction completeness checking.

### 2-8. Foundation Decision Extraction

For each identified framework (from Phase 1-2b):

1. Load `domains/foundations/{framework}.md`
   - If Foundation file exists (Case A): Load full F2 items
   - If no Foundation file but framework known (Case B): Load universal categories from `domains/foundations/_foundation-core.md` § F1
   - If framework is `custom` (Case D): Skip this step entirely

2. For each Foundation item marked **Critical** or **Important**:
   - Apply F3 Extraction Rules to determine current decision in code
   - Record: `decided` / `not-configured` / `ambiguous`

3. Output: Foundation Decision Table per framework

| ID | Item | Detected Value | Confidence | Source File |
|----|------|---------------|------------|-------------|

4. Flag `ambiguous` items for user clarification during `smart-sdd init` Step 3b or `smart-sdd pipeline` pre-phase review

**Foundation Migration** (rebuild with framework change only):
If `change_scope = "framework"` or `"stack"`, apply the Migration Protocol from `domains/foundations/_foundation-core.md` § F5:
- Load OLD framework Foundation from extracted code decisions
- Load NEW framework Foundation from target framework file
- Classify each item: carry-over / equivalent / irrelevant / new
- Output: Foundation Migration Table (see § F5 for format)

Upon completing Phase 2, report a summary of the number of entities, APIs, business rules, environment variables, source behaviors, UI component features, and Foundation decisions discovered.

---

## Phase 3 — Feature Classification and Importance Analysis

### 3-1. Feature Boundary Identification
Identify logical functional units (Features) based on the Phase 2 analysis results, using the boundary heuristics defined in `domains/_core.md` § R5 (Feature Boundary Heuristics).

Define the following for each Feature:
- Feature name (concise English name)
- Description (1-2 sentences)
- List of associated files
- Owned entities
- Provided APIs

**Naming Remapping scan** (only if Phase 0 Question 3 established a new project name):
For each Feature's associated files, scan for code-level identifiers (function names, class names, variable names, constants, package names) that contain the original project name or its prefix mappings. Record each occurrence with:
- Original identifier (e.g., `createCherryIn`, `CherryProvider`)
- File and line number
- Suggested new identifier (apply the prefix mapping, e.g., `Cherry` → `Angdu`)
- Type (function, class, variable, constant, env var, package, etc.)

This per-Feature catalog will be populated into each Feature's `pre-context.md` → "Naming Remapping" section during Phase 4-2.

> Do not assign Feature IDs at this point. IDs will be assigned based on topological sort after constructing the dependency graph in 3-2.

### 3-1b. Feature Granularity Selection (HARD STOP)

After identifying Feature boundaries, present **multiple granularity options** to the user. The same codebase can be decomposed at different levels of granularity, and the right choice depends on project goals, team size, and desired iteration speed.

**Step 1 — Prepare granularity proposals**:
Analyze the identified Features and propose 2-3 granularity levels:

| Level | Name | Description | Typical Feature Count |
|-------|------|-------------|----------------------|
| **Coarse** | Domain-level | One Feature per major business domain. Larger scope per Feature, fewer total Features. Good for small teams or quick prototyping | 4-8 Features |
| **Standard** | Module-level | One Feature per logical module/service boundary. Balanced scope and count. Recommended for most projects | 8-15 Features |
| **Fine** | Capability-level | One Feature per distinct user-facing capability. Smaller scope per Feature, more total Features. Good for large teams or when granular tracking is needed | 15-30 Features |

**Step 2 — Present the proposals**:
For each granularity level, show a concrete Feature list derived from the analysis:

```
📋 Feature Granularity Options:

── Option A: Coarse (Domain-level) ──────────────
[N] Features total
  • auth — User authentication + authorization + roles
  • catalog — Products + categories + search
  • commerce — Cart + orders + payment + shipping
  • admin — Admin panel + analytics + reports
Pros: Faster pipeline, fewer cross-Feature dependencies
Cons: Larger Features (harder to review/test in isolation)

── Option B: Standard (Module-level) — Recommended ──
[N] Features total
  • auth — User registration, login, sessions
  • user-profile — User profiles, preferences
  • product — Product CRUD, categories
  • search — Product search, filtering
  • cart — Shopping cart management
  • order — Order placement, status tracking
  • payment — Payment processing
  • admin — Admin dashboard, reports
Pros: Balanced scope, manageable review cycles
Cons: Moderate number of Features to track

── Option C: Fine (Capability-level) ────────────
[N] Features total
  • user-register — User registration
  • user-login — Login + session management
  • user-roles — Role-based access control
  • product-crud — Product create/read/update/delete
  • product-category — Category management
  • product-search — Search + filtering
  • ...
Pros: Granular tracking, easier isolated testing
Cons: Many Features, more cross-Feature dependencies
```

**Step 3 — User selection**:
Use AskUserQuestion to ask the user:
- "Option B: Standard (Module-level) (Recommended)"
- "Option A: Coarse (Domain-level)"
- "Option C: Fine (Capability-level)"

**You MUST STOP and WAIT for the user's response. Do NOT proceed until the user selects a granularity level. If response is empty → re-ask.**

If the user selects "Other", they can describe a custom granularity or request specific merges/splits of the proposed Features.

**Step 4 — Apply the selected granularity**:
Reconstruct the Feature list according to the selected level. If Coarse is selected, merge related Features. If Fine is selected, split Features into smaller units. Then proceed to 3-1c with the finalized Feature list.

### 3-1c. Demo Group Definition (HARD STOP)

After the Feature list is finalized (3-1b Step 4), define Demo Groups — end-to-end user scenarios that span multiple Features and serve as integration verification milestones.

**Step 1 — Analyze and propose Demo Groups**:
Based on the finalized Feature list, propose 2–4 Demo Groups by analyzing:
- Feature dependency chains (Features that form a complete user flow)
- Business scenario boundaries (distinct user journeys)
- SBI entries from Phase 2 that span multiple Features

For each proposed group:
```
── DG-01: [Scenario Name] ──────────────────
Scenario: [End-to-end user journey description]
Features: F001-xxx, F002-yyy, F003-zzz
Related SBI: [Summary of behaviors this scenario covers]
```

**Step 2 — Display and approve**:
**FIRST**, display ALL proposed Demo Groups using the format above (DG-01, DG-02, ...) so the user can see the full details.
**THEN**, ask via AskUserQuestion:
- "Accept proposed Demo Groups"
- "Modify grouping" (user can reassign Features between groups)
- "Add more groups"
- "Skip Demo Groups" (not recommended — disables Integration Demo triggers)

**You MUST STOP and WAIT for the user's response. Do NOT proceed until the user approves Demo Groups. If response is empty → re-ask.**

**Step 3 — Record decision**:
After approval, **append** to `specs/history.md` under the current session's Architecture Decisions table:

| Decision | Choice | Details |
|----------|--------|---------|
| Demo Groups | [N] groups defined | [Group names: DG-01 Scenario, DG-02 Scenario, ...] |

The Demo Groups will be written to `roadmap.md` in Phase 4-1 and tracked in `sdd-state.md` → Demo Group Progress section.

> **Note**: Infrastructure or cross-cutting Features (e.g., shared utilities, configuration) may not belong to any Demo Group. This is acceptable — they support other Features but don't represent user-facing scenarios.

Then proceed to 3-1d.

### 3-1d. Cross-Feature Interaction Intensity Check

After Feature boundaries are finalized and Demo Groups defined, validate that boundaries correctly separate high-cohesion code and correctly identify cross-Feature interactions. This catches misdrawn boundaries where two "Features" are so tightly coupled they should be merged, or where interactions are unexpectedly complex.

**Step 1 — Build Interaction Intensity Matrix**:

Using Phase 2 inter-module dependency data (2-4), count interactions for each Feature pair:

| Interaction Type | Weight | Detection Method |
|-----------------|--------|-----------------|
| Direct import (A imports B's module) | 1 | Phase 2-4 import graph |
| Shared entity (A writes, B reads same entity) | 2 | Phase 2-1 entity ownership |
| API call (A calls B's endpoint) | 2 | Phase 2-2 API cross-references |
| Event coupling (A publishes, B subscribes) | 1 | Phase 2-4 event patterns |
| Shared business rule (rule spans both Features) | 3 | Phase 2-3 cross-Feature rules |

Calculate **Interaction Score** for each Feature pair: sum of (count × weight) for all interaction types.

**Step 2 — Anomaly Detection**:

| Anomaly | Threshold | Action |
|---------|-----------|--------|
| Over-coupled pair | Score ≥ 10 | Flag: "Consider merging [A] and [B] — interaction score [N] suggests tight coupling" |
| Orphan Feature | Score = 0 with all Features | Flag: "Feature [X] has no interactions — verify it's correctly bounded" |
| Hub Feature | Score ≥ 5 with 3+ Features | Flag: "Feature [Y] is a hub — verify its scope isn't too broad" |

**Step 3 — Display and optional adjustment**:

```
📊 Cross-Feature Interaction Intensity:

Top interactions:
  F001-auth ↔ F003-chat: Score 8 (3 shared entities, 2 API calls, 1 shared rule)
  F002-settings ↔ F005-ai: Score 12 ⚠️ OVER-COUPLED
    → Consider merging, or define explicit Feature Contracts in pre-context

Anomalies:
  ⚠️ F002-settings ↔ F005-ai: Over-coupled (score 12)
  ℹ️ F009-export: Low interaction (score 1 total) — verify boundary
```

If anomalies found, display them but do NOT auto-merge or auto-split. Proceed to 3-2. The user can revisit boundaries after seeing the full dependency graph.

> **Note**: This check is informational, not blocking. It enriches the dependency graph (3-2) with interaction intensity data and helps the user validate boundary decisions. The interaction data also feeds into Phase 4-2 when populating Feature Contract sections in each pre-context.md.

Then proceed to 3-2.

### 3-2. Dependency Graph Construction and Release Group Determination
Derive inter-Feature dependencies:
- **Direct Dependency**: Uses another Feature's modules via import/require
- **API Dependency**: Calls APIs provided by another Feature
- **Entity Dependency**: References entities owned by another Feature
- **Event Dependency**: Subscribes to events published by another Feature
- **Platform Constraint**: Runtime environment setup by one Feature that downstream Features must respect (window config, CSS requirements, security policies, IPC channels)

**Platform constraint detection** (Electron/Tauri/Desktop apps):
- Scan BrowserWindow/Window options: `frame`, `transparent`, `titleBarStyle`, `titleBarOverlay`, `webPreferences`
- Scan security headers: CSP, CORS policies in main process
- Scan IPC channel registrations used by downstream Features
- Record as `Platform constraint` dependency type in Dependency Graph
- Example: `frame: false` in F001-shell → all downstream UI Features must implement custom titlebar with `-webkit-app-region: drag`

Record dependency directions and types, and visualize them as a Mermaid diagram.

**Release Group Determination**:
Group Features into Release Groups based on dependency layers:
1. **Release 1 (Foundation)**: Features with no dependencies (or only external dependencies)
2. **Release 2+**: Features whose dependencies are all satisfied by preceding Release Groups
3. Within each Release Group, order Features by topological sort (most independent first)

> **Do NOT assign Feature IDs yet.** Use temporary labels (feature names only) until Phase 3-3 (Tier classification) is complete. IDs will be assigned after Release Groups and Tiers are both determined.

### 3-2b. Feature ID Assignment (after Phase 3-3)

> **This step runs AFTER Phase 3-3 (Tier Classification).** If Scope = Full, run immediately after 3-2 (no Tier classification needed).

**Feature ID Assignment Rules — IDs MUST follow the pipeline execution order (Tier-first)**:

**If Scope = Core**:
1. **Tier-first global ordering**: Assign ALL Tier 1 Features first, then ALL Tier 2, then ALL Tier 3
2. Within each Tier, follow Release Group order (RG-1 first, then RG-2, etc.)
3. Within the same Tier and Release Group, maintain topological order
4. Assign F001, F002, ... sequentially across all Tiers

This ensures:
- Feature IDs directly correspond to the pipeline execution order
- When only T1 is active: `F001 → F002 → F003 → F004` — no gaps, no skips
- When T2 is activated later, its Features continue sequentially from where T1 ends
- No ID gaps or out-of-order processing at any Tier activation level

**Example** (12 Features, 4 Release Groups):
```
T1 Features (in RG order): F001, F002, F003, F004   ← pipeline processes these first
T2 Features (in RG order): F005, F006, F007          ← activated when T2 starts
T3 Features (in RG order): F008, F009, F010, F011, F012 ← activated when T3 starts
```

**If Scope = Full**:
1. Start with Release Group 1, then Release Group 2, etc.
2. Within each Release Group, maintain topological order
3. Assign F001, F002, ... sequentially

This ensures:
- Feature IDs match the implementation order based on dependency-resolved Release Groups

**Common**: These numbers also correspond to spec-kit's `specs/{NNN-feature}/` directory names (e.g., F001-auth → `specs/001-auth/`)

### 3-3. Importance Analysis and Tier Classification (Core Scope Only, HARD STOP)

> **This phase is SKIPPED when Scope = Full.** In full mode, all Features are implemented without prioritization — Feature ordering is determined by Release Group order (Phase 3-2). Proceed to Phase 3-2b (Feature ID Assignment) then Phase 4.

**If Scope = Core**:

First, identify the project domain: understand what kind of system the project is (e-commerce, SaaS, CMS, education platform, financial service, etc.) and determine which features are foundational within that domain.

Evaluate each Feature comprehensively across the analysis axes and assign to Tier 1 (Essential) / Tier 2 (Recommended) / Tier 3 (Optional). See `domains/_core.md` § R6 (Tier Classification Axes) for the evaluation criteria and Tier definitions. For each Feature, a **specific rationale** for the assigned Tier must be provided.

**FIRST**, display the full Tier classification table showing each Feature's assigned Tier and rationale (using temporary names — final Feature IDs will be assigned in Phase 3-2b after Tier approval):
```
── Tier Classification Results ──────────────────

Tier 1 (Essential):
  auth            — [rationale]
  product         — [rationale]

Tier 2 (Recommended):
  order           — [rationale]

Tier 3 (Optional):
  analytics       — [rationale]
```

**THEN**, ask via AskUserQuestion for approval/adjustments. **If response is empty → re-ask.**

**After Tier approval**: Proceed to Phase 3-2b to assign final Feature IDs in Release Group order (Tier 1 first within each group).

### Decision History Recording — Architecture

After Phase 3 is complete (granularity selected, dependencies mapped, Tier classification approved if core scope), **append** to `specs/history.md` under the current session's section:

```markdown
### Architecture Decisions

| Decision | Choice | Details |
|----------|--------|---------|
| Feature Granularity | Coarse / Standard / Fine | [N] Features |
| Tier Adjustments | [summary of user modifications] | [details, or "None — accepted AI recommendation as-is"] |
```

Record each user modification to the AI's Tier proposals (e.g., "Moved Search from T2 → T1"). If scope is `full`, omit the Tier Adjustments row.

📝 **Case Study Recording**: Append milestone entry to `case-study-log.md` per [recording-protocol.md](../../case-study/reference/recording-protocol.md) § M3.

---

## Phase 4 — Deliverable Generation

Generate hierarchical deliverables in `specs/reverse-spec/` (in CWD — see Output Directory rule in SKILL.md).

> **Scope = Core**: All Features are included in generated artifacts (roadmap.md, pre-context.md, etc.) regardless of Tier. The Tier classification only determines which Features smart-sdd will initially process — Tier 2/3 Features are marked as `deferred` in `sdd-state.md` and skipped by the pipeline until activated via `/smart-sdd expand`. This ensures Tier 2/3 Features are ready for immediate activation without re-running `/reverse-spec`.
>
> **Scope = Full**: All Features are included without Tier classification. No Features are deferred. The `Tier` column is omitted from roadmap.md and sdd-state.md.

### 4-1. Project-Level Deliverables

Generate the following files in order. Each file follows the template structure found in this skill's `templates/` directory.

1. **`specs/reverse-spec/roadmap.md`** — See [roadmap-template.md](templates/roadmap-template.md)
   - Project Overview, Rebuild Strategy, Feature Catalog (by Tier for Core scope / by dependency order for Full scope), Dependency Graph, Release Groups, **Demo Groups** (from Phase 3-1c), Cross-Feature Entity Dependencies, Cross-Feature API Dependencies

2. **`specs/reverse-spec/entity-registry.md`** — See [entity-registry-template.md](templates/entity-registry-template.md)
   - Complete entity list, fields, relationships, validation rules, cross-Feature sharing mapping

3. **`specs/reverse-spec/api-registry.md`** — See [api-registry-template.md](templates/api-registry-template.md)
   - Complete API endpoint index, detailed contracts, cross-Feature dependencies

4. **`specs/reverse-spec/business-logic-map.md`** — See [business-logic-map-template.md](templates/business-logic-map-template.md)
   - Business rules per Feature, validation, workflows, cross-Feature rules

5. **`specs/reverse-spec/constitution-seed.md`** — See [constitution-seed-template.md](templates/constitution-seed-template.md)
   - Source code reference principles (branching by stack strategy), extracted architecture principles, technical constraints, coding conventions
   - **Naming Conventions** (if project identity changed in Phase 0 Question 3): Include a mapping section documenting original → new naming patterns (e.g., `Cherry` → `Angdu`, `CS` → `AS`). This section guides `speckit-constitution` and `speckit-implement` to use the new project naming consistently.
   - **Recommended Development Principles (Best Practices)**: Test-First, Think Before Coding, Simplicity First, Surgical Changes, Goal-Driven Execution, Demo-Ready Delivery
   - **Global Evolution Layer Operational Principles**: Rules for maintaining cross-Feature context
   - **Project-Specific Recommended Principles**: Based on the domain, architecture patterns, and technical traits observed in Phase 1~3, recommend additional constitution principles tailored to this project. Use the recommendation categories in the template (domain-driven, architecture-driven, scale-driven, quality-driven) as a guide. Each recommendation must cite a specific observed trait from the source analysis as evidence.

6. **`specs/reverse-spec/stack-migration.md`** (only for New Stack strategy) — See [stack-migration-template.md](templates/stack-migration-template.md)
   - Current → New mapping per technology component, migration rationale, per-Feature migration notes, risks and mitigations

7. **`.env.example`** (project root, **rebuild mode only** — skip when `--adopt` is specified):
   - **Adoption mode**: `.env.example` already exists in the source project. Do NOT regenerate. Environment variables are documented in each Feature's pre-context.md → "Environment Variables" section only.
   - **Rebuild mode**: Generated at CWD root (NOT inside `specs/reverse-spec/`)
   - Lists all detected env vars with category comments and placeholder values
   - Groups by Feature association (shared vars first, then per-Feature)
   - Format:
     ```
     # ── Shared (used by multiple Features) ──
     DATABASE_URL=postgresql://localhost:5432/myapp

     # ── F001-auth ──
     JWT_SECRET=your-jwt-secret-here
     OAUTH_CLIENT_ID=your-oauth-client-id
     ```

8. **`specs/reverse-spec/speckit-prompt.md`** — See [speckit-prompt-template.md](templates/speckit-prompt-template.md)
   - Standalone prompt for using spec-kit without smart-sdd
   - Per-command context guide: which artifacts to read before each spec-kit command (specify, plan, implement, verify)
   - Cross-Feature awareness rules
   - Fill dynamic fields: PROJECT_NAME, scope, stack, Feature count/Tier breakdown, Feature catalog table (from roadmap.md)

### 4-2. Feature-Level Deliverables

For each Feature, generate `specs/reverse-spec/features/[Feature-ID]-[feature-name]/pre-context.md`. See [pre-context-template.md](templates/pre-context-template.md).

**Path Convention**: All file paths in pre-context.md's Source Reference and Static Resources sections MUST be **relative to the target directory** (the source being analyzed). Do NOT use absolute paths. The `Source Root` header in the template references `$SOURCE_ROOT`, whose actual value is stored as `Source Path` in `sdd-state.md` and resolved at runtime by smart-sdd.

For example, if the target directory is `/Users/dev/legacy-app`:
- ✅ `src/main/index.ts`
- ❌ `/Users/dev/legacy-app/src/main/index.ts`

#### B### ID Assignment Rules

When populating the Source Behavior Inventory (SBI) table in each pre-context.md, assign globally unique **B### IDs** to every SBI entry:

1. **Sequential numbering**: B001, B002, B003, ... across the entire project (not per-Feature)
2. **Feature order**: Assign IDs following Feature ID order — F001's SBI entries get the lowest B### numbers, then F002's entries continue from where F001 left off, and so on
3. **Within a Feature**: Order entries by Priority (P1 first, then P2, then P3), then alphabetically by function name within the same priority
4. **Uniqueness**: Each B### ID is unique project-wide. If F001 has entries B001–B010, F002 starts at B011
5. **Demo Group SBI**: After assigning all B### IDs, update each Demo Group definition in roadmap.md with the SBI Coverage field listing the B### ranges from its constituent Features

Example:
```
F001-auth (10 entries): B001–B010
F002-product (8 entries): B011–B018
F003-order (12 entries): B019–B030
```

Contents to include in each pre-context.md:
- **Runtime Exploration Results** (rebuild only, if Phase 1.5 was performed): Read `specs/reverse-spec/runtime-exploration.md` and distribute observations to each Feature based on route-to-Feature mapping. For each Feature: extract the `## Screen:` sections whose routes belong to this Feature, include associated user flows and runtime behavior from those screen blocks, and add relevant App-Wide Observations. If Phase 1.5 was skipped or the file does not exist, write "Skipped — [reason]"

  **Route-to-Feature Mapping Algorithm**:
  1. Feature boundaries are determined by file/module in Phase 3-1
  2. Phase 1 code scan identifies page component files for each route
  3. Mapping: route → page component file → Feature that owns the file (Phase 3-1 boundary)
  4. Shared routes: included in primary owner Feature, referenced in other Features
  5. Unmappable routes: recorded in App-Wide Observations
- **Source Reference**: List of related original files (relative paths) + reference guide by stack strategy. Include a **Rebuild Target** column set to `[TBD]` for all files — this column will be populated during `/speckit.plan` when the target architecture is decided
- **Source Behavior Inventory**: Phase 2-6 SBI entries filtered to this Feature (see `domains/_core.md` § R3 (Source Behavior Inventory) for format)

  > **SBI Per-Feature Filtering**: Filter only behaviors belonging to this Feature's source files from the Phase 2-6 global SBI. B### IDs are assigned sequentially and uniquely across the entire project in Feature ID order.
- **UI Component Features** (frontend/fullstack projects only): Third-party UI library capabilities from Phase 2-7, filtered to this Feature's associated components. Each entry: component name, library, feature, category. Omit for backend-only projects
- **Interaction Behavior Inventory** (frontend/fullstack projects only): Micro-interaction patterns from Phase 2-7b (hover behaviors, keyboard shortcuts, animations, focus management, drag-and-drop, context menus, scroll behaviors), filtered to this Feature's associated components and screens. Omit for backend-only projects
- **Foundation Decisions** (if Framework ≠ "custom"): From Phase 2-8 extraction results, populate the Foundation Decisions section (Critical, Important, Undecided tables) with items relevant to this Feature's domain. For T0 Features (F000-*): include all items from their owning Foundation categories. For T1+ Features: include only Foundation decisions that constrain this Feature
- **Foundation Dependencies**: For each Feature, classify its relationship to Foundation categories — `owns` (T0 only), `consumes` (T1+ uses Foundation decisions as constraints), `extends` (rare, adds to Foundation). Skip if Framework is "custom" or "none"
- **Naming Remapping** (only if Phase 0 Question 3 established a new project name): Per-Feature catalog of code-level identifiers containing the original project name, with suggested new identifiers. Populated from Phase 3-1 scan results. Omit this section entirely if project name is unchanged or no old-name identifiers were found in this Feature
- **Static Resources**: List of non-code files (images, fonts, i18n, etc.) used by this Feature, with source/target paths (source paths relative to target directory) and usage context. Based on Phase 1-5 inventory, filtered to this Feature's associated files
- **Environment Variables**: Variables this Feature requires at runtime, from Phase 2-5 extraction. Distinguishes Feature-owned vars from shared vars referenced from other Features
- **For /speckit.specify**: Existing feature summary, existing user scenarios, draft requirements (FR-###), draft success criteria (SC-###), edge cases
- **For /speckit.plan**: Preceding Feature dependencies, related entity/API contract drafts (owned + referenced entities, provided + consumed APIs), technical decisions
- **Feature Contracts** (populated from Phase 3-1d interaction data and Phase 2-3 cross-Feature rules): Explicit guarantees this Feature provides to consumers, dependencies it requires from providers, and failure modes when contracts are violated. See [pre-context-template.md](templates/pre-context-template.md) § Feature Contracts. If this Feature has no cross-Feature interactions (Interaction Score = 0), write "None — this Feature operates independently."
- **For /speckit.analyze**: Cross-Feature verification points, impact scope when this Feature changes

### 4-3. Source Coverage Baseline (BLOCKING)

> ⚠️ **This sub-phase is MANDATORY and BLOCKING.** Do NOT skip Steps 2-3 even if the deliverables are already generated. Low source coverage means Features are incomplete — the unmapped source files likely represent functionality that needs to be assigned to existing Features or defined as new Features. **Proceeding to Phase 4-4 without completing Step 3 classification is NOT allowed.**

After generating all deliverables, perform an automated source surface measurement to quantify how much of the original source code is covered by the extracted Features.

#### Step 1 — Automated Surface Measurement

Parse the original source (target directory) and compare against the generated artifacts. Reuse detection patterns from Phase 2 — do NOT re-parse from scratch; compare Phase 2 results against the generated artifact inventories:

| Metric | Source (parse from target) | Mapped (from artifacts) | Comparison Method |
|--------|---------------------------|------------------------|-------------------|
| Source files | Glob all source files (exclude vendor/build/test dirs) | Count files listed in all pre-context.md Source Reference tables | File path matching |
| API endpoints | Parse route definitions (Phase 2-2 tech-stack-specific patterns) | Count entries in api-registry.md | Method + path matching |
| DB models/entities | Parse model/entity definitions (Phase 2-1 patterns) | Count entries in entity-registry.md | Entity name matching |
| Source behaviors | Count exported functions/methods (Phase 2-6) | Count entries in all pre-context.md Source Behavior Inventory tables | Function name matching |
| UI component features | Count library features (Phase 2-7, if applicable) | Count entries in all pre-context.md UI Component Features tables | Feature name matching |
| Micro-interaction inventory | Count patterns (Phase 2-7b, if applicable) | Count entries in all pre-context.md Interaction Behavior Inventory tables | Feature + screen matching |
| Test files | Glob test file patterns (`**/*test*`, `**/*spec*`, `**/__tests__/**`) | Count test files listed in pre-context.md Source Reference | File path matching |
| Business rules | Count rules identified in Phase 2-3 | Count entries in business-logic-map.md | Rule ID matching |

Display the metrics table to the user:

```
📊 Source Coverage Analysis:

| Metric               | Source | Mapped | Coverage |
|----------------------|--------|--------|----------|
| Source files         | 87     | 72     | 82.8%    |
| API endpoints        | 45     | 43     | 95.6%    |
| DB entities          | 20     | 19     | 95.0%    |
| Test files      | 34     | 28     | 82.4%    |
| Source behaviors  | 85     | 72     | 84.7%    |
| UI features      | 12     | 12     | 100%     |
| Business rules   | 42     | 40     | 95.2%    |
```

#### Step 2 — Unmapped Items Identification

For each metric category, identify items in the source that were NOT mapped to any Feature:
- Source files not listed in any pre-context.md Source Reference
- Endpoints parsed from routes but not in api-registry.md
- Models parsed from source but not in entity-registry.md
- Source behaviors (exported functions) not listed in any pre-context.md Source Behavior Inventory
- UI component features not listed in any pre-context.md UI Component Features (if applicable)
- Test files not associated with any Feature

Group the unmapped items by apparent category/module (e.g., "middleware files", "admin endpoints", "utility models") to minimize the number of user interactions in Step 3.

**Project identity renaming**: If Phase 0 Question 3 established a new project name, highlight items containing the original project name prefix in the unmapped items list (e.g., "⚠️ CherryINOAuth — contains original project name"). When the user classifies these items, suggest renamed versions using the new project naming (e.g., "AngduINOAuth" or "INOAuth").

#### Step 3 — Classification (HARD STOP)

For each unmapped group, use AskUserQuestion and WAIT for the user's response:

```
📋 Unmapped Items: [Group Name] ([N] items)

  [file/endpoint/entity list]

Classification:
```

Options:
- **"Assign to Feature [FID]"** — Add to existing Feature's pre-context.md Source Reference. Ask which FID if not obvious from context.
- **"Create new Feature"** — Collect Feature name and description from user. Add to roadmap.md Feature Catalog (with next available ID). Generate pre-context.md for the new Feature.
- **"Cross-cutting concern"** — Flag for constitution-seed.md update (add principle) or future infrastructure Feature. Record in coverage-baseline.md.
- **"Intentional exclusion"** — Record with one of 6 exclusion reasons: `deprecated`, `replaced`, `third-party`, `deferred`, `out-of-scope`, `covered-differently`. If `deferred`, link to the relevant deferred Feature in roadmap.md.

**Empty/blank response = NOT classified — re-ask.** You MUST obtain an explicit classification for every group.

If user selects "Create new Feature" for any items:
- Assign the next available Feature ID (continuing the existing sequence)
- Add to roadmap.md Feature Catalog (with appropriate Tier for core scope, or dependency position for full scope)
- Generate pre-context.md for the new Feature using the [pre-context-template](templates/pre-context-template.md)
- The new Feature will be picked up by smart-sdd when the pipeline runs

#### Step 3b — Post-Classification Coverage Update

After classifying ALL unmapped groups:

1. **Recalculate coverage metrics**: Include newly assigned items and new Features from Step 3
2. **Display updated metrics**:
   ```
   📊 Updated Source Coverage (after classification):

   | Metric       | Before | After | Change |
   |--------------|--------|-------|--------|
   | Source files | 45.5%  | 89.2% | +43.7% |
   | ...          | ...    | ...   | ...    |

   New Features created: [count]
   Items assigned to existing Features: [count]
   Intentional exclusions: [count]
   ```
3. **If source file coverage is still below 70%** after classification: Display a warning and ask the user whether to continue or re-examine:
   ```
   ⚠️ Source file coverage is still [X]% after classification.
   This means [N] source files are not accounted for in any Feature.
   ```

#### Step 4 — Generate coverage-baseline.md

Generate `specs/reverse-spec/coverage-baseline.md` using the [coverage-baseline-template](templates/coverage-baseline-template.md):
- Populate Surface Metrics table with the **final** measured values (after Step 3b update)
- Record all unmapped items with their user-assigned classifications from Step 3
- Record all intentional exclusions with their reasons and descriptions
- Add coverage notes from the classification process

📝 **Case Study Recording**: Append milestone entry to `case-study-log.md` per [recording-protocol.md](../../case-study/reference/recording-protocol.md) § M4.

### 4-4. Completion Report

Report the complete list of generated deliverables and next-step guidance to the user:

```
Generation complete:
- specs/reverse-spec/roadmap.md
- specs/reverse-spec/constitution-seed.md
- specs/reverse-spec/entity-registry.md
- specs/reverse-spec/api-registry.md
- specs/reverse-spec/business-logic-map.md
- specs/reverse-spec/stack-migration.md          (if New Stack strategy)
- specs/reverse-spec/coverage-baseline.md
- specs/reverse-spec/features/F001-xxx/pre-context.md
- specs/reverse-spec/features/F002-xxx/pre-context.md
- ...
- case-study-log.md                                 (observation log for milestone tracking — project root)
- .env.example                                    (rebuild only — if env vars detected)
- specs/reverse-spec/speckit-prompt.md             (spec-kit standalone usage prompt)

SBI: [N] source behaviors tracked (B001–B[N]) across [M] Features
Demo Groups: [K] groups defined — Integration Demos trigger when all Features in a group are verified

Next steps:
  /smart-sdd pipeline       — Run the full SDD pipeline for rebuild (recommended)
  /smart-sdd adopt          — Run the adoption pipeline to wrap existing code with SDD docs
  /smart-sdd parity          — Check implementation parity against original source (after pipeline completes)

  Or use spec-kit standalone with the generated prompt:
  Copy specs/reverse-spec/speckit-prompt.md into CLAUDE.md, then run spec-kit commands directly.
  The prompt guides which artifacts to read before each command.

smart-sdd will automatically:
  1. Finalize constitution based on constitution-seed.md
  2. Progress Features in Release Group order (specify → plan → tasks → analyze → implement → verify → merge)
  3. Inject cross-Feature context from pre-context.md, business-logic-map.md, and registries at each step
  4. Update entity-registry.md and api-registry.md as Features are completed
  5. Track SBI coverage (B### → FR-### mapping) and Demo Group progress in sdd-state.md
```

### 4-5. Completion Checkpoint (commit + tag)

After displaying the Completion Report, create a git checkpoint so the user can reset smart-sdd pipeline state back to this point:

1. **Stage all reverse-spec artifacts**:
   ```bash
   git add specs/reverse-spec/ specs/history.md case-study-log.md .env.example .gitignore
   ```

2. **Commit**:
   ```bash
   git commit -m "chore: reverse-spec analysis complete — [N] Features extracted"
   ```

3. **Tag** (for smart-sdd reset to reference):
   ```bash
   git tag -f reverse-spec-complete
   ```

4. **Playwright MCP CDP notice** (if CDP was used in Phase 1.5):
   If Playwright MCP was configured with `--cdp-endpoint` for Electron Runtime Exploration, display the appropriate notice based on stack strategy:

   **Same stack (Electron rebuild)** — CDP mode is reusable for `/smart-sdd` verify:
   ```
   ℹ️ Playwright MCP is in CDP mode (--cdp-endpoint http://localhost:9222).
      This is fine for /smart-sdd — when verify needs to test the new Electron app,
      start it with --remote-debugging-port=9222 and Playwright will connect automatically.
   ```

   **New stack (non-Electron)** — CDP mode must be restored to standard:
   ```
   ⚠️ Playwright MCP is still in CDP mode (--cdp-endpoint http://localhost:9222).
      Your new stack is not Electron, so restore standard browser mode before /smart-sdd:
        claude mcp remove playwright -s user
        claude mcp add --scope user playwright -- npx @playwright/mcp@latest
      Then restart Claude Code.
   ```

   Skip this notice if Phase 1.5 was skipped or CDP was not configured.

5. Display:
   ```
   📌 Checkpoint: Tagged as 'reverse-spec-complete'
      Use /smart-sdd reset to return to this point if you need to restart the pipeline.
   ```

> **If not a git repo**: Skip this step entirely. Display: "ℹ️ No git repository — checkpoint not created."
> **If tag already exists**: Overwrite with `-f` flag (user may have run reverse-spec multiple times).
