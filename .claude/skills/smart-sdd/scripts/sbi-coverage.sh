#!/usr/bin/env bash
# sbi-coverage.sh — SBI coverage dashboard for smart-sdd
# Read-only: does NOT modify any artifacts.
# Used by: verify post-check, add Phase 4 (SBI Match + Expansion)
#
# Usage: sbi-coverage.sh <target-path> [--filter <keywords>]
#   target-path: Project root containing specs/ directory
#   --filter:    Space-separated keywords to filter SBI entries
#
# Output: SBI coverage summary and optional filtered detail (stdout)
# Supports Origin column (extracted/new) — backward compatible with legacy format

set -euo pipefail

show_help() {
  cat <<'HELP'
Usage: sbi-coverage.sh <target-path> [--filter <keywords>]

Displays Source Behavior Inventory (SBI) coverage dashboard.

Arguments:
  target-path       Project root containing specs/ directory
  --filter <words>  Filter SBI entries matching keywords (space-separated)

Output:
  P1/P2/P3 coverage percentages (extracted behaviors only)
  NEW behaviors summary (if any)
  Overall coverage
  Filtered detail (if --filter provided)

Only applicable to projects with Origin: rebuild, adoption, or add-mode with SBI.
HELP
  exit 0
}

[[ "${1:-}" == "--help" || "${1:-}" == "-h" ]] && show_help
[[ -z "${1:-}" ]] && { echo "Usage: sbi-coverage.sh <target-path> [--filter <keywords>]"; exit 1; }

TARGET="$1"
shift
FILTER=""
if [[ "${1:-}" == "--filter" ]]; then
  shift
  FILTER="$*"
fi

STATE="$TARGET/specs/_global/sdd-state.md"

if [[ ! -f "$STATE" ]]; then
  echo "N/A — no sdd-state.md found at $TARGET/specs/_global/"
  exit 0
fi

# Check if Source Behavior Coverage section exists
if ! grep -q '## Source Behavior Coverage' "$STATE" 2>/dev/null; then
  echo "N/A — no Source Behavior Coverage section in sdd-state.md"
  echo "(Only populated for rebuild/adoption projects or add-mode with SBI)"
  exit 0
fi

# Extract SBI table lines (B### entries)
sbi_lines=$(sed -n '/## Source Behavior Coverage/,/^## /p' "$STATE" | grep -E '^\| B[0-9]+' || true)

if [[ -z "$sbi_lines" ]]; then
  echo "No SBI entries found."
  exit 0
fi

# Detect if Origin column exists (8+ pipe-separated fields = has Origin)
has_origin=false
first_line=$(echo "$sbi_lines" | head -1)
col_count=$(echo "$first_line" | awk -F'|' '{print NF}')
if [[ "$col_count" -ge 8 ]]; then
  has_origin=true
fi

# Separate extracted vs new entries
if $has_origin; then
  extracted_lines=$(echo "$sbi_lines" | grep -E '\| extracted \|' || true)
  new_lines=$(echo "$sbi_lines" | grep -E '\| new \|' || true)
else
  # Legacy format (no Origin column): treat all entries as extracted
  extracted_lines="$sbi_lines"
  new_lines=""
fi

# Count by priority and status
count_by() {
  local lines="$1" priority="$2" status="$3"
  if [[ -z "$lines" ]]; then
    echo 0
    return
  fi
  echo "$lines" | grep -E "^\| B[0-9]+ \| $priority " | grep -c "$status" 2>/dev/null || echo 0
}

total_by() {
  local lines="$1" priority="$2"
  if [[ -z "$lines" ]]; then
    echo 0
    return
  fi
  echo "$lines" | grep -cE "^\| B[0-9]+ \| $priority " 2>/dev/null || echo 0
}

# Extracted coverage (P1/P2/P3) — original source behaviors only
for p in P1 P2 P3; do
  total=$(total_by "$extracted_lines" "$p")
  verified=$(count_by "$extracted_lines" "$p" "verified")
  if [[ "$total" -gt 0 ]]; then
    pct=$((verified * 100 / total))
    icon="⚠️"
    [[ "$pct" -eq 100 ]] && icon="✅"
    echo "$p: $verified/$total ($pct%) $icon"
  else
    echo "$p: 0/0 (N/A)"
  fi
done

# Overall (extracted only)
if [[ -n "$extracted_lines" ]]; then
  overall_total=$(echo "$extracted_lines" | wc -l | tr -d ' ')
  overall_verified=$(echo "$extracted_lines" | grep -c "verified" 2>/dev/null || echo 0)
  if [[ "$overall_total" -gt 0 ]]; then
    overall_pct=$((overall_verified * 100 / overall_total))
    echo "Overall: $overall_verified/$overall_total ($overall_pct%)"
  else
    echo "Overall: 0/0 (N/A)"
  fi
else
  echo "Overall: 0/0 (N/A)"
fi

# NEW behaviors summary (separate from original source metrics)
if [[ -n "$new_lines" ]]; then
  echo ""
  echo "── NEW Behaviors ──"
  new_total=$(echo "$new_lines" | wc -l | tr -d ' ')
  new_verified=$(echo "$new_lines" | grep -c "verified" 2>/dev/null || echo 0)
  new_in_prog=$(echo "$new_lines" | grep -c "in_progress" 2>/dev/null || echo 0)
  new_unmapped=$(echo "$new_lines" | grep -c "unmapped" 2>/dev/null || echo 0)
  echo "NEW: $new_total total ($new_verified verified, $new_in_prog in_progress, $new_unmapped unmapped)"
fi

# Filtered detail (searches ALL entries — both extracted and new)
if [[ -n "$FILTER" ]]; then
  echo ""
  echo "── Filter: $FILTER ──"
  matched=false
  while IFS= read -r line; do
    match=true
    for kw in $FILTER; do
      if ! echo "$line" | grep -qi "$kw"; then
        match=false
        break
      fi
    done
    if $match; then
      echo "$line"
      matched=true
    fi
  done <<< "$sbi_lines"
  if ! $matched; then
    echo "(no matches)"
  fi
fi
