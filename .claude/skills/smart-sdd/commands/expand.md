# Expand Command — Activate Deferred Tiers

> Reference: Read after `/smart-sdd expand` is invoked. For shared rules, see SKILL.md.

## Expand Command — Activate Deferred Tiers (Core Scope Only)

> **Note**: The expand command is only available for `core` scope projects. In `full` scope, all Features are already active — running expand will display "All Features are already active. Nothing to expand." and exit.

Running `/smart-sdd expand` activates additional Tiers that were deferred by `scope=core` during `/reverse-spec`.

### Usage

```
/smart-sdd expand              # Interactive: select which Tiers to activate
/smart-sdd expand T2           # Activate Tier 2 Features
/smart-sdd expand T2,T3        # Activate Tier 2 and Tier 3 Features
/smart-sdd expand full         # Activate all remaining deferred Features
```

### Expand Workflow

**Step 1 — Current state check**:
1. Read `sdd-state.md` → Active Tiers, deferred Features
2. If no deferred Features exist: Display "All Features are already active. Nothing to expand." and exit.
3. Display current state:

```
📊 Current Scope:
  Active Tiers: T1
  Active Features: F001-auth ✅, F002-product 🔄, F003-order (pending)
  Deferred Features: F004-cart (T2), F005-payment (T2), F006-review (T3)
```

**Step 2 — Tier selection (HARD STOP)**:
If no argument was provided, ask via AskUserQuestion:
- "Activate Tier 2 (Recommended)" — adds [N] Features
- "Activate Tier 2 + Tier 3" — adds [N] Features
- "Activate specific Features only" — select individual Features via Other input

**If response is empty → re-ask** (per MANDATORY RULE 1). Do NOT auto-select.

**Step 3 — Dependency validation**:
For each Feature being activated, verify that all its dependencies are either:
- Already completed, or
- Already active (`pending` or `in_progress`), or
- Also being activated in this expansion

If a dependency is still deferred and NOT being activated:
```
⚠️ F005-payment depends on F004-cart (deferred). F004-cart will also be activated.
```
Auto-include the dependency Feature.

**Step 4 — Apply expansion**:
1. Update `sdd-state.md`:
   - Update `Active Tiers` to the new value
   - Change matched `deferred` Features to `pending`
2. Record in Global Evolution Log: "Scope expanded: T1 → T1,T2"
3. Display completion:

```
✅ Scope expanded: T1 → T1,T2
  Activated Features:
    F004-cart (T2) → pending
    F005-payment (T2) → pending

  Next: /smart-sdd pipeline    — Resume pipeline (picks up newly activated Features)
        /smart-sdd specify F004 — Start specifying a specific Feature
```

**Decision History Recording — Scope Expansion**:
After expansion is applied, **append** to `specs/history.md`:

```markdown
---

## [YYYY-MM-DD] /smart-sdd expand

### Scope Expansion

| Decision | Details |
|----------|---------|
| Expanded | [from] → [to] (e.g., T1 → T1,T2) |
| Activated Features | [list of activated Feature IDs and names] |
```
