# Known Limitations & Recovery Paths

> Documents scenarios where the system has known gaps and provides workarounds.
> Referenced by: SKILL.md (for user guidance), pipeline.md (for edge case handling).
> Lazy-loaded: only when user encounters a scenario listed here.

---

## L1. Mid-Step Crash Recovery (S05)

**Scenario**: Session crashes during a spec-kit command execution (e.g., `speckit-specify` was running). Partial artifact on disk.

**Risk**: Half-written `spec.md` or `plan.md`. Re-running the step may append duplicate content.

**Recovery**:
1. Check artifact file size and content — is it complete? (look for closing sections like "## Success Criteria")
2. If incomplete: **delete the partial artifact**, then re-run the step: `/smart-sdd pipeline [FID] --start [step]`
3. If complete but uncertain: keep it, run the next step. The downstream step (plan, tasks) will validate the input
4. `sdd-state.md` Feature Progress shows the last completed step — resume from the NEXT step

**Prevention**: The pipeline writes `sdd-state.md` Feature Progress at each step boundary (after successful completion). If the step didn't complete, the progress still shows the previous step.

---

## L2. Architecture Pivot Mid-Project (S08)

**Scenario**: After completing F001-F003, the developer realizes the overall architecture is wrong and wants to change approach for remaining Features.

**Current limitation**: No "re-constitute" command. Constitution is one-time.

**Workaround**:
1. Edit `.specify/memory/constitution.md` manually with the new architecture decisions
2. For already-completed Features that need updating: `/smart-sdd pipeline [FID] --start specify` (Step-Back Protocol will cascade)
3. For remaining Features: they will naturally pick up the edited constitution
4. Update `entity-registry.md` and `api-registry.md` if the architecture change affects data models or API contracts
5. Record the pivot decision in `sdd-state.md` Notes section

**Future**: A `/smart-sdd reconstitute` command could automate this (re-run constitution, assess impact, cascade).

---

## L3. Completed Feature Re-opening (S10)

**Scenario**: F002 is `completed`, F003 is `in_progress`. User wants to add a requirement to F002.

**Recovery**:
1. Update F002's status in `sdd-state.md`: `completed` → `in_progress` at `specify`
2. Run: `/smart-sdd pipeline F002 --start specify`
3. The Cascading Update Protocol (cascading-update.md) handles downstream updates
4. Cross-Feature Impact Analysis (Step 4) assesses impact on F003
5. If F003 depends on F002's changed entities/APIs, F003 may need re-planning

**Important**: F003's pipeline should be PAUSED until F002's changes are finalized. The system does not auto-pause — the user must manage this manually.

---

## L4. spec-kit CLI Installation Failure (S15)

**Scenario**: Corporate network blocks pip/GitHub access. `specify` CLI cannot be installed.

**Workaround options**:
1. **Pre-install on a machine with access**: Install spec-kit, copy the virtual environment to the restricted machine
2. **Manual spec generation**: Write `spec.md`, `plan.md`, `tasks.md` manually following the templates in `templates/`. The pipeline can consume manually-created artifacts
3. **Proxy configuration**: Set `HTTP_PROXY`/`HTTPS_PROXY` before installation: `HTTP_PROXY=http://proxy:port pip install git+https://github.com/github/spec-kit.git`
4. **Offline install**: Download the wheel file on a connected machine, transfer, install with `pip install speckit-*.whl`

**The pipeline REQUIRES spec-kit CLI**. Without it, the `speckit-specify`, `speckit-plan`, `speckit-tasks` commands cannot execute. Manual artifact creation is the only fallback.

---

## L5. Concurrent Feature Development (S18)

**Scenario**: Two developers work on different Features simultaneously. Shared artifacts (registries, sdd-state.md) may conflict.

**Current limitation**: No concurrency control. Last writer wins.

**Workaround**:
1. **Sequential by Release Group**: Assign Features to developers by Release Group. Only one developer works per RG at a time
2. **Registry merge strategy**: After both developers push, manually merge registry conflicts (entity-registry, api-registry). Entities from different Features should be in different sections
3. **sdd-state.md conflict**: Feature Progress rows are Feature-specific. As long as developers update only their own Feature's row, merge should be clean
4. **Branch discipline**: Each developer works on their Feature branch. Merge to main one at a time. After merge, the next developer rebases before continuing

**Future**: File-level locking or per-Feature registry sections could eliminate conflicts.

---

## L6. Monorepo (S20)

**Scenario**: Monorepo with `packages/frontend` (React) + `packages/backend` (Express). Single Domain Profile cannot express both.

**Current limitation**: One Domain Profile per project. No package-level scoping.

**Workaround**:
1. **Feature-level interface override**: In each Feature's pre-context, specify the primary interface (`gui` for frontend Features, `http-api` for backend Features). The pipeline uses the Feature's interface for verification, not the project-level profile
2. **Separate specs directories**: Not recommended — breaks GEL continuity. Better to use a single `specs/` with Feature-level scoping
3. **Package-aware tasks**: In tasks.md, prefix task file paths with the package name (`packages/frontend/src/...`). The implement step respects these paths

**Future**: `Structure: monorepo` field in sdd-state.md should activate package-level Domain Profile scoping.

---

## L7. Non-Server Application Patterns

**Scenario**: Application doesn't follow "start → listen on port → health check" pattern. Examples: CI runners, Temporal workers, embedded libraries, batch processors.

**Pattern-specific handling**:

| Pattern | Start | Verify | Stop |
|---------|-------|--------|------|
| **Pull-based daemon** (CI runner, worker) | Start process | CLI health command or management API | SIGTERM |
| **Embedded library** | N/A (import) | Import + call API in test script | N/A |
| **Batch processor** | N/A (per-invocation) | Run with test data, verify output | N/A |
| **Background service** (no port) | Start process | Check PID alive + log output | SIGTERM |

The verify-preflight detects this from the interface type (`cli`, `library`, `data-io`) and skips Phase 0 server startup.
