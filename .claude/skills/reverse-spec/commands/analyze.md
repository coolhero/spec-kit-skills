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

### Explore-Enhanced Mode (`--from-explore <path>`)

When `--from-explore` is provided, reverse-spec uses code-explore artifacts as **supplementary context** — enhancing (not replacing) its own analysis.

**Pre-Phase: Read Explore Artifacts**
1. Verify `{path}/synthesis.md` exists → if missing, warn and proceed without explore context
2. Read Domain Profile from synthesis § Recommended Domain Profile → use as initial hypothesis (Phase 1 confirms or overrides)
3. Read Entity/API Consolidation → cross-reference during Phase 2 (explore-sourced entities validate extraction completeness)
4. Read Feature Candidates (C###) → seed Phase 3 boundary detection hypothesis (code analysis may reveal different boundaries)
5. Read Accumulated Insights → enrich Phase 4 pre-context with user observations

**Per-Phase Enrichment**:
| Phase | How Explore Artifacts Help |
|-------|--------------------------|
| 1 (Scan) | Domain Profile hypothesis → confirm/refine tech stack detection faster |
| 2 (Deep) | Entity/API maps → cross-validate extraction completeness (flag missed entities) |
| 3 (Classify) | Feature candidates → seed boundary hypothesis (reduce classification ambiguity) |
| 4 (Generate) | Insights + business rules → enrich pre-context.md with human-validated observations |

Explore context is **advisory, not authoritative** — if code analysis contradicts explore findings, code analysis wins (source code is ground truth).

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
Check if `case-study-log.md` exists at **CWD root** (the project being built, NOT the target/source directory being analyzed):
- **If not exists**: Read [`case-study-log-template.md`](../../case-study/templates/case-study-log-template.md) and write it to `./case-study-log.md` (CWD root). Populate header fields: `**Archetype**: none`, `**Framework**: none` (these will be updated in-place after Phase 1-2b framework detection and Phase 3-1e archetype detection). Display: `📝 Case study log initialized: ./case-study-log.md`
- **If already exists**: Skip silently (user may have manually initialized earlier)

> ⚠️ **Path warning**: The case-study-log.md MUST be at CWD root (`./case-study-log.md`), NOT inside the target directory or `specs/_global/`. The target directory is the source code being analyzed (read-only). All outputs go to CWD.

📝 **Case Study Recording**: Append milestone entry to `./case-study-log.md` (CWD root) per [recording-protocol.md](../../case-study/reference/recording-protocol.md) § M1.

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


---

## Phase Execution — Read Phase File Before Each Phase

Each Phase is in a separate file. **Read the file BEFORE executing that Phase.**

| Phase | File | Purpose | Lines |
|-------|------|---------|-------|
| **1** | [analyze-scan.md](analyze-scan.md) | Project scan — tech stack, entry points, modules | ~150 |
| **1.5** | [analyze-runtime.md](analyze-runtime.md) | Runtime exploration — run source app, capture UI flows (🚫 BLOCKING for rebuild; adopt mode: optional HARD STOP for GUI projects, skip for non-GUI) | ~780 |
| **2** | [analyze-deep.md](analyze-deep.md) | Deep analysis — data models, APIs, SBI, business logic | ~445 |
| **3** | [analyze-classify.md](analyze-classify.md) | Feature classification — tier, dependencies, demo groups | ~358 |
| **4** | [analyze-generate.md](analyze-generate.md) | Artifact + spec-draft generation — roadmap, registries, pre-context, spec-draft | ~585 |

> 🚨 **MANDATORY**: Read the Phase file at the START of each Phase. Do NOT rely on memory from reading the hub file.
> Each Phase file contains the complete, detailed procedure for that Phase.
>
> ```
> ❌ WRONG: Read analyze.md once → execute all Phases from memory
>    → Phase 4 spec-draft generation skipped because agent forgot the rules
>
> ✅ RIGHT: Phase 1 → read analyze-scan.md → execute → Phase 1.5 → read analyze-runtime.md → execute → ...
>    → Each Phase's rules are fresh in context when executed
> ```

**Execution order**: Phase 0 (above) → Phase 1 → Phase 1.5 → Phase 2 → Phase 3 → Phase 4

After Phase 4 completes, the Completion Report and git checkpoint are in [analyze-generate.md](analyze-generate.md) § 4-4 and § 4-5.
