# Implementation and merge workflow

The [`implement-issue` skill](../.agents/skills/implement-issue/SKILL.md) takes one available issue from claim through implementation and review. When its merge checks pass, it hands the PR to the [`merge-pr` skill](../.agents/skills/merge-pr/SKILL.md), which rechecks the merge conditions, merges, confirms issue closure, and cleans up the worktree when it is safe.

```mermaid
flowchart TD
    A([Start: implement one issue]) --> B{Issue available?}
    B -- No --> Z([Report and stop])
    B -- Yes --> C[Claim issue and set status:in-progress]
    C --> D[Create dedicated worktree from latest main]
    D --> E[Implement and validate]
    E --> F[Open ready-for-review PR]
    F --> G[Wait for reviews and CI on current head]
    G --> H{Required approvals,<br/>CI passes, no unresolved threads?}
    H -- No --> I{Can address feedback<br/>within remaining review rounds?}
    I -- Yes --> J[Fix issues, reply to comments,<br/>resolve threads, rerun validation]
    J --> G
    I -- No --> X[Set status:needs-input;<br/>leave PR and worktree open]
    H -- Yes --> K[File discovered bugs;<br/>set issue status:in-review]
    K --> L{Branch is up to date with main<br/>and has no conflicts?}
    L -- Yes --> M
    L -- No --> N[Rebase onto latest main;<br/>resolve conflicts and validate]
    N --> R{Review round remains?}
    R -- Yes --> O[Push branch;<br/>set issue status:in-progress]
    O --> G
    R -- No --> X
    N -- Cannot resolve conflicts --> AC[Run git rebase --abort]
    AC --> X

    subgraph Merge PR skill
        M[Recheck PR is open and ready,<br/>up to date with main and conflict-free,<br/>CI passes, approval is on current head,<br/>no unresolved threads, and reviewDecision<br/>is not CHANGES_REQUESTED] --> P{All merge checks pass?}
        P -- Yes --> Q[Squash-merge pinned head commit]
        Q --> S[Confirm referenced issues closed]
        S --> T{Worktree clean<br/>and not the main checkout?}
        T -- Yes --> U[Remove worktree and local branch]
        T -- No --> V[Leave worktree in place and report]
    end

    P -- No --> W[Merge refused]
    W --> Y{Branch behind main<br/>or has conflicts?}
    Y -- Yes --> L
    Y -- No --> AA{Can implement-issue fix it<br/>within remaining review rounds?}
    AA -- Yes --> AB[Fix refusal, validate and push;<br/>set issue status:in-progress]
    AB --> G
    AA -- No --> X

    U --> AC([Report merge, issue status,<br/>and cleanup])
    V --> AC
```
