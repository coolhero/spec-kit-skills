# Pipeline Execution — Common Protocol + Feature Pipeline

> Reference: Read after `/smart-sdd pipeline` or any step-mode command (constitution, specify, plan, tasks, analyze, implement, verify) is invoked. For shared rules (MANDATORY RULES), see SKILL.md.
> For per-command context injection details, read `reference/injection/{command}.md` (shared patterns in `reference/context-injection-rules.md`).
> For git branch operations, also read `reference/branch-management.md`.

## Common Protocol: Assemble → Checkpoint → Execute+Review → Update

**All spec-kit command executions follow this 4-step protocol. Each step MUST be executed in order. No step may be skipped. In particular, Execute (Step 3) includes a mandatory Review HARD STOP — the spec-kit command runs, then the Review is presented, all in one continuous action.**

> ⚠️ **The most common failure mode is skipping Review.** After executing a spec-kit command (Step 3), you MUST stop, display the generated artifacts, and ask the user for approval. Do NOT proceed to Update without Review. Do NOT combine Execute and Update into a single flow.
>

### 1. Assemble — Context Assembly

- Reads the files/sections required for the given command from BASE_PATH
- Filters and assembles the necessary information per command according to [`reference/injection/{command}.md`](../reference/injection/)
- Also references actual implementation results from preceding Features (under `specs/`) if available
- **Graceful degradation**: If a source file is missing or a section contains only placeholder text (e.g., "N/A", "none yet"), that source is skipped. See [`reference/context-injection-rules.md`](../reference/context-injection-rules.md) § Missing/Sparse Content Handling for details.

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
- Invokes `speckit-[command]` via the Skill tool (e.g., `Skill(speckit-specify)`, `Skill(speckit-plan)`)
- Includes the assembled context content in the conversation so spec-kit can reference it
- Feature artifacts created/modified by the spec-kit command are located under `specs/{NNN-feature}/`
- **Prerequisite**: spec-kit skills must be installed in the target project (Step 0c handles this automatically)

#### Skill Invocation Fallback

If the Skill tool returns "Unknown skill" for a `speckit-*` command (e.g., skills were installed mid-session):
1. Read the skill's SKILL.md file directly: `.claude/skills/speckit-[command]/SKILL.md`
2. Execute the instructions contained in the SKILL.md as inline workflow steps
3. This ensures the pipeline can continue even when skills aren't registered in the current session
4. Display: "ℹ️ Using inline execution for speckit-[command] (skill not yet registered in this session)"

#### Execute Error Handling

If the spec-kit command fails (error, crash, partial output):
1. Display the error message to the user
2. Use AskUserQuestion with options: "Retry", "Abort step", "Troubleshoot". **If response is empty → re-ask** (per MANDATORY RULE 1).
3. If "Retry": Re-run the Execute step
4. If "Abort step": Record failure in sdd-state.md, do NOT proceed to Review
5. If "Troubleshoot": Help the user diagnose and fix the issue, then offer to retry

**⚠️ CRITICAL — SUPPRESS spec-kit output**: spec-kit commands print "Next phase:", "Suggested commit:", and other messages. **IGNORE ALL of them.** Do NOT relay them to the user. smart-sdd controls the workflow.

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

For detailed per-command Review Display Content, see [context-injection-rules.md](reference/context-injection-rules.md).

#### Step 3c. Ask for User Approval (HARD STOP)

Use `ApprovalGate(type: review)` from Step 2 above. **If response is empty → re-ask** (per MANDATORY RULE 1)

**Per-command option overrides**: Some commands use context-specific options (e.g., Clarify: "Run clarify again", Analyze: outcome-dependent, Verify: pass/fail-specific). See [context-injection-rules.md](reference/context-injection-rules.md) for details.

### 4. Update — Global Evolution Layer Refresh

Updates global artifacts to reflect the command execution results. For detailed update rules per step, see the Post-Step Update Rules in the corresponding [reference/injection/{command}.md](reference/injection/).

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

Running `/smart-sdd pipeline` progresses through the entire workflow sequentially.

### Pipeline Initialization

Before Phase 0, initialize the state and validate the source path.

**Step 1 — State file initialization**:
If `BASE_PATH/sdd-state.md` does not exist, create it:
1. Read `BASE_PATH/roadmap.md` to extract the Feature list and Tiers
2. Generate `sdd-state.md` following the [state-schema.md](reference/state-schema.md) format
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

### Phase 0: Constitution Finalization

**Skip check**: Before executing, check if `.specify/memory/constitution.md` already exists AND its content is not just the initial template (i.e., it has been finalized by `speckit-constitution`). If it does, skip Phase 0 entirely and proceed to Phase 1. This covers:
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

Display the constitution-seed content per [injection/constitution.md → Checkpoint Display Content](reference/injection/constitution.md). Then follow **PROCEDURE CheckpointApproval** (defined in Step 2 of the Common Protocol). Do NOT proceed to Phase 0-3 until the user explicitly approves.

#### Phase 0-3. Execute + Review (HARD STOP)

**This is ONE continuous step — ALL of the following (1-7) MUST happen in the SAME response. Do NOT generate a separate response after step 1.**

1. Provide the constitution-seed content as context and execute `speckit-constitution`
2. **In the SAME response** — ignore any "Suggested commit" or "Next step" output from speckit-constitution
3. **In the SAME response** — read `.specify/memory/constitution.md` — the **entire file**
4. Display the Review content per [injection/constitution.md → Review Display Content](reference/injection/constitution.md)
5. Show the "Files You Can Edit" block with the absolute path to `constitution.md`
6. Follow **PROCEDURE ReviewApproval** (defined in Step 3c of the Common Protocol). If the response is empty — re-ask. Do NOT proceed.

Constitution is the most critical artifact — it governs all subsequent Features.

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
- **If not exists**: Read the case-study skill's `templates/case-study-log-template.md` and write it to `case-study-log.md`. Display: `📝 Case study log initialized: case-study-log.md`
- **If already exists**: Skip silently (created by `/reverse-spec` or manually)

📝 **Case Study Recording**: Append milestone entry to `case-study-log.md` per [recording-protocol.md](../../case-study/reference/recording-protocol.md) § M5.

**After recording, IMMEDIATELY proceed to Phase 1 below. Do NOT stop. Do NOT wait for user input. Do NOT suggest running a separate command. The pipeline is a continuous flow — constitution finalization is just the first step.**

> **Fallback**: If you cannot immediately proceed (e.g., context limit reached), display:
> ```
> ⏸️ Pipeline paused after Constitution finalization.
> To resume: /smart-sdd pipeline (or type "continue")
>
> → Next: [first-FID]-[first-name]
>   Steps: specify → plan → tasks → analyze → implement → verify → merge
> ```

### Phase 1~N: Progress Features in Release Group Order

Follows the Release Groups order from `BASE_PATH/roadmap.md`. **Skips completed, adopted, and deferred Features** — only processes Features with `pending`, `in_progress`, or `restructured` status in `sdd-state.md`.

- **Core scope**: Initially only Tier 1 Features are active (`Active Tiers: T1` in `sdd-state.md`). Tier 2/3 Features are `deferred` and skipped until activated via `/smart-sdd expand`.
- **Full scope**: All Features are active — no deferred Features exist.
- **Adopted Features**: Features with status `adopted` (from `/smart-sdd adopt`) are skipped. To transition them to `completed`, re-run the standard pipeline — it will re-execute tasks + implement + verify.
- **Restructured Features**: Processed starting from their first 🔀 step (see `commands/restructure.md`).

**CRITICAL: Each Feature must complete ALL steps (specify through verify and merge) before moving to the next Feature.** Do NOT skip implement or verify. Do NOT start the next Feature until the current Feature's merge step is complete.

Executes the following steps **strictly in order** for each Feature.

**Every "Review" below is a HARD STOP — you MUST use AskUserQuestion and WAIT for explicit user approval before continuing.**

```
0. pre-flight → Ensure on main branch (clean state)
1. specify    → Assemble → Checkpoint(STOP) → speckit-specify → Review(STOP) → Update
                (spec-kit creates Feature branch: {NNN}-{short-name})
   1b. clarify → Auto-scan spec.md for ambiguities → speckit-clarify (conditional sub-step of specify)
2. plan       → Assemble → Checkpoint(STOP) → speckit-plan → Review(STOP) → Update
3. tasks      → Checkpoint(STOP) → speckit-tasks → Review(STOP)
4. analyze    → Checkpoint(STOP) → speckit-analyze → Review(STOP) (CRITICAL issues block implement)
5. implement  → Env check(STOP if missing) → Checkpoint(STOP) → speckit-implement → Review(STOP)
6. verify     → Checkpoint(STOP) → Test/Build/Lint(BLOCK on fail) → Cross-Feature → Demo-Ready → Review(STOP) → Update
7. merge      → Verify-gate(BLOCK if not success/limited) → Checkpoint(STOP) → Merge Feature branch to main → Cleanup

── Feature DONE ── only now proceed to the next Feature ──
```

> **Reminder**: `(STOP)` means you MUST call AskUserQuestion, display the content, and WAIT for the user's response. Do NOT auto-approve. Do NOT skip.>
> **CRITICAL**: After each `speckit-*` command completes, it prints its own "Next phase:" or "Next step:" message. **IGNORE these messages completely — do NOT show them to the user.** smart-sdd controls the flow: after Execute, you MUST immediately proceed to the Review(STOP) step, not follow spec-kit's suggestions.

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

> **Git branching**: spec-kit automatically creates a Feature branch during `speckit-specify`. All subsequent steps (plan through verify) execute on that branch. After verify completes, smart-sdd handles the merge back to main. See [branch-management.md](../reference/branch-management.md) for details.

📝 **Case Study Recording**: Append milestone entry to `case-study-log.md` per [recording-protocol.md](../../case-study/reference/recording-protocol.md) § M6.

#### Next Step Guidance (after each Feature completion)

**If more Features remain in the pipeline**:

Display progress and ask whether the user wants to test before proceeding:
```
✅ [FID]-[name] completed and merged to main!

📊 Progress: [completed]/[total] Features done
→ Next: [next-FID]-[next-name]
  Steps: specify → plan → tasks → analyze → implement → verify → merge
```

**HARD STOP**: Use AskUserQuestion:
- "Proceed to next Feature" — continue pipeline immediately
- "Test first — I'll type 'continue' when ready" — pause pipeline for user testing

**If response is empty → re-ask** (per MANDATORY RULE 1).

If "Proceed": immediately start the next Feature's pre-flight (Step 0).
If "Test first": display the pause message and wait:
```
⏸️ Pipeline paused for testing. Take your time!
To resume: /smart-sdd pipeline (or type "continue")

→ Next: [next-FID]-[next-name]
  Steps: specify → plan → tasks → analyze → implement → verify → merge
```

> **Fallback**: If you cannot immediately proceed to the next Feature (e.g., context limit reached), display the pause message above.

**If all Features are completed**:

📝 **Case Study Recording**: Append milestone entry to `case-study-log.md` per [recording-protocol.md](../../case-study/reference/recording-protocol.md) § M8.

```
🎉 All Features completed!

📊 Final Status: [total]/[total] Features done
  Constitution: ✅ v[version]

All Features have been implemented, verified, and merged to main.

Next steps:
  /smart-sdd status         — View final progress report
  /smart-sdd add            — Add new Features to the project
```

**If the pipeline is interrupted mid-Feature** (e.g., context limit, user pauses, error):

This is the ONLY case where "Next steps" with commands should be displayed:
```
⏸️ Pipeline paused at [FID]-[name] → [current-step]

To resume:
  /smart-sdd pipeline       — Resume from where you left off
  /smart-sdd [step] [FID]   — Resume a specific step (e.g., /smart-sdd implement F003)
  /smart-sdd status         — Check current state
```

> **Pipeline continuity rule**: The pipeline is a CONTINUOUS flow. The only reasons to stop are: (1) HARD STOP checkpoints requiring user approval, (2) BLOCK conditions (verify/merge gates), (3) All Features completed, or (4) Unrecoverable error. Between Features, between Phases — the pipeline keeps running. Never display "Next steps" with commands unless the pipeline is actually stopping.

---

## Step Mode

Executes a single command. Validates prerequisites, then runs the common protocol (Assemble → Checkpoint → Execute+Review → Update).

### Prerequisite Validation

| Command | Prerequisite | Validation Method |
|---------|-------------|-------------------|
| `constitution` | constitution-seed exists | Check existence of `BASE_PATH/constitution-seed.md` |
| `specify` | pre-context exists, on main branch | Check existence of `BASE_PATH/features/[FID]-[name]/pre-context.md`. Verify current branch is `main` (spec-kit will create the Feature branch) |
| `plan` | spec.md exists, on Feature branch | Check existence of `specs/[NNN-feature-name]/spec.md`. Verify current branch matches the Feature |
| `tasks` | plan.md exists, on Feature branch | Check existence of `specs/[NNN-feature-name]/plan.md`. Verify current branch matches the Feature |
| `analyze` | tasks.md exists, on Feature branch | Check existence of `specs/[NNN-feature-name]/tasks.md`. Verify current branch matches the Feature |
| `implement` | analyze completed (no CRITICAL issues), on Feature branch | Confirm analyze completion in `sdd-state.md`. Check no CRITICAL issues remain. Verify current branch matches the Feature |
| `verify` | implement completed, on Feature branch | Confirm implement completion in `sdd-state.md`. Verify current branch matches the Feature |

If prerequisites are not met, displays an error message and guides the user to the required preceding step.

**Deferred Feature check** (core scope only — full scope has no deferred Features): Before checking other prerequisites, verify the Feature's status in `sdd-state.md`. If the Feature is `deferred` (outside current Active Tiers), display:
```
❌ [FID]-[name] is deferred (Tier [N], outside current scope: [Active Tiers]).
Run /smart-sdd expand [Tier] first to activate Tier [N] Features.
```
Do NOT proceed with the step.

**Branch validation**: For `plan` through `verify`, the current git branch must be the Feature branch (pattern: `{NNN}-*`). If not on the correct branch, display the expected branch name and guide the user. For `specify`, the current branch should be `main` — if already on a Feature branch, warn the user.

### Feature ID → spec-kit Feature Name Mapping

> Full naming convention and conversion rules: see `reference/state-schema.md` § Feature Mapping.

**Quick reference**: `F001-auth` (smart-sdd) ↔ `001-auth` (spec-kit/git branch). Strip/prepend `F` prefix. The `short-name` MUST match between both systems.

---

## Constitution Incremental Update

When new architectural principles or conventions are discovered during Feature progression:

1. **Checkpoint indication**: "Proposing a Constitution update: [principle content]"
2. **User approval**: Uses AskUserQuestion to confirm approval. **If response is empty → re-ask** (per MANDATORY RULE 1)
3. **Execute update**: If approved, performs a MINOR version update via `speckit-constitution`
4. **Impact analysis**: Displays a warning if already completed Features are affected

---

## Analyze Command

Running `/smart-sdd analyze [FID]` executes `speckit-analyze` to verify cross-artifact consistency **before implementation**.

**When**: After `tasks` step completes, before `implement` step.

**What it does**: `speckit-analyze` is a READ-ONLY analysis that checks consistency across spec.md, plan.md, and tasks.md. It identifies gaps, duplications, ambiguities, and inconsistencies.

**Workflow**:
1. Execute `speckit-analyze` via the Common Protocol (Assemble → Checkpoint → Execute+Review → Update)
2. Review the analysis report:
   - If **CRITICAL** issues exist (including FR with zero mapped tasks): Block implementation. The user must resolve them first (re-run specify, plan, or tasks as needed)
   - If **HIGH** issues exist (including FR with partial task coverage): Strongly recommend addressing, but user may override and proceed
   - If only **MEDIUM/LOW** issues: Display findings, user may proceed or address them
3. Record analysis results in `sdd-state.md`

**Prerequisite**: `tasks.md` must exist for the Feature (`speckit-analyze` requires all three artifacts: spec.md, plan.md, tasks.md)

> **Note**: `speckit-analyze` checks intra-Feature artifact consistency (spec ↔ plan ↔ tasks). Cross-Feature entity/API consistency is checked separately during `verify` (after implementation).

---

## See Also

- **Verify phases**: `commands/verify-phases.md` — Phase 1-4 verification workflow (loaded only for verify command)
- **Git branch management**: `reference/branch-management.md` — Branch lifecycle, merge workflow, pre-flight checks
