---
created: 2026-08-18T15:17
updated: 2026-08-18T15:17
---

# Global conventions

## My shell aliases shadow standard commands

`PAGER=~/.bin/fv` is my own file viewer, and my shell profile sets:

    alias cat=$PAGER
    alias more=$PAGER
    alias less=$PAGER

The Bash tool initializes from my profile, so **these aliases are live in every
command you run**. `fv` emits syntax-highlighted, line-numbered output with box
drawing and ANSI color.

**Never use bare `cat`, `more`, or `less`.** Two distinct failures:

- **Reading** — output comes back wrapped in ANSI escape codes: hard to parse and
  5-10x the tokens. An 800-line file can land as 130KB of escape sequences.
- **Writing** — `cat > file <<'EOF'` pipes the heredoc through the viewer and writes
  **escape codes into the file itself**. Silent corruption: the terminal looks fine,
  the file on disk is garbage. Symptom is a file 2-3x larger than the content you
  wrote.

Use instead:

- **Reading** — prefer the Read tool. If Bash is required: `/bin/cat`, `sed -n '1,50p'`, `head`, `tail`, or `command cat`.
- **Writing** — prefer the Write tool. If Bash is required: `/bin/cat > file <<'EOF'`
  or `tee`.

Assume other standard commands may be aliased too. If output looks decorated, or a
file you just wrote is unexpectedly large, suspect an alias and rerun with an
absolute path.

## Heredocs

When writing file content via heredoc, **quote the delimiter** — `<<'EOF'`, not
`<<EOF` — unless you specifically want expansion. An unquoted heredoc evaluates
`$(...)`, backticks, and `$VAR` inside the body, so backticks in markdown and `$1`
in shell examples get silently executed or eaten.

