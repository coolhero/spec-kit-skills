#!/usr/bin/env bash
# pipeline-status.sh — Pipeline progress overview for smart-sdd
# Read-only: does NOT modify any artifacts.
# Used by: Session orientation, status checks
#
# Usage: pipeline-status.sh <target-path>
#   target-path: Project root containing specs/ directory
#
# Output: Pipeline progress overview (stdout)

set -euo pipefail

show_help() {
  cat <<'HELP'
Usage: pipeline-status.sh <target-path>

Displays pipeline progress overview from sdd-state.md.

Arguments:
  target-path   Project root containing specs/ directory

Output:
  Project info, constitution status, progress summary,
  current Feature, blocked items, deferred count
HELP
  exit 0
}

[[ "${1:-}" == "--help" || "${1:-}" == "-h" ]] && show_help
[[ -z "${1:-}" ]] && { echo "Usage: pipeline-status.sh <target-path>"; exit 1; }

TARGET="$1"
STATE="$TARGET/specs/_global/sdd-state.md"

if [[ ! -f "$STATE" ]]; then
  echo "N/A — no sdd-state.md found at $TARGET/specs/_global/"
  exit 0
fi

# ── Project Info ──
project=$(grep -oE '\*\*Project\*\*: .+' "$STATE" 2>/dev/null | sed 's/\*\*Project\*\*: //' | head -1)
origin=$(grep -oE '\*\*Origin\*\*: .+' "$STATE" 2>/dev/null | sed 's/\*\*Origin\*\*: //' | head -1)
scope=$(grep -oE '\*\*Scope\*\*: .+' "$STATE" 2>/dev/null | sed 's/\*\*Scope\*\*: //' | head -1)
tiers=$(grep -oE '\*\*Active Tiers\*\*: .+' "$STATE" 2>/dev/null | sed 's/\*\*Active Tiers\*\*: //' | head -1)

echo "Project: ${project:-unknown} | Origin: ${origin:-unknown} | Scope: ${scope:-unknown}"
[[ -n "$tiers" ]] && echo "Active Tiers: $tiers"

# ── Constitution ──
const_status=$(sed -n '/## Constitution/,/^## /p' "$STATE" | grep -oE '(pending|completed)' | head -1)
const_version=$(grep -oE '\*\*Constitution Version\*\*: .+' "$STATE" 2>/dev/null | sed 's/\*\*Constitution Version\*\*: //' | head -1)
if [[ "$const_status" == "completed" ]]; then
  echo "Constitution: ✅ v${const_version:-?}"
else
  echo "Constitution: ⏳ pending"
fi

# ── Feature Progress ──
total=$(grep -cE '^\| F[0-9]+' "$STATE" 2>/dev/null || echo 0)
completed=$(grep -cE '^\| F[0-9]+.*\| completed' "$STATE" 2>/dev/null || echo 0)
adopted=$(grep -cE '^\| F[0-9]+.*\| adopted' "$STATE" 2>/dev/null || echo 0)
done_count=$((completed + adopted))

if [[ "$total" -gt 0 ]]; then
  pct=$((done_count * 100 / total))
  echo "Progress: $done_count/$total completed ($pct%)"
else
  echo "Progress: no Features"
fi

# ── Current Feature ──
current=$(grep -E '^\| F[0-9]+.*\| in_progress' "$STATE" 2>/dev/null | head -1 || true)
if [[ -n "$current" ]]; then
  feat_id=$(echo "$current" | grep -oE 'F[0-9]+' | head -1)
  feat_name=$(echo "$current" | awk -F'|' '{print $3}' | xargs)
  # Find current step (last 🔄)
  current_step=$(echo "$current" | grep -oE '🔄' | wc -l | tr -d ' ')
  last_done=$(echo "$current" | grep -oE '✅' | wc -l | tr -d ' ')
  steps=("specify" "plan" "tasks" "analyze" "implement" "verify" "merge")
  step_name="${steps[$last_done]:-next}"
  echo "Current: $feat_id-$feat_name ($step_name)"
else
  echo "Current: none in progress"
fi

# ── Blocked ──
blocked=$(grep -cE '^\| F[0-9]+.*❌' "$STATE" 2>/dev/null || echo 0)
if [[ "$blocked" -gt 0 ]]; then
  echo "Blocked: $blocked Feature(s) with failures"
else
  echo "Blocked: none"
fi

# ── Deferred ──
deferred=$(grep -cE '^\| F[0-9]+.*\| deferred' "$STATE" 2>/dev/null || echo 0)
if [[ "$deferred" -gt 0 ]]; then
  deferred_tiers=$(grep -E '^\| F[0-9]+.*\| deferred' "$STATE" 2>/dev/null | grep -oE 'T[0-9]' | sort -u | tr '\n' ',' | sed 's/,$//')
  echo "Deferred: $deferred Features ($deferred_tiers)"
fi
