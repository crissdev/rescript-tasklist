# Agent Guidelines

## Project overview

- This project uses ReScript and React.
- ReScript is the primary language for application logic and React components.
- TypeScript/JavaScript is used only where explicitly required for interoperability or tooling.

## Environment setup

### Node.js version

Before running project commands, change to the repository directory that contains `.nvmrc` and run `nvm use` there.
Do not run `nvm use` from a parent directory or a different working copy; use the `.nvmrc` that belongs to the
worktree where the project command will run.

If `nvm use` reports that the version from `.nvmrc` is not installed, remain in the directory containing `.nvmrc`
and run `nvm install` without a version argument so NVM installs the repository-pinned version. Then run `nvm use`
again. If the `nvm` command itself is unavailable, stop and report that NVM is not loaded or installed instead of
silently using a different Node.js version.

## Documentation

### References

- ReScript language: https://rescript-lang.org/llms.txt
- ReScript React: https://www.rescript-lang.org/llms/react/llms.txt
- React: https://react.dev/llms.txt
- Vercel React Best Practices: use the installed `vercel-react-best-practices` skill when applicable.

### Usage requirements

- Use documentation matching the installed dependency versions.
- Do not assume ReScript v11 syntax or configuration is compatible with v12.
- Check the installed React version in `package.json` and the lockfile before using APIs introduced in newer React releases.
- Treat the latest React documentation as a reference for available features, not proof that those features are supported by the installed version or ReScript bindings.
- Before implementing or modifying React functionality, consult the relevant official React documentation.
- Use the React LLM documentation index to discover relevant pages. Read the specific documentation relevant to the APIs, hooks, components or concepts involved.
- Consult the ReScript React documentation to verify how React APIs are exposed through ReScript.
- Do not read the entire documentation for every change. Consult only the relevant sections.

## Implementation

### ReScript

- Prefer idiomatic ReScript over JavaScript-style translations.
- Use ReScript's type system instead of unnecessary runtime validation.
- Prefer pattern matching and explicit domain types.
- Avoid unnecessary JavaScript interop.
- Keep external library bindings isolated and documented.
- Follow the existing module and file organization.

### React

- Use function components and React hooks.
- Use the official React bindings rather than inventing custom React abstractions.
- Follow React's rules of hooks.
- Respect React rendering, state and effect semantics.
- Prefer typed component props.
- Follow existing conventions for events, refs, keys and JSX.
- Follow current official React recommendations rather than relying on potentially outdated LLM knowledge.
- Do not introduce React APIs or patterns without verifying their availability in the installed version and ReScript bindings.

## Testing

### No tautological tests

Tests must verify an independent behavioral contract and fail when that contract is broken. Do not compare a value with itself, derive the expected result from the implementation under test, or mock the behavior under test and only assert its configured return value. Use explicit expected results or an independent oracle, and limit mocks to collaborators.

### Test constants

When a test asserts a production contract, keep the expected value explicit in the test or in a test-local constant. Do not import production constants only to mirror the value being asserted, because the test would update with the implementation and stop catching unintended contract changes.

Production imports are fine for types, schemas, factories, enum values used to create valid setup data, or helpers that are not the expected value under assertion. If a production constant is part of the behavior being verified, repeat the expected literal in the test and let a production change break the test intentionally.

### E2E selectors

Use stable `data-testid` selectors for E2E assertions whenever possible. Avoid `.locator()` and `.getByText()` in E2E tests, and use exact string values for role `name` options instead of regular expressions.

## Validation

- Run the ReScript compiler after making changes.
- Fix compiler errors rather than suppressing them.
- Never assume generated JavaScript is correct without successful compilation.
- Run relevant tests.
- Verify JavaScript/TypeScript interoperability at integration boundaries.

## Git

- Do not sign yourself in any git commit (adding Co-authored-by) unless I ask you to.
- Work in the main checkout unless I specify otherwise. Do not implicitly create a new branch or work in a worktree.

## Before completing a task

- Report the files changed.
- Report validation commands and their results.
- Identify any unverified assumptions or missing bindings.
