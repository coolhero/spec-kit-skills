#!/usr/bin/env bash
# spec-kit-skills uninstaller
# Removes symbolic links from ~/.claude/skills/ that point to this repository.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_SRC="$SCRIPT_DIR/.claude/skills"
SKILLS_DST="$HOME/.claude/skills"

removed=0
skipped=0

for skill_dir in "$SKILLS_SRC"/*/; do
  skill_name="$(basename "$skill_dir")"
  target="$SKILLS_DST/$skill_name"

  if [ -L "$target" ]; then
    existing="$(readlink "$target")"
    if [ "$existing" = "$skill_dir" ] || [ "$existing" = "${skill_dir%/}" ]; then
      rm "$target"
      echo "  remove  $skill_name"
      removed=$((removed + 1))
    else
      echo "  skip  $skill_name (symlink points elsewhere: $existing)"
      skipped=$((skipped + 1))
    fi
  elif [ -e "$target" ]; then
    echo "  skip  $skill_name (not a symlink — not managed by this installer)"
    skipped=$((skipped + 1))
  else
    echo "  skip  $skill_name (not installed)"
    skipped=$((skipped + 1))
  fi
done

echo ""
echo "Done. $removed removed, $skipped skipped."
