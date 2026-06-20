#!/usr/bin/env bash
#
# Convert a PDF to Markdown (with referenced images) in the current directory
# using docling. Bundled with the `pdf-to-markdown` Claude Code skill.

set -euo pipefail

if [ -z "${1:-}" ]; then
  echo "Usage: $(basename "$0") <pdf-file>" >&2
  exit 1
fi

pdf="$1"

if [ ! -f "$pdf" ]; then
  echo "Error: file not found: $pdf" >&2
  exit 1
fi

if ! command -v docling >/dev/null 2>&1; then
  echo "Error: docling is not installed or not on PATH" >&2
  exit 1
fi

docling --verbose \
        --artifacts-path "$HOME/.cache/docling/models" \
        --image-export-mode referenced \
        --from pdf \
        --to md \
        "$pdf"
