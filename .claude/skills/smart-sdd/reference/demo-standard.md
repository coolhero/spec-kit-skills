# Demo-Ready Delivery Standard

> Single source of truth for demo script requirements, template, and anti-patterns.
> Referenced by: `reference/injection/implement.md` (creation), `commands/verify-phases.md` Phase 3 (verification), `reference/injection/tasks.md` (task injection), `domains/_core.md` § S1 (demo pattern) + active interface modules § S1 (interface-specific overrides), `reference/injection/verify.md` + `reference/state-schema.md` (Integration Demo trigger).
> For the MANDATORY rule, see `SKILL.md` Rule 2.

---

## 1. Demo Philosophy

A demo is an **executable script** that launches the real, working Feature so the user can experience it firsthand. It is NOT documentation, NOT a test suite, and NOT manual instructions.

- **Default = interactive**: Start the Feature → print "Try it" instructions → keep running until Ctrl+C
- **`--ci` flag**: Quick health check → exit (for `verify` Phase 3 automation)
- **Script location**: `demos/F00N-name.sh` (or `.ts`/`.py`/etc. matching the project's language)

## 2. Anti-Patterns (REJECT these)

> **⚠️ DO NOT DO THIS:**

```markdown
# F001 Auth Demo          ← WRONG: This is a markdown document
## Demo Steps              ← WRONG: Manual instructions for a human to follow
1. Open the browser       ← WRONG: Not executable by a machine
2. Click "Login"          ← WRONG: Requires human interaction
```
A markdown file with instructions is **documentation, NOT a demo script**.

```bash
#!/usr/bin/env bash
TOTAL=0; PASSED=0
TOTAL=$((TOTAL+1)); curl -s ... | grep -q "OK" && PASSED=$((PASSED+1))
echo "${PASSED}/${TOTAL} passed"    ← WRONG: This is a test suite, not a demo
```
A script that only runs assertions and exits is a **test suite**, not a demo.
Tests are for `verify` Phase 1. Demos are for showing the **real, working Feature**.

Additional anti-patterns:
- Showing demo steps as text in the chat instead of writing a script file
- A script that only runs tests without starting the actual Feature

## 3. Demo Script Template

**CORRECT — executable demo that launches the Feature for the user to experience:**
```bash
#!/usr/bin/env bash
# Demo: [Feature Name]
# Usage: ./demos/F00N-name.sh [--ci]
#
# Coverage (maps to spec.md):
#   FR-001 [Requirement]:
#     ✅ SC-001: navigate /page → fill input#name → click button#submit → verify .result visible
#     ✅ SC-002: navigate /page → click .dropdown → verify .menu visible
#     ⬜ SC-003: (requires WebSocket — skip auto-verify)
#   FR-002 [Requirement]:
#     ⬜ SC-004: (requires external API — skip auto-verify)
#
# Demo Components:
#   [name] | [path] | Demo-only/Promotable | [lifecycle note]
set -euo pipefail

CI_MODE=false; [ "${1:-}" = "--ci" ] && CI_MODE=true
cleanup() { echo "Shutting down demo..."; }
trap cleanup EXIT

echo "══ Demo: [Feature Name] ══"

# ─── Setup & Start ───
echo "Setting up..."; # [seed DB, build assets, etc.]
echo "Starting [Feature Name]..."; # [start server in background]
# ⚠️ The actual Feature startup command (e.g., npm run dev, tauri dev) MUST run HERE,
#    BEFORE the CI exit point below. CI mode must exercise the same startup path.

# ─── Health Check ───
curl -sf http://localhost:3000/health || { echo "❌ Health check failed"; exit 1; }
echo "✅ [Service] running"

# ─── Stability Window (CI only) ───
# Multi-check stability: 3 health probes over 15 seconds to catch intermittent issues.
# Catches: crash-after-start, gradual memory exhaustion, delayed initialization failure,
# intermittent health flapping. A single 10s check can miss bugs that appear between 5-12s.
if [ "$CI_MODE" = true ]; then
  echo "Stability check (15s, 3 probes)..."
  APP_LOG=$(mktemp)
  STABILITY_FAIL=false

  for i in 1 2 3; do
    sleep 5
    if ! curl -sf http://localhost:3000/health > /dev/null 2>&1; then
      echo "❌ Stability probe $i/3 failed — app became unhealthy"
      STABILITY_FAIL=true
      break
    fi
    echo "  ✅ Probe $i/3 passed ($(( i * 5 ))s)"
  done

  # ─── Runtime Error Scan ───
  # Check for client-side errors captured in app output (regardless of probe results)
  if grep -qiE 'TypeError|ReferenceError|SyntaxError|unhandled rejection|FATAL|panic:|Maximum update depth exceeded' "$APP_LOG" 2>/dev/null; then
    echo "❌ Runtime errors detected during stability window:"
    grep -iE 'TypeError|ReferenceError|SyntaxError|unhandled rejection|FATAL|panic:|Maximum update depth exceeded' "$APP_LOG"
    STABILITY_FAIL=true
  fi
  rm -f "$APP_LOG"

  if [ "$STABILITY_FAIL" = true ]; then
    echo "❌ Stability check failed"
    exit 1
  fi
  echo "=== CI health + stability (3-probe) + runtime error check passed ==="
  # ─── Functional Verification (--verify mode) ───
  # Extends CI mode: after health + stability pass, execute VERIFY_STEPS via Playwright MCP.
  # The verify agent reads the VERIFY_STEPS block below and replays actions via MCP.
  # This section is a marker — actual execution is handled by the verify agent, not bash.
  if [ "${2:-}" = "--verify" ]; then
    echo "Functional verification mode — VERIFY_STEPS block will be parsed by the verify agent."
    echo "=== Awaiting Playwright MCP verification ==="
    # Do NOT exit here — the verify agent will drive the remaining steps.
    # Fall through to keep the app running while verification happens.
    wait || true
    exit 0
  fi
  exit 0
fi

# ─── Interactive: Try it ───
echo "🎯 [Feature Name] is live!"
echo "  👉 Open: http://localhost:3000/[page]"
echo "  👉 API:  curl http://localhost:3000/api/[endpoint]"
echo "Press Ctrl+C to stop."

wait || true
```

## 4. Key Requirements

- **The demo shows the real, working Feature** — not just assertions. Running the script launches the Feature so the user can experience it firsthand
- The script must be executable (`chmod +x`) and self-contained
- **Default = interactive**: The script launches the Feature and keeps it running. The user interacts with it via browser, curl, CLI, etc.
- **`--ci` flag**: For `verify` Phase 3 automation — runs setup + health check + stability window, then exits. No user interaction needed
- **⚠️ CI/Interactive path convergence (CRITICAL)**: CI mode MUST execute the **same startup commands** as interactive mode. The CI exit point must come **AFTER** the Feature is actually started, health-checked, AND stability-verified — never before. If CI mode takes a shortcut (e.g., only checks the build without running `npm run dev` / `tauri dev`), the CI check becomes meaningless: it can pass while the actual demo fails.
  - ✅ CORRECT: Start Feature → health check → **stability window (15s, 3 probes)** → `exit 0`
  - ❌ WRONG: Build check → `if CI then exit` → Start Feature → interactive instructions → wait
  - ❌ WRONG: Start Feature → health check → `exit 0` immediately (no stability window — misses crash-after-startup)
- **Stability window (multi-probe)**: After initial health check, CI mode performs 3 health probes at 5-second intervals (total 15s). This catches: crash-after-startup, gradual memory exhaustion, delayed initialization failure, intermittent health flapping. A single 10s check can miss bugs that appear between 5-12 seconds
- **Runtime error detection (CI only)**: During the stability window, capture app stderr/stdout and scan for runtime error patterns (`TypeError`, `ReferenceError`, `SyntaxError`, `Maximum update depth exceeded`, `unhandled rejection`, `FATAL`, `panic:`). These client-side errors (infinite re-renders, selector instability) do NOT cause HTTP health checks to fail but indicate a broken app. CI mode MUST exit 1 if runtime errors are detected, even if the health endpoint returns 200
- **Coverage header REQUIRED**: Map each FR-###/SC-### from spec.md to what the user can see/try in the demo. Each SC-### includes verifiable UI actions (navigate, fill, click, verify) for automated verification during `verify` Phase 3. Use ⬜ for items that can't be auto-verified (WebSocket, external API, etc.)
- **SC→UI Action format** (3-tier verification verbs):
  - **Tier 1 — Presence**: `verify selector visible` — confirm element existence (default)
  - **Tier 2 — State Change**: `verify-state selector attribute "expected"` — confirm DOM attribute/class change after interaction (e.g., `verify-state html class "dark"`, `verify-state #checkbox checked "true"`)
  - **Tier 3 — Side Effect**: `verify-effect target-selector property "expected"` — confirm downstream DOM propagation on a DIFFERENT element (e.g., `verify-effect body style.fontSize "18px"`, `verify-effect .toast visible`)
  - Full sequence example: `navigate /settings → click button#theme-toggle → verify-state html class "dark" → verify-effect body style.backgroundColor "#1a1a2e"`
  - Actions use CSS selectors or element identifiers. This enables `verify` Phase 3 Step 3 to parse and replay these actions via MCP. Tier 2/3 verbs are parsed from the Interaction Chains table's Verify Method column (see plan.md)
  - **Interactive verification verbs** (for micro-interaction patterns from Interaction Behavior Inventory):
    - `hover selector` — move cursor over element for tooltips, hover menus, hover effects
    - `press-key "shortcut"` — press keyboard shortcut (e.g., `press-key "Control+s"`, `press-key "Escape"`)
    - `drag-to source-selector target-selector` — drag element from source to target for drag-and-drop, reorder
    - `focus selector` — focus element for focus ring, focus trap, tab order verification
    - `verify-tooltip selector "expected-text"` — hover over element, wait 1s, verify tooltip/popover text
    - `right-click selector` — right-click for context menu verification
    - `verify-animation selector property` — check computed style change after interaction for CSS transition/animation verification
  - **Temporal verification verbs** (for async UX flows from UX Behavior Contract):
    - `wait-for selector visible [timeout]` — wait until element appears (default timeout 10s). For loading states, streaming indicators
    - `wait-for selector gone [timeout]` — wait until element disappears. For loading→complete transitions
    - `wait-for selector textContent "pattern" [timeout]` — wait until element text matches regex. For streaming text verification
    - `verify-scroll selector "bottom"` — verify element is scrolled to bottom (`scrollTop + clientHeight >= scrollHeight - threshold`). For auto-scroll during streaming
    - `verify-scroll selector "not-bottom"` — verify element is NOT at bottom (user scrolled up)
    - `trigger selector event` — dispatch custom event for testing (e.g., `trigger .chat-input submit`)
    - Full async sequence example: `navigate /chat → fill .chat-input "Hello" → click button#send → wait-for .spinner visible → wait-for .message-content visible → wait-for .spinner gone 15 → verify-scroll .chat-area "bottom" → verify-state button#send disabled "false"`
- **VERIFY_STEPS block** (optional, for UI Features): Include a comment block after the Coverage header that defines functional verification steps. These steps are parsed by the verify agent (Phase 3 Step 6b) and executed via Playwright MCP:
  ```bash
  # VERIFY_STEPS:
  #   navigate /settings
  #   click button#theme-toggle
  #   verify-state html class "dark"
  #   navigate /settings/display
  #   fill input#font-size 18
  #   verify-effect body style.fontSize "18px"
  #
  # Async UX verification (from UX Behavior Contract):
  #   navigate /chat
  #   fill .chat-input "test message"
  #   click button#send
  #   wait-for .spinner visible
  #   wait-for .message-content visible
  #   wait-for .spinner gone 15
  #   verify-scroll .chat-area "bottom"
  #   verify-state button#send disabled "false"
  #
  # Micro-interaction verification (from Interaction Behavior Inventory):
  #   hover .settings-icon
  #   verify-tooltip .settings-icon "Settings"
  #   press-key "Control+k"
  #   verify .command-palette visible
  #   press-key "Escape"
  #   focus input#search
  #   right-click .file-item
  #   verify .context-menu visible
  #   drag-to .sortable-item-1 .sortable-item-3
  #   verify-animation .sortable-list transition
  ```
  Uses the same verb syntax as SC→UI Action format (including `verify-state`/`verify-effect` from Interaction Chains).
  The `--verify` flag causes CI mode to keep the app running for Playwright verification instead of exiting immediately.
- **VERIFY_STEPS test file** (generated during implement, alongside demo script):
  When a VERIFY_STEPS block exists, also generate `demos/verify/F00N-name.spec.ts` (or `.spec.js`).
  This file converts each VERIFY_STEPS verb to a Playwright API call:
  - `navigate /path` → `await page.goto(BASE_URL + '/path')`
  - `click selector` → `await page.click('selector')`
  - `fill selector value` → `await page.fill('selector', 'value')`
  - `verify selector visible` → `await expect(page.locator('selector')).toBeVisible()`
  - `verify-state selector attribute "expected"` → `toHaveAttribute` / `toHaveClass`
  - `verify-effect target property "expected"` → `getComputedStyle` evaluation + assert
  - `wait-for selector visible [timeout]` → `await expect(page.locator('selector')).toBeVisible({ timeout })`
  - `wait-for selector gone [timeout]` → `await expect(page.locator('selector')).toBeHidden({ timeout })`
  - `wait-for selector textContent "pattern" [timeout]` → `await expect(page.locator('selector')).toHaveText(pattern, { timeout })`
  - `verify-scroll selector "bottom"` → `await page.evaluate(s => { const el = document.querySelector(s); return el.scrollTop + el.clientHeight >= el.scrollHeight - 5; }, 'selector')` + assert true
  - `trigger selector event` → `await page.locator('selector').dispatchEvent('event')`
  - `hover selector` → `await page.locator('selector').hover()`
  - `press-key "shortcut"` → `await page.keyboard.press('shortcut')`
  - `drag-to source-selector target-selector` → `await page.locator('source-selector').dragTo(page.locator('target-selector'))`
  - `focus selector` → `await page.locator('selector').focus()`
  - `verify-tooltip selector "expected-text"` → `await page.locator('selector').hover()` + `await expect(page.getByRole('tooltip')).toHaveText('expected-text')`
  - `right-click selector` → `await page.locator('selector').click({ button: 'right' })`
  - `verify-animation selector property` → compare `getComputedStyle` before/after interaction + assert change
  This enables `--ci --verify` to run via CLI Playwright (no MCP needed):
  ```bash
  npx playwright test demos/verify/F00N-name.spec.ts --reporter=list 2>&1
  ```
  Also used by verify Phase 3 as a CLI fallback when MCP is unavailable (see verify-phases.md Step 6b).
- **Concrete "Try it" instructions**: Print at least 2-3 things the user can actually DO — real URLs, real curl commands, real CLI invocations. NOT prose descriptions
- **Demo code separation**: `// @demo-only` and `// @demo-scaffold` markers
- **Playwright header** (optional): For UI Features, include a `# Playwright` comment section with URLs and element assertions for automated UI verification. See [reference/ui-testing-integration.md](ui-testing-integration.md)

## 5. Requirements by Feature Type

| Feature Type | Demo Approach |
|-------------|---------------|
| Has UI | Start the server with demo data, open the real UI. User sees and interacts with actual pages |
| Backend/API | Start the server with demo data, print curl commands for real endpoints |
| CLI/Library | Provide a pre-configured sandbox and sample commands to run |
| Data layer / Store | Provide a seeded database with CRUD command examples |
| Pipeline / Engine | Run the pipeline with sample input and show real output, then let the user try with their own input |

## 6. Demo Code Markers

| Marker | Meaning |
|--------|---------|
| `// @demo-only` | Remove after demo — throwaway scaffolding |
| `// @demo-scaffold — will be extended by F00N-[feature]` | Extend later — promotable to production code |

## 7. Integration Demo (Demo Group completion)

When all Features in a Demo Group complete verify, the trigger HARD STOP fires (see `reference/injection/verify.md` § Post-Step Update Rules). If the user selects **"Run Integration Demo"**:

**Execution procedure**:
1. Read the Demo Group's Feature list from `sdd-state.md` Demo Group Progress
2. For each Feature in the group (in roadmap order), run its demo in CI mode:
   ```
   demos/F00N-name.sh --ci
   ```
   - If any Feature demo fails: report the failure and STOP. The group status stays `⏳`
3. If all Feature demos pass individually, run a **cross-Feature smoke test**:
   - Start all Features' services (using each demo's setup/start logic)
   - Execute the Demo Group's scenario description as an end-to-end flow (e.g., "User registers → browses products → adds to cart → checks out")
   - Verify each step succeeds
4. Display results:
   ```
   🎯 Integration Demo: [DG-0N] — [Scenario Name]

   ── Per-Feature Health ──────────────────────────
     ✅/❌ F001-auth: [pass/fail]
     ✅/❌ F002-product: [pass/fail]
     ✅/❌ F003-cart: [pass/fail]

   ── End-to-End Scenario ─────────────────────────
     [Step-by-step results of the scenario flow]

   Result: ✅ All passed / ❌ [failure details]
   ```
5. Update `sdd-state.md` Demo Group Progress:
   - If passed: Status → `✅ All verified`, Last Demo → current date
   - If failed: Status stays `⏳`, record failure reason in Status column

**If the user selects "Defer Integration Demo"**: Status stays `⏳ all verified, demo pending`. The trigger re-fires on next `/smart-sdd pipeline` or `/smart-sdd verify` invocation.

**Invalidation**: When a Feature is added to an existing group via `/smart-sdd add`, previous results are invalidated → `🔄 re-run needed (F00N added)`. See `reference/state-schema.md` § Integration Demo Invalidation.

---

## 8. Demo Hub (`demos/README.md`)

After creating a demo script, update `demos/README.md`:
- Create if it doesn't exist (first Feature with demo)
- Add the Feature with its demo command and a brief description:
  - `./demos/F00N-name.sh` — launches [brief description of what the user can try]
