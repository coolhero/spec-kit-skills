# Git Branch Management

> Read during pipeline merge steps and Feature branch operations.
> For step-mode branch validation, see `commands/pipeline.md` § Step Mode.
> For Non-Git Projects policy, see `SKILL.md` § Non-Git Projects.

---

smart-sdd integrates with spec-kit's Feature branch workflow to ensure each Feature is developed in isolation and merged to main only after successful verification.

### Branch Lifecycle

```
main ─── (pre-flight) ──→ smart-sdd creates branch {NNN}-{short-name}
                               │
                               ├── specify, plan, tasks, implement, verify (all on Feature branch)
                               │
                               ├── Post-Feature updates (entity-registry, api-registry, etc.)
                               │
                               ├── Merge Checkpoint (HARD STOP — user approval)
                               │
main ←── (merge) ─────────────┘
```

### Pre-Flight: Before Starting a Feature

Before executing `specify` for a new Feature:

1. **Verify current branch is `main`**: Run `git branch --show-current`
   - If not on main: Display warning and ask user whether to switch to main first
   - If there are uncommitted changes: Warn the user and ask how to proceed (stash, commit, or abort)
2. **Ensure main is up to date**: Run `git status` to check for uncommitted changes
   - If the project has a remote: Suggest `git pull` but do not force it
3. **Create Feature branch**: smart-sdd creates and switches to the Feature branch
   ```bash
   git checkout -b {NNN}-{short-name}
   ```
   - `{NNN}` = spec-kit Name prefix from sdd-state.md Feature Mapping (e.g., `001`)
   - `{short-name}` = Feature short name (e.g., `auth`, `product-catalog`)
   - Record the branch name in sdd-state.md Feature Mapping → Branch column

> **Why smart-sdd creates the branch**: spec-kit is initialized with `--no-git` (Step 0c) to avoid conflicts with existing git repos. This means `speckit-specify` does NOT create Feature branches. smart-sdd handles all git operations explicitly.
>
> **⚠️ Auto-numbering conflict**: Because the Feature branch `{NNN}-{short-name}` already exists when `speckit-specify` runs, spec-kit's `create-new-feature.sh` auto-numbering may detect `{NNN}` as "in use" and assign the next number. When invoking `speckit-specify`, always pass the Feature name as `{NNN}-{short-name}` (e.g., `002-navigation`) to force the correct number. See `commands/pipeline.md` § Feature Number Conflict Prevention.

### Pre-Flight for --start Re-execution

When `--start` targets an existing Feature (not a new one):

| Situation | Action |
|-----------|--------|
| On correct Feature branch, clean | Proceed |
| On correct Feature branch, dirty | BLOCKING: commit or stash |
| On main, Feature branch exists | Checkout Feature branch |
| On main, Feature branch doesn't exist | Create Feature branch |
| On different Feature's branch | BLOCKING: switch to main first |
| Feature was already merged (completed/adopted) | Create fresh branch from current main (see § Revisiting a Completed Feature) |

### During Feature Development (specify → verify)

All commands (`specify`, `plan`, `tasks`, `implement`, `verify`) execute on the Feature branch created by smart-sdd:
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
  roadmap.md: [Feature] → completed (or adopted — see adopt.md)
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

### Revisiting a Completed Feature (Step-Back / --start on merged Feature)

When stepping back to a previously completed and merged Feature (e.g., `/smart-sdd pipeline F001 --start specify` after F001 and F002 are both merged to main):

**Branch handling — always fresh from main**:

```bash
# 1. Delete old branch if it still exists (it's already merged, stale)
git branch -D 001-auth 2>/dev/null

# 2. Create fresh branch from current main
git checkout main
git checkout -b 001-auth
```

**Why always fresh, never rebase?** The old `001-auth` branch was created before F002 was merged. It lacks F002's code. A rebase on an already-merged branch is functionally identical to creating fresh from main — but adds complexity and risk of rebase conflicts for no benefit. Fresh creation is simpler and guarantees the branch has ALL merged Features' code.

**After branch creation**:
1. The branch contains **ALL code** (F001 + F002 + any other merged Features)
2. Re-execute the target step (e.g., specify → plan cascade)
3. Cross-Feature Impact Analysis runs (if stepping back to specify/plan)
4. Modified artifacts are committed on the `001-auth` branch
5. Merge Checkpoint merges back to main
6. Downstream Features marked 🔀 (from Impact Analysis) are processed next — each on its own fresh branch from the updated main

```
main ──F001──F002──────────────────────────────── main (after both merged)
                   │
                   └── git checkout -b 001-auth  (fresh from main, has F001+F002 code)
                       │
                       ├── step-back: modify spec → cascade → implement → verify
                       │
main ←── merge ────────┘
```

### Step Mode Branch Handling

When using Step Mode (e.g., `/smart-sdd verify F001`):
- Each command validates the current branch as described in Prerequisite Validation
- After `verify` in Step Mode, the merge step is **not** automatically triggered. The user must explicitly run the pipeline or manually merge.
- To trigger the merge for a completed Feature in Step Mode, the user can run `/smart-sdd pipeline` which will detect the completed-but-unmerged Feature and proceed with the merge Checkpoint.
