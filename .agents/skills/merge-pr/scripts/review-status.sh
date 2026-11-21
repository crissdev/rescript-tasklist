#!/usr/bin/env bash
# Usage: review-status.sh <pr>
#
# Prints the review state of a pull request as JSON, without depending on which reviewers review it:
#   head              head commit of the PR
#   reviews           latest review of each reviewer other than the PR author
#   reviewedHead      reviewers whose latest review is on the head commit
#   approvals         reviewers that approve the head commit (see "Pull requests" in AGENTS.md)
#   unresolvedThreads unresolved review threads, with their comments
set -euo pipefail

pr=${1:?usage: review-status.sh <pr>}
repo=$(gh repo view --json nameWithOwner -q .nameWithOwner)

gh api graphql -F owner="${repo%/*}" -F repo="${repo#*/}" -F pr="$pr" -f query='
  query($owner: String!, $repo: String!, $pr: Int!) {
    repository(owner: $owner, name: $repo) { pullRequest(number: $pr) {
      author { login }
      headRefOid
      reviews(last: 100) { nodes { author { login } state commit { oid } body } }
      reviewThreads(first: 100) { nodes { id isResolved path line
        comments(first: 20) { nodes { databaseId author { login } body } } } } } } }' \
  -q '.data.repository.pullRequest as $p
    | [$p.reviewThreads.nodes[] | select(.isResolved | not)] as $open
    | [$p.reviews.nodes[] | select(.author.login != $p.author.login and .state != "PENDING" and .state != "DISMISSED")]
    | group_by(.author.login) | map(last) as $latest
    | [$latest[] | select(.commit.oid == $p.headRefOid)] as $onHead
    | {
        head: $p.headRefOid,
        reviews: [$latest[] | {reviewer: .author.login, state, commit: .commit.oid, body}],
        reviewedHead: [$onHead[] | .author.login],
        approvals: [$onHead[] | .author.login as $r
          | select(.state != "CHANGES_REQUESTED"
              and ([$open[] | select(.comments.nodes[0].author.login == $r)] | length) == 0)
          | $r],
        unresolvedThreads: [$open[] | {id, path, line, comments: .comments.nodes}]
      }'
