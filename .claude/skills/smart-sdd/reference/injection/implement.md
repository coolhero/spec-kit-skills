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

## Source Reference Injection (rebuild/adoption mode)

If the Feature's `pre-context.md` has a non-empty Source Reference section AND `sdd-state.md` Source Path ≠ `N/A`:

1. Read `Source Path` from `sdd-state.md` (Source Root)
2. Resolve each file in the "Related Original File List" table as `[Source Path]/[File Path]`
3. Before each `speckit-implement` task:
   a. Identify which original source files are relevant to the current task (match by Rebuild Target column if populated, otherwise by Role/component name)
   b. Read those files and inject as reference context
   c. Display: `📂 Source Reference: [N] original files loaded for task context`
4. Reference Guide determines HOW to use the source:
   - Same Stack: Actively reuse patterns, match test structure, reference concrete values (CSS, padding, border-radius, etc.)
   - New Stack: Extract business logic only, use idiomatic new-stack patterns. Still reference concrete CSS/style values from original for visual fidelity

**Skip if**: Source Path = `N/A` (greenfield) or Source Reference = "N/A".
**Incremental (add)**: Source Path = `.` — files are in the current project. Read them for context but do not copy.

> **Rationale**: The specify and plan steps read original source files via `injection/specify.md` Source Reference Path Resolution. But implement — the step that actually writes code — had no equivalent. This gap meant agents implemented code without ever seeing the original implementation, leading to behavioral and visual divergence in rebuild projects.

## CSS Value Map Generation (rebuild mode with utility CSS)

> **Skip if**: `specs/reverse-spec/visual-references/style-tokens.md` does not exist, OR the project does not use a utility CSS framework (detected from constitution tech stack — if plain CSS/SCSS/CSS-in-JS → skip).
> Applies to: rebuild mode with utility CSS frameworks (Tailwind, UnoCSS, WindiCSS).

Before the first UI-related `speckit-implement` task (one-time):

1. Read `specs/reverse-spec/visual-references/style-tokens.md` → extract CSS property-value pairs organized by category (colors, spacing, typography, layout)
2. Read the utility framework config (e.g., `tailwind.config.js`, `uno.config.ts`) → identify available utility classes and custom theme values
3. Generate `specs/{NNN-feature}/css-value-map.md`:

```markdown
# CSS Value Map — [FID]-[Feature Name]

> Auto-generated from style-tokens.md + utility framework config.
> MUST be referenced during UI implementation — do NOT guess styles.

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

### Skip Conditions

- Not rebuild mode (greenfield or add — no source app exists)
- Non-GUI Feature (http-api, cli, data-io)
- Source Path = N/A in sdd-state.md
- Source app cannot be started (dependency issues) → log in sdd-state.md and continue code-only

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
     ✅ react, zustand, electron — installed
     ❌ @radix-ui/react-dialog — NOT in package.json
     ❌ lucide-react — NOT in package.json
   ```
5. If any missing: use AskUserQuestion (**HARD STOP**):
   - "Install missing dependencies" — run the appropriate install command (e.g., `npm install @radix-ui/react-dialog lucide-react`)
   - "Skip — I'll install manually"
   **If response is empty → re-ask** (per MANDATORY RULE 1)
   If "Install missing dependencies": execute the install command, then re-check to verify installation succeeded.

**Step 2 — UI component library check** (only if project uses component libraries like shadcn/ui, Headless UI, etc.):
1. Read `specs/{NNN-feature}/plan.md` → extract mentioned UI components (Button, Dialog, Select, Tabs, etc.)
2. Check if those components exist in the project (e.g., `components/ui/button.tsx` for shadcn/ui)
3. If missing: display which components need to be added
4. Use AskUserQuestion (**HARD STOP**):
   - "Add missing components" — run the library's add command (e.g., `npx shadcn@latest add dialog tabs select`)
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

## Demo-Ready Delivery (only if VI. Demo-Ready Delivery is in the constitution)

After `speckit-implement` completes, if the constitution includes "Demo-Ready Delivery":

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
   - **Playwright dependency check**: If `@playwright/test` is not in devDependencies, display:
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

**Step 1b — i18n Completeness Check** (when project uses i18n — skip otherwise):
After each task that creates/modifies UI files:
1. Grep the task's changed files for translation call patterns (`t('key')`, `$t('key')`, etc.)
2. For each extracted key, check existence in ALL locale JSON files
3. Missing key → auto-add to all locale files (copy from source locale, mark others with `[TRANSLATE]` or copy existing translation pattern)
4. Display: `🌐 i18n: [N] keys checked, [N] added to [locale list]`

**Step 2 — Runtime Check** (when Playwright CLI or MCP available):

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
- "Install Playwright CLI now (`npm i -D @playwright/test && npx playwright install`)" (Recommended) — install, then retry
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

**Scan rules** (derived from plan.md Pattern Constraints — examples below are illustrative; actual patterns depend on the project's stack):

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

**Important**: The grep patterns above are illustrative. Derive actual search patterns from:
1. The project's specific state management library
2. The project's specific framework
3. The Pattern Constraints section in plan.md

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

## Checkpoint

Only a simplified checkpoint is displayed:
```
📋 Implement execution: [FID] - [Feature Name]
speckit-implement will be executed based on tasks.md. Do you want to proceed?
```

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
- **IPC Return Value Defense**: All IPC return values MUST use optional chaining (`result?.field`) and nullish coalescing (`?? fallback`). IPC serialization strips TypeScript type guarantees — `content: MCPToolResultContent[]` in the type definition does NOT guarantee `content` will exist at runtime. Apply: `(result?.content ?? [])` for arrays, `result?.nested?.field ?? default` for nested objects.

### External SDK Type Trust Classification

When implementing code that calls external SDK functions, classify each call by trust level and apply the corresponding defensive pattern:

| Trust Level | What | Examples | Required Defense |
|-------------|------|---------|-----------------|
| **High** — Synchronous, pure functions | Return value matches type definition reliably | `nanoid()`, `z.object()`, `jsonSchema()` | Standard null checks |
| **Medium** — Async functions, resolved values | Return usually matches types; edge cases under error/timeout | `generateText().text`, `fetch().json()`, `db.query()` | `?? fallback` on all fields; `try/catch` around call |
| **Low** — Stream events, callbacks, experimental APIs | Type definitions may not reflect actual runtime values; timing-dependent | `fullStream` part events, `experimental_*` callbacks, WebSocket `onmessage` | **Mandatory**: debug log actual values before coding against them; never trust `.d.ts` alone; use runtime type guards (`typeof x === 'string'`) |

> **Rationale**: SDK type definitions may declare fields that don't exist at runtime (e.g., `.d.ts` declares `output` on stream events, but actual value is `undefined`). Trusting type definitions alone without runtime verification leads to multiple fix iterations. A single debug log confirming the actual runtime value identifies the root cause immediately. **Rule: Low-trust SDK calls → debug log first, code second.**

### Platform CSS Constraints

- **Electron/Tauri Webview CSS Constraints**: Desktop-specific CSS considerations (`-webkit-app-region: drag`, frameless window layouts)
- **Cross-browser Compatibility**: CSS Grid/Flexbox fallbacks, vendor prefix requirements

### Cross-Feature Integration

- **Import Path Validation**: Verify correct paths when importing modules from other Features
- **Interface Contract Compliance**: Confirm actual implementation of shared entities/APIs matches entity-registry/api-registry contracts
- **Module Import Graph**: Prevent circular imports, check tree-shaking impact when using barrel exports

### UI Interaction Surface Audit (UI Features)

When implementing hover, click, or popup interactions, check the following before proceeding to the next task:

- **Hover area scope**: Is the hover trigger area larger than the visual target? (e.g., entire row hover for a small button) → Narrow to the specific element, or use CSS `group-hover` on a tighter container
- **Hover response timing**: Does hover trigger instantly on a high-traffic area (e.g., message list, scrollable container)? → Add CSS `transition-opacity` or debounce to prevent flicker during scroll
- **Hover implementation method**: Is React state (`useState` + `onMouseEnter/Leave`) used purely for show/hide? → Prefer CSS-only (`group-hover:opacity-100`) to avoid unnecessary re-renders
- **Popup occlusion**: Does the hover popup obscure adjacent interactive elements? → Review z-index and positioning
- **Scroll-through interference**: Does scrolling through a list trigger hover effects on every item passed? → CSS transitions naturally handle this; React state hover does not

> **Rationale**: Applying hover/click handlers (e.g., `onMouseEnter/Leave`) to items in a scrollable list causes UI flicker as the cursor passes through each item during scroll. CSS-only solutions (`group-hover` with `transition-opacity`) resolve this with zero re-renders. Prefer CSS for pure visibility toggles; reserve React state for interactions that require data loading or complex logic.

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

> **Note**: Feature Progress Status remains `in_progress` after implement. Status transitions to `completed` only after all steps including merge are ✅ (per state-schema.md).
