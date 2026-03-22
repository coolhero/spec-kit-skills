# Orient — Codebase Orientation

> Reference: Read after `/code-explore [path]` or `/code-explore --update` is invoked.

## Purpose

Scan a codebase and generate a high-level architecture map that serves as the navigation foundation for all subsequent trace explorations. The orientation document is a **living document** — updated automatically after each trace and manually via `--update`.

---

## Initial Orientation (first run)

### Step 0 — Workspace Setup

#### Context-Aware Mode Detection

Before workspace setup, check for existing SDD artifacts:

1. Check `specs/_global/sdd-state.md` → if exists, read Domain Profile, Feature list, Artifact Language
2. Check `specs/reverse-spec/roadmap.md` → if exists, read Feature inventory
3. Check `specs/reverse-spec/entity-registry.md` + `api-registry.md` → if exist, load for cross-referencing

**If any exist → activate Context-Aware Mode**:
- Set internal flag: `CONTEXT_AWARE = true`
- Store loaded Domain Profile as `EXISTING_PROFILE`
- Store loaded Feature list as `EXISTING_FEATURES`
- Store loaded registries as `EXISTING_ENTITIES`, `EXISTING_APIS`
- In Step 3, use `EXISTING_PROFILE` instead of re-deriving (but note any mismatches)
- In Step 4, exclude already-covered Features from suggested topics
- In Step 5, add "Existing SDD Context" section to orientation.md

**If none exist → Fresh Mode** (current behavior unchanged).

#### Branch Strategy

- If `--no-branch` is specified: skip branch creation, work in current working tree
- If already on a non-main branch (e.g., a feature branch): skip branch creation, note current branch name
  - **Auto-detect smart-sdd feature branches**: If current branch matches `{NNN}-{name}` pattern (e.g., `001-auth`), automatically enable `--no-branch` behavior and display: `🔀 Active feature branch detected (001-auth). Exploring in current branch.`
- Otherwise: create `explore-study` branch as before

Determine where to write explore artifacts based on target directory:

**If target directory = CWD** (user ran `/code-explore .`):
- Create `explore-study` branch: `git checkout -b explore-study`
- Output to `./specs/explore/` (standard)

**If target directory ≠ CWD** (user ran `/code-explore /other/project` from `~/my-project/`):
- The user wants to study `/other/project` but build in `~/my-project/`
- **Output to target directory** (`/other/project/specs/explore/`) so source links work
- Create explore branch in target repo to keep original clean:
  ```bash
  cd /other/project
  git checkout -b explore-study
  ```
- Record workspace info for later synthesis handoff:
  ```
  Source project: /other/project (explore-study branch)
  Output project: ~/my-project/ (CWD at invocation)
  ```
- Display:
  ```
  📂 Workspace Setup
    Source: /other/project (branch: explore-study)
    Explore artifacts: /other/project/specs/explore/
    Synthesis handoff: ~/my-project/ (when you run /code-explore synthesis)

    ℹ️ Source links in traces will be relative paths — clickable from the source project.
    ℹ️ When you're done exploring, run /code-explore synthesis from ~/my-project/
        to copy Feature candidates to your project.
  ```

**If target is not a git repo**:
- Output to target directory directly
- No branch creation needed
- Add `specs/` to `.gitignore` if the directory has one

### Step 1 — Project Detection

Scan the target directory to identify:

1. **Language & Framework**: Detect from project markers (`package.json`, `go.mod`, `Cargo.toml`, `pyproject.toml`, `pom.xml`, `CMakeLists.txt`, `Makefile`, etc.)
2. **Project type**: CLI, web app, library, desktop app, API server, TCP/UDP server, message consumer, proxy, gateway, gRPC service, etc.
3. **Entry points**: Detect both traditional and server-specific patterns:
   - Traditional: `main`, `index`, `app`, `server` files
   - Server/network: accept loops, listener bindings (`net.Listen`, `bind()`, `TcpListener::bind`), event loop setup
   - Event-driven: `@KafkaListener`, `@EventHandler`, message consumer registration, subscription setup
   - Protocol-based: gRPC service registration (`RegisterServer`), `.proto` service definitions
   - Embedded: interrupt handlers (ISR), RTOS task creation, hardware init routines
4. **Package/module structure**: Top-level directories and their apparent purpose
5. **Concurrency model** (new — critical for server/network programs):
   - Thread pool (`ThreadPoolExecutor`, worker threads)
   - Async/await (`tokio`, `asyncio`, `libuv`)
   - Goroutines / green threads
   - Actor model (`GenServer`, Akka actors)
   - Event loop (Node.js, libuv, epoll/kqueue)
   - Record the model in orientation.md — it shapes how traces should be read

Display a brief summary:
```
📦 Project: [name] ([language] / [framework])
   Type: [project type]
   Entry: [main entry point(s)]
   Size: [N] files, [M] directories
```

#### Scoped Exploration

If `--scope <path>` is specified:
- Limit file scanning to the specified subdirectory
- Still detect project-wide tech stack from root config files (package.json, go.mod, Cargo.toml)
- Module Map focuses on the scoped directory's internal structure
- Suggested Exploration Topics prioritize flows within the scope

### Step 1.5 — Runtime Exploration (🚫 MANDATORY HARD STOP)

> **🚨 THIS STEP REQUIRES A HARD STOP — ALWAYS.**
> You MUST ask the user via AskUserQuestion whether to run or skip runtime exploration.
> You CANNOT decide on your own. Even if the project is a CLI tool, TUI app, or library,
> the USER decides — not you.
>
> ```
> ❌ WRONG: "Runtime exploration skipped (TUI app, Playwright not suitable)"
>    → Agent decided on its own. User was never asked. VIOLATION.
>
> ❌ WRONG: "CLI-only tool, skipping runtime"
>    → Even CLI tools may have web UIs, admin panels, or interactive modes.
>
> ✅ RIGHT: AskUserQuestion "Run runtime exploration?" with options:
>    - "Run Runtime Exploration" → proceed with Playwright
>    - "Skip — static analysis only" → user explicitly chose to skip
> ```
>
> **Shared protocols**:
> - [`shared/runtime/_index.md`](../../shared/runtime/_index.md) — launch, storage, user setup
> - [`shared/runtime/observation-protocol.md`](../../shared/runtime/observation-protocol.md) — **WHAT to observe** (3-layer: Common + Domain-Aware + Skill-Specific)
>
> Follow **Layer 1 + Layer 2** of observation-protocol.md during this step. Layer 3 (code-explore specific) is used during traces.

**0. HARD STOP — Ask user first**:

Use AskUserQuestion:
```
📋 Runtime Exploration

You can run this project to directly observe UI/behavior.
Captures UI patterns, interaction flows, and error states
that static analysis alone might miss.

Project type: [detected type — TUI/Web/Desktop/API]
```
- **"Run Runtime Exploration (Recommended)"** → proceed to step 1
- **"Skip — static analysis only"** → record skip, proceed to Step 2

**If response is empty → re-ask.**

#### Interface-Specific Runtime Strategy

The runtime exploration approach depends on the detected Interface axis:

| Interface | Runtime Strategy | Tool |
|-----------|-----------------|------|
| `gui` (desktop/web) | Playwright browser/Electron automation | Screenshots + accessibility tree |
| `gui` (TUI/terminal) | Terminal recording or manual screenshots | User-assisted capture (P2 Delegate) |
| `http-api` | HTTP request/response capture | curl/fetch probing of endpoints |
| `cli` | Command execution capture | Run CLI commands, capture stdout |
| `library` | Skip runtime (no interactive surface) | Code analysis only |

**For TUI applications** (detected by: Bubble Tea, OpenTUI, Ink, blessed, ncurses, curses dependencies):
- Playwright cannot interact with terminal-rendered UIs
- Present AskUserQuestion:
  "🖥️ TUI application detected. Playwright cannot capture terminal UIs directly."
  Options:
  - "I'll provide terminal screenshots manually"
  - "Skip runtime exploration (code analysis only)"
  - "Run the app — I'll describe what I see"
  **If response is empty → re-ask** (per MANDATORY RULE 1)
- If user provides screenshots: save to `specs/explore/screenshots/` and reference in orientation.md
- If user describes: record as text observations in orientation.md § Runtime Observations

**🚨 MANDATORY: Read the shared runtime modules BEFORE proceeding.**

Read these files NOW (not "follow" or "reference" — actually READ them):
1. `~/.claude/skills/shared/runtime/playwright-detection.md` — READ this file
2. `~/.claude/skills/shared/runtime/data-storage-map.md` — READ this file
3. `~/.claude/skills/shared/runtime/user-assisted-setup.md` — READ this file
4. `~/.claude/skills/shared/runtime/app-launch.md` — READ this file

Then execute the steps defined in those files:

**1. Detect Playwright** (from playwright-detection.md):
   - Result: `RUNTIME_BACKEND` (cli_direct / cli_browser / cdp / mcp_browser / none)
   - If `none` → HARD STOP: ask user to install Playwright or confirm skip

**2. Detect Data Storage** (from data-storage-map.md):
   - Scan source for storage patterns → resolve userData path → determine lock constraints
   - **CRITICAL for Electron apps**: Determine `PLAYWRIGHT_USER_DATA_DIR` — the path where user's settings (API keys, config) are stored. Playwright MUST use this SAME path.

**3. User-Assisted Setup** (from user-assisted-setup.md):
   - Present BLOCKING / PARTIAL / OPTIONAL items with EXACT setup commands
   - For desktop apps: user runs app → configures → **CLOSES app** (LevelDB lock!) → confirms
   - For web apps: user starts server → configures → leaves running → confirms
   - **HARD STOP** — wait for user confirmation. Do NOT proceed without it.

**4. Launch & Capture** (from app-launch.md):
   - **Electron**: `_electron.launch()` with `--user-data-dir=[PLAYWRIGHT_USER_DATA_DIR]`
   - **Web**: connect to user's running server (do NOT start a new one if already running)
   - **Port conflict check**: Before starting a dev server, check if the port is already in use. If occupied by ANOTHER project → ask user to stop it first.
   - Capture screenshots per major route/view → `specs/explore/screenshots/`
   - Record UI structure (accessibility tree per screen)
   - Note interactive patterns (dropdowns, auto-fill, drag zones, modals)

**5. Record results** — add to orientation.md as `## Runtime Observations` section

```
📋 Runtime Exploration Results
  Screens explored: [N]
  Screenshots: specs/explore/screenshots/
  UI patterns: [dropdowns, modals, drag-zones, etc.]
  Setup requirements: [API key → Settings > Provider, etc.]
```

**If Playwright unavailable AND user confirms skip**:
- Display: `⚠️ Runtime exploration skipped. Traces will rely on static code analysis only.`
- Proceed to Step 2

### Step 2 — Module Map

Build a hierarchical module map by analyzing:
- Directory structure (top 2-3 levels)
- Package declarations / module boundaries
- Import relationships between top-level modules
- Public API surfaces (exported functions/types)

For each module, record:
- **Name**: Directory or package name
- **Purpose**: 1-line inferred description
- **Key files**: Top 3-5 most important files (by size, import count, or centrality)
- **Dependencies**: Which other modules it imports from
- **File count**: Number of source files

### Step 3 — Domain Profile Analysis (5 axes + Scale)

Analyze the detected tech stack, architecture patterns, and module structure to infer the **source project's Domain Profile** across all 5 axes + the Scale modifier. This uses the same module vocabulary as smart-sdd's Domain Profile system (see `../../smart-sdd/domains/_resolver.md` § Profile Selection, `../../smart-sdd/domains/_schema.md` § Domain Profile Model).

1. **Interface detection**: Map project characteristics to Interface modules
   - GUI indicators (UI framework, component files, styles) → `gui`
   - HTTP server indicators (router, handlers, middleware) → `http-api`
   - gRPC indicators (`.proto` files, `grpc.NewServer()`, service registration) → `grpc`
   - TCP/UDP server indicators (`net.Listen`, `TcpListener::bind`, `bind()`+`accept()`, raw socket ops) → detect as network server (use closest: `http-api` for L7, note "custom protocol" for L4)
   - WebSocket server indicators (upgrade handler, `ws.on('message')`, WS frame handling) → `http-api` + `realtime` concern
   - Message consumer indicators (`@KafkaListener`, `subscribe()`, consumer group config, no incoming HTTP) → note as message consumer (use `data-io` interface, `message-queue` concern)
   - CLI indicators (flag parsing, command structure) → `cli`
   - TUI indicators (Bubble Tea, ncurses, blessed, Ink) → `tui`
   - Embedded indicators (ISR, RTOS, HAL, register manipulation) → `embedded`
   - Mobile indicators (Flutter, React Native, SwiftUI, Kotlin Android) → `mobile`
   - Library indicators (no entry point, exported API surface only) → `library`
   - **Multi-interface detection**: A project may expose multiple interfaces simultaneously (e.g., HTTP API + gRPC + admin CLI). List ALL detected interfaces, marking the primary one.

2. **Concern detection**: Map cross-cutting patterns to Concern modules
   - Auth files/middleware → `auth`
   - State management (stores, reducers, context) → `async-state`
   - IPC/messaging (channels, events, message passing) → `ipc`
   - i18n files (locales, translations) → `i18n`
   - Database/ORM files → persistence (use `external-sdk` or note in profile)
   - Queue/worker files → `message-queue` or `task-worker`
   - Real-time indicators (WebSocket, SSE, streaming) → `realtime`
   - Connection pool patterns (`pool.Get()`, connection reuse, max-connections config) → `connection-pool`
   - TLS/certificate handling (cert loading, TLS config, SNI) → `tls-management`
   - Circuit breaker/retry/timeout patterns → `resilience`
   - Logging/metrics/tracing (OpenTelemetry, Prometheus, structured logging) → `observability`
   - Graceful shutdown (signal handling, drain connections, health checks) → `graceful-lifecycle`
   - Crypto operations (encryption, hashing, key management) → `cryptography`
   - Plugin loading (dynamic module discovery, plugin interface) → `plugin-system`

3. **Archetype detection**: Infer from project-level patterns
   - AI/LLM integration (provider abstraction, prompt management, token counting) → `ai-assistant`
   - Plugin/extension architecture → `sdk-framework`
   - Microservice indicators (service mesh, service discovery) → `microservice`
   - Network server (accept loop, connection handling, protocol parsing) → `network-server`
   - Proxy/gateway (upstream forwarding, request routing, load balancing) → `network-server` with proxy note
   - Message broker (topic management, consumer groups, message persistence) → `message-broker`
   - Database/cache engine (query parsing, storage engine, indexing) → `database-engine` or `cache-server`
   - Workflow/orchestration (DAG execution, task scheduling, state machines) → `workflow-engine`

4. **Foundation detection** (Axis 4): Identify frameworks from dependency files
   - Read `package.json` dependencies, `go.mod` requires, `Cargo.toml` dependencies, etc.
   - Match against known Foundation files in `../../reverse-spec/domains/foundations/`
   - Record primary framework + notable libraries

5. **Scale inference**: Estimate project maturity and team context from observable signals
   - **Project maturity**: Infer from code characteristics:
     - CI/CD config present + comprehensive tests + monitoring → `production`
     - Tests present but sparse + basic config → `mvp`
     - No tests + minimal config + experimental code patterns → `prototype`
   - **Team context**: Infer from collaboration signals:
     - `.github/CODEOWNERS`, PR templates, multiple git authors → `large-team`
     - Basic PR template, 2-3 git authors → `small-team`
     - Single author, no PR process → `solo`

Record in orientation.md as a structured section (see Step 5 template below).

### Step 4 — Suggested Exploration Topics

Based on the module map, suggest 5-10 exploration topics as concrete questions:

```
Suggested explorations:
1. "How does [main entry point] handle incoming requests?"
2. "How is [largest module] structured internally?"
3. "What is the data flow from [input] to [output]?"
4. "How does [auth/config/db module] manage [its concern]?"
5. "What patterns does [framework-specific module] use?"
```

Order by: entry points first, then core business logic, then infrastructure.

### Step 5 — Generate orientation.md

> **Output path**: Write to `specs/explore/orientation.md` relative to **CWD** (where the user ran the command), NOT the target directory being analyzed. If user runs `/code-explore /other/project` from `~/my-project/`, write to `~/my-project/specs/explore/orientation.md`.

#### Context-Aware Sections

If `CONTEXT_AWARE = true`, add these sections to orientation.md:

```
## Existing SDD Context

| Field | Value |
|-------|-------|
| **Domain Profile** | {from sdd-state.md} |
| **Active Features** | F001: {name} (status), F002: {name} (status), ... |
| **Registered Entities** | {count} entities in entity-registry.md |
| **Registered APIs** | {count} APIs in api-registry.md |
| **Pipeline Stage** | {latest completed stage from sdd-state.md} |

### Exploration Opportunities (not yet covered by SDD)

| Module | In SDD? | Suggested Trace Topic |
|--------|---------|----------------------|
| {module} | ❌ Not covered | "{suggested question}" |
| {module} | 🟡 Partial (F002 spec only) | "{deeper question}" |
```

Write `specs/explore/orientation.md` using the following structure:

```markdown
# Orientation — [Project Name]

> Generated: [timestamp]
> Source: [target path]
> Language: [lang] | Framework: [framework] | Type: [type]

## Architecture Overview

[2-3 sentence summary of what this project does and how it's structured]

` ``mermaid
flowchart TD
    [Module dependency diagram — top-level modules with arrows showing imports]
` ``

## Detected Domain Profile (5 axes + Scale)

> Inferred from source code analysis. Used by synthesis to recommend a Domain Profile for your project.

| # | Axis | Detected | Evidence |
|---|------|----------|----------|
| 1 | **Interfaces** | [e.g., gui(TUI), cli] | [e.g., Bubble Tea TUI framework, cobra CLI] |
| 2 | **Concerns** | [e.g., async-state, ipc] | [e.g., goroutine-based state, LSP protocol] |
| 3 | **Archetype** | [e.g., ai-assistant] | [e.g., LLM provider abstraction, token counting] |
| 4 | **Foundation** | [e.g., Go stdlib] | [e.g., go.mod dependencies] |
| 5 | **Scenario** | [inferred from context] | [e.g., code-explore → likely greenfield for your project] |

| Modifier | Detected | Evidence |
|----------|----------|----------|
| **Project Maturity** | [e.g., production] | [e.g., comprehensive tests, CI/CD, monitoring] |
| **Team Context** | [e.g., small-team] | [e.g., 3 git authors, PR templates present] |

> This profile describes the **source project** you are studying, not the project you will build.
> During `/code-explore synthesis`, this is combined with your "What I'd Do Differently" decisions
> to derive a **recommended Domain Profile for your project** (all 5 axes + Scale).

## Concurrency Model

| Aspect | Detected |
|--------|----------|
| **Model** | [e.g., async/await (tokio), goroutines, thread pool, event loop, actor model] |
| **Per-connection state** | [e.g., each goroutine holds a connection struct] |
| **Shared state** | [e.g., global config, connection pool, session store] |
| **Synchronization** | [e.g., mutex on pool, channels for shutdown, atomic counters] |

> Understanding the concurrency model is critical for tracing server/network programs.
> Traces should annotate which goroutine/task/thread a step runs on.

## Module Map

| Module | Purpose | Key Files | File Count |
|--------|---------|-----------|------------|
| `cmd/` | CLI entry point | main.go | 3 |
| `internal/context/` | Context window management | context.go, token.go, window.go | 8 |
| ... | ... | ... | ... |

## Exploration Coverage

| Module | Traced | Trace # |
|--------|--------|---------|
| `cmd/` | — | |
| `internal/context/` | — | |
| ... | ... | |

> After each trace, update: `—` → `✅` and add trace numbers.
> Example: `| packages/opencode/ | ✅ | 001, 003 |`

## Suggested Explorations

1. [topic suggestion]
2. [topic suggestion]
...

## Trace Index

| # | Topic | Related Modules | Date |
|---|-------|-----------------|------|
| (none yet) | | | |
```

### Step 6 — HARD STOP

**First, tell the user where to find the full orientation document:**

```
✅ Orientation complete!
📄 Full document: specs/explore/orientation.md
   → Module map, Domain Profile, architecture diagram, suggested topics
```

Then present options via AskUserQuestion:

- **"Start exploring (Recommended)"** → Display the suggested explorations and wait for the user to pick one or type their own topic
- **"Review module map"** → User opens `specs/explore/orientation.md` to review. Agent waits for corrections if any.
- **"Re-scan with different path"** → User specifies a different target directory

**If response is empty → re-ask** (per MANDATORY RULE).

---

## Update Mode (`--update`)

When invoked with `--update`:

1. Re-scan the target directory for new files/directories since last orientation
2. Compare with existing `orientation.md` module map
3. For new modules discovered:
   - Add to Module Map table
   - Add to Exploration Coverage as `—` (not yet traced)
   - Display: `🆕 New module discovered: [name] — [N] files`
4. For modules that no longer exist:
   - Mark as `(removed)` in Module Map (don't delete — traces may reference them)
5. Update file counts for all modules

---

## Post-Trace Auto-Update (MANDATORY — called from trace.md Step 5)

After every trace completion, update `orientation.md` with these **specific edits**:

### 1. Update Exploration Coverage table

Read the new trace's Flow table → identify which modules were touched.

Mark each module as **traced or not** — no percentage calculation:

```
Before:
  | packages/opencode/ | — |
  | packages/app/      | — |

After:
  | packages/opencode/ | ✅ 001, 003 |
  | packages/app/      | ✅ 002 |
  | packages/ui/       | — |
```

Simply list which trace numbers touched each module. Users see "what I've explored" and "what I haven't" at a glance.

### 2. Add trace to Trace Index table

```
Before: | (none yet) | | | |
After:  | 001 | codebase-context-management | packages/opencode/ | 2026-03-20 |
```

### 3. Add new modules if discovered

If the trace referenced files in a directory not in the Module Map, add a new row.

> 🚨 **This step is NOT optional.** If orientation.md is not updated after a trace, the user sees stale data and cannot tell which modules are unexplored.
