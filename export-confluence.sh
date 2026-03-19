#!/usr/bin/env bash
# export-confluence.sh — Generate Confluence-ready README with Mermaid → inline SVG
#
# Usage:
#   ./export-confluence.sh                  # Both README.md + README.ko.md
#   ./export-confluence.sh README.md        # Specific file only
#   ./export-confluence.sh --clean          # Remove generated files
#
# Output:
#   README.confluence.md                    # Single self-contained file (SVGs inlined as base64 <img>)
#   README.ko.confluence.md
#
# Prerequisites:
#   npm install -g @mermaid-js/mermaid-cli   (or: npx handles it automatically)
#
# Confluence workflow:
#   1. Open .confluence.md in a Markdown previewer (e.g., VS Code preview)
#   2. Select All → Copy → Paste into Confluence editor
#   Done. No image uploads needed — everything is in one file.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# --- Clean mode ---
if [[ "${1:-}" == "--clean" ]]; then
  rm -f "$SCRIPT_DIR"/*.confluence.md
  rm -rf "$SCRIPT_DIR/dist"
  echo "✅ Cleaned *.confluence.md and dist/"
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
  "themeVariables": { "fontSize": "14px" },
  "flowchart": { "useMaxWidth": false },
  "sequence": { "useMaxWidth": false }
}
JSONEOF

PUPPETEER_CONFIG=$(mktemp /tmp/puppeteer-config.XXXXXX.json)
cat > "$PUPPETEER_CONFIG" <<'JSONEOF'
{
  "headless": true,
  "args": ["--no-sandbox"]
}
JSONEOF

TMPDIR_WORK=$(mktemp -d /tmp/confluence-export.XXXXXX)

# --- Process each README ---
for FILE in "${FILES[@]}"; do
  BASENAME="$(basename "$FILE" .md)"
  INPUT="$SCRIPT_DIR/$FILE"
  OUTPUT="$SCRIPT_DIR/${BASENAME}.confluence.md"

  if [[ ! -f "$INPUT" ]]; then
    echo "⚠️  $FILE not found, skipping"
    continue
  fi

  echo "📄 Processing $FILE..."

  # Pass 1: Render all Mermaid blocks to SVG, then base64-encode
  declare -a SVG_BASE64=()
  BLOCK_NUM=0

  while IFS= read -r LINE_NUM; do
    BLOCK_NUM=$((BLOCK_NUM + 1))
    SVG_FILE="$TMPDIR_WORK/${BASENAME}-${BLOCK_NUM}.svg"

    # Find end of mermaid block
    END_NUM=$(tail -n "+$((LINE_NUM + 1))" "$INPUT" | grep -n '^```$' | head -1 | cut -d: -f1)
    END_NUM=$((LINE_NUM + END_NUM))

    # Extract mermaid content
    MMD_FILE="$TMPDIR_WORK/block-${BLOCK_NUM}.mmd"
    sed -n "$((LINE_NUM + 1)),$((END_NUM - 1))p" "$INPUT" > "$MMD_FILE"

    # Render
    if $MMDC -i "$MMD_FILE" -o "$SVG_FILE" -c "$MMDC_CONFIG" -p "$PUPPETEER_CONFIG" --quiet 2>/dev/null; then
      B64=$(base64 < "$SVG_FILE" | tr -d '\n')
      SVG_BASE64[$BLOCK_NUM]="$B64"
      echo "  ✅ Block $BLOCK_NUM rendered"
    else
      SVG_BASE64[$BLOCK_NUM]=""
      echo "  ⚠️  Block $BLOCK_NUM render failed, keeping code block"
    fi
  done < <(grep -n '```mermaid' "$INPUT" | cut -d: -f1)

  # Pass 2: Build output file — replace mermaid blocks with inline <img>
  BLOCK_NUM=0
  IN_MERMAID=false
  {
    while IFS= read -r LINE; do
      if [[ "$LINE" == '```mermaid' ]]; then
        IN_MERMAID=true
        BLOCK_NUM=$((BLOCK_NUM + 1))

        if [[ -n "${SVG_BASE64[$BLOCK_NUM]:-}" ]]; then
          # Inline SVG as base64 <img> — self-contained, no external files
          echo "<img src=\"data:image/svg+xml;base64,${SVG_BASE64[$BLOCK_NUM]}\" alt=\"Diagram ${BLOCK_NUM}\" />"
          echo ""
        else
          echo "$LINE"
        fi
        continue
      fi

      if $IN_MERMAID; then
        if [[ "$LINE" == '```' ]]; then
          IN_MERMAID=false
          if [[ -z "${SVG_BASE64[$BLOCK_NUM]:-}" ]]; then
            echo "$LINE"
          fi
        else
          if [[ -z "${SVG_BASE64[$BLOCK_NUM]:-}" ]]; then
            echo "$LINE"
          fi
        fi
        continue
      fi

      echo "$LINE"
    done < "$INPUT"
  } > "$OUTPUT"

  DIAGRAM_COUNT=$(grep -c 'data:image/svg+xml;base64' "$OUTPUT" || true)
  echo "  📝 → ${BASENAME}.confluence.md ($DIAGRAM_COUNT diagrams inlined)"

  unset SVG_BASE64
done

# --- Cleanup ---
rm -rf "$TMPDIR_WORK" "$MMDC_CONFIG" "$PUPPETEER_CONFIG"

echo ""
echo "═══════════════════════════════════════════"
echo "✅ Export complete"
echo ""
for FILE in "${FILES[@]}"; do
  BASENAME="$(basename "$FILE" .md)"
  OUTFILE="${BASENAME}.confluence.md"
  if [[ -f "$SCRIPT_DIR/$OUTFILE" ]]; then
    SIZE=$(du -h "$SCRIPT_DIR/$OUTFILE" | cut -f1 | xargs)
    echo "  📄 $OUTFILE ($SIZE)"
  fi
done
echo ""
echo "Confluence workflow:"
echo "  1. Open .confluence.md in VS Code → Preview (Cmd+Shift+V)"
echo "  2. Select All (Cmd+A) → Copy (Cmd+C)"
echo "  3. Paste (Cmd+V) into Confluence editor"
echo "  Done — all diagrams are embedded. No image uploads needed."
echo "═══════════════════════════════════════════"
