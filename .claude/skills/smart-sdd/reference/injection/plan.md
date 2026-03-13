# Context Injection: Plan

> Per-command injection rules for `/smart-sdd plan [FID]`.
> For shared patterns (HARD STOP, Checkpoint, Missing/Sparse Content Handling), see [context-injection-rules.md](../context-injection-rules.md).

---

## Read Targets

| File | Section | Filtering |
|------|---------|-----------|
| `BASE_PATH/features/[FID]-[name]/pre-context.md` | "For /speckit.plan" section | Relevant Feature only |
| `BASE_PATH/features/[FID]-[name]/pre-context.md` | "Runtime Exploration Results" section | **If present (Phase 1.5 completed)** — reference layout patterns and Component Library for component architecture decisions. **If section says "Skipped"**, proceed without runtime context |
| `BASE_PATH/features/[FID]-[name]/pre-context.md` | "Naming Remapping" section | **If present (project identity changed)** — use new identifiers in data models and API contracts |
| `BASE_PATH/entity-registry.md` | Related entity sections | See rules below |
| `BASE_PATH/api-registry.md` | Related API sections | See rules below |
| `BASE_PATH/stack-migration.md` | Category Details + Per-Feature row | **Only if New Stack strategy**. See rules below |
| `SPEC_PATH/[NNN-feature]/spec.md` | Entire file | Finalized spec for the current Feature |

## Entity Registry Filtering Rules

1. Check the **draft related entities** list in the "For /speckit.plan" section of `pre-context.md`
2. Find the `### [Entity Name]` headings in `entity-registry.md` matching those entity names
3. Entities **owned** by the Feature: Extract full schema (Fields, Relationships, Validation Rules, State Transitions, Indexes)
4. Entities **referenced** by the Feature: Extract summary schema (Fields, Relationships only)

> **Greenfield/add note**: If entity-registry.md is empty or has no matching entities, skip entity injection. The Checkpoint notes: "No pre-existing entity schemas — defining from scratch." As preceding Features complete their plans, entity-registry.md will be populated and available for subsequent Features.

## API Registry Filtering Rules

1. Check the **related API** list in the "For /speckit.plan" section of `pre-context.md`
2. Find the matching sections in `api-registry.md` by API path
3. APIs **provided** by the Feature: Extract full contract
4. APIs **consumed** by the Feature: Extract summary contract (Method, Path, Request/Response schema only)

> **Greenfield/add note**: If api-registry.md is empty or has no matching APIs, skip API injection. The Checkpoint notes: "No pre-existing APIs — defining from scratch." As preceding Features complete their plans, api-registry.md will be populated and available for subsequent Features.

## Stack Migration Filtering Rules (New Stack only)

Skip entirely if "Same Stack" strategy or if `stack-migration.md` does not exist.

1. Read the **Migration Overview** table to provide the full technology mapping context
2. Read the **Category Details** sections relevant to the Feature's technology areas (e.g., if the Feature uses ORM, include the ORM/Data Layer section)
3. Read the **Per-Feature Migration Notes** row for the current Feature
4. Read the **Patterns That Require Rethinking** section to highlight areas where the implementation approach must fundamentally differ

This context helps the plan step make technology decisions aligned with the new stack rather than carrying over patterns from the old stack.

## Preceding Feature Actual Implementation Reference

Reference the actual implementation results of dependent preceding Features:
1. Check the dependency relationship in `BASE_PATH/roadmap.md`
2. If the preceding Feature's `SPEC_PATH/[NNN-feature]/plan.md` exists:
   - Read the finalized schema for shared entities from `data-model.md`
   - Read the finalized contract for APIs to consume from `contracts/`
3. This information **takes precedence over** the drafts in entity-registry/api-registry

## Injected Content

- **Dependency information**: List of preceding Features and dependency types
- **Draft entity schemas**: Related entities filtered from entity-registry (or finalized schemas from preceding Features)
- **Draft API contracts**: Related APIs filtered from api-registry (or finalized contracts from preceding Features)
- **Stack migration context** (New Stack only): Technology mapping, per-Feature migration notes, and patterns requiring rethinking from stack-migration.md. Skipped if Same Stack or file missing
- **Runtime exploration context**: If present, layout patterns (e.g., three-column, split-pane) and Component Library observations from Phase 1.5 runtime exploration — reference layout patterns when designing component structure, and observed Component Library when choosing UI framework approach. If the section says "Skipped", proceed without runtime context
- **Technical decisions**: Draft technical decisions from pre-context
- **Preceding Feature actual results**: Reference data-model and contracts from Features that have already completed plan
- **Naming remapping**: If Naming Remapping section exists in pre-context, remind that entity names, API names, and technical terms should use the new identifiers
- **Dependency stubs from preceding Features**: If any preceding Feature's `SPEC_PATH/[NNN-feature]/stubs.md` contains rows where `Dependent Feature` matches the current FID, inject the stub list. These stubs represent interfaces/components that were hardcoded or stubbed and should be resolved by this Feature's architecture. The plan should account for replacing these stubs with real implementations (see `context-injection-rules.md` § Dependency Stub Resolution Injection)
- **Interaction behavior inventory**: If present in pre-context, inject micro-interaction patterns relevant to this Feature — hover behaviors (tooltip components needed), keyboard shortcuts (shortcut framework choice), animations (animation library decision), drag-and-drop (DnD library selection), focus management (focus trap approach). These inform **architectural decisions**: which interaction libraries to adopt, whether to build a shared tooltip/shortcut/animation system, component prop design for interaction states. For **greenfield/add**: if the user defined interactions during specify, plan should account for them in component structure
- **Foundation Technical Constraints** (from sdd-state.md § Foundation Decisions):
  - Decided items that affect architectural choices (e.g., IPC pattern → component communication)
  - T0 Feature dependencies: which Foundation Features must be completed first
  - For T0 Features: Foundation file § F4 grouping as implementation scope reference
  - **If Foundation Decisions section is empty or absent**: Skip Foundation injection, note "No Foundation decisions — framework-agnostic mode"

## Checkpoint Display Content

Show the **actual schemas, contracts, and dependencies** so the user can verify data models and API designs before plan creation:

```
📋 Context for Plan execution:

Feature: [FID] - [Feature Name]

── Dependencies ──────────────────────────────────
[List each preceding Feature with dependency type]
  - F00X-name: [entity dependency / API dependency / etc.]

── Entity Schemas (Owned) ────────────────────────
[For each owned entity: show full schema with fields, types, constraints, relationships]
  ### EntityName
  | Field | Type | Constraints |
  ...

── Entity Schemas (Referenced) ───────────────────
[For each referenced entity: show summary schema]

── API Contracts (Provided) ──────────────────────
[For each API this Feature provides: show full contract]
  ### POST /api/resource
  Request: { ... }
  Response: { ... }

── API Contracts (Consumed) ──────────────────────
[For each API this Feature consumes from others: show summary]

── Technical Decisions ───────────────────────────
[List each technical decision from pre-context]

── Stack Migration Context (New Stack only) ──────
[If New Stack strategy: show technology mapping, migration notes for this Feature,
 and patterns that require rethinking. Omitted if Same Stack or file missing.]

── Runtime Exploration Context ──────────────────
[If present in pre-context — show layout and component observations]
  Layout Patterns: [observed layout patterns, e.g., three-column, split-pane, tab-based]
  Component Library: [observed UI components and framework elements]
  ⚠️ Reference layout patterns when designing component structure,
    and observed Component Library when choosing UI framework approach.
[If "Skipped" — display: "Runtime exploration skipped — proceeding without runtime context."]

── Preceding Feature Overrides ───────────────────
[If applicable: show which drafts were replaced by finalized schemas from preceding Features]

──────────────────────────────────────────────────
Review the above content. You can:
  - Approve as-is to proceed with speckit-plan
  - Request modifications (adjust schemas, contracts, or decisions)
  - Edit entity-registry.md, api-registry.md, or pre-context.md directly before proceeding
```

## Interaction Chain Verification (UI Features only)

> **Skip for**: backend-only, CLI, or library Features (no UI interaction).
> Detected from: constitution-seed.md project type, or if spec.md has no UI-related SCs.

After `speckit-plan` completes, check the generated `plan.md` for an `## Interaction Chains` section. For Features with UI interactions, this section documents the full propagation path of user actions — from click/input through store mutation to DOM effect to visual result.

**Required format** (one row per interactive FR):

```markdown
## Interaction Chains

| FR | User Action | Handler | Store Mutation | DOM Effect | Visual Result | Verify Method |
|----|-------------|---------|---------------|------------|---------------|---------------|
| FR-012 | Click theme toggle | onThemeChange() | settings.theme='dark' | body.classList.add('dark') | Background → #1e1e2e | verify-effect body class "dark" |
| FR-015 | Change font size | onFontSize(18) | settings.fontSize=18 | body.style.fontSize='18px' | All text enlarges | verify-effect body style.fontSize "18px" |
| FR-018 | Toggle sidebar | onToggleSidebar() | ui.sidebarOpen=false | sidebar.classList.add('hidden') | Sidebar disappears | verify-state .sidebar class "hidden" |
```

**Async UX Behavior rows** (for Features with streaming, loading, or multi-step async operations):

Interaction Chains cover **synchronous** state propagation (click → handler → store → DOM). For Features with **asynchronous UX flows** (streaming responses, loading states, error recovery), add rows with the `async-flow` prefix in the User Action column:

```markdown
| FR | User Action | Handler | Store Mutation | DOM Effect | Visual Result | Verify Method |
|----|-------------|---------|---------------|------------|---------------|---------------|
| FR-020 | async-flow: Send message | onSend() | chat.loading=true | .spinner visible, .input disabled | Loading indicator shown | verify-state .spinner visible |
| FR-020 | async-flow: Streaming response | onChunk(text) | chat.messages[-1].content+=text | .message-content textContent updates | Text appears incrementally | verify-effect .message-content textContent "non-empty" |
| FR-020 | async-flow: Stream complete | onComplete() | chat.loading=false | .spinner hidden, .input enabled, auto-scroll | Input re-enabled, scrolled to bottom | verify-effect .chat-area scrollTop "bottom" |
| FR-020 | async-flow: Stream error | onError(err) | chat.error=err | .error-toast visible, .input enabled | Error message shown, can retry | verify-state .error-toast visible |
```

**Async-flow rows capture temporal UX patterns** that sync chains miss:
- **Loading state transitions**: loading=true → spinner visible → loading=false → spinner hidden
- **Streaming behavior**: incremental content updates + auto-scroll during stream
- **Error recovery**: error display + input re-enabled + retry capability
- **Cleanup**: subscriptions/listeners cleaned up on completion or error

Without async-flow rows, the agent implements the handler but may skip: auto-scroll during streaming, loading spinner management, error recovery UI, cleanup on unmount.

**If `## Interaction Chains` is missing from plan.md** (UI Feature):
- Display in Review: `⚠️ Interaction Chains section missing — UI propagation paths not documented.`
- This is a **warning** (not blocking), but strongly recommended before approval.
- The Verify Method column feeds directly into:
  1. **demo Coverage header** → `verify-state`/`verify-effect` verbs in SC→UI Action format
  2. **verify Phase 3** → Tier 2/3 functional SC verification
  3. **implement tasks** → each chain step becomes a testable implementation unit

**Downstream flow**:
1. **plan.md** → chains defined (Verify Method column) — including async-flow rows
2. **tasks.md** → each chain step decomposed into testable tasks (not just "implement handler" — also "apply DOM effect" and "verify visual result"). Async-flow rows generate explicit tasks for loading state, streaming behavior, error recovery, and cleanup
3. **implement** → full chain implemented (handler + store + DOM + visual), not just the handler
4. **verify** → Tier 2 (State Change) and Tier 3 (Side Effect) verification uses Verify Method column
5. **demo** → Coverage header includes `verify-state`/`verify-effect` from Verify Method

**Cross-Feature Integration rows** (for Features that modify existing Feature code):

When Integration Contracts (see below) contain `Consumes ←` entries that require modifying another Feature's source file, add `cross-feature` rows to the Interaction Chains table. These rows trace the data path from the existing Feature's entry point through the new integration code to the end result.

```markdown
| FR | User Action | Handler | Store Mutation | DOM Effect | Visual Result | Verify Method |
|----|-------------|---------|---------------|------------|---------------|---------------|
| FR-034 | cross-feature: Send message with KB | F005/Inputbar:handleSend() | knowledgePicker.selectedIds read | message.content modified with KB refs | Citation blocks in response | grep handleSend for knowledgePicker |
| FR-027 | cross-feature: Render citation | F005/MessageContent:render() | — | CitationBlock component inserted | KB source shown in message | grep MessageContent for CitationBlock |
```

**Why cross-feature rows matter**: Without them, the agent creates new services and components (KnowledgeService, KnowledgePicker) that individually work, but never modifies the existing code (Inputbar.tsx handleSend(), MessageContent renderer) to actually use them. The `cross-feature` prefix signals that these chains require **modifying existing Feature files**, not creating new ones.

**Downstream flow of cross-feature rows**:
1. **tasks.md** → generates explicit "wire" tasks: "Modify F005/Inputbar.tsx:handleSend() to call getKnowledgeReferencesForMessage()" — with **existing file path** and **modification location** specified
2. **implement** → agent reads the existing file first, then modifies at the specified location
3. **verify** → Phase 2 Step 1f (Cross-Feature File Modification Audit) checks that the target files were actually modified in git diff

**If Integration Contracts have `Consumes ←` entries but NO cross-feature Interaction Chain rows**:
- Display in Review: `⚠️ Integration Contracts define cross-Feature dependencies but Interaction Chains have no cross-feature rows. Without explicit chains, implement will create isolated modules that are never wired into existing code.`

## Integration Contract Verification (Features with cross-Feature dependencies)

> **Skip for**: Features with no Functional Enablement Chain entries (no "Enables →" or "Blocked by ←" in pre-context).
> Detected from: pre-context.md "Functional Enablement Chain" section.

After `speckit-plan` completes, if the Feature has Functional Enablement Chain entries, check plan.md for an `## Integration Contracts` section. This section defines the **data shape contract** at each cross-Feature boundary — what one Feature provides and what the other expects.

**Required format** (one row per integration point):

```markdown
## Integration Contracts

| Direction | Target Feature | Interface | Provider Shape | Consumer Shape | Bridge |
|-----------|---------------|-----------|---------------|---------------|--------|
| Provides → | F005-chat | getActiveTools() | `Tool[]` `{name, description, inputSchema}` | — | — |
| Consumes ← | F003-chat-core | ParameterBuilder.build(assistant) | — | `{mcpMode: string, mcpServers: MCPServer[]}` | adapter: mapMCPStoreToAssistant() |
```

**Column definitions**:
- **Direction**: `Provides →` (this Feature outputs) or `Consumes ←` (this Feature inputs)
- **Target Feature**: The other Feature at this integration boundary
- **Interface**: The actual function, API, store method, or component prop that crosses the boundary
- **Provider Shape**: The data structure the providing Feature outputs (type signature or field list)
- **Consumer Shape**: The data structure the consuming Feature expects as input
- **Bridge**: If Provider Shape ≠ Consumer Shape, the adapter/transform needed. `—` if shapes are directly compatible

**Why this matters**: Without explicit shape contracts, integration mismatches (e.g., `mcpMode` vs `mcp.mode`, `Tool[]` vs `{tools: Tool[]}`) slip through spec/plan/tasks/implement and are only discovered at runtime. This section makes the contract explicit so implement can build the bridge and verify can check it.

**If `## Integration Contracts` is missing from plan.md** (Feature with Enablement Chain):
- Display in Review: `⚠️ Integration Contracts section missing — cross-Feature data shape contracts not defined.`
- Display: `Risk: Shape mismatches between Features (e.g., different field names, nested vs flat) will only be caught at runtime.`
- This is a **warning in Review** (not blocking), but strongly recommended before approval.

**Downstream flow**:
1. **plan.md** → Integration Contracts define shape expectations and required bridges
2. **tasks.md** → Bridge adapter tasks generated when Provider Shape ≠ Consumer Shape
3. **implement** → Bridge adapters implemented alongside Feature code
4. **verify** → Phase 2 Step 4b validates shape compatibility and bridge existence

## API Compatibility Matrix Verification (Features with external API integration)

> **Skip for**: Features with no external API calls, or single-provider integrations.
> Detected from: pre-context Source Behavior Inventory (API call behaviors), spec.md FR-### mentioning providers.

After `speckit-plan` completes, check if the Feature integrates **2+ external API providers**.
Detection: scan plan.md and spec.md for multiple provider names (OpenAI, Anthropic, Google, Azure, Ollama, Groq, Mistral, Cohere, etc.)

If multi-provider integration detected, check plan.md for an `## API Compatibility Matrix` section.

**Required format** (one row per provider):

| Provider | Auth Method | Base URL | Key Header | Model Endpoint | Chat Endpoint | Response Format | Notes |
|----------|-----------|----------|-----------|---------------|--------------|----------------|-------|
| OpenAI | Bearer token | https://api.openai.com | Authorization: Bearer $KEY | GET /v1/models | POST /v1/chat/completions | `{choices:[{message}]}` | Standard |
| Anthropic | API key header | https://api.anthropic.com | x-api-key: $KEY | GET /v1/models | POST /v1/messages | `{content:[{text}]}` | Requires anthropic-version header |
| Ollama | None (local) | http://localhost:11434 | — | GET /api/tags | POST /api/chat | `{message:{content}}` | No auth needed |

If `## API Compatibility Matrix` is missing from plan.md:
- Display: `⚠️ API Compatibility Matrix missing — multiple providers detected but per-provider differences not documented.`
- Display: `Risk: Using one provider's pattern for all (e.g., OpenAI Bearer + /v1/models for Anthropic) causes runtime auth failures.`
- This is a **warning in Review** (not blocking), but strongly recommended before approval.

**Downstream flow**:
1. **plan.md** → matrix defined with per-provider contracts
2. **tasks.md** → provider adapter/strategy tasks include all provider variations
3. **implement** → each provider implementation follows its matrix row
4. **verify** → test each provider's auth/endpoint independently (not just the "default" one)

## SDK Migration Awareness (Features with SDK version upgrades)

> **Skip for**: Features with no SDK/library version changes.
> Detected from: plan.md mentioning version upgrade (e.g., "AI SDK v5→v6", "Dexie v3→v4").

If plan.md references an SDK/library **major version upgrade**:

1. Check if plan.md documents the **breaking changes** relevant to this Feature:
   - API renames (e.g., `textDelta` → `text`, `maxTokens` → `maxOutputTokens`)
   - Default behavior changes (e.g., default base URL changed)
   - Removed/deprecated APIs
2. If breaking changes are NOT documented:
   - Display: `⚠️ SDK migration detected ([library] v[old]→v[new]) but breaking changes not documented in plan.md.`
   - Display: `Risk: Type-checked build may pass while runtime behavior breaks due to renamed/removed APIs.`
3. **Downstream flow**: tasks.md should include an "SDK API contract verification" task that validates each breaking change was handled.

## Review Display Content

> **⚠️ SUPPRESS spec-kit output**: `speckit-plan` prints navigation messages like "Ready for /speckit.tasks" — **never show these to the user**. Suppress ALL spec-kit navigation messages. Immediately proceed to the Review Display below. If context limit prevents continuing, show instead: `✅ speckit-plan executed for [FID] - [Feature Name].\n💡 Type "continue" to review the results.`

After `speckit-plan` completes:

**Files to read**:
1. `specs/{NNN-feature}/plan.md` — Read the **entire file** and extract architecture decisions, implementation phases
2. `specs/{NNN-feature}/data-model.md` — Read the **entire file** and extract entity schemas (fields, types, relationships)
3. `specs/{NNN-feature}/contracts/*.md` — Read **all contract files** and extract endpoints (method, path, request/response)
4. `BASE_PATH/features/{FID}-{name}/pre-context.md` → "Related Entities", "Related API Contracts", "Technical Decisions" sections (for diff comparison)

**Display format**:
```
📋 Review: plan.md for [FID] - [Feature Name]
📄 Files: specs/{NNN-feature}/plan.md, data-model.md, contracts/

── Architecture Overview ────────────────────────
[Key architecture decisions from plan.md]

── Data Model ───────────────────────────────────
[Entity schemas from data-model.md — fields, types, relationships]

── API Contracts ────────────────────────────────
[Endpoints from contracts/ — method, path, request/response summary]

── Implementation Phases ────────────────────────
[Phase breakdown with deliverables from plan.md]

── Pattern Constraints ─────────────────────────
[List each constraint with stack pattern and rationale.
 If section is missing from plan.md output, display:
 "⚠️ Pattern Constraints section missing — must be added before approval."]

── Interaction Chains (UI Features only) ───────
[If UI Feature: show the Interaction Chains table from plan.md.
 Each row = one interactive FR with full propagation path.
 If section is missing from plan.md for a UI Feature, display:
 "⚠️ Interaction Chains section missing — UI propagation paths not documented."
 If non-UI Feature: omit this section entirely.]

── UX Behavior Contract (async UI Features only) ─
[If UI Feature with async operations: show the UX Behavior Contract table.
 Each row = one temporal scenario with expected behavior and verify method.
 If section is missing from plan.md for an applicable Feature, display:
 "⚠️ UX Behavior Contract missing — temporal UX expectations not documented."
 If sync-only UI Feature or non-UI Feature: omit this section entirely.]

── Integration Contracts (cross-Feature deps only) ─
[If Feature has Functional Enablement Chain: show the contracts from plan.md.
 Each row = one integration boundary with Provider/Consumer shapes and bridge.
 If section is missing from plan.md for a Feature with Enablement Chain, display:
 "⚠️ Integration Contracts missing — cross-Feature data shape contracts not defined."
 If no Enablement Chain entries: omit this section entirely.]

── API Compatibility Matrix (multi-provider only) ─
[If 2+ external API providers detected: show the matrix from plan.md.
 Each row = one provider with auth, endpoints, response format.
 If section is missing from plan.md for a multi-provider Feature, display:
 "⚠️ API Compatibility Matrix missing — per-provider differences not documented."
 If single-provider or no external API: omit this section entirely.]

── SDK Migration (version upgrades only) ─────────
[If SDK/library major version upgrade detected: show documented breaking changes.
 If breaking changes not documented, display:
 "⚠️ SDK migration detected but breaking changes not documented."
 If no version upgrade: omit this section entirely.]

── Differences from Draft ───────────────────────
[Compare with pre-context.md drafts:
 - Added: entities/APIs that spec-kit added beyond the drafts
 - Changed: schemas or contracts whose structure significantly changed
 - Architecture decisions that differ from "Technical Decisions" draft]

── Files You Can Edit ─────────────────────────
  📄 specs/{NNN-feature}/plan.md
  📄 specs/{NNN-feature}/data-model.md
  📄 specs/{NNN-feature}/contracts/*.md
You can open and edit these files directly, then select
"I've finished editing" to continue.
──────────────────────────────────────────────────
```

**HARD STOP** (ReviewApproval): Options: "Approve", "Request modifications", "I've finished editing". **If response is empty → re-ask** (per MANDATORY RULE 1).

---

## UX Behavior Contract (mandatory for UI Features with async operations)

> **Skip for**: backend-only, CLI, or library Features. Also skip for UI Features with only synchronous interactions (forms, toggles, navigation — covered by Interaction Chains alone).
> **Required for**: UI Features with streaming, real-time updates, complex loading states, or multi-step async flows.

After speckit-plan completes, verify the generated `plan.md` includes a **`## UX Behavior Contract`** section for applicable Features. If absent, the agent MUST add it during Review before approval.

The UX Behavior Contract makes **expected temporal behavior** explicit — things that FR-### describes functionally but not experientially. Without this, the agent implements the function but not the experience.

**Required format**:

```markdown
## UX Behavior Contract

| Scenario | Expected Behavior | Failure Behavior | Verify Method |
|----------|-------------------|------------------|---------------|
| Streaming response active | Chat area auto-scrolls to show latest text; user scroll-up pauses auto-scroll | No scroll = user can't see new text without manual scrolling | verify-effect .chat-area scrollTop "bottom" |
| Message sending | Send button disabled + spinner; input field disabled | Double-send if button not disabled; lost input if field clears prematurely | verify-state button#send disabled "true" |
| API error during stream | Error toast appears; input re-enabled; partial response preserved | Silent failure = user thinks app frozen; lost partial response | verify-state .error-toast visible |
| Long loading (>3s) | Skeleton/placeholder shown; cancel option available | Blank screen = user thinks app crashed | verify-state .skeleton visible |
| Stream stale (no events for N seconds) | Timeout indicator shown; input re-enabled; retry option available | UI locked in "generating" state forever; user must reload app | verify-state button#send disabled "false" |
| Component unmount during stream | Stream subscription cancelled; no state update after unmount | Memory leak; "setState on unmounted component" warning | — (code review) |
```

**Key principles**:
- Each row describes a **temporal scenario** (not just input→output, but what happens over time)
- **Expected Behavior** = what the user should see/experience
- **Failure Behavior** = what happens if this is NOT implemented (helps agent understand WHY it matters)
- **Verify Method** = same verb syntax as Interaction Chains, feeds into VERIFY_STEPS and demo

**Downstream flow**:
1. **plan.md** → UX Behavior Contract defined
2. **tasks.md** → each UX behavior generates explicit implementation tasks (not just "add streaming" but "add auto-scroll during streaming", "add scroll-pause on user scroll-up", "add loading skeleton after 3s")
3. **implement** → each task explicitly implements the temporal behavior
4. **verify** → Phase 2 Step 3b (UX Behavior Contract Verification) uses Verify Method column for temporal checks
5. **demo** → VERIFY_STEPS includes temporal verification sequences (wait-for + verify)

## Bug Prevention Checks (B-1)

> Pre-implementation bug prevention checks at the plan stage.
> Items below are reviewed during post-plan Review; omissions are shown as ⚠️ warnings.

### Runtime Compatibility

- **Target Runtime Constraints**: Verify JS/CSS constraints of target runtime (browser version, Node.js version, Electron version)
- **API Compatibility**: Confirm Web API / Node API availability in target runtime (e.g., `structuredClone`, CSS `container queries`)
- **Polyfill Strategy**: Specify polyfill approach when using unsupported APIs

### State Management Anti-patterns

- **Shared Mutable State**: Detect patterns where multiple components/modules directly mutate the same state
- **Circular Dependencies**: Check for circular dependencies between stores
- **Store Initialization Order**: Warn about logic that depends on store initialization order

### Async & Concurrency

- **Race Condition Analysis**: Identify concurrent requests, optimistic updates, debounce/throttle points
- **Unhandled Promise Rejection**: Specify error handling strategy for async functions
- **Cleanup on Unmount**: Strategy for cleaning up subscriptions/timers/listeners on component unmount

### Dependency Safety

- **Store Dependency Graph**: Visualize dependency directions between stores/services, detect cycles
- **Downgrade Compatibility**: Check for breaking changes when dependent library major versions differ

---

## Pattern Constraints (mandatory plan.md output section)

After speckit-plan completes, verify the generated `plan.md` includes a **`## Pattern Constraints`** section. If absent, the agent MUST add it during Review before approval.

Pattern Constraints identify framework+library interaction patterns known to cause **runtime-only bugs** (pass build, fail at runtime). They are derived from the project's tech stack detected from constitution and pre-context — NOT library-specific but **stack-pattern-generic**.

### Required constraint categories (include all that apply):

| Stack Pattern | Constraint | Rationale |
|---|---|---|
| **External store + reactive framework** (Zustand/Redux/MobX + React/Vue/Svelte) | Selector return values MUST be referentially stable. No new array/object/filtered-list creation per selector call. Use shallow comparison, memoized selectors, or select raw state + derive in component | Frameworks with synchronous external store integration (useSyncExternalStore, computed) will infinite-loop if selectors create new references on every call |
| **Imperative DOM measurement** (resize, scroll position, element size) | Use synchronous layout effects (useLayoutEffect / watchPostEffect / beforeUpdate) for DOM size/position reads, NOT async effects (useEffect / onMounted) | Async effects execute after browser paint — the browser renders one frame with stale/wrong measurements, causing visible flicker |
| **Concurrent/Fiber rendering** (React 18+, Vue 3 Suspense) | No side effects in render path. Pure components must be idempotent under concurrent mode | Concurrent rendering may invoke render multiple times before commit |
| **SSR + hydration** (Next.js, Nuxt, SvelteKit) | Components must produce identical output on server and client for initial render | Hydration mismatch causes full client-side re-render and state loss |
| **Event handler + state update** | Batch state updates within event handlers. Avoid sequential setState calls triggering multiple re-renders | Unbatched updates cause intermediate renders with inconsistent state |

### Always include (regardless of stack):
- **Error Boundary requirement**: Every route/page-level component MUST be wrapped with an Error Boundary (or framework equivalent). Uncaught render errors must not crash the entire application — they must be caught, reported, and display a fallback UI.

### Visual Reference context (rebuild mode only):
- If `specs/reverse-spec/visual-references/` exists and contains reference screenshots for screens this Feature covers, note the relevant screenshot paths in Pattern Constraints. These serve as visual targets for implementation fidelity.

### How Pattern Constraints flow downstream:
1. **plan.md** → Pattern Constraints section documents the constraints
2. **tasks.md** → Pattern Audit task(s) reference the constraints
3. **implement** → Each parallel agent receives Pattern Constraints as context before task execution
4. **verify** → Post-implement pattern compliance grep validates constraint adherence

---

## Post-Step Update Rules

1. Read `SPEC_PATH/[NNN-feature-name]/data-model.md`
2. Compare with `BASE_PATH/entity-registry.md`:
   - Newly defined entities → Add to entity-registry
   - Field/relationship changes in existing entities → Update entity-registry
   - Update "Used by Features" column
3. Read `SPEC_PATH/[NNN-feature-name]/contracts/`
4. Compare with `BASE_PATH/api-registry.md`:
   - Newly defined APIs → Add to api-registry
   - Contract changes in existing APIs → Update api-registry
   - Update "Cross-Feature Consumers" information
5. **Rebuild Target Update** (rebuild/adoption mode only — skip if Source Path = `N/A`):
   Read `SPEC_PATH/[NNN-feature-name]/plan.md` architecture/file structure → Update `BASE_PATH/features/[FID]-[name]/pre-context.md` "Related Original File List" table:
   - For each original source file, populate the `Rebuild Target` column with the expected new path from the plan's architecture
   - Match by component role/functionality (e.g., original `ChatPanel.vue` → new `src/components/ChatPanel.tsx`)
   - If a 1:1 mapping is unclear, set `Rebuild Target` to `[multiple]` or `[see plan.md]`
