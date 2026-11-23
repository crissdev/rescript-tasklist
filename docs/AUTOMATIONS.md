# Task-list automations

Task-list automation is split between repository-owned configuration and Copilot app automations.
Repository-owned configuration is versioned in Git. Copilot app configuration is stored by the app and is documented here as a maintained inventory.

## Copilot app automations

| Name | Project scope | Mode |
| --- | --- | --- |
| Implementation activity | `task-list`, local branch workspace | Autopilot |
| Decompose issue | `task-list`, local branch workspace | Autopilot |

Both automations use Claude Opus 5.5 with high reasoning effort.

### Implementation activity

Delivers one available `status:ready` issue end to end using the [`implement-issue`](../.agents/skills/implement-issue/SKILL.md) skill.

The automation is unattended: it must not wait for answers in the session. When user input is required, it comments on the issue, changes it to `status:needs-input`, and stops. If no issue is available, it reports that outcome and stops.

This automation does not start without a ready issue and should remain disabled unless unattended issue delivery is intentional.

### Decompose issue

Checks open issues that have no `needs-decision` label and no sub-issues, then uses the [`decompose-issue`](../.agents/skills/decompose-issue/SKILL.md) skill to split suitable issues without confirmation.

Review decomposed issues before approving follow-on implementation work. This automation should remain disabled while no decomposition backlog is being actively managed.

### Managing app automations

Open **Automations** in the Copilot app and select the `task-list` project. From an automation, review or change its prompt, model, reasoning effort, mode, workspace type and schedule, then enable or disable it explicitly.

Keep this document in sync when an app automation is added, removed, renamed, or intentionally changed. App automation configuration is not written to this repository, so Git history cannot recover the previous app settings.

## Repository-owned automation

| Automation | Trigger | Configuration | Purpose |
| --- | --- | --- | --- |
| Lefthook pre-commit | Git commit | [`lefthook.yml`](../lefthook.yml) | Formats staged `*.res` and `*.resi` files and restages fixes |
| CI | Push to `main` or pull request | [`.github/workflows/ci.yml`](../.github/workflows/ci.yml) | Checks formatting, builds, runs component coverage tests and runs E2E tests |
| Issue status | Issue closed | [`.github/workflows/issue-status.yml`](../.github/workflows/issue-status.yml) | Replaces any status label with `status:done` only when the issue is closed as completed |
| Dependabot | Weekly | [`.github/dependabot.yml`](../.github/dependabot.yml) | Opens dependency updates for Bun and GitHub Actions; keeps Playwright packages grouped |
| Implementation and merge workflow | Agent skill invocation | [`docs/implementation-and-merge-workflow.md`](implementation-and-merge-workflow.md) | Describes issue claiming, implementation, review fixes, merge checks and cleanup |

The CI workflow also uploads the Playwright HTML report for seven days when a run fails. It cancels an older run for the same workflow and Git ref when a newer run starts.

## Agent skills

Agent skills are reusable instructions, not schedules:

- [`implement-issue`](../.agents/skills/implement-issue/SKILL.md) claims and delivers an available issue, and then hands merge work to `merge-pr`.
- [`merge-pr`](../.agents/skills/merge-pr/SKILL.md) verifies approvals, CI, unresolved threads and branch freshness before merging.
- [`decompose-issue`](../.agents/skills/decompose-issue/SKILL.md) splits a suitable issue into smaller issues.
- [`component-testing`](../.agents/skills/component-testing/SKILL.md) guides ReScript component test changes and validation.

The Implementation activity app automation invokes `implement-issue`; the Decompose issue app automation invokes `decompose-issue`. Neither app automation is a GitHub Actions workflow.
