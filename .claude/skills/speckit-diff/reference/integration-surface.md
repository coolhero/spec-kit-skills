# Spec-Kit Integration Surface Baseline

**Baseline Date**: 2026-03-02
**Spec-Kit Commit**: (unknown — extracted from installed files, not from repo)
**Note**: spec-kit has no explicit version field. Identification relies on GitHub commit hash (when available) + structural signatures. All data is self-contained — no external directory references required.
**Next Update**: After running `/speckit-diff`, update this baseline with the latest commit hash and any structural changes.

---

## Known Skills

| Skill Name | Source Template | Key Sections | Scripts Invoked | Output Artifacts |
|------------|---------------|--------------|-----------------|------------------|
| speckit-constitution | templates/commands/constitution.md | Outline, Formatting & Style Requirements | (none) | .specify/memory/constitution.md |
| speckit-specify | templates/commands/specify.md | Outline, General Guidelines, Quick Guidelines, Section Requirements, For AI Generation, Success Criteria Guidelines | create-new-feature.sh --json | specs/{NNN}/spec.md, checklists/requirements.md |
| speckit-clarify | templates/commands/clarify.md | Outline, Behavior rules, Context for prioritization | check-prerequisites.sh --json --paths-only | specs/{NNN}/spec.md (Clarifications section) |
| speckit-plan | templates/commands/plan.md | Outline, Phases (Phase 0, Phase 1, Phase 2), Key rules | setup-plan.sh --json, update-agent-context.sh claude | plan.md, research.md, data-model.md, contracts/, quickstart.md |
| speckit-tasks | templates/commands/tasks.md | Outline, Task Generation Rules, Checklist Format (REQUIRED), Task Organization, Phase Structure | check-prerequisites.sh --json | tasks.md |
| speckit-analyze | templates/commands/analyze.md | Goal, Operating Constraints, Execution Steps, Operating Principles, Context | check-prerequisites.sh --json --require-tasks --include-tasks | Analysis report (stdout) |
| speckit-implement | templates/commands/implement.md | Outline, Implementation execution rules | check-prerequisites.sh --json --require-tasks --include-tasks | Source code + tasks.md [x] marks |
| speckit-checklist | templates/commands/checklist.md | Checklist Purpose, Execution Steps, Example Checklist Types & Sample Items, Anti-Examples | check-prerequisites.sh --json | checklists/{domain}.md |
| speckit-taskstoissues | templates/commands/taskstoissues.md | Outline | check-prerequisites.sh --json --require-tasks --include-tasks | GitHub Issues |

### Skill Frontmatter Schema

All skills share this frontmatter structure:

```yaml
name: speckit-{command}
description: ...
compatibility: Requires spec-kit project structure with .specify/ directory
metadata:
  author: github-spec-kit
  source: templates/commands/{command}.md
```

---

## Known Templates

### spec-template.md

**Section Headers**:
- `# Feature Specification: [FEATURE NAME]`
- `## User Scenarios & Testing` *(mandatory)*
  - `### User Story N - [Brief Title] (Priority: P#)`
    - `#### Acceptance Scenarios`
  - `### Edge Cases`
- `## Requirements` *(mandatory)*
  - `### Functional Requirements`
  - `### Key Entities`
- `## Success Criteria` *(mandatory)*
  - `### Measurable Outcomes`

**Format Patterns**: FR-###, SC-###, P1/P2/P3, Given/When/Then, `[NEEDS CLARIFICATION: ...]`

**Placeholder Tokens**: `[FEATURE NAME]`, `[###-feature-name]`, `[DATE]`, `[Brief Title]`, `[initial state]`, `[action]`, `[expected outcome]`, `[Entity 1]`, `[Entity 2]`

### plan-template.md

**Section Headers**:
- `# Implementation Plan: [FEATURE]`
- `## Summary`
- `## Technical Context`
- `## Constitution Check`
- `## Project Structure`
  - `### Documentation (this feature)`
  - `### Source Code (repository root)`
- `## Complexity Tracking`

**Format Patterns**: Language/Version, Primary Dependencies, Storage, Testing, Target Platform, Project Type, Performance Goals, Constraints, Scale/Scope fields

**Placeholder Tokens**: `[FEATURE]`, `[###-feature-name]`, `[DATE]`, `[NEEDS CLARIFICATION]`, `[REMOVE IF UNUSED]`

### tasks-template.md

**Section Headers**:
- `# Tasks: [FEATURE NAME]`
- `## Format: [ID] [P?] [Story] Description`
- `## Path Conventions`
- `## Phase 1: Setup (Shared Infrastructure)`
- `## Phase 2: Foundational (Blocking Prerequisites)`
- `## Phase 3: User Story 1 - [Title] (Priority: P1)`
  - `### Goal`, `### Independent Test`, `### Tests for User Story 1`, `### Implementation for User Story 1`
- `## Phase N: Polish & Cross-Cutting Concerns`
- `## Dependencies & Execution Order`
- `## Implementation Strategy`
- `## Notes`

**Format Patterns**: `- [ ] T### [P] [US#] Description`, Task IDs T001-T999, [P] parallelizable, [US1]/[US2]/[US3] story labels

**Placeholder Tokens**: `[FEATURE NAME]`, `[###-feature-name]`, `[ID]`, `[TaskID]`, `[Title]`, `[TXXX]`, `[REMOVE IF UNUSED]`

### constitution-template.md

**Section Headers**:
- `# [PROJECT_NAME] Constitution`
- `## Core Principles`
  - `### [PRINCIPLE_1_NAME]` through `### [PRINCIPLE_5_NAME]`
- `## [SECTION_2_NAME]`
- `## [SECTION_3_NAME]`
- `## Governance`

**Format Patterns**: MAJOR.MINOR.PATCH semantic versioning, YYYY-MM-DD dates

**Placeholder Tokens**: `[PROJECT_NAME]`, `[PRINCIPLE_#_NAME]`, `[PRINCIPLE_#_DESCRIPTION]`, `[SECTION_#_NAME]`, `[CONSTITUTION_VERSION]`, `[RATIFICATION_DATE]`, `[LAST_AMENDED_DATE]`

### checklist-template.md

**Section Headers**:
- `# [CHECKLIST TYPE] Checklist: [FEATURE NAME]`
- `## [Category 1]`
- `## [Category 2]`
- `## Notes`

**Format Patterns**: `- [ ] CHK### item [Category]`, CHK001-CHK999

**Placeholder Tokens**: `[CHECKLIST TYPE]`, `[FEATURE NAME]`, `[DATE]`, `[Category 1]`, `[Category 2]`

### agent-file-template.md

**Section Headers**:
- `# [PROJECT NAME] Development Guidelines`
- `## Active Technologies`
- `## Project Structure`
- `## Commands`
- `## Code Style`
- `## Recent Changes`

**Format Patterns**: `<!-- MANUAL ADDITIONS START -->` / `<!-- MANUAL ADDITIONS END -->`, `Last updated: [DATE]`

**Placeholder Tokens**: `[PROJECT NAME]`, `[DATE]`, `[EXTRACTED FROM ALL PLAN.MD FILES]`

---

## Known Scripts

### create-new-feature.sh

**CLI Flags**: `--json`, `--short-name <name>`, `--number N`, `--help`
**JSON Output Fields**: `BRANCH_NAME`, `SPEC_FILE`, `FEATURE_NUM`
**Key Behavior**: Creates git branch `{NNN}-{short-name}`, copies spec-template.md to specs/{NNN}/spec.md

### check-prerequisites.sh

**CLI Flags**: `--json`, `--require-tasks`, `--include-tasks`, `--paths-only`, `--help`
**JSON Output Fields**:
- Default mode: `FEATURE_DIR`, `AVAILABLE_DOCS`
- Paths-only mode: `REPO_ROOT`, `BRANCH`, `FEATURE_SPEC`, `IMPL_PLAN`, `TASKS`
**Key Behavior**: Validates feature branch, checks file existence, returns available docs

### setup-plan.sh

**CLI Flags**: `--json`, `--help`
**JSON Output Fields**: `FEATURE_SPEC`, `IMPL_PLAN`, `SPECS_DIR`, `BRANCH`, `HAS_GIT`
**Key Behavior**: Copies plan-template.md to feature directory

### update-agent-context.sh

**Positional Argument**: agent_type (claude|gemini|copilot|cursor-agent|qwen|opencode|codex|windsurf|kilocode|auggie|roo|codebuddy|qodercli|amp|shai|q|agy|bob|generic)
**Key Behavior**: Extracts Technical Context fields from plan.md, generates/updates agent-specific context files (CLAUDE.md, GEMINI.md, etc.)
**Extracted Plan Fields**: Language/Version, Primary Dependencies, Storage, Testing, Target Platform, Project Type, Performance Goals, Constraints, Scale/Scope

### common.sh

**Functions**: `get_repo_root()`, `get_current_branch()`, `has_git()`, `check_feature_branch()`, `get_feature_dir()`, `find_feature_dir_by_prefix()`, `get_feature_paths()`, `check_file()`, `check_dir()`
**JSON Output Fields**: `REPO_ROOT`, `CURRENT_BRANCH`, `HAS_GIT`, `FEATURE_DIR`, `FEATURE_SPEC`, `IMPL_PLAN`, `TASKS`, `RESEARCH`, `DATA_MODEL`, `QUICKSTART`, `CONTRACTS_DIR`

---

## Known CLI

**Binary**: `specify`
**Install**: `uv tool install specify-cli --from git+https://github.com/github/spec-kit.git`
**Commands**: `init`
**Init Flags**: `--here`, `--ai claude`, `--force`, `--no-git`, `--ai-skills`
**Init Effect**: Creates `.specify/` directory with templates, scripts, memory; installs skills to `.claude/skills/speckit-*/`

---

## Known Directory Structure

```
.specify/
  memory/
    constitution.md
  templates/
    spec-template.md
    plan-template.md
    tasks-template.md
    constitution-template.md
    checklist-template.md
    agent-file-template.md
  scripts/bash/
    common.sh
    create-new-feature.sh
    check-prerequisites.sh
    setup-plan.sh
    update-agent-context.sh

.claude/skills/
  speckit-constitution/SKILL.md
  speckit-specify/SKILL.md
  speckit-clarify/SKILL.md
  speckit-plan/SKILL.md
  speckit-tasks/SKILL.md
  speckit-analyze/SKILL.md
  speckit-implement/SKILL.md
  speckit-checklist/SKILL.md
  speckit-taskstoissues/SKILL.md

specs/{NNN-feature-name}/
  spec.md
  plan.md
  tasks.md
  research.md          (optional)
  data-model.md        (optional)
  quickstart.md        (optional)
  contracts/           (optional)
  checklists/
    requirements.md
    {domain}.md        (optional)
```

---

## Workflow Sequence

```
speckit-constitution  (one-time project setup)
     ↓
speckit-specify       → creates branch + spec.md
     ↓
speckit-clarify       (optional, if ambiguities detected)
     ↓
speckit-plan          → plan.md, data-model.md, contracts/, research.md, quickstart.md
     ↓
speckit-checklist     (optional, multiple times)
     ↓
speckit-tasks         → tasks.md
     ↓
speckit-analyze       (optional, cross-artifact validation)
     ↓
speckit-implement     → source code, marks tasks [x]
     ↓
speckit-taskstoissues (optional, GitHub issue conversion)
```

---

## Numbering Conventions

| Type | Format | Example |
|------|--------|---------|
| Feature Number | `{NNN}` (3-digit zero-padded) | 001, 042, 999 |
| Task ID | `T{NNN}` | T001, T042 |
| Checklist Item | `CHK{NNN}` | CHK001, CHK042 |
| Functional Requirement | `FR-{###}` | FR-001, FR-042 |
| Success Criterion | `SC-{###}` | SC-001, SC-042 |
| Constitution Version | `MAJOR.MINOR.PATCH` | 1.0.0, 2.1.1 |
