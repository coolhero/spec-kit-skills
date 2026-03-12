---
name: reverse-spec
description: Reverse-analyzes existing source code to extract the Global Evolution Layer (roadmap.md + supporting artifacts) for spec-kit SDD redevelopment. A Reverse Specification skill that extracts specs from existing implementations.
argument-hint: "[target-directory] [--scope core|full] [--stack same|new] [--name new-project-name] [--domain app|data-science] [--adopt] [--skip-to <phase>]"
allowed-tools: [Read, Grep, Glob, Bash, Write, Task, AskUserQuestion]
---

# Reverse-Spec: Existing Source Code → spec-kit Global Evolution Layer Extraction

> **🚨 MANDATORY RULE — READ FIRST 🚨**
>
> **Empty Response Enforcement**
> Every AskUserQuestion in this skill (Phase 0 questions, Phase 3 checkpoints, Phase 4 classification) MUST be checked after returning:
> 1. **CHECK the response** — is it empty, blank, or missing a selection?
> 2. **If empty → call AskUserQuestion AGAIN.** Do NOT proceed. Do NOT assume a default.
> 3. **Only proceed when the user has explicitly selected an option.**
>
> This rule applies to ALL AskUserQuestion calls. Violating this rule means the user loses control of the workflow. There are no exceptions.

Analyzes existing source code to extract project-level global context needed for spec-kit-based SDD (Spec-Driven Development) redevelopment.

**Prerequisites**: [Playwright](https://playwright.dev) should be installed for Phase 1.5 (Runtime Exploration). Without it, only code analysis is performed.

```bash
# Primary (CLI — recommended)
npm install -D @playwright/test && npx playwright install

# Optional (MCP accelerator — faster interactive exploration)
claude mcp add --scope user playwright -- npx @playwright/mcp@latest
```

**Electron**: CLI mode uses `_electron.launch()` (no CDP needed). See [PLAYWRIGHT-GUIDE.md](../../../PLAYWRIGHT-GUIDE.md) for Electron setup.

**Target Directory** (source to analyze): First positional argument from `$ARGUMENTS` (defaults to the current directory if not specified)
**Output Directory** (where artifacts are written): Always the **current working directory** (CWD) where the skill was invoked — NOT the target directory. The target directory is read-only; no files are written there.

---

## Argument Parsing

```
$ARGUMENTS parsing rules:
  Positional    → target-directory (path to analyze, defaults to "." if not specified)
  --scope <val> → Implementation scope: "core" or "full" (skips Phase 0 Question 1 if provided)
  --stack <val> → Tech stack strategy: "same" or "new" (skips Phase 0 Question 2 if provided)
  --name <val>  → New project name (skips Phase 0 Question 3 if provided; implies rename from detected project name)
  --domain <val> → Project domain profile: "app" (default). Backward-compatible alias for --profile
  --profile <val> → Domain profile name (e.g., "fullstack-web", "desktop-app", "cli-tool"). Overrides --domain
  --adopt       → SDD Adoption mode: forces --scope full --stack same, skips Question 3 (no renaming). Use when documenting existing code in-place.
  --skip-to <phase> → (DEV/TEST) Jump directly to a specific phase. Skips all preceding phases with sensible defaults. Valid values: "1.5", "2", "3", "4". Example: --skip-to 1.5 to test Runtime Exploration.
```

---

## Domain Profile

The `--profile` argument (or `--domain` for backward compatibility) selects the domain profile. Default: `app` (expands to `fullstack-web` profile).

**Loading**: Read [`domains/_resolver.md`](../smart-sdd/domains/_resolver.md) (shared with smart-sdd) before starting Phase 1. The resolver loads modules based on the detected or specified profile:

1. `domains/_core.md` — Universal analysis framework (always loaded)
2. `domains/interfaces/{interface}.md` — For each active interface (http-api, gui, cli, data-io)
3. `domains/concerns/{concern}.md` — For each active concern (detection signals for auto-detection)

Loaded modules provide: **Detection Signals** (R1), **Project Type Classification** (R2), **Analysis Axes** (R3), **Registries** (R4), **Feature Boundary Heuristics** (R5), **Tier Classification Axes** (R6).

---

## Workflow

After parsing arguments, read `commands/analyze.md` for the complete workflow. Execute the following phases in order, reporting progress to the user after each Phase:

| Phase | Name | Description |
|-------|------|-------------|
| **Pre-Phase** | Git Repository Setup | Ensure CWD has a git repository for branch-based workflow |
| **Phase 0** | Strategy Questions | Determine scope, stack strategy, project identity |
| **Phase 1** | Project Scan | Identify tech stack, directory structure, static resources |
| **Phase 1.5** | Runtime Exploration | (Optional, rebuild only) Run the original app and explore interactively |
| **Phase 2** | Deep Analysis | Extract entities, APIs, business logic, behaviors |
| **Phase 3** | Feature Classification | Identify Features, assign IDs, classify importance (core scope) |
| **Phase 4** | Deliverable Generation | Generate artifacts, source coverage baseline, completion report |

---

## Notes

- **`sdd-state.md` is NOT generated by `/reverse-spec`**. It is created and managed by `/smart-sdd` when the pipeline first runs.
- For large codebases (1000+ files), distribute model/API/logic extraction across parallel sub-agents using the Task tool in Phase 2.
- Write entity/API formats in deliverables to be compatible with spec-kit's data-model.md and contracts/ style.
- Refer to [speckit-compatibility.md](reference/speckit-compatibility.md) for the spec-kit integration guide.
