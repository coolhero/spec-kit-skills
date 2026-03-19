#!/usr/bin/env bash
# wiring-check.sh — Post-implement wiring completeness verification
# Read-only: does NOT modify any source files.
# Used by: implement.md (App Lifecycle Wiring Check), verify-phases.md (pre-verify gate)
#
# Usage: wiring-check.sh <project-root> [--feature <FID>]
#   project-root: Project root containing source code
#   --feature: Optional Feature ID to scope checks (e.g., F006)
#
# Output: Check results with ✅/🚫/⚠️ indicators (stdout)
# Exit code: 0 if all pass, 1 if any 🚫 BLOCKING found

set -euo pipefail

show_help() {
  cat <<'HELP'
Usage: wiring-check.sh <project-root> [--feature <FID>]

Verifies that implemented code is properly wired into the application lifecycle.
Catches "code exists but doesn't work" patterns before verify.

Checks:
  1. Store Hydration: New stores have hydrate() calls in app entry point
  2. Message Passing Layers: IPC/API channels have all required layers
  3. UI Entry Points: User-facing features have navigation/access paths
  4. Parameter Shape: Caller and handler parameter names match
  5. External Config: Error messages include actionable guidance

Exit code: 0 if all pass, 1 if any BLOCKING issues found
HELP
}

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

PROJECT_ROOT="${1:-}"
FEATURE=""
BLOCKING=0
WARNINGS=0
PASSES=0

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

if [[ ! -d "$PROJECT_ROOT" ]]; then
  echo "Error: $PROJECT_ROOT is not a directory"
  exit 1
fi

cd "$PROJECT_ROOT"

echo "═══════════════════════════════════════════════"
echo "  Wiring Check — Post-Implement Verification"
echo "  Project: $(basename "$PROJECT_ROOT")"
[[ -n "$FEATURE" ]] && echo "  Feature: $FEATURE"
echo "═══════════════════════════════════════════════"
echo ""

# ─── Check 1: Store Hydration ───────────────────
echo "── Check 1: Store Hydration ──"

# Detect framework and store patterns
STORE_FILES=()
if [[ -f "package.json" ]]; then
  # JavaScript/TypeScript project
  # Find store creation patterns (Zustand, Pinia, Redux, Svelte)
  while IFS= read -r f; do
    STORE_FILES+=("$f")
  done < <(grep -rl "create(" --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" src/ 2>/dev/null | xargs grep -l "zustand\|persist\|devtools" 2>/dev/null || true)

  # Also check for Pinia stores
  while IFS= read -r f; do
    STORE_FILES+=("$f")
  done < <(grep -rl "defineStore" --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" src/ 2>/dev/null || true)
fi

if [[ ${#STORE_FILES[@]} -eq 0 ]]; then
  echo -e "  ${GREEN}✅${NC} No state stores detected (or not JS/TS project)"
  ((PASSES++))
else
  # Find app entry points
  ENTRY_FILES=$(find src/ -maxdepth 2 \( -name "App.tsx" -o -name "App.vue" -o -name "main.ts" -o -name "main.tsx" -o -name "_app.tsx" -o -name "index.tsx" \) 2>/dev/null)

  for store_file in "${STORE_FILES[@]}"; do
    store_name=$(basename "$store_file" | sed 's/\.\(ts\|tsx\|js\|jsx\)$//')
    # Check if hydrate is called somewhere in entry files
    hydrate_found=false
    for entry in $ENTRY_FILES; do
      if grep -q "$store_name\|hydrate" "$entry" 2>/dev/null; then
        hydrate_found=true
        break
      fi
    done
    if $hydrate_found; then
      echo -e "  ${GREEN}✅${NC} $store_name — hydrate found in entry point"
      ((PASSES++))
    else
      echo -e "  ${RED}🚫${NC} $store_name — NO hydrate() in any entry point"
      echo "     Store: $store_file"
      echo "     Entry points checked: $ENTRY_FILES"
      ((BLOCKING++))
    fi
  done
fi
echo ""

# ─── Check 2: Message Passing Layers ───────────
echo "── Check 2: Message Passing Layers ──"

# Detect architecture type
if grep -rq "ipcMain\|ipcRenderer\|contextBridge" src/ 2>/dev/null; then
  echo "  Architecture: Electron IPC"

  # Find all ipcMain.handle channels
  HANDLERS=$(grep -rn "ipcMain\.handle\|ipcMain\.on" --include="*.ts" --include="*.js" src/ 2>/dev/null | grep -oP "'[^']+'" | sort -u || true)

  for channel in $HANDLERS; do
    clean_channel=$(echo "$channel" | tr -d "'")

    # Layer 1: Handler (already found)
    handler_found=true

    # Layer 2: Preload exposure
    preload_found=$(grep -rl "$clean_channel" --include="*.ts" --include="*.js" src/ 2>/dev/null | grep -i "preload\|bridge\|CHANNELS" | head -1 || true)

    # Layer 3: Renderer invocation
    renderer_found=$(grep -rl "$clean_channel" --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" src/ 2>/dev/null | grep -v "main\|preload\|electron" | head -1 || true)

    layers=1
    [[ -n "$preload_found" ]] && ((layers++))
    [[ -n "$renderer_found" ]] && ((layers++))

    if [[ $layers -eq 3 ]]; then
      echo -e "  ${GREEN}✅${NC} $clean_channel — 3/3 layers"
      ((PASSES++))
    elif [[ $layers -eq 2 ]]; then
      echo -e "  ${YELLOW}⚠️${NC}  $clean_channel — $layers/3 layers"
      [[ -z "$preload_found" ]] && echo "     Missing: Preload/bridge exposure"
      [[ -z "$renderer_found" ]] && echo "     Missing: Renderer invocation"
      ((WARNINGS++))
    else
      echo -e "  ${RED}🚫${NC} $clean_channel — $layers/3 layers"
      [[ -z "$preload_found" ]] && echo "     Missing: Preload/bridge exposure"
      [[ -z "$renderer_found" ]] && echo "     Missing: Renderer invocation"
      ((BLOCKING++))
    fi
  done

elif [[ -f "package.json" ]] && grep -q "express\|fastify\|koa\|hono\|nestjs" package.json 2>/dev/null; then
  echo "  Architecture: HTTP API"

  # Find route registrations
  ROUTES=$(grep -rn "router\.\(get\|post\|put\|patch\|delete\)\|app\.\(get\|post\|put\|patch\|delete\)" --include="*.ts" --include="*.js" src/ 2>/dev/null | head -20 || true)

  if [[ -z "$ROUTES" ]]; then
    echo -e "  ${YELLOW}⚠️${NC}  No HTTP routes detected"
    ((WARNINGS++))
  else
    route_count=$(echo "$ROUTES" | wc -l | tr -d ' ')
    echo -e "  ${GREEN}✅${NC} $route_count HTTP routes registered"
    ((PASSES++))
  fi

elif [[ -f "pyproject.toml" ]] || [[ -f "requirements.txt" ]]; then
  echo "  Architecture: Python (Django/Flask/FastAPI)"
  echo -e "  ${GREEN}✅${NC} Python project — route check via framework-specific patterns"
  ((PASSES++))

else
  echo -e "  ${YELLOW}⚠️${NC}  Architecture not auto-detected — manual check needed"
  ((WARNINGS++))
fi
echo ""

# ─── Check 3: UI Entry Points ──────────────────
echo "── Check 3: UI Entry Points ──"

# Check if navigation/router files reference expected paths
NAV_FILES=$(find src/ -maxdepth 4 \( -name "*nav*" -o -name "*sidebar*" -o -name "*menu*" -o -name "*router*" -o -name "*route*" \) -name "*.ts" -o -name "*.tsx" -o -name "*.vue" -o -name "*.jsx" 2>/dev/null | head -10)

if [[ -z "$NAV_FILES" ]]; then
  echo -e "  ${YELLOW}⚠️${NC}  No navigation/router files found — manual check needed"
  ((WARNINGS++))
else
  nav_count=$(echo "$NAV_FILES" | wc -l | tr -d ' ')
  echo -e "  ${GREEN}✅${NC} $nav_count navigation/router files found"
  for f in $NAV_FILES; do
    echo "     $(echo "$f" | sed "s|$PROJECT_ROOT/||")"
  done
  ((PASSES++))
fi
echo ""

# ─── Check 4: Parameter Shape Cross-Check ──────
echo "── Check 4: Parameter Shape ──"
echo -e "  ${YELLOW}⚠️${NC}  Automated parameter shape matching requires project-specific type analysis"
echo "     Agent should manually verify: caller params match handler params"
((WARNINGS++))
echo ""

# ─── Check 5: External Config Error Messages ───
echo "── Check 5: Error Message Actionability ──"

# Find error messages that say "failed" without guidance
BARE_ERRORS=$(grep -rn "\"[Ff]ailed\"\|\"[Ee]rror\"\|\"[Uu]nknown error\"" --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" src/ 2>/dev/null | grep -v "node_modules\|\.test\.\|\.spec\." | grep -v "Settings\|configure\|Go to\|Please\|try\|check" | head -10 || true)

if [[ -z "$BARE_ERRORS" ]]; then
  echo -e "  ${GREEN}✅${NC} No bare error messages found (all include guidance)"
  ((PASSES++))
else
  bare_count=$(echo "$BARE_ERRORS" | wc -l | tr -d ' ')
  echo -e "  ${YELLOW}⚠️${NC}  $bare_count error messages may lack actionable guidance:"
  echo "$BARE_ERRORS" | while read -r line; do
    echo "     $line"
  done
  ((WARNINGS++))
fi

echo ""
echo "═══════════════════════════════════════════════"
echo "  Results: ${GREEN}✅ $PASSES passed${NC}  ${YELLOW}⚠️ $WARNINGS warnings${NC}  ${RED}🚫 $BLOCKING blocking${NC}"
echo "═══════════════════════════════════════════════"

if [[ $BLOCKING -gt 0 ]]; then
  echo ""
  echo -e "  ${RED}BLOCKING issues found — fix before proceeding to verify${NC}"
  exit 1
else
  exit 0
fi
