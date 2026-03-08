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
4. **Jump to**: Phase 1.5 Step 0 (MCP Availability Check)

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
Read configuration files to identify the tech stack. See `domains/{domain}.md` § Tech Stack Detection for the detection-target-to-file mapping.

### 1-3. Project Type Classification
Classify the project type based on the collected information. Use the project types defined in `domains/{domain}.md` § Project Type Classification.

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

### 1.5-0. MCP Availability Check + User Choice (HARD STOP)

**Step 1 — Detect Playwright MCP**:
Check if Playwright MCP tools are available by verifying the existence of `browser_navigate`, `browser_snapshot`, and `browser_click` tools.

**Step 2 — Present options based on detection result**:

**If Playwright MCP is available**:
```
🔍 Runtime Exploration Available

Playwright MCP가 감지되었습니다. 원본 앱을 실제로 실행하고
브라우저로 탐색하여 UI/UX를 기록할 수 있습니다.

이 단계는 선택사항이며, 스킵해도 Phase 2 코드 분석은 정상 진행됩니다.
단, 실행하면 UI 레이아웃, 사용자 플로우, 시각 정보를 더 정확하게 추출합니다.
```
Ask via AskUserQuestion:
- **"Run Runtime Exploration (Recommended)"** — 앱 실행 + 브라우저 탐색
- **"Skip — code analysis only"** — Phase 2로 바로 이동

**If Playwright MCP is NOT available**:
```
🔍 Runtime Exploration

Playwright MCP가 감지되지 않았습니다.
앱을 실행할 수는 있지만, 자동 브라우저 탐색은 불가능합니다.
설치: claude mcp add playwright -- npx @playwright/mcp@latest
```
Ask via AskUserQuestion:
- **"Manual Exploration"** — 에이전트가 앱 실행 후 사용자가 직접 탐색 결과 공유
- **"Skip — code analysis only"** — Phase 2로 바로 이동

**If response is empty → re-ask** (per MANDATORY RULE 1). If "Skip" is selected, record `Runtime Exploration: skipped (user choice)` and proceed to Phase 2.

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

── ✅ Auto-resolvable (에이전트가 처리) ─────────────────
  □ [package manager] install ([dependency dir] 미존재)
  □ .env 생성 (from .env.example — config 변수 기본값 설정)

── ⚠️ Requires Your Action ─────────────────────────────
  □ [VAR_NAME] — [description] ([category: secret])
    💡 [hint: e.g., "docker-compose.yml에 postgres 서비스 정의 있음
       → docker compose up -d postgres 로 시작 가능"]
  □ [VAR_NAME] — [description] ([category: secret])

── ℹ️ Optional (없어도 기본 탐색 가능) ──────────────────
  □ [VAR_NAME] — [description] (탐색 시 불필요)
──────────────────────────────────────────────────────────

Dev Server: `[start command]` (port [N])
```

Ask via AskUserQuestion:
- **"Docker Compose로 인프라 시작 + 진행"** — `docker compose up -d` 실행 후 계속 (only shown if `docker-compose.yml` exists with relevant services)
- **"환경 준비 완료 — 진행"** — 사용자가 이미 수동으로 환경 설정한 경우
- **"일부 서비스 없이 진행"** — 부분 탐색 (일부 기능 에러 가능 인지)
- **"Skip Runtime Exploration"** — 환경 설정이 복잡하여 스킵

**If response is empty → re-ask** (per MANDATORY RULE 1). If "Skip" is selected, record `Runtime Exploration: skipped (environment complexity)` and proceed to Phase 2.

**Rules**:
- ⚠️ NEVER write actual secret values to `.env`. For `secret` category variables, write a placeholder comment: `# REQUIRES: your-value-here`
- `config` category variables: use values from `.env.example` or sensible defaults (e.g., `PORT=3000`, `NODE_ENV=development`)
- `feature-flag` category variables: default to enabled (`true` or `1`) to maximize explorable features

### 1.5-3. Auto Setup

Execute auto-resolvable steps:

1. **Dependency installation**:
   Run the detected package manager install command (e.g., `npm install`, `pip install -r requirements.txt`)
   - If fails → display error message → HARD STOP: "해결 후 재시도" / "Skip Runtime Exploration"

2. **`.env` creation** (if `.env` does not exist and `.env.example` exists):
   Copy `.env.example` → `.env`, apply defaults for `config` variables, leave `secret` variables as placeholders
   - If `.env` already exists → skip (do NOT overwrite user's existing `.env`)

3. **Docker Compose** (if user selected this option):
   Run `docker compose up -d`
   - Wait for services to be ready (up to 30 seconds)
   - If fails → display error → HARD STOP: "재시도" / "수동 설정 후 계속" / "Skip"

4. **Build step** (if detected as necessary):
   Run the build command (e.g., `npm run build`)
   - If fails → display error → HARD STOP (same options as above)

### 1.5-4. App Launch + Readiness Check

**Step 1 — Identify and run the start command**:
Use the dev server command identified in 1.5-1. Run it as a background process, capturing stdout/stderr.

> **Multiple start commands**: If multiple dev-related scripts exist (e.g., `dev`, `dev:web`, `electron:dev`), ask the user which one to run via AskUserQuestion. **If response is empty → re-ask** (per MANDATORY RULE 1).

**Step 2 — Wait for readiness**:
- Monitor stdout for readiness signals: `ready`, `listening on`, `started`, `compiled`, `Local:`, `http://localhost`
- Alternatively, poll the expected port with `lsof -i :[PORT]`
- Timeout: 60 seconds

**Step 3 — Handle launch failure**:
If the app fails to start within the timeout:
1. Capture and analyze stderr/stdout error messages
2. Classify the error:
   - Missing environment variable → "`.env`에 `[VAR]` 설정 필요"
   - DB connection refused → "데이터베이스 연결 실패 — DB가 실행 중인지 확인"
   - Port in use → "포트 `[N]` 사용 중 — 기존 프로세스 종료 필요"
   - Module not found → "`[package]` 미설치 — `npm install` 재실행 필요"
   - Build error → "빌드 에러 — 소스 코드 문제일 수 있음"
3. Display error with suggestion → HARD STOP:
   - "문제 해결 후 재시도"
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
🔧 앱 초기 설정

앱이 실행되었지만, 핵심 기능을 탐색하려면 앱 내 설정이 필요할 수 있습니다.

코드 분석에서 감지된 설정 항목:
  • [항목 1: 예) Settings → AI Provider에서 API Key 입력]
  • [항목 2: 예) Settings → Model 선택]
  • [항목 3: 예) 최초 실행 시 온보딩 완료]

앱에서 직접 설정을 완료한 후 "준비 완료"를 선택해주세요.
설정 없이도 UI 구조 탐색은 가능합니다.
```

**HARD STOP** — Use AskUserQuestion:
- "설정 완료 — 전체 탐색 진행" (Recommended)
- "설정 없이 UI 구조만 탐색"
- "Skip Runtime Exploration"

**If response is empty → re-ask** (per MANDATORY RULE 1).

> **Note**: If no initial setup needs are detected from the code, skip this step and proceed directly to 1.5-5.

### 1.5-5. Runtime Exploration

#### Path A — Automated Exploration (Playwright MCP)

With the app running, systematically explore using Playwright MCP:

**Phase A — Initial Landing**:
1. `browser_navigate` → `http://localhost:[PORT]`
2. `browser_snapshot` → capture accessibility tree (page structure, elements, roles)
3. `browser_take_screenshot` → record initial screen
4. `browser_console_messages` → check for initial JS errors

**Phase B — Navigation Discovery**:
1. From the accessibility tree, identify navigation elements (`nav`, sidebar, menu, tabs, header links)
2. Collect all internal navigation links (URL + text)
3. Cross-reference with route definitions found in Phase 1 code scan (if available)

**Phase C — Screen-by-Screen Survey**:
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

**Budget Control**:
- Maximum screens: 20 (if more routes exist, sample representative ones and note "N more similar pages")
- Per-screen time: 10 seconds max
- Total exploration budget: 5 minutes
- Repeated layout patterns: sample 3, then note "N more with same pattern"

#### Path B — Manual Exploration (no Playwright MCP)

With the app running:

```
📋 Manual Exploration Request

앱이 http://localhost:[PORT] 에서 실행 중입니다.
자동 탐색이 불가능하므로, 아래 정보를 확인 후 공유해주세요:

1. 주요 화면 목록 (URL + 간단한 설명)
2. 네비게이션 구조 (메뉴, 사이드바 항목)
3. 핵심 사용자 플로우 (예: 로그인 → 대시보드 → ...)
4. 특이한 UI 패턴 (에디터, 차트, 드래그앤드롭 등)

스크린샷을 공유해주시면 더 정확한 분석이 가능합니다.
```

Ask via AskUserQuestion:
- **"관찰 결과 공유 준비됨"** — user provides observations as text/screenshots
- **"Skip"** — proceed without runtime data

**If response is empty → re-ask** (per MANDATORY RULE 1).

After the user shares observations, parse and structure them into the same format as Path A output.

### 1.5-6. Observation Recording + Cleanup

**Step 1 — Write `specs/reverse-spec/runtime-exploration.md`**:
Compile exploration results into a structured markdown file organized **by route/screen**. Each screen block contains all observed information (UI elements, user flows, behavior, errors) in one place. This file persists across phases and sessions — Phase 2 reads it for cross-referencing, Phase 4-2 distributes its contents to each Feature's `pre-context.md` using route-to-Feature mapping.

Write the file with the following structure:

```markdown
# Runtime Exploration Results

> Generated by `/reverse-spec` Phase 1.5 — [ISO timestamp]
> Mode: [automated (Playwright) | manual]
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

**Step 3 — Dev server cleanup**:
1. Terminate the dev server process
2. If Docker Compose was started: leave services running (user may need them for `smart-sdd`)
   - Display: "ℹ️ Docker Compose 서비스는 계속 실행 중입니다. 종료: `docker compose down`"
3. `.env` file created during setup: leave in place (reusable for `smart-sdd`)

**Step 4 — Proceed to Phase 2**:
Runtime exploration results are saved in `specs/reverse-spec/runtime-exploration.md`. Phase 2 will read this file to cross-reference code analysis with runtime observations.

📝 **Case Study Recording**: Append milestone entry to `case-study-log.md` per [recording-protocol.md](../../case-study/reference/recording-protocol.md):
```
### M1.5 — Runtime Exploration
- **Timestamp**: [ISO timestamp]
- **Mode**: [automated (Playwright) | manual | skipped]
- **Screens explored**: [N]
- **Key findings**: [1-2 sentence summary]
```

---

## Phase 2 — Deep Analysis

> **Domain Profile**: Read `domains/{domain}.md` § Analysis Axes for the domain-specific extraction targets used throughout this Phase.

Perform deep analysis using patterns appropriate to the tech stack identified in Phase 1. For large codebases, leverage parallel sub-agents via the Task tool.

> **Phase 1.5 Cross-Reference**: If `specs/reverse-spec/runtime-exploration.md` exists, read the file and use the observations to enrich analysis:
> - Validate route definitions against actually observed screens (Screen Inventory)
> - Enrich entity extraction with observed data display patterns — tables, forms, card views (UI Patterns)
> - Cross-reference API endpoints with observed user interactions (User Flows Observed)
> - Note discrepancies between code structure and runtime behavior — e.g., routes defined in code but not reachable in UI (Screen Inventory vs code routes)

### 2-1. Data Model Extraction
Extract entities from appropriate sources depending on the tech stack identified in Phase 1. See `domains/{domain}.md` § Data Model Extraction for the technology-to-search-target mapping and extraction details.

### 2-2. API Endpoint Extraction
Extract APIs from appropriate sources depending on the tech stack identified in Phase 1. See `domains/{domain}.md` § API Endpoint Extraction for the technology-to-search-target mapping and extraction details.

### 2-3. Business Logic Extraction
Extract business rules, validation, workflows, and external integrations from the service layer and domain logic. See `domains/{domain}.md` § Business Logic Extraction for extraction categories.

### 2-4. Inter-Module Dependency Mapping
Analyze import/require statements, service call relationships, shared utilities, and event-based coupling. See `domains/{domain}.md` § Inter-Module Dependency Mapping for details.

### 2-5. Environment Variable Extraction
Scan the codebase for environment variable usage to identify runtime configuration requirements. See `domains/{domain}.md` § Environment Variable Extraction for the technology-to-search-pattern mapping and per-variable extraction details.

⚠️ NEVER read or record actual secret values from `.env` files. Only read `.env.example` or detect variable names from code patterns.

### 2-6. Source Behavior Inventory

For each source file identified in Phase 1, extract a **function-level inventory** of exported/public behaviors (P1 core / P2 important / P3 nice-to-have). This captures discrete units of functionality that structural extraction (entities, APIs) may miss. See `domains/{domain}.md` § Source Behavior Inventory for extraction targets, priority classification, and scan patterns.

- Group by Feature association (determined in Phase 3 when Feature boundaries are identified)
- Skip internal/private helpers that are implementation details, not behaviors

This inventory feeds into each Feature's `pre-context.md` → "Source Behavior Inventory" section (Phase 4-2) and is used by `/smart-sdd verify` for Feature-level completeness checking.

### 2-7. UI Component Feature Extraction (Frontend/Fullstack Projects Only)

> Skip this step entirely for backend-only, library, or CLI projects.

Third-party UI libraries provide user-facing capabilities through **configuration and plugins**, not through exported functions — invisible to function-level analysis but significant functionality that must be reproduced. See `domains/{domain}.md` § UI Component Feature Extraction for the 3-step process (identify → extract → record) and library category mapping.

This inventory feeds into each Feature's `pre-context.md` → "UI Component Features" section (Phase 4-2) and is compared during `/smart-sdd parity` → UI Feature Parity.

Upon completing Phase 2, report a summary of the number of entities, APIs, business rules, environment variables, source behaviors, and UI component features discovered.

---

## Phase 3 — Feature Classification and Importance Analysis

### 3-1. Feature Boundary Identification
Identify logical functional units (Features) based on the Phase 2 analysis results, using the boundary heuristics defined in `domains/{domain}.md` § Feature Boundary Heuristics.

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

Then proceed to 3-2.

### 3-2. Dependency Graph Construction and Release Group Determination
Derive inter-Feature dependencies:
- **Direct Dependency**: Uses another Feature's modules via import/require
- **API Dependency**: Calls APIs provided by another Feature
- **Entity Dependency**: References entities owned by another Feature
- **Event Dependency**: Subscribes to events published by another Feature

Record dependency directions and types, and visualize them as a Mermaid diagram.

**Release Group Determination**:
Group Features into Release Groups based on dependency layers:
1. **Release 1 (Foundation)**: Features with no dependencies (or only external dependencies)
2. **Release 2+**: Features whose dependencies are all satisfied by preceding Release Groups
3. Within each Release Group, order Features by topological sort (most independent first)

> **Do NOT assign Feature IDs yet.** Use temporary labels (feature names only) until Phase 3-3 (Tier classification) is complete. IDs will be assigned after Release Groups and Tiers are both determined.

### 3-2b. Feature ID Assignment (after Phase 3-3)

> **This step runs AFTER Phase 3-3 (Tier Classification).** If Scope = Full, run immediately after 3-2 (no Tier classification needed).

**Feature ID Assignment Rules — IDs MUST follow the actual implementation (Release Group) order**:

**If Scope = Core**:
1. Start with Release Group 1, then Release Group 2, etc.
2. Within each Release Group, Tier 1 Features come first, then Tier 2, then Tier 3
3. Within the same Tier in the same Release Group, maintain topological order
4. Assign F001, F002, ... sequentially across all Release Groups

This ensures:
- Feature IDs directly correspond to the pipeline execution order
- `F001 → F002 → F003 → ...` is the order Features will actually be built
- No ID gaps or out-of-order processing in the pipeline

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

Evaluate each Feature comprehensively across the analysis axes and assign to Tier 1 (Essential) / Tier 2 (Recommended) / Tier 3 (Optional). See `domains/{domain}.md` § Tier Classification Axes for the evaluation criteria and Tier definitions. For each Feature, a **specific rationale** for the assigned Tier must be provided.

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
- **Source Reference**: List of related original files (relative paths) + reference guide by stack strategy
- **Source Behavior Inventory**: Phase 2-6 SBI entries filtered to this Feature (see `domains/app.md` § 3-7 for format)
- **UI Component Features** (frontend/fullstack projects only): Third-party UI library capabilities from Phase 2-7, filtered to this Feature's associated components. Each entry: component name, library, feature, category. Omit for backend-only projects
- **Naming Remapping** (only if Phase 0 Question 3 established a new project name): Per-Feature catalog of code-level identifiers containing the original project name, with suggested new identifiers. Populated from Phase 3-1 scan results. Omit this section entirely if project name is unchanged or no old-name identifiers were found in this Feature
- **Static Resources**: List of non-code files (images, fonts, i18n, etc.) used by this Feature, with source/target paths (source paths relative to target directory) and usage context. Based on Phase 1-5 inventory, filtered to this Feature's associated files
- **Environment Variables**: Variables this Feature requires at runtime, from Phase 2-5 extraction. Distinguishes Feature-owned vars from shared vars referenced from other Features
- **For /speckit.specify**: Existing feature summary, existing user scenarios, draft requirements (FR-###), draft success criteria (SC-###), edge cases
- **For /speckit.plan**: Preceding Feature dependencies, related entity/API contract drafts (owned + referenced entities, provided + consumed APIs), technical decisions
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

SBI: [N] source behaviors tracked (B001–B[N]) across [M] Features
Demo Groups: [K] groups defined — Integration Demos trigger when all Features in a group are verified

Next steps:
  /smart-sdd pipeline       — Run the full SDD pipeline for rebuild (recommended)
  /smart-sdd adopt          — Run the adoption pipeline to wrap existing code with SDD docs
  /smart-sdd parity          — Check implementation parity against original source (after pipeline completes)

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

4. Display:
   ```
   📌 Checkpoint: Tagged as 'reverse-spec-complete'
      Use /smart-sdd reset to return to this point if you need to restart the pipeline.
   ```

> **If not a git repo**: Skip this step entirely. Display: "ℹ️ No git repository — checkpoint not created."
> **If tag already exists**: Overwrite with `-f` flag (user may have run reverse-spec multiple times).
