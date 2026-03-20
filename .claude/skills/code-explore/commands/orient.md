# Orient — Codebase Orientation

> Reference: Read after `/code-explore [path]` or `/code-explore --update` is invoked.

## Purpose

Scan a codebase and generate a high-level architecture map that serves as the navigation foundation for all subsequent trace explorations. The orientation document is a **living document** — updated automatically after each trace and manually via `--update`.

---

## Initial Orientation (first run)

### Step 1 — Project Detection

Scan the target directory to identify:

1. **Language & Framework**: Detect from project markers (`package.json`, `go.mod`, `Cargo.toml`, `pyproject.toml`, `pom.xml`, etc.)
2. **Project type**: CLI, web app, library, desktop app, API server, etc.
3. **Entry points**: `main`, `index`, `app`, `server` files
4. **Package/module structure**: Top-level directories and their apparent purpose

Display a brief summary:
```
📦 Project: [name] ([language] / [framework])
   Type: [project type]
   Entry: [main entry point(s)]
   Size: [N] files, [M] directories
```

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
   - CLI indicators (flag parsing, command structure) → `cli`
   - Library indicators (no entry point, exported API surface only) → `library`

2. **Concern detection**: Map cross-cutting patterns to Concern modules
   - Auth files/middleware → `auth`
   - State management (stores, reducers, context) → `async-state`
   - IPC/messaging (channels, events, message passing) → `ipc`
   - i18n files (locales, translations) → `i18n`
   - Database/ORM files → `persistence`
   - Queue/worker files → `message-queue` or `task-worker`
   - Real-time indicators (WebSocket, SSE, streaming) → `realtime`

3. **Archetype detection**: Infer from project-level patterns
   - AI/LLM integration (provider abstraction, prompt management, token counting) → `ai-assistant`
   - Plugin/extension architecture → `sdk-framework`
   - Microservice indicators (service mesh, service discovery) → `microservice`

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

## Module Map

| Module | Purpose | Key Files | File Count |
|--------|---------|-----------|------------|
| `cmd/` | CLI entry point | main.go | 3 |
| `internal/context/` | Context window management | context.go, token.go, window.go | 8 |
| ... | ... | ... | ... |

## Exploration Coverage

| Module | Coverage | Traces |
|--------|----------|--------|
| `cmd/` | ░░░░░░░░░░ 0% | — |
| `internal/context/` | ░░░░░░░░░░ 0% | — |
| ... | ... | ... |

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

Present the orientation summary to the user via AskUserQuestion:

- **"Looks good — start exploring"** → Display the suggested explorations and wait for the user to pick one or type their own topic
- **"Adjust module map"** → User provides corrections (missed modules, wrong purpose). Agent updates orientation.md and re-presents.
- **"Re-scan with different path"** → User specifies a different target directory

**If response is empty → re-ask** (per MANDATORY RULE).

---

## Update Mode (`--update`)

When invoked with `--update`:

1. Re-scan the target directory for new files/directories since last orientation
2. Compare with existing `orientation.md` module map
3. For new modules discovered:
   - Add to Module Map table
   - Add to Exploration Coverage with 0%
   - Display: `🆕 New module discovered: [name] — [N] files`
4. For modules that no longer exist:
   - Mark as `(removed)` in Module Map (don't delete — traces may reference them)
5. Update file counts for all modules

---

## Post-Trace Auto-Update

After every trace completion (called from trace.md):

1. Read the trace document to identify which modules were touched
2. Update Exploration Coverage percentages:
   - Count unique files referenced in traces for each module
   - Coverage = (files traced / total files in module) × 100%
   - Update progress bar
3. Add the trace to the Trace Index table
4. If trace discovered files in a module not in the Module Map → add it (same as `--update` discovery)
