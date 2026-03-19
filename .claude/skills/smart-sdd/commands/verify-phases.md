# Verify Command — Phase Details

> Read after `/smart-sdd verify [FID]` is invoked. For Common Protocol (Checkpoint, Review), see `pipeline.md`.
> For per-command injection rules, see `reference/injection/verify.md`.
>
> **Adoption mode**: If `sdd-state.md` Origin is `adoption`, read `reference/injection/adopt-verify.md` instead of `reference/injection/verify.md`. Key differences: Phase 1 failures are **non-blocking** (pre-existing issues), Phase 3 is **skipped** (adoption has no per-Feature demos), and Feature status is `adopted` (not `completed`).

---

## Verify Command

Running `/smart-sdd verify [FID]` performs post-implementation verification. This step runs **after implement** to validate that the actual code works correctly and is consistent with the broader project.

### Bug Fix Severity Rule — verify is for FINDING, not REWRITING

When verify discovers a bug (or the user provides feedback during Review), classify its severity and **route to the correct pipeline stage**:

| Severity | Examples | Action |
|---|---|---|
| **Minor** | Missing import, typo, null check, off-by-one, missing CSS class, simple config fix | ✅ Fix inline during verify — commit as `fix:` |
| **Major-Implement** | Frozen object pattern change, missing component, state flow restructuring, new module needed | ❌ Return to **implement** — re-run affected tasks with issue context |
| **Major-Plan** | Wrong architecture pattern, missing data model field, API contract mismatch, component structure redesign needed | ❌ Return to **plan** — re-run speckit-plan with updated constraints |
| **Major-Spec** | Missing functional requirement, wrong success criteria, scope gap, requirement misinterpretation | ❌ Return to **specify** — re-run speckit-specify with corrected requirements |

**How to classify** — 2-step process:

**Step A: Spec Coverage Pre-check (MANDATORY — do this FIRST)**

Before classifying by file count, ask: **"Does spec.md have an SC that defines the expected behavior for this issue?"**

- Read spec.md → search for SCs covering the specific behavior that failed
- If **SC exists AND implementation doesn't match it** → proceed to Step B (file count classification)
- If **NO SC covers this behavior** → **Major-Spec** (regardless of file count)

```
❌ WRONG: "citation tooltip doesn't work" → 3+ files → Major-Implement
   → implement로 돌아가도 spec에 tooltip SC가 없으므로 에이전트가 즉흥으로 구현 → 같은 루프 반복

✅ RIGHT: "citation tooltip doesn't work" → spec.md에 tooltip SC 없음 → Major-Spec
   → specify로 돌아가서 SC 추가: "hover 시 제목+파비콘+내용 미리보기, 클릭 시 소스 URL 열기"
   → 이후 plan → tasks → implement → verify가 명확한 기준으로 진행
```

**Rationale**: SDD의 핵심 원칙은 "spec이 완료 기준을 정의한다"입니다. SC가 없는 동작을 implement에서 고치라고 보내는 것은 spec-driven이 아니라 ad-hoc fix입니다. implement는 반드시 spec의 SC를 구현하는 것이어야 합니다.

**Step B: File count classification (SC가 존재할 때만)**

- **Minor**: Fix touches ≤2 files, no API/interface change, no architectural reasoning needed
- **Major-Implement**: Fix touches 3+ files OR needs a new component, but spec and plan are correct (SC exists, implementation just doesn't match)
- **Major-Plan**: The plan's architecture, data model, or contracts need revision (spec is correct, but the plan made wrong choices)
- **Major-Spec**: The requirements themselves are wrong or incomplete (everything downstream — plan, tasks, implement — is built on wrong assumptions)

**When any Major issue is found**:
1. Record the issue in the verify result report with full details and the recommended regression target
2. Display: `🔴 [Severity] issue detected — requires pipeline regression to [target stage]`
3. Set verify status to `failure` with the issue description and regression target
4. **HARD STOP** — Use AskUserQuestion:
   - "Return to [target stage] with issue context" — pipeline regression with preserved context
   - "Reclassify severity and fix now" — user overrides severity classification
   **If response is empty → re-ask** (per MANDATORY RULE 1)

**Pipeline regression handling** (when user confirms "Return to [stage]"):
1. Record regression reason in `sdd-state.md` Feature Detail Log: `↩️ REGRESSION to [stage] — [reason]`
2. Set Feature status to `regression-[stage]` (e.g., `regression-specify`, `regression-plan`)
3. Preserve current verify results as context — the re-run starts with knowledge of what went wrong
4. Display: `↩️ Returning to [stage] for [FID]. Verify results preserved as regression context.`
5. Resume pipeline from the selected stage — all subsequent steps (specify → plan → tasks → implement → verify) re-execute

**Regression depth limit**:
Track regression count per Feature in the Feature Detail Log. Each `↩️ REGRESSION` entry increments the counter.
- After **2 regressions** for the same Feature (regardless of severity target): HARD STOP
  **Use AskUserQuestion**: "Feature [FID] has regressed 2 times. How to proceed?"
  - "Continue with 3rd regression" — allow one more attempt
  - "Abort Feature — mark as blocked" — set status to `blocked`, move to next Feature
  - "Manual review — pause pipeline" — pause for user investigation
  **If response is empty → re-ask** (per MANDATORY RULE 1)
- After **3 regressions**: Force block. Set status to `blocked`, display: `🚫 Feature [FID] blocked after 3 regressions. Manual intervention required.`
- Regression counter is tracked per-Feature, not per-session (persisted in sdd-state.md Feature Detail Log by counting `↩️ REGRESSION` entries)

**Rationale**: verify-phase fixes bypass spec/plan/tasks and have no checkpoint/review. Quick-patching a Major issue leads to suboptimal architecture — the kind of code that works but accumulates tech debt. Additionally, user feedback during verify Review often identifies issues that are not bugs but rather spec-level or plan-level problems. Without structured regression routing, these fixes happen ad-hoc, outside the pipeline's quality gates.

### Verify-time Change Recording — All Source Modifications

The Bug Fix Severity Rule above handles **bugs** (wrong behavior). But verify may also discover **implementation gaps** — missing behavior that falls within the scope of an existing FR-### or task but was not completed during implement. Unlike a bug, an implementation gap is *absent* behavior, not *wrong* behavior (e.g., missing i18n keys, unimplemented edge case within a documented SC, missing config entry referenced in tasks).

**Classification of ALL source modifications during verify**:

| Change Type | Scope Test | Action |
|-------------|-----------|--------|
| Bug Fix (Minor) | Wrong behavior, ≤2 files, no API change | Fix inline (per Bug Fix Severity Rule) |
| Implementation Gap | Missing behavior within existing FR/task scope, ≤2 files, no API change | Fix inline + record as gap fill |
| Design Change | New behavior beyond FR/task scope, OR 3+ files, OR API/contract change | Pipeline regression (per Bug Fix Severity Rule Major-*) |

**Decision flow** (when modifying source during verify):
1. Is this fixing **wrong** behavior? → Bug Fix → Apply Bug Fix Severity Rule
2. Is this adding **missing** behavior within an existing FR/task?
   - ≤2 files, no API/interface change → **Implementation Gap** — fix inline + record
   - 3+ files OR API change → **Major-Implement** regression
3. Is this adding behavior **beyond** existing FR/task scope? → **Design Change** → Major-* regression

**Recording requirement** (in sdd-state.md Notes after verify completes):
All inline changes (Minor bug fixes + Implementation gap fills) must be summarized in the Notes column. This recording ensures:
- **Transparency**: user sees what was changed during verify beyond the planned verification
- **Audit trail**: if a "gap fill" was actually a scope expansion, the record enables review
- **Pattern detection**: repeated gap fills in the same area suggest implement phase quality issues

Format: `Inline changes: [N] bug fix, [N] gap fill ([brief descriptions])`

### Source Modification Gate (MANDATORY — enforced before ANY source file change)

> **Why this gate exists**: The Bug Fix Severity Rule and Verify-time Change Classification above are reference rules. In practice, agents skip them due to "fix it now" bias — they discover an issue and immediately modify code without first evaluating severity. This gate is the enforcement mechanism that BLOCKS source modification until classification is completed and displayed.

**RULE: Before editing ANY source file (`.ts`, `.tsx`, `.vue`, `.py`, `.go`, `.rs`, `.java`, `.jsx`, `.svelte`, etc.) during verify, the agent MUST execute this gate. No exceptions.**

**Gate procedure**:

1. **STOP** — do NOT open any source file for editing yet.

2. **List ALL planned changes** in a visible table:
   ```
   🔍 Source Modification Gate — Pre-Fix Classification:
   | # | File | What changes | Why |
   |---|------|-------------|-----|
   Example:
   | 1 | tools/index.ts | KB picker popover structure | SC-007a: picker doesn't open |
   | 2 | types/knowledge.ts | Add KnowledgeReference.name field | CitationBlock needs name for display |
   | 3 | KnowledgeService.ts | getKnowledgeReferences() return shape | Include name in returned data |
   | 4 | CitationBlock.tsx | Render name from reference | Display citation source name |
   ```

3. **Apply classification per change** (using Decision Flow above):
   - Each row: Bug Fix / Implementation Gap / Design Change
   - Each row: file count contribution

4. **AGGREGATE file count check**: Count TOTAL unique files across ALL planned changes.
   - Total ≤ 2 files, no API/interface change, no state restructure → **Minor/Gap — proceed inline**
   - Total ≥ 3 files → **Major-Implement** (regardless of individual change sizes)
   - ANY change involves API/contract change → **Major-Plan**
   - ANY change involves state flow restructure or new module → **Major-Implement**
   - ANY change adds behavior beyond existing FR/task scope → **Major-* regression**

   > **Critical**: Do NOT evaluate each change in isolation. Evaluate the AGGREGATE. Four "small" changes across 4 files = Major-Implement, not four Minor fixes.

5. **Display classification result**:
   ```
   ⚙️ Classification: [Minor — proceed inline] OR [🔴 Major-Implement — pipeline regression required]
     Total files: [N]
     API/interface change: [yes/no]
     State restructure: [yes/no]
   ```

6. **HARD STOP — User Approval Gate** (MANDATORY for ALL classifications, including Minor):

   > **Why Minor also requires approval**: A known failure pattern involves repeated Minor fixes accumulating into de facto Major rewrites without user awareness. By making ALL classifications visible and requiring approval, the user can detect when "Minor" fixes are actually a deeper problem before any files are touched.

   Display the classification table from step 2 with the aggregate result from step 5, then:

   **If Minor/Gap classification** — **Use AskUserQuestion**:
   ```
   🔍 Source Modification Gate — Approval Required:
   [Classification table from step 2]

   ⚙️ Aggregate: [Minor/Gap] — [N] files, no API change
   ```
   - "Approve — proceed with inline fix"
   - "Reclassify as Major — pipeline regression"
   - "Skip — do not modify source files"
   **If response is empty → re-ask** (per MANDATORY RULE 1)

   **If Major classification** → Proceed directly to step 8 (Major HARD STOP) for pipeline regression routing.

7. **If user approves Minor/Gap** → Before writing code, execute **Source Reference for Verify Fixes** (rebuild mode only), then proceed with inline fixes. Record all changes in Notes. **Then execute Post-Fix Runtime Verification** (step 9 below).

   **Source Reference for Verify Fixes (rebuild mode — BLOCKING)**:
   > **Why this exists**: In rebuild mode, verify fixes often degrade into "improvise based on error messages" — the agent patches symptoms without understanding the source app's original implementation. This produces a fix → re-fix → re-re-fix loop that eventually requires "start from scratch." The source app already has a working implementation; read it first.

   Before modifying any file during verify in rebuild mode:
   1. Identify the corresponding source app file(s) from the Source→Target Component Mapping (in plan.md) or pre-context.md Source Reference
   2. **Read those source files** — not just reference them. Actually open and parse the source code.
   3. Display: `📂 Verify Source Ref: [source file] → [target file] — reading before fix`
   4. The fix MUST preserve the source app's patterns unless there's an explicit architectural reason to diverge (documented in plan.md)

   ```
   ❌ WRONG (rebuild verify fix):
     SC-008 citation tooltip not showing → add inline style → still broken
     → add z-index → still broken → refactor CSS → more broken
     → "처음부터 다시"

   ✅ RIGHT (rebuild verify fix):
     SC-008 citation tooltip not showing
     → Read source CitationTooltip.tsx → understand positioning logic
     → Read source citation.ts → understand data flow
     → Implement fix based on source pattern → verify → done
   ```

   **Skip if**: Source Path = `N/A` (greenfield) or fix is in a file with no source counterpart (new file not in Source→Target mapping).

8. **If Major** → **HARD STOP**. Do NOT modify any source files. Trigger the "When any Major issue is found" flow (lines 31-38):
   - Display `🔴 [Severity] issue detected — requires pipeline regression to [target stage]`
   - **Use AskUserQuestion**:
     - "Return to [target stage] with issue context"
     - "Reclassify severity and fix now" — user overrides
   - **If response is empty → re-ask** (per MANDATORY RULE 1)

9. **Post-Fix Runtime Verification** (MANDATORY after every inline fix):

   > "Build passes + tests pass ≠ fix is correct." An inline fix during verify MUST be runtime-verified, not just statically validated. This catches the pattern where code compiles but the fix doesn't actually resolve the runtime issue (e.g., service exists but isn't wired in, type is correct but data doesn't flow).

   After applying an inline fix (Minor bug fix or Gap fill):
   1. **Build check**: Run build → confirm no errors introduced
   2. **Test check**: Run tests → confirm no regressions
   3. **Runtime verification of the specific fix**:
      - Identify the SC(s) affected by the fix
      - Re-run the affected SC verification using the appropriate backend (Playwright MCP/CLI, HTTP client, process runner)
      - The fix is NOT complete until the affected SC passes at its Required Depth (from SC Verification Matrix)
      - If runtime verification fails after the fix → the fix is insufficient. Re-evaluate: is this actually Minor, or has the scope grown to Major?
   4. **Display result**:
      ```
      🔧 Post-Fix Verification:
        Build: ✅ | Tests: ✅ | Runtime SC-022: ✅ Tier 2 reached
        Fix confirmed — recording in Notes.
      ```
      OR:
      ```
      🔧 Post-Fix Verification:
        Build: ✅ | Tests: ✅ | Runtime SC-022: ❌ still failing
        ⚠️ Fix did not resolve runtime issue. Re-evaluating severity...
      ```
   5. If runtime re-verification fails AND investigation reveals more files need changes → **re-run the Source Modification Gate** with the expanded scope. The aggregate file count may now push the fix to Major.

10. **Minor Fix Accumulator** (cross-gate tracking):

   The Source Modification Gate evaluates each fix batch independently. But a pattern of repeated Minor fixes in the same area indicates a deeper structural issue that should be handled by implement, not verify.

   **Rule**: Track all inline fixes applied during this verify session. If **3 or more Minor fixes** (bug fix or gap fill) accumulate in the **same module/component** (same directory or same logical boundary), auto-escalate to **Major-Implement**:
   ```
   🔴 Minor Fix Accumulator triggered:
     Module: src/services/{module}/
     Fixes applied: 3 (Bug #1: path resolution, Bug #4: parser config, Bug #5: API format)
     → Auto-escalated to Major-Implement — this module needs redesign in implement, not patchwork in verify.
   ```
   After auto-escalation → trigger the Major HARD STOP flow (step 8 above).

   **Module boundary definition**: Files sharing the same parent directory OR the same service/component name (e.g., `UserService.ts`, `UserLoader.ts`, `UserStore.ts` = same `User` module even if in different directories).

   **SC Re-Fix Loop Detection**: If the same SC fails Post-Fix Runtime Verification (step 9) **2 times** after 2 different fix attempts, auto-escalate to **Major-Implement**:
   ```
   🔴 SC Re-Fix Loop detected:
     SC-008 (citation tooltip) — failed after fix attempt #1 (z-index), failed after fix attempt #2 (CSS refactor)
     → The fix approach is wrong, not just incomplete. Return to implement with source analysis.
   ```
   This prevents the "fix → re-fix → re-re-fix → start from scratch" degradation pattern. Two failed attempts = the problem needs implement-level redesign, not verify-level patching.

**This gate applies to ALL verify phases**: Phase 1 re-fixes, Phase 2 fixes, Phase 3 SC failure fixes, Phase 3b fixes, and post-Review user-requested fixes. There are NO exceptions.

---

### Verify Initialization — Compaction-Safe Checkpoint

Before any Phase execution, write the Verify Progress table AND Process Rules Checklist to sdd-state.md:

1. Read sdd-state.md → Feature Detail Log for this Feature
2. **Check for existing Verify Progress**:
   - If exists with pending phases → **Resumption Protocol** (see below)
   - If not exists → write fresh Verify Progress table with all phases as `⏳ pending`
3. Set `⚠️ RESUME FROM: Phase 0` line
4. **Write Process Rules Checklist** (survives context compaction — agent re-reads sdd-state.md after compaction):
   ```
   #### Verify Process Rules (re-read after compaction)
   - [ ] Source Modification Gate: BEFORE editing ANY source file → list changes → classify → aggregate → **HARD STOP AskUserQuestion for ALL classifications** (Minor AND Major) → user must approve before any edit
   - [ ] Minor Accumulator: 3+ Minor fixes in same module → auto-escalate to Major. State persisted in `#### Minor Fix Accumulator` — re-read after compaction.
   - [ ] Post-Fix Runtime Verification: after inline fix → build + test + runtime SC re-verify at Required Depth
   - [ ] SC Decomposition: mixed SCs → split into sub-SCs (auto + user-assisted)
   - [ ] Per-SC Depth Tracking: record Reached Depth vs Required Depth for each SC
   - [ ] Inline changes recording: all source modifications during verify → Notes column
   ```
   This checklist is written to sdd-state.md as plain text, ensuring it persists across context compaction boundaries. The Resumption Protocol (below) includes re-reading this checklist as step 1.

5. **Write Minor Fix Accumulator state** (survives context compaction):
   ```
   #### Minor Fix Accumulator (re-read after compaction)
   | Module | Fix Count | Fix Descriptions |
   |--------|-----------|-----------------|
   ```
   Initially empty. Updated after each approved Minor fix with the module name, incremented count, and brief description. If count reaches 3 for any module, auto-escalate per step 10.

**After each Phase completes**: Update the Phase's Status to `✅ complete` and write Result summary.
Update `⚠️ RESUME FROM` to point to the next pending Phase.

**On verify completion** (success or failure):
- Delete the `#### Verify Progress` section from sdd-state.md
- Delete the `#### Verify Process Rules` section from sdd-state.md
- Delete the `#### Minor Fix Accumulator` section from sdd-state.md
- Write final result to Notes column as before

---

### Pre-Resumption Validation (run before Resumption Protocol)

Before resuming verify from saved state:
1. **sdd-state.md readable**: File exists, markdown parses, State Schema Version present
2. **Verify Progress table exists**: Feature Detail Log has `### Verify Progress` for current Feature
3. **Process Rules Checklist exists**: `#### Verify Process Rules` section present
4. **Minor Fix Accumulator exists**: `#### Minor Fix Accumulator` section present (may be empty)
5. **Phase status consistency**: No phase marked `🔄 in_progress` (should have been saved as `⏳ pending` or `✅`)

If ANY check fails:
- Display: "Verify state integrity issue: {specific problem}"
- **Use AskUserQuestion**: "Verify state has issues. How to proceed?"
  - Options: "Reset verify from Phase 0", "Attempt auto-repair", "Abort verify"
- **If response is empty → re-ask** (per MANDATORY RULE 1)
- Auto-repair: re-create missing sections with `⏳ pending` status

---

### Resumption Protocol — After Context Compaction

If sdd-state.md contains `#### Verify Progress` with pending phases:

1. **Re-read this file** (commands/verify-phases.md) — MANDATORY
2. **Re-read reference/injection/verify.md** — for Checkpoint/Review display format
3. **Re-read `#### Verify Process Rules`** from sdd-state.md — MANDATORY. These rules survive compaction and MUST be followed for the remainder of the verify session. Pay special attention to the Source Modification Gate and Minor Accumulator.
4. **Re-read `#### Minor Fix Accumulator`** from sdd-state.md — MANDATORY. Restore accumulator state. If any module already has 2 fixes, the NEXT Minor fix in that module triggers auto-escalation.
5. **Identify resume point**: First phase with `⏳ pending` or `🔄 in_progress` status
6. **Re-establish prerequisites**:
   - Run Pre-flight Clean Slate (port check) — previous session's processes may be orphaned
   - If Phase 3 pending and MCP needed → re-run Phase 0 (app start + CDP check)
   - If Phase 1 already complete → do NOT re-run tests/build/lint
7. **Continue from resume point** through remaining phases
8. **Display resume notice**:
   ```
   🔄 Verify resumed from Phase [N] (context compaction detected)
   Previously completed: Phase 0 ✅, Phase 1 ✅, Phase 2 ✅
   Continuing: Phase 3, Phase 3b, Phase 4
   ```

---

### Verify Process Lifecycle Protocol

> Verify launches background processes (app servers, dev servers, Electron instances). Without lifecycle management, failed/aborted verifications leave orphan processes that block ports and corrupt subsequent runs. This protocol ensures deterministic cleanup regardless of how verify ends.

**PID Registry**: Maintain an in-memory list of all PIDs started during this verify session. Every background process launch (Phase 0 app start, 0-2c dev probe, Phase 3 restarts) MUST record its PID.

**Pre-flight Clean Slate** (runs once at verify start, before Phase 0):
1. Read the project's expected ports from constitution/quickstart (e.g., 3000, 5173, 9222, 4173)
2. Check for processes occupying those ports: `lsof -ti :PORT` (macOS/Linux)
3. If processes found:
   - Display: `⚠️ Port [PORT] occupied by PID [PID] ([process name]). Likely residue from a previous session.`
   - Kill the occupying process: `kill $PID` (graceful), wait 2s, `kill -9 $PID` if still alive
   - Display: `🧹 Cleaned up orphan process on port [PORT]`
4. If no conflicts: `✅ All expected ports available`

> **Why port-based, not PID-based**: PID files from previous sessions may be stale (PID recycled by OS). Port occupancy is the ground truth — if something is listening on the app's port, it must be cleared regardless of its origin.

**Cleanup on exit** (runs when verify completes, fails, or is aborted):
1. Iterate the PID registry in reverse order (LIFO — child processes first)
2. For each PID: `kill $PID` (SIGTERM), wait 2s, `kill -9 $PID` (SIGKILL) if still alive
3. Display: `🧹 Cleaned up [N] background processes`

> **Abort scenario**: If verify is interrupted (context compaction, user abort, unrecoverable error), the cleanup may not execute in the same session. The Pre-flight Clean Slate at the start of the NEXT verify session catches these cases — this is why both entry and exit cleanup are needed.

---

## Phase Execution — Read Per-Phase Files

Each phase is in a separate file to fit within context budget. Read ONLY the phase you are currently executing:

| Phase | File | When to Read |
|-------|------|-------------|
| Phase 0 + Pre-flight | [verify-preflight.md](verify-preflight.md) | Before Phase 1 — runtime environment setup (GUI Features only) + backend detection |
| Phase 1 | [verify-build-test.md](verify-build-test.md) | First — build/test/lint verification (BLOCKING) |
| Phase 2 | [verify-cross-feature.md](verify-cross-feature.md) | After Phase 1 passes — cross-Feature consistency + behavior completeness |
| Phase 3 + 3b | [verify-sc-verification.md](verify-sc-verification.md) | After Phase 2 — SC-level runtime verification + bug prevention |
| Evidence + Phase 4-5 | [verify-evidence-update.md](verify-evidence-update.md) | After Phase 3b — evidence gate, registry update, integration demo |

**Do NOT read all phase files at once.** Read one phase file, execute it, then read the next. This keeps context budget under control.

**The gates in THIS file (Bug Fix Severity Rule, Source Modification Gate, Verify Initialization, Process Lifecycle) apply to ALL phases.** They are in this hub file because they must always be in context.
