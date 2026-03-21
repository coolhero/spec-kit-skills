# Pipeline Execution — Common Protocol + Feature Pipeline

> Reference: Read after `/smart-sdd pipeline` or `/smart-sdd constitution` is invoked. For shared rules (MANDATORY RULES), see SKILL.md.
> For per-command context injection details, read `reference/injection/{command}.md` (shared patterns in `reference/context-injection-rules.md`).
> For git branch operations, also read `reference/branch-management.md`.

> **⚠️ Error Propagation Warning**: Each pipeline stage trusts the output of the previous stage. An error in an early stage (reverse-spec, specify) propagates through the entire pipeline — plan, tasks, implement, and verify all build on the flawed assumption. Settings, modes, and defaults that can only be confirmed at runtime MUST NOT be finalized from code analysis alone — runtime verification is required.

### Cross-Stage Validation Gates (rebuild + GUI)

The pipeline is single-direction (reverse-spec → specify → plan → tasks → implement → verify), meaning early-stage errors cascade unchecked. These 3 gates act as **circuit breakers** that independently re-validate critical assumptions:

| Gate | When | What | Reference |
|------|------|------|-----------|
| **Gate 1** | specify entry | Re-verify settings/mode runtime defaults against source app. Catch mismatches before they enter the spec. | `reverse-spec/analyze.md` Phase 1.5 Step 5 + `injection/specify.md` § Runtime Default Coverage Check |
| **Gate 2** | implement entry | Read previous Features' Interaction Surface Inventory. Analyze source app layout structure (component hierarchy, layout direction, sizing strategy). Display in Pre-Implement Checkpoint. | `injection/implement.md` § Layout Structure Analysis + § Interaction Surface Preservation |
| **Gate 3** | verify Phase 3e | Run source app + rebuilt app side-by-side comparison. **BLOCKING** for rebuild+GUI — skip only when source app genuinely cannot build/launch. | `verify-phases.md` § Step 3e Source App Comparative Verification |

> These gates are NOT optional for rebuild+GUI projects. Without them, a single incorrect assumption (e.g., wrong layout mode default) can propagate through all 6 stages undetected.
>
> For foundational guard patterns underlying all gates, see [pipeline-integrity-guards.md](../reference/pipeline-integrity-guards.md).

## Common Protocol: Assemble → Checkpoint → Execute+Review → Update

**All spec-kit command executions follow this 4-step protocol. Each step MUST be executed in order. No step may be skipped. In particular, Execute (Step 3) includes a mandatory Review HARD STOP — the spec-kit command runs, then the Review is presented, all in one continuous action.**

> ⚠️ **The most common failure mode is skipping Review.** After executing a spec-kit command (Step 3), you MUST stop, display the generated artifacts, and ask the user for approval. Do NOT proceed to Update without Review. Do NOT combine Execute and Update into a single flow.
>

### 1. Assemble — Context Assembly

- Reads the files/sections required for the given command from BASE_PATH
- Filters and assembles the necessary information per command according to [`reference/injection/{command}.md`](../reference/injection/) **AND** shared cross-command patterns in [`reference/context-injection-rules.md`](../reference/context-injection-rules.md) (both MUST be read — per-command files contain step-specific rules, context-injection-rules contains shared patterns like Dependency Stub Resolution Injection that span multiple commands)
- Also references actual implementation results from preceding Features (under `specs/`) if available
- **Graceful degradation**: If a source file is missing or a section contains only placeholder text (e.g., "N/A", "none yet"), that source is skipped. See `context-injection-rules.md` § Missing/Sparse Content Handling for details.

**Registry Freshness Pre-check** (for Features after F001, 🚫 BLOCKING if repair fails):
Before assembling context, verify that registries reflect the latest preceding Feature's updates:
1. Read `BASE_PATH/entity-registry.md` and `BASE_PATH/api-registry.md`
2. Check the last "Used by Features" / "Cross-Feature Consumers" entries — do they include the preceding Feature that just completed its plan/implement step?
3. If the preceding Feature's plan completed but its entities/APIs are NOT reflected in the registry:
   - **Registry is stale** — the Post-Step Update from the preceding Feature's plan was likely skipped or failed
   - Display: `⚠️ Registry Freshness: entity-registry.md does not reflect [preceding FID]'s plan output. Running catch-up update.`
   - Read the preceding Feature's `data-model.md` and `contracts/` → update registries now
   - Display: `✅ Registry updated with [preceding FID]'s [N] entities and [M] APIs`
4. If registries are current: proceed silently (no message needed)

#### Post-Repair Verification (🚫 BLOCKING for Features after F001)

After auto-repair completes, verify repair was successful:
1. Re-read entity-registry.md and api-registry.md
2. Confirm preceding Feature's entities/APIs now appear with correct ownership
3. If repair succeeded → proceed silently
4. If repair failed (corrupt data-model.md, empty contracts/, parse error):
   → 🚫 BLOCKING: "Registry repair failed for preceding Feature [FID]. Cross-Feature data is stale."
   → AskUserQuestion:
     - "Fix manually and retry"
     - "Skip registry check (⚠️ risk: duplicate entities)"
   **If response is empty → re-ask** (per MANDATORY RULE 1)

❌ WRONG: Registry stale → warn → proceed anyway → F002 creates duplicate User entity
✅ RIGHT: Registry stale → auto-repair → verify success → if failed, BLOCK with user choice

> **Why this check exists**: If a plan Post-Step Update fails (context limit, session break, or agent omission), the next Feature assembles stale registry data. This pre-check catches the gap before it propagates. The cost is one registry read per Feature start — negligible compared to the cost of cross-Feature inconsistency.

**Context Budget Estimation** (for projects with 10+ Features):
Before reading files, estimate the total context volume of Read Targets:
1. Count the number of Read Target files and their approximate sizes (pre-context: ~200 lines, spec: ~100 lines, plan: ~150 lines, registries: varies)
2. If estimated total exceeds **2000 lines** (roughly 40% of typical context budget after system instructions):
   - Apply **progressive summarization**:
     a. **Current Feature**: Read full content (no compression)
     b. **Direct dependencies** (Features in the Dependency Graph): Read full spec.md + plan.md summary (FR-### list + architecture section only, skip detailed descriptions)
     c. **Indirect dependencies** (Features referenced by direct dependencies): Read spec.md FR-### IDs only (one-line per FR, no descriptions)
     d. **Unrelated preceding Features**: Skip entirely (their registries entries are sufficient)
   - Display in Checkpoint: `📊 Context budget: [N] lines assembled ([M] lines compressed via progressive summarization)`
3. If estimated total is under 2000 lines: Read full content as normal

### 2. Checkpoint — User Confirmation

Presents the assembled context to the user with **actual content**, not just counts. The user must be able to review what will be injected and make informed decisions.

Display format:

```
📋 Context for [command] execution:

Feature: [Feature ID] - [Feature Name]

── Injected Content ──────────────────────────────

[Show the actual assembled content organized by source.
 For example, for specify: show the FR-### list, SC-### list,
 business rules, and edge cases — the real text, not just counts.
 For plan: show the entity schemas, API contracts, and dependencies.
 For greenfield/add: note which sections are empty and will be defined from scratch.]

── Cross-Feature References ──────────────────────

[List of related Features and what is being referenced from each]

── Prerequisites ─────────────────────────────────

[Met / Not met — with details if not met]

──────────────────────────────────────────────────

Review the above content. You can:
  - Approve as-is to proceed
  - Request modifications (add/remove/change items)
  - Edit the source files directly before proceeding
```

**HARD STOP**: You MUST follow this exact procedure. No exceptions.

```
PROCEDURE ApprovalGate(type):
  # type = "checkpoint" → options: ["Approve as-is", "Request modifications"]
  # type = "review"     → options: ["Approve", "Request modifications", "I've finished editing", "Go back to earlier step"]
  #   Note: "Go back" option appears in review type ONLY, and only for steps AFTER specify.
  LOOP:
    response = AskUserQuestion(options per type above)

    IF response is empty/blank → re-ask ("⚠️ No approval received. Please select one option.")
    IF approved (yes/lgtm/approve) → BREAK LOOP → proceed to next step
    IF "Request modifications" → ask what to change → apply → re-display → CONTINUE LOOP
    IF "I've finished editing" (review only) → re-read artifacts → show diff → ask approve/edit-more
    IF "Go back to earlier step" → execute PROCEDURE StepBack (see below)
    OTHERWISE → re-ask with valid options
```

**⚠️ CRITICAL**: If response is empty — you have NOT received approval. Call AskUserQuestion AGAIN. Do NOT proceed.

### Step-Back Protocol

> **When to use**: User wants to fix a previously approved artifact (e.g., fix spec while at implement, change architecture while at verify).
> **Difference from `reset`**: Step-back is **incremental** (preserves existing artifacts as starting point, uses cascading update). Reset is **destructive** (deletes artifacts, starts fresh). Step-back says "I want to fix something"; reset says "I want to start over."

```
PROCEDURE StepBack:

  Step 1 — TARGET SELECTION:
    Present completed prior steps (read sdd-state.md Feature Progress — any ✅ step is a valid target):
    AskUserQuestion: "Which step do you want to go back to?"
    Options: [list of completed steps, e.g., "specify", "plan", "tasks"]
    **If response is empty → re-ask** (per MANDATORY RULE 1)

  Step 2 — REASON RECORDING:
    AskUserQuestion: "What needs to change?" (free text)
    Record in Feature Detail Log: "↩️ STEP-BACK from [current] to [target] — [user reason]"

  Step 3 — STATE UPDATE:
    - Set Feature status to regression-{target} (reuse existing regression statuses)
    - Mark steps from [target] onward as 🔀 in Feature Progress (NOT blank — preserves completion history)
    - Preserve ALL existing artifacts (spec.md, plan.md, tasks.md, source code)

  Step 4 — CROSS-FEATURE IMPACT ANALYSIS (if target = specify or plan):
    🚫 BLOCKING — must complete before re-executing the target step.
    Read reference/cascading-update.md § Cross-Feature Impact Analysis Protocol.
    Execute the 6-step impact analysis:
    1. Identify owned entities/APIs in registries
    2. Find all referencing/consuming Features
    3. After spec/plan change: classify diff as BREAKING / ADDITIVE / INTERNAL
    4. Display Impact Report (HARD STOP)
    5. Record in Feature Detail Log
    6. Mark downstream Features per user selection
    **If target = tasks or implement → skip Impact Analysis (no public interface change).**

  Step 5 — RE-EXECUTE FROM TARGET:
    Resume pipeline from [target] step.
    The existing artifact is the STARTING POINT — cascading-update.md incremental protocol applies.
    (NOT a full re-generation from scratch — the agent modifies the existing artifact based on user's requested change.)

  Step 6 — CASCADING:
    After [target] step completes, cascade changes downstream within this Feature:
    - specify change → cascade to plan → tasks (existing artifacts updated incrementally)
    - plan change → cascade to tasks (existing artifact updated incrementally)
    - tasks change → no cascade needed (implement reads updated tasks)
```

**Preservation rules** — what stays vs what gets re-executed:

| Step-back target | Preserved | Re-executed (🔀) |
|------------------|-----------|-------------------|
| specify | (nothing prior) | specify, plan, tasks, implement, verify |
| plan | spec.md | plan, tasks, implement, verify |
| tasks | spec.md, plan.md | tasks, implement, verify |
| implement | spec.md, plan.md, tasks.md | implement, verify |

### 3. Execute — spec-kit Command Execution

Executes the corresponding spec-kit command with the approved context:
- **Always use Inline Execution** (read SKILL.md → execute as inline workflow steps). Do NOT use the Skill tool for `speckit-*` commands.
- Includes the assembled context content in the conversation so spec-kit can reference it
- Feature artifacts created/modified by the spec-kit command are located under `specs/{NNN-feature}/`
- **Prerequisite**: spec-kit skills must be installed in the target project (Step 0c handles this automatically)

#### Inline Execution Protocol

**Why not the Skill tool?** The Skill tool creates a response boundary — when the speckit skill completes, its output becomes the final response, and smart-sdd loses the ability to continue with Review in the same turn. This structurally violates the Execute + Review Continuity Rule (see below). Inline execution keeps everything in smart-sdd's response context.

**How to execute inline**:
1. Read the skill's SKILL.md file directly: `.claude/skills/speckit-[command]/SKILL.md`
2. Execute the instructions contained in the SKILL.md as inline workflow steps
3. Suppress spec-kit's completion messages (per MANDATORY RULE 3)
4. Continue IMMEDIATELY to Step 3b (Review) in the same response

#### Execute Error Handling

If the spec-kit command fails (error, crash, partial output):
1. Display the error message to the user
2. Use AskUserQuestion with options: "Retry", "Abort step", "Troubleshoot". **If response is empty → re-ask** (per MANDATORY RULE 1).
3. If "Retry": Re-run the Execute step
4. If "Abort step": Record failure in sdd-state.md, do NOT proceed to Review
5. If "Troubleshoot": Help the user diagnose and fix the issue, then offer to retry

### Error Retry Policy

When a pipeline step fails (build, test, lint, spec-kit command):
- Max 3 retries per step per Feature
- After 3 failures: HARD STOP
  **Use AskUserQuestion**: "Step {step} failed 3 times for {Feature}. How to proceed?"
  - Options: "Abort pipeline", "Skip this step", "Troubleshoot"
  **If response is empty → re-ask** (per MANDATORY RULE 1)
- Retry count tracked per-session (not persisted)
- Each retry must attempt a DIFFERENT fix (no identical re-run)

**⚠️ CRITICAL — SUPPRESS spec-kit output (see MANDATORY RULE 3 in SKILL.md)**: spec-kit commands print their own next-step messages. **IGNORE ALL of them.** Do NOT relay them to the user. smart-sdd controls the workflow.

Suppress these patterns (non-exhaustive):
- "Ready for /speckit.clarify or /speckit.plan"
- "Ready for /speckit.plan"
- "Next phase: ..."
- "Suggested commit: ..."
- Any "Ready for /speckit.*" guidance

**Never show spec-kit's own navigation messages.** smart-sdd provides its own continuation prompts.

**⚠️⚠️⚠️ EXECUTE + REVIEW CONTINUITY RULE ⚠️⚠️⚠️**

**Execute and Review are ONE continuous action — they MUST happen in the SAME response.** After the spec-kit command (skill invocation) returns, you MUST NOT:
- Generate a response to show the user the command output
- Stop to present results or a summary
- Wait for the user to click "continue" or send any message
- Show "Done" or "Completed" or "Constitution finalized" messages

Instead, in the SAME response where the spec-kit command completed, IMMEDIATELY:
1. Read the generated artifact file(s)
2. Display the Review content (Step 3b below)
3. Call AskUserQuestion for approval (Step 3c below)

**If you find yourself about to generate a response after Execute without showing the Review — STOP. You are violating this rule. Continue to Step 3b.**

> **Fallback — if this response ends without AskUserQuestion** (for ANY reason — context limit, tool error, unexpected flow):
> Before generating ANY response after Execute that does NOT include AskUserQuestion, you MUST append this continuation prompt:
> ```
> ✅ [command] executed for [FID] - [Feature Name].
>
> 💡 Type "continue" to review the results.
> ```
> **This is a catch-all safety net.** The normal path is Review + AskUserQuestion in the same response. But if that fails for ANY reason, the user must NEVER be left without knowing what to do next. A response that ends after showing spec-kit output without EITHER AskUserQuestion OR this fallback message is a critical violation.

#### Step 3b. Display the Review Content

Each command produces different artifacts. Display the **key content** of the generated artifact(s):

| Command | Artifact to Review | Key Content to Display |
|---------|-------------------|----------------------|
| constitution | `.specify/memory/constitution.md` | Full finalized constitution (principles, constraints, conventions, best practices) |
| specify | `specs/{NNN-feature}/spec.md` | Requirements (FR-###), Success Criteria (SC-###), scope boundaries |
| plan | `specs/{NNN-feature}/plan.md` + `data-model.md` + `contracts/` | Architecture decisions, data model schemas, API contracts, implementation phases |
| tasks | `specs/{NNN-feature}/tasks.md` | Task breakdown, task order, estimated complexity |
| implement | Source code files | Summary of files created/modified, test results, build status |

Display format:

```
📋 Review: [command] result for [FID] - [Feature Name]

── Generated Artifact ──────────────────────────
[Show the key sections of the generated artifact.
 Not the entire file — focus on the decision-making content:
 - For spec.md: list FR-### and SC-### with descriptions
 - For plan.md: architecture overview, data-model summary, API contract list
 - For tasks.md: task list with order and dependencies
 - For constitution: full content (it's a one-time critical document)
 - For implement: file list, test pass/fail summary]

── Differences from Pre-context ────────────────
[If applicable: highlight where spec-kit's output differs from
 the draft in pre-context.md — added requirements, changed schemas, etc.]

── Files You Can Edit ─────────────────────────
[List the EXACT file paths that were created/modified by this step:]
  📄 [absolute-path-to-artifact-1]
  📄 [absolute-path-to-artifact-2]
  ...
You can open and edit these files directly, then select
"I've finished editing" to continue.
──────────────────────────────────────────────────
```

For detailed per-command Review Display Content, see [context-injection-rules.md](../reference/context-injection-rules.md).

#### Step 3c. Ask for User Approval (HARD STOP)

Use `ApprovalGate(type: review)` from Step 2 above. **If response is empty → re-ask** (per MANDATORY RULE 1)

**Per-command option overrides**: Some commands use context-specific options (e.g., Clarify: "Run clarify again", Analyze: outcome-dependent, Verify: pass/fail-specific). See [context-injection-rules.md](../reference/context-injection-rules.md) for details.

### 4. Update — Global Evolution Layer Refresh

Updates global artifacts to reflect the command execution results. For detailed update rules per step, see the Post-Step Update Rules in the corresponding [reference/injection/{command}.md](../reference/injection/).

| Completed Step | Update Target | Content |
|----------------|--------------|---------|
| plan | `entity-registry.md` | Reflect new entities/changes from the `data-model.md` finalized in the plan |
| plan | `api-registry.md` | Reflect new APIs/changes from the `contracts/` finalized in the plan |
| analyze | `sdd-state.md` | Record analysis results (issues found, severity levels) |
| implement | `roadmap.md` | Change Feature status to completed |
| implement | Subsequent Feature `pre-context.md` | Update pre-context affected by changed entities/APIs |
| verify | `sdd-state.md` | Record verification results |
| verify | `entity-registry.md` | Verify and update if actual implementation differs from registry |
| verify | `api-registry.md` | Verify and update if actual implementation differs from registry |
| merge | `sdd-state.md` | Record merge completion, update Feature Mapping, change Status to `completed` |

Reports the changes to the user after the update.

---

## Pipeline Mode

Running `/smart-sdd pipeline` processes **one Feature at a time** by default. Use `--all` for batch processing.

```
/smart-sdd pipeline                        → next single Feature (auto-select)
/smart-sdd pipeline F003                   → F003 specifically
/smart-sdd pipeline --start verify         → next Feature, from verify
/smart-sdd pipeline F003 --start verify    → F003, from verify
/smart-sdd pipeline --all                  → all eligible Features (batch)
/smart-sdd pipeline --all --start verify   → all eligible Features, from verify
/smart-sdd constitution                    → finalize constitution (standalone)
```

### Regression-Implement Protocol (`--start specify` or `--start plan`)

When pipeline is re-run from a mid-point (`--start specify`, `--start plan`, etc.), existing code already exists for this Feature. The implement step MUST handle this differently from a fresh run:

1. **Delta analysis**: Compare new spec/plan/tasks against existing code → identify what changed
2. **Existing Code Audit** (🚫 MANDATORY for regression):
   - Run **Semantic Stub Detection** (see `injection/implement.md`): grep for `Math.random()`, placeholder comments, external call bypasses in ALL existing Feature files (not just new/changed files)
   - Run **Integration Contract Fulfillment Check**: verify all "Consumes ←" entries have actual calls in code
   - Run **UI Control Type Audit** (rebuild+GUI): verify source→target control type parity
3. **Audit results in Checkpoint**: Display existing code audit results BEFORE implementing delta changes. If audit finds issues in existing code → those become additional implementation tasks.

```
❌ WRONG: "Existing code already implements F006. Only applying SC-011/SC-012 delta."
  → Misses Math.random() embeddings, missing IPC calls, text inputs replacing dropdowns

✅ RIGHT: "Existing code audit found 3 issues:
  🚫 KnowledgeService.ts:272 — Math.random() embeddings (semantic stub)
  🚫 No ai:embed IPC call (Integration Contract unfulfilled)
  🚫 AddKnowledgeBasePopup: Input[text] instead of Select (UX downgrade)
  These will be fixed alongside the SC-011/SC-012 delta."
```

> **Domain Profile condition**: The audit depth is adjusted by Scale modifier — `prototype` mode may classify semantic stubs as ⚠️ WARNING instead of 🚫 BLOCKING if the external service is intentionally deferred. `mvp` and `production` modes treat all semantic stubs as BLOCKING.

### Pipeline Initialization

Before Feature processing, initialize the state and validate the source path.

**Step 1 — State file initialization**:
If `BASE_PATH/sdd-state.md` does not exist, create it:
1. Read `BASE_PATH/roadmap.md` to extract the Feature list and Tiers
2. Generate `sdd-state.md` following the [state-schema.md](../reference/state-schema.md) format
3. Set Origin based on the project type (`greenfield`, `rebuild`, or `adoption`)
4. Set Source Path (see state-schema.md for rules per mode)

**Step 2 — Source Path verification (HARD STOP)**:
Read the `Source Path` from `sdd-state.md` and verify based on the project mode:

| Mode | Source Path | Verification |
|------|------------|-------------|
| **greenfield** | `N/A` | Skip — no source to reference. Display: "Greenfield project — no existing source reference." |
| **rebuild** | Absolute path from reverse-spec | Verify the path exists and is accessible. Display the path and ask the user to confirm or update it (the source may have moved since `/reverse-spec` was run). |
| **adoption** | `.` (CWD) | Same as incremental — the existing code is in the current directory. Display: "Adoption mode — current directory is the source reference." |
| **add (incremental)** | `.` (CWD) | Verify that the current directory contains source code (check for common markers: `package.json`, `pyproject.toml`, `go.mod`, `src/`, etc.). Display: "Incremental mode — current directory is the source reference." |

For **rebuild** mode, present to the user via AskUserQuestion:
```
📂 Source Reference Path: [path from sdd-state.md]
```
- "Confirm path"
- "Update path"

If the user selects "Update path", accept the new path via "Other" input, verify it exists, and update `sdd-state.md`.
If the path does not exist, warn the user and ask for correction. **Do NOT proceed until a valid source path is confirmed** (source reference is essential for brownfield development).

**You MUST STOP and WAIT for the user's response.** Do NOT auto-confirm. **If response is empty → re-ask** (per MANDATORY RULE 1).

**Step 3 — Scope display**:
Read `Scope` from `sdd-state.md` and display scope information:

| Scope | Display |
|-------|---------|
| `full` | "📋 Scope: Full — All Features will be processed." |
| `core` | Read `Active Tiers` and display per the table below |

**Active Tiers display (core scope only)**:

| Active Tiers | Display |
|-------------|---------|
| `T1` | "📋 Scope: Core — Only Tier 1 Features will be processed. Use `/smart-sdd expand` to add Tier 2/3 later." |
| `T1,T2` | "📋 Scope: Expanded — Tier 1 + Tier 2 Features will be processed. Tier 3 deferred." |
| `T1,T2,T3` | "📋 Scope: Core (All Tiers active) — All Features will be processed." |

If deferred Features exist (core scope only), list them:
```
⏸️ Deferred Features (not in current scope):
  F005-review (Tier 3), F006-notification (Tier 3)
```

This step is informational only — no user confirmation required.

**Step 3a — CI Propagation Check (greenfield only)**:

Read `Clarity Index` from `sdd-state.md`. If CI is not `N/A`, apply verification intensity adjustments throughout the pipeline. See `reference/clarity-index.md` § 6 for the full propagation table.

| CI at Pipeline Start | Impact |
|---------------------|--------|
| ≥ 70% | Standard pipeline — no additional checks |
| 40–69% | specify: extra SC completeness check for low-CI dimensions. plan: Review emphasizes low-CI areas |
| < 40% | specify: mandatory clarify sub-step. plan: HARD STOP for low-CI gap discussion. verify: Phase 3b adds empty-state checks |

**Per-dimension low-confidence** (`CI Low-confidence` field): When specific dimensions have confidence ≤ 1, the agent applies targeted checks at the relevant pipeline step. For example, if "Target Users" is low-confidence, specify adds a "user role identification" prompt. See `reference/clarity-index.md` § 6 for the per-dimension table.

This step is informational only — no user confirmation required.

### Step 3b — Registry Freshness Verification (per Feature)

> Runs at the START of each Feature's pipeline, before specify Checkpoint.
> **Skip for**: The first Feature in the pipeline (no preceding Features to verify against), or greenfield projects with no completed Features.

**Purpose**: Detect registry staleness from preceding Features whose Post-Step updates may have been incomplete (due to context limits, session breaks, or errors). Without this check, a Feature could build on stale entity/API definitions.

**Verification**:
1. Read `sdd-state.md` Feature Progress — identify all preceding Features with status `completed`, `adopted`, or `verified`
2. For each completed preceding Feature, quick-check:
   - Does `entity-registry.md` contain entries with `Owner Feature` = that FID? If that Feature's `data-model.md` exists but no registry entries reference it → **stale**
   - Does `api-registry.md` contain entries with `Provider` = that FID? If that Feature's `contracts/` exists but no registry entries reference it → **stale**
3. **If staleness detected**:
   ```
   ⚠️ Registry Staleness Detected
     [FID]-[name]: data-model.md has [N] entities but entity-registry has [M] entries for this Feature
     [FID]-[name]: contracts/ has [N] APIs but api-registry has [M] entries for this Feature

   Auto-repairing: reading missing artifacts and updating registries...
   ```
   - Auto-repair: read the stale Feature's data-model.md / contracts/ and update registries
   - Display repair summary: `✅ Registry repaired: added [N] entities, [M] APIs from [FID]`
   - **Post-Repair Verification**: After auto-repair, re-read registries to confirm repair succeeded. If repair failed (corrupt data-model.md, empty contracts/, parse error) → 🚫 BLOCKING gate applies (see § Assemble — Post-Repair Verification)
4. **If no staleness**: proceed silently (no message needed)

### Step 3c — Foundation Verification Gate (first Feature only)

> Runs ONCE before the first Feature enters the pipeline.
> **Skip for**: greenfield projects (no Foundation exists yet — nothing to validate), OR the current Feature IS a T0 (Foundation) Feature (cannot verify Foundation before building it), OR if `sdd-state.md` records `Foundation Verified: [date]` with no Foundation-affecting changes since.

**Purpose**: Validate cross-cutting Foundation systems (CSS theme, state management patterns, IPC bridge, core layout) before Feature code builds on them. Common Foundation-level bugs include: CSS theme not loading, state selector instability, IPC bridge disconnection, layout patterns breaking. No amount of Feature-level testing catches a broken Foundation. For user assistance patterns during Foundation setup, see [reference/user-cooperation-protocol.md](../reference/user-cooperation-protocol.md).

**When to run**: Before the FIRST Feature's `specify` step. Also re-run if a preceding Feature modified Foundation files (detected via `git diff` on files outside `specs/`).

**Foundation Checklist** (check all that apply based on constitution tech stack):

| Category | Check | Method | Blocking? |
|----------|-------|--------|-----------|
| **Build** | Clean build succeeds | Run build command → exit 0 | ❌ **BLOCKING** |
| **Theme/Styling** | Theme tokens load at runtime | Start app → verify theme system is active (check for expected visual tokens/variables) | ⚠️ warning |
| **Theme/Styling** | Theme switching works (if applicable) | Toggle theme → verify visual change | ⚠️ warning |
| **State Management** | Store/state initialization succeeds | Initialize state system → verify non-null/non-error | ⚠️ warning |
| **State Management** | State access stability | Access the same state twice → verify consistent results (no unintended re-creation) | ⚠️ warning |
| **IPC / Cross-boundary** | Inter-process communication works (if applicable) | Send test message across boundary → verify response | ⚠️ warning |
| **Layout** | Core layout renders without error | Navigate to base route → snapshot → no error screen | ⚠️ warning |
| **Build Plugins** | Build-time framework plugins registered | Check build config for required plugins (CSS: `@tailwindcss/vite`, i18n: extraction plugin, codegen: generate script in prebuild). See `injection/implement.md` § Build Toolchain Integration Verification | ⚠️ warning |
| **Toolchain** | Lint/Test/Build tools available | Detect per `domains/_core.md` § S3b → verify executable | ⚠️ warning |

**Execution**:
1. Run build → **BLOCK on failure** (same as Phase 1 build gate)
   **Structure-aware build**: Read `sdd-state.md` → `**Structure**` field. If `monorepo`, use workspace-aware build command (e.g., `turbo run build`, `nx build`, `bun run --filter=* build`) instead of single-package build. The workspace build tool is determined from F8 `build` field or auto-detected from `turbo.json`/`nx.json`/root `package.json` scripts.
1b. **Toolchain Pre-flight** — Verify development tools are available:
   **F8 Foundation Override**: If the active Foundation file declares an `### F8. Toolchain Commands` section (see `domains/foundations/_foundation-core.md` § F8), use those commands directly instead of auto-detection. Read the PRIMARY framework's Foundation file (first in `**Framework**` field of sdd-state.md) and extract `build`, `test`, `lint`, `typecheck`, `package_manager`, `install` fields. If F8 is absent, fall back to auto-detection below.

   1. **Lint detection**: If F8 `lint` field exists → use that command. Otherwise, read `domains/_core.md` § S3b (Lint Tool Detection Rules) and follow the detection order.
      If a lint command is found, verify it is executable (`--version` check or binary exists).
   2. **Test detection**: If F8 `test` field exists → use that command. Otherwise, detect test command from project config (`package.json` → `scripts.test`, `pyproject.toml` → `[tool.pytest]`, `Makefile` test target, etc.).
      Verify it is executable.
   3. **Build detection**: If F8 `build` field exists → use that command. Otherwise, record the build command already verified in Step 1.

   **Result display** (example — adapt tool names to project stack):
   ```
   🔧 Toolchain Pre-flight:
     Build: ✅ {build command}
     Test:  ✅ {test command}
     Lint:  ⚠️ {lint tool} — configured but NOT installed
            💡 Install: {install command}
   ```

   **Classification**:
   - Tool configured + installed → `✅ available`
   - Tool configured but NOT installed → `⚠️ warning` — offer auto-install (see below)
   - Tool not configured → `ℹ️ not configured` (informational note)

   **Auto-install offer** (when tool is configured but not installed):
   Use AskUserQuestion:
   - "Install now" — run the install command from `domains/_core.md` § S3b install guidance (e.g., `npm install --save-dev eslint`). After install, re-verify (`--version` check). If successful → update status to `✅ available`.
   - "Skip — proceed without lint" — record `⚠️ not installed`, verify Phase 1 will skip lint checks for all Features.
   **If response is empty → re-ask** (per MANDATORY RULE 1).

   **Record** in `sdd-state.md` → `## Toolchain` section (see `reference/state-schema.md`).
   This cached result is read by verify Phase 1 to skip unavailable tools without re-discovering.

   After toolchain checks, if Framework ≠ "custom"/"none":

   4. **Platform Foundation Status Check**:
      - Read sdd-state.md § Foundation Decisions § T0 Features
      - If T0 Features exist and any have status ≠ "completed"/"skipped":
        Foundation Status: PENDING
      - If no T0 Features exist:
        Foundation Status: N/A (no Foundation Features defined)
      - If all T0 completed:
        Foundation Status: READY

   5. **Display**: Add Foundation Status to existing Foundation Verified line:
      `Foundation Verified: {date} | {toolchain status} | Platform: {Foundation Status}`

   6. **Gating rule**:
      - Foundation Status PENDING + processing T1+ Feature → BLOCK
        "T0 Foundation Features must complete before T1. Process T0 first."
      - Foundation Status N/A → PASS (no Foundation Features, proceed)
      - Foundation Status READY → PASS

2. **Generate Foundation test file** (e.g., `tests/foundation.spec.ts` or equivalent for the project's test framework):
   Based on constitution tech stack, generate tests for each applicable Checklist category. Each test should verify the **intent** described in the Checklist, using the project's actual APIs and framework conventions.

   > **Example (Web/Electron + Playwright)** — adapt to your stack:
   > ```typescript
   > import { test, expect } from '@playwright/test';
   > test('Theme tokens load at runtime', async ({ page }) => {
   >   await page.goto('http://localhost:PORT/');
   >   const token = await page.evaluate(() =>
   >     getComputedStyle(document.documentElement).getPropertyValue('--bg-primary').trim()
   >   );
   >   expect(token).not.toBe('');
   > });
   > test('Core layout renders without error', async ({ page }) => {
   >   await page.goto('http://localhost:PORT/');
   >   const errors: string[] = [];
   >   page.on('pageerror', e => errors.push(e.message));
   >   await page.waitForTimeout(3000);
   >   expect(errors).toHaveLength(0);
   > });
   > ```

   Generate additional tests for other Checklist categories (State Management, IPC/Cross-boundary, etc.) using the same pattern: start app → exercise the system → assert no errors.

3. **Run Foundation tests** (3-tier fallback):
   a. If the project's test runner is available (e.g., `@playwright/test`, `pytest`, `go test`): start app → run tests → parse results → map to Checklist
   b. Else if MCP available: start app → run applicable checks via MCP
   c. Else: build-only mode. Display:
      `⚠️ Foundation verification limited to build check. Install the project's test framework OR configure Playwright MCP for runtime checks.`
4. **Foundation test file is committed** — becomes a regression test for all subsequent Features. Re-run on subsequent Features only if Foundation-affecting files changed.

**Result display** (adapt category names and details to project stack):
```
🏗️ Foundation Verification:
  ✅ Build: clean build succeeded
  🔧 Toolchain: Build ✅, Test ✅, Lint [✅ / ⚠️ / ℹ️]
  [✅/⚠️/⏭️] Theme/Styling: {result}
  [✅/⚠️/⏭️] State Management: {result}
  [✅/⚠️/⏭️] IPC / Cross-boundary: {result or "skipped (not applicable)"}
  [✅/⚠️/⏭️] Layout: {result}

Foundation status: PASS (N warnings)
```

**Multi-ecosystem build check**: If sdd-state.md Foundation contains comma-separated values (multi-language project), verify build succeeds for each ecosystem. Record per-ecosystem results. A Feature that spans multiple ecosystems must have ALL relevant builds passing.

**Record** in `sdd-state.md`: `Foundation Verified: [date] | [PASS/WARN/FAIL] | [details]`
- PASS or WARN → proceed to Feature pipeline
- Any BLOCKING check fails → **HARD STOP**. Use AskUserQuestion:
  - "Fix Foundation issues and retry" — user fixes, agent re-runs gate
  - "Override and proceed" — requires reason via "Other" input. Records `⚠️ FOUNDATION-OVERRIDE — [reason]`
  **If response is empty → re-ask** (per MANDATORY RULE 1)

**On subsequent Features**: Skip if `Foundation Verified` exists in `sdd-state.md` AND no Foundation-affecting changes since last verification. Foundation-affecting changes = modifications to files outside `specs/` that touch cross-cutting systems (styling/theme config, state management definitions, layout/navigation components, inter-process communication handlers, build config — varies by stack).

### Step 3d — Dependency Cycle Detection

1. Read roadmap.md Dependency Graph
2. Run topological sort (Kahn's algorithm conceptual):
   - For each Feature, collect its dependencies
   - Detect cycles: if a Feature appears in its own transitive dependency chain → CYCLE
3. If cycle detected:
   Display: "Dependency cycle detected: F001 → F003 → F005 → F001"
   **Use AskUserQuestion**: "How to resolve this cycle?"
   - Options: "Break cycle by removing dependency", "Abort pipeline"
   **If response is empty → re-ask** (per MANDATORY RULE 1)
4. Store validated processing order for Feature iteration

### Step 4 — Feature Selection

Determines which Feature(s) to process based on the invocation arguments.

#### 4a. Single-Feature Mode (default — no `--all`)

**If Feature ID is specified** (e.g., `pipeline F003`):
1. Validate FID exists in sdd-state.md
2. If Feature is `deferred` → BLOCK: "❌ [FID] is deferred (Tier [N]). Run /smart-sdd expand first."
3. Use this Feature as the **target Feature**

**If no Feature ID specified** (e.g., `pipeline` or `pipeline --start verify`):
Auto-select the **next Feature** in pipeline order:
1. First Feature with `in_progress` status → resume it
2. If none, first Feature with `restructured` status → re-run from 🔀 step
3. If none, first Feature with `pending` status → start it
4. If none (all completed/adopted/deferred) → "✅ All active Features are completed!" and stop

Display the selected Feature:
```
🎯 Target Feature: [FID]-[name] ([status])
   [Current position: specify/plan/tasks/... or "starting fresh"]
```

#### 4b. Batch Mode (`--all`)

When `--all` is specified, ALL active Features (not `completed`, `adopted`, or `deferred`) are selected for processing. They will be processed in Release Group order, one at a time, each Feature completing all steps before moving to the next.

Display the batch plan:
```
📋 Batch Mode: [N] Features will be processed

  [FID]-[name]: [status] → [starting step]
  [FID]-[name]: [status] → [starting step]
  ...

[D] deferred, [C] completed (skipped).
```

#### 4c. --start Pre-check (when `--start <step>` is specified)

**Valid `--start` values**: `specify`, `plan`, `tasks`, `analyze`, `implement`, `verify`

1. **Validate start step**: Confirm the value is one of the valid steps above. If invalid, display error and list valid values.

2. **Constitution check**: Verify `.specify/memory/constitution.md` exists and is finalized. If not → BLOCK:
   ```
   ❌ Constitution has not been finalized.
   Run /smart-sdd pipeline (without --start) or /smart-sdd constitution first.
   ```

3. **Prerequisite check** (for selected Feature(s) from 4a or 4b):

   | --start | Required prerequisites (must be ✅) |
   |---------|--------------------------------------|
   | specify | (none — only constitution) |
   | plan | specify |
   | tasks | specify, plan |
   | analyze | specify, plan, tasks |
   | implement | specify, plan, tasks, analyze |
   | verify | specify, plan, tasks, analyze, implement |

   - If prerequisites not met → BLOCK with missing step details
   - If the `--start` step is already ✅ → **mark it 🔀 and re-execute**. This is the purpose of `--start` — force re-run from a specific step
   - Steps AFTER `--start` that were already ✅ are also re-executed (marked 🔀)

   **Branch handling for already-merged Features** (when Feature status is `completed` or `adopted`):
   🚫 BLOCKING — If the target Feature was already merged to main, the old Feature branch is stale. **Always create a fresh branch from current main** (delete old branch if it exists). See [`branch-management.md`](../reference/branch-management.md) § Revisiting a Completed Feature. This ensures the branch has ALL other Features' code, not just the original Feature's code.

   **Cross-Feature Impact Analysis** (when `--start specify` or `--start plan`):
   After the re-executed step completes and BEFORE cascading downstream within this Feature, run the Impact Analysis Protocol from [`cascading-update.md`](../reference/cascading-update.md) § Cross-Feature Impact Analysis Protocol. This checks whether the spec/plan change affects entities or APIs that other Features reference, and lets the user choose which downstream Features to mark for re-run. Skip Impact Analysis for `--start tasks` or later (no public interface change).

4. **Display confirmation (HARD STOP)**:

   **Single-Feature mode**:
   ```
   📋 Pipeline --start [step] for [FID]-[name]

   Prerequisites: ✅ all met
   [step] status: [✅ → will re-run | pending → will run]
   Flow: [step] → ... → merge
   ```

   **Batch mode** (`--all`):
   ```
   📋 Pipeline --start [step] (batch)

   ── Eligible Features ─────────────────────────
     ✅ [FID]-[name]: will run [step] → ... → merge
     🔀 [FID]-[name]: will re-run from [step]

   ── Blocked Features (prerequisites not met) ──
     ❌ [FID]-[name]: missing: [step1], [step2]

   ──────────────────────────────────────────────
   [N] Features will be processed, [M] blocked, [D] deferred.
   ```

   Use AskUserQuestion (HARD STOP):
   - "Proceed" (single) / "Proceed with [N] Features" (batch)
   - "Abort"

   **If response is empty → re-ask** (per MANDATORY RULE 1).

> **Note**: `--start` **forces re-execution** of the named step, even if already ✅. Steps AFTER the named step that were already ✅ are also re-executed (marked 🔀). Steps BEFORE the named step are not affected.

### Phase 0: Constitution Finalization

**Skip check**: Skip Phase 0 entirely if ANY of the following is true:
- `--start` is specified (constitution is verified during --start Pre-check; Phase 0 is skipped)
- `.specify/memory/constitution.md` already exists AND its content is not just the initial template (i.e., it has been finalized by `speckit-constitution`)

This covers:
- `--start` mode (constitution already verified as prerequisite)
- `add` mode (constitution already created in previous pipeline runs)
- Pipeline re-runs after interruption (constitution was already finalized)
- Any scenario where `speckit-constitution` has already been executed

**If constitution has not been finalized**:

Execute the **full Common Protocol** — same 4-step flow as Features:

```
constitution → Assemble → Checkpoint(STOP) → speckit-constitution + Review(STOP) → Update
```

#### Phase 0-1. Assemble

Read `BASE_PATH/constitution-seed.md`:
- For greenfield/init: Uses the constitution-seed generated by the init command
- For rebuild: Uses the constitution-seed generated by `/reverse-spec`

#### Phase 0-2. Checkpoint (HARD STOP)

Display the constitution-seed content per [injection/constitution.md → Checkpoint Display Content](../reference/injection/constitution.md). Then follow **PROCEDURE CheckpointApproval** (defined in Step 2 of the Common Protocol). Do NOT proceed to Phase 0-3 until the user explicitly approves.

#### Phase 0-3. Execute + Review (HARD STOP)

> **⚠️ MANDATORY RULE 3 REMINDER**: After `speckit-constitution` returns, do NOT show its raw output ("Constitution finalized", "Suggested commit", etc.). You MUST suppress it, read the artifact, display Review, and call AskUserQuestion. Skipping this HARD STOP to "proceed to Phase 1" is a violation — NOT continuity. See SKILL.md Rule 3.

**This is ONE continuous step — ALL of the following (1-7) MUST happen in the SAME response. Do NOT generate a separate response after step 1.**

1. Provide the constitution-seed content as context and execute `speckit-constitution`
2. **In the SAME response** — SUPPRESS any "Suggested commit", "Constitution finalized", "Next step", or navigation output from speckit-constitution. Do NOT show these to the user.
3. **In the SAME response** — read `.specify/memory/constitution.md` — the **entire file**
4. Display the Review content per [injection/constitution.md → Review Display Content](../reference/injection/constitution.md)
5. Show the "Files You Can Edit" block with the absolute path to `constitution.md`
6. Follow **PROCEDURE ReviewApproval** (defined in Step 3c of the Common Protocol). If the response is empty — re-ask. Do NOT proceed.
7. **Catch-all**: If this response ends without AskUserQuestion (for ANY reason), you MUST show: `✅ speckit-constitution executed.\n💡 Type "continue" to review the results.` — Do NOT end silently. Do NOT skip to Phase 1.

Constitution is the most critical artifact — it governs all subsequent Features.

#### Phase 0-3b. Archetype Detection from Constitution-Seed

After reading the constitution-seed content (Phase 0-1), check for archetype-specific principles:
1. Scan constitution-seed for archetype-indicative sections (e.g., "AI Assistant Domain", "Public API Domain", "Microservice Domain")
2. If detected and sdd-state.md `**Archetype**` is `"none"` or missing:
   - Update sdd-state.md Archetype field with the detected archetype name(s)
   - Display: `🔍 Archetype detected from constitution-seed: {archetype-name}`
3. If sdd-state.md already has a non-"none" Archetype value: no change needed (already set during init or manually)

This step ensures rebuild/adoption workflows (which skip init) still get archetype information from reverse-spec analysis.

#### Phase 0-4. Update

Record the constitution completion in `sdd-state.md`:
- Set Constitution Status to `completed`
- Set Constitution Version to the version from the generated file
- Set Constitution Completed At to current ISO 8601 timestamp
- Add entry to Constitution Update Log

**Decision History Recording — Constitution**:
After Phase 0-4 completes, **append** to `specs/history.md` (create with the standard header if it doesn't exist — see SKILL.md § History File Header):

```markdown
---

## [YYYY-MM-DD] /smart-sdd pipeline — Constitution

### Constitution

| Decision | Details |
|----------|---------|
| Constitution Version | [version from generated file] |
| Key Modifications | [changes made during review, or "Accepted as-is"] |
```

**Post-Phase 0 validation**: Run `scripts/validate.sh <project-root>` to check cross-file consistency (Feature IDs, SBI mappings, Demo Group references). If ❌ errors are found, display them and resolve before proceeding. ⚠️ warnings are informational — note but continue.

**After recording and validation, IMMEDIATELY proceed to Phase 1 below. Do NOT stop. Do NOT wait for user input. Do NOT suggest running a separate command. The pipeline is a continuous flow — constitution finalization is just the first step.**

> **Fallback**: If you cannot immediately proceed (e.g., context limit reached), display:
> ```
> ⏸️ Pipeline paused after Constitution finalization.
> To resume: /smart-sdd pipeline (or type "continue")
>
> → Next: [first-FID]-[first-name]
>   Steps: specify → plan → tasks → analyze → implement → verify → merge
> ```

### Phase 1~N: Process Features

Processes the Feature(s) selected in Step 4 (Feature Selection). In single-Feature mode (default), only ONE Feature is processed. In batch mode (`--all`), Features are processed in Release Group order.

**Feature processing order**: T0 → T1 → T2 → T3
- **T0 (Foundation)**: Infrastructure Features from Foundation categories (BST, SEC, framework-specific)
- **T0 Features MUST complete before T1 begins** — they establish the platform infrastructure that T1+ Features depend on
- **Within T0**: order by Foundation category dependency (BST first, then SEC, then framework-specific)
- T1/T2/T3 ordering follows existing Tier-based rules (see analyze.md § Feature ID Tier-first ordering)

**Feature processing rules**:
- **Core scope**: Only active-Tier Features are processed. Deferred Features are skipped.
- **Full scope**: All Features are active.
- **Adopted Features**: Status `adopted` → skipped. To transition to `completed`, target with `pipeline [FID]`.
- **Restructured Features**: Start from first 🔀 step (see `reference/restructure-guide.md`).
- **--start mode**: Skip steps before `--start`, force re-execute from `--start` onward. Already-✅ steps at or after `--start` are marked 🔀.

**CRITICAL: Each Feature must complete ALL steps (from its starting step through verify and merge) before moving to the next Feature.** Do NOT skip implement or verify. Do NOT start the next Feature until the current Feature's merge step is complete.

Executes the following steps **strictly in order** for each Feature.

**Every "Review" below is a HARD STOP — you MUST use AskUserQuestion and WAIT for explicit user approval before continuing.**

```
0. pre-flight → Ensure on main branch (clean state) → Create Feature branch {NNN}-{short-name}
1. specify    → Assemble → Checkpoint(STOP) → speckit-specify → Review(STOP) → Update
   1b. clarify → Auto-scan spec.md for ambiguities → speckit-clarify (conditional sub-step of specify)
2. plan       → Assemble → Checkpoint(STOP) → speckit-plan → Review(STOP) → Update
3. tasks      → Checkpoint(STOP) → speckit-tasks → Review(STOP) → Update
4. analyze    → Checkpoint(STOP) → speckit-analyze → Review(STOP) (CRITICAL issues block implement) (simplified — Assemble/Update are no-ops)
5. implement  → Env check(STOP if missing) → Checkpoint(STOP, file plan + parallel plan + B-3 remind) → speckit-implement (parallel file ownership) + Per-Task Runtime Verify + Fix Loop → Post-Implement SC Verify → Smoke Launch → **Completeness Gate(BLOCK)** → Demo-Ready Delivery → Review(STOP)
6. verify     → Checkpoint(STOP) → Phase 1(BLOCK) → Phase 2 → Phase 3(SC Verify) → Evidence Gate(BLOCK) → Review(STOP) → Phase 4(Update)
7. merge      → Verify-gate(BLOCK if not success/limited) → Checkpoint(STOP) → Merge Feature branch to main → Cleanup

── Feature DONE ── only now proceed to the next Feature ──
```

> **Reminder**: `(STOP)` means you MUST call AskUserQuestion, display the content, and WAIT for the user's response. Do NOT auto-approve. Do NOT skip.
>
> **CRITICAL**: After each `speckit-*` command completes, it prints its own "Next phase:" or "Next step:" message. **IGNORE these messages completely — do NOT show them to the user.** smart-sdd controls the flow: after Execute, you MUST immediately proceed to the Review(STOP) step, not follow spec-kit's suggestions.

> **🚫 AGENT BEHAVIORAL RULES** (apply to ALL pipeline steps):
>
> **1. Pipeline Completion Bias Prevention**: After specify→plan→tasks→analyze→implement in one session, the agent's implicit goal shifts from "ensure quality" to "finish the pipeline." This manifests as: Level 1 verification (code review only), skipping Playwright launch, declaring "12/12 SC ✅" without evidence. **verify MUST have the same rigor regardless of how many steps preceded it.**
>
> **2. Automate, Don't Delegate**: If the agent CAN do it programmatically, do NOT ask the user. App restart → `pkill + pnpm run dev`. DB state check → `sqlite3 query`. Log review → capture to file + grep. localStorage reset → code-level clear. KB rebuild → script. **Only delegate truly non-automatable actions** (OS-native drag&drop, visual judgment, external API key entry).
>
> **3. Empty Results → Investigate, Don't Report**: When a query/search/API returns empty results `[]`, do NOT report "results are empty" to the user. Instead: (1) check data exists in storage, (2) check query was formed correctly, (3) check intermediate processing logs, (4) identify and fix the root cause, (5) THEN report the fix. `❌ "Search results are []" → ✅ "DB has 3 records but threshold 0.7 was too high, returning 0. Adjusted to 0.3 and confirmed 3 results returned."`
>
> **4. Fix → Runtime Verify → Report**: Every code fix must be followed by runtime verification before reporting to user. `❌ Code fix → build passes → "Fix complete" → ✅ Code fix → build → run app → verify the specific feature works → "Fix complete, runtime verified"`

> **🔄 CASCADING UPDATE PROTOCOL** (apply at ALL HARD STOPs after specify):
>
> When the user requests changes or directly edits an artifact file (spec.md, plan.md, tasks.md):
>
> **1. NEVER modify code directly to address user feedback.** First determine: is this a spec issue, plan issue, tasks issue, or code bug?
> **2. Update the HIGHEST-LEVEL artifact first**, then cascade incrementally downstream.
> **3. If user edited a file directly**, detect the change and offer cascading update.
>
> ```
> ❌ User: "citation doesn't work" → agent modifies code directly
> ✅ User: "citation doesn't work" → "No FR for citation in spec.md.
>    Adding FR-008 + SC-008 → cascading to plan (CitationBlock)
>    → tasks (T012) → implement T012 → verify SC-008"
> ```
>
> **Read [`reference/cascading-update.md`](../reference/cascading-update.md) when**:
> - User requests changes at any Review HARD STOP
> - User says "this should also do X" or "X is missing"
> - Artifact file timestamps changed since last check
> - verify finds Major-Spec or Major-Plan issue
>
> **Do NOT read it** at every HARD STOP — only when a change is detected.

> **⚠️ INTER-STEP CONTINUITY — DO NOT STOP BETWEEN STEPS**:
> After a step's Update completes and there are remaining steps, **IMMEDIATELY begin the next step** (e.g., plan Update done → start tasks Checkpoint). Do NOT display a "completed" summary and wait. Do NOT show "Next steps" commands. The pipeline is a continuous flow within a Feature — the ONLY valid pause points are HARD STOPs (awaiting user approval), BLOCK conditions, Feature completion, or unrecoverable errors. If you find yourself about to generate a response that ends without starting the next step — **STOP, you are breaking continuity. Proceed to the next step.**

#### Specify Execute+Review (HARD STOP)

> **⚠️ MANDATORY RULE 3 REMINDER**: After `speckit-specify` returns, do NOT show its raw output ("Spec created and validated", "Ready for /speckit.clarify or /speckit.plan", "Coverage: N functional requirements", etc.). You MUST suppress it, read the artifact, display Review, and call AskUserQuestion. Stopping after raw output is **Violation Pattern A** — see SKILL.md Rule 3.

> **🚨 rebuild + GUI mandatory gate** (must verify before specify Review):
> - **Entry Point BLOCKING**: Verify that **each** entry path from pre-context § Entry Points is defined as a separate FR. Missing = BLOCKING.
>   ❌ WRONG: FR-035 "accessible from navigation" (1 abstract FR)
>   ✅ RIGHT: FR-035 "Sidebar icon → /knowledge", FR-036 "Inputbar KB button", FR-037 "Assistant settings KB link" (3 concrete FRs)
> - **Domain Rule Compliance (S1)**: Verify that active domain module S1 SC rules are reflected in spec.md. Coverage < 50% = BLOCKING.
> - **Source app UI controls**: In rebuild mode, verify that source app UI control types (dropdown, slider, auto-fill) are reflected in FRs.
>   ❌ WRONG: FR "create KB with name, model, dimensions" (text-level description)
>   ✅ RIGHT: FR "create KB: select embedding model from provider dropdown, dimensions auto-filled" (UI control-level description)

1. **CI Pre-check (greenfield only)**: Read `Clarity Index` and `CI Low-confidence` from sdd-state.md. If CI < 40%: insert an inline clarify sub-step — ask 1–2 targeted questions for the lowest-confidence dimensions, re-score, then proceed. If Core Purpose confidence ≤ 1: **HARD STOP** — "Purpose unclear, clarify before proceeding to specify."
2. Execute `speckit-specify` via Inline Execution (NOT Skill tool)
3. **In the SAME response** — SUPPRESS any "Ready for", "Coverage:", "No [NEEDS CLARIFICATION]", "Spec created" or navigation output from speckit-specify. Do NOT show these to the user.
4. Run Post-Execution Verification Sequence from `injection/specify.md` (SBI Accuracy, Platform Constraints, Edge Cases, Entry Point check, Domain Rule Compliance, etc.)
5. **CI Coverage Check (greenfield, CI 40–69% only)**: After reading spec.md, verify every CI dimension with confidence ≤ 1 has at least one FR or SC addressing it. If gaps found, list them in the Review as "⚠️ CI Coverage Gaps" section. Also: if Target Users confidence ≤ 1, add "user role identification" note. If Key Capabilities confidence ≤ 1, add "completeness gap" warnings.
6. Read `SPEC_PATH/{NNN-feature}/spec.md` and assemble Review Display
7. **HARD STOP**: Call AskUserQuestion with ReviewApproval options
8. **Catch-all**: If this response ends without AskUserQuestion (for ANY reason), you MUST show: `✅ speckit-specify executed for [FID] - [Feature Name].\n💡 Type "continue" to review the results.` — Do NOT end silently. Do NOT skip to plan.

#### Plan Execute+Review (HARD STOP)

> **🚨 CRITICAL: Read `reference/injection/plan.md`** — Entity/API Registry Filtering, Stack Migration context, Scale & Cross-Concern adjustments. Generating a plan without reading injection/plan.md means missing entity schemas, API contracts, and Scale-appropriate architecture depth.

> **⚠️ MANDATORY RULE 3 REMINDER**: After `speckit-plan` returns, do NOT show its raw output ("Plan created", "architecture decisions", etc.). You MUST suppress it, read the artifact, display Review, and call AskUserQuestion. Stopping after raw output is **Violation Pattern A**.

> **🚨 rebuild + GUI mandatory gate** (must verify before plan Review):
> - **Source Component Mapping** (🚫 BLOCKING): plan.md must contain a Source→Target Component Mapping table. Each source app component must be mapped to a target. Unmapped source component = BLOCKING.
> - **Entity Ownership Conflict** (🚫 BLOCKING): If an entity in data-model.md is owned by a different Feature in entity-registry = conflict. Cannot approve until resolved.
> - **Data Lifecycle Mapping**: Source app's data paradigm (opt-in/opt-out/CRUD order) must be specified in the plan. Unspecified = WARNING.

1. **Read `reference/injection/plan.md`** — Entity/API Registry Filtering, Stack Migration, Scale & Cross-Concern adjustments
2. Execute `speckit-plan` via Inline Execution (NOT Skill tool)
3. **In the SAME response** — SUPPRESS any navigation output from speckit-plan. Do NOT show these to the user.
4. **CI Propagation Check (greenfield only)**: Read `CI Low-confidence` from sdd-state.md. If CI 40–69%: in Review, emphasize low-CI areas and highlight architecture decisions compensating for uncertainty. If CI < 40%: display "⚠️ Low-CI areas remain underspecified" warning before Review. Per-dimension: if Project Type confidence ≤ 1, Review must include "Interface Choice Rationale". If Tech Stack confidence ≤ 1, Review must include "Tech Stack Rationale". If Scale & Scope confidence ≤ 1, plan should default to minimal architecture.
5. Read `SPEC_PATH/{NNN-feature}/plan.md` and assemble Review Display
6. **Entity Ownership Conflict Gate**: Before showing Review options, check for entity ownership conflicts:
   - Read `SPEC_PATH/{NNN-feature}/data-model.md` (just generated by plan)
   - For each entity defined in data-model.md, look up `BASE_PATH/entity-registry.md`
   - If an entity already exists in the registry with a **different Owner Feature** → **CONFLICT DETECTED**
   - Display conflict report in Review:
     ```
     🚫 Entity Ownership Conflict:
       Entity: [EntityName]
       Current Feature claiming ownership: [current FID]
       Existing owner in registry: [other FID]

     Resolution options:
       a) Reference instead of own — remove from data-model.md, reference existing definition
       b) Transfer ownership — update registry to new owner (coordinate with previous owner's spec)
       c) Split entity — create a new entity variant with a distinct name
     ```
   - **BLOCK ReviewApproval until all conflicts are resolved.** The user must select a resolution for each conflict before approving the plan.
   - If no conflicts: proceed to Review normally (no message needed)
7. **HARD STOP**: Call AskUserQuestion with ReviewApproval options
8. **Catch-all**: If this response ends without AskUserQuestion (for ANY reason), you MUST show: `✅ speckit-plan executed for [FID] - [Feature Name].\n💡 Type "continue" to review the results.` — Do NOT end silently. Do NOT skip to tasks.

#### Tasks Execute+Review (HARD STOP)

> **🚨 CRITICAL: Read `reference/injection/tasks.md`** (if it exists) — for task-specific injection context. If no tasks-specific injection file exists, the Common Protocol Assemble step + `context-injection-rules.md` shared patterns apply.

> **⚠️ MANDATORY RULE 3 REMINDER**: After `speckit-tasks` returns, do NOT show its raw output. You MUST suppress it, read the artifact, display Review, and call AskUserQuestion. Stopping after raw output is **Violation Pattern A**.

1. Execute `speckit-tasks` via Inline Execution (NOT Skill tool)
2. **In the SAME response** — SUPPRESS any navigation output from speckit-tasks. Do NOT show these to the user.
3. Read `SPEC_PATH/{NNN-feature}/tasks.md` and assemble Review Display
4. **HARD STOP**: Call AskUserQuestion with ReviewApproval options
5. **Catch-all**: If this response ends without AskUserQuestion (for ANY reason), you MUST show: `✅ speckit-tasks executed for [FID] - [Feature Name].\n💡 Type "continue" to review the results.` — Do NOT end silently. Do NOT skip to implement.

#### Clarify Trigger (after specify Review)

After `speckit-specify` completes and the user approves the Review, **automatically scan** the generated `spec.md` for ambiguities before proceeding to plan:

1. **Scan for explicit markers**: Search `spec.md` for `[NEEDS CLARIFICATION]`, `[TBD]`, `[TODO]`, `???`, or `<placeholder>` markers
2. **Scan for vague qualifiers**: Check for ambiguous adjectives without measurable criteria (e.g., "fast", "scalable", "intuitive", "robust")
3. **If ambiguities found**:
   - Display: "⚠️ Ambiguities detected in spec.md. Running speckit-clarify to resolve them."
   - Execute `speckit-clarify` via Inline Execution (NOT Skill tool)
   - `speckit-clarify` will ask the user up to 5 questions interactively and update spec.md directly
   - After clarify completes, re-scan to verify ambiguities are resolved
   - If unresolved ambiguities remain, display them and ask if the user wants to run clarify again or proceed
4. **If no ambiguities found**: Skip clarify and proceed directly to plan
   - Display: "✅ No critical ambiguities detected in spec.md. Proceeding to plan."

#### Clarify Execute+Review (HARD STOP)

> **⚠️ MANDATORY RULE 3 REMINDER**: After `speckit-clarify` returns, do NOT show its raw output. You MUST suppress it, read the artifact, display Review, and call AskUserQuestion. Stopping after raw output is **Violation Pattern A**.

1. Execute `speckit-clarify` via Inline Execution (NOT Skill tool)
2. **In the SAME response** — SUPPRESS any navigation output from speckit-clarify. Do NOT show these to the user.
3. Read the updated `SPEC_PATH/{NNN-feature}/spec.md` and assemble Review Display (show clarification results: questions asked, answers received, spec sections updated)
4. **HARD STOP**: Call AskUserQuestion with ReviewApproval options
5. **Catch-all**: If this response ends without AskUserQuestion (for ANY reason), you MUST show: `✅ speckit-clarify executed for [FID] - [Feature Name].\n💡 Type "continue" to review the results.` — Do NOT end silently. Do NOT skip to plan.

#### Analyze Execute+Review (HARD STOP)

> **⚠️ MANDATORY RULE 3 REMINDER**: After `speckit-analyze` returns, do NOT show its raw output. You MUST suppress it, read the artifact, display Review, and call AskUserQuestion. Stopping after raw output is **Violation Pattern A**.

1. Execute `speckit-analyze` via Inline Execution (NOT Skill tool)
2. **In the SAME response** — SUPPRESS any navigation output from speckit-analyze. Do NOT show these to the user.
3. Read the analysis output and assemble Review Display (show: CRITICAL issues that block implement, warnings, analysis summary)
4. **HARD STOP**: Call AskUserQuestion with ReviewApproval options. If CRITICAL issues exist, inform the user they block implement.
5. **Catch-all**: If this response ends without AskUserQuestion (for ANY reason), you MUST show: `✅ speckit-analyze executed for [FID] - [Feature Name].\n💡 Type "continue" to review the results.` — Do NOT end silently. Do NOT skip to implement.

#### Per-Feature Environment Variable Check (implement step)

Environment variables are checked **per Feature, at implement time** — not aggregated upfront. This ensures variables are only requested when the Feature that needs them is about to be implemented.

**Skip conditions**: If the current Feature's `pre-context.md` has no Environment Variables section or it contains only "None" / "TBD", skip this check entirely.

Before running `speckit-implement`, read the current Feature's `pre-context.md` → "Environment Variables" section and check for required variables:

**Step 1 — Collect this Feature's required env vars**:
Read `SPEC_PATH/{NNN-feature}/pre-context.md` → "Environment Variables" section.
Include both Feature-owned variables AND shared variables listed in the "Shared variables" sub-table.

**Step 2 — Check .env file**:
- If `.env` exists: Check for the **presence** of each required variable name (do NOT read actual values)
- If `.env` does not exist: All variables are missing

**Step 3 — Display and confirm (HARD STOP if missing required vars)**:

```
📋 Environment Variables for [FID]-[name]:

── Required ────────────────────────────────────
  ✅ DATABASE_URL     — already set
  ❌ STRIPE_SECRET_KEY — missing [secret] Payment processing API key
  ❌ STRIPE_WEBHOOK_SECRET — missing [secret] Webhook verification

── Optional ────────────────────────────────────
  ✅ LOG_LEVEL        — already set
  ❌ SENTRY_DSN       — missing [config] Error tracking (optional)

⚠️ I will NOT ask you to paste secret values here.
   Edit the .env file directly in your editor.
```

**If any REQUIRED variables are missing**:
Use AskUserQuestion (HARD STOP):
- "Environment is ready — I've added the missing variables"
- "Skip for now — proceed without them"

**If response is empty → re-ask** (per MANDATORY RULE 1). If "Environment is ready": Re-check `.env` to verify the missing variables are now present. If still missing, display which ones and ask again.
If "Skip for now": Display warning "⚠️ Tests may fail due to missing environment variables." and proceed.

**If all required variables are present** (or the Feature has no env vars):
Display: "✅ All required environment variables for [FID]-[name] are set." and proceed directly to Checkpoint (no HARD STOP needed).

> **Security rule**: NEVER read actual values from `.env`. Only check for the **presence** of variable names.

#### Parallel Agent File Ownership (implement step)

When using background agents (Agent tool) to parallelize implement tasks:

1. **File scope separation**: Before dispatching agents, partition the task list so each agent's files **do not overlap**. Display the partition in the Checkpoint for user review
2. **Shared entry point reservation**: Files that multiple tasks naturally touch (e.g., app entry point, router/navigation config, service registry, dependency injection root) are **not assigned to any parallel agent**. The main agent writes these files after all parallel agents complete, integrating their outputs
3. **Conflict detection**: After all agents complete, run `git diff --name-only` per agent. If any file appears in multiple agents' diffs → the main agent must manually reconcile before proceeding
4. **Sequential fallback**: If clean file separation is not feasible (too many shared files), execute tasks sequentially instead of in parallel. Note: sequential is the default — parallel is an optimization, not a requirement

#### Dependency Stub Enforcement Gate

> **Purpose**: Prevent implementing a Feature when its dependencies have unresolved stubs that this Feature depends on. Without this gate, the agent builds on placeholder implementations that will break when the dependency Feature is completed and stubs are replaced with real code.

Before assembling the implement Checkpoint, check:

1. Read `sdd-state.md` → Feature Progress to identify preceding Features that the current Feature depends on (from roadmap.md Dependency Graph)
2. For each dependency Feature that has completed implement: check if `specs/{NNN-dep}/stubs.md` exists
3. If stubs.md exists, scan for entries where **Depends On** matches the current Feature ID
4. For each such entry, check if the dependency Feature's stub has been resolved (stub file references actual implementation)

**If unresolved stubs found that BLOCK the current Feature**:

```
🚫 Dependency Stub Block for [FID]:

  F001-auth has unresolved stubs that [FID] depends on:
    ❌ getUserProfile() — stub returns mock data, real implementation pending
    ❌ validateToken() — stub always returns true

  These stubs will cause [FID] to build against fake implementations.
  When F001's stubs are resolved, [FID]'s code will break.

  Options:
    - "Resolve stubs first" — implement the real code in F001 before proceeding
    - "Proceed with awareness" — acknowledge stub dependency, record ⚠️ STUB-DEPENDENT
```

**HARD STOP** — Use AskUserQuestion with the options above. **If response is empty → re-ask** (per MANDATORY RULE 1).

If "Proceed with awareness": record `⚠️ STUB-DEPENDENT — [stub list]` in sdd-state.md Feature Detail Log. verify Phase 2 will re-check these stubs.

**Skip if**: No dependency Features have stubs.md, or no stubs reference the current Feature.

#### Implement Execute (MANDATORY — injection/implement.md Required Reading)

> **🚨 CRITICAL: The core gates for implement are in `reference/injection/implement.md`, NOT in this file (pipeline.md).**
> **You MUST read `reference/injection/implement.md` before starting implement.**
> **Generating code without reading injection/implement.md is a CRITICAL violation.**
>
> Gates that MUST be executed especially in rebuild + GUI projects:
>
> 1. **Source Reference Injection** (🚫 BLOCKING): Must actually read source app code before each UI task.
>    UI task without `📂 Source Reference` = gate violation.
>    ❌ WRONG: Generate UI based only on tasks.md text
>    ✅ RIGHT: Read source AddKnowledgeBasePopup.tsx → reproduce ModelSelector + auto-dimensions
>
> 2. **Background Agent Source Injection** (🚫 BLOCKING): Source code original text must be included in agent prompt.
>    ❌ WRONG: "Create a dialog with name, model, dims inputs"
>    ✅ RIGHT: Paste source code + "Reproduce this UX flow in the new stack"
>
> 3. **Post-Implement Gates** (after implement completes, before Review):
>    - Semantic Stub Detection: Math.random(), placeholder, external call bypass → 🚫 BLOCKING
>    - Integration Contract Fulfillment: Verify actual invocation of plan's "Consumes ←" → 🚫 BLOCKING
>    - UI Control Type Audit: Source Select → Target Input = UX downgrade → 🚫 BLOCKING

> **⚠️ MANDATORY RULE 3 REMINDER**: After `speckit-implement` returns, do NOT show its raw output ("Suggested commit", "Implementation complete", etc.). You MUST suppress it, read the artifacts, display Review, and call AskUserQuestion. Stopping after raw output is **Violation Pattern A**.

1. **Read `reference/injection/implement.md`** — Source Reference, Background Agent Injection, Post-Implement Gates
2. Execute `speckit-implement` via Inline Execution (NOT Skill tool)
3. **In the SAME response** — SUPPRESS any navigation output from speckit-implement.
4. Run Post-Implement Gates (Semantic Stub Detection + Integration Contract + UI Control Audit). Display results.
5. Read the implementation artifacts and assemble Review Display — show implementation summary + gate results.
6. **HARD STOP**: Call AskUserQuestion with ReviewApproval options
7. **Catch-all**: If this response ends without AskUserQuestion (for ANY reason), you MUST show: `✅ speckit-implement executed for [FID] - [Feature Name].\n💡 Type "continue" to review the results.` — Do NOT end silently. Do NOT skip to verify.

#### Implement Checkpoint Display

The implement Checkpoint MUST show the following before user approval:
- **File plan**: List of files to create/modify (derived from tasks.md), grouped by module/layer
- **Parallel execution plan** (if using background agents): Which agent handles which files, and which files are reserved for post-agent integration
- **Dependency install plan**: Packages to be added
- **Dependency stub status**: Stubs from preceding Features that affect this Feature (if any — from Dependency Stub Enforcement Gate above)

If tasks are executed sequentially (default), the parallel execution plan is omitted.

#### Post-Implement Smoke Launch

> **⚠️ implement is NOT complete until Smoke Launch passes.** Do NOT mark implement ✅ and defer failures to verify. If the app cannot launch, implement is still in progress.

After build succeeds and before proceeding to the Review step, perform a **smoke launch** to catch build-pass-but-runtime-crash issues:

1. **Start the app** using the project's standard launch command (dev or preview mode)
2. **Wait 5 seconds** — if the process exits with a non-zero code or stderr contains crash indicators (uncaught exception, segfault, FATAL), the smoke launch fails
3. **For GUI projects (MANDATORY)**: Take a Playwright snapshot (`page.accessibility.snapshot()`) and verify:
   - The window is not blank (snapshot contains interactive elements)
   - Layout structure is reasonable (elements are not all stacked linearly without styling — symptom of build-time framework misconfiguration, e.g., CSS plugin missing, asset pipeline broken)
   - Content is rendered (not showing raw template keys, placeholder text, or empty containers that should have data)
   - If Playwright CLI is not available, manually inspect the running app and report what is visible
4. **GUI operability check**: If the Feature includes user-facing UI, verify basic operability:
   - Can the user perform the fundamental interactions the Feature provides? (e.g., window control, navigation, settings access)
   - If the UI is a placeholder with no interactive elements → this is a smoke launch failure
5. **Shut down** the app after the check
6. **On failure**: Follow the Auto-Fix Escalation below

**Smoke Launch Auto-Fix Escalation** (step 6 detail):

```
Level 1 — Code Fix (agent handles autonomously):
  Build errors, missing imports, config issues, runtime exceptions
  → Fix immediately within implement (no Source Modification Gate needed)
  → Re-run smoke launch

Level 2 — Environment Fix (agent attempts before asking user):
  Native/compiled dependency failures, toolchain version mismatches
  → Identify the failing dependency and attempt platform-appropriate rebuild
  → If auto-fix succeeds → re-run smoke launch
  → If auto-fix fails → Level 3

Level 3 — HARD STOP (only after Level 1-2 exhausted):
  Use AskUserQuestion with:
  - "Retry after manual environment fix" — user fixes toolchain, agent re-runs smoke launch
  - "Switch to alternative dependency" — agent replaces the failing module with a compatible alternative
  - "Proceed with build-only verification" — mark implement as ⚠️ SMOKE-LAUNCH-DEGRADED, NOT ✅
```

> **CRITICAL**: The "Proceed with build-only" option does NOT mark implement ✅. It records `⚠️ SMOKE-LAUNCH-DEGRADED` in sdd-state.md Feature Progress and carries a warning into verify. The implement status line shows `implement ⚠️` (not ✅).
>
> ❌ **Wrong**: "✅ implement complete. Verify is blocked by [issue]."
> ✅ **Right**: "⚠️ implement — Smoke Launch failed ([reason]). HARD STOP for resolution."

> This overlaps with verify Phase 0's Dev Mode Stability Probe but catches issues earlier, avoiding the verify → regression → re-implement cycle.

#### Post-Implement Completeness Gate

> **⚠️ implement is NOT complete until the Completeness Gate passes.** This gate catches incomplete implementations BEFORE they reach verify — where detection is too late and produces only non-blocking warnings.

After Smoke Launch passes, verify implementation completeness:

1. **Task completion audit**: Read `specs/{NNN-feature}/tasks.md` → count checked `[x]` vs total `[ ]` tasks.
   - 100% completion → ✅ proceed
   - <100% completion → list uncompleted tasks and **HARD STOP**:
     ```
     ⚠️ Completeness Gate — [N]/[total] tasks incomplete:
       [ ] Task 5: Implement settings persistence
       [ ] Task 8: Add keyboard shortcuts
     ```
     **Use AskUserQuestion**:
     - "Complete remaining tasks before Review" — resume implement for missing tasks
     - "Defer [N] tasks — proceed to Review" — user explicitly acknowledges incomplete (recorded in sdd-state.md Notes: `⚠️ DEFERRED: [task list]`)
     **If response is empty → re-ask** (per MANDATORY RULE 1)

2. **Rebuild parity check** (rebuild mode + GUI only):
   - If visual references exist (`specs/_global/visual-references/manifest.md`): verify that the Visual Reference Checkpoint (see `injection/implement.md`) was executed (check sdd-state.md for `📂 Visual References` or `📂 Source App Reference` entry)
   - If NO visual reference was consulted for a GUI Feature in rebuild mode → **HARD STOP**:
     ```
     ⚠️ Completeness Gate — No visual reference consulted for rebuild GUI Feature:
       Visual references/ directory: [exists / not found]
       Source app reference: [captured / not captured]

     Rebuild without visual reference is high-risk for layout divergence.
     ```
     **Use AskUserQuestion**:
     - "Load visual references now" — capture source app screenshots or read static references
     - "Acknowledge risk — proceed without visual reference" (recorded: `⚠️ NO-VISUAL-REF`)
     **If response is empty → re-ask** (per MANDATORY RULE 1)

3. **Display gate result**:
   ```
   ✅ Completeness Gate:
     Tasks: [N]/[N] complete
     Visual reference: [✅ consulted / ⚠️ deferred / N/A (not rebuild)]
   ```

> **Git branching**: smart-sdd creates the Feature branch during pre-flight (Step 0), before `speckit-specify`. All subsequent steps (specify through verify) execute on that branch. After verify completes, smart-sdd handles the merge back to main. See [branch-management.md](../reference/branch-management.md) for details.
>
> **⚠️ Feature Number & Branch Conflict Prevention**: Since smart-sdd creates the Feature branch `{NNN}-{short-name}` in pre-flight (Step 0), the branch already exists when `speckit-specify` runs. Two conflicts can occur:
> 1. **Numbering conflict**: `create-new-feature.sh` auto-numbering detects `{NNN}` as "in use" and assigns the next number → branch/directory mismatch. **Prevention**: pass the Feature name as `{NNN}-{short-name}` (e.g., `002-navigation`) so `create-new-feature.sh` uses the explicit number. **Recovery**: If mismatch occurs, rename the directory (`mv specs/{wrong}-{name} specs/{NNN}-{name}`) and delete the spurious branch.
> 2. **Branch-already-exists error**: `create-new-feature.sh` tries to create a branch that smart-sdd already created → `git checkout -b` fails with "already exists." **This error is non-fatal.** The pre-created branch from smart-sdd pre-flight is correct. Ignore the branch creation error and proceed directly to spec directory/file creation. If `create-new-feature.sh` terminates on this error, manually create `specs/{NNN}-{short-name}/` and run `speckit-specify` without the branch creation step.

📋 **Dependency Stub Registry**: After implement completion, generate `specs/{NNN-feature}/stubs.md` if any stub/placeholder implementations depend on future Features. See `injection/implement.md` § Post-Step Update Rules #2 for format and detection rules. These stubs are auto-injected into the dependent Feature's pipeline context.

📝 **Decision History Recording — Feature Implementation** (after merge):
**Append** to `specs/history.md` for EVERY completed Feature:

```markdown
### [FID]-[name] — Implementation Decisions

**Delivers**: [What the user can now do — e.g., "Users can register, login, and manage accounts via OAuth or email/password"]

| Decision | Choice | Details |
|----------|--------|---------|
| [e.g., Spec deviation] | [what changed] | [why — from specify/plan review discussions] |
| [e.g., Architecture choice] | [pattern/approach chosen] | [rationale] |
| [e.g., Limited verification] | [what was limited] | [reason and planned resolution] |

#### Philosophy Adherence
- [Principle name]: [How this Feature applied or was constrained by the principle — e.g., "Streaming-First: Implemented SSE streaming for chat responses (FR-003, FR-004)"]
- [Principle name]: [e.g., "Secure by Default: Context isolation enforced in preload script (FR-001)"]
```

> **"Delivers" field is MANDATORY** for every Feature — this is the user-facing narrative of what was built. It feeds into the auto-generated Pipeline Completion Report § Outcomes.
>
> **"Philosophy Adherence" section**: Read the project's constitution (`.specify/memory/constitution.md`) for active archetype/F7 principles. Reference the Feature's spec.md and implementation decisions to identify which principles were applied. If no principles apply to this Feature, write "N/A — no applicable archetype/F7 principles for this Feature". This feeds into the Pipeline Completion Report § Philosophy Assessment.
>
> **Decision table**: Only include rows if there were meaningful decisions — spec deviations, architecture choices, trade-offs, limited verification. If no notable decisions, omit the table (but keep "Delivers" and "Philosophy Adherence").

#### Delegate, Don't Skip (common across all pipeline stages — delegate to user when automation is impossible)

> **🚨 The agent's tool limitations are NOT the limits of verification.**
> When encountering a verification that cannot be automated, do NOT "skip" — use AskUserQuestion to request specific manual confirmation from the user.
>
> ❌ "Skip due to Playwright limitations" → unverified items pass silently
> ✅ "Automated testing is not possible. Please perform [specific action] and verify [expected result]"
>
> This principle applies to all verification stages including implement smoke launch, verify Phase 3, demo verification, etc.

---

#### Runtime Error Triage Protocol (common across all pipeline stages)

> **🚨 This protocol applies not only to verify but whenever the user reports a runtime error or points out a non-functioning feature at any point in the pipeline.**

When the user reports a problem with phrases like "there's an error", "it doesn't work", "it's not working properly":

```
1. Error analysis: Trace the root cause (crash log, undefined access, empty data, etc.)
2. Scope check: Is this the only issue? Are there other issues with the same pattern?
   → Run Semantic Stub Detection (Math.random, placeholder, external call bypass)
   → Verify actual invocation of Integration Contracts
3. Apply Bug Fix Severity Rule (same criteria as verify-phases.md):
   | Severity | Condition | Action |
   |----------|-----------|--------|
   | Minor | ≤2 files, no API change | Fix inline OK |
   | Major-Implement | 3+ files OR new component needed | Return to implement |
   | Major-Plan | Architecture/contracts change needed | Return to plan |
   | Major-Spec | Requirements themselves are wrong | Return to specify |
4. If Major → HARD STOP (AskUserQuestion):
   "🔴 Major-[level] issue detected — [N] files affected.
    Pipeline regression to [level] recommended. Proceed?"
   Options: "Return to [level]", "Fix inline anyway (risk acknowledged)"
5. Even if the user requests "just fix it now", if it's Major-Implement or above,
   propose regression first. Only fix inline if the user explicitly selects "fix inline anyway".
```

```
❌ WRONG: User "there's an error" → agent starts code modification immediately (without severity assessment)
✅ RIGHT: User "there's an error" → agent analyzes → "6 files need modification, this is Major-Implement.
          Shall we return to the implement stage for systematic fixes?"
```

> **NEVER fix a Major issue inline while skipping pipeline regression.** verify is the FINDING stage, not the REWRITING stage.

---

#### Verify Execute (MANDATORY — verify-phases.md Required Reading)

> **🚨 CRITICAL: The detailed verify procedures are in `commands/verify-phases.md`, NOT in this file (pipeline.md).**
> **You MUST read `commands/verify-phases.md` before starting verify.**
> **Performing only "build + TS + lint" without reading verify-phases.md does NOT constitute verify.**
>
> 1. Read `commands/verify-phases.md` — Phase 0 (Runtime Readiness), Phase 1 (Static),
>    Phase 2 (Cross-Feature), Phase 3 (SC Verification), Phase 3b (Bug Prevention)
> 2. Read `reference/injection/verify.md` — Checkpoint/Review content rules
> 3. Execute ALL Phases in order per verify-phases.md
> 4. Display Verify Execution Checklist in Review

**Verify Execution Checklist** (MUST be displayed in verify Review — blank "Executed?" = BLOCKING):

```
| Phase | Required? | Executed? | Result | Skip Reason |
|-------|-----------|-----------|--------|-------------|
| 0-2 App Launch (Playwright) | Yes (GUI) | | | |
| 0-4b Reachability Gate | Yes (GUI) | | | |
| 1 Build/TS/Lint | Yes | | | |
| 1 Tests | Yes (if test runner exists) | | | |
| 2 Cross-Feature Regression | Yes (if F002+) | | | |
| 3 SC Verification (Playwright) | Yes | | | |
| 3b Bug Prevention (B-4) | Yes | | | |
| 3e Source Comparison | Yes (rebuild+GUI) | | | |
| Demo --ci | Yes (if demo exists) | | | |
```

**Rules**:
- Every row with "Required? = Yes" MUST have "Executed?" filled (✅, ⚠️, or ❌)
- To skip a required phase, "Skip Reason" MUST be non-empty (e.g., "No test runner configured", "CLI-only Feature")
- Verify Review with **any blank Required row** is BLOCKING — cannot approve
- "Executed?" = ❌ (failed) is acceptable IF the failure is classified by severity (Minor/Major) per verify-phases.md Bug Fix Severity Rule

**Domain Profile conditions** (determines "Required?" value):
- `(GUI)` = active when `gui` or `tui` is in Interfaces (Axis 1)
- `(rebuild+GUI)` = active when Scenario (Axis 5) = `rebuild` AND GUI is active
- `(if F002+)` = active when current Feature is not the first Feature
- Scale modifier (project_maturity) affects enforcement WITHIN phases (SC depth, test coverage thresholds) but does NOT allow skipping entire phases. Even `prototype` mode must execute all Required phases — the difference is in pass/fail criteria, not in whether the phase runs.

> **Domain Profile independent**: The Checklist structure itself (must display, blank=BLOCKING) applies regardless of Domain Profile. This is a pipeline integrity rule, not a domain-specific rule.

**Anti-pattern ban**:
```
❌ WRONG: pnpm run dev & sleep N; kill $PID → "Smoke Launch ✅"
  → This is NOT Playwright verification. It's a process existence check.

✅ RIGHT: const app = await _electron.launch({args: ['out/main/index.js']})
  → Playwright accessibility.snapshot() + Feature-specific element verification
```

#### Verify Execute+Review (HARD STOP)

> **⚠️ MANDATORY RULE 3 REMINDER**: After verify phases complete, do NOT just show "verify ✅". You MUST suppress navigation output, display the Verify Execution Checklist with results, and call AskUserQuestion. Stopping with only a summary is **Violation Pattern A**.

1. Execute all verify phases per `commands/verify-phases.md` and `reference/injection/verify.md`
2. **In the SAME response** — SUPPRESS any spec-kit navigation messages. Do NOT show these to the user.
3. Assemble Review Display: filled Verify Execution Checklist (above) + per-SC verification results + bug severity classifications
4. **HARD STOP**: Call AskUserQuestion with ReviewApproval options
5. **Catch-all**: If this response ends without AskUserQuestion (for ANY reason), you MUST show: `✅ Verification executed for [FID] - [Feature Name].\n💡 Type "continue" to review the results.` — Do NOT end silently. Do NOT skip to merge.

#### Verify Structural Enforcement Gates (SKF-053)

> These gates address the structural root cause of shallow verification: agents skip detailed phase files and improvise with general knowledge. Each gate is **count-based or evidence-based**, not trust-based — the agent's self-report is insufficient.

**Gate V1 — Verify Depth Structural Check (🚫 BLOCKING)**:

Before verify Review, count the number of Tier 2+ (behavioral) SC verifications actually performed:
- Tier 2 = click/interact → state change confirmed
- Tier 3 = action in A → effect in B confirmed

```
If behavioral_count == 0 AND total_SCs > 3:
  🚫 "Zero behavioral verifications performed. All checks were Tier 1
  (existence only). Pipeline Completion Bias detected."
  → MUST re-run Phase 3 with Tier 2+ depth.
```

This gate is **structural** (count-based), not **trust-based** (agent self-report). An agent that only checks "button exists" without clicking it scores behavioral_count = 0.

**Gate V2 — Smoke Launch Minimum Bar (🚫 BLOCKING for GUI Features)**:

Process alive check (e.g., `kill -0 $PID`) does NOT constitute Smoke Launch. At minimum 1 GUI interaction must succeed:

```
For each Interface type:
  gui/tui:  Launch app → navigate to Feature page → verify page content is non-empty
  http-api: Start server → health check endpoint returns 200 with body
  cli:      Run command with --help → verify output contains expected subcommands
  data-io:  Run pipeline with test input → verify output file exists and is non-empty

❌ kill -0 $PID → "alive" → ✅  (process check only — NOT acceptable)
✅ _electron.launch() → navigate → textContent.length > 0 → ✅  (GUI content verified)
✅ curl localhost:3000/health → 200 {"status":"ok"} → ✅  (API health verified)
```

**Gate V3 — Evidence-Based Task Verification (🚫 BLOCKING for cross-feature tasks)**:

For tasks involving cross-Feature integration (marked with `cross-feature:` in Interaction Chains or `Consumes ←` in Integration Contracts):
1. Identify the target file(s) from the task description
2. Check `git diff --name-only` for those files
3. If file NOT in diff → task was NOT implemented regardless of checkbox state

```
❌ tasks.md checkbox [x] but file not in git diff → task declared done but code unchanged
✅ tasks.md checkbox [x] AND file appears in git diff → task actually implemented
```

**Gate V4 — Evidence Column in Verify Checklist (🚫 BLOCKING)**:

The Verify Execution Checklist (above) MUST include an "Evidence" column. Each Phase's `Executed?` field requires a supporting evidence string:

```
| Phase | Required? | Executed? | Evidence | Result |
|-------|-----------|-----------|----------|--------|
| 0-4b Reachability | Yes (GUI) | ✅ | Playwright: click .sidebar-knowledge → /knowledge loaded (2.1s) | pass |
| 3 SC Verify | Yes | ✅ | Matrix: 12 SCs, 8 cdp-auto (Tier 2), 2 user-assisted, 2 ext-dep | 10/12 verified |

"Evidence" column empty → Executed? ✅ is INVALID → BLOCKING
```

This prevents agents from marking ✅ without having actually performed the verification step.

**Gate V5 — Functional Smoke Test (🚫 BLOCKING — after build passes, before verify)**:

Build ✅ + TypeScript ✅ does NOT mean implement is complete. After static checks pass, perform 3 functional tests:

1. **Integration Contract Functional Test**: For each "Consumes ←" in plan.md, trigger the integration in the running app and confirm it succeeds. User-assisted dependencies (API keys) → ask user to configure first.

2. **External Library Functional Test**: For each new library added, verify it works in the bundled environment (not just dev). Import failures in Electron/webpack/vite bundles are invisible to `tsc`.

3. **Platform API Functional Test**: For Electron preload-exposed APIs, IPC channels, or platform-specific APIs — verify the call works end-to-end (renderer → preload → main → response).

```
❌ Build passes + tsc clean → "implement complete"
   → 7/7 runtime bugs in F006 passed build+tsc (SKF-056)

✅ Build passes + tsc clean + 3 functional tests pass → "implement complete"
   → Integration calls verified, libraries import in bundle, platform APIs respond
```

If ANY functional test fails → remain in implement and fix before proceeding to verify.

---

#### Feature Completion

**Single-Feature mode (default)**:

After the Feature completes all steps through merge:
```
✅ [FID]-[name] completed and merged to main!

📊 Progress: [completed]/[total] Features done
💡 Next Feature: /smart-sdd pipeline (auto-selects [next-FID]-[next-name])
   Or target: /smart-sdd pipeline [next-FID]
```

The pipeline STOPS here. The user runs `pipeline` again when ready for the next Feature.

**Batch mode (`--all`)**:

After each Feature completes, ask whether to continue to the next:

**HARD STOP**: Use AskUserQuestion:
- "Proceed to next Feature ([next-FID]-[next-name])"
- "Stop here — I'll continue later"

**If response is empty → re-ask** (per MANDATORY RULE 1).

If "Stop here":
```
⏸️ Pipeline paused. [completed]/[total] Features done.
💡 Resume: /smart-sdd pipeline --all
```

**All Features completed** (both modes):

```
🎉 All active Features completed!

📊 Final Status: [completed]/[total] Features done
  Constitution: ✅ v[version]

Next steps:
  /smart-sdd pipeline         — Process next Feature (if any remain)
  /smart-sdd status           — View final progress report
  /smart-sdd add              — Define new Feature(s) (spec only, then run pipeline to build)
```

**Pipeline Completion Report (MANDATORY — auto-generated)**:

After all Features are completed, generate the Pipeline Completion Report automatically:

1. Read the shared template: `~/.claude/skills/shared/reference/completion-report.md`
2. Set mode = `rebuild-pipeline` (for rebuild) or `adoption` (for adopt — note: adopt has its own report trigger in adopt.md)
3. Follow the template's Data Extraction protocol (Steps 2-1 through 2-10) to populate all sections
4. Write to `specs/_global/pipeline-report.md`
5. Display summary:
   ```
   📊 Pipeline Completion Report saved to specs/_global/pipeline-report.md

   Key metrics:
   - [N] Features completed across [N] Release Groups
   - [N] SBI entries (P1: [N], P2: [N], P3: [N])
   - [N] entities, [N] APIs
   - Demo Groups: [completed]/[total]
   ```

> This auto-report replaces the manual `/case-study` invocation. All data is extracted from existing artifacts (history.md, sdd-state.md, registries, pre-contexts, specs) — no separate log file needed.

**Final validation**: Run `scripts/validate.sh <project-root>` to verify cross-file consistency across all completed Features. Display any ❌ errors or ⚠️ warnings.

**If the pipeline is interrupted mid-Feature** (e.g., context limit, user pauses, error):
```
⏸️ Pipeline paused at [FID]-[name] → [current-step]

💡 Type "continue" to resume from where you left off.
   Or run: /smart-sdd pipeline [FID]
```

> **Pipeline continuity rule**: Within a single Feature, the pipeline is a CONTINUOUS flow. The only reasons to stop are: (1) HARD STOP checkpoints requiring user approval, (2) BLOCK conditions (verify/merge gates), (3) Feature completed, or (4) Unrecoverable error. Never display "Next steps" with commands unless the pipeline is actually stopping.
>
> **Common violation**: After a step's Review is approved and Update completes, the agent displays a "✅ step completed" message and stops — forcing the user to type "continue". This is WRONG. After Update, immediately begin the next step's Assemble/Checkpoint. The user should only see HARD STOP prompts (AskUserQuestion), not "continue" prompts between steps.

---

## Feature ID → spec-kit Feature Name Mapping

> Full naming convention and conversion rules: see `reference/state-schema.md` § Feature Mapping.

**Quick reference**: `F001-auth` (smart-sdd) ↔ `001-auth` (spec-kit/git branch). Strip/prepend `F` prefix. The `short-name` MUST match between both systems.

---

## Constitution Incremental Update

When new architectural principles or conventions are discovered during Feature progression:

1. **Checkpoint indication**: "Proposing a Constitution update: [principle content]"
2. **User approval**: Uses AskUserQuestion with options: "Approve constitution update", "Reject — keep current version", "Request modifications". **If response is empty → re-ask** (per MANDATORY RULE 1)
3. **Execute update**: If approved, performs a MINOR version update via `speckit-constitution`

#### Verify Critical Gates (inline — always in context)

> **🚨 These gates are inlined here because verify-phases.md and phase files may be pushed out of context. These 3 rules MUST be followed regardless of which phase files are loaded.**

1. **🚫 Code review alone CANNOT pass an SC**: Confirming "code path exists" via Explore agent → SC ✅ is absolutely prohibited. SC pass requires runtime evidence (Playwright logs, HTTP responses, user confirmation). SCs without evidence are BLOCKING in Review.
   ```
   ❌ "knowledge:search exists in useChatStore" → SC-002 ✅
   ✅ "Playwright: KB linked → message sent → kbSearchCalled=true" → SC-002 ✅
   ```

2. **🚫 Reading source code is mandatory for rebuild fixes**: When modifying code during verify, the corresponding source app file must be read first. Prevents the pattern of improvising patches based on error messages → patch on top of patch → "start from scratch" loop.

3. **🚫 Same SC fails 2 times → Major escalation**: If the same SC fails 2 consecutive times after fixes, do NOT patch in verify — return to implement.

4. **🚫 Verify Depth Structural Check (count-based, not trust-based)**: Before verify Review, count the number of **Tier 2+** (behavioral) SC verifications performed:
   - Tier 2 = click/interact → state change confirmed
   - Tier 3 = action in Feature A → effect in Feature B confirmed
   - **If behavioral_count == 0 AND total_auto_SCs > 0**: `🚫 Zero behavioral verifications performed. All checks were Tier 1 (existence only). Pipeline Completion Bias detected. Must re-run Phase 3 with Tier 2+ depth.`
   - This is a **structural gate** (count-based) — the agent cannot self-report Tier 2 without actually performing a click→state change sequence that produces a different snapshot/state than before the click.

5. **🚫 Evidence-Based Completeness Gate (diff-based, not checkbox-based)**: For cross-feature tasks in tasks.md, verify the target file appears in `git diff --name-only`. If tasks.md says "modify Inputbar.tsx to add KB button" but Inputbar.tsx is NOT in the diff → task was NOT implemented, regardless of checkbox state.

> For full gate details: [verify-phases.md](verify-phases.md) (Source Modification Gate, Evidence Gate), [verify-sc-verification.md](verify-sc-verification.md) (SC Matrix, depth requirements)

#### Constitution Incremental Update Execute+Review (HARD STOP)

> **⚠️ MANDATORY RULE 3 REMINDER**: After `speckit-constitution` (incremental update) returns, do NOT show its raw output. You MUST suppress it, read the artifact, display Review, and call AskUserQuestion. Stopping after raw output is **Violation Pattern A**.

1. Execute `speckit-constitution` via Inline Execution (NOT Skill tool)
2. **In the SAME response** — SUPPRESS any navigation output from speckit-constitution. Do NOT show these to the user.
3. Read the updated `.specify/memory/constitution.md` and assemble Review Display (show diff summary: what principles were added/modified, version bump)
4. **Impact analysis**: Display a warning if already completed Features are affected by the updated principles
5. **HARD STOP**: Call AskUserQuestion with ReviewApproval options
6. **Catch-all**: If this response ends without AskUserQuestion (for ANY reason), you MUST show: `✅ speckit-constitution (incremental update) executed.\n💡 Type "continue" to review the results.` — Do NOT end silently.

---

## Analyze Command

Running `/smart-sdd analyze [FID]` executes `speckit-analyze` to verify cross-artifact consistency **before implementation**.

> **🚨 CRITICAL: Read `reference/injection/analyze.md`** (if it exists) — for analyze-specific injection context. If no analyze-specific injection file exists, the Common Protocol Assemble step + `context-injection-rules.md` shared patterns apply.

**When**: After `tasks` step completes, before `implement` step.

**What it does**: `speckit-analyze` is a READ-ONLY analysis that checks consistency across spec.md, plan.md, and tasks.md. It identifies gaps, duplications, ambiguities, and inconsistencies.

**Workflow**:
1. Execute `speckit-analyze` via the Common Protocol (Assemble → Checkpoint → Execute+Review → Update)

   > **⚠️ MANDATORY RULE 3 REMINDER — Execute+Review Continuity**:
   > After `speckit-analyze` completes, **SUPPRESS** any raw analysis output, "next steps", or navigation messages.
   > Instead: Read the analysis report artifact → Display the Review below → Call AskUserQuestion.
   > These three actions MUST happen in the SAME response as execution.

2. Review the analysis report:
   - If **CRITICAL** issues exist (including FR with zero mapped tasks): Block implementation. The user must resolve them first (re-run specify, plan, or tasks as needed)
   - If **HIGH** issues exist (including FR with partial task coverage): Strongly recommend addressing, but user may override and proceed
   - If only **MEDIUM/LOW** issues: Display findings, user may proceed or address them
3. Record analysis results in `sdd-state.md`

   > If this response ends without AskUserQuestion after speckit-analyze execution — for ANY reason (context limit, error, unexpected flow) — you MUST show:
   > `✅ speckit-analyze executed.`
   > `💡 Type "continue" to review the results.`

**Prerequisite**: `tasks.md` must exist for the Feature (`speckit-analyze` requires all three artifacts: spec.md, plan.md, tasks.md)

> **Note**: `speckit-analyze` checks intra-Feature artifact consistency (spec ↔ plan ↔ tasks). Cross-Feature entity/API consistency is checked separately during `verify` (after implementation).

---

## See Also

- **Verify phases**: `commands/verify-phases.md` — Phase 1-4 verification workflow (loaded only for verify command)
- **Git branch management**: `reference/branch-management.md` — Branch lifecycle, merge workflow, pre-flight checks
