# Verify Phase 1: Execution Verification (BLOCKING)

> Part of verify-phases.md split. For common gates (Bug Fix Severity, Source Modification Gate), see [verify-phases.md](verify-phases.md).

---

### Phase 1: Execution Verification (BLOCKING)

Run each check and record results. **If any check fails, verification is BLOCKED — do not proceed to Phase 2/3/4.**

1. **Test check**: Detect and execute the project's test command (from `sdd-state.md` → `## Toolchain` → Test row, or from `package.json` scripts, `pyproject.toml`, `Makefile`, etc.). If `**Structure**: monorepo`, use workspace-aware test command (e.g., `turbo run test`, `bun run --filter=* test`).
2. **Build check**: Run the build command and confirm no errors. If `**Structure**: monorepo`, use workspace-aware build command.
3. **Lint check**: Detect and execute the lint tool per domain detection rules.

   **Step 3a — Check Toolchain state** (from Foundation Gate):
   Read `sdd-state.md` → `## Toolchain` section → Lint row Status:
   - `⚠️ not installed` → **skip lint entirely**. Display:
     `⏭️ Lint: skipped — tool not installed (detected in Foundation Gate). Install [command] to enable.`
     This is NOT a Phase 1 failure. Record lint result as `skipped (not installed)`.
   - `✅ available` → proceed to Step 3b (execute lint)
   - `ℹ️ not configured` → **skip**. Display: `ℹ️ Lint: not configured`. Record as `not configured`.
   - Toolchain section absent (legacy sdd-state.md or Foundation Gate not yet run) → fall through to Step 3b (detect on-the-fly for backward compatibility)

   **Step 3b — Execute lint** (when tool is available or status unknown):
   1. Detect the lint command per `domains/_core.md` § S3b (Lint Tool Detection Rules)
   2. Run the detected lint command
   3. **Distinguish failure types**:
      - **Tool not found** (exit code 127 / "command not found"): This is a **toolchain issue**, NOT a code quality issue.
        Display: `⚠️ Lint: tool not found ([command]). This is a toolchain issue, not a code problem.`
        **Offer auto-install** via AskUserQuestion:
        - "Install now" — run the install command from `domains/_core.md` § S3b (e.g., `npm install --save-dev eslint`). After install, re-run lint. If lint passes → record `✅ available` + `✅ Lint: passed`. If lint finds errors → record `✅ available` + report lint errors as normal Phase 1 failure.
        - "Skip — proceed without lint" — record `⚠️ not installed` in `sdd-state.md` Toolchain. Treat as skipped, do NOT block.
        **If response is empty → re-ask** (per MANDATORY RULE 1).
      - **Lint errors found** (exit code 1 with lint output): This is a **code quality issue**.
        Display: `❌ Lint: [N] errors found`
        This IS a Phase 1 failure — **BLOCKS** per normal rules.
      - **Lint passes** (exit code 0): Display: `✅ Lint: passed`

4. **i18n coverage check** (skip if project has no i18n / translation framework):

   Detect i18n framework: search for `i18next`, `react-intl`, `vue-i18n`, `@angular/localize`, `gettext` in config/package files. If none found → skip entirely.

   > Adapt file extensions and translation call patterns to the project's tech stack.

   **Step 4a — Collect used keys**: Grep source files (`src/**/*.{ts,tsx,js,jsx,vue,svelte}`) for translation call patterns:
   - `t('key')`, `t("key")`, `$t('key')`, `i18n.t('key')`, `useTranslation` + `t('key')`
   - Extract the key strings into a deduplicated list

   **Step 4b — Collect defined keys**: For each locale JSON/YAML file (e.g., `en.json`, `ko.json`, `messages_en.properties`):
   - Extract all key paths (flattened dot-notation for nested JSON)

   **Step 4c — Cross-check**:
   | Check | Severity |
   |-------|----------|
   | Key used in code but missing in ANY locale file | ❌ ERROR — UI will show raw key string |
   | Key in locale A but missing in locale B | ⚠️ WARNING — incomplete translation |
   | Key defined but never used in code | ℹ️ INFO — dead key (not blocking) |

   **Display**:
   ```
   🌐 i18n Coverage:
     Keys used in code: [N]
     Locale files: [list e.g., en.json, ko.json]
     Missing keys (code → locale): [N] ❌
       [key1] — missing in: ko.json
       [key2] — missing in: en.json, ko.json
     Incomplete translations: [N] ⚠️
     Dead keys: [N] ℹ️
   ```

   **Blocking**: Missing keys (code references a key that exists in NO locale file) → Phase 1 FAILURE. Incomplete translations (key in one locale but not another) → ⚠️ WARNING (not blocking, but reported).

5. **Build output fidelity check** (all project types — scope varies):

   Build success does NOT guarantee runtime correctness. Many frameworks require build-time plugins that, when missing, cause **silent failures** — build passes, types check, app runs, but framework output is absent.

   **Step 5a — Build-time framework detection**: Scan project configuration for frameworks requiring build plugins:
   - **CSS frameworks**: Tailwind CSS (`@tailwindcss/vite`, `@tailwindcss/postcss`), PostCSS plugins, CSS Modules
   - **i18n extraction**: compile-time message extractors (`@formatjs/swc-plugin`, `babel-plugin-react-intl`)
   - **Code generation**: Prisma, GraphQL codegen, OpenAPI generators (check if `generate` scripts exist in `package.json`)
   - **Asset pipeline**: image optimizers, SVG sprite generators, font subsetters
   - No build-time frameworks detected → skip this check

   **Step 5b — Plugin registration verification** (for each detected framework):
   - Verify the framework's build plugin is registered in the correct build configuration
   - For multi-config builds (e.g., `electron.vite.config` with main/preload/renderer): verify the plugin is in the **correct target config** (e.g., CSS plugin in renderer, not main)
   - For codegen: verify generation scripts run before build (prebuild hook or explicit step)
   - If plugin/script is missing → ❌ **BLOCKING** — framework output will not be generated

   **Step 5c — Runtime output spot check** (if applicable and Playwright available for GUI):
   - **GUI/CSS**: Start the app, take a snapshot — check that styled container elements have non-default dimensions (not all at 0×0 or stacked linearly)
   - **i18n**: Verify at least one translated string appears in rendered output (not raw keys like `messages.welcome`)
   - **Codegen**: Verify generated types/clients exist and are importable
   - If output appears non-functional → ⚠️ WARNING — likely build plugin misconfiguration

   **Display**:
   ```
   🔧 Build Output Fidelity:
     Detected frameworks: [Tailwind CSS 4, i18n (formatjs) / none]
     Plugin registration: [✅ all registered / ❌ MISSING — {framework}: {expected plugin} not in {config}]
     Runtime check: [✅ output verified / ⚠️ output missing / skipped (not applicable)]
   ```

**If ANY check fails** (test, build, lint errors, missing i18n keys, or build plugin missing), display and STOP:
```
❌ Execution Verification failed for [FID] - [Feature Name]:
  Tests: [PASS/FAIL — pass count/total, failure details]
  Build: [PASS/FAIL — error summary]
  Lint:  [PASS/FAIL/skipped (not installed)/not configured]
  i18n:  [PASS/FAIL/skipped (no i18n) — missing key count]
  Build fidelity: [PASS/FAIL/skipped (no build-time frameworks detected)]

Fix the failing checks before verification can continue.
Verification is BLOCKED — merge will not be allowed until all checks pass.
⚠️ Source Modification Gate applies — before fixing ANY source file, run the Pre-Fix Classification gate.
```

**Use AskUserQuestion** with options:
- "Fix and re-verify" — user will fix, then re-run `/smart-sdd verify`
- "Show failure details" — display full test/build/lint output
- "Acknowledge limited verification" — proceed with ⚠️ limited-verify (requires reason)

**If response is empty → re-ask** (per MANDATORY RULE 1). **Do NOT proceed to Phase 2** until all three checks pass **OR** the user explicitly acknowledges limited verification.

**Limited-verify exception path**: If the user selects "Acknowledge limited verification":
1. Ask for the reason (e.g., "Tests require external service not available", "Build depends on Feature B not yet merged", "DB migration requires completed Feature C")
2. Record in `sdd-state.md` Feature Detail Log → verify row Notes: `⚠️ LIMITED — [reason]`
3. Set the verify step icon to `⚠️` (not ✅) in Feature Progress
4. **Proceed to Phase 2 AND Phase 3 sequentially** — Phase 1 limited-acknowledge does NOT skip subsequent phases. All phases (2, 3, 4) MUST still execute. The merge step will display a reminder that this Feature has limited verification.
5. **This is NOT a skip** — the limitation is tracked and visible in status reports

> **Build prerequisites**: If the build fails due to missing setup steps (e.g., `pnpm approve-builds`, native module compilation), include the specific prerequisite command in the error message so the user knows what to run.
