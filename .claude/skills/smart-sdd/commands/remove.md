# Remove Feature

Remove one or more Features from the project. Handles all artifact cleanup (roadmap, registries, state, specs, branches, demos) and warns about downstream dependencies.

Works for Features in **any status** (pending, in_progress, completed, adopted).

---

## Step 1 — Parse & Validate

1. **Parse Feature IDs** from arguments: `/smart-sdd remove F007` or `/smart-sdd remove F007 F008`
   - Accept `F007` format (smart-sdd ID) — resolve to spec-kit Name via sdd-state.md Feature Mapping
   - Also accept `007-chat` format (spec-kit Name)

2. **Read `sdd-state.md`**: Validate each FID exists in the Feature Progress table.
   - If FID not found:
     ```
     ❌ F007 not found in sdd-state.md Feature Progress table.
     Available Features: F001-auth, F002-product, F003-order, ...
     ```

3. **Check current branch**: If currently on one of the target Feature branches, switch to `main` first.
   - If uncommitted changes exist on the Feature branch:
     ```
     ⚠️ You have uncommitted changes on branch 007-chat.
     These will be lost if you remove this Feature.
     ```
     **Use AskUserQuestion**: "Discard changes and continue" / "Cancel removal"
     **If response is empty → re-ask** (per MANDATORY RULE 1)

---

## Step 2 — Impact Scan

For each target Feature, scan all dependency surfaces:

### 2a. Status & Progress

- Read Feature status from sdd-state.md Feature Progress (pending / in_progress / completed / adopted)
- Read current step (if in_progress)
- Read Feature Mapping: branch name, merged status

### 2b. Dependency Scan — Who depends on THIS Feature?

1. **roadmap.md Dependency Graph**: Parse the dependency table → find Features that list this FID as a dependency
2. **pre-context.md files**: Grep all `specs/reverse-spec/features/*/pre-context.md` for references to this FID
3. **entity-registry.md**: Find entities owned by this Feature → check if other Features reference them (Foreign Key column)
4. **api-registry.md**: Find APIs owned by this Feature → check if other Features consume them

Collect all dependent Feature IDs into a `dependents` list.

### 2c. Owned Artifacts

- **Entities**: List entities in entity-registry.md where Owner Feature = this FID
- **APIs**: List APIs in api-registry.md where Owner Feature = this FID
- **SBI entries**: Count SBI Coverage entries mapped to this Feature
- **Demo Group memberships**: Check Demo Group Progress for this Feature

### 2d. Git Artifacts

- **Branch**: Does `git branch --list '{NNN}-*'` return a match?
- **Merged**: Is the branch merged to main? (`git branch --merged main` check)
- **Spec directory**: Does `specs/{NNN}-*/` exist?
- **Demo files**: Do `demos/F{NNN}-*` files exist?

---

## Step 3 — Impact Report + Confirmation (HARD STOP)

Display the full impact report for each target Feature:

```
🗑️ Remove Feature: [FID]-[name]

  Status: [status] (at [step] step)
  Branch: [NNN]-[name] ([merged to main / not merged])

  ── Will be REMOVED ─────────────────────────────────
    📁 specs/[NNN]-[name]/                    (spec directory)
    📁 specs/reverse-spec/features/[FID]-[name]/  (pre-context.md)
    🌿 [NNN]-[name] branch
    📄 demos/[FID]-[name].*                   (demo scripts)
    📊 sdd-state.md entries                   (Progress, Mapping, Detail Log)
    📋 Owned entities: [list or "none"]
    📋 Owned APIs: [list or "none"]
    📋 SBI entries: [N] behaviors → unmapped

  ── Warnings ────────────────────────────────────────
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

    [If in_progress and not merged:]
    ⚠️ Source code on branch [NNN]-[name] will be deleted with the branch.

    [If entities are referenced by other Features:]
    ⚠️ Orphaned entities (referenced by other Features but owner removed):
      [Entity]: referenced by [FID2], [FID3]
    → Owner column will be cleared. Reassign ownership manually or via /smart-sdd pipeline.
  ──────────────────────────────────────────────────
```

**Use AskUserQuestion**:
- "Remove [FID] and mark dependents 🔀" (single Feature)
- "Remove [N] Features and mark dependents 🔀" (multiple Features)
- "Cancel"

**If response is empty → re-ask** (per MANDATORY RULE 1)

---

## Step 4 — Execute Removal

For each confirmed Feature, update artifacts in this order (based on [restructure-guide.md](../reference/restructure-guide.md) Artifact Update Checklist):

### 4-1. roadmap.md

- Remove Feature from **Feature Catalog** table
- Remove Feature from **Dependency Graph** (mermaid diagram + dependency table)
- Remove Feature from **Release Groups** (remove from group members; if group becomes empty, remove group)
- Remove Feature from **Demo Groups** (remove from group members)
- Remove Feature from **Cross-Feature Entity/API Dependencies** table (if exists)

### 4-2. entity-registry.md

For each entity owned by this Feature:
- **Not referenced by other Features** → remove the entity row entirely
- **Referenced by other Features** → clear the Owner Feature column (set to `—`). Display:
  ```
  ⚠️ Entity "[Entity]" owner cleared — referenced by [FID2], [FID3]. Reassign ownership.
  ```

### 4-3. api-registry.md

Same logic as entity-registry:
- **Not consumed by other Features** → remove the API row
- **Consumed by other Features** → clear Owner, display warning

### 4-4. sdd-state.md

- **Feature Progress table**: Remove the Feature's row
- **Feature Mapping table**: Remove the Feature's row
- **Feature Detail Log**: Remove the Feature's section
- **SBI Coverage** (if exists): Clear Feature column for this Feature's entries, set status → `unmapped`
- **Demo Group Progress** (if exists): Remove this Feature from group members
- **Restructure Log**: Add entry:
  ```
  | [date] | delete | [FID]-[name] | User requested via /smart-sdd remove |
  ```

### 4-5. Pre-context directory

```bash
rm -rf specs/reverse-spec/features/[FID]-[name]/
```

### 4-6. Spec directory

```bash
rm -rf specs/[NNN]-[name]/
```

### 4-7. Demo files

```bash
rm -f demos/[FID]-[name].*
rm -f demos/F[NNN]-[name].*
```

If `demos/` directory is now empty, remove it.

### 4-8. Feature branch

```bash
git branch -D [NNN]-[name]
```

- If branch doesn't exist → skip silently
- If branch has unmerged changes → already warned in Step 3, delete anyway (user confirmed)

### 4-9. Mark dependent Features 🔀

For each Feature in the `dependents` list (from Step 2b):
- In sdd-state.md Feature Progress: mark `plan` step as 🔀 (needs re-execution)
- Set Feature status to `restructured`
- This ensures the next pipeline run will re-plan these Features (dependency removed)

### 4-10. Record in history.md

```markdown
## [YYYY-MM-DD] /smart-sdd remove

| Removed | Status | Dependents Affected |
|---------|--------|---------------------|
| [FID]-[name] | [status] | [FID2] 🔀, [FID3] 🔀 (or "none") |
```

---

## Step 5 — Commit & Report

### 5-1. Commit

```bash
git add -A
git commit -m "chore: remove Feature [FID]-[name]"
```

For multiple Features: `"chore: remove Features [FID1], [FID2]"`

### 5-2. Completion Report

```
✅ Removed [FID]-[name]

  Deleted:
    - specs/[NNN]-[name]/ (spec directory)
    - specs/reverse-spec/features/[FID]-[name]/ (pre-context)
    - [NNN]-[name] branch
    - [N] demo files
    - [N] entity entries, [N] API entries
    - [N] SBI entries → unmapped

  Dependents marked 🔀:
    - [FID2]-[name2]: re-run from plan
    - [FID3]-[name3]: re-run from plan

  [If code was merged:]
  ⚠️ Source code remains in your codebase. To remove:
    git revert [merge-commit]   # or manually delete related files

  Next:
    /smart-sdd pipeline — will re-plan dependent Features marked 🔀
```

---

## Edge Cases

### No sdd-state.md
```
❌ No sdd-state.md found. Nothing to remove.
```

### Feature is currently being processed (in_progress)
- Warn: "F007 is currently in_progress at [step]. Removing will discard all progress."
- Proceed normally if user confirms.

### Last remaining Feature
- Allow removal — results in an empty pipeline
- Display: "No Features remaining. Use /smart-sdd add or /smart-sdd pipeline to add Features."

### No git repository
- Skip branch operations (Steps 4-8)
- Skip commit (Step 5-1)
- Display: "No git repository — files deleted directly (no commit created)"

### Removing a Feature that was already removed
- Step 1 validation catches this: "F007 not found in sdd-state.md"
