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
    F --> G[Wait for reviews and CI]
    G --> H{Approval on current head,<br/>CI passes, no unresolved threads?}
    H -- No --> I{Can address feedback<br/>within 5 rounds?}
    I -- Yes --> J[Fix issues, reply to comments,<br/>resolve threads, rerun validation]
    J --> F
    I -- No --> X[Set status:needs-input;<br/>leave PR and worktree open]
    H -- Yes --> K[File discovered bugs and switch issue to status:in-review]
    K --> M

    subgraph Merge PR skill
        M[Recheck PR is open and ready,<br/>conflict-free, CI-passing,<br/>approved on current head,<br/>and has no unresolved threads] --> N{All merge checks pass?}
        N -- No --> O([Report failed checks and stop])
        N -- Yes --> P[Squash-merge pinned head commit]
        P --> Q[Confirm referenced issues closed]
        Q --> R{Worktree clean<br/>and not the main checkout?}
        R -- Yes --> S[Remove worktree and local branch]
        R -- No --> T[Leave worktree in place and report]
        S --> U([Report merge, issue status,<br/>and cleanup])
        T --> U
    end
```
