# Context Injection: Specify + Clarify

> Per-command injection rules for `/smart-sdd specify [FID]` and the conditional Clarify sub-step.
> For shared patterns (HARD STOP, Checkpoint, Missing/Sparse Content Handling), see [context-injection-rules.md](../context-injection-rules.md).
>
> **Source App Runtime Reference** (rebuild/adoption): If the user or agent needs to verify a UI detail during specify (e.g., "is this field a dropdown or text input?"), the source app can be launched using [`shared/runtime/app-launch.md`](../../../shared/runtime/app-launch.md). This is NOT mandatory — it's available on-demand when static analysis (pre-context, screenshots) is insufficient.

---

## Scale & Cross-Concern Adjustments (🚫 BLOCKING)

> Apply [`context-injection-rules.md`](../context-injection-rules.md) § Scale Modifier Enforcement + § Cross-Concern Integration Enforcement before proceeding. If not applied → output will not match project maturity/team context.

**specify-specific adjustments**:
- `prototype` → FR scope reduced to core-only, SC reduced to happy-path
- `production` → add edge-case SCs, error-handling FRs, accessibility requirements
- Cross-Concern: verify SCs cover combined behavior patterns (e.g., `gui` + `realtime` → SC for reconnection UI; `gui` + `ai-assistant` → SC for streaming display)

```
❌ WRONG: Generate SCs without checking Scale → production project gets prototype-level coverage
✅ RIGHT: Read Scale → adjust SC depth → verify cross-concern SCs present
```

---

## Domain Module Filtering (per _resolver.md Step 5)

After domain modules are merged (Steps 1-4), retain ONLY these sections for `specify`:

| Active (retain) | Skipped (discard from context) |
|-----------------|-------------------------------|
| S0, S1, S5, S9, A2, A3, A5 | S2, S3, S6, S7, S8 |

Display in Checkpoint: `📊 Domain: [N] modules → [M] sections active (S0,S1,S5,S9,A2,A3,A5) | [K] skipped`

🚫 Do NOT retain skipped sections. They consume context budget without contributing to specify output.

---

## Specify

### Read Targets

| File | Section | Filtering |
|------|---------|-----------|
| `SPEC_PATH/[NNN-feature]/spec-draft.md` | Entire file | **If present (rebuild mode)** — THIS IS THE PRIMARY INPUT. spec-draft contains detailed FR/SC with UI control types, interaction patterns, error paths, and data pipeline stages. speckit-specify should **refine** this draft, not generate from scratch. See "Spec-Draft Seeding Protocol" below |
| `SPEC_PATH/[NNN-feature]/pre-context.md` | "For /speckit.specify" section | Relevant Feature only |
| `SPEC_PATH/[NNN-feature]/pre-context.md` | "UI Flow Specifications" section | **If present (rebuild with Runtime Exploration)** — cross-reference against spec-draft FR/SC for completeness. If spec-draft is absent, this becomes the primary source for FR/SC generation |
| `SPEC_PATH/[NNN-feature]/pre-context.md` | "Source Behavior Inventory" section | **If present (rebuild/adoption/add mode with SBI)** — ensure FR-### cover all P1/P2 behaviors |
| `SPEC_PATH/[NNN-feature]/pre-context.md` | "UI Component Features" section | **If present (frontend/fullstack rebuild)** — ensure FR-### cover all UI features |
| `BASE_PATH/business-logic-map.md` | Relevant Feature section | Filtered by Feature ID. **If file does not exist (greenfield/add), skip entirely** |
| `SPEC_PATH/[NNN-feature]/pre-context.md` | "Source Reference" section | Reference to original file list. **If N/A (greenfield), skip** |
| `SPEC_PATH/[NNN-feature]/pre-context.md` | "Runtime Exploration Results" section | **If present (Phase 1.5 completed)** — reference observed UI layouts, user flows, and errors when drafting FR/SC. **If section says "Skipped"**, proceed without runtime context |
| `SPEC_PATH/[NNN-feature]/pre-context.md` | "Naming Remapping" section | **If present (project identity changed)** — use new identifiers in requirements |
| `BASE_PATH/domain-profile-instance.md` | Per-Concern Decisions, Per-Feature Domain Summary | **Feature 2+ only.** Check Per-Concern Decisions for consistency with preceding Features' choices. Read Per-Feature Domain Summary to understand inherited constraints |

### Source Reference Path Resolution

File paths in pre-context.md's Source Reference and Static Resources are **relative to Source Root** (i.e., the original source directory). The pre-context.md header shows `Source Root: $SOURCE_ROOT` as a placeholder — the actual value is stored in `sdd-state.md` → `Source Path` field.

To resolve file paths at runtime:

1. Read `Source Path` from `sdd-state.md` to get the Source Root value
2. For each relative path in Source Reference / Static Resources, resolve as: `[Source Path]/[relative path]`
3. **Before injecting**, verify that the resolved files actually exist. If a file is missing (e.g., source was moved/deleted), note it in the Checkpoint: "⚠️ Source file not found: [resolved path]"

| Mode | Source Path (= Source Root) | Path Resolution |
|------|---------------------------|-----------------|
| **reverse-spec (rebuild)** | Absolute path (e.g., `/Users/dev/old-project`) | Prepend Source Path to each relative file in Source Reference |
| **add (incremental)** | `.` (CWD) | Files are in the current working directory — resolve relative to CWD. Read the existing source to understand current implementation before specifying changes |
| **greenfield** | `N/A` | Skip Source Reference entirely — no existing source to reference |

### Spec-Draft Seeding Protocol (rebuild mode)

> **Why this protocol exists**: speckit-specify generates spec.md from scratch using context injection. When it generates from scratch, it compresses UI details — "Dropdown with auto-fill" becomes "select model", "7-stage data pipeline" becomes "process files". By providing a spec-draft.md as seed, speckit-specify REFINES instead of GENERATES, preserving the detail reverse-spec captured.

**When spec-draft.md exists** (rebuild mode):

1. **Read spec-draft.md in full** — this contains detailed FR/SC with UI control types, error paths, data pipeline stages
2. **Inject as seed content** for speckit-specify:
   - Include spec-draft FR/SC in the context before spec generation
   - Instruct speckit-specify: "Use these draft requirements as the baseline. Refine wording, fill gaps, add domain-specific SC patterns (from S1 rules), but do NOT compress or abstract. A Dropdown MUST stay a Dropdown. An auto-fill MUST stay an auto-fill."
3. **Post-execution cross-check** (added to Post-Execution Verification Sequence):
   - Compare generated spec.md FR count against spec-draft FR count
   - If spec.md has FEWER FRs than spec-draft → ⚠️ WARNING: "spec.md has [N] FRs but spec-draft had [M]. [M-N] requirements may have been compressed or dropped."
   - For each spec-draft FR with explicit UI control (Dropdown, Slider, etc.): verify spec.md preserves the control type → if abstracted to generic "input" → 🚫 BLOCKING: "FR-### was 'Dropdown' in spec-draft but 'input' in spec.md. UI control downgrade."

**When spec-draft.md does NOT exist** (greenfield, add, adopt without runtime exploration):
- No seed — speckit-specify generates from pre-context drafts as before
- No cross-check applies

### Feature Section Filtering Rules (business-logic-map.md)

1. Find the section in `business-logic-map.md` that starts with the `## F[ID]` heading
2. Extract the Core Rules, Validation Logic, and Workflows sections for that Feature
3. Extract rules related to the Feature from the Cross-Feature Rules section

### Injected Content

- **Feature summary**: Feature description and scope from pre-context
- **Draft requirements (FR-###)**: Draft Functional Requirements extracted from pre-context
- **Draft success criteria (SC-###)**: Draft Success Criteria extracted from pre-context. For UI Features, SCs should include verifiable UI actions where possible (e.g., "User enters credentials in login form and clicks Submit → dashboard screen is displayed"). These SC descriptions are converted to automated verification actions in the demo script's Coverage header
- **Source behavior inventory**: If present, the function-level behavior list with priorities — remind that each P1/P2 behavior should map to at least one FR-###. This prevents functionality loss during rebuild. **NEW entries** (Origin=`new`): Treat as new requirements to be specified, not as coverage of existing code. They should still map to FR-### but do not represent original source behaviors
- **UI component features**: If present, the third-party UI library capabilities — remind that each UI feature should map to an FR-###. These features (toolbar items, editing modes, plugins) are invisible to function-level analysis
- **Interaction behavior inventory**: If present, the micro-interaction patterns from pre-context (hover behaviors, keyboard shortcuts, animations, focus management, drag-and-drop, context menus, scroll behaviors) — remind that each P1/P2 interaction should map to an FR-### or be captured as a verifiable SC. For **greenfield/add** projects without a pre-existing inventory: prompt the user to define key micro-interactions during specify (e.g., "Should this Feature have keyboard shortcuts? Tooltips on action buttons? Drag-and-drop reordering?") and record defined interactions as new FR-### entries. SC descriptions should include interaction verbs (e.g., "User hovers over settings icon → tooltip 'Settings' appears", "User presses Ctrl+K → command palette opens")
- **Runtime exploration observations**: If present, the per-screen UI observations from Phase 1.5 runtime exploration — observed UI layouts inform FR descriptions, observed user flows inform SC scenarios, observed errors inform edge case SCs. If the section says "Skipped", note it and proceed without runtime context
- **Business rules**: List of rules for the Feature from business-logic-map (skipped if business-logic-map.md does not exist)
- **Edge cases**: Edge cases found in pre-context and business-logic-map
- **Original source reference**: File list from Source Reference (skipped if Source Reference is N/A)
- **Naming remapping**: If Naming Remapping section exists in pre-context, remind that requirements and descriptions should use the new identifiers (e.g., "AngduProvider" not "CherryProvider")
- **Foundation Decisions** (from sdd-state.md § Foundation Decisions):
  - Framework: {name}
  - Critical decisions relevant to this Feature's domain
  - For T0 Features: full Foundation category items as requirements source
  - For T1+ Features: only Foundation decisions that constrain this Feature
  - **If Foundation Decisions section is empty or absent**: Skip Foundation injection, note "No Foundation decisions — framework-agnostic mode"

### Preceding Feature Result Reference

When a completed preceding Feature exists and the current Feature depends on it:
1. Check the dependency relationship in `BASE_PATH/roadmap.md`
2. If the preceding Feature's `SPEC_PATH/[NNN-feature]/spec.md` exists, reference the relevant requirements
3. **Pre-context freshness check**: Read the preceding Feature's actual implementation artifacts (`SPEC_PATH/[NNN-feature]/data-model.md`, `contracts/`) and compare key assumptions against this Feature's `pre-context.md`. If a discrepancy is found (e.g., pre-context says "better-sqlite3" but preceding Feature actually used "electron-store"), flag it at Checkpoint with ⚠️ and override the stale assumption in the injected context.
4. Display "Preceding Feature [FID] spec referenced" information at the Checkpoint

### Checkpoint Display Content

Show the **actual content** that will be injected, so the user can review requirements, success criteria, and business rules before spec creation:

```
📋 Context for Specify execution:

Feature: [FID] - [Feature Name]

── Feature Summary ───────────────────────────────
[Actual feature description and scope from pre-context]

── Draft Requirements ────────────────────────────
[List each FR-### with its full description]
  FR-001: ...
  FR-002: ...

── Draft Success Criteria ───────────────────────
[List each SC-### with its full description]
  SC-001: ...
  SC-002: ...

── Source Behavior Inventory (rebuild/adoption) ──
[If present in pre-context — list P1/P2 behaviors with B### IDs]
  P1: B001 registerUser(), B002 loginUser(), B003 requireAuth() ...
  P2: B004 resetPassword(), B005 updateProfile() ...
  ⚠️ Ensure each P1/P2 behavior maps to at least one FR-### with [source: B###] tag.
  Example: FR-001: User registration with email verification [source: B001]

── UI Component Features (frontend/fullstack rebuild) ─
[If present in pre-context — list UI library capabilities]
  NoteEditor (@toast-ui/editor): Bold/Italic toolbar, WYSIWYG mode, ...
  ⚠️ Ensure each UI feature maps to an FR-###.

── Runtime Exploration Observations ─────────────
[If present in pre-context — show per-screen observations]
  Layout: [observed layout pattern, e.g., three-column, split-pane]
  Key Elements: [observed interactive elements, forms, tables]
  User Flows: [observed navigation paths and interactions]
  Errors/Edge Cases: [observed error states or edge cases]
  ⚠️ Reference observed UI layouts when describing FR scope,
    observed user flows when writing SC scenarios,
    and observed errors when defining edge case SCs.
[If "Skipped" — display: "Runtime exploration skipped — proceeding without runtime context."]

── Business Rules (from business-logic-map) ──────
[List each business rule with its description]

── Edge Cases ────────────────────────────────────
[List each edge case]

── Original Source Files ─────────────────────────
[List of source files for reference]

── Preceding Feature References ──────────────────
[If applicable: what was referenced from preceding Features]

── Dependency Stubs Targeting This Feature ────────
[If preceding Features have stubs.md entries where Dependent Feature = current FID]
  From [FID]-[name] stubs.md:
    • [File:Line] — [Current (Stub)] → [Target (Real)]
  ⚠️ This Feature should resolve these stubs. Ensure requirements/SCs cover the target behavior.
[If no preceding stubs target this Feature: skip this block entirely]

── Feature Reachability Path (GUI Features) — 🚫 BLOCKING ────
[If GUI interface is active:]
  🚫 Every GUI Feature spec MUST include **separate FRs for EACH user entry point**
  describing how the user navigates to this Feature from the app.

  [If rebuild mode AND pre-context § Entry Points exists:]
    Source app entry points for this Feature:
    [Display all rows from pre-context § Entry Points table]

    **BLOCKING**: Each source entry point MUST have a corresponding FR in spec.md.
    Missing entry points = missing FRs = spec Review cannot be approved.

    Example (3 entry points = 3 FRs):
      FR-035: User clicks Knowledge icon in sidebar → /knowledge page
      FR-036: User clicks KB button in chat inputbar → KB selection panel
      FR-037: User configures KB in assistant settings → KB linked to assistant

  [If greenfield mode:]
    ⚠️ Define at least one FR describing how the user navigates to this Feature.
    If accessing this Feature requires modifying another Feature's UI (e.g., adding
    an icon to the Navbar), declare it as an Integration Contract.

  [If entry points not in pre-context:]
    ⚠️ No entry points extracted. Ensure at least one navigation FR is defined.
    For rebuild: consider running `/reverse-spec` Entry Point Extraction first.

[If not GUI: skip this block entirely]

── Functional Enablement Chain ─────────────────
[If present in pre-context — show enablement/blocking relationships]
  Enables → F005-chat: Provider settings panel works
  Blocked by ← F001-shell: Window frame config applied
  ⚠️ Ensure SC-### cover the functional interfaces that downstream Features depend on.
    These interfaces are what downstream Features need to work at runtime.
[If section empty, absent, or "None": skip this block entirely]

── Runtime-Verified Defaults ──────────────────────
> 🚫 G3 [G3]: Cross-Stage Trust Breakers — Gate 1 (specify entry). Runtime config defaults
> must be independently verified at specify entry, not blindly trusted from code analysis.
> See pipeline-integrity-guards.md § Guard 3.

[If rebuild mode AND Feature involves settings/modes/configuration
 AND runtime-exploration.md has relevant default values:]
  ⚠️ The following defaults were verified by running the source app (reverse-spec Phase 1.5):
    • navbarPosition: 'top' (code analysis had 'left' — CORRECTED)
    • theme: 'dark'
    • sidebarWidth: 260px
  Use these runtime-verified values in FR/SC, NOT code analysis values.
[If not rebuild mode, or Feature has no settings/modes: skip this block entirely]

──────────────────────────────────────────────────
Review the above content. You can:
  - Approve as-is to proceed with speckit-specify
  - Request modifications (add/remove/change requirements or criteria)
  - Edit pre-context.md or business-logic-map.md directly before proceeding
```

### Post-Execution Verification Sequence

> **⚠️ SUPPRESS spec-kit output**: `speckit-specify` prints messages like "Ready for /speckit.clarify or /speckit.plan." — **never show these to the user**. Suppress ALL spec-kit navigation messages. Immediately proceed to the verification steps and Review Display below. **Catch-all**: If this response ends without AskUserQuestion (for ANY reason — context limit, tool error, or any other cause), you MUST show: `✅ speckit-specify executed for [FID] - [Feature Name].\n💡 Type "continue" to review the results.` — Do NOT end silently.

After `speckit-specify` completes and BEFORE assembling the Review Display, run these checks in order:

1. **SBI Accuracy Cross-Check** (if applicable — rebuild/adoption with SBI)
2. **Platform Constraint FR Verification** (if applicable — pre-context has Platform Constraints)
3. **Edge Case Coverage Check** (if applicable — pre-context has Edge Cases)
4. **Multi-Provider API Detection** (if applicable — 2+ external API providers in FR-###)
5. **Runtime Default Coverage Check** (if applicable — rebuild mode + Feature has settings/mode/configuration)
6. **Build-Time Plugin FR Check** (if applicable — rebuild mode + source has build config with plugins)
7. **Domain Rule Compliance Check (S1)** (always — see § Domain Rule Compliance Check below)
8. **External API Dependency Edge Cases** (if Feature consumes external APIs — see below)
9. **Error Scenario Coverage Check** (always — see § Error Scenario Coverage Check below)
10. **Integration Method Specificity Check** (if Feature integrates with AI/LLM pipeline — rebuild only — see below)
11. **Data Pipeline Completeness Check** (if Feature processes data through multiple stages — see below)
12. **FR Granularity Check** (always — see below)
13. **SC Testability Check** (always — see below)
12. **UI Flow Spec Generation** (GUI Features — see § UI Flow Spec Generation below)
13. **Source Screenshot Reference** (rebuild/adoption mode with runtime observations):
    If `pre-context.md` has runtime screenshots (from reverse-spec Phase 1.5 or code-explore orient):
    - Display the **relevant screen screenshot(s)** for this Feature in the Review
    - Format: `🖼️ Source app reference: [screenshot path] — [screen name]`
    - This helps the user compare spec.md against the actual source app UI
    - If a Form Field Inventory exists for this Feature's screens, display it alongside the FR list so the user can spot missing controls
    ```
    🖼️ Source Reference (from runtime exploration):
      Screen: Knowledge Base — specs/_global/visual-references/05-knowledge.png
      Screen: KB Create Dialog — specs/_global/visual-references/kb-create-dialog.png

      Form Field Inventory (KB Create Dialog):
      | Field | Control Type | Auto-fill | Validation |
      | Name | TextInput | no | required |
      | Model | Dropdown (configured providers only) | no | required |
      | Dimensions | NumberInput (readonly) | yes (from model) | auto |

      Compare: Do FR-001~003 cover all fields and controls above?
    ```

14. **Assemble Review Display** (include any ⚠️/❌ from steps 1-13)
15. **HARD STOP** (ReviewApproval)

### SBI Accuracy Cross-Check (rebuild/adoption mode)

> **Purpose**: SBI text can be misinterpreted without checking the actual source. Example: "Manage sidebar tabs (assistants, topics, sessions)" was interpreted as 3 separate tabs, but the original had 2 tabs (sessions was a conditional view within topics). Reading the source prevents such misinterpretation.

If pre-context has SBI entries AND Source Reference files:

1. Read the original source files **relevant to P1/P2 SBI entries** (resolved via Source Reference Path Resolution above — only files whose functions appear in P1/P2 SBI, not all Source Reference files)
2. For each P1/P2 SBI entry that maps to an FR-###, spot-check:
   - Does the FR description match what the source code actually does?
   - Are counts correct? (e.g., tab count, form field count, block type count)
   - Are conditional behaviors captured? (e.g., feature flags, platform-specific branches)
3. If any discrepancy is found, append to Review Display:
   ```
   ── ⚠️ SBI Accuracy Concerns ─────────────────────
   B105 → FR-012: SBI says "3 sidebar tabs" but source HomeTabs.tsx
     shows 2 tabs (Sessions is conditional view within Topics tab).
   → Recommend updating FR-012 before approval.
   ────────────────────────────────────────────────────
   ```
4. **If visual references exist** (`specs/_global/visual-references/`): Cross-reference UI structure claims in FRs against reference screenshots. Visual references are the ground truth for tab counts, layout structure, and visible elements.

5. **Enforcement**: If discrepancies are found → **BLOCKING**. SBI mismatches represent silent functionality loss in rebuild — the rebuilt Feature will have wrong behavior (e.g., wrong tab count, missing conditional views). The user must correct FRs or acknowledge the gap before approval.

**Skip if**: No SBI entries, or Source Reference = "N/A" (greenfield).

### Platform Constraint FR Verification

> **Purpose**: Platform Constraints from preceding Features (in pre-context.md) impose requirements that MUST appear as explicit FRs. Missing these causes critical bugs (e.g., frameless window with no drag region).

If pre-context has a "Platform Constraints from Preceding Features" section with entries:

1. For each Platform Constraint entry, check whether an FR-### addresses the required action
2. If any constraint is NOT covered by an FR, append to Review Display:
   ```
   ── ⚠️ Platform Constraint Coverage Gap ──────────
   Constraint: "Frameless window" (F001-shell → frame: false)
   Required: -webkit-app-region: drag on navbar, no-drag on interactive elements
   ⚠️ No FR-### found that addresses this constraint.
   → Recommend adding an FR for window drag region.
   ────────────────────────────────────────────────────
   ```

3. **Enforcement**: If any constraint is NOT covered by an FR → **BLOCKING**. Uncovered platform constraints cause critical bugs (e.g., frameless window with no drag region = unusable app). The agent MUST add missing FRs before approval is offered.

**Skip if**: No Platform Constraints section, or section says "None".

### Edge Case Coverage Check

> **Purpose**: Edge cases from pre-context are often listed as free text without structured scenarios (expected result + verify method). This check ensures each edge case is covered by at least one SC-###, so they don't surface as surprise bugs during implementation.

If pre-context contains an "Edge Cases" section with entries:

1. For each edge case, search `spec.md` SC-### descriptions for a matching scenario
2. Build a coverage matrix and append to Review Display:
   ```
   ── ⚠️ Edge Case Coverage ─────────────────────
   | Edge Case | Covered by SC | Expected Result | Verify Method |
   |-----------|--------------|-----------------|---------------|
   | Empty form submit | SC-005 | Validation error shown | verify-state .error visible |
   | Network timeout | NOT COVERED | Retry or error toast | — |
   | Max-length input | SC-012 | Input truncated | verify-state input maxLength "100" |

   ⚠️ [N] edge cases have no corresponding SC-###.
   ────────────────────────────────────────────────
   ```
3. **Enforcement**: If uncovered edge cases exist → **BLOCKING** with options in ReviewApproval:
   - "Add missing SCs for uncovered edge cases" (recommended)
   - "Acknowledge gap — proceed without coverage" (records ⚠️ EDGE-CASE-GAP in Review notes)
   Without explicit acknowledgment, uncovered edge cases surface as surprise bugs during implement/verify.

**Skip if**: No Edge Cases section in pre-context, or section is empty/contains only "N/A".

### Multi-Provider API Detection

> **Purpose**: When a Feature integrates multiple external API providers (e.g., OpenAI, Anthropic, Ollama), each provider has unique auth methods, endpoints, headers, and response formats. If SC-### only covers one provider's pattern, the others fail silently at runtime.

If spec.md FR-### descriptions mention 2+ external API providers:

1. Scan FR-### and SC-### for provider names (OpenAI, Anthropic, Google, Azure, Ollama, Groq, Mistral, Cohere, etc.)
2. If 2+ providers found, check if SC-### exist for EACH provider's unique behavior:
   - Different auth flows per provider
   - Different response parsing per provider
   - Provider-specific error handling
3. If any provider lacks dedicated SC-###, append to Review Display:
   ```
   ── ⚠️ Multi-Provider Coverage Gap ──────────────
   [N] providers detected but only [M] have dedicated SC-###:
     ✅ OpenAI: SC-003 (auth), SC-008 (response parsing)
     ❌ Anthropic: No SC for x-api-key auth or anthropic-version header
     ❌ Ollama: No SC for no-auth local mode

   ⚠️ Missing provider-specific SCs may cause runtime auth/parsing failures.
   ────────────────────────────────────────────────
   ```
4. **Enforcement**: If any provider lacks dedicated SC → **BLOCKING**. Without per-provider SCs, one provider's auth/parsing pattern gets applied to all — causing silent runtime failures for N-1 providers. The agent MUST add missing SCs before approval is offered.

**Skip if**: < 2 providers detected, or Feature does not call external APIs.

### Runtime Default Coverage Check (rebuild mode)

> 🚫 G7 [G7]: Rebuild Fidelity Chain. Source app defaults must flow into FR/SC at specify —
> not be invented or assumed. This check is part of the fidelity chain from reverse-spec
> through specify. See pipeline-integrity-guards.md § Guard 7.

> **Purpose**: Ensure that settings/mode/configuration Features specify the correct runtime defaults. Code analysis can misidentify defaults (e.g., a constant `'left'` in code while the app actually defaults to `'top'` mode at runtime). Runtime-verified defaults from reverse-spec Phase 1.5 Step 5 take precedence over code analysis.

If this Feature involves settings, modes, layout positions, or configuration that affects UI behavior:

1. **Check `runtime-exploration.md`** for runtime-verified defaults relevant to this Feature:
   - Layout modes (sidebar position, panel arrangement, tab mode vs sidebar mode)
   - Theme defaults (dark/light)
   - UI configuration defaults (default visible items, default selections)

2. **Cross-check spec.md FR/SC against runtime defaults**:
   - If FR/SC reference a default value → verify it matches runtime-verified value
   - If runtime-exploration.md has a `⚠️ Corrected from code analysis` note for any setting relevant to this Feature → **ensure spec.md uses the corrected runtime value**

3. **If mismatch found**, append to Review Display:
   ```
   ── ⚠️ Runtime Default Mismatch ──────────────────
   FR-003 specifies navbarPosition default as 'left', but runtime
   verification (reverse-spec Phase 1.5) confirmed the default is 'top'.

   ⚠️ Using the wrong default will cause the entire Feature's UI to be
   built around the wrong layout mode. Update FR/SC to use runtime value.
   ────────────────────────────────────────────────────
   ```

4. **Enforcement**: If layout-affecting default mismatch found → **BLOCKING**. Wrong layout defaults (e.g., sidebar position, navigation mode) cause the entire Feature's UI to be built around the wrong structure — requiring complete rework. Non-layout mismatches (e.g., theme default) → ⚠️ warning (not blocking).

**Skip if**: Not rebuild mode, or Feature does not involve settings/modes/configuration.

### Build-Time Plugin FR Check (rebuild mode)

> **Purpose**: Build-time transformation frameworks (CSS preprocessors, i18n extractors, code generators, asset pipelines) require explicit plugin registration in build config. If the source project uses these but the spec doesn't capture them as requirements, the rebuild will silently produce incomplete output — build passes, types check, app runs, but content is missing (unstyled UI, raw i18n keys, missing generated types).

If rebuild mode AND source project has build config files (vite.config, webpack.config, next.config, tsconfig, babel.config, postcss.config, etc.):

1. **Scan source build configs** for plugin registrations:
   - CSS: `@tailwindcss/vite`, `postcss-*`, `sass`, `less`, `styled-components/babel`
   - i18n: `i18next-parser`, `babel-plugin-react-intl`, `@formatjs/*`
   - Codegen: `@graphql-codegen/*`, `prisma generate`, `openapi-typescript`
   - Asset: `vite-plugin-svgr`, `@svgr/webpack`, `image-webpack-loader`
2. **Cross-check spec.md FR-###** for each detected plugin category:
   - Does an FR explicitly address the build-time setup?
   - If not, the rebuild will silently skip that transformation
3. **If any build-time plugin has no corresponding FR**, append to Review Display:
   ```
   ── ⚠️ Build-Time Plugin Coverage Gap ──────────────
   Source build config registers plugins not covered by FR-###:
     ❌ @tailwindcss/vite (CSS) — no FR for Tailwind CSS setup
     ✅ @vitejs/plugin-react — covered by FR-003

   ⚠️ Missing build-time plugin FRs cause silent output failures:
   build passes, app runs, but output is incomplete (unstyled, raw keys).
   ────────────────────────────────────────────────────
   ```
4. **Enforcement**: ⚠️ Warning (not blocking) — but **strongly recommended** to add FRs. Build-time plugin gaps are caught later by the Post-Implement Completeness Gate and Verify Phase 1 Build Output Fidelity check, but catching them here is far cheaper.

**Skip if**: Not rebuild mode, or no build config files in source.

### Brief↔Spec Alignment Check

> **Purpose**: Verify that the generated spec.md faithfully reflects the user's approved Brief. Without this check, the agent's interpretation in specify may silently diverge from the user's intent — the user approved a Brief about X, but the spec emphasizes Y.

After the post-execution checks above, read the Brief Summary from `SPEC_PATH/{NNN-feature}/pre-context.md` § Brief Summary (or from `specs/add-draft.md` if pre-context doesn't have it yet for greenfield).

**Cross-check**:
1. **Capability coverage**: Each capability listed in the Brief should map to at least one FR in spec.md. Flag capabilities with no corresponding FR.
2. **Entity alignment**: Entities mentioned in the Brief's Data section should appear in spec.md scope or FR definitions. Flag missing entities.
3. **Interface consistency**: APIs/UI touchpoints from the Brief should be reflected in spec.md. Flag Brief interfaces absent from spec.
4. **Scope drift**: Check if spec.md introduces significant capabilities NOT mentioned in the Brief. These aren't necessarily wrong, but the user should be aware.

**Display (if misalignments found)**:
```
── ⚠️ Brief↔Spec Alignment ────────────────────
Brief capabilities not reflected in spec:
  ❌ "export notification history as CSV" — no FR covers this
  ✅ "send push notifications" — covered by FR-002

Brief entities not in spec scope:
  ❌ "NotificationTemplate" — not mentioned in any FR

Spec additions beyond Brief:
  ➕ FR-005 "notification analytics dashboard" — not in Brief
     (may be valid — confirm with user)
────────────────────────────────────────────────
```

**Enforcement**:
- **Capability coverage gaps** (Brief capability → no FR): **🚫 BLOCKING**. If any Brief-defined capability has no corresponding FR, the user MUST resolve before approving:
  - Add an FR to cover the capability, OR
  - Confirm the capability was intentionally deferred ("Remove from scope")
  - Display in Review with AskUserQuestion options per gap
- **Entity alignment / Interface consistency gaps**: ⚠️ Warning (not blocking) — shown in Review for awareness
- **Scope drift** (spec adds beyond Brief): ⚠️ Warning (not blocking) — user should be aware but may approve

> **Rationale for blocking capability gaps**: The Brief represents the user's verified intent. If the spec silently drops a capability the user explicitly defined, it defeats the purpose of intent verification. Entity/interface gaps and scope drift are softer signals that benefit from user awareness but don't represent clear intent violations.

**Skip if**: No Brief Summary exists in pre-context (legacy projects without Phase 1e).

### External API Dependency Edge Cases

> **Purpose**: Features that consume external APIs (LLM, embedding, payment, etc.) MUST spec error handling and user guidance for API unavailability. Without this, the app silently fails when API keys are missing.

If any FR references an external API/service (keywords: "via API", "using provider", "LLM", "embedding", "external service", "third-party"):

1. Check if spec.md includes edge case FRs/SCs for:
   - **API key not configured**: Actionable error message guiding user to Settings
   - **API key expired/invalid**: Re-authentication flow
   - **API call failure**: Retry + user-visible status
   - **Provider not activated**: UI disables dependent functionality or shows setup guide

2. If missing → 🚫 **BLOCKING** (not just warning). Add to Review as:
   ```
   🚫 External API Dependency Edge Cases Missing (BLOCKING):
     Feature consumes [provider/LLM/embedding API] but spec has no FR/SC for:
     - API key not configured → user sees cryptic error, no guidance to Settings
     - Provider not activated → user can select non-functional options

     REQUIRED: Add FR for "When API key is not configured, display
     actionable error: 'Go to Settings > Provider to add your API key'"

     Cannot approve spec without external API error handling coverage.
   ```
   **Rationale (SKF-066)**: Without these FRs, the implement step produces features that silently fail when API keys are missing. Users see only a red X status icon with no guidance. Source apps (Cherry Studio) handle this gracefully — our rebuild must too.

3. For rebuild mode: check how source app handles these cases (e.g., Cherry Studio only shows authenticated providers in ModelSelector). If source app has a UX pattern for this, the FR MUST specify that same pattern or an explicit alternative.

**Skip if**: Feature has no external API dependencies (pure local functionality).

### Error Scenario Coverage Check (always — 🚫 BLOCKING for production)

> Every Feature has failure modes. SCs that only cover happy paths produce "all tests pass" while users hit unhandled errors.

Scan spec.md and verify coverage of applicable error categories:

| Category | Applicable When | What SC Must Specify |
|----------|----------------|---------------------|
| **Input Validation** | Feature has forms, user inputs, API params | Error state display for invalid/empty/oversized input |
| **Network/Service Errors** | Feature calls APIs or external services | Timeout, 5xx, rate-limit behavior (retry? fallback? error message?) |
| **Empty/No-Data States** | Feature displays collections or search results | What user sees when zero items (first-time user, empty search) |
| **Permission/Auth Errors** | Feature has auth-gated operations | Session expired, insufficient permissions behavior |
| **Concurrent/State Conflicts** | Feature modifies shared state | Concurrent edit, stale data, optimistic update rollback |

**Display in Review**:
```
── Error Scenario Coverage ─────────────────────
| Category | Applicable | Covered | Status |
|----------|-----------|---------|--------|
| Input Validation | Yes (FR-001) | SC-008 | ✅ |
| Network Errors | Yes (FR-003) | — | ❌ |
| Empty States | Yes (FR-002) | SC-015 | ✅ |
```

**Enforcement**: `production` → 🚫 BLOCKING (all applicable must have SC). `mvp` → ⚠️ WARNING. `prototype` → skip.

```
❌ WRONG: 12 FRs, 12 happy-path SCs → "spec complete"
✅ RIGHT: 12 FRs, 12 happy-path SCs + 5 error SCs → error paths specified
```

### Integration Method Specificity Check (rebuild — 🚫 BLOCKING)

> **Skip if**: Not rebuild mode, or Feature does not integrate with AI/LLM processing pipeline.
> **Triggered by**: FR containing "inject", "add to context", "provide as context", "search and inject", or any integration with AI/LLM pipeline.

**Purpose (SKF-075)**: FR verbs like "inject results as context" pre-commit to an architecture (system message injection) without checking how the source app actually integrates. Source app may use AI Tool registration, Plugin hooks, or Event systems — fundamentally different patterns that produce different UX.

Check each FR that describes Feature integration with the AI/LLM pipeline:

1. **Read SBI `-INT` entries** (from pre-context): What integration pattern does the source app use?
   - AI Tool: AI decides when to invoke (`tools[builtin_memory_search]`)
   - Plugin Hook: lifecycle hooks transform request/response (`onRequestStart`, `transformParams`)
   - System Message Injection: forced content prepended to conversation
   - Direct Import: synchronous function call in request handler

2. **Compare FR verb with source pattern**:
   ```
   🚫 Integration Method Mismatch (BLOCKING):
     SBI B194-INT: "Memory as AI Tool via Plugin hook"
     FR-027: "inject relevant results as context"

     Source uses AI Tool pattern (AI decides when to search).
     FR uses injection verb (forced every message).
     These are architecturally incompatible.

     → Rewrite FR: "provide memory search as AI tool.
        AI invokes when relevant to conversation."
   ```

3. **Forbidden verbs for AI Tool pattern**: When source uses AI Tool/Plugin pattern, these FR verbs are BLOCKING:
   - "inject" → implies forced insertion, not AI choice
   - "prepend to system message" → implies always-on, not selective
   - "search and add" → implies synchronous forced flow

   **Allowed verbs**: "provide as tool", "register as capability", "make available to AI", "AI may invoke"

### Data Pipeline Completeness Check

> **Purpose (S4c — Data Pipeline Traceability)**: Features that process data through multiple stages (input→transform→store→query→display) must have each stage represented in FRs. Writing "file embedding" as a single FR hides 6+ pipeline stages, each of which can fail independently.

If the Feature involves data processing (keywords: "process", "import", "embed", "index", "search", "extract", "transform", "parse", "convert", "analyze"):

1. **Identify the data pipeline stages**: Trace the full data path from input to output. Example:
   - File upload → format detection → text extraction (txt/md/pdf/docx) → chunking → embedding → vector storage → search → ranking → citation display
   - Each `→` is a pipeline stage that needs its own FR or is covered by another FR

2. **Check FR coverage per stage**: For each identified stage, verify at least one FR addresses it:
   ```
   ── 🚫 Data Pipeline Coverage Gap (BLOCKING) ────────
   Pipeline: [input] → [extract] → [chunk] → [embed] → [store] → [search] → [display]

   Missing FR coverage:
     ⚠️ [extract] stage: No FR for text extraction from PDF/DOCX (only plain text mentioned)
     ⚠️ [display] stage: No FR for citation rendering (only "inject into AI context" mentioned)

   Each uncovered stage is a potential silent failure during implement.
   ──────────────────────────────────────────────────────
   ```

3. **For rebuild mode**: Read source app's pipeline implementation and verify every stage in source is covered by an FR in the spec. Source stages not covered = **BLOCKING**.

4. **Check empty/invalid input SCs (S4b)**: For each pipeline stage, verify an SC exists for the "empty or invalid input" case:
   - Empty file → explicit error (not "completed with 0 results")
   - Unsupported format → explicit error with supported formats list
   - Extraction failure → status reflects failure, not success

**Skip if**: Feature is purely UI/config with no data processing pipeline.

### FR Granularity Check

> **Purpose**: A single FR that covers too much scope produces vague implementations. When an FR contains multiple independent capabilities, each capability should be a separate FR so it can be individually tested and tracked.

For each FR in spec.md:

1. **Multi-verb detection**: If an FR description contains 3+ independent verbs connected by "and" or commas (e.g., "create, manage, search, and display"), it likely covers multiple capabilities:
   ```
   ❌ "FR-010: User can create, manage, search, and display knowledge bases"
   → 4 independent capabilities in 1 FR — implement will miss some, verify can't test individually

   ✅ "FR-010: User can create a knowledge base with name and embedding model"
      "FR-011: User can add/remove files from a knowledge base"
      "FR-012: User can search a knowledge base and see results with citations"
      "FR-013: Knowledge base list is displayed in sidebar with status indicators"
   → Each FR is independently implementable and testable
   ```

2. **Multi-layer detection**: If an FR spans multiple architectural layers (UI + backend + external API), it should be split unless the layers are trivially connected:
   ```
   ❌ "FR-015: Files are embedded using the selected provider's embedding API"
   → Hides: file format detection, text extraction (per format), chunking strategy,
     embedding API call, vector storage, error handling per layer

   ✅ "FR-015: Supported file formats are detected (txt, md, pdf, docx)"
      "FR-016: Text is extracted from each format using appropriate parser"
      "FR-017: Extracted text is chunked with configurable overlap"
      "FR-018: Chunks are embedded using the selected provider's API"
      "FR-019: Embeddings are stored in the vector database"
   ```

3. **Threshold**: If any single FR would require 5+ implementation tasks in tasks.md, it's too broad. Flag for splitting.

**Display (if issues found)**:
```
⚠️ FR Granularity Issues:
  FR-010: 4 verbs (create, manage, search, display) → recommend split into 4 FRs
  FR-015: Spans 3 layers (UI → service → external API) → recommend split by layer
```
**Enforcement**: ⚠️ WARNING — included in Review. Not blocking, but splitting is recommended before approval.

### SC Testability Check

> **Purpose**: SCs that cannot be verified produce "12/12 ✅" results based on code review, not runtime evidence. Every SC must have a clear, mechanical verification method.

For each SC in spec.md:

1. **Verification method check**: Can this SC be verified by a specific, repeatable action?
   ```
   ❌ "SC-005: Knowledge base search returns relevant results"
   → "Relevant" is subjective. How does the agent verify this?

   ✅ "SC-005: Searching 'test content' in a KB containing a file with 'test content' returns at least 1 result with similarity > 0"
   → Concrete: known input, measurable output, specific threshold
   ```

2. **Observable output check**: Does the SC specify what is observable?
   ```
   ❌ "SC-008: Citations are displayed correctly"
   → "Correctly" is undefined. What does the agent check?

   ✅ "SC-008: Each search result renders as a numbered badge [N]. Clicking the badge shows a tooltip with the source file name and matched text snippet."
   → Observable: badge visible, tooltip appears, content matches
   ```

3. **For rebuild mode**: If the SC describes behavior that exists in the source app, the SC MUST reference the source pattern:
   ```
   ✅ "SC-008: Citations render as inline [N] badges with hover tooltip (matching source CitationsList.tsx pattern)"
   ```

**Display (if issues found)**:
```
🚫 SC Testability Issues (BLOCKING):
  SC-005: No concrete expected output — "relevant" is subjective
    → Recommend: "returns at least 1 result with similarity > 0 for known input"
  SC-008: No observable criteria — "correctly" is undefined
    → Recommend: specify visible elements and interaction behavior
```
**Enforcement**: 🚫 BLOCKING for SCs without any testable criteria. ⚠️ WARNING for SCs with weak but present criteria.

### Interaction Data Flow SC Check (rebuild + GUI — 🚫 BLOCKING)

> **Purpose (SKF-072)**: SCs like "citations are visible" verify presence but not data flow correctness. When the user clicks citation [2], the correct document for reference #2 must be displayed — this is a **data mapping accuracy** requirement that "visible" doesn't cover.

**Skip if**: Not rebuild mode, or Feature has no "click → ID lookup → display" interactions.

For each UI element in the Feature that maps an ID to data (citations, references, tabs, list items with detail views):

1. **SC must include mapping accuracy**, not just presence:
   ```
   ❌ "Citations are visible in the response"
   ✅ "User clicks citation badge [2] → tooltip shows source file name and content snippet matching reference #2. Clicking tooltip header opens source URL in new tab."
   ```

2. **SC must use interaction verbs** (click, hover, select, drag), not state verbs (is visible, exists, shows):
   ```
   ❌ "KB search results are shown"
   ✅ "User sends message with KB attached → response contains numbered citation badges → clicking badge [N] displays source #N's preview"
   ```

3. **Each clickable/interactive data reference needs its own SC or sub-SC**:
   - Citation badge click → tooltip with correct source
   - Citation list "N references" button → expanded list with all sources
   - Source link click → opens source URL

**Display (if gaps found)**:
```
🚫 Interaction Data Flow SC Gaps (BLOCKING):
  SC-002: "citations are visible" — no SC for click→correct document mapping
    → Recommend: "clicking [N] shows source #N's file name and content preview"
  SC-007: "KB can be attached to assistant" — no SC for attachment persistence
    → Recommend: "after attaching KB, refreshing page preserves the attachment"
```

### Source Parity Clause (rebuild SC — 🚫 BLOCKING)

> **Skip if**: Not rebuild mode.

Every SC in a rebuild Feature MUST include a **Source Parity Clause** — an explicit reference to the source app's behavior pattern that the SC is expected to match.

**Purpose**: Without parity clauses, SCs verify "does the feature exist?" but not "does it match the source app's quality?". The agent implements the **minimum** that passes the SC, which is often far below the source app's UX level.

**Format**: Append to each SC one of:
- `Matches source [ComponentName] behavior.` — when the target should replicate source exactly
- `Matches source [ComponentName] pattern: [specific behavior description].` — when you want to call out a specific pattern
- `Diverges from source: [reason].` — when intentionally different (must be explicit)

```
❌ "SC-002: Citations are visible in the response"
   → "visible" = minimum bar. Agent shows raw text, no badges, no click behavior.

✅ "SC-002: Citations render as [N] badges, click opens source file,
   numbered by first appearance. Matches source CitationsList pattern:
   inline sup badges + Ant Tooltip preview + click-to-open."
   → Specific, verifiable, source-referenced.
```

**🚫 BLOCKING**: Rebuild SC without Source Parity Clause → cannot approve spec. If source pattern is unknown, the clause should state `Source pattern: [to be analyzed during plan]` — which triggers plan-stage Source Behavior Depth Check.

### Domain Rule Compliance Check (S1)

> **Purpose**: Domain modules load S1 SC rules into context, but loading ≠ application. This check verifies that active S1 rules actually influenced the generated spec.md. Without this gate, domain rules are "trusted implicitly" — the agent may silently ignore rules buried in long context.

After spec.md is generated, cross-check the active domain modules' S1 rules against the actual SCs in spec.md:

**Procedure**:
1. Recall the active S1 SC rules from the cached domain profile (loaded at session start by `_resolver.md` Step 3)
2. For each S1 rule that is applicable to this Feature's scope:
   - Check if at least one SC in spec.md addresses this rule's concern
   - Example: S1 rule "UI interaction SCs must include loading states" → check if any SC covers loading state behavior
   - Example: S1 rule "IPC call SCs must include timeout handling" → check if any SC covers IPC timeout
3. Classify results:
   - **✅ Covered**: SC exists that addresses this rule
   - **⚠️ Not covered**: No SC addresses this rule — potential gap

**Display (if gaps found)**:
```
── ⚠️ Domain Rule Compliance (S1) ──────────────
Active S1 rules not reflected in spec SCs:
  ⚠️ [gui] "UI interaction SCs must include loading states"
     → No SC covers loading/spinner behavior
  ⚠️ [async-state] "State transition SCs must cover error→retry"
     → No SC covers retry-after-error flow
  ✅ [ipc] "IPC call SCs must include timeout handling"
     → Covered by SC-007

[N] of [M] applicable S1 rules are covered by SCs.
────────────────────────────────────────────────
```

**Enforcement** — tiered by coverage ratio:
- **Coverage ≥ 80%**: ✅ Pass — display single line in Review: `✅ Domain Rules (S1): [M]/[M] applicable rules covered by SCs`
- **Coverage 50–79%**: ⚠️ Warning (not blocking) — included in Review Display. The user decides whether uncovered rules need additional SCs.
- **Coverage < 50%**: 🚫 **BLOCKING** — majority of domain rules are not reflected in SCs. This indicates the spec was generated without meaningful domain awareness. The user must either add SCs to cover the gaps or explicitly waive each uncovered rule before approving.
  - Display: `🚫 Domain Rule Coverage Critical: only [N]/[M] ([P]%) applicable S1 rules covered. Resolve before approving.`
  - AskUserQuestion options per uncovered rule: "Add SC for this rule" / "Not applicable to this Feature" / "Defer to plan phase"

**Skip if**: No domain modules loaded (e.g., `--skip-domain`), or only `_core.md` is active (core rules are too generic for meaningful compliance checking).

### Review Display Content

After `speckit-specify` completes and post-execution checks above have run:

**Files to read**:
1. `specs/{NNN-feature}/spec.md` — Read the **entire file** and extract FR-###, SC-###, scope sections
2. `SPEC_PATH/{NNN-feature}/pre-context.md` → "Draft Requirements" and "Draft Success Criteria" sections (for diff comparison)

**Display format**:
```
📋 Review: spec.md for [FID] - [Feature Name]
📄 File: specs/{NNN-feature}/spec.md

── Requirements ─────────────────────────────────
[List each FR-### with its full description from spec.md]
  FR-001: ...
  FR-002: ...

── Success Criteria ─────────────────────────────
[List each SC-### with its full description from spec.md]
  SC-001: ...
  SC-002: ...

── Scope ────────────────────────────────────────
[In-scope and out-of-scope items from spec.md]

── Differences from Draft ───────────────────────
[Compare spec.md content with pre-context.md drafts:
 - Added: requirements/criteria that spec-kit added beyond the drafts
 - Removed: draft items that were dropped
 - Changed: items whose scope or description significantly changed]

── Files You Can Edit ─────────────────────────
  📄 specs/{NNN-feature}/spec.md
You can open and edit this file directly, then select
"I've finished editing" to continue.
──────────────────────────────────────────────────
```

**Pre-ReviewApproval Validation** (before offering options):

Before displaying ReviewApproval options, verify all applicable blocking checks passed:

| Check | Condition | Blocking? |
|-------|-----------|-----------|
| SBI Accuracy — no discrepancies | Rebuild/adoption with SBI | **YES** — correct FRs before approval |
| Platform Constraints — all covered by FR | Pre-context has Platform Constraints | **YES** — add FRs before approval |
| Edge Cases — all covered by SC (or acknowledged) | Pre-context has Edge Cases | **YES** — add SCs or acknowledge gap |
| Multi-Provider — all providers have SCs | 2+ external API providers | **YES** — add SCs before approval |
| Runtime Default — no layout mismatch | Rebuild mode + settings Feature | **YES** (layout) / ⚠️ (non-layout) |

If ANY blocking check failed, resolve before offering "Approve". Add missing FRs/SCs, then re-run the failed check.

**HARD STOP** (ReviewApproval): Options: "Approve", "Request modifications", "I've finished editing". **If response is empty → re-ask** (per MANDATORY RULE 1).

---

## Clarify (conditional — triggered after Specify Review)

> Clarify is a conditional sub-step. It runs **only** when the spec.md scan detects ambiguities (see SKILL.md "Clarify Trigger" section). If no ambiguities are found, skip directly to Plan.

### Read Targets

| File | Section | Filtering |
|------|---------|-----------|
| `SPEC_PATH/[NNN-feature]/spec.md` | Entire file | Scan for ambiguity markers and vague qualifiers |

### Ambiguity Scan

Before executing `speckit-clarify`, scan `spec.md` for:
1. **Explicit markers**: `[NEEDS CLARIFICATION]`, `[TBD]`, `[TODO]`, `???`, `<placeholder>`
2. **Vague qualifiers**: Adjectives without measurable criteria (e.g., "fast", "scalable", "intuitive", "robust")

If **no ambiguities found**: Display "✅ No critical ambiguities detected in spec.md. Proceeding to plan." and skip this section entirely.

### Checkpoint Display Content

If ambiguities are found:

```
📋 Ambiguities detected in spec.md for [FID] - [Feature Name]

── Explicit Markers ─────────────────────────────
[List each marker with its location in spec.md:
 - Line/section: "[NEEDS CLARIFICATION] ..."
 - Line/section: "[TBD] ..."]

── Vague Qualifiers ─────────────────────────────
[List each vague term with context:
 - "fast response time" — no measurable threshold defined
 - "scalable architecture" — no concrete scaling target]

──────────────────────────────────────────────────
⚠️ Running speckit-clarify to resolve these ambiguities.
```

### Injected Content

- The list of detected ambiguities (for speckit-clarify to focus on)
- `speckit-clarify` will interactively ask up to 5 questions and update spec.md directly

### Review Display Content

After `speckit-clarify` completes:

**Files to read**:
1. `specs/{NNN-feature}/spec.md` — Re-read the **entire file** and identify what changed (compare with pre-clarify content)

**Display format**:
```
📋 Review: Clarify results for [FID] - [Feature Name]
📄 File: specs/{NNN-feature}/spec.md

── Resolved Ambiguities ────────────────────────
[For each ambiguity that was resolved:
 - Before: "[TBD] response time"
 - After: "Response time under 200ms for 95th percentile"]

── Remaining Ambiguities (if any) ──────────────
[List any markers/qualifiers still present in spec.md]

── Files You Can Edit ─────────────────────────
  📄 specs/{NNN-feature}/spec.md
You can open and edit this file directly, then select
"I've finished editing" to continue.
──────────────────────────────────────────────────
```

**If remaining ambiguities exist**: Offer to re-run clarify or proceed.

**HARD STOP** (ReviewApproval): Options: "Approve", "Run clarify again", "I've finished editing". **If response is empty → re-ask** (per MANDATORY RULE 1).

---

## UI Flow Spec Generation (GUI Features — after spec.md approved)

> **Skip if**: `gui` and `tui` are NOT in active Interfaces (pure API/CLI/data-io Feature).
> **Reference**: See [ui-flow-spec.md](../ui-flow-spec.md) for full format, rules, and examples.
> **Domain Profile condition**: Axis 1 (Interface) includes `gui` or `tui`.

After spec.md is approved in the Review HARD STOP, generate `ui-flows.md`:

1. **Identify interactive FRs**: Scan spec.md for all FR-### that involve user interaction (forms, dialogs, navigation, CRUD, selections, toggles). Keywords: "click", "select", "enter", "drag", "toggle", "open", "create", "edit", "delete", "submit".

2. **Generate one flow per interactive FR** (or group tightly related FRs):

   **Rebuild mode**:
   - Read source component files referenced in pre-context Source Reference
   - Trace each interaction: entry point → event handler → state mutation → UI update
   - Extract: form field types, validation rules, conditional UI, error handling
   - Each flow step must reference the source file:line

   **Greenfield mode**:
   - Derive from FR/SC descriptions
   - If FR mentions a form/dialog but doesn't specify fields → this should have been caught during Brief elaboration. If still vague, add ⚠️ WARNING in Review.

3. **Completeness check (🚫 BLOCKING for rebuild)**:
   - Every interactive FR has a flow → if not, BLOCKING
   - Every flow has ≥2 steps → single-step = too vague
   - Every form has field definitions (type, required, validation, default)
   - At least 1 error path per flow
   - Preconditions explicit (API key, login, data exists)

4. **Write to** `SPEC_PATH/{NNN-feature}/ui-flows.md`

5. **Display summary in Review**:
   ```
   📋 UI Flow Specs Generated:
     Flow 1: Create Knowledge Base (5 steps, 3 error paths) — source: AddKnowledgeBasePopup.tsx
     Flow 2: Add Files to KB (4 steps, 2 error paths) — source: KnowledgeContent.tsx
     Flow 3: Search with Citations (6 steps, 2 error paths) — source: CitationsList.tsx
   ```

```
❌ WRONG: spec.md approved → proceed to plan without ui-flows.md
   → Agent improvises UI during implement → always simpler than source

✅ RIGHT: spec.md approved → generate ui-flows.md → show in Review → user approves both
   → implement follows ui-flows.md step by step → matches source app
```

---

## SC Preservation on Re-specification

> When re-specifying a Feature with status `augmented` (set by `add --to F00N`), existing SCs must be preserved. New SCs are added for the augmented requirements, not replaced.

### Trigger

- Read Feature status from `sdd-state.md`
- If status = `augmented` → activate this protocol
- If status is anything else → skip this section entirely

### Protocol

1. **Read existing spec.md SCs first**: Before invoking `speckit-specify`, read the current `SPEC_PATH/F00N-name/spec.md` and extract all existing SC-### entries with their full descriptions
2. **Identify augmented requirements**: Read the `## Augmented Requirements` section from `SPEC_PATH/F00N-name/pre-context.md` — these are the NEW requirements added by `add --to`
3. **Generate new SCs**: Run `speckit-specify` with context that includes both the original pre-context AND the augmented requirements. Instruct speckit-specify to generate SCs for the new requirements only
4. **Merge SCs**:
   - All existing SCs from the previous spec.md are **preserved** — mark each with `[preserved]` tag
   - New SCs generated for augmented requirements are **appended** — mark each with `[new]` tag
   - If a new requirement explicitly contradicts an existing SC, the existing SC is updated (not deleted) and marked `[updated]` with a note explaining the change
   - Renumber SC-### sequentially if needed to maintain a clean sequence
5. **Inject preservation instruction**: Include this in the speckit-specify context:
   ```
   ⚠️ SC PRESERVATION MODE (Feature status: augmented)
   This Feature was augmented via `add --to`. You MUST:
   - Preserve all existing SCs from the current spec.md (listed below)
   - Generate NEW SCs only for the Augmented Requirements section in pre-context
   - Mark preserved SCs with [preserved] and new SCs with [new]
   - Do NOT remove, merge, or compress existing SCs unless explicitly contradicted

   Existing SCs to preserve:
   {list of current SC-### entries from spec.md}
   ```

### Post-Execution Verification (added to standard verification sequence)

After `speckit-specify` completes for an augmented Feature:

1. **SC count check**: Compare SC count in new spec.md against previous spec.md
   - If new count < previous count → **BLOCKING**: "SC count decreased from [M] to [N]. [M-N] SCs may have been dropped during re-specification."
2. **SC preservation check**: For each `[preserved]` SC, verify its description matches the original (minor wording refinements OK, semantic changes NOT OK)
3. **New SC coverage**: Verify each augmented requirement has at least one `[new]` SC

### Review Display Addition

When displaying the Review for an augmented Feature, add a preservation summary:

```
── SC Preservation Summary ──────────────────────
Preserved: [N] SCs from previous spec (unchanged)
New: [M] SCs for augmented requirements
Updated: [K] SCs modified due to requirement conflicts
Total: [N+M+K] SCs

[preserved] SC-001: ...
[preserved] SC-002: ...
[new] SC-00N: ...
──────────────────────────────────────────────────
```

```
❌ WRONG: Re-specify from scratch → lose existing SCs → rebuild rework
✅ RIGHT: Preserve existing SCs + add new ones → incremental specification growth
```

---

## Post-Step Update Rules

Update `sdd-state.md` per generic step-completion rules in [state-schema.md](../state-schema.md). Additionally:
- Populate the Feature Mapping table: record spec-kit Name, spec-kit Path, and Branch (spec-kit creates the branch during specify)
- **SBI Coverage Update** (rebuild/adoption/add with SBI): After specify completes, scan the generated `spec.md` for `[source: B###]` tags. For each found tag:
  - Update `sdd-state.md` → Source Behavior Coverage table: set FR column to the FR-### ID, Feature column to the Feature ID, Status to `🔄 in_progress`
  - This establishes the SBI → FR mapping that will be confirmed during verify
  - For NEW entries (Origin=`new`): same process, but these entries are tracked separately in coverage metrics
- **Domain Profile Instance Update**: After specify completes, update `BASE_PATH/domain-profile-instance.md`:
  - Record cross-concern integrations that were activated during this Feature's specify in the Cross-Concern Integrations Applied table (one row per activated rule from `_resolver.md` Step 3.5; skip if already recorded by a preceding Feature)
  - Add a Per-Feature Domain Summary entry: active modules, key decisions from the generated spec.md, inherited constraints from preceding Features, and new decisions made by this Feature
  - If the file does not exist (e.g., legacy project without add Brief), create it from `smart-sdd/templates/domain-profile-instance-template.md` and populate Project-Level Profile from sdd-state.md
- No other Global Evolution Layer artifact updates beyond the above
