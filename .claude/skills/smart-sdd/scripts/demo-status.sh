#!/usr/bin/env bash
# demo-status.sh — Demo Group progress dashboard for smart-sdd
# Read-only: does NOT modify any artifacts.
# Used by: add Step 5 (Demo Group Assignment), verify post-check
#
# Usage: demo-status.sh <target-path>
#   target-path: Project root containing specs/ directory
#
# Output: Demo Group progress summary (stdout)

set -euo pipefail

show_help() {
  cat <<'HELP'
Usage: demo-status.sh <target-path>

Displays Demo Group progress from sdd-state.md.

Arguments:
  target-path   Project root containing specs/ directory

Output:
  Per-group status: scenario, feature count, completion, status
HELP
  exit 0
}

[[ "${1:-}" == "--help" || "${1:-}" == "-h" ]] && show_help
[[ -z "${1:-}" ]] && { echo "Usage: demo-status.sh <target-path>"; exit 1; }

TARGET="$1"
STATE="$TARGET/specs/reverse-spec/sdd-state.md"

if [[ ! -f "$STATE" ]]; then
  echo "N/A — no sdd-state.md found"
  exit 0
fi

# Check if Demo Group Progress section exists
if ! grep -q '## Demo Group Progress' "$STATE" 2>/dev/null; then
  echo "N/A — no Demo Group Progress section in sdd-state.md"
  exit 0
fi

# Extract DG lines
dg_lines=$(sed -n '/## Demo Group Progress/,/^## /p' "$STATE" | grep -E '^\| DG-[0-9]+' || true)

if [[ -z "$dg_lines" ]]; then
  echo "No Demo Groups defined."
  exit 0
fi

dg_count=$(echo "$dg_lines" | wc -l | tr -d ' ')
echo "Demo Groups: $dg_count"
echo ""

echo "$dg_lines" | while IFS='|' read -r _ group scenario features completed status last_demo _rest; do
  group=$(echo "$group" | xargs)
  scenario=$(echo "$scenario" | xargs)
  features=$(echo "$features" | xargs)
  completed=$(echo "$completed" | xargs)
  status=$(echo "$status" | xargs)
  last_demo=$(echo "$last_demo" | xargs)

  # Determine display icon
  icon="⏳"
  if echo "$status" | grep -q "All verified"; then
    icon="✅"
  elif echo "$status" | grep -q "re-run"; then
    icon="🔄"
  fi

  printf "  %s %-30s | %s | Last: %s\n" "$icon" "$group $scenario" "$completed" "${last_demo:-—}"

  # Show waiting features
  waiting=$(echo "$status" | grep -oE 'F[0-9]+-[a-zA-Z0-9_-]+' || true)
  if [[ -n "$waiting" ]]; then
    echo "     Waiting: $waiting"
  fi
done
