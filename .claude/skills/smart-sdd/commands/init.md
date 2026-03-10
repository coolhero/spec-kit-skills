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
2. **S0 scan**: Read S0 Signal Keywords from all `domains/interfaces/*.md` and `domains/concerns/*.md` modules (see `domains/_resolver.md` § Greenfield Inference)
3. **Match signals**: Map extracted keywords against S0 Primary/Secondary keywords
4. **Score CI**: Calculate Clarity Index across 7 dimensions (see `reference/clarity-index.md` § 1)
5. **Infer Domain Profile**: Build candidate Interfaces + Concerns from signal matches

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
- **Proposed Features**: Extracted from signals + inferred from domain knowledge
- **Quality Rules Activated**: S1/S7 rules from active modules
- **Open Questions**: Any CI dimensions with confidence ≤ 1

Display the Proposal and ask via AskUserQuestion:
- "Approve and continue (Recommended)" — Proceed with Proposal
- "Modify Proposal" — User adjusts specific sections
- "Switch to standard init" — Fall back to full interactive Q&A

**You MUST STOP and WAIT for the user's response. Do NOT proceed until the user explicitly approves.** **If response is empty → re-ask** (per MANDATORY RULE 1).

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
   - Project-Specific Recommended Principles: Based on the domain and tech stack from Phase 1 (e.g., e-commerce → Inventory Consistency, Payment Idempotency; SaaS → Tenant Isolation; real-time → Optimistic Updates). Use the recommendation categories in the constitution-seed template as a guide
   - Best Practices: From Phase 2 selections
   - Global Evolution Layer Operational Principles: Always included

3. **`entity-registry.md`**: Empty registry with headers only
   - Note: "Entities will be populated as Features are planned via speckit-plan."

4. **`api-registry.md`**: Empty registry with headers only
   - Note: "Endpoints will be populated as Features are planned via speckit-plan."

5. **`sdd-state.md`**: Initialize with Origin: `greenfield`, Scope: `full`, Feature Progress table empty (no Features defined yet — Features will be added via `/smart-sdd add`)

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

