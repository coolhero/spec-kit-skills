# Verify Phase 2: Cross-Feature Consistency + Behavior Completeness

> Part of verify-phases.md split. For common gates (Bug Fix Severity, Source Modification Gate), see [verify-phases.md](verify-phases.md).

---

### Phase 2: Cross-Feature Consistency + Behavior Completeness Verification

**Step 1 — Cross-Feature consistency**:
- Check the cross-verification points in the "For /speckit.analyze" section of `pre-context.md`
- Analyze whether shared entities/APIs changed by this Feature affect other Features
- Verify that entity-registry.md and api-registry.md match the actual implementation

**Step 1a — Feature Contract Compliance Check** (skip if pre-context.md has no "Feature Contracts" section):

> Guard 6a: Provides Interface Verification. Each `Provides →` interface must be verified
> from the consumer's perspective — not just the provider's.
> See pipeline-integrity-guards.md § Guard 6.

1. **Guarantee verification**: For each Guarantee this Feature provides (C-[FID]-G## entries):
   - Grep the Feature's code for the interface/function/API described in the Guarantee
   - Verify the interface returns/provides what the Guarantee promises (type check, not runtime)
   - If not implemented → `⚠️ Contract C-[FID]-G## not implemented — [Consumer Feature] depends on this`

2. **Dependency status check**: For each Dependency this Feature requires (C-[FID]-D## entries):
   - Check if the Provider Feature has verify status = `success` or `limited` in sdd-state.md
   - If Provider NOT verified → `⚠️ Dependency C-[FID]-D## on [Provider Feature] — provider not yet verified`
   - If Provider verified → check that the specific interface still exists in Provider's code (cross-reference)

3. Report:
   Example:
   ```
   📋 Feature Contract Compliance for [FID]:
     Guarantees: [N]/[M] implemented
       ⚠️ C-F007-G01: getKnowledgeReferences() not returning name field (F005-chat depends on this)
     Dependencies: [N]/[M] providers verified
       ✅ C-F007-D01: F001-auth verified, middleware available
   ```

4. **Result**:
   - **Default (greenfield/incremental/adoption)**: ⚠️ HARD STOP — unimplemented Guarantees are presented to the user via AskUserQuestion with options: "Return to implement to fix", "Defer to next Feature (document reason)", "Accept risk and proceed". **If response is empty → re-ask** (per MANDATORY RULE 1). This ensures the user explicitly acknowledges each unimplemented Guarantee rather than silently proceeding.
   > **🚫 G6 [G6]**: Silent skipping of unimplemented Guarantees causes downstream Features to build against missing interfaces. Even in greenfield mode, the user must make an explicit decision.
   - **BLOCKING escalation for rebuild mode**: When Origin=`rebuild` AND this Feature has `Provides →` interfaces (i.e., at least one C-[FID]-G## Guarantee), unimplemented Guarantees are **❌ BLOCKING**, not warnings. The agent MUST halt and report:
     ```
     🔴 BLOCKING: Contract C-[FID]-G## not implemented — rebuild mode requires all Guarantees to be fulfilled.
        [Consumer Feature] depends on this interface matching the source app's behavior.
        → Return to implement to complete the interface, or explicitly defer with user approval.
     ```
     **Rationale**: In rebuild mode, downstream Features depend on these interfaces matching the source app's behavior. An unimplemented Guarantee will cause the next Feature's implementation to diverge from the original app, propagating behavioral drift through the pipeline.
     (See pipeline-integrity-guards.md § Guard 6: Cross-Feature Interface Verification, § Guard 1: Guideline → Gate Escalation)

**Step 1b — Plan Deviation Quick Check**:
Lightweight sanity check to catch structural drift between plan artifacts and implementation:
1. **Entity count**: Count entities in `data-model.md` (or plan.md data model section) → compare to actual model/type/schema files. Flag if actual count differs by ±30% or more.
2. **API/IPC channel count**: Count endpoints/channels in `contracts/` → compare to actual route/handler definitions. Flag if mismatch.
3. **Tasks completion rate**: Read `tasks.md` checkbox states → report completion rate.
   - 100% complete → ✅ proceed
   - <100% AND sdd-state.md Notes contains `⚠️ DEFERRED:` for this Feature → ⚠️ warning (user already acknowledged during Completeness Gate)
   - <100% AND no DEFERRED acknowledgment → ❌ **BLOCKING**: `🔴 [N] tasks not completed and not deferred — implement Completeness Gate may have been skipped. Return to implement to complete remaining tasks or explicitly defer them.`
4. Report:
   ```
   📋 Plan Deviation Quick Check:
     Entities: plan [N] / actual [N] — ✅ match (or ⚠️ ±[N] drift)
     API channels: plan [N] / actual [N] — ✅ match (or ⚠️ ±[N] drift)
     Tasks: [N]/[total] complete ([%])
   ```
5. Any flag → ⚠️ warning (NOT blocking). Helps reviewer spot gaps before Phase 3.
6. **Skip if**: No data-model.md, no contracts/, or Feature has < 5 tasks (too small to drift)

**Step 1c — Data Dependency Verification** (cross-Feature runtime data):

> Addresses the case where a Feature depends on data from another Feature (e.g., AI model embeddings, shared database entries, cached state) and that data source is not available at verify time.
> Beyond structural type compatibility (Step 1/Step 6) — checks runtime data availability.

1. Read `pre-context.md` → "Functional Enablement Chain" → "Blocked by ←" entries. Identify each cross-Feature data dependency.
2. For each data dependency:
   a. **Structural check** (always — grep-based):
      - Verify the data source exists in code (store, API endpoint, database table/model)
      - Verify the data shape is compatible (per Step 6 Integration Contract verification)
   b. **Runtime data check** (when `RUNTIME_BACKEND` is not `build-only`):
      - Start app (reuse Phase 0 instance if running)
      - Navigate to the screen/endpoint that consumes the data:
        - For GUI: snapshot → check for data elements (list items, table rows, rendered content)
        - For API: curl endpoint → verify response body is not empty/default
        - For CLI: run command → verify output contains expected data
      - **Empty data = WARNING** (not blocking):
        `⚠️ Data dependency: [source Feature] → [this Feature] — runtime data is EMPTY. This may indicate [source Feature] model/service is not running or populated.`
   c. **External model/service check** (if dependency involves AI models, external services):
      - Probe the service endpoint (`curl` with timeout 5s)
      - If unreachable: `⚠️ External dependency [service name] not reachable. SCs depending on it will be classified as user-assisted or external-dep.`
3. Report:
   ```
   📊 Data Dependency Verification for [FID]:
     F001-auth → session store: (code) ✅ (runtime) ✅ data present
     F003-ai → embedding model: (code) ✅ (runtime) ❌ model not responding
       ⚠️ SCs requiring embeddings reclassified to user-assisted
   ```
4. **Result**: ⚠️ warnings (NOT blocking) — prominently displayed in Review. Downstream impact: SCs whose data dependencies are unavailable are reclassified from auto categories to `user-assisted` or `external-dep` in the SC Verification Matrix.
5. **Skip if**: No "Blocked by ←" entries in pre-context.md, or Feature has no cross-Feature dependencies.

**Step 1d — Service Integration Verification** (import graph check):

> Catches "orphaned service" pattern: a service/module is implemented and tested in isolation but never imported by its runtime consumer. Phase 1 (test/build/lint) does not detect orphaned code — tests pass, build succeeds, lint is clean. This step verifies that new services are actually wired into the application.

1. **Scope**: Use `git diff --name-only main...HEAD` to identify files created/modified by this Feature. Filter to service/module files (exclude tests, types, configs):
   > The patterns below are for JS/TS projects. Adapt file extensions and naming conventions to the project's language.
   - Include: `*.service.ts`, `*.store.ts`, `*.composable.ts`, `*.hook.ts`, `*.provider.ts`, `*Service.ts`, `*Store.ts`, `*Repository.ts`, `*Manager.ts`, `*Helper.ts`, `*Util.ts`
   - Include any file that exports a class or function with `Service`, `Store`, `Repository`, `Manager`, `Provider` in the name
   - Exclude: `*.test.*`, `*.spec.*`, `*.d.ts`, `*.config.*`, `*.mock.*`

2. **For each service/module file**, check import graph:
   Example (JS/TS):
   ```bash
   # Find all non-test files that import this module
   grep -r "import.*from.*[module-path]" src/ --include="*.ts" --include="*.tsx" --include="*.vue" --include="*.js" --include="*.jsx" \
     | grep -v ".test." | grep -v ".spec." | grep -v "__tests__" | grep -v "__mocks__"
   ```
   - Count non-test consumers (files that import this module)

3. **Classification**:
   - **0 non-test consumers** → `⚠️ WARNING: Orphaned service — [ServiceName] has no runtime consumers`
   - **0 non-test consumers AND plan.md lists this service as consumed by a component/route** → `⚠️ HIGH WARNING: [ServiceName] is planned as runtime dependency of [Consumer] but has 0 imports — likely missing wire-up`
   - **≥1 non-test consumer** → ✅ Service is integrated

4. Report:
   ```
   📊 Service Integration Verification for [FID]:
     KnowledgeChatService: ⚠️ ORPHANED — 0 runtime imports (test-only: knowledge-chat.test.ts)
       → Plan.md: consumed by InputBar.tsx (knowledge base picker)
       → Suggested fix: import KnowledgeChatService in InputBar.tsx
     AssistantStore: ✅ 3 runtime consumers (ChatPanel.tsx, InputBar.tsx, SettingsPanel.tsx)
     ThemeService: ✅ 1 runtime consumer (App.tsx)
   ```
5. **Result**: ⚠️ warnings (NOT blocking) — prominently displayed in Review. Orphaned services are strong indicators of incomplete implementation wiring.
6. **Skip if**: No new service/module files in Feature diff, or Feature is test-only/docs-only.

**Step 1e — Cross-Module API Contract Verification** (intra-Feature boundary check):

> Catches function name mismatches, argument format incompatibilities, and return type mismatches across module boundaries WITHIN the same Feature. Step 3 (Interaction Chain) checks handler names exist. Step 6 checks cross-Feature data shapes. Step 1d checks import existence. But NONE verify that the caller's arguments match the callee's parameters, or that the caller uses the correct function name.
>
> Common bugs caught: mismatched function names across module boundaries, incompatible argument shapes, missing platform API calls.

1. **Identify API boundaries** in the Feature's code (use `git diff --name-only main...HEAD`):
   - **IPC boundaries** (Electron/Tauri): `ipcRenderer.invoke('channel', args)` ↔ `ipcMain.handle('channel', (event, args) => ...)`
   - **Preload bridge** (Electron only): renderer calls via `window.api.method(args)` ↔ preload exposes `method: (args) => ipcRenderer.invoke(...)`
   - **Service layer**: component imports `ServiceName` and calls `service.method(args)` ↔ service defines `method(params)`
   - **External API**: service constructs URL and sends `fetch(url, {body})` ↔ API expects specific URL format and body schema

2. **For each boundary**, verify contract compatibility:
   ```
   Caller side:                          Callee side:
   ─────────────────────                  ─────────────────────
   Function name match?                   Function/method name exists?
   Argument count match?                  Parameter count matches?
   Argument types compatible?             Parameter types expected?
   Return value used correctly?           Return type documented/typed?
   ```

   **Verification method** (grep + AST-lite):
   - Grep caller file for the call expression → extract function name + argument pattern
   - Grep callee file for the function definition → extract parameter pattern
   - Compare:
     - Function name exact match (case-sensitive)
     - Argument count: caller passes N args, callee expects M params → if N ≠ M: `❌ Argument count mismatch`
     - Argument shape: if caller passes `{extensions: [...]}` but callee expects `(filters, multiple)` → `❌ Argument shape mismatch`

3. **Report**:
   Example (Electron + AI project):
   ```
   📊 Cross-Module API Contract Verification for [FID]:
     Renderer → Preload (window.api):
       selectFiles({extensions: ['.pdf']}) ↔ selectFiles(filters, multiple)
       ❌ Argument shape mismatch — caller passes object, callee expects positional args
     Preload → IPC Handler:
       invoke('kb:loadDocument', path) ↔ handle('kb:loadItem', (event, path))
       ❌ Channel name mismatch — 'kb:loadDocument' vs 'kb:loadItem'
     KBService → EmbeddingService:
       embed(text, model) ↔ embed(text, options)
       ⚠️ Second argument shape may differ (string vs object)
     EmbeddingService → External API:
       POST /embeddings ↔ API expects /v1/embeddings
       ❌ URL path mismatch
   ```

4. **Result classification**:
   - Function/channel name mismatch → `❌ HIGH WARNING` — will cause runtime TypeError or "no handler" error
   - Argument count/shape mismatch → `❌ HIGH WARNING` — will cause undefined parameters or wrong behavior
   - URL path mismatch → `⚠️ WARNING` — will cause 404 at runtime
   - All contracts match → `✅ API contracts verified`
5. **Result**: ⚠️ warnings (NOT blocking) — prominently displayed in Review. Contract mismatches are strong indicators of integration bugs.
6. **Skip if**: Feature has no cross-module boundaries (single-file Feature, pure UI component, or utility library).

**Step 1f — Cross-Feature File Modification Audit** (Features with Integration Contracts):

> Step 1d checks "is the new service imported?" and Step 1e checks "do caller/callee interfaces match?" — but NEITHER checks "did this Feature modify the existing Feature files it was supposed to modify?" A Feature that `Consumes ← F005-chat-ui: Inputbar toolbar` should have modified Inputbar.tsx, but if it only created new files without touching the existing code, Steps 1d/1e both pass while the integration is actually missing.

1. **Read plan.md** `## Integration Contracts` → extract all `Consumes ←` entries. For each entry, identify the Target Feature and Interface.
2. **Map Interface to source files**: From the Interface column (e.g., `Inputbar toolbar`, `MessageContent renderer`, `AppRouter routes`), identify the likely source file(s) in the target Feature's directory.
3. **Check git diff**:
   ```bash
   git diff main...HEAD --name-only | grep -i "[target feature path or file pattern]"
   ```
4. **Classification**:
   - Integration Contract target file IS in diff → `✅ Cross-Feature file modified`
   - Integration Contract target file NOT in diff:
     - `⚠️ WARNING: [FID] consumes [Target Feature]/[Interface] per Integration Contracts, but no files in [Target Feature path] were modified. This suggests the integration wiring may be missing — new code was created but not connected to the existing application.`
5. **Report**:
   ```
   📊 Cross-Feature File Modification Audit for [FID]:
     Consumes ← F005-chat-ui / Inputbar toolbar:
       ⚠️ 0 files modified in pages/home/Inputbar/ — wiring likely missing
     Consumes ← F003-ai-core / ParameterBuilder:
       ✅ services/ParameterBuilder.ts modified (+12 lines)
   ```
6. **Result**: ⚠️ warnings (NOT blocking) — prominently displayed in Review. Combined with Step 1d (orphan detection) and Step 1e (contract mismatch), this provides a three-layer integration verification: import exists (1d) + interface matches (1e) + target file actually modified (1f).
7. **Skip if**: No `## Integration Contracts` in plan.md, or no `Consumes ←` entries.

**Step 2 — Source Behavior Completeness** (only for brownfield rebuild — Origin: `rebuild`):
If `pre-context.md` contains a "Source Behavior Inventory" section, perform a per-Feature mini-parity check:

1. Read the Source Behavior Inventory table (function/method list with P1/P2/P3 priorities)
2. Read the Feature's `spec.md` FR-### list
3. For each P1/P2 behavior, check if a corresponding FR-### exists that covers the behavior
4. Display a coverage summary:
   ```
   📊 Source Behavior Coverage for [FID]:
     P1 behaviors: [covered]/[total] ([%])
     P2 behaviors: [covered]/[total] ([%])
     P3 behaviors: [covered]/[total] (informational)
     Uncovered P1: [list function names]
     Uncovered P2: [list function names]
   ```
5. **If any P1 behavior is uncovered**: Display a warning — `⚠️ [N] P1 source behaviors not covered by FR-###. These may represent missing functionality.`
   - This is a **warning, not a blocker** — the user may proceed but should consider whether the omission is intentional
   - **Migration-strategy-aware coverage** (read `migration_strategy` from sdd-state.md Rebuild Configuration):
     - `big-bang`: P1 coverage must be 100% across ALL Features before first merge. If any P1 is uncovered in ANY Feature, escalate to ⚠️ HIGH WARNING
     - `incremental` / `strangler-fig`: P1 coverage required for current Feature only. Cross-Feature P1 coverage tracked but not blocking per-Feature
6. If no Source Behavior Inventory exists (greenfield/add), skip this step

**Greenfield check**: If Origin = greenfield AND no `coverage-baseline.md` exists → skip SBI coverage verification. Cross-Feature registry consistency check still applies (entities and APIs from preceding Features must be consistent).

**Step 3 — Interaction Chain Completeness** (UI Features with Interaction Chains in plan.md):

If `plan.md` contains an `## Interaction Chains` section:

1. Parse each row: FR | User Action | **Handler** | **Store Mutation** | **DOM Effect** | Visual Result | Verify Method
2. For each chain, verify the key implementation steps exist in the Feature's code (use `git diff --name-only` to scope to changed files):
   - **Handler**: grep for the function name (e.g., `onThemeChange`, `handleFontSize`)
   - **Store Mutation**: grep for the store field assignment (e.g., `settings.theme`, `setTheme`, `theme =`)
   - **DOM Effect**: grep for the DOM manipulation (e.g., `classList.add`, `classList.toggle`, `style.fontSize`)
3. Report (tag each check `(code)` for grep-based, `(runtime)` for MCP/Playwright-verified):
   ```
   📊 Interaction Chain Completeness (code):
     FR-012 (theme toggle): Handler ✅ → Store ✅ → DOM ✅ — Full chain
     FR-015 (font size):    Handler ✅ → Store ✅ → DOM ❌ — Chain broken at DOM Effect
       ⚠️ Store mutation `settings.fontSize` found, but no corresponding `style.fontSize` assignment
   ```
4. **Async-flow rows**: If Interaction Chains contain `async-flow:` rows, additionally verify:
   - **Loading state**: grep for loading state management (e.g., `loading = true`, `setLoading`, `isLoading`)
   - **Error recovery**: grep for error handler + UI recovery (e.g., `catch`, `onError`, error state → enabled input)
   - **Cleanup**: grep for subscription/listener cleanup (e.g., `unsubscribe`, `abort`, `removeEventListener`, `cleanup`)
5. Broken chains → ⚠️ warning (NOT blocking) — but highlighted in Review as likely runtime failure
6. **Skip if**: No Interaction Chains section in plan.md, or Feature is backend-only

**Step 3b — UX Behavior Contract Verification** (UI Features with UX Behavior Contract in plan.md):

If `plan.md` contains a `## UX Behavior Contract` section:

1. Parse each row: Scenario | Expected Behavior | Failure Behavior | Verify Method
2. For each scenario, verify the implementation exists:
   - **Code check** (grep-based, no MCP needed):
     - Scroll behavior: grep for `scrollTop`, `scrollIntoView`, `scrollTo` in Feature's UI files
     - Loading states: grep for loading/spinner state management
     - Error recovery: grep for error state + input re-enable pattern
     - Cleanup on unmount: grep for lifecycle cleanup patterns appropriate to the framework (e.g., React `useEffect` return, Vue `onUnmounted`, Svelte `onDestroy`, Angular `ngOnDestroy`)
   - **Runtime check** (if MCP or Playwright CLI available):
     - Execute the Verify Method from the contract row (same verb syntax as Interaction Chains)
3. Report (each check tagged `(code)` or `(runtime)` to distinguish verification depth):
   ```
   📋 UX Behavior Contract Verification:
     Streaming auto-scroll:  (code) ✅ scrollIntoView found | (runtime) ✅ verify-scroll passed
     Loading state:          (code) ✅ isLoading state found | (runtime) ✅ wait-for .spinner passed
     Error recovery:         (code) ✅ error handler found   | (runtime) ⬜ requires API error — skip
     Cleanup on unmount:     (code) ❌ no cleanup in lifecycle hook
       ⚠️ Missing cleanup may cause memory leak or "state update on unmounted component" warning
   ```
4. Missing implementations → ⚠️ warning (NOT blocking) — but highlighted in Review
5. **Skip if**: No UX Behavior Contract in plan.md, or Feature is backend-only / sync-only UI

**Step 4 — Enablement Interface Smoke Test** (if Functional Enablement Chain exists):

> Guard 6b: Interaction Surface Inventory. Playwright checks each interaction surface
> from the inventory still works after this Feature's implementation.
> See pipeline-integrity-guards.md § Guard 6.

If `pre-context.md` contains a "Functional Enablement Chain" section with "Enables →" entries:

> This Feature provides runtime interfaces that downstream Features depend on.
> Verify these interfaces actually work BEFORE downstream Features are built.

1. Parse "Enables →" rows: Target Feature | Functional Dependency | Failure Impact
2. For each enablement interface:
   a. **Code existence check** (always — no MCP needed):
      - Grep for the interface (function, component, API endpoint) in the Feature's code
      - If not found → ❌ "Enablement interface not implemented"
   b. **Runtime smoke test** (if MCP or Playwright CLI available):
      - Navigate to the relevant screen and verify the interface element is visible/interactive
      - For API endpoints: `curl` the endpoint and verify non-error response
3. Report (each check tagged `(code)` or `(runtime)` to distinguish verification depth):
   ```
   🔗 Enablement Interface Smoke Test:
     Enables → F005-chat: Provider settings panel
       (code) ✅ SettingsPanel component exists
       (runtime) ✅ /settings renders, provider dropdown visible
     Enables → F006-export: Export API endpoint
       (code) ✅ /api/export handler exists
       (runtime) ✅ curl /api/export → 200 OK
   ```
4. **Failed enablement** → ⚠️ **HIGH warning** — downstream Features will likely fail
   Display: `⚠️ Enablement interface for [target] not working — [target Feature] will be blocked at runtime`
5. **Skip if**: No "Enables →" entries in Functional Enablement Chain

**Also check "Blocked by ←" entries** (this Feature's prerequisites):
1. For each "Blocked by ←" row, check if the source Feature has verify status = `success` in sdd-state.md
2. If source Feature is NOT verified: display warning:
   `⚠️ Blocked by F00N-[feature] which has NOT passed verify yet. This Feature's runtime may be affected.`
3. If source Feature IS verified AND app is running: run source Feature's demo in `--ci` mode to confirm it still works
   - If demo fails → ⚠️ warning: `Source Feature F00N-[feature] demo --ci failed — may affect this Feature`

**Step 5 — API Compatibility Matrix Verification** (if plan.md has API Compatibility Matrix):

If `plan.md` contains an `## API Compatibility Matrix` section with 2+ providers:

1. For each provider row in the matrix, verify the implementation handles provider-specific details:
   - **Auth method**: grep for each provider's auth pattern (e.g., `Bearer`, `x-api-key`, `anthropic-version`)
   - **Endpoint URLs**: grep for each provider's base URL or endpoint paths
   - **Response parsing**: grep for each provider's response format (e.g., `choices[0].message`, `content[0].text`)
2. Report:
   ```
   📊 API Compatibility Matrix Verification:
     OpenAI:    Auth ✅ (Bearer found) | Endpoint ✅ | Response ✅
     Anthropic: Auth ✅ (x-api-key found) | Endpoint ✅ | Response ❌ — using OpenAI response format
       ⚠️ Response parsing uses choices[0].message but Anthropic returns content[0].text
     Ollama:    Auth ✅ (no-auth) | Endpoint ✅ | Response ✅
   ```
3. Provider-specific mismatch → ⚠️ **HIGH warning** — will cause runtime auth/parsing failures
4. **Skip if**: No API Compatibility Matrix in plan.md, or < 2 providers

**Step 6 — Integration Contract Data Shape Verification** (if plan.md has Integration Contracts):

> **Skip if**: No `## Integration Contracts` section in plan.md, or no Functional Enablement Chain entries.

Verifies that the data shape contracts defined in plan.md are actually implemented with compatible types and that required bridges exist.

1. Read `SPEC_PATH/[NNN-feature]/plan.md` → `## Integration Contracts` section
2. For each row in the contracts table:
   a. **Interface existence check**: Grep for the Interface (function/API/store method) in the Feature's code
      - If not found → ❌ "Integration interface not implemented"
   b. **Shape compatibility check**: Read the actual type/interface definition from source code
      - Compare the implemented return type/parameter type against the documented Provider/Consumer Shape
      - Check field names, nesting structure, and type compatibility
      - If shapes are structurally incompatible → ❌ "Shape mismatch"
   c. **Bridge implementation check** (if Bridge column specifies an adapter/transform):
      - Grep for the bridge function/adapter in the Feature's code
      - If Bridge is specified but code not found → ❌ "Bridge adapter NOT FOUND"
      - If Bridge is `—` (shapes directly compatible): skip bridge check
3. Report (each check tagged `(code)` or `(runtime)` to distinguish verification depth):
   ```
   🔗 Integration Contract Verification:
     Provides → F005-chat: getActiveTools()
       (code) Interface: ✅ found in src/stores/mcp-store.ts
       (code) Shape: ✅ returns Tool[] matching consumer expectation
     Consumes ← F003-chat-core: ParameterBuilder.build(assistant)
       (code) Interface: ✅ found in src/services/parameter-builder.ts
       (code) Consumer expects: {mcpMode, mcpServers}
       (code) Bridge: ❌ mapMCPStoreToAssistant() NOT FOUND
       ⚠️ No adapter transforms useMCPStore state → assistant.mcpServers format
   ```
4. **Result classification**:
   - Missing interface → ⚠️ **HIGH warning** (enablement interface not implemented)
   - Shape mismatch → ⚠️ **HIGH warning** (will cause runtime TypeError or undefined access)
   - Missing bridge → ⚠️ **HIGH warning** (data will not flow between Features)
   - All checks pass → ✅ Integration contracts verified
5. **If Integration Contracts section missing in plan.md** but Feature has Enablement Chain:
   Display: `⚠️ Integration Contracts not defined in plan.md — cross-Feature data shape compatibility not verified. Consider running /smart-sdd plan [FID] to add contracts.`
