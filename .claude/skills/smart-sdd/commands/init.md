# Init Command — Greenfield Project Setup

> Reference: Read after `/smart-sdd init` is invoked. For shared rules (MANDATORY RULES, argument parsing), see SKILL.md.

## Init Command — Greenfield Project Setup

Running `/smart-sdd init` sets up a new greenfield project by defining project identity and development principles, then generating the Global Evolution Layer artifacts. **Feature definition is handled separately via `/smart-sdd add`** after init completes.

### Input Sources

1. **Idea string** (positional argument): `init "Build a task management app with Kanban boards"` — brief natural language description triggers Proposal Mode
2. **PRD document** (`--prd path/to/prd.md`): Reads the PRD file and extracts project description and requirements. If the PRD is sufficiently detailed, triggers Proposal Mode
3. **Conversational input**: If no idea string and no `--prd` is specified, gathers all information through interactive Q&A with the user (original flow)

### Mode Selection

| Input | Mode | Description |
|-------|------|-------------|
| Idea string present | **Proposal Mode** | Signal Extraction → CI scoring → Proposal → auto-chain |
| `--prd` with rich detail (CI ≥ 40%) | **Proposal Mode** | PRD signals → CI scoring → Proposal → auto-chain |
| `--prd` with sparse detail (CI < 40%) | **Standard Mode** | Fall back to Phase 1 Q&A with PRD as seed |
| No arguments | **Standard Mode** | Full interactive Phase 1 Q&A |

### Proposal Mode

> Activated when an idea string or rich PRD is provided. Streamlines greenfield setup by inferring project structure from user input.
> Full CI specification: `reference/clarity-index.md`

#### Proposal Step 1: Signal Extraction + CI Scoring

1. **Parse input**: Extract keyword signals from the idea string or PRD text
2. **S0 scan**: Read S0 Signal Keywords from all `shared/domains/interfaces/*.md` and `shared/domains/concerns/*.md` modules (see `domains/_resolver.md` § Greenfield Inference)
3. **Match signals**: Map extracted keywords against S0 Primary/Secondary keywords
4. **Score CI**: Calculate Clarity Index across 7 dimensions (see `reference/clarity-index.md` § 1)
5. **Infer Domain Profile**: Build candidate Interfaces + Concerns from signal matches
6. **Infer Project Maturity & Team Context** (greenfield only — see `domains/scenarios/greenfield.md` § Configuration Parameters):
   - **Project Maturity**: Infer from CI Scale & Scope dimension:
     - CI Scale = 0–1 or keywords "personal tool", "experiment", "POC" → `prototype`
     - CI Scale = 2 or keywords "MVP", "startup", "first version" → `mvp`
     - CI Scale = 3 or keywords "enterprise", "production", "scalable" → `production`
     - Default: `mvp`
   - **Team Context**: Infer from user input keywords:
     - "team of", "large team", "multiple developers", "organization" → `large-team`
     - "small team", "pair", "2-3 developers" → `small-team`
     - No team mention → `solo` (default)
   - Store both values in sdd-state.md header after Proposal approval (see `reference/state-schema.md`)

#### Proposal Step 2: Tier-Based Routing

| CI Result | Action |
|-----------|--------|
| **Rich (≥ 70%)** | Skip to Proposal Step 3 — generate Proposal directly |
| **Medium (40–69%)** | Ask 2–3 targeted questions for the lowest-confidence dimensions, re-score, then generate Proposal |
| **Vague (15–39%)** | Ask a seed question to unlock the lowest-confidence dimension, re-score, route again |
| **Empty (< 15%)** | Ask: "What are you building and why?" — re-score, route again |

**Clarification questions**: Use the **S5 Elaboration Probes** from the inferred active modules. Pick probes from dimensions with confidence ≤ 1. Present as AskUserQuestion with concrete options (not open-ended). **If response is empty → re-ask** (per MANDATORY RULE 1).

**Re-scoring**: After each clarification, re-calculate CI. If tier improves, route to the new tier's action. Maximum 3 clarification rounds — if CI is still < 40% after 3 rounds, generate Proposal anyway with explicit Open Questions section.

#### Proposal Step 3: Generate Proposal (HARD STOP)

Generate the Proposal document (format in `reference/clarity-index.md` § 7) containing:
- **Overview**: 1–2 sentence summary
- **Clarity Index**: Score breakdown per dimension
- **Inferred Domain Profile**: Interfaces, Concerns, and rationale
- **Inferred Archetype**: Matched archetype(s) from A0 keywords or `"none"` (see `domains/_resolver.md` § S0/A0 Aggregation)
- **Proposed Features**: Extracted from signals + inferred from domain knowledge
- **Quality Rules Activated**: S1/S7 rules from active modules
- **Project Maturity**: Inferred value (`prototype`/`mvp`/`production`) with rationale
- **Team Context**: Inferred value (`solo`/`small-team`/`large-team`) with rationale
- **Open Questions**: Any CI dimensions with confidence ≤ 1

Display the Proposal and ask via AskUserQuestion:
- "Approve and continue (Recommended)" — Proceed with Proposal
- "Modify Proposal" — User adjusts specific sections
- "Switch to standard init" — Fall back to full interactive Q&A

**You MUST STOP and WAIT for the user's response. Do NOT proceed until the user explicitly approves.** **If response is empty → re-ask** (per MANDATORY RULE 1).

#### Proposal Step 3a: Modify Proposal

When the user selects "Modify Proposal" at Step 3's HARD STOP:

1. **Ask which section to modify** via AskUserQuestion:
   - "Overview / Project Description"
   - "Features (add, remove, or change)"
   - "Domain Profile (Interfaces / Concerns)"
   - "Tech Stack"
   - "Archetype"
   - "Project Maturity / Team Context"
   - "Other section"

   **If response is empty → re-ask** (per MANDATORY RULE 1).

2. **Section-specific modification rules**:

   | Section Modified | Modification Action | CI Re-score? |
   |-----------------|-------------------|--------------|
   | Overview | Free-text edit by user | Re-score Core Purpose dimension only |
   | Features | Add/remove/rename features in the table | Re-score Key Capabilities dimension |
   | Domain Profile | Add/remove interfaces or concerns | Re-score Project Type dimension + re-run S0 for added modules |
   | Tech Stack | Change/add technologies | Re-score Tech Stack dimension + re-run S0 for new tech keywords |
   | Archetype | Add/remove archetype | No CI change (archetypes are orthogonal) + re-run A0 for new keywords |
   | Target Users | Free-text edit | Re-score Target Users dimension only |
   | Scale & Scope | Free-text edit | Re-score Scale & Scope dimension only |
   | Constraints | Free-text edit | Re-score Constraints dimension only |
   | Project Maturity / Team Context | Select from `prototype`/`mvp`/`production` and `solo`/`small-team`/`large-team` | No CI change — these are greenfield scenario parameters stored in sdd-state.md |

3. **CI re-scoring rules**:
   - Only re-score affected dimension(s), not all 7
   - CI never decreases (per `reference/clarity-index.md` § 6)
   - If modification adds new S0/A0 keyword matches, update Domain Profile accordingly
   - Display updated CI after modification

4. **Signal re-extraction**: Modification does NOT re-run full signal extraction on the original input. It only processes newly added/changed text against the S0/A0 vocabulary (see `reference/clarity-index.md` § 3 Matching Algorithm). Original extraction results are preserved for unchanged sections.

5. **After modification**: Re-generate the Proposal with updated content and return to Step 3 HARD STOP (Approve / Modify / Switch to standard). Multiple modification rounds are allowed.

#### Proposal Step 4: Auto-Chain to Standard Flow

After Proposal approval:
1. **Pre-Phase**: Run Git Repository Setup (same as standard flow)
2. **Skip Phase 1**: Project Definition is already captured in the Proposal
3. **Phase 2**: Constitution Seed Definition — use Proposal's Domain Profile + tech stack to pre-fill recommended principles. Continue with standard Phase 2 flow (user selection + checkpoint)
4. **Phase 3**: Artifact Generation — use Proposal data. Write CI fields to sdd-state.md (see `reference/state-schema.md`)
5. **Phase 4**: Completion — if Proposal included Features, auto-chain to `add` with the Feature list pre-populated

---

### Standard Mode — Init Workflow

> Activated when no idea string is provided and `--prd` is sparse or absent.

#### Pre-Phase: Git Repository Setup

Before starting project setup, ensure the CWD has a git repository.

**Step 1 — Check existing git repo**:
Run `git rev-parse --is-inside-work-tree` in CWD.

- **If git repo already exists**: Skip to Step 3 (branch option).
- **If no git repo**: Proceed to Step 2.

**Step 2 — Initialize git repo**:
1. Run `git init` in CWD
2. Create a `.gitignore` with sensible defaults:
   - Always include: `node_modules/`, `.env`, `.env.*`, `__pycache__/`, `*.pyc`, `.DS_Store`, `dist/`, `build/`, `.venv/`, `venv/`
   - Add stack-specific entries if the user already specified the tech stack (from `--prd` or conversation)
3. Display: "Git repository initialized with .gitignore"

**Step 3 — Branch option (HARD STOP)**:
Ask the user via AskUserQuestion whether to work on the current branch or create a dedicated branch:
- "Stay on current branch (Recommended)" — Continue on the current branch (usually `main`)
- "Create a new branch" — Create and checkout a new branch for the SDD work

**If response is empty → re-ask** (per MANDATORY RULE 1). If the user selects "Create a new branch", ask for the branch name via "Other" input (suggest `sdd-setup` as default).

**Step 4 — Auto-initialize case study logging**:
Check if `case-study-log.md` exists at project root:
- **If not exists**: Read [`case-study-log-template.md`](../../case-study/templates/case-study-log-template.md) and write it to `case-study-log.md`. Display: `Case study log initialized: case-study-log.md`
- **If already exists**: Skip silently

#### Phase 1: Project Definition

1. **If `--prd` is provided**: Read the PRD document and extract:
   - Project name and description
   - Target domain
   - Technical requirements or constraints (if mentioned)
   - Present the extracted information to the user for confirmation/adjustment

2. **If no `--prd`**: Ask the user:
   - Project name
   - Project description (what problem it solves, target users)
   - Domain (e-commerce, SaaS, CMS, education platform, etc.)
   - Target architecture type (monolithic, microservice, etc.)
   - Tech stack (language, framework, DB, testing framework)

#### Step 3b. Framework Selection & Foundation Decisions

1. **Determine framework source** based on project state:

   | Condition | Source | Action |
   |-----------|--------|--------|
   | **Proposal Mode** (idea string / PRD) | User input signals | Extract framework from Tech Stack CI dimension. If confidence ≥ 2, infer from matched S0 keywords (e.g., `React` → `react`, `Hono` → `hono`). If confidence ≤ 1, ask user directly |
   | **Standard Mode + existing project files** | File system scan | Auto-detect from project files using R7 heuristics (see `../../reverse-spec/domains/_core.md` § R7) |
   | **Standard Mode + empty directory** | Phase 1 Q&A answers | Use the tech stack answer from Phase 1 |
   | **`--prd` with explicit tech stack** | PRD document | Extract from PRD content |

   > In true greenfield (empty directory), there are no project files to scan. The framework comes from user input, not file detection. Step 2 (user confirmation) still applies regardless of source.

2. **Confirm with user via AskUserQuestion**:
   - Detected: "{framework}" — Is this correct?
   - Options: "Confirm {framework}", "Select different framework", "Custom (no Foundation)"
   **If response is empty → re-ask** (per MANDATORY RULE 1)

3. **Load Foundation checklist** from `../../reverse-spec/domains/foundations/{framework}.md`
   - If Foundation file exists (Case A): Load full F2 items
   - If no Foundation file (Case B): Load universal categories from `../../reverse-spec/domains/foundations/_foundation-core.md` § F1 and present generic probes
   - If "Custom" selected (Case D): Skip Foundation entirely, record `Framework: custom`

4. **Present Critical items via AskUserQuestion** (grouped by category):
   - For each Foundation category with Critical items:
     - Show item name, description, decision type + available options
     - User selects/confirms each decision
   **If response is empty → re-ask** (per MANDATORY RULE 1)

5. **Record in sdd-state.md**:
   - `**Framework**:` field in header section
   - `## Foundation Decisions` section with decided items table

6. **Generate T0 Feature candidates** from Foundation categories:
   - Each Foundation category with >= 1 Critical item requiring code → T0 Feature candidate
   - Apply T0 Feature Grouping rules from `../../reverse-spec/domains/foundations/_foundation-core.md` § F3
   - Present candidates to user via AskUserQuestion for selection
   **If response is empty → re-ask** (per MANDATORY RULE 1)
   - Selected candidates become T0 Features in the roadmap

> Note: If `Framework: custom` or `Framework: none`, this entire step is skipped.

#### Phase 2: Constitution Seed Definition

1. **Present the 6 Best Practices** with descriptions:
   - I. Test-First (NON-NEGOTIABLE) — Write tests first. Code without tests is not complete
   - II. Think Before Coding — No assumptions. Mark unclear items as `[NEEDS CLARIFICATION]`
   - III. Simplicity First — Implement only what is in the spec. No speculative additions
   - IV. Surgical Changes — No "improving" adjacent code. Only clean up own changes
   - V. Goal-Driven Execution — Verifiable completion criteria required
   - VI. Demo-Ready Delivery — Each Feature must be demonstrable upon completion. "Tests pass" alone is NOT sufficient. Provide an **executable demo script** at `demos/F00N-name.sh` (or `.ts`/`.py`/etc.) that **launches the real, working Feature** so the user can experience it firsthand (browse the UI, call the API, use the CLI). Default = interactive (keep running), `--ci` = health check for verify automation. The script **maps to spec.md's FR-###/SC-###** to show what the user can try

2. **User selection**: All 6 are selected by default. The user can:
   - Deselect specific practices
   - Modify descriptions
   - Add custom principles (with Rule + Rationale format)

3. **Project conventions**: Ask for project-specific conventions:
   - Naming conventions
   - Project structure conventions
   - Error handling patterns
   - Testing patterns

4. **Checkpoint (HARD STOP)**: Display the complete constitution-seed content. Use AskUserQuestion with options: "Approve as-is", "Request modifications" (per PROCEDURE CheckpointApproval in pipeline.md). **You MUST STOP and WAIT for the user's response. Do NOT proceed to Phase 3 until the user explicitly approves.** **If response is empty → re-ask** (per MANDATORY RULE 1).

**Decision History Recording — Constitution**:
After the user approves the Phase 2 Checkpoint, **append** to `specs/history.md` (create with the standard header if it doesn't exist — see SKILL.md § History File Header):

```markdown
---

## [YYYY-MM-DD] /smart-sdd init — Project Setup

### Constitution

| Decision | Details |
|----------|---------|
| Best Practices | [e.g., "All 6 adopted" or "5 adopted, excluded: Demo-Ready Delivery"] |
| Custom Principles | [any custom principles added, or "None"] |
```

#### Phase 3: Artifact Generation

Generate all artifacts at BASE_PATH (defaults to `./specs/reverse-spec/`):

1. **`roadmap.md`**: Using the roadmap template format
   - Project Overview: From Phase 1 input
   - "Development Strategy" section (instead of "Rebuild Strategy"): "Greenfield — new project, no existing codebase"
   - Feature Catalog: Empty — note: "Features will be defined via `/smart-sdd add`"
   - Dependency Graph: Empty
   - Release Groups: Empty — note: "Release groups will be populated as Features are added"
   - Cross-Feature Entity/API Dependencies: Empty (populated as Features are planned)

2. **`constitution-seed.md`**: Using the constitution-seed template format
   - Source Code Reference Principles: "N/A — Greenfield project. No existing source code to reference."
   - Architecture Principles: From user input (if any), otherwise "Define as the project evolves"
   - Technical Constraints: From user input (if any)
   - Coding Conventions: From user input (if any)
   - Project-Specific Recommended Principles: Derive from active signal matches and CI dimensions using the Principle Recommendation Table below. Each principle maps from a signal source (active module, CI dimension, domain keyword) to a concrete rule + rationale

#### Principle Recommendation Table

> Signal-driven principle selection for greenfield constitution-seed. Apply all rows where the "Signal Match" condition is true based on the current project's CI scoring and active S0/A0 modules.

| Signal Source | Signal Match | Recommended Principle | Rationale |
|--------------|-------------|----------------------|-----------|
| **Domain signals** | | | |
| Core Purpose keywords | payment, checkout, cart, order, e-commerce | Payment Idempotency, Inventory Consistency | Double-charge and oversell prevention |
| Core Purpose keywords | patient, medical, health, HIPAA, PHI | Encryption at Rest, Audit Logging | Healthcare compliance requirement |
| Core Purpose keywords | tenant, multi-tenant, subscription, SaaS | Tenant Data Isolation | Data leak prevention between tenants |
| Core Purpose keywords | transaction, ledger, accounting, finance | Double-Entry Consistency, Audit Trail | Financial data integrity |
| Core Purpose keywords | chat, messaging, collaboration | Message Ordering Guarantee | Conversation coherence |
| **Active concern modules** | | | |
| `realtime` concern active | WebSocket, SSE, live updates | Optimistic UI Updates, Reconnection Strategy | UX responsiveness under network variance |
| `external-sdk` concern active | third-party API, SDK | Contract Testing, Retry with Backoff | Integration resilience against external failures |
| `external-sdk` + webhook signal | webhook, callback URL | Webhook Idempotency, Retry-safe Handlers | Prevent duplicate processing from webhook retries |
| `auth` concern active | JWT, OAuth, login | Secure Token Storage, Session Timeout Policy | Security baseline for user data |
| `i18n` concern active | multi-language, localization | String Externalization, RTL-safe Layout | Internationalization readiness from day one |
| **Active archetype modules** | | | |
| `ai-assistant` archetype active | LLM, AI, chatbot | Streaming-First, Model Agnosticism, Token Budget Awareness | AI-specific quality guarantees |
| `public-api` archetype active | OpenAPI, developer portal | Semantic Versioning, Rate Limiting, Deprecation Policy | API consumer trust |
| `microservice` archetype active | gRPC, distributed, containers | Circuit Breaker, Distributed Tracing, Idempotent Operations | Fault isolation in distributed systems |
| **Scale signals** | | | |
| CI Scale ≥ 2 | enterprise, high-traffic, production | Rate Limiting, Cache Strategy, Horizontal Scalability | Performance under load |
| CI Scale ≤ 1 | personal tool, prototype, MVP | Start Simple (YAGNI), No Premature Optimization | Avoid over-engineering early |
| **Interface signals** | | | |
| `data-io` interface active | pipeline, ETL, batch | Idempotent Processing, Checkpoint/Resume | Data integrity in long-running jobs |
| `cli` interface active | CLI, command-line | Graceful Degradation, Meaningful Exit Codes | Developer experience in automation |
   - Best Practices: From Phase 2 selections
   - Global Evolution Layer Operational Principles: Always included

3. **`entity-registry.md`**: Empty registry with headers only
   - Note: "Entities will be populated as Features are planned via speckit-plan."

4. **`api-registry.md`**: Empty registry with headers only
   - Note: "Endpoints will be populated as Features are planned via speckit-plan."

5. **`sdd-state.md`**: Initialize with Origin: `greenfield`, Scope: `full`, Feature Progress table empty (no Features defined yet — Features will be added via `/smart-sdd add`).
   - **Org Convention**: Ask via AskUserQuestion: "Do you have an organization convention file?" with options:
     - "Yes — specify path" → record path in `**Org Convention**` field
     - "No" → set `**Org Convention**: none`
   - **If response is empty → re-ask** (per MANDATORY RULE 1)
   - Common path pattern: `~/.claude/domain-conventions/{org-name}.md`

6. **Not generated**: `business-logic-map.md` (no existing logic to map), `stack-migration.md` (no existing stack), per-Feature `pre-context.md` (created by `/smart-sdd add`)

#### Phase 4: Completion + Feature Definition Prompt

Display the completion report:

```
✅ Greenfield project initialized:

  specs/reverse-spec/roadmap.md
  specs/reverse-spec/constitution-seed.md
  specs/reverse-spec/entity-registry.md (empty — populated during plan)
  specs/reverse-spec/api-registry.md (empty — populated during plan)
  specs/reverse-spec/sdd-state.md
  case-study-log.md
```

Then ask the user via AskUserQuestion whether to define Features now:
- "Define Features now (Recommended)" — Chain into `/smart-sdd add` flow immediately
- "Later — I'll run /smart-sdd add separately" — Show completion message and stop

**If response is empty → re-ask** (per MANDATORY RULE 1).

**If "Define Features now"**:
- If `--prd` was provided to init: pass the same PRD path to the add flow (triggers Phase 1 Type 1 — Document-based Feature extraction)
- If no `--prd`: enter add flow in conversational mode (Phase 1 Type 2 — Conversational)
- Transition directly into the add command's Phase 1. The agent reads `commands/add.md` and continues execution without requiring the user to type `/smart-sdd add`

**If "Later"**:
```
✅ Project initialized!

💡 When you're ready, type "continue" or run one of:
  /smart-sdd add                — Define your first Feature(s)
  /smart-sdd constitution       — Finalize the constitution first (optional)
```

