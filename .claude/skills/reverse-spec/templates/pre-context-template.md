# Pre-Context: [Feature Name]

**Feature ID**: [F00N]
**Tier**: [Tier 1 / Tier 2 / Tier 3 (Core scope only — omit this line for Full scope)]
**Generated**: [DATE]

---

## Runtime Exploration Results

> Observations from running the original application during `/reverse-spec` Phase 1.5.
> Extracted from `specs/reverse-spec/runtime-exploration.md` — only the `## Screen:` sections belonging to this Feature are included here.
> These provide visual and behavioral context that code reading alone cannot capture.
> If runtime exploration was skipped, write: "Skipped — [reason: environment issues | user choice]"

### App-Wide Context

- **Component library**: [from runtime-exploration.md App-Wide Observations]
- **Theme/color scheme**: [from runtime-exploration.md App-Wide Observations]

> Only include App-Wide items relevant to this Feature. Omit if not applicable.

### Screens in This Feature

> Copied from `## Screen:` sections in runtime-exploration.md whose routes belong to this Feature.
> If a screen is shared across Features, include it in the primary owner's pre-context and reference from others.

#### /route-path — [Page Title]

**Layout**: [sidebar+content / centered-form / full-width / split-pane / ...]

**UI Elements**:
- [Key elements: forms, tables, editors, modals, etc.]
- [Interactive elements: buttons, dropdowns, toggles, etc.]

**User Flows**:
| Flow | Steps | Observations |
|------|-------|--------------|
| [Flow name] | `/this-route` → [action] → `/next-route` → ... | redirects, toasts, loading states |

**Runtime Behavior**:
- **Loading states**: [skeleton, spinner, progressive, optimistic updates]
- **Empty states**: [placeholder messages, illustrations, CTAs when no data]
- **Error handling**: [validation messages, toast notifications, error boundaries]
- **Console errors**: [JS errors observed on this screen, if any]

**Notes**: [Notable patterns, special interactions, accessibility observations]

#### /another-route — [Page Title]

(... same structure per screen ...)

> If runtime exploration was skipped, write "Skipped — [reason]" for this entire section (matching the section-level skip notation above).

---

## Source Reference

**Source Root**: `$SOURCE_ROOT`

> All file paths below are **relative to Source Root**. The actual Source Root value is stored in `sdd-state.md` → `Source Path` field and resolved at runtime by smart-sdd.

### Related Original File List

| File Path | Role | Rebuild Target |
|-----------|------|----------------|
| `[relative/path/filename]` | [Role description: e.g., User model definition] | `[TBD]` |
| `[relative/path/filename]` | [Role description: e.g., Authentication middleware] | `[TBD]` |
| `[relative/path/filename]` | [Role description: e.g., Login API handler] | `[TBD]` |
| `[relative/path/filename]` | [Role description: e.g., Authentication-related tests] | `[TBD]` |

> **Rebuild Target**: Expected file path in the new project. Set to `[TBD]` during `/reverse-spec`. Populated during `/speckit.plan` when the target architecture is decided. Used during `/smart-sdd implement` to match original source files to implementation tasks.
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

### Source Behavior Inventory

> Function-level inventory of exported/public behaviors in this Feature's source files.
> Extracted during `/reverse-spec` Phase 2 to ensure no functionality is lost during rebuild.
> Each entry represents a discrete behavior that should map to one or more FR-### in spec.md.

| ID | Source File | Function/Method | Behavior Description | Priority | Origin |
|----|-------------|----------------|---------------------|----------|--------|
| B001 | `[relative/path/service.ts]` | `registerUser()` | [Creates new user account with email verification] | P1 | extracted |
| B002 | `[relative/path/service.ts]` | `loginUser()` | [Authenticates user with email/password, returns JWT] | P1 | extracted |
| B003 | `[relative/path/middleware.ts]` | `requireAuth()` | [Validates JWT token, attaches user to request] | P1 | extracted |
| B004 | `[relative/path/service.ts]` | `resetPassword()` | [Sends password reset email with time-limited token] | P2 | extracted |
| B050 | — | — | [New behavior defined during /smart-sdd add] | P2 | new |

> **ID**: Globally unique SBI identifier (B001, B002, ...) assigned sequentially across all Features during `/reverse-spec` Phase 4-2 or `/smart-sdd add` Phase 4. IDs are unique project-wide — if F001 has B001–B010, F002 starts at B011.
> **Priority**: P1 = core behavior (must implement), P2 = important (should implement), P3 = nice-to-have (can defer).
> **Origin**: `extracted` = behavior found in original source during `/reverse-spec`. `new` = behavior defined by user during `/smart-sdd add` (not in original source). NEW entries are tracked separately in coverage metrics — they do not affect original source coverage percentages.
> **How to use**: During `/speckit.specify`, ensure each P1/P2 behavior maps to at least one FR-### with `[source: B###]` tag. During `/smart-sdd verify`, check implementation coverage against this inventory. SBI coverage is tracked in `sdd-state.md` → Source Behavior Coverage section.
> If this Feature has no source files (greenfield/add without SBI), write "N/A — no source to inventory".

### UI Component Features

> **Only present for frontend/fullstack projects** with third-party UI component libraries.
> Lists user-facing capabilities provided by UI libraries that must be reproduced in the new implementation.
> These features are configured via library options/plugins — they don't appear as exported functions and would be missed by function-level analysis.
> Omit this section for backend-only, library, or CLI projects.

| Component | Library | Feature | Category |
|-----------|---------|---------|----------|
| `[ComponentName]` | `[library@version]` | [e.g., Bold/Italic/Strikethrough toolbar] | [text-formatting] |
| `[ComponentName]` | `[library@version]` | [e.g., Markdown ↔ WYSIWYG mode toggle] | [editing-mode] |
| `[ComponentName]` | custom plugin | [e.g., Wiki-link autolink `[[title]]`] | [navigation] |

> **New Stack migration note** (if applicable): For each library, suggest equivalent options in the new stack.
> **How to use**: During `/speckit.specify`, ensure each UI feature maps to an FR-###. During `/speckit.plan`, decide on the library/approach. During `/smart-sdd parity`, compare against this list.

### Interaction Behavior Inventory

> **Only present for frontend/fullstack projects** with interactive UI behaviors.
> Lists micro-interaction patterns (hover effects, tooltips, keyboard shortcuts, animations, drag-and-drop, focus management, context menus, scroll behaviors) extracted from source code analysis and runtime probing.
> These behaviors are invisible to function-level analysis (Source Behavior Inventory) and library-level analysis (UI Component Features).
> Omit this section for backend-only, library, or CLI projects.

#### Hover Behaviors

| ID | Element/Component | Trigger | Behavior | Content | Source File |
|----|-------------------|---------|----------|---------|-------------|
| `[H001]` | `[.button-primary]` | `[mouseenter]` | `[opacity change + tooltip]` | `[Tooltip: "Save document"]` | `[src/components/Button.tsx]` |

#### Keyboard Shortcuts

| ID | Shortcut | Scope | Action | Source File |
|----|----------|-------|--------|-------------|
| `[K001]` | `[Ctrl+S]` | `[global]` | `[Save current document]` | `[src/hooks/useKeyboard.ts]` |

#### Animations & Transitions

| ID | Element/Selector | Type | Properties | Duration | Trigger | Source File |
|----|------------------|------|------------|----------|---------|-------------|
| `[A001]` | `[.modal-overlay]` | `[transition]` | `[opacity]` | `[200ms ease-out]` | `[mount/unmount]` | `[src/components/Modal.tsx]` |

#### Focus Management

| ID | Element | Focus Style | Control | Tab Order | Source File |
|----|---------|-------------|---------|-----------|-------------|
| `[F001]` | `[.modal-dialog]` | `[ring-2 ring-blue-500]` | `[trapped]` | `[custom]` | `[src/components/Modal.tsx]` |

#### Drag-and-Drop

| ID | Source Element | Drop Targets | Behavior | Feedback | Source File |
|----|---------------|--------------|----------|----------|-------------|
| `[D001]` | `[.task-card]` | `[.column-container]` | `[reorder]` | `[placeholder]` | `[src/components/KanbanBoard.tsx]` |

#### Context Menus

| ID | Trigger Element | Menu Items | Source File |
|----|-----------------|------------|-------------|
| `[C001]` | `[.file-item]` | `[Open, Rename, Delete, Properties]` | `[src/components/FileList.tsx]` |

#### Scroll Behaviors

| ID | Element | Behavior | Trigger | Source File |
|----|---------|----------|---------|-------------|
| `[S001]` | `[.message-list]` | `[infinite-scroll]` | `[IntersectionObserver at bottom]` | `[src/components/ChatView.tsx]` |

> **Priority**: P1 = core interaction (must reproduce), P2 = enhancement (should reproduce), P3 = polish (can defer).
> **How to use**: During `/speckit.specify`, ensure each P1/P2 interaction maps to an FR-### or is noted as a non-functional requirement in SCs. During `/speckit.plan`, design components to support these interactions. During `/smart-sdd verify`, check interaction completeness.
> If this Feature has no micro-interactions (e.g., backend processing, data-only Feature), write "N/A — no interactive UI in this Feature".

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

> **Rebuild mode**: Non-code files used by this Feature that must be **copied from the original source** during implementation. These files cannot be regenerated — they must be copied as-is.
> **Adoption mode**: Non-code files used by this Feature that **already exist in the project** and will continue to be used as-is. Documented for reference only — no Target Path needed.
> Source Path is **relative to Source Root** (same as file paths above). Resolve as `[Source Root]/[Source Path]` at runtime.

**Rebuild mode** (include Target Path):

| Source Path | Type | Target Path | Usage |
|-------------|------|-------------|-------|
| `[relative/path/logo.svg]` | Image | `[new/path/logo.svg]` | [e.g., App logo displayed in header] |

**Adoption mode** (omit Target Path — files stay in place):

| Path | Type | Usage |
|------|------|-------|
| `[relative/path/logo.svg]` | Image | [e.g., App logo displayed in header] |

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

### Draft Success Criteria

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

### Platform Constraints from Preceding Features

> Constraints imposed by preceding Features' platform/window/environment configuration.
> These are NOT entity/API dependencies — they are runtime environment requirements
> that this Feature must respect during implementation.
> Common in Electron/Tauri/Desktop apps where window config, security policies, or IPC channels
> created by infrastructure Features affect all downstream UI Features.

| Constraint | Source Feature | Source Decision | Impact on This Feature |
|-----------|---------------|-----------------|----------------------|
| Frameless window | F001-shell | `BrowserWindow({ frame: false })` | Must implement custom titlebar with `-webkit-app-region: drag` for window dragging |
| CSP strict mode | F001-shell | `Content-Security-Policy: script-src 'self'` | Cannot use inline scripts or eval() |

> If no platform constraints from preceding Features, write "None".

### Foundation Decisions

> Framework-specific infrastructure decisions extracted during Phase 2-8 or recorded during smart-sdd init Step 3b.
> These decisions are **constraints** — implementations must conform, not override.
> Omit this section if `Framework: custom` or `Framework: none`.

**Framework**: {name}

#### Critical Decisions

| ID | Item | Decision | Confidence | Source |
|----|------|----------|------------|--------|

#### Important Decisions

| ID | Item | Decision | Confidence | Source |
|----|------|----------|------------|--------|

#### Undecided / Ambiguous

| ID | Item | Notes |
|----|------|-------|

> If no Foundation decisions apply (framework-agnostic project), write "No Foundation decisions — framework-agnostic mode."

### Foundation Dependencies

> How this Feature relates to Foundation decisions.

| Foundation Category | Dependency Type | Notes |
|---------------------|----------------|-------|

> Dependency Types:
> - **owns**: This Feature IS the Foundation for this category (T0 only)
> - **consumes**: This Feature USES Foundation decisions as constraints (T1+)
> - **extends**: This Feature adds to Foundation capabilities (rare, needs justification)
>
> If no Foundation dependencies, write "None — this Feature has no Foundation dependencies."

### Functional Enablement Chain

> Functional (not structural) dependencies between Features.
> Unlike entity/API dependencies above, these describe **runtime behavioral prerequisites** —
> "Feature X's UI must work for Feature Y to function."
> These are discovered during `/reverse-spec` Phase 3 or `/smart-sdd add` when analyzing how Features interact at runtime.

| Direction | Target Feature | Functional Dependency | Failure Impact |
|-----------|---------------|----------------------|----------------|
| Enables → | [F00N-feature] | [What this Feature provides that the target needs at runtime] | [What breaks if this doesn't work] |
| Blocked by ← | [F00N-feature] | [What this Feature needs from the source at runtime] | [What breaks if the source doesn't work] |

> Examples:
>   Enables → F005-chat: Provider settings panel works → F005 cannot configure AI providers
>   Blocked by ← F001-shell: Window frame config applied → Custom titlebar drag non-functional
>
> If no functional enablement dependencies, write "None — this Feature is functionally independent."
> For specify: Ensure SC-### cover the functional interfaces that downstream Features depend on.
> For verify: Check that functional enablement interfaces actually work at runtime.

### Feature Contracts

> Explicit guarantees, dependencies, and failure modes for cross-Feature boundaries.
> Populated during `/reverse-spec` Phase 4-2 from Phase 3-1d interaction analysis and Phase 2-3 cross-Feature rules.
> Used by `/speckit.plan` to design integration points, and by `/smart-sdd verify` Phase 2 for contract compliance checking.

#### Guarantees (what this Feature promises to consumers)

| Contract ID | Consumer Feature | Guarantee | Verification Method |
|------------|-----------------|-----------|-------------------|
| C-[FID]-G01 | [F00N-feature] | [What this Feature guarantees — e.g., "Auth middleware returns valid User object on req.user for any authenticated request"] | [How to verify — e.g., "Unit test: middleware attaches user; Integration: downstream Feature receives user object"] |

#### Dependencies (what this Feature requires from providers)

| Contract ID | Provider Feature | Dependency | Failure Impact |
|------------|-----------------|------------|----------------|
| C-[FID]-D01 | [F00N-feature] | [What this Feature requires — e.g., "Database connection pool initialized before auth queries execute"] | [What breaks — e.g., "All auth operations fail with connection refused, blocking login/register"] |

#### Failure Modes

| Contract ID | Trigger | Symptom | Blast Radius |
|------------|---------|---------|-------------|
| C-[FID]-F01 | [C-[FID]-G01 violated: e.g., Auth middleware returns null user] | [Downstream Features receive undefined user, causing TypeError on user.id access] | [All Features depending on auth — F003, F005, F007] |

> If this Feature has no cross-Feature contracts (standalone/utility), write "None — this Feature operates independently."
> For specify: Ensure SC-### cover the Guarantee verification methods.
> For plan: Design integration points that respect the Contract dependencies.
> For verify: Phase 2 checks Contract compliance; Phase 3 verifies Guarantees at runtime.

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
