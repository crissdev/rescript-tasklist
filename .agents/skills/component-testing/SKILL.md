---
name: component-testing
description: How to write, run, and debug React component tests in this repository (ReScript tests run by Vitest Browser Mode in Chromium, with V8 coverage). Use when adding, changing, running, or debugging tests, extending the Vitest bindings, or collecting coverage.
---

# Component testing

The general testing rules in `AGENTS.md` (no tautological tests, explicit test constants, selector guidance) still apply. This skill covers the project-specific setup.

## Setup

- Tests are ReScript files named `tests/**/*_test.res`. Vitest runs the compiled `tests/**/*_test.res.mjs` (see `test.include` in `vite.config.js`).
- `tests` is a ReScript `dev` source in `rescript.json`, so production code in `src` cannot depend on it.
- Tests run in [Vitest Browser Mode](https://vitest.dev/guide/browser/) in headless Chromium through `@vitest/browser-playwright`. Components are rendered with [`vitest-browser-react`](https://vitest.dev/api/browser/react).
- Coverage uses `@vitest/coverage-v8` and is reported on the compiled `src/**/*.res.mjs` files, because ReScript does not emit source maps. `src/Main.res.mjs` is excluded because it only mounts the app.
- Coverage reports go to `coverage/`, and failure screenshots go to `.vitest/`. Both are git-ignored.

## Commands

Run every command from the repository root after `nvm use`.

| Task | Command |
| --- | --- |
| Install Chromium (once per machine) | `bunx playwright install chromium` |
| Compile ReScript and run tests | `bun run test` |
| Compile ReScript and run tests with coverage | `bun run test:coverage` |
| Watch mode | `bun run res:dev` and `bun run test:watch` in separate terminals |
| Watch in a visible browser | append `--browser.headless=false` to a Vitest command |

`test:watch` does not compile ReScript, so it needs `res:dev` running alongside it.

## Bindings

- Local bindings live in `tests/bindings` and cover only the APIs the tests use. `Vitest.res` binds `describe`, `test`, locators and `expect.element`. `VitestBrowserReact.res` binds `render`.
- When a test needs another API, extend these bindings rather than adding a third-party binding package. Check the signature against the installed type declarations in `node_modules` first.
  - Test API: https://vitest.dev/api/test
  - Locators: https://vitest.dev/api/browser/locators
  - Assertions: https://vitest.dev/api/browser/assertions
- Add ARIA roles to `Vitest.Locator.role` as tests need them.

## Writing tests

- Use the locator returned by `VitestBrowserReact.render`, which is scoped to the rendered component.
- Prefer `Locator.getByRole` with `exact: true` and a literal `name`.
- Assert with `Expect.element`, which retries until the assertion passes or times out. Do not add manual waits.
- Await every locator action and assertion.
- Follow `tests/App_test.res` as the reference example.

## Verifying a new test

To confirm that a new test can fail, temporarily break the behavior it covers, run `bun run test`, check that the test fails, then restore the code.
