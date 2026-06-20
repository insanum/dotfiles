---
name: pdf-to-markdown
description: Convert a PDF file to Markdown (with referenced images) in the current directory using docling. Use when the user wants to turn a PDF into markdown or extract a PDF's text/content. Takes the PDF path as the single argument.
argument-hint: <pdf-file>
arguments: [pdf]
allowed-tools: Bash(bash "$HOME/.claude/skills/pdf-to-markdown/convert.sh":*)
created: 2026-06-19T11:30
updated: 2026-06-19T11:30
---

## /pdf-to-markdown

Convert the PDF at `$pdf` to Markdown in the **current working directory** using
docling, by running the bundled script:

```bash
bash "$HOME/.claude/skills/pdf-to-markdown/convert.sh" "$pdf"
```

What to expect:
- Output is written to the current directory: a `<name>.md` file plus a folder
  of referenced images (image export mode is `referenced`).
- docling uses the locally cached models at `~/.cache/docling/models`, so a
  local PDF needs no network access.
- Conversion runs model inference and can take a while on large or scanned PDFs
  — let it finish.

After it completes:
- Report the generated Markdown file path and the images directory (if created).
- If docling errors, surface its output verbatim rather than guessing.
