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
| `SPEC_PATH/[NNN-feature]/ui-flows.md` | Entire file | **If exists (GUI Features)** — UI Flow Specs drive Interaction Chain design. Each flow step should map to a chain row. See [ui-flow-spec.md](../ui-flow-spec.md) § Pipeline Integration |

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
- **Interaction Surface Inventory from preceding Features** (GUI only): If preceding Features have `SPEC_PATH/[NNN-feature]/interaction-surfaces.md`, read and inject surfaces that this Feature's plan may affect. When this Feature modifies shared components (layout, router, app shell), the plan architecture must account for preserving Critical/High surfaces. List the surfaces in the Checkpoint so the user can review before plan execution (see `injection/implement.md` § Post-Step Update Rules #3 for inventory format)
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
- Display in Review: `🚫 Interaction Chains section missing — UI propagation paths not documented. BLOCKING.`
- This is **BLOCKING** for UI Features. Without chains, implement creates handlers but skips DOM effects and visual results — producing code that builds but doesn't work visually.
- The agent MUST add the section during Review before approval is offered.
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
| FR | User Action | Handler | Store/State Mutation | Effect | Visual/Output Result | Verify Method |
|----|-------------|---------|---------------------|--------|---------------------|---------------|
| FR-034 | cross-feature: Action in Feature A triggers Feature B behavior | FeatureA/entrypoint:handler() | FeatureB state read/updated | Output reflects FeatureB data | Combined result visible | grep entrypoint for FeatureB reference |
```

**Per-interface examples**:
- **GUI (React)**: `FR-034 | cross-feature: Send with KB | Inputbar:handleSend() | knowledgePicker.selectedIds | CitationBlock inserted | KB source in message`
- **HTTP-API**: `FR-034 | cross-feature: Order triggers payment | POST /orders → PaymentService.charge() | order.status=paid | 201 + payment confirmation`
- **CLI**: `FR-034 | cross-feature: Deploy triggers notify | deploy --notify → NotificationService.send() | deployment.notified=true | "Notification sent to #channel"`

**Why cross-feature rows matter**: Without them, the agent creates new services and components that individually work, but never modifies the existing code to actually use them. The `cross-feature` prefix signals that these chains require **modifying existing Feature code**, not just creating new modules.

**Inline reference/citation rows** (🚫 BLOCKING — for Features with clickable data references):

When the Feature displays inline references (citations, footnotes, tagged items) that the user can click to see details, each clickable reference MUST have an Interaction Chain row:

```markdown
| FR | User Action | Handler | Store Mutation | DOM Effect | Visual Result | Verify Method |
|----|-------------|---------|---------------|------------|---------------|---------------|
| FR-008 | Click citation [N] | onCitationClick(refNum) | — | Tooltip/Popover shows source #N | Source name + content preview | verify: click [2] → tooltip shows source #2's file name |
| FR-008 | Hover citation [N] | onCitationHover(refNum) | — | Preview tooltip appears | File name + snippet | verify: hover → tooltip visible |
| FR-008 | Click tooltip header | onSourceOpen(url) | — | Opens URL in new tab | Source document loaded | verify: new tab opens with correct URL |
```

**CRITICAL**: The Handler column MUST specify the **ID lookup method** explicitly:
```
❌ Handler: "onCitationClick(idx)" — idx is array position (unstable)
✅ Handler: "onCitationClick(refNum) → citations.find(c => c.refNumber === refNum)" — refNumber match (stable)
```

**Rationale (SKF-072)**: Without explicit Interaction Chain rows for clickable references, implement uses the simplest possible lookup (`citations[num-1]`). This breaks when: (1) AI cites out of order, (2) citations are deduplicated, (3) the list is filtered. The chain makes the lookup method an architectural decision, not an implementation accident.

**Downstream flow of cross-feature rows**:
1. **tasks.md** → generates explicit "wire" tasks: "Modify F005/Inputbar.tsx:handleSend() to call getKnowledgeReferencesForMessage()" — with **existing file path** and **modification location** specified
2. **implement** → agent reads the existing file first, then modifies at the specified location
3. **verify** → Phase 2 Step 1f (Cross-Feature File Modification Audit) checks that the target files were actually modified in git diff

**If Integration Contracts have `Consumes ←` entries but NO cross-feature Interaction Chain rows**:
- Display in Review: `🚫 Integration Contracts define cross-Feature dependencies but Interaction Chains have no cross-feature rows. Without explicit chains, implement will create isolated modules that are never wired into existing code. BLOCKING.`

## AI-Generated Reference Pipeline (Features with RAG, web search, tool results — 🚫 BLOCKING)

> **Skip if**: Feature does not involve AI/LLM generating text that references external data.
> **Triggered by**: FR/SC containing "citation", "reference", "RAG", "web search results", "tool call results", "knowledge base search", or any pattern where AI output contains numbered/linked references to external data.

When AI generates text that references external data sources, plan.md MUST include a complete reference pipeline section. Without this, implement uses the simplest approach (array index lookup, no filtering, no renumbering) which breaks in real-world usage.

**Required pipeline stages** (plan.md must address ALL):

| Stage | Design Item | Example | Anti-Pattern |
|-------|-----------|---------|-------------|
| 1. Injection | How search results are formatted in the AI prompt | `[1] "filename.pdf"\ncontent...` | No numbering in prompt → AI can't reference by number |
| 2. AI Rules | Instructions to AI for how to cite | `"Use [N] inline when referencing source material"` | No citation instruction → AI may or may not cite |
| 3. Extraction | How citation numbers are parsed from AI response | `Regex \[(\d+)\]` → `Set<number>` | No extraction → all search results shown as citations |
| 4. Filtering | Only cited results become citation blocks | `searchResults.filter(r => citedNums.has(r.refNumber))` | ❌ All search results → "5 refs" when AI only cited 2 |
| 5. Renumbering | Display number assignment strategy | First-appearance order in text (not search rank order) | ❌ Search rank order → text [3] appears before [1] |
| 6. Storage | Citation block data structure | `{ refNumber(display), originalRefNumber, filePath, text }` | ❌ Array index → breaks when citations reordered |
| 7. Rendering | How numbers in text are transformed for display | Render-time `useMemo` (stored text untouched) | ❌ `updateBlock` to modify text → rendering corruption |
| 8. Interaction | Badge/link click behavior | `shell:openPath(filePath)` or `window.open(url)` | ❌ Raw DOM tooltip → layout shift, no rich preview |

**🚫 BLOCKING**: If the Feature involves AI-referenced external data and plan.md lacks this pipeline → cannot approve plan.

**Anti-pattern summary** (from SKF-073 — 7 failures in one Feature):
```
❌ citations[num - 1]           → breaks when AI cites out of order
❌ all search results as refs   → "5 references" when only 2 were cited
❌ updateBlock to renumber text → React state corruption + markdown parsing failure
❌ inline DOM tooltip           → layout shift, no rich preview
❌ useStore selector .filter()  → new array every render → infinite loop
```

---

## Integration Contract Verification (Features with cross-Feature dependencies)

> **Skip for**: Features with no Functional Enablement Chain entries (no "Enables →" or "Blocked by ←" in pre-context).
> Detected from: pre-context.md "Functional Enablement Chain" section.

After `speckit-plan` completes, if the Feature has Functional Enablement Chain entries, check plan.md for an `## Integration Contracts` section. This section defines the **data shape contract** at each cross-Feature boundary — what one Feature provides and what the other expects.

**Required format** (one row per integration point):

```markdown
## Integration Contracts

| Direction | Target Feature | Interface | Provider Shape | Consumer Shape | Bridge | Architecture |
|-----------|---------------|-----------|---------------|---------------|--------|-------------|
| Provides → | F005-chat | getActiveTools() | `Tool[]` `{name, description, inputSchema}` | — | — | AI Tool |
| Consumes ← | F003-chat-core | ParameterBuilder.build(assistant) | — | `{mcpMode: string, mcpServers: MCPServer[]}` | adapter: mapMCPStoreToAssistant() | Plugin Hook |
```

**Column definitions**:
- **Direction**: `Provides →` (this Feature outputs) or `Consumes ←` (this Feature inputs)
- **Target Feature**: The other Feature at this integration boundary
- **Interface**: The actual function, API, store method, or component prop that crosses the boundary
- **Provider Shape**: The data structure the providing Feature outputs (type signature or field list)
- **Consumer Shape**: The data structure the consuming Feature expects as input
- **Bridge**: If Provider Shape ≠ Consumer Shape, the adapter/transform needed. `—` if shapes are directly compatible
- **Architecture**: The integration pattern. Values: `AI Tool` | `Plugin Hook` | `System Message Injection` | `Direct Import` | `Event/PubSub` | `Middleware`

**Architecture column enforcement (rebuild — 🚫 BLOCKING)**:

In rebuild mode, the Architecture column must match the source app's integration pattern (from SBI `-INT` entries):
```
🚫 Integration Architecture Mismatch (BLOCKING):
  Source B194-INT: "Memory as AI Tool via Plugin hook"
  Plan Architecture: "System Message Injection"

  Source provides memory as an AI Tool (AI decides when to use).
  Plan uses system message injection (forced every message).
  These are fundamentally different patterns with different UX.

  → Change Architecture to "AI Tool" and redesign integration accordingly.
```

**Why this matters**: Without explicit shape contracts AND architecture patterns, integration mismatches (e.g., `mcpMode` vs `mcp.mode`, forced injection vs AI Tool) slip through spec/plan/tasks/implement and are only discovered at runtime. This section makes both the contract and the pattern explicit.

**If `## Integration Contracts` is missing from plan.md** (Feature with Enablement Chain):
- Display in Review: `🚫 Integration Contracts section missing — cross-Feature data shape contracts not defined. BLOCKING.`
- Display: `Risk: Shape mismatches between Features (e.g., different field names, nested vs flat) will only be caught at runtime.`
- This is **BLOCKING** for Features with Enablement Chain entries. Without explicit shape contracts, implement creates isolated modules that are never integrated correctly. The agent MUST add the section during Review before approval is offered.

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
- Display: `🚫 API Compatibility Matrix missing — multiple providers detected but per-provider differences not documented. BLOCKING.`
- Display: `Risk: Using one provider's pattern for all (e.g., OpenAI Bearer + /v1/models for Anthropic) causes runtime auth failures.`
- This is **BLOCKING** for multi-provider Features. Using one provider's auth/endpoint pattern for all causes silent runtime failures. The agent MUST add the section during Review before approval is offered.

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
 "🚫 Interaction Chains section missing — UI propagation paths not documented. BLOCKING."
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
 "🚫 Integration Contracts missing — cross-Feature data shape contracts not defined. BLOCKING."
 If no Enablement Chain entries: omit this section entirely.]

── API Compatibility Matrix (multi-provider only) ─
[If 2+ external API providers detected: show the matrix from plan.md.
 Each row = one provider with auth, endpoints, response format.
 If section is missing from plan.md for a multi-provider Feature, display:
 "🚫 API Compatibility Matrix missing — per-provider differences not documented. BLOCKING."
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

**Pre-ReviewApproval Validation** (before offering options):

Before displaying ReviewApproval options, the agent MUST verify all applicable blocking sections exist:

| Check | Condition | Blocking? |
|-------|-----------|-----------|
| Pattern Constraints present | Always | **YES** — add before approval |
| Interaction Chains present | UI Feature | **YES** — add before approval |
| Integration Contracts present | Feature has Enablement Chain entries | **YES** — add before approval |
| API Compatibility Matrix present | 2+ external API providers detected | **YES** — add before approval |
| UX Behavior Contract present | UI Feature with async operations | ⚠️ Warning — strongly recommended |

If ANY blocking section is missing, the agent MUST add it now (not just warn). Only after all blocking sections are present, proceed to:

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

## Domain Rule Compliance Check (S7 → Pattern Constraints)

> **Purpose**: S7 Bug Prevention rules are loaded from domain modules, but loading ≠ enforcement. This check verifies that active S7 rules are reflected in the plan's Pattern Constraints and Bug Prevention sections. Without this gate, domain-specific prevention rules may be silently ignored.

After plan.md is generated, cross-check the active domain modules' S7 rules against the plan:

**Procedure**:
1. Recall the active S7 Bug Prevention rules from the cached domain profile
2. For each S7 rule applicable to this Feature:
   - Check if Pattern Constraints section addresses this rule's concern
   - Check if Bug Prevention Checks (B-1) below cover this rule
   - Example: S7 rule [gui] "CSS rendering: stale hover state on scroll" → check if Pattern Constraints mentions scroll/hover interaction
   - Example: S7 rule [ipc] "IPC boundary safety: unhandled rejection in main process" → check if Pattern Constraints mentions IPC error handling
3. Classify:
   - **✅ Addressed**: Rule reflected in Pattern Constraints or B-1
   - **⚠️ Missing**: Rule not addressed — add to Pattern Constraints

**Enforcement**: If missing rules are found, the agent MUST add them to Pattern Constraints before offering ReviewApproval. This is **BLOCKING** — Pattern Constraints completeness is already a blocking gate, and this extends it to cover domain-specific rules. Display in Review:
```
── Domain Rule Compliance (S7) ──────────────────
  ✅ [N] domain-specific S7 rules addressed in Pattern Constraints
  ➕ [M] rules auto-added to Pattern Constraints:
     • [async-state] "Unbatched state updates in event handlers"
     • [ipc] "Unhandled rejection crossing IPC boundary"
────────────────────────────────────────────────
```

**Skip if**: No domain modules beyond `_core.md` are active.

---

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

After speckit-plan completes, verify the generated `plan.md` includes a **`## Pattern Constraints`** section. If absent, the agent MUST add it during Review before approval — this is **BLOCKING**. Without Pattern Constraints, implement proceeds without awareness of framework-specific runtime pitfalls, producing code that builds but fails at runtime.

Pattern Constraints identify framework+library interaction patterns known to cause **runtime-only bugs** (pass build, fail at runtime). They are derived from the project's tech stack detected from constitution and pre-context — NOT library-specific but **stack-pattern-generic**.

### Required constraint categories (include all that apply):

| Stack Pattern | Constraint | Rationale |
|---|---|---|
| **External store + reactive framework** (Zustand/Redux/MobX + React/Vue/Svelte) | Selector return values MUST be referentially stable. No new array/object/filtered-list creation per selector call. Use shallow comparison, memoized selectors, or select raw state + derive in component | Frameworks with synchronous external store integration (useSyncExternalStore, computed) will infinite-loop if selectors create new references on every call |
| **Imperative DOM measurement** (resize, scroll position, element size) | Use synchronous layout effects (useLayoutEffect / watchPostEffect / beforeUpdate) for DOM size/position reads, NOT async effects (useEffect / onMounted) | Async effects execute after browser paint — the browser renders one frame with stale/wrong measurements, causing visible flicker |
| **Concurrent/Fiber rendering** (React 18+, Vue 3 Suspense) | No side effects in render path. Pure components must be idempotent under concurrent mode | Concurrent rendering may invoke render multiple times before commit |
| **SSR + hydration** (Next.js, Nuxt, SvelteKit) | Components must produce identical output on server and client for initial render | Hydration mismatch causes full client-side re-render and state loss |
| **Event handler + state update** | Batch state updates within event handlers. Avoid sequential setState calls triggering multiple re-renders | Unbatched updates cause intermediate renders with inconsistent state |
| **Build-time plugin registration** (Tailwind/PostCSS, i18n extractors, codegen, asset pipeline) | Every build-time transformation framework MUST have its plugin registered in the build config (vite.config, webpack.config, next.config, etc.). Verify: plugin listed → scope/scanning configured → build output contains expected artifacts | Missing plugin registration = build passes, types check, app runs, but output is silently incomplete (unstyled UI, raw i18n keys, missing generated types) |
| **Plugin chain ordering** (Babel, PostCSS, Vite plugins) | Plugins with order dependencies must be registered in the correct sequence. Document order constraints when 2+ plugins in the same chain | Wrong order = silent incorrect output or plugin conflict that only manifests at runtime |
| **Code generation pipeline** (GraphQL codegen, Prisma, OpenAPI) | Generated files must be re-generated after schema changes. Build scripts must include codegen step before compilation | Stale generated types = TypeScript passes with old types, runtime fails with new schema |

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

## Source → Target Component Mapping (rebuild mode, BLOCKING)

> Guard 1: Guideline → Gate Escalation. Plan Review rejects if source components are
> unmapped — this is a BLOCKING gate, not a guideline.
> See pipeline-integrity-guards.md § Guard 1.
>
> (See [pipeline-integrity-guards.md](../pipeline-integrity-guards.md) § Guard 7: Rebuild Fidelity Chain)
> **Skip for**: greenfield, add mode, or backend-only Features.

When pre-context.md contains a `## Component Tree` section (populated by reverse-spec Phase 2-7c), the plan MUST include a `## Source → Target Component Mapping` section in plan.md.

### Required format

| Source Component | Source File | Lines | UI Pattern Summary | Target Component | Target File | Notes |
|---|---|---|---|---|---|---|
| [SourceName] | [source/path.tsx] | [N] | [key UI patterns] | [TargetName] | [target/path.tsx] | [1:1 / merged / deferred] |

**UI Pattern Summary column** (🚫 BLOCKING for source components with 300+ lines):

For source components with **300+ lines** (complex UI), this column MUST describe the key UI patterns:
- Layout structure (sections, panels, tabs)
- Modal/dialog triggers
- List rendering method (pagination, infinite scroll, virtualized)
- Key interactions (icon→modal, dropdown→refresh, menu actions)

```
Example:
| MemorySettings | ...settings.tsx | 857 | toggle+gear→modal, user dropdown+add/delete, infinite scroll list, context menu(refresh/reset/delete) | MemorySettings | ...tsx | 1:1 |
```

**Why this matters (SKF-076)**: Without UI Pattern Summary, an 857-line source component gets mapped as "1:1" with no structural guidance. The agent produces a 200-line simplified version that looks nothing like the source. The pattern summary serves as the **structural contract** for implement — every listed pattern must appear in the target.

### Construction rules

1. **Enumerate**: List every component from pre-context.md Component Tree (all levels, not just roots)
2. **Map**: For each source component, identify the target component in plan.md's Project Structure
3. **UI Pattern Summary**: For components with 300+ lines, extract key UI patterns from UI Screen Inventory (if available) or from reading the source component
4. **Account for all**: Every source component must appear in the table with one of:
   - **1:1 mapping**: Direct correspondence (may be renamed)
   - **Merged**: Multiple source components combined into one target (`merged into [TargetName]`)
   - **Split**: One source component split into multiple targets (multiple rows with same source)
   - **Deferred**: Component belongs to a future Feature (`deferred to F00N-name`)
   - **Removed**: Component intentionally excluded (`removed — [reason]`)
4. **No silent omissions**: A source component with no row in this table is a BLOCKING error

### Checkpoint addition

Add to the plan Checkpoint display:
```
📊 Source Component Mapping: [N] source → [M] target ([K] deferred, [J] merged)
```

### Review enforcement

During plan Review HARD STOP:
- If any source component has no mapping AND no explicit "deferred"/"removed" note → **BLOCKING — do not proceed**
- User must either add the mapping or explicitly approve the omission

### Downstream flow

- **tasks.md**: Each UI task should reference its source component(s) from this mapping
- **implement**: Source-First Implementation Gate reads this table to determine which source files to load per task
- **verify**: Phase 3e Source App Comparison checks that all "1:1" mappings actually match structurally

## Data Lifecycle Mapping (rebuild mode, BLOCKING)

> (See [pipeline-integrity-guards.md](../pipeline-integrity-guards.md) § Guard 7: Rebuild Fidelity Chain)
> **Skip for**: greenfield, add mode, or Features with no managed entities.

When pre-context.md contains a `### Data Lifecycle Patterns` section (populated by reverse-spec Phase 2-7d), the plan MUST include a `## Data Lifecycle Mapping` section in plan.md.

### Required format

| Entity | Source Paradigm | Target Paradigm | Justification | Key Components |
|--------|----------------|-----------------|---------------|----------------|
| [EntityName] | [opt-in / opt-out / curated / import-driven] | [same or different] | [why — required if different] | [TargetComponent1, TargetComponent2] |

### Construction rules

1. **Enumerate**: List every entity from pre-context.md § Data Lifecycle Patterns
2. **Map paradigm**: For each entity, declare the target paradigm
3. **Justify divergence**: If Target Paradigm ≠ Source Paradigm, a Justification is MANDATORY. Examples of valid justification:
   - "Source has 200+ models — opt-out UX is impractical. Switch to opt-in with category filter."
   - "Source uses file import but target is cloud-first — switch to API-driven with sync."
4. **No unjustified divergence**: An entity with Source=opt-in and Target=opt-out (or vice versa) WITHOUT justification is a **BLOCKING error**
5. **Key Components**: List the target components that implement this lifecycle (must exist in plan.md Project Structure)

### Checkpoint addition

Add to the plan Checkpoint display:
```
📊 Data Lifecycle Mapping: [N] entities — [M] same paradigm, [K] diverged (justified)
```

### Review enforcement

During plan Review HARD STOP:
- If any entity has paradigm divergence without justification → **BLOCKING — do not proceed**
- If any entity's Key Components don't exist in plan.md Project Structure → **BLOCKING**
- User must approve all paradigm divergences explicitly

### Downstream flow

- **tasks.md**: Data-handling tasks should note the lifecycle paradigm (e.g., "opt-in: implement ManageModelsPopup add flow")
- **implement**: Source-First Implementation Gate verifies data flow logic matches declared paradigm
- **verify**: Round-trip verification checks lifecycle behavior (e.g., "new model is NOT auto-enabled" for opt-in)

## Domain Bug Prevention Compliance Check (S7)

> **Purpose**: Domain modules load S7 Bug Prevention rules into context. These rules describe known failure patterns for the project's domain (e.g., "CSS rendering: avoid inline style recalculation in scroll handlers"). If the plan's architecture doesn't account for these patterns, bugs are likely to surface during implement — where they're far more expensive to fix.

After plan.md is generated, cross-check the active domain modules' S7 rules against the plan's architecture:

**Procedure**:
1. Recall the active S7 Bug Prevention rules from the cached domain profile
2. For each S7 rule applicable to this Feature's scope:
   - Check if plan.md's architecture, patterns, or explicit notes address this rule's concern
   - Example: S7 rule "MQ-003: message queue dead letter handling" → check if plan.md architecture includes DLQ component
   - Example: S7 rule "CSS-001: avoid inline style recalc in scroll" → check if plan.md mentions CSS/rendering strategy
3. Classify:
   - **✅ Addressed**: Plan architecture accounts for this failure pattern
   - **⚠️ Not addressed**: Plan has no mitigation for this known failure pattern

**Display (if gaps found)**:
```
── ⚠️ Bug Prevention Compliance (S7) ──────────
Active S7 rules not addressed in plan architecture:
  ⚠️ [async-state] "Selector instability — memoize selectors"
     → Plan uses global store but doesn't mention selector strategy
  ⚠️ [ipc] "IPC boundary safety — validate payloads"
     → Plan has IPC layer but no validation strategy noted
  ✅ [gui] "CSS rendering — avoid inline style recalc"
     → Plan specifies CSS-only hover states (§ Component Patterns)

[N] of [M] applicable S7 rules addressed by plan.
────────────────────────────────────────────────
```

**Enforcement**: ⚠️ Warning (not blocking) — S7 gaps are design-level risks, not specification errors. Included in plan Review Display so the user is aware. If the user approves with S7 gaps, they accept the risk of encountering these patterns during implement.

**Skip if**: No domain modules loaded, or only `_core.md` is active.

---

## Architecture→Spec FR Coverage Check (plan Review — rebuild ⚠️ WARNING)

> **Purpose**: In rebuild mode, the plan's architecture (project structure, component list, file layout) should cover every FR from the spec. If a spec FR mentions "citation display" but the plan's component structure has no CitationBlock or equivalent, the FR will be implemented ad-hoc without architectural guidance.

**Skip if**: Not rebuild mode, or Feature has no GUI components.

After plan.md is generated (rebuild + GUI):

1. Read spec.md → extract all FR-### that describe UI behavior
2. Read plan.md → extract the Project Structure / component list / file layout
3. For each UI-behavioral FR: verify at least one component/file in the plan covers this behavior
   ```
   ⚠️ Architecture→Spec FR Coverage Gaps:
     FR-008 "citation display with inline numbers" → No component in plan.md covers citation rendering
     FR-012 "drag-and-drop file upload" → No component in plan.md for drag-drop handling
   ```
4. For rebuild: cross-reference with Source→Target Component Mapping. If source has a component for this FR but the plan mapping doesn't include it → explicit gap.

**Enforcement**: ⚠️ WARNING — included in Review. The user should review whether the plan needs component additions before approval.

---

## Source Behavior Depth Check (rebuild + GUI — plan Review 🚫 BLOCKING)

> **Purpose (SKF-074)**: Source app features often have multi-stage pipelines (8+ steps) that SBI reduces to 1 line and plan reduces to 3 steps. The missing 5 steps become "implement surprises" — citation numbering, filtering, rendering patterns that were never designed.

**Skip if**: Not rebuild mode, or Feature has no GUI components.

After plan.md is generated (rebuild + GUI):

1. For each FR with a Source Parity Clause (from specify):
   - Read the source app code for this behavior
   - Count the **number of processing stages** in the source implementation
   - Count the **number of stages** covered by plan.md's architecture + Interaction Chains + AI-Generated Reference Pipeline (if applicable)

2. **Stage count comparison**:
   ```
   ⚠️ Source Behavior Depth Check:
     FR-008 "citation display":
       Source stages: inject→AI-cite→extract→filter→renumber→embed→tooltip→click = 8
       Plan stages:   inject→display = 2
       Gap: 6 stages missing (filter, renumber, embed, tooltip, click, extract)
   ```

3. **Enforcement**:
   - **Gap ≤ 1 stage**: ⚠️ WARNING — plan may be summarizing (acceptable)
   - **Gap ≥ 2 stages**: 🚫 BLOCKING — plan is missing significant processing steps
   - Agent must add the missing stages to plan.md (Interaction Chain rows, AI-Generated Reference Pipeline stages, or Architecture components) before Review approval

> **Rationale**: A plan that covers 2 of 8 source stages will produce an implement that handles 2 stages. The other 6 become ad-hoc fixes during verify, each potentially introducing new bugs (SKF-073: 7 sequential failures from missing pipeline stages).

---

## Technology Compatibility Pre-Research (plan Review — 🚫 BLOCKING for risks, ⚠️ WARNING for unknowns)

> **Purpose**: Libraries and platform APIs change between versions. plan.md's architecture decisions must account for the actual runtime environment, not assume latest-stable behavior. This check surfaces compatibility risks before implement.

After plan.md is generated, check for technology compatibility risks:

1. **Platform Version Breaking Changes**: Read the project's framework/platform version (from package.json, Cargo.toml, pyproject.toml, etc.) and check if plan.md references any APIs deprecated or removed in that version.
   - Example: Electron 40+ removed `File.path` → must use `webUtils.getPathForFile()`
   - Example: React 19 changed `forwardRef` behavior → wrapper patterns may break
   - Example: Python 3.12 removed `distutils` → must use `setuptools`
   - If plan.md references a deprecated API → ⚠️ WARNING in Review: `plan uses [API] which is deprecated in [platform] v[version]. Consider [alternative].`

2. **Library Import Verification**: For each new library added in plan.md's dependencies:
   - Check ESM/CJS compatibility with the project's module system
   - Check if the library has native bindings that need build-time compilation
   - Check version-specific API differences (v1 vs v2 may have different export shapes)
   - ⚠️ WARNING if any compatibility risk is identified

3. **Data Processing Defaults**: For libraries that process data (embedding models, search engines, ML frameworks):
   - Check default parameter values (similarity thresholds, batch sizes, dimension counts)
   - Verify defaults are appropriate for the project's data characteristics
   - Example: cosine similarity threshold 0.7 is too high for most embedding models — text-embedding-3-small typically produces 0.2–0.5 for relevant matches
   - ⚠️ WARNING if plan uses library defaults without explicit validation

4. **Library Import Smoke Test** (🚫 BLOCKING if fails):
   - For each new library in plan.md dependencies, **attempt actual import** in the project environment:
     ```
     # Node.js: node -e "require('pdf-parse')" or node -e "import('pdf-parse')"
     # Python: python -c "import langchain"
     # Go: go build ./... (with new import)
     ```
   - If import fails → 🚫 BLOCKING: `Library [name] cannot be imported in this project environment. [error]. Choose alternative or resolve compatibility before proceeding.`
   - If import succeeds → ✅ proceed
   - **Rationale (SKF-070 #13)**: pdf-parse v2 has incompatible ESM/CJS exports that aren't discoverable until actual import. "It should work" ≠ "it does work."

**Enforcement**:
- Platform breaking changes confirmed → 🚫 BLOCKING (plan must use the correct API)
- Library import failure → 🚫 BLOCKING (plan cannot depend on non-importable library)
- Data processing default concerns → ⚠️ WARNING (included in Review for user decision)
- Unverifiable risks → ⚠️ WARNING

**Skip if**: Feature adds no new dependencies and uses no platform-specific APIs.

---

## Post-Step Update Rules

> **Pre-condition**: The Entity Ownership Conflict Gate (see pipeline.md § Plan Execute+Review step 5) must have passed before these updates run. All ownership conflicts must be resolved first.

1. Read `SPEC_PATH/[NNN-feature-name]/data-model.md`
2. **Entity Schema Consistency Check**: Before updating the registry, compare each entity in data-model.md against `BASE_PATH/entity-registry.md`:
   - **Same name, same owner** → normal update (proceed to step 2a)
   - **Same name, different owner** → caught by Ownership Conflict Gate (should not reach here)
   - **Same name, referencing (not owning), different fields** → ⚠️ **Schema Drift Warning**: the current Feature references entity `[name]` but assumes fields that differ from the registry definition. Display:
     ```
     ⚠️ Schema Drift: [EntityName]
       Registry (owned by [other FID]): fields [a, b, c]
       This Feature's data-model assumes: fields [a, b, d]
       Mismatched: [c] missing, [d] added
       → Align data-model.md with registry, or coordinate with [other FID] to update the entity
     ```
   - **New entity, name similar to existing** (edit distance ≤ 2 or plural/singular variant) → ⚠️ **Naming Collision Warning**: "Entity `Users` is very similar to existing `User` (owned by [FID]). Is this intentional or should it reference the existing entity?"
2a. Update `BASE_PATH/entity-registry.md`:
   - Newly defined entities → Add to entity-registry with `Owner Feature` = current FID
   - Field/relationship changes in existing entities **owned by current FID** → Update entity-registry
   - Field/relationship changes in entities **owned by another FID** → Do NOT update directly. Instead, add a `⚠️ Schema Divergence` note in the entity's section: "[current FID] plan proposes different fields — coordinate with owner [other FID]"
   - Update "Referencing Features" column for all referenced entities
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
   - **Completeness check**: If >30% of source files have `Rebuild Target` = `[multiple]` or blank, display ⚠️ warning: "Rebuild Target mapping is incomplete — plan architecture may not cover all source components. Review before proceeding."
   - **Build config verification**: If source files include build config files (vite.config, webpack.config, tsconfig, babel.config, postcss.config, etc.), verify the plan accounts for migrating their plugin registrations and settings
