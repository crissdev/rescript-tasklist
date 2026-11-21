---
name: merge-pr
description: Safely squash-merge a pull request once CI passes and Copilot code review recommends approval, then confirm its linked issues closed and clean up its worktree and local branch. Use when asked to merge a PR, or as the final step of the implement-issue skill.
argument-hint: "<PR number> [skip review check]"
---

# Merge a pull request

Merge the PR given as the argument, or the PR for the current branch when none is given. Check everything first and
merge only when every check passes. This skill does not fix problems: when a check fails, report it and stop.

In the commands below, `R=repos/<owner>/<repo>` and `<owner>/<repo>` come from `gh repo view --json nameWithOwner -q .nameWithOwner`.

## 1. Check that the PR can be merged

Read its state:

```sh
gh pr view <pr> --json number,state,isDraft,headRefName,headRefOid,mergeable,mergeStateStatus,reviewDecision,closingIssuesReferences,body
```

Every condition must hold:

1. **Open and ready:** `state` is `OPEN` and `isDraft` is `false`.
2. **No conflicts:** `mergeable` is `MERGEABLE` and `mergeStateStatus` is not `DIRTY`. GitHub computes these lazily;
   if `mergeable` is `UNKNOWN`, wait a few seconds and read it again.
3. **CI passes:** `gh pr checks <pr>` reports no failing or pending checks. Wait for pending checks with `--watch`.
4. **Copilot recommends approval:** the latest Copilot review is on the head commit (`headRefOid`), its summary
   reports no open issues (currently `🟢 Approval recommended` and `No open issues`), and no review threads are
   unresolved. Copilot never submits an `APPROVED` review, so this is the approval signal:

   ```sh
   gh api "$R/pulls/<pr>/reviews" \
     -q '[.[] | select(.user.login == "copilot-pull-request-reviewer[bot]")] | last | {commit_id, body}'
   gh api graphql -F owner=<owner> -F repo=<repo> -F pr=<pr> -f query='
     query($owner: String!, $repo: String!, $pr: Int!) {
       repository(owner: $owner, name: $repo) { pullRequest(number: $pr) {
         reviewThreads(first: 100) { nodes { isResolved } } } } }' \
     -q '[.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved | not)] | length'
   ```

5. **No human objections:** `reviewDecision` is not `CHANGES_REQUESTED`.

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
