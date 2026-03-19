#!/usr/bin/env bash
# context-summary.sh — Aggregated context summary for smart-sdd
# Read-only: does NOT modify any artifacts.
# Used by: add Step 2 (Impact Analysis), session orientation
#
# Usage: context-summary.sh <target-path>
#   target-path: Project root containing specs/ directory
#
# Output: Feature/Entity/API/DemoGroup summary (stdout)

set -euo pipefail

show_help() {
  cat <<'HELP'
Usage: context-summary.sh <target-path>

Generates a concise context summary from project artifacts.

Arguments:
  target-path   Project root containing specs/ directory

Output:
  Features:     Count and status breakdown
  Entities:     Count and names from entity-registry.md
  APIs:         Endpoint count from api-registry.md
  Demo Groups:  Group status from sdd-state.md
HELP
  exit 0
}

[[ "${1:-}" == "--help" || "${1:-}" == "-h" ]] && show_help
[[ -z "${1:-}" ]] && { echo "Usage: context-summary.sh <target-path>"; exit 1; }

TARGET="$1"
BASE="$TARGET/specs/_global"
STATE="$BASE/sdd-state.md"

# ── Features ──
if [[ -f "$STATE" ]]; then
  total=$(grep -cE '^\| F[0-9]+' "$STATE" 2>/dev/null || echo 0)
  completed=$(grep -cE '^\| F[0-9]+.*\| completed' "$STATE" 2>/dev/null || echo 0)
  adopted=$(grep -cE '^\| F[0-9]+.*\| adopted' "$STATE" 2>/dev/null || echo 0)
  in_progress=$(grep -cE '^\| F[0-9]+.*\| in_progress' "$STATE" 2>/dev/null || echo 0)
  pending=$(grep -cE '^\| F[0-9]+.*\| pending' "$STATE" 2>/dev/null || echo 0)
  deferred=$(grep -cE '^\| F[0-9]+.*\| deferred' "$STATE" 2>/dev/null || echo 0)

  status_parts=()
  [[ "$completed" -gt 0 ]] && status_parts+=("$completed completed")
  [[ "$adopted" -gt 0 ]] && status_parts+=("$adopted adopted")
  [[ "$in_progress" -gt 0 ]] && status_parts+=("$in_progress in_progress")
  [[ "$pending" -gt 0 ]] && status_parts+=("$pending pending")
  [[ "$deferred" -gt 0 ]] && status_parts+=("$deferred deferred")

  joined=$(IFS=', '; echo "${status_parts[*]}")
  echo "Features: $total (${joined:-none})"
else
  echo "Features: N/A (no sdd-state.md)"
fi

# ── Entities ──
ENTITY_REG="$BASE/entity-registry.md"
if [[ -f "$ENTITY_REG" ]]; then
  entity_count=$(grep -cE '^### ' "$ENTITY_REG" 2>/dev/null || echo 0)
  entity_names=$(grep -oE '^### (.+)' "$ENTITY_REG" 2>/dev/null | sed 's/^### //' | head -10 | tr '\n' ', ' | sed 's/, $//')
  echo "Entities: $entity_count ($entity_names)"
else
  echo "Entities: N/A (no entity-registry.md)"
fi

# ── APIs ──
API_REG="$BASE/api-registry.md"
if [[ -f "$API_REG" ]]; then
  api_count=$(grep -cE '^\| (GET|POST|PUT|PATCH|DELETE|HEAD|OPTIONS) ' "$API_REG" 2>/dev/null || echo 0)
  echo "APIs: $api_count endpoints"
else
  echo "APIs: N/A (no api-registry.md)"
fi

# ── Demo Groups ──
if [[ -f "$STATE" ]]; then
  dg_lines=$(grep -E '^\| DG-[0-9]+' "$STATE" 2>/dev/null || true)
  if [[ -n "$dg_lines" ]]; then
    dg_count=$(echo "$dg_lines" | wc -l | tr -d ' ')
    echo "Demo Groups: $dg_count"
    echo "$dg_lines" | while IFS='|' read -r _ group scenario features completed status _rest; do
      group=$(echo "$group" | xargs)
      scenario=$(echo "$scenario" | xargs)
      completed=$(echo "$completed" | xargs)
      status=$(echo "$status" | xargs)
      echo "  $group: $scenario — $completed ($status)"
    done
  else
    echo "Demo Groups: none defined"
  fi
else
  echo "Demo Groups: N/A"
fi

# ── Origin & Scope ──
if [[ -f "$STATE" ]]; then
  origin=$(grep -oE '\*\*Origin\*\*: .+' "$STATE" 2>/dev/null | sed 's/\*\*Origin\*\*: //' | head -1)
  scope=$(grep -oE '\*\*Scope\*\*: .+' "$STATE" 2>/dev/null | sed 's/\*\*Scope\*\*: //' | head -1)
  echo "Origin: ${origin:-unknown} | Scope: ${scope:-unknown}"
fi
