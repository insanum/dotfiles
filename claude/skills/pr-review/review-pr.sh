#!/usr/bin/env bash
#
# review-pr.sh <PR-number>
#
# Pulls a GitHub PR into a detached worktree (sibling of the current repo) with
# the PR's code as UNSTAGED changes against the base branch tip, so the diffs
# show up directly in neovim (HEAD/index = base tip, worktree = PR head).
#
set -euo pipefail

PR="${1:-}"
if [[ -z "$PR" ]]; then
  echo "usage: review-pr.sh <PR-number>" >&2
  exit 2
fi

# Resolve the repo we're invoked from.
repo_root=$(git rev-parse --show-toplevel)
repo_name=$(basename "$repo_root")
parent=$(dirname "$repo_root")
wt="$parent/${repo_name}-pr-${PR}"

# Bail early if the worktree already exists.
if git worktree list --porcelain | grep -qx "worktree $wt"; then
  echo "Worktree already exists: $wt" >&2
  echo "Remove it first:  git worktree remove '$wt'" >&2
  exit 1
fi

# Which branch does this PR target?
base_ref=$(gh pr view "$PR" --json baseRefName -q .baseRefName)

# Fetch the PR head commit (capture its SHA before FETCH_HEAD is overwritten).
git fetch --quiet origin "pull/${PR}/head"
head_sha=$(git rev-parse FETCH_HEAD)

# Fetch the base branch and take its tip.
git fetch --quiet origin "$base_ref"
base_sha=$(git rev-parse FETCH_HEAD)

# Create the worktree at the PR head (detached), then re-point HEAD and the
# index to the base tip while leaving the PR's tree in the working dir -> the
# changes appear as UNSTAGED modifications vs base.
git worktree add --quiet --detach "$wt" "$head_sha"
git -C "$wt" reset --quiet --mixed "$base_sha"

short() { git -C "$wt" rev-parse --short "$1"; }

echo
echo "PR #$PR ready in: $wt"
echo "  HEAD/index = ${base_ref} tip ($(short "$base_sha"))"
echo "  worktree   = PR #${PR} head ($(short "$head_sha"))"
echo
echo "Unstaged PR diff:"
git -C "$wt" --no-pager diff --stat
echo
echo "Open it:        cd '$wt' && nvim"
echo "View diff:      git -C '$wt' diff"
echo "Clean up after: git worktree remove '$wt'"
