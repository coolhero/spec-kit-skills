# Extend — Create New Domain Modules

> Reference: Read after `/domain-extend extend` is invoked.

## Purpose

Create new domain module files (concern, interface, archetype, foundation, profile, or cross-concern rule) with guided elaboration and template-based generation.

---

## Arguments

```
/domain-extend extend <type> <name> [flags]

  <type>       concern | interface | archetype | foundation | profile | rule | context-modifier
  <name>       Module name in kebab-case (e.g., "message-queue", "grpc")

  --from-explore    Seed from code-explore artifacts (traces/orientation)
  --from-detect     Seed from auto-detected patterns in current codebase
```

---

## Workflow

### Step 0 — Parse Arguments

1. Validate `<type>` is one of: `concern`, `interface`, `archetype`, `foundation`, `profile`, `rule`, `context-modifier`
2. Validate `<name>` is kebab-case, no duplicates in existing modules
3. If `--from-explore`: verify `specs/explore/orientation.md` exists
4. If `--from-detect`: verify CWD is a project with source files
5. If `<type>` is `rule`: branch to **Cross-Concern Rule Flow** (see below)
6. If `<type>` is `context-modifier`: branch to **Context Modifier Flow** (single file in `smart-sdd/domains/contexts/modifiers/`)

### Step 1 — Template Selection + Similar Module Analysis

1. **Select base template** based on `<type>`:
   - `concern` → 3-file set: `shared/`, `reverse-spec/domains/concerns/`, `smart-sdd/domains/concerns/`
   - `interface` → 3-file set: `shared/`, `reverse-spec/domains/interfaces/`, `smart-sdd/domains/interfaces/`
   - `archetype` → 3-file set: `shared/`, `reverse-spec/domains/archetypes/`, `smart-sdd/domains/archetypes/`
   - `foundation` → 1-file: `smart-sdd/domains/foundations/`
   - `profile` → 1-file: `smart-sdd/domains/profiles/`
   - `context-modifier` → 1-file: `smart-sdd/domains/contexts/modifiers/`

2. **Find similar existing modules** (by name or keyword overlap):
   - Read `_taxonomy.md` for the relevant module type
   - List top 3 most similar modules with their S0/A0/F0 keywords
   - Display:
     ```
     📋 Similar existing modules:
       1. realtime (S0: websocket, sse, streaming)
       2. async-state (S0: state-management, reactive)
       3. ipc (S0: inter-process, message-passing)
     ```

3. **Load schema** — read `_schema.md` for the target module type to know required sections

### Step 2 — Source Ingestion

**If `--from-explore`**:
- Read `specs/explore/orientation.md` → extract Domain Profile, Module Map
- Read `specs/explore/traces/*.md` → extract relevant patterns
- Map source findings to module sections:
  - Detected patterns → S1 (structural rules) / A1 (archetype patterns)
  - Error patterns found in traces → S7 (failure modes)
  - Keywords from traces → S0 (detection keywords)
- Display:
  ```
  📂 Source ingestion from code-explore:
    Orientation: 3 relevant modules found
    Traces: 2 traces reference similar patterns
    Pre-filled sections: S0, S1, S7
  ```

**If `--from-detect`**:
- Scan current codebase for patterns matching `<name>`
- Extract file patterns, naming conventions, common structures
- Pre-fill S0 keywords from detected file names and imports

**If neither flag**: proceed with empty template (fully manual elaboration).

### Step 3 — Interactive Elaboration (HARD STOP)

> **This step is a HARD STOP.** You MUST ask the user each question and wait for answers.
> Do NOT auto-fill answers or skip questions based on source ingestion.

Ask 2-4 questions via AskUserQuestion, adapting based on `<type>`:

**For Concern modules:**

1. **Detection keywords** (→ S0):
   ```
   What keywords should trigger this concern module?
   (e.g., for "message-queue": kafka, rabbitmq, amqp, pub-sub, consumer-group)

   Pre-filled from source: [list if --from-explore/--from-detect, else "none"]
   ```
   **If response is empty → re-ask** (per MANDATORY RULE 1)

2. **Primary failure modes** (→ S7):
   ```
   What are the most common bugs or failure patterns in this domain?
   (e.g., for "message-queue": duplicate processing, lost messages, poison pill, consumer lag)
   ```
   **If response is empty → re-ask** (per MANDATORY RULE 1)

3. **Critical structural rules** (→ S1):
   ```
   What structural patterns MUST be followed?
   (e.g., for "message-queue": idempotent consumers, dead-letter queues, ordered processing)
   ```
   **If response is empty → re-ask** (per MANDATORY RULE 1)

4. **Verification approach** (→ S3/S8):
   ```
   How should implementations be tested/verified?
   (e.g., for "message-queue": integration test with test broker, verify at-least-once delivery)
   ```

**For Interface modules**: Replace S7 with "User interaction failure patterns", S1 with "UI/API structural patterns".

**For Archetype modules**: Ask about A1 (core patterns), A2 (typical components), A3 (evolution stages).

**For Foundation modules**: Ask about F2 (best practices), F7 (anti-patterns), F8 (style conventions).

### Step 4 — Generate Files

Based on template + source ingestion + user answers, generate the module files.

**For concern/interface/archetype (3-file set):**

1. **Shared file** (`shared/domains/{type}s/{name}.md`):
   - S0/A0: Detection keywords
   - S1/A1: Structural rules (universal, framework-agnostic)
   - S7: Failure modes and prevention

2. **Reverse-spec file** (`reverse-spec/domains/{type}s/{name}.md`):
   - Analysis-specific sections (what to look for during code analysis)
   - Pattern detection rules for reverse-spec phase

3. **Smart-sdd file** (`smart-sdd/domains/{type}s/{name}.md`):
   - Implementation-specific sections (how to apply during SDD pipeline)
   - Verification rules for verify phase

**For foundation (1 file):**
- `smart-sdd/domains/foundations/{name}.md` with F0-F9 sections

**For profile (1 file):**
- `smart-sdd/domains/profiles/{name}.md` with axis combinations + activation rules

### Step 5 — HARD STOP Review

> **This is a HARD STOP.** You MUST show the generated content and wait for user approval.

Display generated content summary:

```
📄 Generated Module: {name} ({type})

Files to create:
  1. shared/domains/{type}s/{name}.md (S0-S9)
  2. reverse-spec/domains/{type}s/{name}.md
  3. smart-sdd/domains/{type}s/{name}.md

Section highlights:
  S0 Keywords: [list]
  S1 Rules: [count] structural rules
  S7 Failure modes: [count] patterns
  S3 Verification: [summary]

📁 Manual alternative:
  Copy template from _schema.md → fill sections manually
  Schema: ~/.claude/skills/{skill}/domains/_schema.md
```

AskUserQuestion:
- **"Approve and install"** → proceed to Step 6
- **"Edit first"** → show full content, accept corrections, regenerate
- **"Cancel"** → abort, no files written

**If response is empty → re-ask** (per MANDATORY RULE 1)

### Step 6 — Install

1. **Write files** to their target paths
2. **Update `_taxonomy.md`** — add the new module entry under the correct category
3. **Suggest cross-concern rules** — if the new module commonly combines with existing modules:
   ```
   💡 Suggested cross-concern rules:
     {name} + auth → Consider: "authenticated message handling" rule
     {name} + realtime → Consider: "real-time queue consumption" rule

   Run `/domain-extend extend rule {name}+auth` to create.
   ```

### Step 7 — Post-Install Verification

1. Validate all generated files match `_schema.md` section format
2. Verify `_taxonomy.md` entry is correct
3. Check no S0 keyword conflicts with existing modules
4. Display:
   ```
   ✅ Module "{name}" installed successfully.
     Files: [count] created
     Taxonomy: updated
     Keywords: [count] registered (no conflicts)
   ```

---

## Cross-Concern Rule Flow (`extend rule <combo>`)

For `extend rule <combo>` where `<combo>` is like `auth+realtime` or `message-queue+resilience`:

### Step R1 — Identify Combination

1. Parse module names from `<combo>` (split on `+`)
2. Verify both modules exist in `_taxonomy.md`
3. Check if a rule already exists for this combination in `_resolver.md` Step 3.5 table

### Step R2 — Emergent Pattern Elaboration (HARD STOP)

AskUserQuestion:
```
What emergent pattern does the combination of {module1} + {module2} produce?

Example: auth + realtime → "Authenticated WebSocket connections require token refresh
  during long-lived connections, not just at initial handshake"

Describe the pattern that ONLY emerges when both concerns interact:
```
**If response is empty → re-ask** (per MANDATORY RULE 1)

### Step R3 — Generate Rule

1. Create rule entry for `_resolver.md` Step 3.5 table:
   ```
   | {module1} + {module2} | {pattern description} | {S1 rules to add} | {S7 failure modes} |
   ```
2. Show preview → HARD STOP for approval
3. Write to `_resolver.md`

### Step R4 — Verify

1. Confirm rule was added to the table
2. Verify referenced modules exist
3. Display confirmation

---

## Context Modifier Flow (`extend context-modifier <name>`)

Context modifiers are **single-file** situational overlays (not 3-file sets like concerns).
They adjust rule depth for a specific situation without producing new structural rules.

### Step M1 — Validate

1. Verify `<name>` is kebab-case
2. Check `smart-sdd/domains/contexts/modifiers/` for duplicates
3. Load template from `templates/context-modifier-template.md`

### Step M2 — Interactive Elaboration (HARD STOP)

AskUserQuestion:
```
Describe the context modifier "{name}":

1. When is it active? (activation condition)
2. What additional SCs or preservation rules does it add? (S1)
3. What context-specific questions should be asked during elaboration? (S5)
4. What failure patterns are unique to this context? (S7)
```
**If response is empty -> re-ask** (per MANDATORY RULE 1)

### Step M3 — Generate + Review (HARD STOP)

1. Generate single file: `smart-sdd/domains/contexts/modifiers/{name}.md`
2. Show preview -> HARD STOP for approval
3. Write file on approval

### Step M4 — Post-Install

1. Validate file matches template structure (Activation Condition, S1, S5, S7)
2. Context modifiers are NOT registered in `_taxonomy.md` (activated by condition, not keywords)
3. Display:
   ```
   ✅ Context Modifier "{name}" installed.
     File: smart-sdd/domains/contexts/modifiers/{name}.md
     Note: Activated by condition, not keyword detection.
   ```
