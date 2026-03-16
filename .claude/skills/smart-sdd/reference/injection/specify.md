# Context Injection: Specify + Clarify

> Per-command injection rules for `/smart-sdd specify [FID]` and the conditional Clarify sub-step.
> For shared patterns (HARD STOP, Checkpoint, Missing/Sparse Content Handling), see [context-injection-rules.md](../context-injection-rules.md).

---

## Specify

### Read Targets

| File | Section | Filtering |
|------|---------|-----------|
| `BASE_PATH/features/[FID]-[name]/pre-context.md` | "For /speckit.specify" section | Relevant Feature only |
| `BASE_PATH/features/[FID]-[name]/pre-context.md` | "Source Behavior Inventory" section | **If present (rebuild/adoption/add mode with SBI)** — ensure FR-### cover all P1/P2 behaviors |
| `BASE_PATH/features/[FID]-[name]/pre-context.md` | "UI Component Features" section | **If present (frontend/fullstack rebuild)** — ensure FR-### cover all UI features |
| `BASE_PATH/business-logic-map.md` | Relevant Feature section | Filtered by Feature ID. **If file does not exist (greenfield/add), skip entirely** |
| `BASE_PATH/features/[FID]-[name]/pre-context.md` | "Source Reference" section | Reference to original file list. **If N/A (greenfield), skip** |
| `BASE_PATH/features/[FID]-[name]/pre-context.md` | "Runtime Exploration Results" section | **If present (Phase 1.5 completed)** — reference observed UI layouts, user flows, and errors when drafting FR/SC. **If section says "Skipped"**, proceed without runtime context |
| `BASE_PATH/features/[FID]-[name]/pre-context.md` | "Naming Remapping" section | **If present (project identity changed)** — use new identifiers in requirements |

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
3. Display "Preceding Feature [FID] spec referenced" information at the Checkpoint

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

── Functional Enablement Chain ─────────────────
[If present in pre-context — show enablement/blocking relationships]
  Enables → F005-chat: Provider settings panel works
  Blocked by ← F001-shell: Window frame config applied
  ⚠️ Ensure SC-### cover the functional interfaces that downstream Features depend on.
    These interfaces are what downstream Features need to work at runtime.
[If section empty, absent, or "None": skip this block entirely]

── Runtime-Verified Defaults ──────────────────────
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

> **⚠️ SUPPRESS spec-kit output**: `speckit-specify` prints messages like "Ready for /speckit.clarify or /speckit.plan." — **never show these to the user**. Suppress ALL spec-kit navigation messages. Immediately proceed to the verification steps and Review Display below. If context limit prevents continuing, show instead: `✅ speckit-specify executed for [FID] - [Feature Name].\n💡 Type "continue" to review the results.`

After `speckit-specify` completes and BEFORE assembling the Review Display, run these checks in order:

1. **SBI Accuracy Cross-Check** (if applicable — rebuild/adoption with SBI)
2. **Platform Constraint FR Verification** (if applicable — pre-context has Platform Constraints)
3. **Edge Case Coverage Check** (if applicable — pre-context has Edge Cases)
4. **Multi-Provider API Detection** (if applicable — 2+ external API providers in FR-###)
5. **Runtime Default Coverage Check** (if applicable — rebuild mode + Feature has settings/mode/configuration)
6. **Build-Time Plugin FR Check** (if applicable — rebuild mode + source has build config with plugins)
7. **Assemble Review Display** (include any ⚠️/❌ from steps 1-6)
8. **HARD STOP** (ReviewApproval)

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
4. **If visual references exist** (`specs/reverse-spec/visual-references/`): Cross-reference UI structure claims in FRs against reference screenshots. Visual references are the ground truth for tab counts, layout structure, and visible elements.

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

### Review Display Content

After `speckit-specify` completes and post-execution checks above have run:

**Files to read**:
1. `specs/{NNN-feature}/spec.md` — Read the **entire file** and extract FR-###, SC-###, scope sections
2. `BASE_PATH/features/{FID}-{name}/pre-context.md` → "Draft Requirements" and "Draft Success Criteria" sections (for diff comparison)

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

## Post-Step Update Rules

Update `sdd-state.md` per generic step-completion rules in [state-schema.md](../state-schema.md). Additionally:
- Populate the Feature Mapping table: record spec-kit Name, spec-kit Path, and Branch (spec-kit creates the branch during specify)
- **SBI Coverage Update** (rebuild/adoption/add with SBI): After specify completes, scan the generated `spec.md` for `[source: B###]` tags. For each found tag:
  - Update `sdd-state.md` → Source Behavior Coverage table: set FR column to the FR-### ID, Feature column to the Feature ID, Status to `🔄 in_progress`
  - This establishes the SBI → FR mapping that will be confirmed during verify
  - For NEW entries (Origin=`new`): same process, but these entries are tracked separately in coverage metrics
- No other Global Evolution Layer artifact updates
