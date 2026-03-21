# Reset

Resets pipeline state for re-execution. Three modes:

| Mode | Syntax | What it does |
|------|--------|-------------|
| **Per-Feature** | `reset F007 [--from step]` | Resets a Feature's progress for re-execution |
| **Full pipeline** | `reset` | Resets entire pipeline — re-run all Features from scratch |
| **Permanent delete** | `reset --delete F007` | Permanently removes Feature(s) from the project |

All modes preserve reverse-spec artifacts (roadmap, pre-context, registries) unless explicitly stated.

---

## Step 1 — Parse & Validate

1. **Parse arguments**:
   - FID(s) without `--delete` → **Per-Feature Reset** (Mode B)
   - No FID, no `--delete` → **Full Pipeline Reset** (Mode A)
   - `--delete` flag with FID(s) → **Permanent Delete** (Mode C)
   - `--delete` without FID → error: `❌ --delete requires at least one Feature ID. Usage: reset --delete F007`
   - `--from [step]` → valid with Per-Feature mode only. Values: `specify` | `plan` | `tasks` | `implement` | `verify`
   - `--from` combined with `--delete` → error: `❌ --from is not compatible with --delete. --delete permanently removes the Feature.`
   - `--all` → valid with Full Pipeline mode only (include logs)

2. **Check BASE_PATH**: Verify `roadmap.md` exists at BASE_PATH. If not found:
   ```
   ❌ No roadmap.md found at {BASE_PATH}.
   Nothing to reset — run /reverse-spec first to analyze your project.
   ```

3. **Check sdd-state.md**: If not found:
   - Full Pipeline: `ℹ️ No sdd-state.md found. Pipeline has not been started yet.`
   - Per-Feature / Delete: `❌ No sdd-state.md found. Nothing to reset.`

4. **Validate FIDs** (Per-Feature and Delete modes):
   - Accept `F007` format → resolve to spec-kit Name via sdd-state.md Feature Mapping
   - Accept `007-chat` format (spec-kit Name)
   - If FID not found:
     ```
     ❌ F007 not found in sdd-state.md Feature Progress table.
     Available Features: F001-auth, F002-product, F003-order, ...
     ```

5. **Check current branch**: If on a target Feature branch, switch to `main` first.
   - If uncommitted changes exist:
     ```
     ⚠️ You have uncommitted changes on branch {branch-name}.
     These will be lost. Commit or stash first.
     ```
     **Use AskUserQuestion**: "Discard changes and continue" / "Cancel"
     **If response is empty → re-ask** (per MANDATORY RULE 1)

---

## Mode A: Full Pipeline Reset

> Syntax: `reset` or `reset --all`
> Resets the entire pipeline to start from scratch while preserving reverse-spec analysis artifacts.

### A-1. Current State Summary

Read `sdd-state.md` and display:

```
📋 Current Pipeline State:

  Origin: {greenfield/rebuild/adoption}
  Constitution: {status} (v{version})
  Features: {completed}/{total} completed, {adopted}/{total} adopted
  In-progress: {FID}-{name} at step {step} (if any)

  ── Artifacts to be REMOVED ─────────────────────────
    📄 specs/_global/sdd-state.md          — Pipeline state tracking
    📄 .specify/memory/constitution.md           — Finalized constitution
    📁 specs/{NNN-*/}                            — Feature spec directories ({count} found)
    📄 specs/add-draft.md                        — Add draft (if exists)
    🌿 Feature branches                          — {list of branches matching NNN-* pattern}

  ── Artifacts PRESERVED (reverse-spec) ──────────────
    📄 specs/_global/roadmap.md
    📄 specs/_global/constitution-seed.md
    📄 specs/_global/entity-registry.md
    📄 specs/_global/api-registry.md
    📄 specs/_global/business-logic-map.md  (if exists)
    📄 specs/_global/coverage-baseline.md   (if exists)
    📄 specs/_global/stack-migration.md     (if exists)
    📁 specs/_global/features/              (pre-context.md files)

  ── Optional (choose below) ─────────────────────────
    📄 specs/history.md                          — Decision history
```

### A-2. Reset Options (HARD STOP)

Use AskUserQuestion with the following options:

- **"Reset pipeline state only"** — Remove pipeline artifacts, keep history.md
- **"Full reset (include logs)"** — Also remove pipeline entries from history.md
- **"Cancel"** — Abort without changes

**If response is empty → re-ask** (per MANDATORY RULE 1).

### A-3. Execute Reset

#### A-3a. Switch to main branch

```bash
git checkout main
```

#### A-3b. Delete pipeline artifacts

In this exact order:

1. **Delete `sdd-state.md`**:
   ```bash
   rm -f specs/_global/sdd-state.md
   ```

2. **Delete `.specify/memory/constitution.md`** (if exists):
   ```bash
   rm -f .specify/memory/constitution.md
   ```

3. **Delete Feature spec directories** (spec-kit generated, NOT reverse-spec):
   ```bash
   rm -rf specs/[0-9][0-9][0-9]-*/
   ```

4. **Delete add-draft.md** (if exists):
   ```bash
   rm -f specs/add-draft.md
   ```

5. **Delete Feature branches** (if git repo):
   ```bash
   git branch --list '[0-9][0-9][0-9]-*' | xargs -r git branch -D
   ```

6. **Delete demos directory** (if exists):
   ```bash
   rm -rf demos/
   ```

#### A-3c. Restore registries to reverse-spec baseline

```bash
# If reverse-spec-complete tag exists, restore registries from that point
if git tag -l "reverse-spec-complete" | grep -q "reverse-spec-complete"; then
  git checkout reverse-spec-complete -- specs/_global/entity-registry.md
  git checkout reverse-spec-complete -- specs/_global/api-registry.md
fi
```

If the tag does not exist: Display a warning that registries may contain pipeline modifications, and leave them as-is.

#### A-3d. Optional: Reset logs

**If "Full reset (include logs)" was selected**:

1. **Clean history.md pipeline entries**: Remove all `### [FID]-[name] — Implementation Decisions` sections and `## [YYYY-MM-DD] /smart-sdd pipeline — Constitution` sections from `specs/history.md`. Keep `/reverse-spec` entries, strategy/architecture decisions, and the Project Context block intact.

#### A-3e. Commit

```bash
git add -A
git commit -m "chore: reset smart-sdd pipeline state (preserve reverse-spec artifacts)"
```

### A-4. Completion Report

```
✅ Pipeline state reset complete.

  Removed:
    - sdd-state.md (pipeline state)
    - constitution.md (will be re-finalized from constitution-seed.md)
    - {N} Feature spec directories
    - {N} Feature branches
    {- history.md pipeline entries removed (if full reset)}

  Preserved (reverse-spec artifacts):
    - roadmap.md ({N} Features defined)
    - constitution-seed.md
    - entity-registry.md, api-registry.md
    - {N} pre-context.md files
    - coverage-baseline.md

  Next: /smart-sdd pipeline — Start the pipeline from scratch
```

---

## Mode B: Per-Feature Reset

> Syntax: `reset F007` or `reset F007 --from plan` or `reset F007 F008`
> Resets a Feature's pipeline progress so it can be re-executed via `/smart-sdd pipeline`.
>
> **Preserves**: roadmap entry, pre-context.md, entity/API registry ownership, Feature row in sdd-state.md.
> **Resets**: pipeline step progress, spec directory contents, branch, demo files.

### B-1. --from Step Resolution

Default `--from` is `specify` (full reset from beginning).

| --from | Steps preserved (✅) | Steps reset (→ ⬜) | Artifacts deleted |
|--------|---------------------|---------------------|-------------------|
| `specify` | (none) | All | `specs/NNN-name/` dir, branch, demo files |
| `plan` | specify | plan → verify | `plan.md`, `tasks.md` in spec dir; branch, demo files |
| `tasks` | specify, plan | tasks → verify | `tasks.md` in spec dir; branch, demo files |
| `implement` | specify, plan, tasks | implement, verify | Branch, demo files |
| `verify` | specify, plan, tasks, implement | verify | (nothing — just re-verify) |

### B-2. Status & Impact Summary

For each target Feature, read and display:

```
🔄 Reset Feature: [FID]-[name]

  Current: [status] at [current-step] step
  Reset to: [--from step] (all progress from [step] onward will be cleared)

  ── Will be RESET ──────────────────────────────────
    📊 sdd-state.md progress: [list of steps] → ⬜
    📁 specs/[NNN]-[name]/  [partial/full deletion details]
    🌿 [NNN]-[name] branch  [will be deleted / kept]
    📄 demos/F[NNN]-[name].*  [will be deleted / kept]

  ── PRESERVED ──────────────────────────────────────
    📄 specs/_global/features/[FID]-[name]/pre-context.md
    📋 roadmap.md entry
    📋 entity-registry.md ownership
    📋 api-registry.md ownership
    📊 sdd-state.md Feature row (progress reset, not removed)

  ── Warnings ───────────────────────────────────────
    [If branch is merged to main:]
    ⚠️ Source code has been merged to main.
    Re-implementing will create new code alongside existing code.
    Consider: git revert [merge commit hash] before re-running pipeline.

    [If Feature is completed/adopted:]
    ⚠️ Feature was [completed/adopted]. All progress will be discarded.

    [If other Features depend on this and specify/plan is being reset:]
    ⚠️ Dependent Features may be affected:
      [FID2]-[name]: depends on [FID] in roadmap
    → These will be marked 🔀 (re-run from plan) after reset
```

### B-3. Confirmation (HARD STOP)

**Use AskUserQuestion**:
- "Reset [FID] from [step]" (single Feature)
- "Reset [N] Features from [step]" (multiple Features)
- "Cancel"

**If response is empty → re-ask** (per MANDATORY RULE 1)

### B-4. Execute Reset

For each confirmed Feature:

#### B-4a. sdd-state.md — Feature Progress

Reset steps from the `--from` step onwards to ⬜:

- If `--from specify`: all steps → ⬜, status → `pending`
- If `--from plan` or later: keep prior steps as ✅, set `--from` step and after → ⬜, status → `in_progress`
- Clear the Feature Detail Log entries for the reset steps

#### B-4b. Spec directory

| --from | Action |
|--------|--------|
| `specify` | `rm -rf specs/[NNN]-[name]/` |
| `plan` | Delete `plan.md`, `tasks.md` from `specs/[NNN]-[name]/` (keep `spec.md`) |
| `tasks` | Delete `tasks.md` from `specs/[NNN]-[name]/` (keep `spec.md`, `plan.md`) |
| `implement` | Keep all spec files (they define what to re-implement) |
| `verify` | Keep all spec files |

#### B-4c. Feature branch

| --from | Action |
|--------|--------|
| `specify` through `implement` | `git branch -D [NNN]-[name]` (will be recreated by implement) |
| `verify` | Keep branch (implementation is preserved) |

If branch doesn't exist → skip silently.
If branch is merged to main → display warning (code remains in main).

#### B-4d. Demo files

| --from | Action |
|--------|--------|
| `specify` through `implement` | `rm -f demos/[FID]-[name].*` and `rm -f demos/F[NNN]-[name].*` |
| `verify` | Keep demo files (just re-verify them) |

#### B-4e. Mark dependent Features 🔀

If resetting from `specify` or `plan`: Other Features that depend on this Feature may need re-planning.

For each dependent Feature (found via roadmap.md Dependency Graph):
- Mark `plan` step as 🔀 in sdd-state.md Feature Progress
- Set status to `restructured`

#### B-4f. Record in history.md

```markdown
## [YYYY-MM-DD] /smart-sdd reset

| Feature | Reset from | Previous Status | Dependents Affected |
|---------|-----------|-----------------|---------------------|
| [FID]-[name] | [step] | [status] | [FID2] 🔀, [FID3] 🔀 (or "none") |
```

### B-5. Commit & Report

```bash
git add -A
git commit -m "chore: reset [FID]-[name] from [step]"
```

For multiple Features: `"chore: reset Features [FID1], [FID2] from [step]"`

```
✅ Reset [FID]-[name] from [step]

  Progress cleared: [list of steps] → ⬜
  Artifacts deleted:
    - specs/[NNN]-[name]/ [full dir / partial files]
    - [NNN]-[name] branch [deleted / kept]
    - [N] demo files [deleted / kept]

  Preserved:
    - pre-context.md, roadmap entry, registry ownership
    - sdd-state Feature row (ready for re-execution)

  Dependents marked 🔀:
    - [FID2]-[name2]: re-run from plan
    (or "none")

  [If code was merged:]
  ⚠️ Source code remains in main branch. Consider:
    git revert [merge-commit]   # before re-running pipeline

  Next: /smart-sdd pipeline [FID] — Re-run the Feature
```

---

## Mode C: Permanent Deletion (--delete)

> Syntax: `reset --delete F007` or `reset --delete F007 F008`
> Permanently removes Feature(s) from the project. Removes ALL traces including roadmap entry, pre-context, registry ownership, and sdd-state row.
>
> Works for Features in **any status** (pending, in_progress, completed, adopted).
> For pending-only cleanup, see the cleanup flow in `commands/add.md`.

### C-1. Impact Scan

For each target Feature, scan all dependency surfaces:

1. **Status & Progress**: Read status, current step, branch name, merge status from sdd-state.md
2. **Dependency Scan — Who depends on THIS Feature?**:
   - roadmap.md Dependency Graph: Find Features listing this FID as a dependency
   - pre-context.md files: Grep all `specs/_global/features/*/pre-context.md` for references
   - entity-registry.md: Find entities owned by this Feature → check if other Features reference them
   - api-registry.md: Find APIs owned by this Feature → check if other Features consume them
3. **Owned Artifacts**: Entities, APIs, SBI entries, Demo Group memberships

### C-2. Impact Report + Confirmation (HARD STOP)

Display for each target Feature:

```
🗑️ Delete Feature: [FID]-[name]

  Status: [status] (at [step] step)
  Branch: [NNN]-[name] ([merged to main / not merged])

  ── Will be PERMANENTLY DELETED ───────────────────
    📄 specs/_global/features/[FID]-[name]/  (pre-context.md)
    📁 specs/[NNN]-[name]/                        (spec directory)
    🌿 [NNN]-[name] branch
    📄 demos/[FID]-[name].*                       (demo scripts)
    📊 sdd-state.md entries                       (Progress, Mapping, Detail Log)
    📋 roadmap.md entries                         (Catalog, Dependency Graph, Groups)
    📋 Owned entities: [list or "none"]
    📋 Owned APIs: [list or "none"]
    📋 SBI entries: [N] behaviors → unmapped

  ── Warnings ──────────────────────────────────────
    [If dependents exist:]
    ⚠️ Referenced by other Features:
      [FID2]-[name]: pre-context.md depends on [FID]
      [FID3]-[name]: entity-registry references "[Entity]" owned by [FID]
    → These Features will be marked 🔀 (re-run from plan)

    [If completed and merged:]
    ⚠️ Source code has been merged to main.
    Code removal is your responsibility:
      - Review and manually remove related code, or:
      - git revert [merge commit hash]

    [If entities are referenced by other Features:]
    ⚠️ Orphaned entities (referenced by other Features but owner removed):
      [Entity]: referenced by [FID2], [FID3]
    → Owner column will be cleared. Reassign ownership manually or via /smart-sdd pipeline.
```

**Use AskUserQuestion**:
- "Delete [FID] permanently and mark dependents 🔀"
- "Cancel"

**If response is empty → re-ask** (per MANDATORY RULE 1)

### C-3. Execute Deletion

Update artifacts in this order (based on [restructure-guide.md](../reference/restructure-guide.md) Artifact Update Checklist).

> **Exception**: restructure-guide's "never auto-delete" policy for `specs/NNN-name/` directories and branches applies to restructure operations (split/merge/move) where the user may want to reference old artifacts. `--delete` is an explicit permanent removal with HARD STOP confirmation — deletion of all traces is intentional.

1. **roadmap.md**: Remove from Feature Catalog, Dependency Graph (mermaid + table), Release Groups, Demo Groups
2. **entity-registry.md**: Entities owned by this Feature →
   - Not referenced by other Features → remove entity row
   - Referenced by other Features → clear Owner column (set to `—`), display warning
3. **api-registry.md**: Same logic as entity-registry
4. **business-logic-map.md** (if exists): Remove Feature-assigned business rules for this Feature
5. **sdd-state.md**: Remove Feature Progress row, Feature Mapping row, Feature Detail Log section
   - SBI Coverage: Clear Feature column, set status → `unmapped`
   - Demo Group Progress: Remove this Feature from group members
   - Restructure Log: `| [date] | delete | [FID]-[name] | User requested via /smart-sdd reset --delete |`
6. **Pre-context directory**: `rm -rf specs/_global/features/[FID]-[name]/`
7. **Spec directory**: `rm -rf specs/[NNN]-[name]/`
8. **Demo files**: `rm -f demos/[FID]-[name].*` and `rm -f demos/F[NNN]-[name].*`
9. **Feature branch**: `git branch -D [NNN]-[name]` (skip silently if not found)
10. **Dependent Features**: Mark `plan` step as 🔀, set status to `restructured`
11. **history.md**:
    ```markdown
    ## [YYYY-MM-DD] /smart-sdd reset --delete

    | Deleted | Status | Dependents Affected |
    |---------|--------|---------------------|
    | [FID]-[name] | [status] | [FID2] 🔀, [FID3] 🔀 (or "none") |
    ```

### C-4. Commit & Report

```bash
git add -A
git commit -m "chore: delete Feature [FID]-[name]"
```

For multiple Features: `"chore: delete Features [FID1], [FID2]"`

```
✅ Deleted [FID]-[name]

  Permanently removed:
    - specs/[NNN]-[name]/ (spec directory)
    - specs/_global/features/[FID]-[name]/ (pre-context)
    - roadmap.md entries
    - [NNN]-[name] branch
    - [N] demo files
    - [N] entity entries, [N] API entries
    - [N] SBI entries → unmapped

  Dependents marked 🔀:
    - [FID2]-[name2]: re-run from plan
    (or "none")

  [If code was merged:]
  ⚠️ Source code remains in your codebase. To remove:
    git revert [merge-commit]   # or manually delete related files

  Next:
    /smart-sdd pipeline — will re-plan dependent Features marked 🔀
```

---

## Edge Cases

### No git repository
- Skip branch operations, registry restore, commit
- Delete files directly
- Display: "No git repository — files deleted directly (no commit created)"

### Feature is currently being processed (in_progress)
- Warn: "[FID] is currently in_progress at [step]. Resetting will discard all progress."
- Proceed normally if user confirms.

### Greenfield project (no reverse-spec artifacts) — Mode A only
- `specs/_global/` files were created by `smart-sdd init`, not reverse-spec
- Preserved: roadmap.md, entity-registry.md, api-registry.md (they define project structure)

### Partial pipeline (some completed, some pending) — Mode A only
- Reset removes ALL Feature specs regardless of status
- Source code remains in the working tree
- Display: "⚠️ Source code written during implementation remains in your project. Use `git reset --hard reverse-spec-complete` to also remove implementation code."

### Last remaining Feature — Mode C only
- Allow deletion — results in an empty pipeline
- Display: "No Features remaining. Use /smart-sdd add or /smart-sdd pipeline to add Features."

### Deleting a Feature that was already deleted — Mode C only
- Step 1 validation catches this: "[FID] not found in sdd-state.md"

### reset F007 when Feature is pending — Mode B
- Specify hasn't run yet → nothing to reset
- Display: "ℹ️ [FID] is pending (no progress to reset). Use /smart-sdd pipeline [FID] to start."

### --from verify when verify hasn't run — Mode B
- Set verify → ⬜ (it was already ⬜)
- Display: "ℹ️ [FID] verify hasn't run yet. Use /smart-sdd pipeline [FID] --start verify to run it."

### Multiple FIDs with --from when Features are at different steps — Mode B
- `--from` applies uniformly to all specified FIDs
- If a Feature hasn't reached the `--from` step yet: skip it with notice
  - Example: `reset F007 F008 --from plan` but F008 is still at `pending` (specify not done)
  - Display: "ℹ️ F008 hasn't reached plan step — skipped. Only F007 was reset."
- Process each Feature independently based on its current progress
