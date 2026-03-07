---
name: case-study
description: Generates a Case Study report from reverse-spec and smart-sdd execution artifacts. Aggregates quantitative metrics from project artifacts and qualitative observations from the case study log.
argument-hint: "[init|generate] [target-directory] [--lang en|ko]"
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

> `case-study-log.md` (qualitative observations) is automatically created at the project root by `/reverse-spec`, `/smart-sdd init`, and `/smart-sdd pipeline`. Milestone entries are appended automatically during workflow execution. If it doesn't exist, the report is generated without qualitative sections.

---

## Argument Parsing

```
$ARGUMENTS parsing rules:
  "init"            → Sub-command: read `commands/init.md` and execute its workflow. Stop here.
  "generate"        → Sub-command: read `commands/generate.md` and execute its workflow. Stop here.
  First token       → target-directory (optional, defaults to CWD). If it looks like a path.
  --lang <en|ko>    → Output language (default: "en")
```

If the first argument is `init`, read `commands/init.md` and execute its workflow.
If the first argument is `generate`, read `commands/generate.md` and execute its workflow.
Otherwise, after parsing arguments, read `commands/generate.md` and execute its workflow (default).

---

## Case Study Agenda

The report follows an 8-section structure (see `commands/generate.md` for details). Sections with no available data are omitted or show "Data not available".

---

## CRITICAL Rules

1. **Read-only**: This skill NEVER modifies project files. It only reads artifacts and writes a new report file.
2. **Graceful degradation**: Only `roadmap.md` and `sdd-state.md` are required. All other artifacts are optional — the report adapts to available data.
3. **No project dependency**: This skill does not require reverse-spec or smart-sdd to be installed. It only reads their output artifacts.
4. **Language consistency**: When `--lang ko`, ALL section headers and descriptive text must be in Korean. Artifact names (file names, Feature IDs) remain in English.
