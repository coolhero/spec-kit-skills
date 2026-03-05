---
name: case-study
description: Generates a Case Study report from reverse-spec and smart-sdd execution artifacts. Aggregates quantitative metrics from project artifacts and qualitative observations from the case study log.
argument-hint: "[target-directory] [--lang en|ko]"
allowed-tools: [Read, Grep, Glob, Write, AskUserQuestion]
---

# Case Study: SDD Workflow Report Generator

Generates a structured Case Study report from the artifacts produced by `/reverse-spec` and `/smart-sdd`. Combines automatically-extracted quantitative metrics (Feature counts, test results, parity scores) with qualitative observations recorded during execution.

**This skill works independently** — it reads existing artifacts from a project's `specs/` directory. It does not modify any project files.

---

## Usage

```
/case-study                                # English → case-study-YYYYMMDD-HHMM.md
/case-study --lang ko                      # Korean → case-study-YYYYMMDD-HHMM.md
/case-study ./my-project --lang ko         # Specific project directory
```

> `case-study-log.md` (qualitative observations) is automatically created by `/reverse-spec`, `/smart-sdd init`, and `/smart-sdd pipeline`. If it doesn't exist, the report is generated without qualitative sections.

---

## Argument Parsing

```
$ARGUMENTS parsing rules:
  First token       → target-directory (optional, defaults to CWD). If it looks like a path.
  --lang <en|ko>    → Output language (default: "en")
```

After parsing arguments, read `commands/generate.md` and execute its workflow.

---

## Case Study Agenda

The generated report follows this 8-section structure:

| # | Section | Primary Data Source |
|---|---------|-------------------|
| 1 | **Executive Summary** | Aggregated metrics from all artifacts |
| 2 | **Project Background** | case-study-log.md (M1) + roadmap.md |
| 3 | **Source Analysis** | coverage-baseline.md + registries |
| 4 | **Architecture & Strategy** | history.md + constitution-seed.md |
| 5 | **Pipeline Execution** | sdd-state.md + spec-kit artifacts |
| 6 | **Quality & Parity** | sdd-state.md (verify/parity logs) |
| 7 | **Challenges & Solutions** | case-study-log.md (M2-M8 Challenges) |
| 8 | **Outcomes & Lessons Learned** | case-study-log.md (M8) + metrics |

Sections with no available data are omitted or show "Data not available".

---

## CRITICAL Rules

1. **Read-only**: This skill NEVER modifies project files. It only reads artifacts and writes a new report file.
2. **Graceful degradation**: Only `roadmap.md` and `sdd-state.md` are required. All other artifacts are optional — the report adapts to available data.
3. **No project dependency**: This skill does not require reverse-spec or smart-sdd to be installed. It only reads their output artifacts.
4. **Language consistency**: When `--lang ko`, ALL section headers and descriptive text must be in Korean. Artifact names (file names, Feature IDs) remain in English.
