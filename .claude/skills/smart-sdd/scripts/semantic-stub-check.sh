#!/usr/bin/env bash
# semantic-stub-check.sh — Detect semantic stubs in implemented code
# Read-only: does NOT modify any source files.
# Used by: implement.md (Semantic Stub Detection), verify-phases.md (Phase 3 sanity check)
#
# Usage: semantic-stub-check.sh <project-root> [--feature <FID>]
#   project-root: Project root containing source code
#   --feature: Optional Feature ID to scope checks
#
# Output: Detection results with ✅/🚫/⚠️ indicators (stdout)
# Exit code: 0 if no stubs found, 1 if any 🚫 semantic stubs detected

set -euo pipefail

show_help() {
  cat <<'HELP'
Usage: semantic-stub-check.sh <project-root> [--feature <FID>]

Detects semantic stubs — code that compiles and runs but doesn't actually work.
These pass build, type-check, and basic smoke tests but produce wrong results.

Detects:
  1. Random data where real computation expected (Math.random, uuid for embeddings)
  2. Placeholder returns (hardcoded arrays, empty results, TODO markers)
  3. External API bypasses (no network call where one is expected)
  4. Sort-by-date masquerading as relevance search
  5. No-op implementations (function exists but does nothing meaningful)

Exit code: 0 if clean, 1 if semantic stubs found
HELP
}

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

PROJECT_ROOT="${1:-}"
FEATURE=""
STUBS_FOUND=0
WARNINGS=0

if [[ -z "$PROJECT_ROOT" || "$PROJECT_ROOT" == "--help" || "$PROJECT_ROOT" == "-h" ]]; then
  show_help
  exit 0
fi

shift
while [[ $# -gt 0 ]]; do
  case "$1" in
    --feature) FEATURE="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; show_help; exit 1 ;;
  esac
done

cd "$PROJECT_ROOT"

echo "═══════════════════════════════════════════════"
echo "  Semantic Stub Detection"
echo "  Project: $(basename "$PROJECT_ROOT")"
[[ -n "$FEATURE" ]] && echo "  Feature: $FEATURE"
echo "═══════════════════════════════════════════════"
echo ""

# Determine which files to scan
SCAN_DIRS="src/"
[[ ! -d "src/" ]] && SCAN_DIRS="."

# ─── Pattern 1: Random data where real computation expected ───
echo "── Pattern 1: Random Data Stubs ──"

RANDOM_STUBS=$(grep -rn "Math\.random\|crypto\.randomBytes\|uuid\.\|nanoid\|Math\.floor.*Math\.random" \
  --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" \
  $SCAN_DIRS 2>/dev/null | \
  grep -i "embed\|vector\|score\|similar\|relevance\|weight\|feature\|predict\|inference" | \
  grep -v "node_modules\|\.test\.\|\.spec\.\|__test__" || true)

# Python patterns
RANDOM_STUBS_PY=$(grep -rn "random\.random\|random\.uniform\|random\.randint\|np\.random" \
  --include="*.py" \
  $SCAN_DIRS 2>/dev/null | \
  grep -i "embed\|vector\|score\|similar\|relevance\|weight\|feature\|predict" | \
  grep -v "test_\|_test\.\|conftest\|__pycache__" || true)

RANDOM_ALL="$RANDOM_STUBS$RANDOM_STUBS_PY"

if [[ -z "$RANDOM_ALL" ]]; then
  echo -e "  ${GREEN}✅${NC} No random data in computation paths"
else
  echo -e "  ${RED}🚫${NC} Random data found where real computation expected:"
  echo "$RANDOM_ALL" | while read -r line; do
    echo "     $line"
  done
  ((STUBS_FOUND++))
fi
echo ""

# ─── Pattern 2: Placeholder returns ───
echo "── Pattern 2: Placeholder Returns ──"

PLACEHOLDERS=$(grep -rn "return \[\]\|return {}\|return null\|return undefined\|return ''\|return \"\"" \
  --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" \
  $SCAN_DIRS 2>/dev/null | \
  grep -i "search\|find\|query\|fetch\|get\|load\|retrieve\|extract\|process\|generate\|compute\|calculate" | \
  grep -v "node_modules\|\.test\.\|\.spec\.\|__test__\|// early return\|// guard\|// fallback" || true)

PLACEHOLDERS_PY=$(grep -rn "return \[\]\|return {}\|return None\|return ''" \
  --include="*.py" \
  $SCAN_DIRS 2>/dev/null | \
  grep -i "search\|find\|query\|fetch\|get\|load\|retrieve\|extract\|process\|generate" | \
  grep -v "test_\|_test\.\|conftest\|__pycache__\|# early return\|# guard\|# fallback" || true)

PLACE_ALL="$PLACEHOLDERS$PLACEHOLDERS_PY"

if [[ -z "$PLACE_ALL" ]]; then
  echo -e "  ${GREEN}✅${NC} No suspicious placeholder returns"
else
  count=$(echo "$PLACE_ALL" | wc -l | tr -d ' ')
  echo -e "  ${YELLOW}⚠️${NC}  $count potential placeholder returns (verify manually):"
  echo "$PLACE_ALL" | head -5 | while read -r line; do
    echo "     $line"
  done
  [[ $count -gt 5 ]] && echo "     ... and $((count-5)) more"
  ((WARNINGS++))
fi
echo ""

# ─── Pattern 3: TODO/FIXME/HACK markers ───
echo "── Pattern 3: Unresolved TODO/FIXME Markers ──"

TODOS=$(grep -rn "TODO\|FIXME\|HACK\|XXX\|PLACEHOLDER\|STUB" \
  --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" --include="*.py" --include="*.go" --include="*.rs" \
  $SCAN_DIRS 2>/dev/null | \
  grep -v "node_modules\|\.test\.\|\.spec\.\|__test__\|__pycache__" || true)

if [[ -z "$TODOS" ]]; then
  echo -e "  ${GREEN}✅${NC} No TODO/FIXME/STUB markers"
else
  todo_count=$(echo "$TODOS" | wc -l | tr -d ' ')
  stub_count=$(echo "$TODOS" | grep -ci "STUB\|PLACEHOLDER\|HACK" || true)

  if [[ $stub_count -gt 0 ]]; then
    echo -e "  ${RED}🚫${NC} $stub_count STUB/PLACEHOLDER/HACK markers found:"
    echo "$TODOS" | grep -i "STUB\|PLACEHOLDER\|HACK" | while read -r line; do
      echo "     $line"
    done
    ((STUBS_FOUND++))
  fi

  remaining=$((todo_count - stub_count))
  if [[ $remaining -gt 0 ]]; then
    echo -e "  ${YELLOW}⚠️${NC}  $remaining TODO/FIXME markers (may be intentional):"
    echo "$TODOS" | grep -vi "STUB\|PLACEHOLDER\|HACK" | head -5 | while read -r line; do
      echo "     $line"
    done
    ((WARNINGS++))
  fi
fi
echo ""

# ─── Pattern 4: Sort-by-date masquerading as relevance ───
echo "── Pattern 4: Fake Search (sort-by-date instead of relevance) ──"

FAKE_SEARCH=$(grep -rn "sort.*date\|sort.*created\|sort.*updated\|orderBy.*date\|ORDER BY.*date\|ORDER BY.*created" \
  --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" --include="*.py" \
  $SCAN_DIRS 2>/dev/null | \
  grep -i "search\|find\|query\|relevant\|similar\|match" | \
  grep -v "node_modules\|\.test\.\|\.spec\.\|__test__\|__pycache__" || true)

if [[ -z "$FAKE_SEARCH" ]]; then
  echo -e "  ${GREEN}✅${NC} No date-sorted results in search functions"
else
  echo -e "  ${RED}🚫${NC} Search function uses date sorting instead of relevance:"
  echo "$FAKE_SEARCH" | while read -r line; do
    echo "     $line"
  done
  ((STUBS_FOUND++))
fi
echo ""

# ─── Pattern 5: External API call bypassed ───
echo "── Pattern 5: External API Bypass ──"

# Find functions that should call external APIs but don't
API_FUNCS=$(grep -rn "async.*embed\|async.*generate\|async.*predict\|async.*inference\|async.*classify\|async.*extract" \
  --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" \
  $SCAN_DIRS 2>/dev/null | \
  grep -v "node_modules\|\.test\.\|\.spec\.\|__test__" || true)

if [[ -n "$API_FUNCS" ]]; then
  # For each, check if there's a fetch/axios/api call nearby
  echo "$API_FUNCS" | while read -r line; do
    file=$(echo "$line" | cut -d: -f1)
    lineno=$(echo "$line" | cut -d: -f2)

    # Check ±20 lines for network calls
    start=$((lineno > 20 ? lineno - 20 : 1))
    end=$((lineno + 20))

    has_call=$(sed -n "${start},${end}p" "$file" 2>/dev/null | grep -c "fetch\|axios\|\.post\|\.get\|api\.\|invoke\|request\|http\|client\." || true)

    if [[ $has_call -eq 0 ]]; then
      echo -e "  ${YELLOW}⚠️${NC}  $file:$lineno — async function with no network/API call nearby"
      ((WARNINGS++))
    fi
  done
fi

[[ -z "$API_FUNCS" ]] && echo -e "  ${GREEN}✅${NC} No async compute functions found (or not applicable)"
echo ""

echo "═══════════════════════════════════════════════"
echo -e "  Results: ${RED}🚫 $STUBS_FOUND semantic stubs${NC}  ${YELLOW}⚠️ $WARNINGS warnings${NC}"
echo "═══════════════════════════════════════════════"

if [[ $STUBS_FOUND -gt 0 ]]; then
  echo ""
  echo -e "  ${RED}SEMANTIC STUBS DETECTED — code compiles but doesn't work correctly${NC}"
  echo "  Fix stubs before proceeding to verify."
  exit 1
else
  exit 0
fi
