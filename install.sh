#!/usr/bin/env bash
# spec-kit-skills installer
# Creates symbolic links in ~/.claude/skills/ for all skills,
# and installs Stop hook for spec-kit output interception.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_SRC="$SCRIPT_DIR/.claude/skills"
SKILLS_DST="$HOME/.claude/skills"
HOOKS_SRC="$SCRIPT_DIR/.claude/hooks"

# ── Skills Installation ──────────────────────────────────

echo "── Skills ──"
mkdir -p "$SKILLS_DST"

linked=0
skipped=0

for skill_dir in "$SKILLS_SRC"/*/; do
  skill_name="$(basename "$skill_dir")"
  target="$SKILLS_DST/$skill_name"

  if [ -L "$target" ]; then
    existing="$(readlink "$target")"
    if [ "$existing" = "$skill_dir" ] || [ "$existing" = "${skill_dir%/}" ]; then
      echo "  skip  $skill_name (already linked)"
      skipped=$((skipped + 1))
      continue
    else
      echo "  update  $skill_name (relink: $existing → ${skill_dir%/})"
      rm "$target"
    fi
  elif [ -e "$target" ]; then
    echo "  WARN  $skill_name: $target exists and is not a symlink — skipping"
    skipped=$((skipped + 1))
    continue
  fi

  ln -s "${skill_dir%/}" "$target"
  echo "  link  $skill_name → ${skill_dir%/}"
  linked=$((linked + 1))
done

echo "  $linked linked, $skipped skipped."

# ── Stop Hook Installation ───────────────────────────────
#
# The Stop hook detects when the agent stops with spec-kit raw output
# (e.g., "Next Actions: Proceed to /speckit.implement") instead of
# continuing to the Review step. It forces the agent to continue.
#
# This hook is installed per-project: each project that uses smart-sdd
# needs .claude/settings.json with the hook configuration.
#
# Usage: Run this installer from the TARGET PROJECT directory, or
#        copy the hook config to your project's .claude/settings.json.

echo ""
echo "── Stop Hook ──"

HOOK_SCRIPT="$HOOKS_SRC/stop-speckit-intercept.sh"

if [ ! -f "$HOOK_SCRIPT" ]; then
  echo "  WARN  Hook script not found: $HOOK_SCRIPT"
else
  # If run from a project directory (not the spec-kit-skills repo itself),
  # offer to install the hook in the current project
  if [ "$SCRIPT_DIR" != "$(pwd)" ] && [ -d ".git" ]; then
    PROJECT_SETTINGS=".claude/settings.json"
    mkdir -p .claude

    if [ -f "$PROJECT_SETTINGS" ]; then
      # Check if hook is already configured
      if grep -q "stop-speckit-intercept" "$PROJECT_SETTINGS" 2>/dev/null; then
        echo "  skip  Stop hook already configured in $PROJECT_SETTINGS"
      else
        echo "  WARN  $PROJECT_SETTINGS exists — add Stop hook manually:"
        echo "        See spec-kit-skills/.claude/settings.json for the hook config"
      fi
    else
      # Create settings.json with hook configuration
      cat > "$PROJECT_SETTINGS" << SETTINGS
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "$HOOK_SCRIPT",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
SETTINGS
      echo "  install  Stop hook → $PROJECT_SETTINGS"
      echo "           Script: $HOOK_SCRIPT"
    fi
  else
    echo "  info  Run install.sh from your target project directory to install the Stop hook"
    echo "        Example: cd ~/my-project && $SCRIPT_DIR/install.sh"
    echo "        Or copy .claude/settings.json to your project's .claude/"
  fi
fi

echo ""
echo "Done."
