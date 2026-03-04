#!/usr/bin/env bash
# spec-kit-skills installer
# Creates symbolic links in ~/.claude/skills/ for all skills in this repository.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_SRC="$SCRIPT_DIR/.claude/skills"
SKILLS_DST="$HOME/.claude/skills"

# Ensure destination directory exists
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

echo ""
echo "Done. $linked linked, $skipped skipped."
