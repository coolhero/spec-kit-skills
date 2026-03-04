# Pre-Context: [Feature Name]

**Feature ID**: [F00N]
**Tier**: [Tier 1 / Tier 2 / Tier 3 (Core scope only — omit this line for Full scope)]
**Generated**: [DATE]

---

## Source Reference

**Source Root**: `$SOURCE_ROOT`

> All file paths below are **relative to Source Root**. The actual Source Root value is stored in `sdd-state.md` → `Source Path` field and resolved at runtime by smart-sdd.

### Related Original File List

| File Path | Role |
|-----------|------|
| `[relative/path/filename]` | [Role description: e.g., User model definition] |
| `[relative/path/filename]` | [Role description: e.g., Authentication middleware] |
| `[relative/path/filename]` | [Role description: e.g., Login API handler] |
| `[relative/path/filename]` | [Role description: e.g., Authentication-related tests] |

> Original sources are referenced directly from their original locations without copying.
> When proceeding with /speckit.specify and /speckit.plan, resolve each path as `[Source Root]/[File Path]` and read the files to review existing implementations.

### Reference Guide

#### [Same Stack] Implementation Reference
- Actively reference and reuse existing implementation patterns
- **Key reference points**: Design patterns, error handling approaches, test structure
- **Reusable code**:
  - `[file]:[function name]` — [Reuse rationale]
  - `[file]:[class name]` — [Reuse rationale]

#### [New Stack] Logic-Only Reference
- Reference existing code only for understanding business logic/requirements
- Do not reference implementation patterns or library usage
- **Extract**: What (what it does), Why (why it does it)
- **Ignore**: How (how it was implemented)

### Naming Remapping

> **Only present when the project identity changed** (Phase 0 Question 3). Omit this section entirely if the project name is unchanged.
> Lists code-level identifiers in this Feature's source files that contain the original project name and must be renamed in the new implementation.

| Original Identifier | Location | New Identifier | Type |
|---------------------|----------|----------------|------|
| `createCherryIn` | `src/providers/index.ts:42` | `createAngdu` | function |
| `CherryProvider` | `src/providers/cherry.ts:8` | `AngduProvider` | class |
| `cherryConfig` | `src/config/app.ts:15` | `angduConfig` | variable |
| `CHERRY_API_KEY` | `src/env.ts:3` | `ANGDU_API_KEY` | env var |
| `@cherry-in/core` | `package.json` | `@angdu/core` | package |

> **How to use**: During `/speckit.specify`, `/speckit.plan`, and `/speckit.implement`, always use the **New Identifier** column. The Original Identifier is for reference when reading the existing source code.
> If no identifiers containing the original project name were found in this Feature's source files, write "None — no original project name references in this Feature".

### Static Resources

> Non-code files used by this Feature that must be **copied from the original source** during implementation.
> These files cannot be regenerated — they must be copied as-is and placed in the appropriate location in the new project.
> Source Path is **relative to Source Root** (same as file paths above). Resolve as `[Source Root]/[Source Path]` at runtime.

| Source Path | Type | Target Path | Usage |
|-------------|------|-------------|-------|
| `[relative/path/logo.svg]` | Image | `[new/path/logo.svg]` | [e.g., App logo displayed in header] |
| `[relative/path/locales/en.json]` | i18n | `[new/path/locales/en.json]` | [e.g., English translation strings] |
| `[relative/path/fonts/custom.woff2]` | Font | `[new/path/fonts/custom.woff2]` | [e.g., Custom brand font] |

> If no static resources are associated with this Feature, write "None".
> If resources need modification (e.g., resizing images, updating translation keys), note it in the Usage column.

### Environment Variables

> Environment variables required by this Feature at runtime. Variables marked as `secret` must NOT have their actual values recorded here — only the variable name and purpose.

| Variable | Category | Required | Description | Example |
|----------|----------|----------|-------------|---------|
| `[VAR_NAME]` | [secret/config/feature-flag] | [Yes/No] | [Purpose description] | [Placeholder or example value] |

**Shared variables** (defined by other Features but also used here):

| Variable | Owner Feature | Usage in This Feature |
|----------|--------------|----------------------|
| `DATABASE_URL` | F001-auth | DB connection for user data queries |

> If this Feature introduces no new environment variables, write "None — uses only shared variables from preceding Features" or "None".

---

## For /speckit.specify

> Use the content of this section as a draft when writing spec.md.

### Existing Feature Summary

[Summarize in 2-3 sentences the role this Feature played in the existing code]

### Existing User Scenarios

| Priority | Scenario | Description |
|----------|----------|-------------|
| P1 | [Scenario name] | [User action and expected outcome] |
| P2 | [Scenario name] | [User action and expected outcome] |

### Draft Requirements (spec.md Requirements section)

- **FR-001**: [Functional requirement extracted from existing code]
- **FR-002**: [Functional requirement extracted from existing code]
- **FR-003**: [Functional requirement extracted from existing code]

### Draft Acceptance Criteria (spec.md Success Criteria section)

- **SC-001**: [Success criterion extracted from existing code. In measurable form]
- **SC-002**: [Success criterion extracted from existing code]

### Edge Cases

- [Edge case 1 handled in the existing code]
- [Edge case 2 handled in the existing code]

---

## For /speckit.plan

> Reference the content of this section when writing plan.md.

### Preceding Feature Dependencies

| Dependency Target | Dependency Type | Specific Details |
|-------------------|----------------|-----------------|
| F001-auth | Entity reference | References User entity via FK |
| F001-auth | API call | Uses authentication middleware (Bearer Token verification) |

### Related Entities (data-model.md draft)

#### Owned Entities

**[EntityName]** — Refer to the corresponding section in entity-registry.md

| Field Name | Type | Constraints | Description |
|------------|------|------------|-------------|
| [field] | [type] | [constraint] | [description] |

#### Referenced Entities (owned by other Features)

| Entity | Owner Feature | Reference Type | Purpose |
|--------|--------------|----------------|---------|
| User | F001-auth | FK (user_id) | [Purpose description] |

### Related API Contracts (contracts/ draft)

#### APIs Provided by This Feature

| Method | Path | Description |
|--------|------|-------------|
| [GET/POST/...] | [/api/...] | [Description] |

> See the corresponding section in api-registry.md for detailed schemas

#### APIs Consumed by This Feature (provided by other Features)

| Method | Path | Provider | Call Purpose |
|--------|------|----------|-------------|
| [GET/POST/...] | [/api/...] | F001-auth | [Call purpose] |

### Technical Decisions

#### [Same Stack]
- **Recommended reuse patterns**: [Patterns used in existing code and how to reuse them]
- **Existing libraries**: [Library name] — [Usage purpose]
- **Existing architecture decisions**: [Decision and rationale]

#### [New Stack]
- **Existing logic summary**: [Technology-neutral summary of existing implementation's core logic]
- **Recommended implementation approach**: [Recommended approach in the new stack]
- **Caveats**: [Migration considerations]

---

## For /speckit.analyze

> Use the content of this section for cross-Feature verification during /speckit.analyze execution.

### Cross-Feature Verification Points

| Verification Item | Target Feature | Verification Content |
|-------------------|---------------|---------------------|
| Entity compatibility | F001-auth | Verify that User entity field types match |
| API contract compatibility | F001-auth | Verify that authentication API request/response schemas match |
| Business rule consistency | F003-order | Verify that [shared rule] is applied identically on both sides |

### Impact Scope When This Feature Changes

| Impact Target | Impact Type | Description |
|---------------|------------|-------------|
| F003-order | Entity change impact | If [Entity] schema changes, F003's reference code needs modification |
| F005-cart | API change impact | If [API] response format changes, F005's calling code needs modification |
