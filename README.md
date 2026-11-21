# Task List

A task list app built with ReScript and React.

## Tech stack

- [ReScript](https://rescript-lang.org) 12 with [@rescript/react](https://github.com/rescript-lang/rescript-react) 0.15 and JSX v4
- [React](https://react.dev) 19
- [Vite](https://vite.dev) 8 with the React plugin (Fast Refresh)
- [Tailwind CSS](https://tailwindcss.com) 4
- [Vitest](https://vitest.dev) 5 with Browser Mode (Playwright) and V8 coverage
- [Playwright Test](https://playwright.dev) for end-to-end tests
- [Bun](https://bun.sh) as the package manager

ReScript compiles to ES modules next to the sources (`*.res.mjs`).

## Getting started

```sh
nvm use
bun install
```

### Error monitoring

The app reports errors, traces, logs and Session Replays to [Sentry](https://sentry.io) when `VITE_SENTRY_DSN` is set, and Sentry stays disabled otherwise. For local development, put the project's DSN in `.env.development.local`, which git ignores:

```sh
VITE_SENTRY_DSN=https://<key>@<host>/<project-id>
```

Production builds read `VITE_SENTRY_DSN` from the build environment, so set it in the Vercel project's environment variables. On Vercel, Sentry tags events with the deployment environment (`VITE_VERCEL_ENV`) and uses the commit SHA (`VITE_VERCEL_GIT_COMMIT_SHA`) as the release; elsewhere the environment is Vite's mode. Traces are sampled at 100% in development and 10% in production builds.

Sentry captures console output as logs at all supported levels, including `console.log`, `console.warn` and `console.error`. Avoid logging sensitive information.

When `SENTRY_AUTH_TOKEN` is set at build time, `bun run build` generates hidden source maps, uploads them to Sentry and deletes them from `dist/`, so production stack traces stay readable. Add the token, an [organization auth token](https://docs.sentry.io/account/auth-tokens/), to the Vercel project's environment variables and never commit it. Without it, the build skips source maps.

## Development

Run the ReScript compiler in watch mode:

```sh
bun run res:dev
```

In another terminal, start the Vite dev server:

```sh
bun run dev
```

## Building

```sh
bun run build     # compiles ReScript and outputs to dist/
bun run preview   # serves the production build
```

## Testing

Component tests are written in ReScript (`tests/**/*_test.res`) and run in Chromium with [Vitest Browser Mode](https://vitest.dev/guide/browser/).

```sh
bunx playwright install chromium   # once
bun run test                       # or: bun run test:coverage
```

See [`.agents/skills/component-testing/SKILL.md`](.agents/skills/component-testing/SKILL.md) for details.

End-to-end tests are written in ReScript (`e2e/**/*_spec.res`) and run with [Playwright Test](https://playwright.dev) in Chromium against the production build served by `vite preview`. Bindings live in `e2e/bindings`.

```sh
bun run test:e2e   # builds the app, then runs the e2e specs
```

## Formatting

```sh
bun run format         # formats all ReScript files
bun run format:check   # fails if any file needs formatting
```

`bun install` sets up a [Lefthook](https://lefthook.dev) pre-commit hook that formats staged `.res`/`.resi` files and re-stages them.

## Continuous integration

[`.github/workflows/ci.yml`](.github/workflows/ci.yml) runs the format check, production build, component tests and e2e tests on pushes to `main` and on pull requests. The Playwright HTML report is uploaded as an artifact when a run fails. [Dependabot](.github/dependabot.yml) checks Bun dependencies and GitHub Actions weekly.

## Contributing

Coding conventions, including the `.resi` rule that keeps Fast Refresh working, are in [`AGENTS.md`](AGENTS.md).
