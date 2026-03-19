# Verify Phase 3 — Rebuild-Only Steps

> Rebuild-mode-only verification steps extracted from verify-sc-verification.md.
> **Read this file ONLY when Origin=rebuild** (from sdd-state.md scenario config).
> For the main SC verification flow, see [verify-sc-verification.md](verify-sc-verification.md).
> For common gates (Bug Fix Severity, Source Modification Gate), see [verify-phases.md](verify-phases.md).

---

## Step 3-rebuild: Visual Fidelity + Source App Comparison

> These steps are rebuild-mode-only. They appear in the Phase 3 Checklist as a single checkpoint
> after all interface-generic steps (Steps 3–3g) are complete.

---

### Step 3-rebuild-a — Visual Fidelity Check (rebuild mode only — skip for greenfield/add)

If `specs/reverse-spec/visual-references/manifest.md` exists AND this Feature covers screens listed in the manifest:

1. Read the manifest to identify which reference screenshots apply to this Feature (match by screen name, route, or Feature coverage from pre-context)
2. For each matching screen:
   a. Navigate to the equivalent screen in the rebuilt app (use demo URL or route from spec.md)
   b. Take a screenshot of the current rebuilt state
   c. Read BOTH the reference screenshot and current screenshot
   d. Compare: layout structure, key element presence, obvious visual regressions
3. Report per screen:
   - `✅ Visual match` — layout structure and key elements consistent
   - `⚠️ Visual deviation` — describe specific differences (missing elements, layout shift, style mismatch, color/spacing drift)
   - `❌ Major regression` — screen fundamentally different or broken
4. **Result severity** varies by `preservation_level` (read from sdd-state.md Rebuild Configuration — see `domains/scenarios/rebuild.md` §S3):
   - `exact`: Visual deviations are ⚠️ HIGH WARNING (pixel-level match expected)
   - `equivalent`: Structural deviations are ⚠️ WARNING; minor spacing/color differences informational
   - `functional`: Visual fidelity check is informational only (UI may be intentionally redesigned)
5. User can acknowledge intentional deviations ("redesigned on purpose") vs. unintentional gaps during Review

If visual references don't exist or no screens match this Feature: skip silently.

---

### Step 3-rebuild-b — Source App Comparative Verification (rebuild mode only)

> Guard 3: Cross-Stage Trust Breakers — Gate 3 (verify Phase 3e). MANDATORY source app
> comparison for rebuild+GUI — independently verifies runtime-configurable settings against
> the source app, catching trust breaker errors that propagated through earlier stages.
> See pipeline-integrity-guards.md § Guard 3.
>
> Guard 7: Rebuild Fidelity Chain. Final verification in the fidelity chain — source app
> comparison confirms the rebuild matches the original. This is the BLOCKING endpoint of
> the chain that started at reverse-spec. See pipeline-integrity-guards.md § Guard 7.

> In rebuild mode, compare the rebuilt app against the original running app for behavioral parity.
> Only when Origin=`rebuild` AND `source_available: running` in sdd-state.md scenario config.
> See [user-cooperation-protocol.md](../reference/user-cooperation-protocol.md) § Source App Access.

**Skip conditions**:
- Not rebuild mode, OR Source Path is N/A → skip entirely

> **🚫 MANDATORY for rebuild + GUI**: When Origin=`rebuild` AND `gui` is in active Interfaces, source app comparison is BLOCKING, not optional. The agent MUST attempt to start and compare against the source app. Without source comparison, errors like wrong layout mode defaults propagate undetected through the entire pipeline (see SKF-014, SKF-024).

**Prerequisite**: Source app must be running. Detection:
1. Read Source Path from sdd-state.md
2. Probe source app (curl health endpoint or process check)
3. If not running → **attempt to start** the source app (read the project's script configuration, try the detected dev start command)
4. If start attempt fails → **Fallback to static visual references**:
   a. Check if `specs/reverse-spec/visual-references/manifest.md` exists
   b. If exists → use static screenshots for comparison (same as Step 3-rebuild-a) and record: `⚠️ Source app unavailable — used static visual references as fallback`
   c. If no static references either → **HARD STOP** — Use AskUserQuestion:
      ```
      ⚠️ Source App Comparison BLOCKED for rebuild GUI Feature [FID]:
        Source app: cannot be started ([reason])
        Static visual references: not found

      Without ANY visual reference, parity verification is impossible.
      Feature verify status will be "unverified-visual" (not "success").
      ```
      - "Start source app manually — I'll provide the port" → agent captures reference and compares
      - "Provide screenshots — I'll place them in visual-references/" → user provides, agent re-checks
      - "Acknowledge — proceed with unverified-visual status" → record `⚠️ UNVERIFIED-VISUAL` in sdd-state.md (Feature status = `limited`, not `success`)
      **If response is empty → re-ask** (per MANDATORY RULE 1)

   > **Why single "skip and acknowledge risk" is insufficient**: A single acknowledgment hides the severity. Marking the Feature as `limited` (not `success`) makes the gap visible in sdd-state.md and blocks merge unless the user explicitly overrides the verify-gate.

**Comparison procedure** (when both apps are running):

Comparison criteria vary by `preservation_level` (read from sdd-state.md Rebuild Configuration — see `domains/scenarios/rebuild.md` §S3):
- `exact`: Byte-level response comparison (API), pixel-level screenshot comparison (UI). Any deviation = ⚠️ WARNING
- `equivalent`: Data shape and semantic comparison. Format differences (JSON key order, whitespace) ignored. Same data values required
- `functional`: Goal-level comparison. Same user flow produces same outcome. UI appearance and API format may differ

1. For each page/route in this Feature:
   a. Navigate to the page in the REBUILT app → Snapshot A
   b. Navigate to the equivalent page in the SOURCE app → Snapshot B (requires separate browser context or port)
   c. Compare (apply criteria above):
      - Layout structure: element positions, container hierarchy
      - Data presentation: same data shape displayed
      - Interaction behavior: same click targets produce same outcomes
2. For API endpoints (if http-api interface):
   a. Send same request to both apps
   b. Compare response status codes and body shapes (apply criteria above)
3. Report:
   ```
   📊 Source App Comparison for [FID]:
     /settings page: ✅ Layout match, ✅ Data match
     /chat page: ⚠️ Layout deviation — sidebar width differs (240px vs 200px)
     GET /api/config: ✅ Response shape match
   ```

**Result**:
- **rebuild + GUI**: ⚠️ BLOCKING if layout structure deviations detected. The user must explicitly acknowledge each deviation before proceeding. Layout mode mismatches (e.g., sidebar vs tab mode) are Critical — cannot be acknowledged as "intentional" without justification.
- **rebuild + non-GUI**: ⚠️ warnings (NOT blocking). User can acknowledge intentional deviations during Review.
- **non-rebuild**: N/A (this step is rebuild-only).

**Note on dual-app management**: The agent manages both apps. Source app port must differ from rebuilt app port. If both are Electron, they need different CDP ports.
