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

**`ls` is aliased too** — a bare `ls` can block on a pager until the Bash tool
times out (a 120s hang with no output). Use `/bin/ls`.

Assume other standard commands may be aliased too. If output looks decorated, or a
file you just wrote is unexpectedly large, suspect an alias and rerun with an
absolute path.

## `cp` and `mv` are interactive

`cp` is aliased to `cp -i` (assume `mv` is too). In a non-interactive tool call
this does **not** fail — it prints `overwrite <file>? (y/n [n])` and **blocks
until the command times out**, leaving the copy undone.

This is worse than the `cat` problem, because it fails in the wrong direction: a
command you believe restored a file has actually left the old contents in place,
and anything chained after it never runs either.

It is especially dangerous for **revert** steps — restoring a backup over an
edited file, undoing a temporary change — because the thing you were trying to
undo stays live. On a mutagen-synced tree it then keeps propagating to every
remote host.

**Always use `/bin/cp -f` and `/bin/mv -f`** (or `command cp`) for anything
non-interactive. After a revert that matters, verify rather than assume:

    /bin/cp -f backup.c target.c
    diff -q backup.c target.c && echo REVERTED

## Heredocs

When writing file content via heredoc, **quote the delimiter** — `<<'EOF'`, not
`<<EOF` — unless you specifically want expansion. An unquoted heredoc evaluates
`$(...)`, backticks, and `$VAR` inside the body, so backticks in markdown and `$1`
in shell examples get silently executed or eaten.

