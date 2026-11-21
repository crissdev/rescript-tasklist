# GitHub Issue Labels

Use this guide whenever you create or triage GitHub issues for this repository.
Apply labels when the issue is created so later cleanup is not needed.

## Label Rules

- Always apply exactly one type label: `bug`, `feature`, `enhancement` or `documentation`.
- Always apply at least one `area:*` label.
- Add `type:refactor`, `accessibility` or `needs-decision` only when they apply.
- Agents add `status:needs-triage` to every issue they create. The user replaces it with `status:ready` after verifying the issue. See the status workflow in [`AGENTS.md`](../AGENTS.md#issue-status).
- Record dependencies as GitHub "blocked by" links and parent issues as sub-issues, not only as text in the body.
- Prefer existing labels over creating one-off labels. Create a new label only when several future issues are likely to need it, and add it to this guide.
- Use `feature` for net-new user-facing capabilities described in [`APP_DESCRIPTION.md`](APP_DESCRIPTION.md).
- Use `enhancement` for improving existing behavior, UI or code, and for internal building blocks such as shared components, theme tokens, test bindings and tooling.
- Use `documentation` for docs and specs, such as `docs/*.md`, `README.md` and `AGENTS.md`.
- Remove `needs-decision` once the decision is recorded in the issue.

## Type Labels

| Label           | Use for                                                              |
| --------------- | -------------------------------------------------------------------- |
| `bug`           | Broken behavior, regressions, failing tests or CI                    |
| `feature`       | Net-new user-facing capability                                       |
| `enhancement`   | Improvement to existing behavior, UI, code, tests or tooling         |
| `documentation` | Docs, specs and agent guidelines                                     |
| `type:refactor` | Internal cleanup without a meaningful behavior change                |

## Cross-cutting Labels

| Label            | Use for                                                              |
| ---------------- | -------------------------------------------------------------------- |
| `accessibility`  | Keyboard access, focus, labels, screen readers, contrast             |
| `needs-decision` | An open design or technical decision blocks implementation           |

## Status Labels

| Label                 | Use for                                                       |
| --------------------- | ------------------------------------------------------------- |
| `status:needs-triage` | Created by an agent and waits for the user to verify it       |
| `status:ready`        | Approved by the user for agents to pick up                    |
| `status:in-progress`  | Claimed by an agent and being worked on                       |
| `status:needs-input`  | The claiming agent waits on the user for an answer            |
| `status:in-review`    | Work is done and waits for the user to review, merge or close |

## Area Labels

| Label                | Use for                                                                     |
| -------------------- | --------------------------------------------------------------------------- |
| `area:domain`        | Task and board models, statuses, pure domain logic                          |
| `area:state`         | App state, reducer and actions                                              |
| `area:storage`       | `localStorage` persistence, encoding and decoding                           |
| `area:board`         | Board layout, board name, columns and empty states                          |
| `area:cards`         | Normal and relaxed task cards, card style switch                            |
| `area:task-actions`  | Create, edit and delete task flows and their forms                          |
| `area:drag-and-drop` | Moving cards between columns by dragging                                    |
| `area:design-system` | `docs/DESIGN.md`, theme tokens in `src/index.css`, shared UI components     |
| `area:testing`       | Vitest and Playwright setup and bindings (`tests/bindings`, `e2e/bindings`) |
| `area:tooling`       | Build, ReScript and Vite config, CI, dependencies, git hooks                |

## Resolution Labels

GitHub's defaults `duplicate`, `invalid`, `wontfix`, `question`, `help wanted` and `good first issue` stay available for triage and closing issues.

## Examples

| Issue shape                                     | Labels                                                   |
| ----------------------------------------------- | -------------------------------------------------------- |
| Edited task keeps its old modified date         | `bug`, `area:state`, `area:task-actions`                 |
| Let the user create a task                      | `feature`, `area:task-actions`                           |
| Choose a drag-and-drop approach                 | `feature`, `area:drag-and-drop`, `needs-decision`        |
| Native dialog component with focus handling     | `enhancement`, `area:design-system`, `accessibility`     |
| Extract duplicated column markup                | `enhancement`, `type:refactor`, `area:board`             |
| Add `Locator.fill` to the Vitest bindings       | `enhancement`, `area:testing`                            |
| Write the design spec                           | `documentation`, `area:design-system`                    |

## Before Creating An Issue

1. Check for an existing issue with the same scope.
2. Pick one type label.
3. Add the most specific `area:*` labels.
4. Add `type:refactor`, `accessibility` or `needs-decision` only when useful.
5. Link blocking issues and sub-issues.
6. Write the body in the [issue body format](#issue-body).
7. If you are an agent, add `status:needs-triage`.
8. If the work is too large for one agent to finish without its context being compacted, do not split it yourself.
   Create it as a single issue and say in a comment that it needs decomposing.
   The developer splits it with the `decompose-issue` skill (`/decompose-issue <n>`).

## Issue Body

If `.github/` has an issue template, follow it. Otherwise use these sections:

```markdown
## Summary
## Scope
## Acceptance criteria   (as a - [ ] checklist)
## Depends on            (list "#N Title", or omit when there are no dependencies)

Part of #<parent> <parent title>.   (sub-issues only)

## Testing               (commands, plus pointers to AGENTS.md and relevant skills)
```

The body has enough context when an agent can start work without re-discovering facts you already found:

- **Scope** names the files, modules and bindings to change or add, the existing conventions to follow, and
  constraints from related issues, for example work that belongs to another issue.
- **Acceptance criteria** are checkable outcomes, including the tests that must cover them.
- Facts you have not verified, such as whether a binding or API exists, are written as the first step to check, not
  as settled.
- Product questions that the issue and its referenced docs do not answer go in an `## Open decisions` section with the
  `needs-decision` label. Do not choose an answer yourself.
