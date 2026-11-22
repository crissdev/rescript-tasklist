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
    H -- No --> I{Do feedback fixes require<br/>code changes?}
    I -- Yes --> AR{Review round remains?}
    AR -- Yes --> J[Fix and validate;<br/>reply and resolve threads;<br/>commit and push fixes]
    J --> G
    AR -- No --> X[Set status:needs-input;<br/>leave PR and worktree open]
    I -- No --> RR[Reply and resolve threads;<br/>no commit or push]
    RR --> H
    H -- Yes --> K[File discovered bugs;<br/>set issue status:in-review]
    K --> L{Branch is up to date with main<br/>and has no conflicts?}
    L -- Yes --> M
    L -- No --> N[Rebase onto latest main;<br/>resolve conflicts and validate]
    N --> O[Push rebased branch with --force-with-lease]
    O --> R{Review round remains?}
    R -- Yes --> S[Set issue status:in-progress]
    S --> G
    R -- No --> X
    N -- Cannot resolve conflicts --> AC[Run git rebase --abort]
    AC --> X

    subgraph Merge PR skill
        M[Recheck PR is open and ready,<br/>up to date with main and conflict-free,<br/>CI passes, approval is on current head,<br/>no unresolved threads, and reviewDecision<br/>is not CHANGES_REQUESTED] --> P{All merge checks pass?}
        P -- Yes --> Q[Immediately before merging,<br/>reread baseRefName and recheck behind_by]
        Q --> AD{Did baseRefName change?}
        AD -- Yes --> M
        AD -- No --> AE{behind_by equals 0?}
        AE -- Yes --> AF[Squash-merge pinned head commit]
        AF --> AG[Confirm referenced issues closed]
        AG --> AH{Worktree clean<br/>and not the main checkout?}
        AH -- Yes --> AI[Remove worktree and local branch]
        AH -- No --> AJ[Leave worktree in place and report]
    end

    P -- No --> W[Merge refused]
    W --> Y{Branch behind main<br/>or has conflicts?}
    Y -- Yes --> L
    Y -- No --> AA{Can implement-issue fix it<br/>within remaining review rounds?}
    AA -- Yes --> AB[Fix refusal, validate and push;<br/>set issue status:in-progress]
    AB --> G
    AA -- No --> X
    AE -- No --> AK[Report branch fell behind;<br/>return to implement-issue update path]
    AK --> L

    AI --> AL([Report merge, issue status,<br/>and cleanup])
    AJ --> AL
```
