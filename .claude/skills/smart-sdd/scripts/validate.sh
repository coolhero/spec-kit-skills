#!/usr/bin/env bash
# validate.sh — Cross-file consistency validation for smart-sdd
# Read-only: does NOT modify any artifacts.
# Used by: pipeline.md (Phase 0 completion + all Features completed), status.md (on-demand)
#
# Usage: validate.sh <target-path>
#   target-path: Project root containing specs/ directory
#
# Output: Validation results with ✅/⚠️/❌ indicators (stdout)
# Exit code: 0 if all pass, 1 if any ❌ found

set -euo pipefail

show_help() {
  cat <<'HELP'
Usage: validate.sh <target-path>

Validates cross-file consistency across smart-sdd artifacts.

Arguments:
  target-path   Project root containing specs/ directory

Checks:
  - Feature IDs in roadmap.md match sdd-state.md
  - Entity registry references match Feature plans
  - SBI mappings are consistent across artifacts
  - Demo Group Feature references exist in roadmap

Exit code: 0 if all pass, 1 if any errors found
HELP
  exit 0
}

[[ "${1:-}" == "--help" || "${1:-}" == "-h" ]] && show_help
[[ -z "${1:-}" ]] && { echo "Usage: validate.sh <target-path>"; exit 1; }

TARGET="$1"
BASE="$TARGET/specs/reverse-spec"
SPECS="$TARGET/specs"
STATE="$BASE/sdd-state.md"
ROADMAP="$BASE/roadmap.md"
ENTITY_REG="$BASE/entity-registry.md"
API_REG="$BASE/api-registry.md"

errors=0
warnings=0

pass() { echo "  ✅ $1"; }
warn() { echo "  ⚠️ $1"; warnings=$((warnings + 1)); }
fail() { echo "  ❌ $1"; errors=$((errors + 1)); }

echo "Validating: $TARGET"
echo ""

# ── Check 1: Required files exist ──
echo "── File Existence ──"
for f in "$STATE" "$ROADMAP"; do
  if [[ -f "$f" ]]; then
    pass "$(basename "$f") exists"
  else
    fail "$(basename "$f") missing"
  fi
done
for f in "$ENTITY_REG" "$API_REG"; do
  if [[ -f "$f" ]]; then
    pass "$(basename "$f") exists"
  else
    warn "$(basename "$f") missing (optional)"
  fi
done
echo ""

# ── Check 2: Feature ID consistency (roadmap ↔ sdd-state) ──
echo "── Feature ID Consistency ──"
if [[ -f "$ROADMAP" && -f "$STATE" ]]; then
  roadmap_ids=$(grep -oE 'F[0-9]+' "$ROADMAP" | sort -u)
  state_ids=$(grep -E '^\| F[0-9]+' "$STATE" | grep -oE 'F[0-9]+' | sort -u)

  # IDs in roadmap but not in state
  for id in $roadmap_ids; do
    if ! echo "$state_ids" | grep -q "^${id}$"; then
      warn "$id in roadmap.md but not in sdd-state.md"
    fi
  done

  # IDs in state but not in roadmap
  for id in $state_ids; do
    if ! echo "$roadmap_ids" | grep -q "^${id}$"; then
      fail "$id in sdd-state.md but not in roadmap.md"
    fi
  done

  matching=$(comm -12 <(echo "$roadmap_ids") <(echo "$state_ids") | wc -l | tr -d ' ')
  pass "Feature IDs: $matching matched between roadmap and state"
else
  warn "Skipped — missing roadmap.md or sdd-state.md"
fi
echo ""

# ── Check 3: Pre-context files exist for all Features ──
echo "── Pre-context Files ──"
if [[ -f "$STATE" ]]; then
  while IFS='|' read -r _ feat_id feat_name _rest; do
    fid=$(echo "$feat_id" | xargs)
    fname=$(echo "$feat_name" | xargs)
    if [[ -z "$fid" || ! "$fid" =~ ^F[0-9]+ ]]; then continue; fi
    short="${fid#F}"  # Remove F prefix
    short="${short#0}" # Remove leading zeros for glob
    # Try to find pre-context
    pc=$(find "$BASE/features/" -maxdepth 2 -name "pre-context.md" -path "*${fid}*" -o -name "pre-context.md" -path "*${fname}*" 2>/dev/null | head -1)
    if [[ -n "$pc" ]]; then
      pass "$fid pre-context.md exists"
    else
      warn "$fid pre-context.md not found"
    fi
  done < <(grep -E '^\| F[0-9]+' "$STATE" 2>/dev/null)
else
  warn "Skipped — no sdd-state.md"
fi
echo ""

# ── Check 4: SBI mapping consistency ──
echo "── SBI Coverage Consistency ──"
if [[ -f "$STATE" ]] && grep -q '## Source Behavior Coverage' "$STATE"; then
  sbi_mapped=$(sed -n '/## Source Behavior Coverage/,/^## /p' "$STATE" | grep -E '^\| B[0-9]+' | grep -v '❌ unmapped' | grep -v '🔒 deferred' || true)

  if [[ -n "$sbi_mapped" ]]; then
    # Check that mapped FR-### references exist in corresponding spec.md
    issues=0
    checked=0
    while IFS='|' read -r _ sbi_id priority fr_ref feature _status _rest; do
      fr=$(echo "$fr_ref" | xargs)
      feat=$(echo "$feature" | xargs)
      if [[ "$fr" == "—" || -z "$fr" ]]; then continue; fi
      checked=$((checked + 1))

      # Find the spec.md for this Feature
      feat_lower=$(echo "$feat" | sed 's/F0*//' | head -1)
      spec_files=$(find "$SPECS" -maxdepth 2 -name "spec.md" 2>/dev/null || true)
      found=false
      for sf in $spec_files; do
        if grep -q "$fr" "$sf" 2>/dev/null; then
          found=true
          break
        fi
      done
      if ! $found && [[ -n "$spec_files" ]]; then
        warn "$(echo "$sbi_id" | xargs) mapped to $fr but not found in any spec.md"
        issues=$((issues + 1))
      fi
    done <<< "$sbi_mapped"

    if [[ "$issues" -eq 0 && "$checked" -gt 0 ]]; then
      pass "SBI mappings: $checked checked, all consistent"
    elif [[ "$checked" -eq 0 ]]; then
      pass "SBI mappings: no mapped entries to check"
    fi
  else
    pass "SBI: no mapped entries to validate"
  fi
else
  pass "SBI: not applicable (no SBI section)"
fi
echo ""

# ── Check 5: Demo Group Feature references ──
echo "── Demo Group Consistency ──"
if [[ -f "$STATE" ]] && grep -q '## Demo Group Progress' "$STATE"; then
  dg_lines=$(sed -n '/## Demo Group Progress/,/^## /p' "$STATE" | grep -E '^\| DG-[0-9]+' || true)

  if [[ -n "$dg_lines" ]]; then
    while IFS='|' read -r _ group scenario features _rest; do
      group=$(echo "$group" | xargs)
      features=$(echo "$features" | xargs)

      # Extract Feature IDs from the features field
      feat_ids=$(echo "$features" | grep -oE 'F[0-9]+' || true)
      for fid in $feat_ids; do
        if [[ -f "$ROADMAP" ]] && ! grep -q "$fid" "$ROADMAP"; then
          fail "$group references $fid but $fid not in roadmap.md"
        fi
      done
    done <<< "$dg_lines"
    pass "Demo Group Feature references checked"
  else
    pass "No Demo Groups to validate"
  fi
else
  pass "Demo Groups: not applicable"
fi

# ── Summary ──
echo ""
echo "── Summary ──"
if [[ "$errors" -gt 0 ]]; then
  echo "  ❌ $errors error(s), $warnings warning(s)"
  exit 1
elif [[ "$warnings" -gt 0 ]]; then
  echo "  ⚠️ $warnings warning(s), no errors"
  exit 0
else
  echo "  ✅ All checks passed"
  exit 0
fi
