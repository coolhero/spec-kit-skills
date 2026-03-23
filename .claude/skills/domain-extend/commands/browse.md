# Browse — Explore the Domain Module System

> Reference: Read after `/domain-extend browse` is invoked.

## Purpose

Interactive exploration of the 5-axis domain module system. Shows module inventory, section summaries, file paths, and cross-concern integration rules. Every display includes file paths so users can open and edit modules directly.

---

## Browse Modes

### Mode 1: System Overview (no arguments)

**Trigger**: `/domain-extend browse`

**Steps**:

1. Read `shared/domains/_taxonomy.md`
2. Count modules per axis by scanning each table
3. Display system summary:

```
Domain Module System Overview

| Axis | Modules | Path |
|------|---------|------|
| Interfaces | {N} | .claude/skills/shared/domains/interfaces/ |
| Concerns | {N} | .claude/skills/shared/domains/concerns/ |
| Archetypes | {N} | .claude/skills/shared/domains/archetypes/ |
| Foundations | {N} | .claude/skills/shared/domains/foundations/ |
| Contexts | {N} | .claude/skills/shared/domains/contexts/ |
| **Total** | **{sum}** | |

Template: .claude/skills/shared/domains/_TEMPLATE.md
Taxonomy: .claude/skills/shared/domains/_taxonomy.md
```

4. Ask via AskUserQuestion:
   - **"Browse a specific axis"** → proceed to Mode 2
   - **"Search by keyword"** → proceed to Mode 3
   - **"Show active modules"** → proceed to Mode 6
   - **"Done"** → exit

**If response is empty → re-ask** (per MANDATORY RULE 1)

**Manual alternative**: `cat .claude/skills/shared/domains/_taxonomy.md`

---

### Mode 2: Category Listing (browse <axis>)

**Trigger**: `/domain-extend browse concerns` (or interfaces, archetypes, foundations, contexts)

**Steps**:

1. Read `_taxonomy.md` → extract the matching axis table
2. For each module in the table, display:

```
{Axis}: {N} modules

| Module | Description | File | Pairings |
|--------|-------------|------|----------|
| auth | Authentication flows (JWT, OAuth, session) | concerns/auth.md | http-api |
| async-state | Reactive state management patterns | concerns/async-state.md | gui |
| ... | ... | ... | ... |
```

3. If `--full` flag is set: for each module, also read the file and show § Signal Keywords (S0 Primary)

4. Ask via AskUserQuestion:
   - **"View module details"** → read and display full module content
   - **"Back to overview"** → return to Mode 1
   - **"Done"** → exit

**If response is empty → re-ask** (per MANDATORY RULE 1)

**Manual alternative**: `ls .claude/skills/shared/domains/{axis}/`

---

### Mode 3: Keyword Search (browse "keyword")

**Trigger**: `/domain-extend browse "realtime"` or `/domain-extend browse "websocket"`

**Steps**:

1. Glob all `.md` files under `shared/domains/` (excluding `_taxonomy.md`, `_TEMPLATE.md`, `_schema.md`, `_resolver.md`)
2. Search each file for the keyword in:
   - S0 Primary keywords
   - S0 Secondary keywords
   - Module name
   - Description line
   - R1 Code Patterns
3. Rank results by match location (S0 Primary > name > description > S0 Secondary > R1)
4. Display:

```
Search: "{keyword}" — {N} matches

| # | Module | Match Location | File |
|---|--------|---------------|------|
| 1 | realtime | S0 Primary: "websocket, SSE, live" | concerns/realtime.md |
| 2 | wire-protocol | R1 Code Pattern: "ws.on('message')" | concerns/wire-protocol.md |
| 3 | gui | S0 Secondary: "real-time updates" | interfaces/gui.md |
```

5. Ask via AskUserQuestion:
   - **"View module [N]"** → read and display that module
   - **"Search again"** → prompt for new keyword
   - **"Done"** → exit

**If response is empty → re-ask** (per MANDATORY RULE 1)

**Manual alternative**: `grep -rl "keyword" .claude/skills/shared/domains/`

---

### Mode 4: Profile Expansion (browse profile <name>)

**Trigger**: `/domain-extend browse profile ai-assistant`

**Steps**:

1. Read `shared/domains/archetypes/{name}.md` (or search by name across axes)
2. Extract the `Common pairings` field from Module Metadata
3. For each paired module, read its file to get its pairings (transitive expansion)
4. Display: archetype → paired concerns → their transitive pairs → deduplicated full activation set with file paths
5. Note: This shows what WOULD activate, not what IS active. For active modules, use `browse --active`.

**Manual alternative**: Open the archetype file, follow `Common pairings` links manually.

---

### Mode 5: Cross-Concern Rules (browse rules <combo>)

**Trigger**: `/domain-extend browse rules gui+async-state` or `/domain-extend browse rules auth+authorization`

**Steps**:

1. Parse the combo string (split on `+`)
2. Read each module file
3. Check for cross-concern sections:
   - Look for references to the other module(s) in each file
   - Check `_taxonomy.md` Common Pairings column for the combination
4. Display:

```
Cross-Concern Rules: gui + async-state

From gui.md:
  → Pairs with async-state for reactive UI state binding
  → [relevant section excerpts]

From async-state.md:
  → Pairs with gui for component-level state subscriptions
  → [relevant section excerpts]

Common Pairings (from _taxonomy.md):
  gui ↔ async-state: "async-state, ipc (Electron/Tauri)"

File paths:
  .claude/skills/shared/domains/interfaces/gui.md
  .claude/skills/shared/domains/concerns/async-state.md
```

**Manual alternative**: Open both module files side-by-side and search for cross-references.

---

### Mode 6: Active Modules (browse --active)

**Trigger**: `/domain-extend browse --active`

**Steps**:

1. Read `specs/_global/sdd-state.md`
   - If not found → display: `No sdd-state.md found. Run /smart-sdd init first to set up a Domain Profile.`
   - Exit
2. Extract `**Domain Profile**:` section → parse active modules per axis
3. For each active module, read its file and extract:
   - Description
   - S0 Primary keywords
   - Per-command sections (if any — specify, plan, implement, verify sections)
4. Display:

```
Active Domain Profile (from sdd-state.md)

| # | Axis | Module | Per-Command Sections | File |
|---|------|--------|---------------------|------|
| 1 | Interface | gui | specify(3), plan(2), implement(4) | interfaces/gui.md |
| 2 | Concern | async-state | specify(2), plan(1), implement(3) | concerns/async-state.md |
| 3 | Concern | auth | specify(4), plan(2), implement(5) | concerns/auth.md |
| 4 | Archetype | ai-assistant | specify(2), plan(3), implement(2) | archetypes/ai-assistant.md |

(N) = number of rules/items in that command's section
```

5. Ask via AskUserQuestion:
   - **"View module details"** → read and display full module
   - **"Detect gaps"** → chain to `/domain-extend detect`
   - **"Done"** → exit

**If response is empty → re-ask** (per MANDATORY RULE 1)

**Manual alternative**: Read `sdd-state.md` Domain Profile section, then open each listed module file.
