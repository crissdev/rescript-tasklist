---
name: merge-pr
description: Safely squash-merge a pull request once CI passes, the head commit has the required number of review approvals and no review thread is unresolved, then confirm its linked issues closed and clean up its worktree and local branch. Use when asked to merge a PR, or as the final step of the implement-issue skill.
argument-hint: "<PR number> [skip review check]"
---

# Merge a pull request

Merge the PR given as the argument, or the PR for the current branch when none is given. Check everything first and
merge only when every check passes. This skill does not fix problems: apart from waiting for missing reviews, when a
check fails, report it and stop.

In the commands below, `review-status.sh` is [`.agents/skills/merge-pr/scripts/review-status.sh`](scripts/review-status.sh)
in the repository root. It prints the PR's reviews, approvals and unresolved threads as JSON.

## 1. Check that the PR can be merged

Read its state:

```sh
gh pr view <pr> --json number,state,isDraft,headRefName,headRefOid,mergeable,mergeStateStatus,reviewDecision,closingIssuesReferences,body
```

Every condition must hold:

1. **Open and ready:** `state` is `OPEN` and `isDraft` is `false`.
2. **Up to date with no conflicts:** `mergeable` is `MERGEABLE` and `mergeStateStatus` is neither `DIRTY`
   (conflicts) nor `BEHIND` (the branch lacks commits from the base branch, so CI and reviews did not see the code
   that would be merged). GitHub computes these lazily; if either is `UNKNOWN`, wait a few seconds and read it again.
3. **CI passes:** `gh pr checks <pr>` reports no failing or pending checks. Wait for pending checks with `--watch`.
4. **Reviews approve the head commit:** following [Pull requests](../../../AGENTS.md#pull-requests), `approvals`
   from `review-status.sh <pr>` has at least the required number of reviewers, and its `head` is `headRefOid`.
   Never request reviews: reviewers are configured to review every push.

   If `reviewedHead` has fewer reviewers than required (for example right after new commits or a rebase), poll the
   script every minute, for up to 30 minutes, until it has enough. Then check this condition again. If too few
   reviews arrive, the condition fails.

5. **No unresolved conversations:** `unresolvedThreads` from the same script is empty.
6. **No requested changes:** `reviewDecision` is not `CHANGES_REQUESTED`.

**Override:** skip condition 4 only when the invocation explicitly says to skip the review check (for example
`/merge-pr 42 skip review check`). Never skip the other conditions.

If a condition fails, reply with which ones failed and why, and stop.

## 2. Merge

The repository allows squash merges only. Pin the checked head commit so nothing pushed after the checks is merged:

```sh
gh pr merge <pr> --squash --match-head-commit <headRefOid>
```

Do not pass `--delete-branch`: GitHub deletes the remote branch on merge, and step 4 removes the local branch.

## 3. Check the referenced issues

Follow the merge rule in [AGENTS.md](../../../AGENTS.md#rules): every issue the PR references must be closed.

1. For each issue in `closingIssuesReferences`, confirm with `gh issue view <n> --json state -q .state` that it is
   `CLOSED`. The [`Issue status`](../../../.github/workflows/issue-status.yml) workflow then sets `status:done`.
2. Also look for issues the body mentions (`#<n>`) without a closing keyword.
3. Do not close issues or change their labels yourself. Tell the user which referenced issues are still open.

## 4. Clean up

Find the worktree that has the PR's branch checked out with `git worktree list --porcelain`. If it exists, is not the
main checkout and has no uncommitted changes, move out of it and remove it and its local branch from the main checkout:

```sh
main=$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")
cd "$main"
git worktree remove <worktree path>
git branch -D <headRefName>
```

`-D` is needed because a squash merge leaves the branch's own commits unmerged. Leave a worktree with uncommitted
changes in place and mention it. If the branch is checked out in the main checkout, leave it there.

## 5. Report

Reply with the merge commit, the issues that closed, any referenced issues still open, and what was cleaned up.
