# Reset Pipeline State

Resets smart-sdd pipeline state to start over from scratch while preserving reverse-spec analysis artifacts.

---

## Step 1 — Pre-Validation

1. **Check BASE_PATH**: Verify `roadmap.md` exists at BASE_PATH. If not found:
   ```
   ❌ No roadmap.md found at {BASE_PATH}.
   Nothing to reset — run /reverse-spec first to analyze your project.
   ```

2. **Check sdd-state.md**: If `sdd-state.md` does not exist at BASE_PATH:
   ```
   ℹ️ No sdd-state.md found. Pipeline has not been started yet.
   Use /smart-sdd pipeline to start the SDD pipeline.
   ```

---

## Step 2 — Current State Summary

Read `sdd-state.md` and display the current state:

```
📋 Current Pipeline State:

  Origin: {greenfield/rebuild/adoption}
  Constitution: {status} (v{version})
  Features: {completed}/{total} completed, {adopted}/{total} adopted
  In-progress: {FID}-{name} at step {step} (if any)

  ── Artifacts to be REMOVED ─────────────────────────
    📄 specs/reverse-spec/sdd-state.md          — Pipeline state tracking
    📄 .specify/memory/constitution.md           — Finalized constitution
    📁 specs/{NNN-*/}                            — Feature spec directories ({count} found)
    📄 specs/add-draft.md                        — Add draft (if exists)
    🌿 Feature branches                          — {list of branches matching NNN-* pattern}

  ── Artifacts PRESERVED (reverse-spec) ──────────────
    📄 specs/reverse-spec/roadmap.md
    📄 specs/reverse-spec/constitution-seed.md
    📄 specs/reverse-spec/entity-registry.md
    📄 specs/reverse-spec/api-registry.md
    📄 specs/reverse-spec/business-logic-map.md  (if exists)
    📄 specs/reverse-spec/coverage-baseline.md   (if exists)
    📄 specs/reverse-spec/stack-migration.md     (if exists)
    📁 specs/reverse-spec/features/              (pre-context.md files)

  ── Optional (choose below) ─────────────────────────
    📄 case-study-log.md                         — Case study observations
    📄 specs/history.md                          — Decision history
```

---

## Step 3 — Reset Options (HARD STOP)

Use AskUserQuestion with the following options:

- **"Reset pipeline state only"** — Remove pipeline artifacts, keep case-study-log and history.md
- **"Full reset (include logs)"** — Also reinitialize case-study-log.md and remove pipeline entries from history.md
- **"Cancel"** — Abort without changes

**If response is empty → re-ask** (per MANDATORY RULE 1).

---

## Step 4 — Execute Reset

### 4-1. Switch to main branch

```bash
git checkout main
```

If on a Feature branch with uncommitted changes, warn:
```
⚠️ You have uncommitted changes on branch {branch-name}.
These will be lost if you reset. Commit or stash first.
```
Display AskUserQuestion: "Discard changes and continue" / "Cancel reset"

### 4-2. Delete pipeline artifacts

In this exact order:

1. **Delete `sdd-state.md`**:
   ```bash
   rm -f specs/reverse-spec/sdd-state.md
   ```

2. **Delete `.specify/memory/constitution.md`** (if exists):
   ```bash
   rm -f .specify/memory/constitution.md
   ```

3. **Delete Feature spec directories** (spec-kit generated, NOT reverse-spec):
   ```bash
   # Delete specs/{NNN-name}/ directories (3-digit prefix pattern)
   # These are spec-kit Feature directories, NOT reverse-spec artifacts
   rm -rf specs/[0-9][0-9][0-9]-*/
   ```

4. **Delete add-draft.md** (if exists):
   ```bash
   rm -f specs/add-draft.md
   ```

5. **Delete Feature branches** (if git repo):
   ```bash
   # List branches matching NNN-* pattern (Feature branches)
   git branch --list '[0-9][0-9][0-9]-*' | xargs -r git branch -D
   ```

6. **Delete demos directory** (if exists and contains only demo scripts):
   ```bash
   rm -rf demos/
   ```

### 4-3. Restore registries to reverse-spec baseline

The entity-registry.md and api-registry.md may have been modified during pipeline execution (new entities/APIs added by smart-sdd). Reset them to the reverse-spec baseline state using the git tag:

```bash
# If reverse-spec-complete tag exists, restore registries from that point
if git tag -l "reverse-spec-complete" | grep -q "reverse-spec-complete"; then
  git checkout reverse-spec-complete -- specs/reverse-spec/entity-registry.md
  git checkout reverse-spec-complete -- specs/reverse-spec/api-registry.md
fi
```

If the tag does not exist: Display a warning that registries may contain pipeline modifications, and leave them as-is.

### 4-4. Optional: Reset logs

**If "Full reset (include logs)" was selected**:

1. **Reinitialize case-study-log.md**: Read [`case-study-log-template.md`](../../case-study/templates/case-study-log-template.md) and overwrite `case-study-log.md` at project root

2. **Clean history.md pipeline entries**: Remove all `### [FID]-[name] — Implementation Decisions` sections and `## [YYYY-MM-DD] /smart-sdd pipeline — Constitution` sections from `specs/history.md`. Keep `/reverse-spec` entries, strategy/architecture decisions, and the Project Context block intact.

### 4-5. Commit the reset

```bash
git add -A
git commit -m "chore: reset smart-sdd pipeline state (preserve reverse-spec artifacts)"
```

---

## Step 5 — Completion Report

```
✅ Pipeline state reset complete.

  Removed:
    - sdd-state.md (pipeline state)
    - constitution.md (will be re-finalized from constitution-seed.md)
    - {N} Feature spec directories
    - {N} Feature branches
    {- case-study-log.md reinitialized (if full reset)}
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

## Edge Cases

### No git repository
- Skip branch operations (Steps 4-1, 4-3, 4-5)
- Delete files directly without git commit
- Display: "No git repository — files deleted directly (no commit created)"

### Greenfield project (no reverse-spec artifacts)
- All `specs/reverse-spec/` files were created by `smart-sdd init`, not reverse-spec
- Reset removes everything: sdd-state.md + constitution + Feature specs
- Preserved: roadmap.md, entity-registry.md, api-registry.md (even though they were created by init, they define the project structure)

### Partial pipeline (some Features completed, some pending)
- Reset removes ALL Feature specs regardless of status
- Source code written by `speckit-implement` remains in the project (it's in the working tree, not in specs/)
- Display warning: "⚠️ Source code written during implementation remains in your project. Use `git reset --hard reverse-spec-complete` to also remove implementation code."
