# Demo-Ready Delivery Standard

> Single source of truth for demo script requirements, template, and anti-patterns.
> Referenced by: `reference/injection/implement.md` (creation), `commands/verify-phases.md` Phase 3 (verification), `reference/injection/tasks.md` (task injection), `domains/app.md` § 1 (domain profile), `reference/injection/verify.md` + `reference/state-schema.md` (Integration Demo trigger).
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
# Wait briefly after startup to catch crash-after-start, hangs, and delayed errors.
if [ "$CI_MODE" = true ]; then
  echo "Stability check (10s)..."
  sleep 10
  # Re-check: is the process still alive and responding?
  curl -sf http://localhost:3000/health || { echo "❌ Stability check failed — app crashed after startup"; exit 1; }
  echo "=== CI health + stability check passed ==="
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
  - ✅ CORRECT: Start Feature → health check → **stability window (10s)** → re-check → `exit 0`
  - ❌ WRONG: Build check → `if CI then exit` → Start Feature → interactive instructions → wait
  - ❌ WRONG: Start Feature → health check → `exit 0` immediately (no stability window — misses crash-after-startup)
- **Stability window**: After initial health check, CI mode waits ~10 seconds then re-checks health. This catches applications that start successfully but crash or hang shortly after startup (e.g., event loop blocking, resource exhaustion, delayed initialization failure)
- **Coverage header REQUIRED**: Map each FR-###/SC-### from spec.md to what the user can see/try in the demo. Each SC-### includes verifiable UI actions (navigate, fill, click, verify) for automated verification during `verify` Phase 3. Use ⬜ for items that can't be auto-verified (WebSocket, external API, etc.)
- **SC→UI Action format**: `navigate /path → fill selector → click selector → verify selector visible`. Actions use CSS selectors or element identifiers. This enables `verify` Phase 3 Step 2b to parse and replay these actions via MCP
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
