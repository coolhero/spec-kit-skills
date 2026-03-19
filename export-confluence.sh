#!/usr/bin/env bash
# export-confluence.sh — Render Mermaid blocks in README as SVG images for Confluence
#
# Usage:
#   ./export-confluence.sh                  # Both README.md + README.ko.md
#   ./export-confluence.sh README.md        # Specific file only
#   ./export-confluence.sh --clean          # Remove generated files
#
# Output:
#   dist/confluence/README.md               # Mermaid blocks replaced with ![diagram](img/...)
#   dist/confluence/README.ko.md
#   dist/confluence/img/README-1.svg ...    # Rendered SVG diagrams
#
# Prerequisites:
#   npm install -g @mermaid-js/mermaid-cli   (or: npx handles it automatically)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUT_DIR="$SCRIPT_DIR/dist/confluence"
IMG_DIR="$OUT_DIR/img"

# --- Clean mode ---
if [[ "${1:-}" == "--clean" ]]; then
  rm -rf "$OUT_DIR"
  echo "✅ Cleaned $OUT_DIR"
  exit 0
fi

# --- Determine which files to process ---
if [[ -n "${1:-}" && "$1" != "--"* ]]; then
  FILES=("$1")
else
  FILES=("README.md" "README.ko.md")
fi

# --- Check mmdc availability ---
MMDC=""
if command -v mmdc &>/dev/null; then
  MMDC="mmdc"
else
  echo "ℹ️  mmdc not found globally, using npx @mermaid-js/mermaid-cli"
  MMDC="npx --yes @mermaid-js/mermaid-cli"
fi

# --- Mermaid config for clean SVGs ---
MMDC_CONFIG=$(mktemp /tmp/mmdc-config.XXXXXX.json)
cat > "$MMDC_CONFIG" <<'JSONEOF'
{
  "theme": "default",
  "themeVariables": {
    "fontSize": "14px"
  },
  "flowchart": { "useMaxWidth": false },
  "sequence": { "useMaxWidth": false }
}
JSONEOF

# Puppeteer config for headless rendering
PUPPETEER_CONFIG=$(mktemp /tmp/puppeteer-config.XXXXXX.json)
cat > "$PUPPETEER_CONFIG" <<'JSONEOF'
{
  "headless": true,
  "args": ["--no-sandbox"]
}
JSONEOF

mkdir -p "$IMG_DIR"

# --- Process each README ---
for FILE in "${FILES[@]}"; do
  BASENAME="$(basename "$FILE" .md)"
  INPUT="$SCRIPT_DIR/$FILE"

  if [[ ! -f "$INPUT" ]]; then
    echo "⚠️  $FILE not found, skipping"
    continue
  fi

  echo "📄 Processing $FILE..."

  # Extract mermaid blocks and render each to SVG
  BLOCK_NUM=0
  OUTPUT="$OUT_DIR/$FILE"
  TEMP_FILE=$(mktemp)
  cp "$INPUT" "$TEMP_FILE"

  # Find all mermaid blocks, extract, render, replace
  while IFS= read -r LINE_NUM; do
    BLOCK_NUM=$((BLOCK_NUM + 1))
    SVG_NAME="${BASENAME}-${BLOCK_NUM}.svg"
    SVG_PATH="$IMG_DIR/$SVG_NAME"

    # Find the end of this mermaid block
    END_NUM=$(tail -n "+$((LINE_NUM + 1))" "$INPUT" | grep -n '^```$' | head -1 | cut -d: -f1)
    END_NUM=$((LINE_NUM + END_NUM))

    # Extract mermaid content (between ```mermaid and ```)
    MERMAID_CONTENT=$(sed -n "$((LINE_NUM + 1)),$((END_NUM - 1))p" "$INPUT")

    # Write to temp .mmd file
    MMD_FILE=$(mktemp /tmp/mermaid-XXXXXX.mmd)
    echo "$MERMAID_CONTENT" > "$MMD_FILE"

    # Render to SVG
    if $MMDC -i "$MMD_FILE" -o "$SVG_PATH" -c "$MMDC_CONFIG" -p "$PUPPETEER_CONFIG" --quiet 2>/dev/null; then
      echo "  ✅ Block $BLOCK_NUM → $SVG_NAME"
    else
      echo "  ⚠️  Block $BLOCK_NUM render failed, keeping as code block"
      rm -f "$MMD_FILE"
      continue
    fi

    rm -f "$MMD_FILE"
  done < <(grep -n '```mermaid' "$INPUT" | cut -d: -f1)

  # Now build the output file with replacements
  BLOCK_NUM=0
  {
    CURRENT_LINE=0
    IN_MERMAID=false
    while IFS= read -r LINE; do
      CURRENT_LINE=$((CURRENT_LINE + 1))

      if [[ "$LINE" == '```mermaid' ]]; then
        IN_MERMAID=true
        BLOCK_NUM=$((BLOCK_NUM + 1))
        SVG_NAME="${BASENAME}-${BLOCK_NUM}.svg"

        if [[ -f "$IMG_DIR/$SVG_NAME" ]]; then
          echo "![Diagram ${BLOCK_NUM}](img/${SVG_NAME})"
          echo ""
        else
          # Render failed — keep original block
          echo "$LINE"
        fi
        continue
      fi

      if $IN_MERMAID; then
        if [[ "$LINE" == '```' ]]; then
          IN_MERMAID=false
          SVG_NAME="${BASENAME}-${BLOCK_NUM}.svg"
          if [[ ! -f "$IMG_DIR/$SVG_NAME" ]]; then
            echo "$LINE"
          fi
        else
          if [[ ! -f "$IMG_DIR/${BASENAME}-${BLOCK_NUM}.svg" ]]; then
            echo "$LINE"
          fi
        fi
        continue
      fi

      echo "$LINE"
    done < "$INPUT"
  } > "$OUTPUT"

  rm -f "$TEMP_FILE"
  echo "  📝 $OUTPUT ($(grep -c 'img/' "$OUTPUT") diagrams embedded)"
done

rm -f "$MMDC_CONFIG" "$PUPPETEER_CONFIG"

echo ""
echo "═══════════════════════════════════════════"
echo "✅ Export complete → $OUT_DIR/"
echo ""
echo "Confluence workflow:"
echo "  1. Open dist/confluence/README.md in a Markdown previewer"
echo "  2. Copy rendered content → Paste into Confluence editor"
echo "  3. SVG images are in dist/confluence/img/ — upload to Confluence page"
echo "     or drag-drop them into the editor"
echo ""
echo "💡 Tip: For inline images in Confluence, upload SVGs as attachments"
echo "   then use !filename.svg! in wiki markup, or drag-drop in the editor."
echo "═══════════════════════════════════════════"
