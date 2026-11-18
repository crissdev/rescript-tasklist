# Task List

A task list app built with ReScript and React.

## Tech stack

- [ReScript](https://rescript-lang.org) 12 with [@rescript/react](https://github.com/rescript-lang/rescript-react) 0.15 and JSX v4
- [React](https://react.dev) 19
- [Vite](https://vite.dev) 8 with the React plugin (Fast Refresh)
- [Tailwind CSS](https://tailwindcss.com) 4
- [Vitest](https://vitest.dev) 5 with Browser Mode (Playwright) and V8 coverage
- [Bun](https://bun.sh) as the package manager

ReScript compiles to ES modules next to the sources (`*.res.mjs`).

## Getting started

```sh
nvm use
bun install
```

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
bun run res:build
bun run build     # outputs to dist/
bun run preview   # serves the production build
```

## Testing

Component tests are written in ReScript (`tests/**/*_test.res`) and run in Chromium with [Vitest Browser Mode](https://vitest.dev/guide/browser/).

```sh
bunx playwright install chromium   # once
bun run test                       # or: bun run test:coverage
```

See [`.agents/skills/component-testing/SKILL.md`](.agents/skills/component-testing/SKILL.md) for details.

## Contributing

Coding conventions, including the `.resi` rule that keeps Fast Refresh working, are in [`AGENTS.md`](AGENTS.md).
