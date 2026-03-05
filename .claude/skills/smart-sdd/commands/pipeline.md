# Pipeline Execution — Common Protocol + Feature Pipeline

> Reference: Read after `/smart-sdd pipeline` or any step-mode command (constitution, specify, plan, tasks, analyze, implement, verify) is invoked. For shared rules (MANDATORY RULES, --auto), see SKILL.md.
> For per-command context injection details, read `reference/injection/{command}.md` (shared patterns in `reference/context-injection-rules.md`).
> For git branch operations, also read `reference/branch-management.md`.

## Common Protocol: Assemble → Checkpoint → Execute+Review → Update

**All spec-kit command executions follow this 4-step protocol. Each step MUST be executed in order. No step may be skipped (unless `--auto` mode is active). In particular, Execute (Step 3) includes a mandatory Review HARD STOP — the spec-kit command runs, then the Review is presented, all in one continuous action.**

> ⚠️ **The most common failure mode is skipping Review.** After executing a spec-kit command (Step 3), you MUST stop, display the generated artifacts, and ask the user for approval. Do NOT proceed to Update without Review. Do NOT combine Execute and Update into a single flow.
>
> **`--auto` mode summary**: When `--auto` is specified, BOTH Checkpoint (Step 2) and Review (Step 3b-c) are skipped — their content is still displayed for transparency, but execution proceeds immediately without waiting for user approval. This is the ONLY way to bypass these stops. Without `--auto`, every Checkpoint and Review is a mandatory HARD STOP.

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
PROCEDURE CheckpointApproval:
  LOOP:
    response = AskUserQuestion(
      options: ["Approve as-is", "Request modifications"]
    )

    IF response is empty, blank, or has no meaningful selection:
      Display "⚠️ No approval received. Please review the context above and select one option."
      CONTINUE LOOP  ← ask again, do NOT proceed

    IF response == "Approve as-is" OR user typed "yes"/"approved"/"lgtm":
      BREAK LOOP → proceed to Step 3 (Execute+Review)

    IF response == "Request modifications":
      Ask user what to change
      Apply modifications to the context
      Re-display the updated context summary
      CONTINUE LOOP  ← ask for approval again

    OTHERWISE (unrecognized response):
      Display "Please select: Approve as-is / Request modifications"
      CONTINUE LOOP
```

**⚠️ CRITICAL**: After AskUserQuestion returns, you MUST check the response BEFORE doing anything else. If the response is empty — you have NOT received approval. Call AskUserQuestion AGAIN. Do NOT proceed to Execute.

**Mode overrides**:
- `--auto`: Skip the LOOP entirely. Content is still displayed for transparency but execution proceeds immediately.
- `--dangerously-skip-permissions`: Replace AskUserQuestion with a text message ("Approve as-is / Request modifications?") and WAIT for text response. Checkpoints are NOT auto-skipped — only `--auto` does that.

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

You MUST follow this exact procedure. No exceptions.

```
PROCEDURE ReviewApproval:
  LOOP:
    response = AskUserQuestion(
      options: ["Approve", "Request modifications", "I've finished editing"]
    )

    IF response is empty, blank, or has no meaningful selection:
      Display "⚠️ No approval received. Please review the artifact above and select one option."
      CONTINUE LOOP  ← ask again, do NOT proceed

    IF response == "Approve" OR user typed "yes"/"approved"/"looks good"/"lgtm":
      BREAK LOOP → proceed to Step 4 (Update)

    IF response == "Request modifications":
      Ask user what to change
      Re-execute spec-kit command with feedback
      Go back to Step 3b (re-display Review with updated content)
      CONTINUE LOOP

    IF response == "I've finished editing":
      Re-read the artifact file(s) to pick up user's changes
      Display a brief summary of what changed
      response2 = AskUserQuestion(options: ["Approve changes", "Edit more"])
      IF response2 == "Approve changes": BREAK LOOP → proceed to Step 4
      IF response2 == "Edit more": CONTINUE LOOP

    OTHERWISE (unrecognized response):
      Display "Please select: Approve / Request modifications / I've finished editing"
      CONTINUE LOOP
```

**⚠️ CRITICAL**: After AskUserQuestion returns, you MUST check the response BEFORE doing anything else. If the response is empty — you have NOT received approval. Call AskUserQuestion AGAIN. Do NOT proceed to Update.

**Mode overrides**:
- `--auto`: Skip the LOOP entirely (Step 3b content is still displayed for transparency).
- `--dangerously-skip-permissions`: Replace AskUserQuestion with a text message ("Approve / Request modifications / I've finished editing?") and WAIT for text response.

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

📝 **Case Study Recording**: Append milestone entry to `case-study-log.md` per [recording-protocol.md](../../../case-study/reference/recording-protocol.md) § M5.

**After recording, IMMEDIATELY proceed to Phase 1 below. Do NOT stop. Do NOT wait for user input. Do NOT suggest running a separate command. The pipeline is a continuous flow — constitution finalization is just the first step.**

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
2. clarify    → Auto-scan spec.md for ambiguities → speckit-clarify (if needed)
3. plan       → Assemble → Checkpoint(STOP) → speckit-plan → Review(STOP) → Update
4. tasks      → Checkpoint(STOP) → speckit-tasks → Review(STOP)
5. analyze    → Checkpoint(STOP) → speckit-analyze → Review(STOP) (CRITICAL issues block implement)
6. implement  → Env check(STOP if missing) → Checkpoint(STOP) → speckit-implement → Review(STOP)
7. verify     → Checkpoint(STOP) → Test/Build/Lint(BLOCK on fail) → Cross-Feature → Demo-Ready → Review(STOP) → Update
8. merge      → Verify-gate(BLOCK if not success/limited) → Checkpoint(STOP) → Merge Feature branch to main → Cleanup

── Feature DONE ── only now proceed to the next Feature ──
```

> **Reminder**: `(STOP)` means you MUST call AskUserQuestion, display the content, and WAIT for the user's response. Do NOT auto-approve. Do NOT skip. The only exception is `--auto` mode.
>
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

**`--auto` mode**: Clarify scan still runs. If ambiguities are found, `speckit-clarify` executes but uses its own recommendation/suggestion as the default answer for each question (clarify's built-in "recommended" option). The user can still intervene if watching.

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

> **Git branching**: spec-kit automatically creates a Feature branch during `speckit-specify`. All subsequent steps (plan through verify) execute on that branch. After verify completes, smart-sdd handles the merge back to main. See [Git Branch Management](#git-branch-management) for details.

📝 **Case Study Recording**: Append milestone entry to `case-study-log.md` per [recording-protocol.md](../../../case-study/reference/recording-protocol.md) § M6.

#### Next Step Guidance (after each Feature completion)

**If more Features remain in the pipeline**:

Display progress and **IMMEDIATELY proceed to the next Feature** — do NOT stop, do NOT wait for user input, do NOT suggest running a separate command. The pipeline is a continuous flow:
```
✅ [FID]-[name] completed!

📊 Progress: [completed]/[total] Features done
  Proceeding to: [next-FID]-[next-name]
```
Then immediately start the next Feature's pre-flight (Step 0).

**If all Features are completed**:

📝 **Case Study Recording**: Append milestone entry to `case-study-log.md` per [recording-protocol.md](../../../case-study/reference/recording-protocol.md) § M8.

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

spec-kit uses the naming format `{NNN}-{short-name}` (e.g., `001-auth`), while smart-sdd uses `F{NNN}-{short-name}` (e.g., `F001-auth`). The **short-name** portion MUST be identical across both systems.

**Naming Convention (MANDATORY)**:

| System | Format | Example | Notes |
|--------|--------|---------|-------|
| smart-sdd Feature ID | `F{NNN}-{short-name}` | `F001-auth` | Used in roadmap.md, pre-context folders, sdd-state.md |
| spec-kit Feature directory | `{NNN}-{short-name}` | `001-auth` | Under `specs/`. Created by `create-new-feature.sh` |
| git branch | `{NNN}-{short-name}` | `001-auth` | Created by spec-kit during `speckit-specify` |
| pre-context folder | `F{NNN}-{short-name}/` | `F001-auth/` | Under `specs/reverse-spec/features/` |

**Conversion rules**:
- `F001-auth` → spec-kit name: strip `F` prefix → `001-auth`
- `001-auth` → smart-sdd ID: prepend `F` → `F001-auth`

**When creating a Feature in spec-kit** (during `specify` step):
1. Extract the `short-name` from the smart-sdd Feature ID (e.g., `F001-auth` → `auth`)
2. Extract the numeric part (e.g., `F001` → `1`)
3. Pass to spec-kit: `create-new-feature.sh --number {N} --short-name "{short-name}"`
4. This produces the spec-kit directory `{NNN}-{short-name}` (e.g., `001-auth`)
5. Record the mapping in `sdd-state.md` → Feature Mapping table

**IMPORTANT**: The `short-name` MUST match between smart-sdd and spec-kit. If the user defined Feature name as `F001-platform` in the init/reverse-spec phase, the spec-kit Feature must be `001-platform` (NOT `001-app-shell` or any other name). This ensures consistent naming across all artifacts.

---

## Constitution Incremental Update

When new architectural principles or conventions are discovered during Feature progression:

1. **Checkpoint indication**: "Proposing a Constitution update: [principle content]"
2. **User approval**: Uses AskUserQuestion to confirm approval
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
   - If **CRITICAL** issues exist: Block implementation. The user must resolve them first (re-run specify, plan, or tasks as needed)
   - If only **HIGH/MEDIUM/LOW** issues: Display findings, user may proceed or address them
3. Record analysis results in `sdd-state.md`

**Prerequisite**: `tasks.md` must exist for the Feature (`speckit-analyze` requires all three artifacts: spec.md, plan.md, tasks.md)

> **Note**: `speckit-analyze` checks intra-Feature artifact consistency (spec ↔ plan ↔ tasks). Cross-Feature entity/API consistency is checked separately during `verify` (after implementation).

---

## Verify Command

Running `/smart-sdd verify [FID]` performs post-implementation verification. This step runs **after implement** to validate that the actual code works correctly and is consistent with the broader project.

### Phase 1: Execution Verification (BLOCKING)

Run each check and record results. **If any check fails, verification is BLOCKED — do not proceed to Phase 2/3/4.**

1. **Test check**: Detect and execute the project's test command (from `package.json` scripts, `pyproject.toml`, `Makefile`, etc.)
2. **Build check**: Run the build command and confirm no errors
3. **Lint check**: Run the lint tool if configured

**If ANY check fails**, display and STOP:
```
❌ Execution Verification failed for [FID] - [Feature Name]:
  Tests: [PASS/FAIL — pass count/total, failure details]
  Build: [PASS/FAIL — error summary]
  Lint:  [PASS/FAIL — critical issue count]

Fix the failing checks before verification can continue.
Verification is BLOCKED — merge will not be allowed until all checks pass.
```

**Use AskUserQuestion** with options:
- "Fix and re-verify" — user will fix, then re-run `/smart-sdd verify`
- "Show failure details" — display full test/build/lint output
- "Acknowledge limited verification" — proceed with ⚠️ limited-verify (requires reason)

**Do NOT proceed to Phase 2** until all three checks pass **OR** the user explicitly acknowledges limited verification.

**Limited-verify exception path**: If the user selects "Acknowledge limited verification":
1. Ask for the reason (e.g., "Tests require external service not available", "Build depends on Feature B not yet merged", "DB migration requires completed Feature C")
2. Record in `sdd-state.md` Feature Detail Log → verify row Notes: `⚠️ LIMITED — [reason]`
3. Set the verify step icon to `⚠️` (not ✅) in Feature Progress
4. Proceed to Phase 2 — but the merge step will display a reminder that this Feature has limited verification
5. **This is NOT a skip** — the limitation is tracked and visible in status reports

> **Build prerequisites**: If the build fails due to missing setup steps (e.g., `pnpm approve-builds`, native module compilation), include the specific prerequisite command in the error message so the user knows what to run.

### Phase 2: Cross-Feature Consistency + Behavior Completeness Verification

**Step 1 — Cross-Feature consistency**:
- Check the cross-verification points in the "For /speckit.analyze" section of `pre-context.md`
- Analyze whether shared entities/APIs changed by this Feature affect other Features
- Verify that entity-registry.md and api-registry.md match the actual implementation

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
6. If no Source Behavior Inventory exists (greenfield/add), skip this step

### Phase 3: Demo-Ready Verification (BLOCKING — only if VI. Demo-Ready Delivery is in the constitution)

> **If VI. Demo-Ready Delivery is NOT in the constitution**: Skip this phase entirely.

**Step 1 — Check demo script exists AND is a real demo (NOT markdown, NOT test-only)**:
- Verify `demos/F00N-name.sh` (or `.ts`/`.py`/etc. matching the project's language) exists
- **REJECT if**: the file is `.md`, contains `## Demo Steps`, or consists of prose instructions instead of executable commands
- **REJECT if**: the file lacks a shebang line (`#!/usr/bin/env bash` or equivalent) for `.sh` files
- **REJECT if**: the script only runs test assertions and exits (that's a test suite, not a demo) — a demo must launch the real Feature for the user to experience
- If a markdown demo file or test-only script was generated instead, **delete it** and create a proper demo script

**Step 2 — Check the demo launches the real Feature**:
- The demo script's default behavior must **start the Feature** and keep it running for the user to interact with
- The script must print concrete "Try it" instructions: real URLs to open, real curl commands to run, real CLI invocations to try (at least 2)
- The `--ci` flag must be supported for automated verification: runs setup + health check, then exits cleanly
- **REJECT if**: the script has no interactive experience (i.e., only runs assertions and exits with no live Feature)

**Step 3 — Check coverage mapping and demo components**:
- The demo script must include a **Coverage** header comment mapping FR-###/SC-### from spec.md to what the user can try/see in the demo
  - Each FR/SC should be either ✅ (demonstrated) or ⬜ (not demoed with reason)
  - **Aim for maximum coverage** — every functional requirement should be experienceable in the demo unless genuinely impossible
  - If coverage is below 50% of the Feature's FR count, **WARN** the user and suggest expanding the demo
- The demo script must include a **Demo Components** header comment listing each component as Demo-only or Promotable
- Demo-only components are marked with `// @demo-only` (removed after all Features complete)
- Promotable components are marked with `// @demo-scaffold — will be extended by F00N-[feature]`

**Step 4 — Execute the demo in CI mode (`--ci`)**:
- Run `demos/F00N-name.sh --ci` and verify it completes without errors (health check passes)
- Capture the demo output (stdout/stderr) for the Review display

**If any check fails**, display and BLOCK:
```
❌ Demo-Ready verification failed for [FID] - [Feature Name]:
  - [Missing: demos/F00N-name.sh | --ci health check failed: <error> | Demo is test-only (no live Feature) | Missing: Demo Components header | Missing: component markers]

"Tests pass" alone does not satisfy Demo-Ready Delivery.
A demo must launch the real, working Feature so the user can experience it.
Please create a demo script at demos/F00N-name.sh that:
  - Starts the Feature and prints "Try it" instructions (default)
  - Supports --ci for automated health check (verify phase)
  - Includes Demo Components with appropriate category markers
```

**Use AskUserQuestion** with options:
- "Fix and re-verify" — user will fix, then re-run `/smart-sdd verify`
- "Show failure details" — display full demo script output
- "Acknowledge limited verification" — proceed with ⚠️ limited-verify (requires reason)

**Do NOT proceed to Phase 4** until the demo passes **OR** the user explicitly acknowledges limited verification.

**Limited-verify exception path** (same as Phase 1): If the user selects "Acknowledge limited verification":
1. Ask for the reason (e.g., "Demo requires Feature B's UI not yet built", "No frontend in this Feature — pure library")
2. Append to `sdd-state.md` Feature Detail Log → verify Notes: `⚠️ DEMO-LIMITED — [reason]`
3. If Phase 1 already passed normally, set verify icon to `⚠️` (limited) instead of ✅
4. Proceed to Phase 4

- Update `demos/README.md` (Demo Hub) with the Feature's demo and what the user can experience:
  - `./demos/F00N-name.sh` — launches [brief description of the live demo experience]

### Phase 4: Global Evolution Update
- entity-registry.md: Verify that the actually implemented entity schemas match the registry; update if discrepancies are found
- api-registry.md: Verify that the actually implemented API contracts match the registry; update if discrepancies are found
- sdd-state.md: Record verification results — **status MUST be one of `success`, `limited`, or `failure`**, plus test pass/fail counts, build result, and verification timestamp. The merge step checks this status as a gate condition.
  - `success`: All phases passed normally
  - `limited`: User acknowledged limited verification in Phase 1 or Phase 3 (⚠️ marker). Merge is allowed with a reminder
  - `failure`: One or more phases failed without acknowledgment. Merge is blocked

---

## Git Branch Management

smart-sdd integrates with spec-kit's Feature branch workflow to ensure each Feature is developed in isolation and merged to main only after successful verification.

### Branch Lifecycle

```
main ─── (start) ──→ speckit-specify creates branch {NNN}-{short-name}
                          │
                          ├── plan, tasks, implement, verify (all on Feature branch)
                          │
                          ├── Post-Feature updates (entity-registry, api-registry, etc.)
                          │
                          ├── Merge Checkpoint (HARD STOP — user approval)
                          │
main ←── (merge) ────────┘
```

### Pre-Flight: Before Starting a Feature

Before executing `specify` for a new Feature:

1. **Verify current branch is `main`**: Run `git branch --show-current`
   - If not on main: Display warning and ask user whether to switch to main first
   - If there are uncommitted changes: Warn the user and ask how to proceed (stash, commit, or abort)
2. **Ensure main is up to date**: Run `git status` to check for uncommitted changes
   - If the project has a remote: Suggest `git pull` but do not force it

### During Feature Development (specify → verify)

spec-kit handles the branch creation automatically during `speckit-specify`:
- Creates branch `{NNN}-{short-name}` and switches to it
- All subsequent commands (`plan`, `tasks`, `implement`, `verify`) execute on this Feature branch
- smart-sdd validates the current branch matches the expected Feature branch before each step

**Branch validation** (for `plan`, `tasks`, `implement`, `verify`):
1. Run `git branch --show-current` to get the current branch name
2. Extract the numeric prefix (e.g., `001` from `001-auth`)
3. Match against the Feature's spec-kit Name prefix in `sdd-state.md`'s Feature Mapping
4. If mismatch: Display the expected branch and current branch, ask user to switch

### Post-Feature Merge: After verify Completes

After verify completes and Global Evolution Layer updates are applied:

**Step 0 — Verify-Success Gate (BLOCKING)**:
Before ANY merge activity, check the Feature's verification status in `sdd-state.md`:
- If the Feature's last verification result is **not `success` and not `limited`** (or if no verification was recorded): **BLOCK the merge**.
  ```
  ❌ Cannot merge [FID] - [Feature Name]: Verification has not passed.
  Last verify result: [failure/not recorded]

  Run `/smart-sdd verify [FID]` and ensure all checks pass before merging.
  ```
- If verify status is `limited` (⚠️): Allow merge but display a reminder:
  ```
  ⚠️ [FID] - [Feature Name] has limited verification:
    [reason from verify Notes]
  Proceeding with merge — re-verify when the limitation is resolved.
  ```
- Only proceed to Step 1 if verify status is `success` or `limited`.

**Step 1 — Commit Global Evolution updates on the Feature branch**:
All Post-Feature Completion updates (entity-registry.md, api-registry.md, roadmap.md, pre-context.md updates, sdd-state.md) are committed on the Feature branch before merging.

**Step 2 — Merge Checkpoint (HARD STOP)**:
Present the merge summary to the user via AskUserQuestion:

```
🔀 Feature merge: [FID] - [Feature Name]

Branch: {NNN}-{short-name} → main

── Changes Summary ─────────────────────────────
  Commits: [N commits on this branch]
  Files changed: [count]
  Tests: [pass count]/[total] passed
  Build: [success/failure]

── Global Evolution Updates ────────────────────
  entity-registry.md: [changes summary]
  api-registry.md: [changes summary]
  roadmap.md: [Feature] → completed
  sdd-state.md: updated

─────────────────────────────────────────────────
```

Options:
- "Merge to main" — Proceed with merge
- "Review changes first" — Show detailed diff before merging
- "Skip merge (stay on branch)" — Keep the branch for manual merge later

**If response is empty → re-ask** (per MANDATORY RULE 1). Do NOT auto-merge.

**Step 3 — Execute merge** (only after user approval):
1. Switch to main: `git checkout main`
2. Merge the Feature branch: `git merge {NNN}-{short-name}`
   - Use the default merge strategy (no squash, no rebase — preserving commit history)
   - If merge conflicts occur: Report the conflicts to the user and **stop**. Do NOT attempt to resolve merge conflicts automatically.
3. Verify the merge was clean: `git status`
4. Record the merge in `sdd-state.md` Feature Detail Log

**Step 4 — Post-merge cleanup**:
- Do NOT delete the Feature branch automatically
- Display: "Feature branch `{NNN}-{short-name}` has been merged to main. You may delete it with `git branch -d {NNN}-{short-name}` if no longer needed."

### Step Mode Branch Handling

When using Step Mode (e.g., `/smart-sdd verify F001`):
- Each command validates the current branch as described in Prerequisite Validation
- After `verify` in Step Mode, the merge step is **not** automatically triggered. The user must explicitly run the pipeline or manually merge.
- To trigger the merge for a completed Feature in Step Mode, the user can run `/smart-sdd pipeline` which will detect the completed-but-unmerged Feature and proceed with the merge Checkpoint.

### Non-Git Projects

If the project directory is not a git repository:
- Skip all branch management (pre-flight, validation, merge)
- Display a one-time notice: "No git repository detected. Branch management is disabled."
- All other smart-sdd functionality works normally
