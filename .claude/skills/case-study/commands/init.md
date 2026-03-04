# Case Study Init

Initializes case study observation logging for a project. Creates the `case-study-log.md` file from the template and displays the recording protocol.

---

## Step 1 — Resolve Target Directory

- If target-directory argument is provided: use that path
- If not provided: use the current working directory (CWD)

Set `BASE_PATH` = `{target-directory}/specs/reverse-spec/`

---

## Step 2 — Prerequisite Check

Check if `specs/reverse-spec/` directory exists at the target location.

- **If exists**: Proceed to Step 3
- **If not exists**: Display warning and create the directory:
  ```
  ⚠️ specs/reverse-spec/ does not exist yet. Creating it.
  Run /reverse-spec before /case-study generate to populate artifacts.
  ```
  Create the directory: `mkdir -p {target-directory}/specs/reverse-spec/`

Check if `case-study-log.md` already exists at `BASE_PATH`:
- **If exists**: Ask via AskUserQuestion:
  - "Overwrite existing case-study-log.md (Recommended)" — Replace with fresh template
  - "Keep existing" — Skip template deployment, just display the protocol
- **If not exists**: Proceed to Step 3

---

## Step 3 — Template Deployment

Read `templates/case-study-log-template.md` from the skill directory.

Write the template content to `{BASE_PATH}/case-study-log.md`.

Display:
```
✅ Created: {BASE_PATH}/case-study-log.md
```

---

## Step 4 — Display Recording Protocol

Read `reference/recording-protocol.md` from the skill directory.

Display the full recording protocol content to the user, including:
- Milestone reference table (M1-M8)
- Entry format template
- Tips for effective recording

---

## Step 5 — Completion Message

```
📝 Case Study logging initialized.

Log file: {BASE_PATH}/case-study-log.md

Record observations at each milestone during /reverse-spec and /smart-sdd execution.
After completing the workflow, generate the Case Study report with:

  /case-study generate {target-directory}              # English (default)
  /case-study generate {target-directory} --lang ko    # Korean
```
