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

### Step 3 — Suggested Exploration Topics

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

### Step 4 — Generate orientation.md

Write `specs/explore/orientation.md` using the following structure:

```markdown
# Orientation — [Project Name]

> Generated: [timestamp]
> Source: [target path]
> Language: [lang] | Framework: [framework] | Type: [type]

## Architecture Overview

[2-3 sentence summary of what this project does and how it's structured]

```mermaid
flowchart TD
    [Module dependency diagram — top-level modules with arrows showing imports]
```

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

### Step 5 — HARD STOP

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
