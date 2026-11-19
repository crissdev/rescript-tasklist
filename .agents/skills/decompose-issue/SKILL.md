---
name: decompose-issue
description: Split a large GitHub issue into small, dependency-ordered sub-issues that an AI agent can implement one at a time, in parallel where possible. Proposes a table first and creates the sub-issues on GitHub only after the developer confirms.
argument-hint: "<issue number>"
disable-model-invocation: true
---

# Decompose an issue

Split the parent issue given as the argument into sub-issues. Each sub-issue must be small enough for one agent to finish without its context being compacted, and must still contribute directly to the parent issue.

The work has two phases. Stop after phase 1 and wait. Start phase 2 only when the developer explicitly asks for the issues to be created.

## Phase 1: Propose

1. Read the parent issue, including its comments, acceptance criteria and any linked or blocking issues: `gh issue view <n> --comments`.
2. Look at the parts of the repository the issue touches, just enough to find shared files, existing conventions and missing building blocks. Do not implement, prototype or run experiments. If something needs checking (for example whether a binding or API exists), make that check the first step of the relevant sub-issue.
3. Split the work using these rules:
   - **One logical change per sub-issue.** It should cover one component, one layer or one document, together with its tests and its `.resi` file. As a rough limit, aim for a handful of source files.
   - **Pull shared prerequisites out early.** When several sub-issues would edit the same shared file (test bindings, theme tokens, a spec), give that work its own sub-issue and have the others depend on it. This avoids edit conflicts between parallel agents.
   - **Make dependencies explicit and minimal.** A sub-issue depends on another only when it actually needs that one's output. Maximise the work that can run in parallel.
   - **Cover the parent.** Every acceptance criterion of the parent issue maps to at least one sub-issue. If the criteria span several sub-issues, add a final acceptance-check sub-issue that depends on the rest, and say that it is optional.
   - **Respect existing scope.** Do not pull in work that the parent assigns to other issues. Note any constraints this places on the sub-issues instead (for example "only update the call site").
   - **Do not make product decisions.** If the parent issue, its comments and the docs it references do not settle a product question (behaviour, UX, copy, visual design, priorities or scope), do not choose an answer and do not write it into a sub-issue as if it were settled. List the question as an open decision and say which sub-issues it blocks. Technical choices needed only to split the work are fine; state them as assumptions.
4. Reply with:
   - a short note on any repository findings that shaped the split;
   - a table with the columns `#`, `Title`, `One-line description` and `Depends on`, numbered locally (1, 2, 3…);
   - the execution order, for example "1 and 2 in parallel, then 3, then 4–6 in parallel";
   - any split you were unsure about, such as two items that could be merged or separated;
   - an **Open decisions** list: each question, why the sources don't answer it, and which sub-issues it affects. Write "None" if there are none.

Do not create any GitHub issues in this phase.

## Phase 2: Create on GitHub

Only after the developer confirms the table, including any changes they asked for:

1. Read [`docs/GITHUB_ISSUES.md`](../../../docs/GITHUB_ISSUES.md) and apply its labels to every sub-issue when you create it.
2. Check `.github/` for issue templates. If there are none, follow the format of the parent and its existing sub-issues:

   ```markdown
   ## Summary
   ## Scope
   ## Acceptance criteria   (as a - [ ] checklist)
   ## Depends on            (list "#N Title", or omit when there are no dependencies)

   Part of #<parent> <parent title>.

   ## Testing               (commands, plus pointers to AGENTS.md and relevant skills)
   ```

   Give each body enough context (files, conventions, constraints from phase 1) for an agent to pick it up without re-discovering the same facts. Include only the decisions the developer has confirmed. If a decision is still open, add an `## Open decisions` section that states the question and apply the `needs-decision` label.
3. Create the issues in dependency order with `gh issue create`, so each `Depends on` section can refer to real issue numbers.
4. Link each issue to the parent as a sub-issue, then record its blockers. Both endpoints take the issue's database `id`, not its number:

   ```sh
   R=repos/<owner>/<repo>
   id() { gh api "$R/issues/$1" -q .id; }
   gh api -X POST "$R/issues/<parent>/sub_issues" -F sub_issue_id="$(id <child>)"
   gh api -X POST "$R/issues/<child>/dependencies/blocked_by" -F issue_id="$(id <blocker>)"
   ```

5. Verify the result with `gh api "$R/issues/<parent>/sub_issues" -q '[.[].number]'` and, for each child, `gh api "$R/issues/<child>/dependencies/blocked_by" -q '[.[].number]'`.
6. Reply with a table listing each issue number, title and "Blocked by" entry, and mention any constraints you wrote into specific issues.
