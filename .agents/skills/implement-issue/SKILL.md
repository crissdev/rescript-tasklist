---
name: implement-issue
description: Take one available `status:ready` GitHub issue from claim to merge — claim it, implement it in a dedicated git worktree, open a PR, iterate on Copilot code review until it recommends approval, file issues for bugs found along the way, then merge with the merge-pr skill. Use when asked to pick up, implement or ship an issue, or when running unattended issue automation.
argument-hint: "[issue number]"
---

# Implement an issue end to end

Deliver **one** issue per invocation. Never start work on a second issue, even if the first finishes early. Other
agents may be working on other issues at the same time; leave their issues, branches and worktrees alone.

Follow [`AGENTS.md`](../../../AGENTS.md) throughout, especially [Issue status](../../../AGENTS.md#issue-status). This
skill only adds the steps that are specific to delivering an issue.

In the commands below, `R=repos/<owner>/<repo>` and `<owner>/<repo>` come from `gh repo view --json nameWithOwner -q .nameWithOwner`.

## Agent ID and session link

Pick the agent ID once and use it for every claim, release and footer:

- **Agent ID:** your harness's session ID, for example `$COPILOT_AGENT_SESSION_ID` in GitHub Copilot. If the harness
  exposes none, use your agent name plus the branch name.
- **Session link:** the URL your harness gives for this session or task, if any. Never invent a link; omit it when you
  do not have one.

## 1. Pick and claim an issue

1. If an issue number was given, use only that issue. Otherwise list the candidates, oldest first:
   `gh issue list --state open --label status:ready --json number,title,labels --limit 100 -q 'sort_by(.number)'`.
2. Take the first **available** candidate as defined in [AGENTS.md](../../../AGENTS.md#issue-status): no
   `needs-decision` label, and no open blockers or open sub-issues:

   ```sh
   gh api "$R/issues/<n>/dependencies/blocked_by" -q '[.[] | select(.state == "open") | .number]'
   gh api "$R/issues/<n>/sub_issues" -q '[.[] | select(.state == "open") | .number]'
   ```

3. Claim it with the [claiming steps](../../../AGENTS.md#claiming-an-issue). If you lose the race, try the next
   candidate (a given issue number has no next candidate).
4. If nothing is available, report that and stop. This is a normal outcome, not an error.

## 2. Create the worktree

Automated work always runs in a dedicated git worktree, never in the main checkout or a checkout shared with other
agents. Create it from the latest `main`, next to the main checkout:

```sh
main=$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")
wt="$main/../$(basename "$main")-worktrees/issue-<n>"
git -C "$main" fetch origin main
git -C "$main" worktree add -b issue-<n>-<short-slug> "$wt" origin/main
```

If that path or branch already exists, it belongs to an earlier or concurrent run: do not reuse or delete it. Release
the issue ([While working](../../../AGENTS.md#while-working)) noting the leftover worktree, and stop.

Run every later command inside `$wt`. Set up the environment there as
[Environment setup](../../../AGENTS.md#environment-setup) describes (`nvm use`, then `bun install`).

## 3. Implement

1. Re-read the issue with `gh issue view <n> --comments`, including its acceptance criteria and linked issues.
2. Implement it following [AGENTS.md](../../../AGENTS.md) and the skills it points to. Make focused commits.
3. Validate: compile, run `bun run test`, and run `bun run test:e2e` when the change affects user-facing behaviour or
   the e2e setup. Every acceptance criterion must be met.
4. Keep a list of **discovered bugs**: problems you notice that are outside this issue's scope. Do not fix them in
   this PR (see step 6).
5. If the issue cannot be finished without a product decision or another blocker, handle it as in step 7.

## 4. Open the pull request

Push the branch and open a ready-for-review PR against `main` with `gh pr create`. The body contains:

- a short summary of the change;
- `Closes #<n>` so the merge closes the issue;
- how it was tested;
- a footer naming the session, for example:

  ```markdown
  ---
  <sub>🤖 Implemented by <agent name> · session `<agent ID>` · [session link](<session link>)</sub>
  ```

## 5. Copilot review loop

Run at most **5** review rounds. A round is one Copilot review of the current head commit.

1. Request a review: `gh pr edit <pr> --add-reviewer @copilot` (this also re-requests it in later rounds).
2. Wait for it. Poll every minute, for up to 30 minutes, until a Copilot review of the head commit exists:

   ```sh
   head=$(gh pr view <pr> --json headRefOid -q .headRefOid)
   gh api "$R/pulls/<pr>/reviews" \
     -q "[.[] | select(.user.login == \"copilot-pull-request-reviewer[bot]\" and .commit_id == \"$head\")] | last | .body"
   ```

   If none arrives, re-request once and wait again. If it still does not arrive, handle it as in step 7.
3. Read the unresolved review threads (GraphQL reports the reviewer as `copilot-pull-request-reviewer`, without `[bot]`):

   ```sh
   gh api graphql -F owner=<owner> -F repo=<repo> -F pr=<pr> -f query='
     query($owner: String!, $repo: String!, $pr: Int!) {
       repository(owner: $owner, name: $repo) { pullRequest(number: $pr) {
         reviewThreads(first: 100) { nodes { id isResolved path line
           comments(first: 20) { nodes { databaseId author { login } body } } } } } } }' \
     -q '[.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved | not)]'
   ```

4. The review **recommends approval** when it is on the head commit, its summary reports no open issues (currently
   `🟢 Approval recommended` and `No open issues`), and no review threads are unresolved. Copilot never submits an
   `APPROVED` review, so this is the approval signal. Also wait for CI with `gh pr checks <pr> --watch`. If both pass,
   go to step 6.
5. Otherwise address every unresolved thread and failing check:
   - Fix valid in-scope comments with focused commits and re-run the relevant validation.
   - For comments you disagree with, or that are valid but out of scope, reply with the reason. Add out-of-scope bugs
     to the discovered bugs list.
   - Reply in each thread, then resolve it:

     ```sh
     gh api -X POST "$R/pulls/<pr>/comments/<first comment databaseId>/replies" -f body='<reply>'
     gh api graphql -f query='mutation($id: ID!) { resolveReviewThread(input: {threadId: $id}) { thread { isResolved } } }' -f id=<thread id>
     ```

   - Fix failing CI the same way. Push, then start the next round.
6. If approval is still not recommended after round 5, handle it as in step 7.

## 6. File discovered bugs and merge

1. For each discovered bug, check that no open issue covers it, then create one as
   [`docs/GITHUB_ISSUES.md`](../../../docs/GITHUB_ISSUES.md) describes (labels, `status:needs-triage`, body format).
   Mention the PR in the body, and list the new issues in a PR comment.
2. Switch the issue to `status:in-review`.
3. Merge with the [`merge-pr`](../merge-pr/SKILL.md) skill. It merges, checks that the issue closed and removes the
   worktree. If it refuses to merge, fix what it reports when you can (for example a merge conflict: merge `main`,
   validate, push, switch back to `status:in-progress` and run the review loop again within the remaining rounds).
   Otherwise handle it as in step 7.

## 7. Blockers

When you have to stop before merging (an open product decision, no review arrives, the round limit is reached, an
unfixable CI failure, or a merge conflict you cannot resolve):

1. Comment on the issue with what is done, what is left, the PR link if there is one, and what you need from the user.
2. Switch the issue to `status:needs-input`.
3. Leave the PR open and the worktree in place, and stop.

## 8. Report

Reply with the issue, the PR, the merge result, the review rounds used and any issues you created.
