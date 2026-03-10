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

- If `**Domain Profile**` is a profile name (e.g., `desktop-app`): read `domains/profiles/{name}.md` to expand into interfaces + concerns
- If `**Interfaces**` and `**Concerns**` are already explicit: use directly
- **Scenario** is determined by the `**Origin**` field in sdd-state.md:
  - `greenfield` → `scenarios/greenfield.md`
  - `rebuild` → `scenarios/rebuild.md`
  - `adoption` → `scenarios/adoption.md`
  - If Origin is `rebuild` or `greenfield` and project already has Features: `scenarios/incremental.md` for subsequent additions

### Step 3. Load Modules in Order

```
1. domains/_core.md                              (ALWAYS — universal rules)
2. domains/interfaces/{interface}.md              (for EACH listed interface)
3. domains/concerns/{concern}.md                  (for EACH listed concern)
4. domains/scenarios/{scenario}.md                (ONE scenario)
5. {Custom path}/domain-custom.md                 (if specified and file exists)
```

**Merge rule**: Later modules extend earlier ones. For same-section content:
- **S5 Elaboration Probes**: Append (accumulate all probes)
- **S1 SC Rules**: Append (accumulate all rules)
- **S7 Bug Prevention**: Append (accumulate all activation conditions)
- **S2 Parity Dimensions**: Append (add module-specific dimensions)
- **S3 Verify Steps**: Override only if module explicitly overrides (otherwise inherit _core)

### Step 4. Cache in Working Memory

Once loaded, the merged domain profile is used for the entire command session. No need to re-read module files mid-command.

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

When no Domain Profile exists yet (first-time setup):

1. **Auto-detection**: Scan project for signals:
   - `package.json` + `src/pages/` or `src/app/` → likely `fullstack-web`
   - `Cargo.toml` + `src/main.rs` without UI → likely `cli-tool` or `web-api`
   - Electron indicators (`electron`, `electron-builder` in dependencies) → likely `desktop-app`
2. **User confirmation**: Present detected profile via AskUserQuestion
3. **User can specify** `--profile` argument to override auto-detection
4. Write Domain Profile to sdd-state.md

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

### S0 Aggregation

During inference, the agent reads S0 sections from all modules to build the signal vocabulary:

```
domains/interfaces/gui.md       → S0.Primary: ["React", "Vue", ...]
domains/interfaces/http-api.md  → S0.Primary: ["REST", "Express", ...]
domains/concerns/auth.md        → S0.Primary: ["JWT", "OAuth", ...]
...
```

This is a one-time scan at init start. Results are cached for the duration of the init command.
