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
  # type = "review"     → options: ["Approve", "Request modifications", "I've finished editing"]
  LOOP:
    response = AskUserQuestion(options per type above)

    IF response is empty/blank → re-ask ("⚠️ No approval received. Please select one option.")
    IF approved (yes/lgtm/approve) → BREAK LOOP → proceed to next step
    IF "Request modifications" → ask what to change → apply → re-display → CONTINUE LOOP
    IF "I've finished editing" (review only) → re-read artifacts → show diff → ask approve/edit-more
    OTHERWISE → re-ask with valid options
```

**⚠️ CRITICAL**: If response is empty — you have NOT received approval. Call AskUserQuestion AGAIN. Do NOT proceed.

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

### Step 3b — Foundation Verification Gate (first Feature only)

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

**Record** in `sdd-state.md`: `Foundation Verified: [date] | [PASS/WARN/FAIL] | [details]`
- PASS or WARN → proceed to Feature pipeline
- Any BLOCKING check fails → **HARD STOP**. Use AskUserQuestion:
  - "Fix Foundation issues and retry" — user fixes, agent re-runs gate
  - "Override and proceed" — requires reason via "Other" input. Records `⚠️ FOUNDATION-OVERRIDE — [reason]`
  **If response is empty → re-ask** (per MANDATORY RULE 1)

**On subsequent Features**: Skip if `Foundation Verified` exists in `sdd-state.md` AND no Foundation-affecting changes since last verification. Foundation-affecting changes = modifications to files outside `specs/` that touch cross-cutting systems (styling/theme config, state management definitions, layout/navigation components, inter-process communication handlers, build config — varies by stack).

### Step 3c — Dependency Cycle Detection

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

**Auto-initialize case study logging** (if not already present):
Check if `case-study-log.md` exists at project root:
- **If not exists**: Read [`case-study-log-template.md`](../../case-study/templates/case-study-log-template.md) and write it to `case-study-log.md`. Display: `📝 Case study log initialized: case-study-log.md`
- **If already exists**: Skip silently (created by `/reverse-spec` or manually)

📝 **Case Study Recording**: Append milestone entry to `case-study-log.md` per [recording-protocol.md](../../case-study/reference/recording-protocol.md) § M5.

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
6. verify     → Checkpoint(STOP) → Test/Build/Lint(BLOCK on fail) → Cross-Feature → Demo-Ready → SC UI Verify → Phase 3b (B-4) → Review(STOP) → Update
7. merge      → Verify-gate(BLOCK if not success/limited) → Checkpoint(STOP) → Merge Feature branch to main → Cleanup

── Feature DONE ── only now proceed to the next Feature ──
```

> **Reminder**: `(STOP)` means you MUST call AskUserQuestion, display the content, and WAIT for the user's response. Do NOT auto-approve. Do NOT skip.
>
> **CRITICAL**: After each `speckit-*` command completes, it prints its own "Next phase:" or "Next step:" message. **IGNORE these messages completely — do NOT show them to the user.** smart-sdd controls the flow: after Execute, you MUST immediately proceed to the Review(STOP) step, not follow spec-kit's suggestions.

> **⚠️ INTER-STEP CONTINUITY — DO NOT STOP BETWEEN STEPS**:
> After a step's Update completes and there are remaining steps, **IMMEDIATELY begin the next step** (e.g., plan Update done → start tasks Checkpoint). Do NOT display a "completed" summary and wait. Do NOT show "Next steps" commands. The pipeline is a continuous flow within a Feature — the ONLY valid pause points are HARD STOPs (awaiting user approval), BLOCK conditions, Feature completion, or unrecoverable errors. If you find yourself about to generate a response that ends without starting the next step — **STOP, you are breaking continuity. Proceed to the next step.**

#### Specify Execute+Review (HARD STOP)

> **⚠️ MANDATORY RULE 3 REMINDER**: After `speckit-specify` returns, do NOT show its raw output ("Spec created and validated", "Ready for /speckit.clarify or /speckit.plan", "Coverage: N functional requirements", etc.). You MUST suppress it, read the artifact, display Review, and call AskUserQuestion. Stopping after raw output is **위반 패턴 A** — see SKILL.md Rule 3.

1. **CI Pre-check (greenfield only)**: Read `Clarity Index` and `CI Low-confidence` from sdd-state.md. If CI < 40%: insert an inline clarify sub-step — ask 1–2 targeted questions for the lowest-confidence dimensions, re-score, then proceed. If Core Purpose confidence ≤ 1: **HARD STOP** — "Purpose unclear, clarify before proceeding to specify."
2. Execute `speckit-specify` via Inline Execution (NOT Skill tool)
3. **In the SAME response** — SUPPRESS any "Ready for", "Coverage:", "No [NEEDS CLARIFICATION]", "Spec created" or navigation output from speckit-specify. Do NOT show these to the user.
4. Run Post-Execution Verification Sequence from `injection/specify.md` (SBI Accuracy, Platform Constraints, Edge Cases, etc.)
5. **CI Coverage Check (greenfield, CI 40–69% only)**: After reading spec.md, verify every CI dimension with confidence ≤ 1 has at least one FR or SC addressing it. If gaps found, list them in the Review as "⚠️ CI Coverage Gaps" section. Also: if Target Users confidence ≤ 1, add "user role identification" note. If Key Capabilities confidence ≤ 1, add "completeness gap" warnings.
6. Read `SPEC_PATH/{NNN-feature}/spec.md` and assemble Review Display
7. **HARD STOP**: Call AskUserQuestion with ReviewApproval options
8. **Catch-all**: If this response ends without AskUserQuestion (for ANY reason), you MUST show: `✅ speckit-specify executed for [FID] - [Feature Name].\n💡 Type "continue" to review the results.` — Do NOT end silently. Do NOT skip to plan.

#### Plan Execute+Review (HARD STOP)

> **⚠️ MANDATORY RULE 3 REMINDER**: After `speckit-plan` returns, do NOT show its raw output ("Plan created", "architecture decisions", etc.). You MUST suppress it, read the artifact, display Review, and call AskUserQuestion. Stopping after raw output is **위반 패턴 A**.

1. Execute `speckit-plan` via Inline Execution (NOT Skill tool)
2. **In the SAME response** — SUPPRESS any navigation output from speckit-plan. Do NOT show these to the user.
3. **CI Propagation Check (greenfield only)**: Read `CI Low-confidence` from sdd-state.md. If CI 40–69%: in Review, emphasize low-CI areas and highlight architecture decisions compensating for uncertainty. If CI < 40%: display "⚠️ Low-CI areas remain underspecified" warning before Review. Per-dimension: if Project Type confidence ≤ 1, Review must include "Interface Choice Rationale". If Tech Stack confidence ≤ 1, Review must include "Tech Stack Rationale". If Scale & Scope confidence ≤ 1, plan should default to minimal architecture.
4. Read `SPEC_PATH/{NNN-feature}/plan.md` and assemble Review Display
5. **HARD STOP**: Call AskUserQuestion with ReviewApproval options
6. **Catch-all**: If this response ends without AskUserQuestion (for ANY reason), you MUST show: `✅ speckit-plan executed for [FID] - [Feature Name].\n💡 Type "continue" to review the results.` — Do NOT end silently. Do NOT skip to tasks.

#### Tasks Execute+Review (HARD STOP)

> **⚠️ MANDATORY RULE 3 REMINDER**: After `speckit-tasks` returns, do NOT show its raw output. You MUST suppress it, read the artifact, display Review, and call AskUserQuestion. Stopping after raw output is **위반 패턴 A**.

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
   - Execute `speckit-clarify` via the Common Protocol (Assemble → Checkpoint → Execute+Review → Update)
   - `speckit-clarify` will ask the user up to 5 questions interactively and update spec.md directly
   - After clarify completes, re-scan to verify ambiguities are resolved
   - If unresolved ambiguities remain, display them and ask if the user wants to run clarify again or proceed
4. **If no ambiguities found**: Skip clarify and proceed directly to plan
   - Display: "✅ No critical ambiguities detected in spec.md. Proceeding to plan."

#### Per-Feature Environment Variable Check (implement step)

Environment variables are checked **per Feature, at implement time** — not aggregated upfront. This ensures variables are only requested when the Feature that needs them is about to be implemented.

**Skip conditions**: If the current Feature's `pre-context.md` has no Environment Variables section or it contains only "None" / "TBD", skip this check entirely.

Before running `speckit-implement`, read the current Feature's `pre-context.md` → "Environment Variables" section and check for required variables:

**Step 1 — Collect this Feature's required env vars**:
Read `BASE_PATH/features/{FID}-{name}/pre-context.md` → "Environment Variables" section.
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
   - If visual references exist (`specs/reverse-spec/visual-references/manifest.md`): verify that the Visual Reference Checkpoint (see `injection/implement.md`) was executed (check sdd-state.md for `📂 Visual References` or `📂 Source App Reference` entry)
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

📝 **Case Study Recording**: Append milestone entry to `case-study-log.md` per [recording-protocol.md](../../case-study/reference/recording-protocol.md) § M6. When composing the `### Philosophy Adherence` subsection: read the project's constitution (`.specify/memory/constitution.md`) for active archetype/F7 principles, and reference the Feature's `spec.md` and implementation decisions from `history.md` to identify which principles were applied during this Feature's pipeline. If no archetype/F7 principles are active, record "N/A".

📝 **Decision History Recording — Feature Implementation** (after merge):
If there were notable decisions during this Feature's pipeline (specify → verify), **append** to `specs/history.md`:

```markdown
### [FID]-[name] — Implementation Decisions

| Decision | Choice | Details |
|----------|--------|---------|
| [e.g., Spec deviation] | [what changed] | [why — from specify/plan review discussions] |
| [e.g., Architecture choice] | [pattern/approach chosen] | [rationale] |
| [e.g., Limited verification] | [what was limited] | [reason and planned resolution] |
```

> **When to record**: Only if there were meaningful decisions — spec deviations, architecture choices, trade-offs, limited verification acknowledgments, or user-requested changes. If the Feature went through without notable decisions, skip this recording (do NOT create empty entries).

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

📝 **Case Study Recording**: Append milestone entry to `case-study-log.md` per [recording-protocol.md](../../case-study/reference/recording-protocol.md) § M8.

```
🎉 All active Features completed!

📊 Final Status: [completed]/[total] Features done
  Constitution: ✅ v[version]

Next steps:
  /smart-sdd pipeline         — Process next Feature (if any remain)
  /smart-sdd status           — View final progress report
  /smart-sdd add              — Add new Features to the project
```

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
4. **Impact analysis**: Displays a warning if already completed Features are affected

---

## Analyze Command

Running `/smart-sdd analyze [FID]` executes `speckit-analyze` to verify cross-artifact consistency **before implementation**.

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
