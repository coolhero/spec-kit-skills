# Parity Command — Brownfield Source Parity Check

> Reference: Read after `/smart-sdd parity` is invoked. For shared rules, see SKILL.md.
> For domain-specific parity dimensions, also read `domains/{domain}.md` § Parity Dimensions.

## Parity Command — Brownfield Source Parity Check

Running `/smart-sdd parity` compares the original source code against implemented Features to identify functionality gaps after the pipeline completes. This is a utility command — it does NOT follow the Common Protocol (Assemble → Checkpoint → Execute+Review → Update) but has its own multi-phase workflow.

### Prerequisites

- **Origin must be `rebuild`**: Parity checking is only available for brownfield rebuild projects. If Origin in sdd-state.md is not `rebuild` (e.g., `greenfield` or `adoption`), display: "⚠️ Parity check is only available for brownfield rebuild projects (Origin: rebuild)." and exit.
- **At least one Feature must be `completed`** in sdd-state.md.
- **`coverage-baseline.md` is optional but recommended**: If present at `BASE_PATH/coverage-baseline.md`, intentional exclusions will be filtered from the gap list. If missing, parity still runs but without exclusion filtering — display a note: "ℹ️ coverage-baseline.md not found. Run `/reverse-spec` with Phase 4-3 to generate it, or all source items will be treated as expected."

### Source Path Resolution

The original source path is resolved in this priority order:

1. `--source <path>` argument (if provided)
2. `Source Path` field from `sdd-state.md`
3. If neither is available: use AskUserQuestion to prompt the user for the path

**Verification**: Before proceeding, verify the resolved source path exists and is accessible. If not found, display error and ask user to provide a valid path.

### Phase 1: Structural Parity (Automated)

Parse the original source and compare against implemented code.

**Step 1 — Source parsing**: Reuse reverse-spec Phase 2 tech-stack-specific detection patterns to parse:
- All API endpoints (route definitions, controllers, decorators)
- All DB models/entities (ORM models, schema definitions)
- All route registrations (pages, views)
- All test files
- All UI component features (from Phase 2-7 — library configs, toolbar items, plugins, editing modes)
- All source behaviors (from Phase 2-6 — exported functions, public methods, handlers)

**Step 2 — Implementation inventory**:
- Read `BASE_PATH/api-registry.md` for all defined endpoints
- Read `BASE_PATH/entity-registry.md` for all defined entities
- Read pre-context.md "UI Component Features" sections for all Features (if present)
- Scan implemented source code on the main branch for actually implemented endpoints, entities, routes, UI component features

**Step 3 — Exclusion filtering**:
- If `BASE_PATH/coverage-baseline.md` exists: read the Intentional Exclusions table
- Remove all items marked with any exclusion reason from the gap list
- Items marked as `deferred` are excluded from the gap count but listed separately as "Deferred items"

**Step 4 — Display metrics**:

```
📊 Structural Parity: [Project Name]
   Source: [resolved source path]

| Category            | Original | Implemented | Excluded | Gap | Parity  |
|---------------------|----------|-------------|----------|-----|---------|
| API endpoints       | 45       | 42          | 1        | 2   | 95.6%   |
| DB entities         | 20       | 18          | 1        | 1   | 94.7%   |
| Routes/pages        | 38       | 35          | 2        | 1   | 97.2%   |
| UI component features | 12     | 4           | 0        | 8   | 33.3%   |
| Source behaviors    | 85       | 72          | 3        | 10  | 87.8%   |
| Test files          | 30       | 25          | 0        | 5   | 83.3%   |

Deferred items (from coverage-baseline.md): 12 endpoints, 3 entities
```

### Phase 2: Logic Parity (Semi-Automated)

**Step 1 — Business rule comparison**:
- Read `BASE_PATH/business-logic-map.md` for all extracted rules (skip if file does not exist — greenfield origin or no rules extracted)
- For each rule, check if the implementing Feature's `SPEC_PATH/{NNN-feature}/spec.md` contains a corresponding FR-### that maps to the rule
- A rule is "covered" if a FR-### in the responsible Feature's spec.md addresses the same behavior

**Step 2 — Test case comparison**:
- Parse original test files to extract test case names/descriptions (using `describe`/`it`/`test` patterns, or language-specific equivalents)
- Compare against implemented test files in the new codebase
- A test case is "covered" if a test with similar intent exists (name matching + behavior description comparison)

**Step 3 — Display metrics**:

```
📊 Logic Parity:

| Category        | Original | Covered | Gap | Parity |
|-----------------|----------|---------|-----|--------|
| Business rules  | 42       | 38      | 4   | 90.5%  |
| Test cases      | 120      | 98      | 22  | 81.7%  |
```

### Phase 3: Gap Report Generation

Generate `BASE_PATH/parity-report.md` with the following structure:

```markdown
# Parity Report

**Source**: [source path]
**Generated**: [DATE]
**Overall Parity**: Structural [X%] | Logic [Y%]

---

## Summary

| Category | Original | Implemented | Excluded | Gap | Parity |
|----------|----------|-------------|----------|-----|--------|
| [per category row] | ... | ... | ... | ... | ... |

---

## Gaps

### Structural Gaps

| # | Category | Item | Original Location | Related Feature | Group |
|---|----------|------|-------------------|-----------------|-------|
| G-001 | endpoint | DELETE /admin/users/:id | src/routes/admin.ts:42 | F001-auth | A |
| G-002 | entity | AuditLog | src/models/audit.ts:1 | (cross-cutting) | B |

### Logic Gaps

| # | Category | Rule/Test | Original Location | Related Feature | Group |
|---|----------|-----------|-------------------|-----------------|-------|
| G-003 | business-rule | "Discount caps at 50%" | src/services/pricing.ts:88 | F005-pricing | C |
| G-004 | test-case | "should handle timeout" | tests/api/reports.test.ts:45 | F003-reports | C |

---

## Suggested Grouping

| Group | Scope | Suggested Action | Gaps |
|-------|-------|-----------------|------|
| A | F001-auth scope | New Remediation Feature | G-001 |
| B | Cross-cutting | Infrastructure Feature + constitution update | G-002 |
| C | F003-reports + F005-pricing | New Remediation Feature | G-003, G-004 |

---

## Intentional Exclusions Applied

[Items from coverage-baseline.md that were filtered out during this parity check]

---

## Deferred Items

[Items from coverage-baseline.md marked as `deferred` — not counted as gaps but listed for reference]
```

**Auto-grouping logic**:
1. Gaps that belong to the same Feature scope → one group
2. Gaps that are cross-cutting (affect multiple Features or no single Feature) → "infrastructure" group
3. Test case gaps → grouped with the Feature they test
4. Single-item gaps → either standalone or merged into the closest group

### Phase 4: Remediation Plan (HARD STOP per group)

Present the gap groups to the user and ask for a decision per group:

```
📋 Remediation Plan:

── Group A: F001-auth scope (1 gap) ──────────
  G-001: DELETE /admin/users/:id (endpoint)

  Suggested: New Remediation Feature
```

Use AskUserQuestion per group with options:

- **"Create new Feature"** → Invoke the `add` workflow with pre-populated Feature definition:
  - Feature name derived from group scope (e.g., "F010-auth-parity")
  - Description includes the gap items as draft requirements
  - Dependencies derived from related existing Features
  - Pre-context.md populated with gap details and source references

- **"Add to existing Feature [FID]"** → Update the Feature's pre-context.md with additional requirements from the gaps. Mark the Feature's pipeline steps with 🔀 from specify onward in sdd-state.md. The Feature will need to re-run specify → plan → tasks → implement → verify.

- **"Intentional exclusion"** → Record in parity-report.md with one of 6 exclusion reasons (`deprecated`, `replaced`, `third-party`, `deferred`, `out-of-scope`, `covered-differently`). Also update coverage-baseline.md if it exists.

- **"Defer"** → Create a new Feature via the `add` workflow with Tier 3 (or user-specified Tier). The Feature status is set to `deferred` (🔒) if outside Active Tiers. Record in parity-report.md as deferred with a link to the new Feature.

**You MUST STOP and WAIT for the user's response for each group. Empty/blank response = NOT decided — re-ask.**

**Cross-cutting group special handling**: When a group is classified as cross-cutting:
1. Propose constitution update — add architectural principle (e.g., "All API endpoints must implement rate limiting")
2. Create an infrastructure Feature via the `add` workflow (e.g., "F010-infrastructure-parity")
3. Both actions happen together — constitution for the principle, Feature for the implementation

### Phase 5: Completion Report

```
✅ Parity check completed:

📊 Final Parity: Structural [X%] | Logic [Y%]

Gaps found: [N total]
  → New Features created: [N] (ready for /smart-sdd pipeline)
  → Added to existing Features: [N] (marked 🔀 for re-execution)
  → Intentional exclusions: [N] (recorded in parity-report.md)
  → Deferred: [N] (added to roadmap.md)

Generated: specs/reverse-spec/parity-report.md
Updated: specs/reverse-spec/sdd-state.md

Next steps:
  /smart-sdd pipeline       — Resume pipeline for new/modified Features
  /smart-sdd status         — View updated progress
```

**Decision History Recording — Parity Remediation**:
After Phase 5 completes, **append** to `specs/history.md`:

```markdown
---

## [YYYY-MM-DD] /smart-sdd parity — Gap Remediation

### Parity Decisions

| Group | Decision | Details |
|-------|----------|---------|
| [Group name] | Create new Feature / Add to [FID] / Exclude ([reason]) / Defer | [gap summary] |
```

One row per group decision from Phase 4.

### `--auto` Mode

When `--auto` is specified:
- Phases 1-3 (automated analysis and report generation) proceed normally
- Phase 4 HARD STOPs are skipped:
  - Groups are auto-assigned based on the suggested grouping in Phase 3
  - "Create new Feature" for groups with a clear Feature scope
  - "Create infrastructure Feature" for cross-cutting groups (constitution update included)
  - No gaps are auto-excluded (conservative: all gaps are treated as actionable)
- Phase 5 displays the results as usual

### `--dangerously-skip-permissions` handling

Same handling as other commands: AskUserQuestion replaced with text messages. Classification prompts display options as regular text and wait for text response.
