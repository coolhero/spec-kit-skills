#!/usr/bin/env bash
# sbi-coverage.sh — SBI coverage dashboard for smart-sdd
# Read-only: does NOT modify any artifacts.
# Used by: verify post-check, add Step 4 (SBI Match)
#
# Usage: sbi-coverage.sh <target-path> [--filter <keywords>]
#   target-path: Project root containing specs/ directory
#   --filter:    Space-separated keywords to filter SBI entries
#
# Output: SBI coverage summary and optional filtered detail (stdout)

set -euo pipefail

show_help() {
  cat <<'HELP'
Usage: sbi-coverage.sh <target-path> [--filter <keywords>]

Displays Source Behavior Inventory (SBI) coverage dashboard.

Arguments:
  target-path       Project root containing specs/ directory
  --filter <words>  Filter SBI entries matching keywords (space-separated)

Output:
  P1/P2/P3 coverage percentages
  Overall coverage
  Filtered detail (if --filter provided)

Only applicable to projects with Origin: rebuild or adoption.
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

STATE="$TARGET/specs/reverse-spec/sdd-state.md"

if [[ ! -f "$STATE" ]]; then
  echo "N/A — no sdd-state.md found at $TARGET/specs/reverse-spec/"
  exit 0
fi

# Check if Source Behavior Coverage section exists
if ! grep -q '## Source Behavior Coverage' "$STATE" 2>/dev/null; then
  echo "N/A — no Source Behavior Coverage section in sdd-state.md"
  echo "(Only populated for rebuild/adoption projects)"
  exit 0
fi

# Extract SBI table lines (B### entries)
sbi_lines=$(sed -n '/## Source Behavior Coverage/,/^## /p' "$STATE" | grep -E '^\| B[0-9]+' || true)

if [[ -z "$sbi_lines" ]]; then
  echo "No SBI entries found."
  exit 0
fi

# Count by priority and status
count_by() {
  local priority="$1" status="$2"
  echo "$sbi_lines" | grep -E "^\| B[0-9]+ \| $priority " | grep -c "$status" 2>/dev/null || echo 0
}

total_by() {
  local priority="$1"
  echo "$sbi_lines" | grep -cE "^\| B[0-9]+ \| $priority " 2>/dev/null || echo 0
}

for p in P1 P2 P3; do
  total=$(total_by "$p")
  verified=$(count_by "$p" "verified")
  in_prog=$(count_by "$p" "in_progress")
  if [[ "$total" -gt 0 ]]; then
    pct=$((verified * 100 / total))
    icon="⚠️"
    [[ "$pct" -eq 100 ]] && icon="✅"
    echo "$p: $verified/$total ($pct%) $icon"
  else
    echo "$p: 0/0 (N/A)"
  fi
done

# Overall
overall_total=$(echo "$sbi_lines" | wc -l | tr -d ' ')
overall_verified=$(echo "$sbi_lines" | grep -c "verified" 2>/dev/null || echo 0)
if [[ "$overall_total" -gt 0 ]]; then
  overall_pct=$((overall_verified * 100 / overall_total))
  echo "Overall: $overall_verified/$overall_total ($overall_pct%)"
else
  echo "Overall: 0/0 (N/A)"
fi

# Filtered detail
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
