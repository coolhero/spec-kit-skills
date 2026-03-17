# Domain Module Resolution Protocol

> Defines how the agent loads domain modules for the current project.
> Read this file once at skill invocation (referenced from SKILL.md § Domain Profile).

---

## Resolution Steps

### Step 1. Read Domain Profile from sdd-state.md

Look for the Domain Profile fields in `sdd-state.md` header:

```
**Domain Profile**: <profile-name>
**Interfaces**: <comma-separated list>
**Concerns**: <comma-separated list>
**Scenario**: <greenfield | rebuild | incremental | adoption>
**Custom**: <path to domain-custom.md or "none">
```

### Step 2. Resolve Profile (if needed)

- If `**Domain Profile**` is a profile name (e.g., `desktop-app`): read `domains/profiles/{name}.md` to expand into interfaces + concerns (+ archetype if profile specifies one, e.g., `sdk-library` → `sdk-framework`)
- If `**Interfaces**` and `**Concerns**` are already explicit: use directly
- **Scenario** is determined by the `**Origin**` field in sdd-state.md:
  - `greenfield` → `scenarios/greenfield.md`
  - `rebuild` → `scenarios/rebuild.md`
  - `adoption` → `scenarios/adoption.md`
  - If Origin is `rebuild` or `greenfield` and project already has Features: `scenarios/incremental.md` for subsequent additions

### Step 2b. Resolve Foundation

1. Read `**Framework**` from sdd-state.md header
2. If framework is "custom" or "none" → skip Foundation loading
3. For each framework (comma-separated):
   - Load `../../reverse-spec/domains/foundations/{framework}.md` § F2 (items only)
   - Load `../../reverse-spec/domains/foundations/_foundation-core.md` § F3 (T0 rules)
4. Cache Foundation items for session

### Step 2c. Resolve Archetype

1. Read `**Archetype**` from sdd-state.md header (comma-separated list or `"none"`)
2. If `"none"` or field is missing → skip archetype loading
3. For each archetype name:
   - Load `domains/archetypes/{name}.md`
   - Validate: file must have at least A0 and A1 sections
4. Multiple archetypes are allowed (comma-separated) — merge by append

**When Archetype field is missing** (backward compatibility):
- Treat as `"none"` — no archetypes loaded
- Do NOT write the field retroactively (only set during init/pipeline Phase 0)

### Step 2d. Resolve Organization Conventions (optional)

Organization-level conventions provide shared rules that apply across all projects in an organization. Unlike `domain-custom.md` (project-specific), org conventions are reusable and versioned.

1. Read `**Org Convention**` from sdd-state.md header (path or `"none"`)
2. If `"none"` or field is missing → skip org convention loading
3. Resolution order:
   a. If path is absolute → load directly
   b. If path is relative → resolve from CWD
   c. If path starts with `~` → expand home directory (e.g., `~/.claude/domain-conventions/my-org.md`)
4. Validate: file must be valid markdown with at least one S-section or A-section
5. Org conventions are loaded AFTER archetypes but BEFORE scenarios, allowing them to override archetype defaults while respecting scenario-specific rules

**Typical org convention file structure**:
```markdown
# Org Convention: {org-name}

> Organization-specific coding standards and architectural patterns.
> Version: 1.0.0

## S1. SC Generation Rules (org overrides)
[Org-specific SC patterns — e.g., "all APIs must return standard error envelope"]

## S7. Bug Prevention Rules (org additions)
[Org-specific anti-patterns — e.g., "never use ORM lazy loading in API endpoints"]

## Custom Rules
[Any org-specific rules not covered by S-sections]
```

**When Org Convention field is missing** (backward compatibility):
- Treat as `"none"` — no org conventions loaded
- Do NOT write the field retroactively (only set during init)

### Step 3. Load Modules in Order

```
1. domains/_core.md                              (ALWAYS — universal rules)
2. domains/interfaces/{interface}.md              (for EACH listed interface)
3. domains/concerns/{concern}.md                  (for EACH listed concern)
4. domains/archetypes/{archetype}.md              (for EACH listed archetype)
5. {Org convention path}/org-convention.md        (if specified and file exists)
6. domains/scenarios/{scenario}.md                (ONE scenario)
7. {Custom path}/domain-custom.md                 (if specified and file exists)
```

> **Signal Keywords resolution**: Each module's S0/A0 section references `shared/domains/` for signal keywords. During S0/A0 aggregation (init inference), read keywords from `../../shared/domains/{type}/{name}.md § Signal Keywords` instead of the skill-local module. See `shared/domains/_taxonomy.md` for the complete module registry.

**Merge rule**: Later modules extend earlier ones. For same-section content (summary — 5 of 15 rules):
- **S1 SC Rules**: Append (accumulate all rules)
- **S2 Parity Dimensions**: Append (add module-specific dimensions)
- **S3 Verify Steps**: Override only if module explicitly overrides (otherwise inherit _core)
- **S5 Elaboration Probes**: Append (accumulate all probes)
- **S7 Bug Prevention**: Append (accumulate all activation conditions)

> See `_schema.md` § Section Merge Rules for the complete merge rule table (15 rules covering S0–S9, A0–A5).

### Step 4. Cache in Working Memory

Once loaded, the merged domain profile is used for the entire command session. No need to re-read module files mid-command.

---

## Worked Example: `desktop-app` Rebuild with Electron

Traces the full resolution chain for a project with:
- **Domain Profile**: `desktop-app` | **Origin**: `rebuild` | **Framework**: `electron` | **Archetype**: `ai-assistant` | **Org Convention**: `none` | **Custom**: `none`

### Step 1 → 2: Profile Expansion

`domains/profiles/desktop-app.md` expands to:
- **Interfaces**: `[gui]`
- **Concerns**: `[async-state, ipc]`
- **Scenario**: Origin `rebuild` → `scenarios/rebuild.md`

### Step 2b: Foundation

Framework `electron` → Load:
- `../../reverse-spec/domains/foundations/electron.md` § F2 (58 items across 13 categories)
- `../../reverse-spec/domains/foundations/_foundation-core.md` § F3 (T0 grouping rules)

### Step 2c: Archetype

Archetype `ai-assistant` → Load:
- `domains/archetypes/ai-assistant.md` (A0–A4: Streaming-First, Model Agnosticism, etc.)

### Step 3: Module Loading (6 files)

| # | File Loaded | Sections Contributed |
|---|-------------|----------------------|
| 1 | `domains/_core.md` | S1 base SC rules, S2 base parity, S3 verify steps (test/build/lint/demo), S5 universal probes (auth/CRUD/validation/pagination/file + middleware + concurrency/cache/observability), S7 base B-1/B-2/B-3 |
| 2 | `domains/interfaces/gui.md` | S1 +UI interaction SCs, S2 +UI component/layout parity, S5 +routing/UI completeness/responsive probes, S6 UI testing (new), S7 +CSS rendering/UI surface audit, S8 runtime verification strategy (new) |
| 3 | `domains/concerns/async-state.md` | S1 +state transition/async flow SCs, S5 +state library/async pattern/subscription probes, S7 +selector instability/unbatched updates/UX behavior contract |
| 4 | `domains/concerns/ipc.md` | S1 +IPC call/process lifecycle SCs, S5 +IPC channel/error/security probes, S7 +IPC boundary safety/return value defense |
| 5 | `domains/archetypes/ai-assistant.md` | A1 philosophy principles (Streaming-First, Model Agnosticism, etc.), A2 +AI-specific SC rules, A3 +model/streaming/prompt probes, A4 constitution principles |
| 6 | `domains/scenarios/rebuild.md` | S1 +preservation SCs, S3 extends (migration regression gate) + S3d Foundation Compliance, S5 +source comparison/preservation probes, S7 +migration-specific rules |

### Step 4: Merged Result

After merge, the cached profile contains:

| Section | Sources (merge order) |
|---------|----------------------|
| **S1** SC Rules | _core → gui → async-state → ipc → rebuild (appended) |
| **S2** Parity | _core structural+logic → gui +UI component/layout (appended) |
| **S3** Verify | _core test/build/lint/demo → rebuild migration gate + S3d Foundation (extended) |
| **S5** Probes | _core 5 perspectives → gui routing/UI → async-state state/async → ipc channels/security → ai-assistant model/streaming/prompt → rebuild source/preservation (appended) |
| **S6** UI Testing | gui only (new section) |
| **S7** Bug Prevention | _core B-3 base → gui CSS/UI audit → async-state selector/unbatched → ipc boundary/return → rebuild migration (appended) |
| **S8** Runtime | gui only (new section) |
| **A1** Philosophy | ai-assistant (Streaming-First, Model Agnosticism, Offline Resilience, Token Awareness, Prompt Versioning) |
| **A2** SC Extensions | ai-assistant (AI-specific SC rules — appended to S1) |
| **A3** Probes | ai-assistant (model/streaming/prompt probes — appended to S5) |
| **A4** Constitution | ai-assistant (AI-specific constitution principles) |

**Total reads at session start**: 6 domain modules + 2 Foundation files = 8 file reads, then cached.

---

## Backward Compatibility

### Legacy `**Domain**: app` format

If sdd-state.md contains `**Domain**: app` (old format) without `**Domain Profile**`:

1. Read `domains/app.md` — it is a backward-compatibility shim
2. The shim specifies the default expansion (equivalent to `fullstack-web` profile)
3. Write the expanded Domain Profile fields to sdd-state.md (one-time migration)
4. Proceed with Step 3 (module loading) as normal

### `--domain` argument

If user passes `--domain app`, treat it as `--profile fullstack-web` (default expansion).
If user passes `--profile <name>`, read the named profile from `domains/profiles/{name}.md`.

---

## When to Read This File

- At every smart-sdd command invocation (after argument parsing, before command execution)
- At every reverse-spec invocation (after argument parsing, before Phase 1)
- For reverse-spec: the same resolution applies, but modules are read from `reverse-spec/domains/` (which have R-sections for analysis)

---

## Profile Selection (during init or reverse-spec)

When no Domain Profile exists yet (first-time setup), the detection method depends on the scenario:

### Brownfield / Adoption (existing codebase)

1. **File-system scanning**: Scan project files for R1 code pattern signals:
   - `package.json` + `src/pages/` or `src/app/` → likely `fullstack-web`
   - `Cargo.toml` + `src/main.rs` without UI → likely `cli-tool` or `web-api`
   - Electron indicators (`electron`, `electron-builder` in dependencies) → likely `desktop-app`
2. **User confirmation**: Present detected profile via AskUserQuestion

### Greenfield (no existing code)

1. **S0/A0 keyword inference**: Extract signals from the user's text description (idea string or PRD) and match against S0/A0 signal keywords from `shared/domains/` modules. See § Greenfield Inference below for the full algorithm.
2. **User confirmation**: Present inferred profile via AskUserQuestion (HARD STOP)

### Common

- **User can specify** `--profile` argument to override auto-detection or inference
- Both paths produce the same Domain Profile format written to sdd-state.md

---

## Greenfield Inference (during init Proposal Mode)

When `init` is invoked with an idea string or PRD (Proposal Mode), Domain Profile is inferred from user input before any sdd-state.md exists. This extends Profile Selection with signal-based inference.

> Full specification: `reference/clarity-index.md`

### Inference Steps

```
1. Extract signals from user input (idea string / PRD text)
2. Read S0 Signal Keywords from ALL interface and concern modules
3. Match signals against S0 keywords:
   - Primary keyword match (≥ 1) → activate module
   - Secondary keyword match only → flag for confirmation
4. Build candidate Domain Profile:
   - Interfaces: all activated interface modules
   - Concerns: all activated concern modules
   - Flagged: modules needing confirmation
5. Calculate per-axis confidence (0–3)
6. Write to Proposal (displayed for user approval at HARD STOP)
```

### Merge with Profile Selection

- If user also passes `--profile`: profile takes precedence, inference results are used only to fill gaps
- If no `--profile` and inference yields high confidence: present inferred profile directly
- If inference yields low confidence: present as suggestions with "Other" option

### S0/A0 Aggregation

> Full matching algorithm, S0/A0 aggregation rules, and archetype inference: See `reference/clarity-index.md` § 3 (Matching Algorithm), § 5 (S0/A0 Aggregation Rules).

During inference, the agent reads signal keywords from `shared/domains/` to build the vocabulary:
- **S0**: `shared/domains/interfaces/*.md` + `shared/domains/concerns/*.md` → Interface/Concern signal maps
- **A0**: `shared/domains/archetypes/*.md` → Archetype signal map (runs in parallel with S0)

> **Module registry**: `shared/domains/_taxonomy.md` lists all available modules.

Both S0 and A0 are one-time scans at init start. Results are cached for the duration of the init command.
