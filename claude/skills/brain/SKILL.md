---
name: brain
description: Capture what this session established into Eric's second brain at /Volumes/work/notes. Two modes, inferred from the working directory and overridable: inside a git repo under investigation it files a Sources/ page pinned to the commit plus derived root notes; anywhere else it files derived root notes from the conversation itself, plus a Sources/ record page when the discussion warrants one. Takes a topic argument that bounds which part of the session gets captured. Use when Eric wants a discussion, an investigation, or a conclusion from this session saved, filed, captured, or put in his notes. Not for importing documents - a URL, PDF or clip goes through /ingest or /pdf-import in the notes repo.
argument-hint: "[repo|note] [topic, e.g. 'provider dispatch']"
allowed-tools: Bash(git:*), Bash(python3:*), Bash(ls:*), Bash(grep:*), Bash(sed:*), Bash(head:*), Bash(tail:*), Bash(/bin/cat:*), Bash(wc:*), Bash(date:*), Read, Write, Edit, Glob, Grep
---

# brain

File what this session established into the second brain at
`/Volumes/work/notes`. Everything written goes there by absolute path. The cwd
never changes, and nothing outside the notes repo is ever modified.

**Why this skill exists at user scope**: `/ingest` and `/digest` are project
skills in the notes repo, unreachable from anywhere else. And the session that
did the work is the one holding the findings — an hour of reading `ib_verbs.c`
knows which three functions mattered. A later notes-repo session would start
cold from whatever got pasted into it.

## Modes

| | **repo mode** | **note mode** |
|---|---|---|
| Captures | what the session worked out about the local code | what the session worked out, full stop |
| Provenance | `origin` + `commit`, re-checkable at a SHA | whatever the discussion actually rested on |
| `Sources/` page | always — it is the anchor | only when the discussion earns one |
| Root notes | derived, `author: claude` | derived, author follows the substance |

Steps 0, 1 and 3 through 7 are shared. The modes differ only in provenance
(step 2) and in whether a source page is mandatory (step 6).

### Choosing the mode

```bash
git rev-parse --show-toplevel 2>/dev/null
```

- Not a repo, or the toplevel **is** `/Volumes/work/notes` -> **note mode**.
  Never run repo mode against the notes repo itself; recording it as `origin:`
  would pin the wiki to itself and mean nothing.
- Any other repo -> **repo mode** by default.

**The repo test is necessary, not sufficient.** Sitting in `rdma-core` while
the discussion drifted to general RoCE semantics is note mode. The cwd picks
the default; what the captured material is actually *about* decides. State the
chosen mode and the one-line reason in the step 5 proposal.

`/brain repo <topic>` and `/brain note <topic>` force it. A forced `repo` with
no repo, or inside the notes repo, is an error — say so and stop.

## 0. Read the conventions first

The notes repo's `CLAUDE.md` does not auto-load here, and this file must not
carry a copy that drifts:

```bash
/bin/cat /Volumes/work/notes/CLAUDE.md
/bin/cat /Volumes/work/notes/Sources/CLAUDE.md
```

`## Atomic Notes`, `### Note style`, `### Derived notes` and `## The Wiki`
govern everything written. `## Code repositories` in `Sources/CLAUDE.md` covers
repo mode specifically.

## 1. Scope the capture to the topic

**The topic argument bounds what gets captured. It is not just a name.** A
session with ten threads in it must not produce one page with ten subjects in
it.

- **The topic bounds subject matter, not position in the session.** A subject
  discussed early and returned to forty messages later is one capture. Sweep
  the whole session for material on that subject, wherever it sits.
- **When in doubt, exclude.** Over-narrow costs one sentence to correct.
  Over-broad smears three subjects into one note and breaks one-note-one-idea
  before anything is written.
- **Nothing drops silently.** The step 5 proposal names every other thread in
  the session that was deliberately left out, one line each.
- **One invocation, one subject, one commit.** Three threads worth keeping is
  three runs of this skill, so each capture reverts on its own.

### No topic given

Enumerate the distinct subjects the session covered, one line each, and stop —
ask which to capture. This doubles as a readout of what the session even did.

**Shortcut**: when the session genuinely covered one subject, skip the
enumeration and go straight to the normal proposal. Do not make Eric pick from
a list of one.

## 2. Establish provenance

Draw only on what this session actually established. **Never re-derive a claim
from memory** — if it was not read, worked out, or stated in this session,
either establish it now or leave it out.

### Repo mode — repo identity

```bash
git remote get-url origin            # -> origin:   (may not exist)
git rev-parse HEAD                   # -> commit:
git rev-parse --short HEAD
git symbolic-ref --short -q HEAD     # branch, if not detached
git status --porcelain               # dirty?
```

Three things to get right:

- **No remote** -> `origin:` is the local absolute path. Say so on the page,
  since nobody else can resolve it.
- **Dirty tree** -> the SHA does not describe what was read. Record
  `dirty: true` on the source page and name the modified paths. Do not pretend
  the commit is sufficient.
- **Detached HEAD** -> record the SHA, omit the branch.

### Note mode — what the claims rest on

There is no SHA here, and that is the whole risk. A claim from a spec on disk
and a claim from model training data look identical once they are prose in a
note. Classify every claim before writing it:

| Class | Citable | Treatment |
|---|---|---|
| Code or a document read this session | yes | cite it at claim level |
| An existing note in the wiki | yes | `[[wikilink]]` at claim level |
| A URL fetched this session | yes | cite the URL |
| Worked out jointly in the session | the reasoning is the provenance | state the reasoning |
| **Eric asserted it** | he is the authority | no marker needed — see `author:` below |
| **Model training data only** | **no** | see the floor below |

**`author:` follows where the substance came from, not who typed it.** Eric
designs this silicon; a conversation where he explains how a NIC behaves and
this session organizes it is `author: mixed`, or `eric` where the shaping was
trivial. Writing `author: claude` over his own expertise is a lie that makes
the note look machine-derived forever.

**The hard floor — unsourced specific values are not written.** Anything
version-dependent recalled from training data with no source in the session —
numbers, field widths, bit layouts, defaults, wire formats — **may not go into
a note**. Either verify it now against something on disk (`grep` the wiki, read
the spec already in `PDFs/`), or state the mechanism qualitatively and omit the
number. A mechanism roughly right is useful and correctable. A bit width wrong
is a landmine with a five-year shelf life.

**Unsourced mechanisms are marked inline** with `(unverified)`, placed on the
sentence it applies to, not at the top of the note:

```markdown
The completion path appears to drain the CQ before rearming the doorbell (unverified).
```

It is plain, greppable, and collides with nothing — `???` is reserved for
Eric's own open questions and `==highlight==` for major ideas. Do not use
either.

## 3. Decide what is worth keeping

Rank by what Eric would use. He designs NIC silicon, so mechanisms, state
machines, wire formats, locking rules and lifetimes matter; module layout and
build plumbing rarely do.

A finding is worth a note when it took work to establish and would take the
same work again. A finding that is one grep away is not. `### Derived notes` in
the notes `CLAUDE.md` sets the same bar for note mode: synthesized 3+ sources,
produced a comparison, resolved a contradiction, or corrected an existing note.

**The bar is advisory, not enforced.** Eric curates what comes in; a skill that
overrules the curator is the wrong shape. State plainly in the step 5 proposal
whether the capture clears the bar, recommend against when it does not, and
write it anyway if he says go.

### Depth

**The filter above is on what goes in, never on how much each thing gets.**
Once a finding passes it, write it deep. The target is that Eric can use the
note years later without opening the repo, or having the conversation, again.

Deep means a note carries all of:

- The mechanism itself, not a summary of it. "Firmware polls port counters on
  a timer" is a summary. That the timer is a self-rearming one-shot which
  re-queues itself at the end of the handler, so the period is `250ms` plus
  execution and scheduling delay and it drifts rather than holding cadence —
  that is the knowledge, and it is the part that cost an hour to establish.
- The symbols and files that implement it, so the claim is re-checkable. In
  note mode, whatever the equivalent anchor is: the spec section, the note, the
  URL.
- Every constant with the symbol that defines it and where that symbol lives,
  not the bare number.
- The consequences that follow, stated plainly. Worst-case staleness, what the
  host actually observes, what breaks.
- The edge cases and gates. The conditions under which the mechanism silently
  does nothing are usually the reason the note exists.

Two things bound depth, and neither is a length target:

- **What the session established.** Padding to look thorough is worse than a
  short filing. A thin investigation produces a thin page, and that is correct.
- **Marked uncertainty.** Anything inconclusive stays inconclusive, per step 5.
  Depth without that is confident wrong notes with a long shelf life.

Compressing to save effort is the failure mode to avoid. A finding written at
half fidelity reads fine today and is useless in a year, which is exactly when
it is wanted -> if the choice is fewer notes written properly or more notes
written thin, take fewer.

## 4. Check what the wiki already has

**Never claim a gap without checking.**

```bash
grep -i '<topic>' /Volumes/work/notes/_wiki_index.txt
ls /Volumes/work/notes/Sources/
```

Read any related note in full before deciding it is missing something.

## 5. Propose, then stop

Print, in this order, and **write nothing until Eric answers**:

1. **The mode**, and the one-line reason it was chosen
2. **Provenance** — repo mode: remote, branch, short SHA, dirty state. Note
   mode: what the claims rest on, naming anything that rests on training data
   alone
3. The proposed source-page name, `snake_case_no_spaces`, describing the
   subject rather than the repo or the session — `rdma_core_provider_dispatch`,
   not `rdma_core`. Note mode: whether a source page is warranted at all
4. Proposed tags from the existing vocabulary, flagging anything new
5. Each proposed note, one line each, marked **new** or **extends `<name>`**
6. **Other threads in the session, left out of scope**, one line each
7. Whether the capture clears the worth-keeping bar, per step 3
8. Anything that was inconclusive, so it does not get written up as settled

## 6. Write

Into `/Volumes/work/notes`, never anywhere else.

### The source page

**Repo mode**: `Sources/<name>.md`, always. **Note mode**: `Sources/<name>.md`
only when the discussion earns it, by the same bar repo mode uses for a `_qa`
record — long enough or branchy enough to be worth auditing later. It exists to
give the notes something to cite; without it, provenance lives in a
`## Provenance` section at the foot of each note instead.

```bash
echo '{"desc":"...","title":"...","tags":["rdma"],"origin":"...","commit":"...","body":"..."}' \
    | python3 /Volumes/work/notes/.claude/source-page.py Sources/<name> <YYYY-MM-DDTHH:MM>
```

- Repo mode sets `origin:` to the remote (or local path) and `commit:` to the
  full SHA, plus `dirty: true` when the tree was dirty.
- **Note mode sets `origin: conversation` and no `commit:`.** It is greppable,
  and it makes it impossible to mistake the page for code-backed.
- **A note-mode page must say what it is** in its own body: a record written by
  the session that had the discussion, not a transcript, and not an authority.
- `author:` on the page follows the substance too, per step 2. `source-page.py`
  defaults it to `claude`, which is wrong for a discussion Eric drove — pass it
  explicitly.

### Root notes

Via `new-note.py`, **never a bare write**:

```bash
echo '{"name":"...","desc":"...","author":"claude","tags":[...],"body":"...","stamp":"..."}' \
    | python3 /Volumes/work/notes/.claude/new-note.py
```

It refuses if the note exists. That refusal is the point — `UET Verbs.md`,
Eric's own work index, was once destroyed by a generated hub of the same name.
Use `--append` to add a section to an existing note instead.

- **Derived-note form**: each note opens with a `[!question]` callout stating
  what was being worked out, and cites `[[<source page>]]` at claim level on
  anything version-dependent.
- **`author:`** is `claude` in repo mode. In note mode it follows the substance,
  per step 2 — `mixed` or `eric` when the knowledge was Eric's.
- **Cite symbols, not line numbers.** `bnxt_re_create_qp()` in
  `drivers/infiniband/hw/bnxt_re/ib_verbs.c` survives refactors;
  `ib_verbs.c:1247` is wrong within a month. The SHA on the source page is what
  makes the exact line recoverable.
- **A hub** once the topic has 2+ notes, per `## Atomic Notes`.

### Repo mode only

**A long investigation** may also get `Sources/<name>_qa.md` — the questions
asked and what the code showed. This is a **record written by this session**,
not a transcript, and must say so. Skip it when the source page covers it.

## 7. Verify and commit

```bash
python3 /Volumes/work/notes/.claude/fmt-notes.py <every file written>   # explicit list, never a glob
python3 /Volumes/work/notes/.claude/wiki-index.py
python3 /Volumes/work/notes/.claude/notes-gate.py                        # must be clean
```

Append to `/Volumes/work/notes/_wiki_log.md` under
`## [YYYY-MM-DD] brain | <name>`, recording `origin:` and, in repo mode,
`commit:`, so the trail back to the code survives.

Then commit **in the notes repo**, leaving everything else untouched:

```bash
git -C /Volumes/work/notes add -A
git -C /Volumes/work/notes commit -m "..."
```

**Never commit, stage, or modify anything in the repo under investigation.**
This skill only reads there. In note mode there may be no other repo at all,
and the rule is unchanged: the notes repo is the only thing written.

## Scope

Capturing what a session established, into the wiki. Two things it does not do:

- **It never fetches, converts or imports a document.** If the session
  discussed a URL, `/brain` captures the conclusions and names the URL as
  provenance -> say in the proposal that `/ingest` is what he wants if he also
  wants the document itself on disk. A PDF for the reading queue is
  `/pdf-import`; an already-imported source is `/digest`.
- **It is not journaling.** Dailies, weeklies and the 12-week year have their
  own skills in the notes repo.

If Eric wants something else filed, tell him which of those it is rather than
stretching this one.
