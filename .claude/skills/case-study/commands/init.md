# Case Study Init

Initializes case study observation logging for a project. Creates the `case-study-log.md` file from the template and displays the recording protocol.

> **Note**: `case-study-log.md` is automatically created when running `/reverse-spec`, `/smart-sdd init`, or `/smart-sdd pipeline`. Use this command to **reset** an existing log or **view the recording protocol**.

---

## Step 1 — Resolve Target Directory

- If target-directory argument is provided: use that path
- If not provided: use the current working directory (CWD)

---

## Step 2 — Prerequisite Check

Check if `case-study-log.md` already exists at the target directory root:
- **If exists**: Ask via AskUserQuestion:
  - "Overwrite existing case-study-log.md (Recommended)" — Replace with fresh template
  - "Keep existing" — Skip template deployment, just display the protocol
- **If not exists**: Proceed to Step 3

---

## Step 3 — Template Deployment

Read `templates/case-study-log-template.md` from the skill directory.

Write the template content to `{target-directory}/case-study-log.md`.

Display:
```
✅ Created: case-study-log.md
```

---

## Step 4 — Display Recording Protocol

Read `reference/recording-protocol.md` from the skill directory.

Display the full recording protocol content to the user, including:
- Milestone reference (M1-M8 with triggers, data sources, templates)
- Entry format template
- Tips for effective recording

---

## Step 5 — Completion Message

```
📝 Case Study logging initialized.

Log file: case-study-log.md

Milestone entries are recorded automatically during /reverse-spec and /smart-sdd execution.
After completing the workflow, generate the Case Study report with:

  /case-study {target-directory}              # English (default)
  /case-study {target-directory} --lang ko    # Korean
```
