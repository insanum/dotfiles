---
name: pr-review
description: Pull a GitHub PR into a temporary detached git worktree (sibling of the current repo) with the PR's changes left UNSTAGED against the base branch tip, so the diff is visible directly in neovim. Then optionally analyze the PR and produce a description plus a detailed code review. Use when the user wants to review, pull down, check out, or inspect a GitHub PR locally. Takes the PR number as the single argument.
argument-hint: <PR-number>
allowed-tools: Bash(bash:*), Bash(git:*), Bash(gh:*)
---

# pr-review

Set up a local review checkout of a GitHub pull request, then optionally analyze it.

## Step 1 — Set up the worktree

Run the helper script with the PR number provided as the argument, from the repo
the user is in:

```bash
bash ~/.claude/skills/pr-review/review-pr.sh <PR-number>
```

The script:

1. Reads the PR's base branch via `gh pr view`.
2. Fetches the PR head commit and the base branch tip.
3. Creates a **detached worktree** at `../<repo>-pr-<N>` (sibling of the repo).
4. `git reset --mixed` to the base tip, leaving the PR's tree in the working
   directory as **unstaged** changes (HEAD/index = base tip, worktree = PR head).

The result: the PR's changes appear as unstaged modifications, visible directly
in neovim (e.g. gitsigns against HEAD) or via `git diff`.

Report back to the user:
- The worktree path.
- The unstaged `--stat` summary the script printed.
- The cleanup command: `git worktree remove <path>`.

If the worktree already exists, the script stops and prints the removal command;
relay that to the user.

## Step 2 — Ask whether to analyze

After the worktree is set up, ask the user a single yes/no question:

> Analyze the PR now — description of the changes plus a detailed code review?

Use the AskUserQuestion tool (Yes / No). If the user declines, stop here.

## Step 3 — Analyze (only if the user says yes)

Review the PR's changes in the worktree. The changes come in two forms — **both
must be included** in the analysis:

- **Modified files** (unstaged): `git -C <path> diff` shows these.
- **New files** (untracked): `git -C <path> diff` does NOT show these. Find them
  with `git -C <path> status --porcelain` (the `??` entries) and read each one in
  full. Treat their entire contents as added code in the review.

Produce:

1. **Description of the changes** — a concise summary of what the PR does and
   why, organized by area/file where helpful.
2. **Detailed code review** — identify:
   - Bugs, correctness issues, and edge cases.
   - The trickier or subtle changes whose implications are easy to overlook,
     with enough detail to explain *why* they're subtle.
   - Anything risky, unclear, or worth a second look.

Read the actual changed files in the worktree as needed for context; don't review
from the diff alone where surrounding code matters.

## Notes

- Must be run from inside the target git repo (it uses the current repo's remote
  and computes the worktree path relative to it).
- The diff is against the **base branch tip**, not the merge-base, so unrelated
  churn on the base branch can appear if it has advanced.
