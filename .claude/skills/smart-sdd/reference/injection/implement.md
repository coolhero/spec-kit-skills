# Context Injection: Implement

> Per-command injection rules for `/smart-sdd implement [FID]`.
> For shared patterns (HARD STOP, Checkpoint, Missing/Sparse Content Handling), see [context-injection-rules.md](../context-injection-rules.md).

---

## Read Targets

| File | Section | Filtering |
|------|---------|-----------|
| `SPEC_PATH/[NNN-feature]/tasks.md` | Entire file | Current Feature |
| `SPEC_PATH/[NNN-feature]/quickstart.md` | Entire file | **If exists** — run instructions for the Feature |
| `BASE_PATH/features/[FID]-[name]/pre-context.md` | "Static Resources" section | **If present and non-empty** |
| `BASE_PATH/features/[FID]-[name]/pre-context.md` | "Environment Variables" section | **If present and non-empty** |
| `BASE_PATH/features/[FID]-[name]/pre-context.md` | "Naming Remapping" section | **If present (project identity changed)** |
| `SPEC_PATH/[NNN-feature]/plan.md` | "Pattern Constraints" section | **If present** — inject as mandatory reference for every task execution |
| `SPEC_PATH/[NNN-feature]/plan.md` | "Interaction Chains" section | **If present (UI Features)** — inject chain propagation context for each task |
| `SPEC_PATH/[NNN-feature]/plan.md` | "UX Behavior Contract" section | **If present (async UI Features)** — inject temporal UX expectations for each task |
| `SPEC_PATH/[NNN-feature]/plan.md` | "API Compatibility Matrix" section | **If present (multi-provider)** — inject per-provider contracts for each task |
| `specs/reverse-spec/visual-references/manifest.md` | Relevant screens | **Rebuild mode only, if exists** — inject as visual target reference |
| `BASE_PATH/features/[FID]-[name]/pre-context.md` | "Source Reference" section | **Rebuild/adoption mode only** (Source Path ≠ N/A). Resolve file paths per specify.md Source Reference Path Resolution rules |
| `specs/reverse-spec/visual-references/style-tokens.md` | Entire file | **Rebuild mode only, if exists** — inject as CSS reference for matching original styles |

## Pattern Constraints Injection

If plan.md contains a `## Pattern Constraints` section, this section MUST be included in the context for **every** `speckit-implement` task execution. This is critical when tasks are executed by parallel agents or across context window boundaries — each agent must receive the Pattern Constraints to maintain consistency.

Display before each task: `📋 Pattern Constraints (from plan.md): [constraint count] constraints active`

This prevents the scenario where parallel agents independently generate code with inconsistent patterns (e.g., one agent uses stable selectors while another creates new arrays per selector call).

## Parallel Agent File Ownership Injection

When the implement Checkpoint plan includes parallel agents, inject the file ownership partition into each agent's prompt:

1. **Per-agent scope**: Each agent receives ONLY its assigned file list — no visibility into other agents' files
2. **Shared file exclusion**: Explicitly state which files are reserved for post-agent integration (e.g., "Do NOT create or modify [entry-point]. The main agent will integrate your exports after completion")
3. **Export convention**: Each agent must export its public API from a barrel file or explicit export list, enabling the main agent to integrate without reading all agent code

See `commands/pipeline.md` § Parallel Agent File Ownership for the full protocol.

## Interaction Chains Injection (UI Features)

If plan.md contains an `## Interaction Chains` section, inject the relevant chain rows for each task. When a task implements a handler (e.g., `onThemeChange`), the agent MUST also implement the full chain: Store Mutation → DOM Effect → Visual Result — not just the handler function.

Display before each UI-related task: `📋 Interaction Chains: [N] chains active — implement full propagation (Handler → Store → DOM → Visual)`

For tasks implementing `async-flow:` rows, the agent MUST implement the full temporal sequence: loading state → streaming updates → completion → error recovery → cleanup.

## UX Behavior Contract Injection (async UI Features)

If plan.md contains a `## UX Behavior Contract` section, inject the contract rows for each task that involves async operations (streaming, loading, API calls). The agent MUST implement the Expected Behavior described in the contract — not just the functional handler.

Display before each async-related task: `📋 UX Behavior Contract: [N] scenarios — implement temporal behavior (loading, streaming, error recovery, cleanup)`

## API Compatibility Matrix Injection (multi-provider Features)

If plan.md contains an `## API Compatibility Matrix` section, inject the full matrix for each task that involves API integration. The agent MUST follow the specific provider's row (auth method, endpoint, headers, response format) — NOT apply one provider's pattern to all.

Display before each API-related task: `📋 API Compatibility Matrix: [N] providers — follow per-provider contracts (auth, endpoints, response format)`

## Source Reference Injection (rebuild/adoption mode) — BLOCKING for rebuild+GUI

> Guard 1: Guideline → Gate Escalation. Source Reference Injection is a BLOCKING gate
> (not a guideline) because its violation causes Major+ quality regression in rebuild projects.
> See pipeline-integrity-guards.md § Guard 1.
>
> Guard 3: Cross-Stage Trust Breakers — Gate 2 (implement entry). Read Interaction Surface
> Inventory + analyze source layout structure independently — do not blindly trust previous
> stage assumptions about runtime defaults or UI structure.
> See pipeline-integrity-guards.md § Guard 3.
>
> Guard 7: Rebuild Fidelity Chain. Source-First: read source BEFORE writing code.
> Source structure is a first-class artifact at every pipeline stage, not a one-time
> reverse-spec input. See pipeline-integrity-guards.md § Guard 7.

If the Feature's `pre-context.md` has a non-empty Source Reference section AND `sdd-state.md` Source Path ≠ `N/A`:

1. Read `Source Path` from `sdd-state.md` (Source Root)
2. Resolve each file in the "Related Original File List" table as `[Source Path]/[File Path]`
3. **Before each `speckit-implement` task** (BLOCKING — no UI task may proceed without this):
   a. Identify which original source files are relevant to the current task (match by Rebuild Target column if populated, otherwise by Role/component name)
   b. **Actually read those files** — not just reference them. The agent must open and parse the source code.
   c. Display: `📂 Source Reference: [N] original files loaded for task context`
   d. **If no source files can be identified for a UI task**: Display `⚠️ No source reference found for task [name]` and check if the task creates a component that exists in the Source→Target Component Mapping. If it does, the corresponding source file MUST be loaded — resolve the mapping before proceeding.
4. Reference Guide determines HOW to use the source:
   - Same Stack: Actively reuse patterns, match test structure, reference concrete values (CSS, padding, border-radius, etc.)
   - New Stack: Extract business logic only, use idiomatic new-stack patterns. Still reference concrete CSS/style values from original for visual fidelity
5. **Data lifecycle compliance** (when pre-context.md § Data Lifecycle Patterns exists):
   - Before implementing any data flow (store, API call, CRUD operation), read the lifecycle paradigm for the entity
   - Verify the implementation matches the declared paradigm (e.g., opt-in → explicit user add action required, NOT auto-enable-all)
   - Display: `📂 Lifecycle: [Entity] = [paradigm] — implementing [specific pattern]`
   - Paradigm mismatch (e.g., implementing opt-out when source is opt-in) = **BLOCKING — stop and flag**

**Enforcement level**:
- **rebuild + GUI Features**: BLOCKING — a UI task without `📂 Source Reference` display is a gate violation. If context limits prevent loading all files, load at minimum the primary component file and display `📂 Source Reference: [N] of [M] files loaded (context-limited)`.
- **rebuild + backend-only**: WARNING — source reference is strongly recommended but not blocking.
- **adoption mode**: WARNING — source is the current project, reference for understanding not replication.

**Skip if**: Source Path = `N/A` (greenfield) or Source Reference = "N/A".
**Incremental (add)**: Source Path = `.` — files are in the current project. Read them for context but do not copy.

### Background Agent Source Injection (rebuild + GUI — MANDATORY)

When delegating UI implementation to background agents, the main agent MUST include source app code in the agent prompt. Reading source for display is insufficient — the source insights must be **carried into the execution context**.

**Procedure**:
1. Before spawning a background agent for UI tasks, identify the source files from the Source→Target Component Mapping (plan.md)
2. Read each source file
3. Include the **actual source code** (not a summary) in the agent prompt:
   ```
   ✅ RIGHT:
     "This is a rebuild project. Here is the source app's AddKnowledgeBasePopup.tsx:
      [full source code]
      Reproduce the same UX flow in the new stack (React + shadcn/ui + Tailwind).
      Key patterns to preserve: ModelSelector dropdown, auto-dimensions on model select."

   ❌ WRONG:
     "Create a dialog with name input, embedding model input, dimensions input."
     → SBI-level abstraction loses all UX detail. Agent creates text inputs instead of dropdowns.
   ```
4. If context limits prevent including full source, include at minimum:
   - Component structure (what sub-components exist)
   - UI control types (dropdown vs input vs slider)
   - Inter-control dependencies (model select → dimensions auto-fill)

**BLOCKING**: For rebuild+GUI tasks delegated to background agents, the agent prompt MUST contain either:
- Full source code of the corresponding component(s), OR
- Explicit `⚠️ Source code omitted due to context limit` with the 3 minimum items above

An agent prompt for UI implementation that contains **neither source code nor source summary** is a gate violation.

> **Rationale (SKF-053)**: Source Reference Injection (above) requires the main agent to read source files and display them. But when UI tasks are delegated to background agents, the source insights stay with the main agent — the background agent sees only task descriptions from tasks.md. This creates a second information gap: even though source was read, it wasn't transmitted to the agent that actually writes the code.

## CSS Value Map Generation (rebuild mode with utility CSS)

> **Skip if**: `specs/reverse-spec/visual-references/style-tokens.md` does not exist, OR the project does not use a build-time CSS framework (detected from constitution tech stack — if plain inline styles only → skip).
> Applies to: rebuild mode with build-time CSS frameworks (utility-first: Tailwind/UnoCSS/WindiCSS; CSS-in-JS: styled-components/Emotion/Vanilla Extract; Atomic: Pico/Open Props).

Before the first UI-related `speckit-implement` task (one-time):

1. Read `specs/reverse-spec/visual-references/style-tokens.md` → extract CSS property-value pairs organized by category (colors, spacing, typography, layout)
2. Read the CSS framework config (e.g., `tailwind.config.js`, `uno.config.ts`, theme file, design tokens) → identify available utility classes/theme values
3. Generate `specs/{NNN-feature}/css-value-map.md`:

```markdown
# CSS Value Map — [FID]-[Feature Name]

> Auto-generated from style-tokens.md + utility framework config.
> MUST be referenced during UI implementation — do NOT guess styles.

Example (Tailwind CSS):

| Category | Original Value | CSS Property | Utility Class | Note |
|----------|---------------|-------------|---------------|------|
| Color | #1e1e2e | background-color | bg-[#1e1e2e] | Header background |
| Color | #e2e8f0 | border-color | border-slate-200 | Card border |
| Spacing | 16px | padding | p-4 | Content area |
| Spacing | 24px | gap | gap-6 | Grid gap |
| Typography | 14px | font-size | text-sm | Body text |
| Typography | 600 | font-weight | font-semibold | Headings |
| Layout | 8px | border-radius | rounded-lg | Cards |
| Layout | 240px | width | w-60 | Sidebar width |
```

4. Display: `📋 CSS Value Map: [N] mappings generated → specs/{NNN-feature}/css-value-map.md`

**MUST rule**: When implementing UI components, reference this mapping table for every CSS value. Do NOT invent "typical web app styles" or use generic defaults. Each CSS value from the original source has an explicit utility class target.

## Source App Visual Reference (rebuild mode, GUI)

> **Purpose**: During implement, the agent references the running source app for visual and structural context.
> This resolves the gap where implement had code-level source reference but no runtime visual reference.
> See [runtime-verification.md](../runtime-verification.md) §7 for CLI Script Patterns.

### Protocol

Before the first UI-related task (one-time setup):
1. Read `sdd-state.md` Source Path and app start command
2. Start the source app in background on its default port
3. Capture CLI library-mode snapshots of key screens referenced in this Feature's pre-context.md
4. Display: `📂 Source App Reference: [N] screens captured from [Source Path]`

During each UI task:
1. Before implementing: CLI snapshot of the source app's corresponding screen for reference
2. After implementing + build pass:
   a. Start the target app on a different port (source on default, target on +1000)
   b. CLI snapshot of the target app's equivalent screen
   c. Compare structural elements — report deviations: `⚠️ Visual deviation: [description]`
   d. If CSS mismatch suspected: CLI css-extract on both apps for comparison
3. After all tasks complete: Include comparison summary in Review Display

### Dual-App Port Convention

- **Source app**: project's default port (from package.json scripts or launch.json)
- **Built app**: source port + 1000 (e.g., 3000 → 4000) or explicit override in sdd-state.md

### Layout Structure Analysis (rebuild mode, GUI — one-time before first UI task)

> Visual reference (screenshots) catches surface-level differences but misses DOM hierarchy divergence. This step ensures the **code-level layout structure** matches the source app.

Before the first UI-related task, read the source app's root layout code (from Source Reference files) and document:

1. **Root container direction**: `flex-direction: row` vs `column`, `grid-template` layout
2. **Container nesting hierarchy**: Which components are siblings vs parent-child (e.g., Sidebar alongside Content vs Sidebar inside a wrapper)
3. **Height/width strategy**: `100vh`, `calc(100vh - Npx)`, `flex: 1`, or CSS environment variables (`env(titlebar-area-height)`)
4. **Platform-specific offsets**: Mac titlebar area, Electron `frame: false` adjustments, fullscreen handling
5. **Persistent element placement**: Where are WindowControls, Navbar, Titlebar placed — globally (outside router) vs per-page (inside route components)

Record the analysis in a brief comment block at the top of the Feature's main layout file (e.g., `Router.tsx`, `Layout.tsx`):
```
// Layout Structure (from source analysis):
// Root: flex-row | Sidebar: full-height (100vh) | Content: flex-1
// WindowControls: inside per-page Navbar (not global)
// Mac: sidebar margin-top: env(titlebar-area-height)
```

**Why code-level, not just visual**: Screenshots look identical between `flex-row` (Sidebar + Content side-by-side) and `flex-column` (Titlebar + row) — both produce a sidebar layout. But the underlying structure determines how future Features (tab mode, multi-window, fullscreen) integrate. Getting this wrong at F002 forces a structural rewrite later.

### Visual References Fallback (rebuild mode, when source app cannot start)

Even when the source app cannot be launched (dependency issues, missing env, etc.), if `specs/reverse-spec/visual-references/` directory exists with screenshots:
1. Read `specs/reverse-spec/visual-references/manifest.md` to identify screens relevant to this Feature
2. Read each screenshot file referenced in the manifest for the Feature's screens
3. Use these as the visual reference instead of live source app snapshots
4. Display: `📂 Visual References (static): [N] screenshots loaded from visual-references/`

### Rebuild Visual Reference Checkpoint (MANDATORY — rebuild + GUI)

> Guard 1: Guideline → Gate Escalation. This checkpoint was promoted from guideline to
> BLOCKING gate because prior violations (SKF-024) caused Major+ quality regression.
> See pipeline-integrity-guards.md § Guard 1.

> **Why this is a HARD STOP, not a read instruction**: Prior failures (SKF-024) show agents skip visual references despite "MUST consult" prose. This gate ensures visual reference is loaded and confirmed before any UI task begins.

**Run ONCE before the first UI-related task** (after Layout Structure Analysis):

1. **Detect available visual references**:
   - Live source app: Source App Visual Reference (§ Protocol above) was executed → `source_ref = true`
   - Static screenshots: `specs/reverse-spec/visual-references/manifest.md` exists → `static_ref = true`
   - Neither available → `no_ref = true`

2. **If source_ref OR static_ref**:
   - Load relevant screens for this Feature
   - Display:
     ```
     📂 Rebuild Visual Reference Checkpoint:
       Source: [live app on port NNNN / static screenshots]
       Screens loaded: [N] — [screen list]

       These references will be compared against your implementation.
     ```
   - Record in sdd-state.md Notes: `📂 Visual References: [source type], [N] screens`
   - Proceed to implement.

3. **If no_ref** (rebuild + GUI with NO visual reference at all):
   - **HARD STOP** — Use AskUserQuestion:
     ```
     ⚠️ No visual reference available for rebuild GUI Feature [FID]:
       Visual references/ directory: not found
       Source app: cannot be started ([reason])

     Without visual reference, layout divergence from the original is very likely.
     ```
     - "Start source app manually — I'll provide the port" → agent captures reference
     - "Provide screenshots — I'll place them in visual-references/" → user provides, agent re-checks
     - "Acknowledge risk — proceed without visual reference" → record `⚠️ NO-VISUAL-REF` in sdd-state.md
     **If response is empty → re-ask** (per MANDATORY RULE 1)

### Skip Conditions

- Not rebuild mode (greenfield or add — no source app exists)
- Non-GUI Feature (http-api, cli, data-io)
- Source Path = N/A in sdd-state.md
- Source app cannot be started (dependency issues) → use Visual References Fallback above, then continue code-only

## Static Resource Handling

Before or during implementation, if the Feature's `pre-context.md` has a non-empty Static Resources section:

1. Read `Source Path` from `sdd-state.md` to get the Source Root value
2. For each resource listed in the Static Resources table:
   - **Copy** the file from `[Source Path]/[relative Source Path column]` to `[Target Path column]` in the new project
   - Create target directories if they don't exist
   - If the source file is not found, warn: "⚠️ Static resource not found: [path]. Manual action required."
3. If any resources have modification notes (in the Usage column), display them to the user after copying
4. Include the resource copy as a task in the implementation — either as a pre-task before code implementation or integrated into the relevant code task

**Greenfield projects**: Skip — no Static Resources section exists.
**Incremental (add) projects**: Source Path = `.`, so resources are already in place. Skip copying but verify the files exist at the expected paths.

## Environment Variable Handling

Before implementation, if the Feature's `pre-context.md` has a non-empty Environment Variables section:

1. Read the Feature's `pre-context.md` → "Environment Variables" section (both owned and shared variables)
2. Check if a `.env` file exists in the project root
3. If `.env` exists: Check for the **presence** of each required variable name (do NOT read actual values)
4. Display a summary showing which variables are set (✅) and which are missing (❌)
5. **If any REQUIRED variables are missing**: HARD STOP — use AskUserQuestion with "Environment is ready" / "Skip for now" and WAIT for user response. If "ready", re-check to verify. If "skip", warn and proceed.
6. **If all required variables are present**: Display "✅ All set" and proceed without stopping.

**Security rule**: NEVER read actual values from `.env`. Only check for the **presence** of variable names (e.g., check if a line starts with `VARIABLE_NAME=`). Never display, log, or reference actual secret values.

**Greenfield projects**: Environment Variables section may be empty or contain "TBD" entries. Display TBD entries as reminders during implementation.
**Incremental (add) projects**: `.env` should already exist. Verify required variables are present.

## Plugin/Dependency Pre-flight

> Runs ONCE at the start of implement (before the first task).
> **Purpose**: Verify all required dependencies are installed before writing code that imports them.
> Prevents mid-implementation discovery of missing packages, which wastes time and produces incomplete results.

**Step 1 — Package dependency check**:
1. Read `specs/{NNN-feature}/plan.md` → extract mentioned libraries/packages (from architecture decisions, Pattern Constraints, technology choices)
2. Read the project's dependency manifest (`package.json`, `Cargo.toml`, `requirements.txt`, `go.mod`, etc.)
3. For each dependency mentioned in plan.md that is not a standard library:
   - Check if it exists in dependencies/devDependencies
   - If missing: add to Missing Dependencies list
4. Display result:
   ```
   📦 Dependency Pre-flight for [FID]:
     ✅ {existing-dep-1}, {existing-dep-2} — installed
     ❌ {missing-dep} — NOT in dependency manifest
   ```
5. If any missing: use AskUserQuestion (**HARD STOP**):
   - "Install missing dependencies" — run the appropriate install command for the project's package manager
   - "Skip — I'll install manually"
   **If response is empty → re-ask** (per MANDATORY RULE 1)
   If "Install missing dependencies": execute the install command, then re-check to verify installation succeeded.

**Step 1b — Native/compiled dependency compatibility check**:
> Runs only when Step 1 identified dependencies that require native compilation (C/C++ addons, Rust FFI, Python C extensions, etc.).

1. For each native dependency, verify build compatibility with the project's runtime:
   - Can the module build against the current runtime version? (e.g., Electron's V8 headers, Python's C API version)
   - Are prebuild binaries available for the target platform, or will it require local compilation?
   - Are build toolchain prerequisites met? (compiler version, system headers, build tools)
2. **Quick smoke test**: Attempt to install and import the native dependency in isolation. If the build fails at this stage, it will fail during implement — catch it now.
3. **On failure**: Use AskUserQuestion (**HARD STOP**):
   - "Switch to alternative dependency" — identify a compatible alternative (e.g., WASM-based or pure-language equivalent)
   - "Attempt build fix" — try platform-appropriate rebuild tools
   - "Proceed and handle at Smoke Launch" — record `⚠️ NATIVE-DEP-RISK` in sdd-state.md
   **If response is empty → re-ask** (per MANDATORY RULE 1)

> **Why here, not at plan**: Plan chooses dependencies based on functionality and architecture fit. Build compatibility depends on the specific machine/toolchain and is best verified at implement time when the actual build environment is available.

**Step 2 — UI component library check** (only if project uses component libraries like shadcn/ui, Headless UI, etc.):
1. Read `specs/{NNN-feature}/plan.md` → extract mentioned UI components (Button, Dialog, Select, Tabs, etc.)
2. Check if those components exist in the library's component directory
3. If missing: display which components need to be added
4. Use AskUserQuestion (**HARD STOP**):
   - "Add missing components" — run the library's add/install command
   - "Skip — I'll add manually"
   **If response is empty → re-ask** (per MANDATORY RULE 1)
   If "Add missing components": execute the add commands, then verify the component files were created.

**Skip if**: No external dependencies mentioned in plan.md, or all dependencies already installed.

## Naming Remapping (only if pre-context has a Naming Remapping section)

When the Feature's `pre-context.md` contains a "Naming Remapping" section (indicating the project identity changed):

1. Read the Naming Remapping table — it lists original identifiers found in this Feature's source files and their new names
2. **Inject as context for `speckit-implement`**: Before execution, provide the remapping table as implementation guidance:
   ```
   ⚠️ Project Identity Remapping for [FID]:
   The following identifiers from the original source must use new names:
     createCherryIn → createAngdu (function)
     CherryProvider → AngduProvider (class)
     CHERRY_API_KEY → ANGDU_API_KEY (env var)
   Ensure all new code uses the "New Identifier" column. Do NOT carry over original project naming.
   ```
3. This is a **soft reminder** — not a HARD STOP. The constitution's "Naming Conventions" section provides the authoritative old → new prefix mapping; the pre-context table provides the Feature-specific occurrences

**Greenfield/incremental projects**: No Naming Remapping section exists. Skip entirely.

## Demo-Ready Delivery (if VI. Demo-Ready Delivery is in the constitution OR `demos/` already contains Feature demo scripts)

After `speckit-implement` completes, if Demo-Ready Delivery is **active** (constitution includes "Demo-Ready Delivery", OR `demos/` directory already contains demo scripts from previous pipeline runs — indicating the project has an established demo pattern):

1. **Clean up obsolete demo-only components from previous Features**:
   - Check `demos/` directory for demo scripts of **already completed** Features
   - In each completed Feature's demo script, check the **Demo Components** header comment
   - If any component has Category = "Demo-only" and Fate = "Remove after F0XX-[current-feature]", **remove that component** (delete the file/directory) and update the demo script's header comment
   - Report removed demo-only components to the user

2. **Determine the Feature's demo surface type** based on what was implemented:
   - Has UI components → demo script starts the server, opens/tests the route, and shuts down
   - Backend/API only → demo script invokes the API endpoints and displays results
   - Data/logic layer only → demo script exercises the core logic with sample data
   - Pipeline/engine → demo script runs the pipeline with sample input and shows output

3. **Categorize each demo component** as either:
   - **Demo-only**: Mock data, temporary UI scaffolding. Mark with `// @demo-only` comment. Will be removed when the real Feature replaces it
   - **Promotable**: Minimal but real implementation that future Features will extend. Place in the regular source tree. Mark with `// @demo-scaffold — will be extended by F00N-[feature]` comment. Not deleted, but evolved

4. **Create executable demo script** at `demos/F00N-name.sh` (or `.ts`/`.py`/etc.):
   > Anti-patterns, full bash template, key requirements, and Feature-type-specific demo approaches are defined in [demo-standard.md](../demo-standard.md).
   > **Demo artifacts**: During `implement`, create the surfaces users will interact with (demo routes, demo pages, demo data fixtures, demo CLI wrappers, etc.) — these are what make the demo real, not just test stubs.
   >
   > **quickstart.md reference**: If `specs/{NNN-feature}/quickstart.md` exists (generated by `speckit-plan`), the demo script MUST follow its run instructions (startup commands, required environment, health check endpoints, etc.). The quickstart.md is the authoritative source for how to launch and verify the Feature.

5. **Update `demos/README.md`** — see [demo-standard.md § 8](../demo-standard.md) for format.

6. **Generate VERIFY_STEPS test file** (if demo script contains a `# VERIFY_STEPS:` block):
   - Parse the VERIFY_STEPS block → convert each verb to Playwright API call:
     - `navigate /path` → `await page.goto(BASE_URL + '/path')`
     - `click selector` → `await page.click('selector')`
     - `fill selector value` → `await page.fill('selector', 'value')`
     - `verify selector visible` → `await expect(page.locator('selector')).toBeVisible()`
     - `verify-state selector attribute "expected"` → `await expect(page.locator('selector')).toHaveAttribute('attribute', 'expected')` (or `toHaveClass` for class)
     - `verify-effect target property "expected"` → custom assertion (evaluate `getComputedStyle` + assert for style properties; `toHaveClass` for class; `toBeVisible` for visible)
     - `wait-for selector visible [timeout]` → `await expect(page.locator('selector')).toBeVisible({ timeout })`
     - `wait-for selector gone [timeout]` → `await expect(page.locator('selector')).toBeHidden({ timeout })`
     - `wait-for selector textContent "pattern" [timeout]` → `await expect(page.locator('selector')).toHaveText(pattern, { timeout })`
     - `verify-scroll selector "bottom"` → `await page.evaluate(s => { const el = document.querySelector(s); return el.scrollTop + el.clientHeight >= el.scrollHeight - 5; }, 'selector')` + expect true
     - `trigger selector event` → `await page.locator('selector').dispatchEvent('event')`
   - Generate `demos/verify/F00N-name.spec.ts` with the converted assertions
   - Display: `📋 Generated verify test: demos/verify/F00N-name.spec.ts ([N] assertions)`
   - **Skip if**: No VERIFY_STEPS block in demo script, or project has no Playwright dependency
   - **Playwright dependency check**: If the project's Playwright package is not installed (e.g., `@playwright/test` for JS/TS, `playwright` for Python), display:
     `ℹ️ Playwright not installed — VERIFY_STEPS test file not generated. Add @playwright/test to use CLI verification fallback.`

## Runtime Verification + Fix Loop

> **Purpose**: Resolve G4 — implement only generates code without running it. Per-task runtime verification prevents bug explosion at verify time.
> **App Session Management**: Start app at first task verification → subsequent tasks use Navigate for screen switching only → shut down after Review complete. See [PLAYWRIGHT-GUIDE.md](../../../../../PLAYWRIGHT-GUIDE.md) for Runtime Capability Map.
> **Runtime backend architecture**: See [runtime-verification.md](../runtime-verification.md) for the full multi-backend detection protocol and interface-specific verification strategies.

### Per-Task Runtime Verification

After each `speckit-implement` task completes (before starting the next task):

**Step 1 — Build Gate**:
- Run build command (`npm run build`, `cargo build`, etc.)
- **Build failure**: Enter Auto-Fix Loop (see below)
- **Build success**: Proceed to Step 2

**Step 1c — i18n Completeness Check** (when project uses i18n — skip otherwise):
After each task that creates/modifies UI files:
1. Grep the task's changed files for translation call patterns (`t('key')`, `$t('key')`, etc.)
2. For each extracted key, check existence in ALL locale JSON files
3. Missing key → auto-add to all locale files (copy from source locale, mark others with `[TRANSLATE]` or copy existing translation pattern)
4. Display: `🌐 i18n: [N] keys checked, [N] added to [locale list]`

**Step 2 — Runtime Check** (when Playwright CLI or MCP available):

> Guard 2: Static ≠ Runtime — Level 1. App launches without crash (smoke check).
> Static build pass alone is insufficient for GUI projects.
> See pipeline-integrity-guards.md § Guard 2.

**CLI mode** (primary — RUNTIME_BACKEND = cli):
1. If app not running: start app (dev server or Electron via `_electron.launch()`)
2. Run CLI library-mode snapshot from the project root: `cd PROJECT_ROOT && node -e "const { chromium } = require('playwright'); ..."` targeting the relevant screen
   (PROJECT_ROOT = the directory containing package.json where playwright is installed. See [runtime-verification.md](../runtime-verification.md) §7 for CWD requirement and script patterns.)
3. Check snapshot output for error indicators (error boundary text, blank page)
4. **Success**: Proceed to next task
5. **Failure**: Enter Auto-Fix Loop

**MCP mode** (accelerator — RUNTIME_BACKEND = mcp):
1. If app is not yet running: start app (dev server / Electron / etc.)
2. Navigate to the screen related to the completed task
3. Snapshot to confirm normal rendering (not an error screen)
4. Check Console logs for JS errors (TypeError, ReferenceError, etc.)
5. **Success**: Proceed to next task (keep app running)
6. **Failure**: Enter Auto-Fix Loop

**Without Playwright CLI — Check MCP Before Degradation**:

CLI is the expected backend (checked in pre-flight). If CLI is unavailable:
1. Check if Playwright MCP is active in this session (`browser_snapshot` probe)
2. If MCP active → use MCP for runtime checks (NOT degradation)
3. If MCP also unavailable → declare Level 1 Degradation

**If Playwright MCP available as fallback** (NOT degradation):
- Use MCP tools for runtime verification instead of CLI
- Display: `ℹ️ Playwright CLI not available — using Playwright MCP for runtime verification.`
- Proceed with normal Step 2 flow (navigate, snapshot, console check via MCP)
- Do NOT set `RUNTIME-DEGRADED` flag

**If neither CLI nor MCP available — Level 1 Degradation (HARD STOP)**:

At first task verification, display:
```
⚠️ Runtime Verification Degraded — Level 1 (build-only)
  Neither Playwright CLI nor Playwright MCP available.
  Runtime verification is limited to:
  ✅ Build gate (compile/transpile)
  ❌ Runtime rendering check — SKIPPED
  ❌ Console error scan — SKIPPED
  ❌ Post-implement SC verification — SKIPPED

  Risk: Bugs that pass build but fail at runtime (selector instability,
  layout effect timing, infinite re-renders) will NOT be caught until verify.
```

Use AskUserQuestion (**HARD STOP**):
- "Install Playwright CLI now" (Recommended) — run the appropriate install command for the project's package manager, then retry
- "Continue with Level 1 (build-only)" — proceed, but record `RUNTIME-DEGRADED` flag
- "Configure Playwright MCP" — requires session restart for MCP tools (see [runtime-verification.md §4](../runtime-verification.md))

**If response is empty → re-ask** (per MANDATORY RULE 1)

If "Continue with Level 1":
- Record `⚠️ RUNTIME-DEGRADED` in sdd-state.md Feature Progress (Detail column)
- Replace Step 2 with build success confirmation only
- Post-implement SC verification and Post-Implement Pattern Compliance Scan are skipped
- The verify step will display a prominent reminder and may BLOCK if MCP is still unavailable (see verify-phases.md Pre-flight + Phase 3 Step 3 RUNTIME-DEGRADED check)

### Post-Implement Full Verification

After all tasks complete, before Review:

1. Start app (or keep running if already started)
2. Identify verifiable items from the Feature's SC-### list
3. Navigate to each SC-related screen → Snapshot → confirm normal rendering
4. Scan Console logs for all errors
5. **Runtime Error Zero Gate** (BLOCKING when runtime verification is available):
   - Collect all JS errors from Console: TypeError, ReferenceError, SyntaxError, unhandled rejection, Maximum update depth exceeded
   - **If runtime errors found AND MCP/Playwright CLI is available**:
     Display:
     ```
     ❌ Runtime Error Zero Gate FAILED — [N] runtime errors detected:
       - [Error type]: [message] — [source file]
       - [Error type]: [message] — [source file]

     These errors indicate the Feature does NOT work at runtime despite build success.
     Fix runtime errors before proceeding to Review.
     ```
     Enter Auto-Fix Loop (max 3 attempts). If auto-fix fails → **HARD STOP**:
     Use AskUserQuestion:
     - "Fix manually and re-verify" — user fixes, agent re-runs runtime check
     - "Proceed with runtime errors" — requires reason. Records `⚠️ RUNTIME-ERRORS-ACKNOWLEDGED — [reason]` in sdd-state.md
     **If response is empty → re-ask** (per MANDATORY RULE 1)
   - **If RUNTIME-DEGRADED** (no runtime check possible): skip this gate, but display:
     `⚠️ Runtime Error Zero Gate skipped — RUNTIME-DEGRADED. Static analysis (Pattern Compliance Scan) is primary verification.`
6. **All pass**: Display "Runtime Verified: ✅ 0 errors" in Review Display

### Post-Implement Pattern Compliance Scan

After Post-Implement Full Verification, run a grep-based anti-pattern scan on files changed by this Feature (use `git diff --name-only main` on the Feature branch).

**Skip if**: plan.md has no `## Pattern Constraints` section.

> **Note**: This scan runs even when `RUNTIME-DEGRADED` is set. Without runtime verification, static analysis is the last line of defense against anti-patterns. The scan is grep-based and does not require MCP.

**Enhanced scan when RUNTIME-DEGRADED**: When the `RUNTIME-DEGRADED` flag is set, extend the scan with additional checks:
- All ⚠️ warnings are promoted to **⚠️ HIGH** severity (still non-blocking, but prominently displayed)
- Add extra patterns to the scan rules below:
  - Hardcoded `localhost` URLs outside test/demo files (may indicate demo-only code leaking into production)
  - Missing error handling in async functions (`async` without `try/catch` or `.catch`)
  - `console.log` statements in non-test files (should be removed or replaced with proper logging)
- Display: `🔍 Enhanced pattern scan (RUNTIME-DEGRADED — static analysis is primary verification)`

**Scan rules** (derived from plan.md Pattern Constraints):

> **Note**: The patterns below use React/JS examples for illustration. Derive actual search patterns from the project's specific framework and state management library.

| Pattern Constraint | Grep/Search Pattern | Severity |
|---|---|---|
| Selector reference stability | Selector callbacks containing `.filter(`, `.map(`, `.slice(`, `Object.keys(` — creating new references per call | ⚠️ warning — likely infinite re-render |
| DOM measurement in async effect | `useEffect` callback body containing `getBoundingClientRect`, `offsetHeight`, `scrollHeight`, `clientHeight`, `offsetWidth` | ⚠️ warning — layout flicker |
| Missing Error Boundary | Route/page-level components (files under `pages/`, `routes/`, `views/`) without `ErrorBoundary` or `error.tsx` sibling | ⚠️ warning |
| Unbatched state updates | Multiple sequential `setState(` / `set(` / `store.` calls within same function without `batch(` wrapper | ⚠️ warning |
| Stub/empty implementation | Function bodies containing only `return null`, `() => null`, `return undefined`, `return <>`, `return <></>`, `// TODO`, `throw new Error('Not implemented')` | ⚠️ warning — hollow implementation |
| SDK API contract gap | SDK function calls (e.g., `tool()`, `streamText()`, `fetch()`) where required callback/field is missing: `tool({...})` without `execute`, `streamText({...})` without error handler | ⚠️ HIGH — builds but silently fails at runtime |
| Loose type bypass | Parameters typed as `Record<string, unknown>`, `any`, `object`, or `unknown` that are passed to external SDK functions — hides shape mismatches from the compiler | ⚠️ warning — type system cannot catch runtime errors |

> **Stub detection rationale**: During rebuild, registering components with `render: () => null` or `return null` creates the illusion of "implementation complete" while delivering zero functionality. Each component/function must have a meaningful implementation — at minimum, rendering its key UI elements or performing its core logic. If a component is intentionally deferred, it should be explicitly marked as out-of-scope in spec.md, not silently stubbed.

> **SDK API contract gap rationale**: Passing metadata-only objects (e.g., `{ type: "mcp", serverId: "xxx" }`) where the SDK expects callable objects (e.g., `tool({ execute: async () => {...} })`) causes silent failure — the build succeeds because loose types accept any shape, but the SDK ignores the object at runtime. When implementing SDK integrations, verify that all required fields (especially `execute`, `parameters`, `description` for tool definitions) are present and callable.

**Result classification**: ⚠️ warning (NOT blocking). Violations are reported in the Review Display as a "Pattern Compliance" section. The agent MAY auto-fix simple violations before Review (e.g., wrapping a selector with `useShallow`, changing `useEffect` to `useLayoutEffect`). Stub violations SHOULD be flagged prominently — they indicate under-implementation, not a pattern issue.

### CSS Value Map Compliance Scan (rebuild mode with utility CSS)

> **Skip if**: `specs/{NNN-feature}/css-value-map.md` does not exist.
> Runs after Pattern Compliance Scan, before Review.

1. Read `css-value-map.md` → extract Original Value column (all CSS values)
2. Identify UI files changed in this Feature (`git diff --name-only` → filter `.tsx`, `.jsx`, `.vue`, `.svelte`, `.css`, `.scss`)
3. For each Original Value, grep UI files for hardcoded usage:
   - Color values: `#1e1e2e`, `rgb(30, 30, 46)` (look for hex/rgb variants)
   - Spacing values: `16px`, `1rem` (when the map has a utility class equivalent)
   - Skip values already using the correct utility class (e.g., `bg-[#1e1e2e]` is OK)
4. Report:
   ```
   📋 CSS Value Map Compliance:
     ✅ 12/15 values use mapped utility classes
     ⚠️ 3 hardcoded values found:
       - src/components/Header.tsx:24 — `background: #1e1e2e` → should be `bg-[#1e1e2e]`
       - src/components/Card.tsx:8 — `padding: 16px` → should be `p-4`
       - src/components/Card.tsx:12 — `border-radius: 8px` → should be `rounded-lg`
   ```
5. **Severity**: ⚠️ warning (NOT blocking) — agent MAY auto-fix before Review

**Important**: Only scan for values that appear in css-value-map.md. Do NOT flag CSS values that are not in the map (they may be intentionally new or different).

### E2E Integration Smoke Test (cross-boundary Features)

> **Why**: Per-Task Runtime Verify checks each module independently. Post-Implement SC Verify checks each screen for console errors. But neither tests whether data flows through ALL layers end-to-end. F007 Knowledge Base had all modules "working" individually, but 12 bugs were found in verify because the full chain (file upload → parsing → embedding → vector store → search → chat injection → citation display) was never tested as one connected flow.

**Skip if**: Feature has no cross-boundary data flow (single-layer Feature, UI-only, or simple CRUD with no processing pipeline).

**Detect cross-boundary flow** (same criteria as tasks injection check):
- Renderer → IPC → Main process (Electron/Tauri)
- Frontend → Backend API (REST/GraphQL)
- Service → External API (embeddings, search, webhooks)
- File I/O across process boundaries
- Multi-stage processing pipeline

**When cross-boundary flow detected**:

1. **Identify the primary E2E flow** from spec.md Success Criteria:
   - Find the SC that describes the most complete user journey (e.g., "user uploads file → file is processed → content is searchable → results appear in chat")
   - This SC defines the E2E test path

2. **Execute the E2E flow** using the available runtime backend:
   - **GUI (Playwright CLI/MCP)**: Navigate → perform user actions through the ENTIRE flow → verify end state
   - **API (HTTP client)**: Send request at entry point → verify response includes data that traversed all layers
   - **CLI (process runner)**: Execute command → verify output reflects full pipeline execution
   - **If RUNTIME-DEGRADED**: Substitute with a grep-based seam check (step 3 below)

3. **Seam check** (always runs, even with runtime available — supplements runtime test):
   - Trace the data flow path from plan.md / Interaction Chains / spec.md
   - For each seam (module boundary crossing), verify:

     Example (Electron/Node.js):
     ```bash
     # Seam 1: Renderer → IPC
     grep -r "invoke.*channelName" src/renderer/ → must find caller
     grep -r "handle.*channelName" src/main/ → must find handler

     # Seam 2: IPC Handler → Service
     grep -r "import.*ServiceName" src/main/ → must find import
     grep -r "serviceName.methodName" src/main/ → must find call

     # Seam 3: Service → External API
     grep -r "fetch\|axios\|http" src/services/ServiceName → must find API call
     ```
   - Each seam has a caller AND a callee. If either is missing → `❌ Broken seam`

4. **Report**:

   Example:
   ```
   📊 E2E Integration Smoke Test for [FID]:
     Primary flow: File upload → PDF parse → Embedding → Vector store → Search → Chat
     Seam 1 (Renderer → IPC):     ✅ invoke('kb:addFile') ↔ handle('kb:addFile')
     Seam 2 (IPC → KBService):    ✅ import KBService ↔ kbService.addFile()
     Seam 3 (KBService → Loader):  ❌ BROKEN — KBService calls loadDocument() but Loader exports loadItem()
     Seam 4 (Loader → Embeddings): ✅ import EmbeddingService ↔ embeddings.embed()
     Seam 5 (Embeddings → API):    ⚠️ URL uses /embeddings but provider requires /v1/embeddings

     Runtime E2E: ❌ Failed at Seam 3 — TypeError: loadDocument is not a function
   ```

5. **Result classification**:
   - **Any broken seam** → `⚠️ HIGH WARNING` (NOT blocking — but prominently displayed in Review)
   - **Runtime E2E failure** → `⚠️ HIGH WARNING` — strong indicator that implement is incomplete
   - These warnings should drive the Review conversation: "These seams are broken. Should we return to implement to fix the integration?"
   - **All seams connected + runtime passes** → `✅ E2E Integration: all seams verified`

### Auto-Fix Loop

Attempt automatic fix when runtime verification fails:

```
FIX_LOOP (max 3 attempts):
  1. Analyze stdout/stderr error messages
  2. Classify error type:
     - Import/Module: path errors, unregistered modules
     - Config: missing/invalid config files
     - Type: type mismatches, unimplemented interfaces
     - API: endpoint mismatches, schema errors
     - Runtime: null reference, undefined access
  2b. Upstream tracing (MANDATORY for Runtime/API errors):
     Before modifying code, trace the data flow from source to error point:
       a. Identify the value that caused the error (e.g., `result.content` is undefined)
       b. Trace upstream: where was this value created? What boundaries did it cross?
          (IPC serialize → SDK callback → stream event → store → component)
       c. Add a temporary debug log at each boundary to confirm actual runtime values
       d. Fix at the EARLIEST point where the value diverges from expectation
     Why: Fixing at the error point (downstream) patches the symptom.
     The same root cause will surface as a different symptom in the next iteration.
     Example: 5 fix iterations for "tool result not displayed" — each fixed a crash
     but the root cause was "SDK stream event doesn't carry tool output" (upstream).
     A single upstream trace would have found this in 1 iteration.
  3. Modify related source files (at the upstream origin, not just the error site)
  4. Rebuild → re-verify
  5. Same error repeats: break loop → error report
```

**Loop break conditions**:
- Same error after 3 attempts → break
- New error resets counter (different issue)
- Error from external dependency (DB, API server, etc.) → break immediately, show reason
- **Native/compiled dependency failure** → attempt platform-appropriate rebuild (e.g., `npm rebuild`, `cargo build`, etc.) first. If auto-fix fails → break with environment classification (see Smoke Launch Escalation in pipeline.md)

**Break report**:
```
⚠️ Runtime Verification — Auto-Fix failed:
  Error: [error message]
  Attempts: [N]
  Classification: [error type]
  Files modified: [list of attempted fix files]

You can fix manually or proceed to Review with this state.
```

**Use AskUserQuestion** with options:
- "Fix manually and re-verify"
- "Proceed to Review as-is" — Review includes ⚠️ marker
**If response is empty → re-ask** (per MANDATORY RULE 1)

## UI Fix Escalation — Visual Tool Re-check

> **Principle**: If an agent has attempted 2+ code-reasoning UI fixes for the same visual issue
> and the user still reports the problem, the agent MUST re-check visual tool availability
> before attempting another code-only fix.

**Trigger**: User reports UI issue persists after 2+ fix attempts for the same problem category (layout, styling, rendering, spacing, visual appearance).

**Re-check procedure**:
1. Attempt `browser_snapshot` — if available now (MCP became active mid-session), USE IT immediately
2. If tool still unavailable, run CDP probe: `curl -s http://localhost:9222/json/version`
   - Success: "CDP is active. Playwright MCP tools need session restart to load."
     → HARD STOP: recommend session restart for visual debugging
   - Failure: "Neither MCP nor CDP available."
     → Display: `⚠️ Code-reasoning has failed to resolve this UI issue after [N] attempts. Visual confirmation is needed. Please start the app with CDP and restart the session.`
3. If MCP IS available: take screenshot/snapshot → diagnose from actual rendering → fix

**Rationale**: CSS is context-dependent — `w-full` renders differently depending on parent `flex`, `overflow`, `position` chains. Tailwind utility class interactions are unpredictable from code alone. After 2 failed code-reasoning attempts, visual confirmation is more efficient than a third guess.

## Playwright Usage During Implement (CLI Primary, MCP Optional)

> During implement, use Playwright CLI library mode for runtime verification
> and source app reference. MCP is an optional accelerator when active in session.

### MUST (required when Playwright CLI available)
- Per-task runtime verification (Step 2) — CLI snapshot + error check after each task
- Post-implement SC verification — verify all SCs render correctly before Review

### SHOULD (recommended, rebuild mode)
- Before first UI task: CLI snapshot of source app for visual reference
- After CSS/styling changes: CLI css-extract to confirm computed values match source
- After layout changes: CLI compare between source and built app

### MAY (optional)
- Use MCP tools if active in session for faster iteration (interactive snapshot → click → re-snapshot loop)
- Use CLI screenshot for visual-references/ comparison (rebuild exact mode)

## Injected Content

- Automatically executes `speckit-implement` based on tasks.md
- Static resource copy instructions from pre-context.md (if applicable)
- Naming remapping context from pre-context.md (if applicable) — displays old → new identifier mapping before execution
- If Demo-Ready Delivery is active: demo surface implementation + executable demo script creation (`demos/F00N-name.sh`)
- **Runtime verification**: Per-task build gate + runtime check (when MCP available), post-implement full SC verification
- **Interaction behavior inventory**: If present in pre-context, inject micro-interaction patterns for this Feature — hover behaviors (tooltip rendering), keyboard shortcuts (shortcut registration), animations (CSS transitions / animation triggers), drag-and-drop (DnD handler wiring), focus management (focus trap activation), context menus (right-click handler registration), scroll behaviors (scroll position save/restore). Each interaction maps to concrete implementation tasks: component props for interaction states, event listener setup, CSS classes for transitions. For **greenfield/add**: implement interactions defined during specify as FR-### entries
- **Foundation Implementation Reference** (from sdd-state.md § Foundation Decisions):
  - Decided items with concrete values (e.g., "electron-store" for storage, "invoke-handle" for IPC)
  - These decisions are CONSTRAINTS — implementation must conform, not choose differently
  - **If Foundation Decisions section is empty or absent**: Skip Foundation injection

## Checkpoint

Only a simplified checkpoint is displayed:
```
📋 Implement execution: [FID] - [Feature Name]
speckit-implement will be executed based on tasks.md. Do you want to proceed?
```

**Additional Checkpoint lines** (append when applicable):
- **Visual references** (rebuild mode + GUI + `visual-references/` exists): `📂 Visual References: [N] screenshots available — will reference during UI tasks`
- **Interaction surface preservation** (when this Feature modifies/replaces UI components from completed Features): `⚠️ Interaction Surface Check: [component] from [previous FID] will be modified — preserving [N] interaction surfaces`

## Review Display Content

> **⚠️ SUPPRESS spec-kit output**: `speckit-implement` prints navigation messages like "Suggested commit: ..." — **never show these to the user**. Suppress ALL spec-kit navigation messages. Immediately proceed to the Review Display below. If context limit prevents continuing, show instead: `✅ speckit-implement executed for [FID] - [Feature Name].\n💡 Type "continue" to review the results.`

After `speckit-implement` completes:

**Files to read**:
1. `specs/{NNN-feature}/tasks.md` — Re-read to cross-reference which tasks were completed
2. All source files created/modified during implementation — use `git diff --name-only` on the Feature branch to identify them
3. Build output — capture from the build step during implementation
4. `demos/{FID}-{name}.sh` (or `.ts`/`.py`/etc.) — If Demo-Ready Delivery is active, read the demo script

**Display format**:
```
📋 Review: Implementation for [FID] - [Feature Name]
📄 Branch: {NNN}-{short-name}

── Files Created/Modified ───────────────────────
[List of files from git diff --name-only:
 - New files: path — purpose
 - Modified files: path — what changed]

── Build Status ─────────────────────────────────
[Final build success/failure]

── Runtime Verification ────────────────────────
[Per-task verification summary:
 Task 1: ✅ Build + Runtime OK
 Task 2: ✅ Build + Runtime OK
 Task 3: ⚠️ Build OK, Runtime Fix (1 attempt)
 Post-implement: ✅ [N]/[M] SCs verified]
[If MCP not available: "Build-only verification (Level 1)"]

── Runtime Error Status ─────────────────────────
  Runtime errors: [0 errors ✅ / N errors ❌ / DEGRADED ⚠️]
  [If errors acknowledged: ⚠️ RUNTIME-ERRORS-ACKNOWLEDGED — [reason]]
  [If DEGRADED: "Static analysis only — runtime not verified"]

── Demo Status (if Demo-Ready Delivery active) ──
[Demo surface created: yes/no
 demos/F00N-name.sh: created/updated]

── Files You Can Edit ─────────────────────────
  📄 All source files listed above under "Files Created/Modified"
  📄 specs/{NNN-feature}/tasks.md  (to adjust remaining tasks)
  📄 demos/{FID}-{name}.sh  (if Demo-Ready Delivery active)
You can open and edit any of these files directly, then select
"I've finished editing" to continue.
──────────────────────────────────────────────────
```

**HARD STOP** (ReviewApproval): Options: "Approve", "Request modifications", "I've finished editing". **If response is empty → re-ask** (per MANDATORY RULE 1).

---

## Bug Prevention Checks (B-3)

> Bug prevention rules applied during code writing in the implement stage.
> Reminded at Checkpoint before speckit-implement execution, compliance checked during Review.
> **Result classification**: ⚠️ warning (NOT blocking) — violations found during Review are reported as recommendations. They do not block verify.

> **Module-conditional activation**: Before applying B-3 rules, read `sdd-state.md` Domain Profile.
> Only apply rules whose activating module is in the active Interfaces or Concerns.
> Rules not matched by any active module are SKIPPED (not errors).
> See `domains/_core.md` § S7 for the full activation conditions table.

### IPC Boundary Safety (Electron/Tauri)

- **IPC Message Validity**: Prevent argument type/count mismatches in main↔renderer IPC calls
- **Context Isolation**: Confirm renderer cannot directly access Node.js APIs
- **IPC Error Handling**: Recovery strategy for IPC call failures (process crash, timeout)
- **IPC Return Value Defense**: All IPC return values MUST use defensive access patterns (e.g., optional chaining, null checks, default values). IPC serialization strips type guarantees — typed definitions do NOT guarantee fields will exist at runtime. Apply defensive patterns for arrays (e.g., `result?.content ?? []`), nested objects (e.g., `result?.nested?.field ?? default`), and primitives.

### External SDK Type Trust Classification

When implementing code that calls external SDK functions, classify each call by trust level and apply the corresponding defensive pattern:

| Trust Level | What | Examples | Required Defense |
|-------------|------|---------|-----------------|
| **High** — Synchronous, pure functions | Return value matches type definition reliably | e.g., `nanoid()`, `z.object()`, `jsonSchema()` | Standard null checks |
| **Medium** — Async functions, resolved values | Return usually matches types; edge cases under error/timeout | e.g., `generateText().text`, `fetch().json()`, `db.query()` | `?? fallback` on all fields; `try/catch` around call |
| **Low** — Stream events, callbacks, experimental APIs | Type definitions may not reflect actual runtime values; timing-dependent | e.g., `fullStream` part events, `experimental_*` callbacks, WebSocket `onmessage` | **Mandatory**: debug log actual values before coding against them; never trust `.d.ts` alone; use runtime type guards (`typeof x === 'string'`) |

> **Rationale**: SDK type definitions may declare fields that don't exist at runtime (e.g., `.d.ts` declares `output` on stream events, but actual value is `undefined`). Trusting type definitions alone without runtime verification leads to multiple fix iterations. A single debug log confirming the actual runtime value identifies the root cause immediately. **Rule: Low-trust SDK calls → debug log first, code second.**

### Platform CSS Constraints

- **Electron/Tauri Webview CSS Constraints**: Desktop-specific CSS considerations (`-webkit-app-region: drag`, frameless window layouts)
- **Cross-browser Compatibility**: CSS Grid/Flexbox fallbacks, vendor prefix requirements

### Build Toolchain Integration Verification

Many frameworks require **build-time plugin registration** to function. Code compiles without the plugin, but runtime output is incomplete or broken. This is a **silent failure** — build passes, types check, app runs, but the framework's output is missing.

**When to check**: Whenever adding components that depend on a build-time transformation framework.

**General procedure**:

1. **Plugin registration check**: Verify the framework's build plugin is registered in the project's build tool configuration:
   - **CSS frameworks**: Tailwind CSS 4 + Vite (`@tailwindcss/vite`), Tailwind CSS 3 + PostCSS (`tailwindcss` in `postcss.config`), CSS Modules (bundler `.module.css` support)
   - **i18n extraction**: Compile-time key extractors (`@formatjs/swc-plugin`, `babel-plugin-react-intl`, etc.) in bundler/compiler config
   - **Code generation**: Prisma (`prisma generate` in build scripts), GraphQL codegen (`graphql-codegen` config), OpenAPI generators
   - **Asset pipeline**: Image optimization (`vite-plugin-image-optimizer`), SVG sprite generation, font subsetting
   - **Other build-time transforms**: Any plugin listed in project docs or `package.json` scripts that must run for correct output
2. **Scope/scanning check**: Verify the plugin's scope covers the new files:
   - CSS: content scanning includes new component paths
   - i18n: extraction config includes new source directories
   - Codegen: schema/spec files are included in generation input
3. **Build output sanity check**: After build, compare relevant output (CSS file size, generated type count, asset manifest entries) before and after changes. If output is unchanged or decreased after adding new framework-dependent code → likely misconfigured
4. **CSS Theme Token mapping check** (when adding components that use CSS variable-based design tokens):
   - Verify that CSS variables (e.g., `--primary`, `--background`) are not only defined in `:root`/`@layer base` but also **mapped to the CSS framework's theme system**:
     - Tailwind CSS 4: `@theme` block must exist with token mappings (`--color-primary: var(--primary)` or `--color-primary: hsl(...)`)
     - Tailwind CSS 3: `tailwind.config.js` → `theme.extend.colors` must reference the CSS variables
     - UnoCSS: `uno.config.ts` → `theme.colors` must reference the CSS variables
   - Without this mapping, utility classes (`bg-primary`, `text-muted-foreground`) compile to empty values — the build succeeds but elements render with no visible styling
   - **When to check**: Any time a component library (shadcn/ui, Radix Themes, DaisyUI, Flowbite) is first added or components are added that use design token utility classes

> **Why this pattern is dangerous**: Build-time transformation frameworks (CSS utility generators, i18n extractors, code generators) produce output only when their plugin is correctly registered AND their input scope covers the source files. Without the plugin, the build succeeds (the framework's references are just strings/imports that don't cause errors), but the runtime output is incomplete. This silent failure is invisible to build, type-check, and basic smoke gates.

### Async Hydration Sync (Features with persistent config + external system binding)

When a store/config that is **asynchronously hydrated** (e.g., from electron-store, localStorage, database, file) also controls an **external system's state** (i18n language, theme engine, OS notification preferences, audio/video settings), apply these rules:

1. **Unconditional sync on hydrate completion**: After hydrate completes, ALWAYS call the external system's API to synchronize, even if the loaded value appears to match the current state. The external system may have been initialized with a different default (e.g., i18n initialized with `lng: 'ko'` while config has `'en'` from previous session)
2. **Ordering guarantee**: The external system sync call must happen AFTER hydrate is complete, not in parallel. If the framework provides lifecycle hooks (`onRehydrate`, `afterHydrate`), use them
3. **UI binding**: UI controls that display the config value (Select, Radio, Toggle) must be bound to the **config store value**, not the external system's current state. This prevents display/state mismatch after hydrate
4. **Common instances** (non-exhaustive):
   - i18n library (i18next, react-intl) + language config: `i18n.changeLanguage(config.language)` after hydrate
   - Theme engine (CSS variables, class toggle) + theme config: apply theme after hydrate
   - Audio/video settings + media config: apply device selection after hydrate
   - Notification preferences + permission config: sync permission state after hydrate

> **Rationale**: Static initialization (compile-time default) and async hydration (runtime persisted value) create a race condition window where the external system and config store disagree. This window causes UI mismatch (Select shows 'English' while UI renders Korean) that users perceive as a bug. The unconditional sync eliminates this window regardless of timing.

### Data Persistence Round-Trip Verification

> (See [pipeline-integrity-guards.md](../pipeline-integrity-guards.md) § Guard 2: Static ≠ Runtime, Level 4)

**Trigger**: Feature writes data that must survive app restart (DB, electron-store, localStorage, file system).

After implementing any data persistence flow, the agent MUST verify the **round-trip**: write → close → reopen → read → same data.

**Rules**:

1. **INSERT vs UPDATE awareness**: When flushing in-memory data to a database:
   - New entities (created during this session) → MUST use INSERT or UPSERT
   - Existing entities (loaded from DB, modified in-memory) → may use UPDATE
   - **UPDATE-only flush for new entities = data loss** (UPDATE on non-existent row = no-op)

2. **Renderer ↔ Main Process sync**: If a renderer store persists data via IPC to main process:
   - Renderer store MUST have `hydrate()` that calls main process on app start
   - `hydrate()` MUST be called in App initialization (not lazy)
   - localStorage `partialize` MUST NOT strip fields that main process owns (e.g., `apiKey: ''` in localStorage while actual key is in safeStorage)

3. **Post-implement verification** (when runtime verification is available):
   ```
   1. Create data (e.g., send chat message, save API key)
   2. Verify data visible in UI
   3. Close app (or reload)
   4. Reopen app
   5. Verify same data still visible
   If data disappears → BLOCKING (do not proceed to verify)
   ```

4. **Streaming data special case**: For streaming features (AI chat, real-time feeds):
   - Streaming blocks are created in-memory during stream
   - Flush to DB must INSERT new blocks, not just UPDATE existing
   - Verify: stream → complete → reload → blocks still present

This rule prevents the class of bugs where "data works during session but vanishes on restart" — a critical failure mode that static checks (build/TS) cannot catch.

### Cross-Feature Integration

- **Import Path Validation**: Verify correct paths when importing modules from other Features
- **Interface Contract Compliance**: Confirm actual implementation of shared entities/APIs matches entity-registry/api-registry contracts
- **Module Import Graph**: Prevent circular imports, check tree-shaking impact when using barrel exports

### Interaction Surface Preservation (UI Features — when modifying/replacing previous Feature components)

> Guard 1: Guideline → Gate Escalation. Reading the Interaction Surface Inventory before
> modifying shared components is BLOCKING — not advisory.
> See pipeline-integrity-guards.md § Guard 1.

When a task modifies or replaces a UI component created by a **previously completed Feature** (e.g., replacing App.tsx, restructuring layout, swapping navigation):

1. **Read previous Features' Interaction Surface Inventories**: Before modifying, read `SPEC_PATH/[NNN-feature]/interaction-surfaces.md` from all preceding Features. This provides the definitive list of surfaces to preserve (do NOT rely on ad-hoc enumeration alone — the inventory is the authoritative source)
2. **Enumerate existing interaction surfaces** (supplement inventory with inspection): List all user-facing interactions the component provides:
   - Window drag regions (`-webkit-app-region: drag`)
   - Window controls (minimize, maximize, close buttons)
   - Theme toggle / settings access
   - Keyboard shortcuts registered in the component
   - Focus management (focus traps, tab order)
   - Navigation elements (sidebar, breadcrumbs, tabs)
3. **Verify preservation in the new implementation**: After modifying, confirm each surface from the inventory still exists — either in the same component or explicitly relocated to another
4. **Report any removals**: If an interaction surface is intentionally removed, display:
   `⚠️ Interaction surface removed: [surface] from [previous FID] — [reason]`
5. **Fail the per-task runtime check** if a critical surface is missing (drag region, window controls) — same treatment as GUI Operability Check in Smoke Launch

> **Rationale**: When Feature N+1 restructures Feature N's entry component (e.g., replacing App.tsx with a Router layout), it can silently remove interaction surfaces that users rely on (window dragging, theme toggle, window controls). The agent sees the NEW structure as complete but doesn't realize the OLD structure provided essential interactions. The Interaction Surface Inventory provides a concrete checklist for preservation.

### UI Interaction Surface Audit (UI Features)

When implementing hover, click, or popup interactions, check the following before proceeding to the next task:

- **Hover area scope**: Is the hover trigger area larger than the visual target? (e.g., entire row hover for a small button) → Narrow to the specific element, or use CSS `group-hover` on a tighter container
- **Hover response timing**: Does hover trigger instantly on a high-traffic area (e.g., message list, scrollable container)? → Add CSS `transition-opacity` or debounce to prevent flicker during scroll
- **Hover implementation method**: Is framework state used purely for show/hide? → Prefer CSS-only (`:hover` pseudo-class, CSS transitions) for performance and simplicity; reserve framework state for interactions requiring logic (data fetching, complex conditionals)
- **Popup occlusion**: Does the hover popup obscure adjacent interactive elements? → Review z-index and positioning
- **Scroll-through interference**: Does scrolling through a list trigger hover effects on every item passed? → CSS transitions naturally handle this; framework state hover does not

> **Rationale**: Applying hover/click handlers (e.g., `onMouseEnter/Leave`) to items in a scrollable list causes UI flicker as the cursor passes through each item during scroll. CSS-only solutions (`:hover` pseudo-classes with `transition-opacity`) resolve this with zero re-renders. Prefer CSS for pure visibility toggles; reserve framework state for interactions that require data loading or complex logic.

### Data Persistence Safety

- **Write-Through Consistency**: Synchronization strategy between in-memory state changes and persistence layer (DB, localStorage, file)
- **Optimistic Update Rollback**: Mechanism to restore previous state when optimistic updates fail

---

## Post-Step Update Rules

1. Subsequent Feature impact analysis:
   - Find the list of Features that depend on the current Feature from the Dependency Graph in `roadmap.md`
   - Inspect the `pre-context.md` of each subsequent Feature
   - If the entity/API drafts in the "For /speckit.plan" section differ from the actual implementation, update them
   - Report the changes to the user

2. **Dependency Stub Registry (MANDATORY SCAN)** — generate `SPEC_PATH/[NNN-feature]/stubs.md`:
   After all tasks are implemented, **always scan** the codebase for stub/placeholder implementations created due to dependency on future Features. This scan is mandatory — do NOT skip it even if no stubs seem obvious.

   **Detection method** (apply ALL three — do not stop at the first):
   - Scan `tasks.md` for tasks explicitly marked as partial/stub due to future Feature dependency
   - Search **all files modified or created during this implement step** for `TODO` comments referencing other Feature IDs (e.g., `// TODO: F003`, `// TODO: Read from settings store (F003-settings)`)
   - Cross-reference the roadmap Dependency Graph: for each Feature that depends on the current Feature, check if any implemented code includes hardcoded values, empty stub components, or mock data that should eventually come from that dependent Feature's store/API/config

   **Result reporting** (always display, even when no stubs found):
   - If stubs found: generate `stubs.md` and display summary
   - If no stubs found: display `📋 Dependency Stubs: None — scanned [N] modified files, no future-Feature dependencies detected` (explicit confirmation that the scan ran)

   **stubs.md format**:
   ```markdown
   # Dependency Stub Registry — [FID]-[name]

   > Stub/placeholder implementations that depend on future Features.
   > Auto-generated at implement completion. Consumed by dependent Features' pipeline.

   | # | File:Line | Dependent Feature | Current (Stub) | Target (Real) | TODO Marker |
   |---|-----------|-------------------|----------------|---------------|-------------|
   | 1 | src/components/Sidebar.tsx:54 | F003-settings | `DEFAULT_VISIBLE_ICONS` hardcoded array | Read from settings store | `// TODO: F003` |
   | 2 | src/components/PinnedApps.tsx:12 | F008-mcp | Empty stub component returning `null` | Render pinned MCP apps | `// TODO: F008` |
   ```

   **Rules**:
   - Each row must have a specific `File:Line` location (not just a file name)
   - `Dependent Feature` must reference an actual FID from the roadmap
   - If no stubs are found, do NOT create an empty `stubs.md` — but still display the scan confirmation (see Result reporting above)
   - If stubs found: display summary `📋 Dependency Stubs: [N] stubs registered in stubs.md (dependencies: [FID list])`

3. **Interaction Surface Inventory** (GUI Features only) — generate `SPEC_PATH/[NNN-feature]/interaction-surfaces.md`:
   After all tasks are implemented, scan the Feature's UI components and record all user-facing interaction surfaces.

   **interaction-surfaces.md format**:
   ```markdown
   # Interaction Surface Inventory — [FID]-[name]

   > User-facing interaction surfaces provided by this Feature.
   > Auto-generated at implement completion. Consumed by subsequent Features' pipeline.

   | # | Surface | Type | Component:Line | Size/Area | Criticality |
   |---|---------|------|----------------|-----------|-------------|
   | 1 | Titlebar drag region | Drag Region | Titlebar.tsx:12 | 100% × 36px | Critical |
   | 2 | Window controls | Buttons | WindowControls.tsx:8 | 3 × 46px | Critical |
   | 3 | Theme toggle | Button | Titlebar.tsx:24 | 1 × 36px | High |
   | 4 | Sidebar navigation | Navigation | Sidebar.tsx:15 | 260px × 100% | High |
   | 5 | Keyboard: Ctrl+, | Shortcut | App.tsx:42 | N/A | Medium |
   ```

   **Criticality levels**:
   - **Critical**: Removal breaks platform functionality (drag regions, window controls). Must ALWAYS be preserved.
   - **High**: Removal significantly degrades UX (navigation, theme toggle, primary actions). Preservation expected unless explicitly redesigned.
   - **Medium**: Removal may be acceptable with justification (keyboard shortcuts, secondary actions).

   **Rules**:
   - Only generate for GUI Features (skip for API/CLI/data-io)
   - Include specific `Component:Line` location for each surface
   - If this Feature modified a previous Feature's surfaces, update the previous Feature's inventory file too (append `Relocated to: [new-component]` note)
   - Display summary: `🎯 Interaction Surfaces: [N] surfaces inventoried ([C] critical, [H] high, [M] medium)`

4. **Post-Update Consistency Verification** — GEL artifact cross-check:
   After updating entity-registry.md and api-registry.md (rule #1), verify consistency:

   **Entity-Registry Cross-Check**:
   - For each entity this Feature owns in entity-registry.md: verify the actual schema file exists at the specified path
   - For each entity this Feature references: verify the owning Feature has completed implement (or has a stub)
   - Flag inconsistencies:
     ```
     ⚠️ Entity-Registry Consistency:
       ❌ entity-registry.md lists "Notification" owned by F009,
          but no schema/model file found at src/models/notification.*
       ⚠️ entity-registry.md references "User" from F001-auth,
          but F001's actual schema has field "email" not listed in registry
     ```

   **API-Registry Cross-Check**:
   - For each API this Feature provides in api-registry.md: verify an actual route/handler exists in the implementation
   - For each API this Feature consumes: verify the providing Feature's API actually exists and matches the expected signature
   - Flag inconsistencies:
     ```
     ⚠️ API-Registry Consistency:
       ❌ api-registry.md lists POST /notifications/send for F009,
          but no route handler found in implementation
       ⚠️ F009 consumes GET /users/:id from F001, but F001's actual
          response includes "role" field not in registry
     ```

   **Action on inconsistencies**:
   - Auto-update registry entries when implementation differs from draft (e.g., field name changes, path changes)
   - Display summary of updates made
   - If structural differences are found (missing entities/APIs entirely): record as `⚠️ REGISTRY-DRIFT` in sdd-state.md and flag for verify Phase 4

> **Note**: Feature Progress Status remains `in_progress` after implement. Status transitions to `completed` only after all steps including merge are ✅ (per state-schema.md).
