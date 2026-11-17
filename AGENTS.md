## Development

- Do not sign yourself in any git commit (adding Co-authored-by) unless I ask you to.
- Work in the main checkout unless I specify otherwise. Do not implicitly create a new branch or work in a worktree.

## Project

- This project uses ReScript and React.
- ReScript is the primary language for application logic and React components.
- TypeScript/JavaScript is used only where explicitly required for interoperability or tooling.

## Documentation

- ReScript language: https://rescript-lang.org/llms.txt
- ReScript React: https://www.rescript-lang.org/llms/react/llms.txt
- React: https://react.dev/llms.txt
- Vercel React Best Practices: use the installed `vercel-react-best-practices` skill when applicable.

### Documentation requirements

- Use documentation matching the installed dependency versions.
- Before implementing or modifying React functionality, consult the relevant official React documentation.
- Use the React LLM documentation index to discover relevant pages. Read the specific documentation relevant to the APIs, hooks, components or concepts involved.
- Do not read the entire documentation for every change. Consult only the relevant sections.
- Check the installed React version in package.json and the lockfile before using APIs introduced in newer React releases.
- Treat the latest React documentation as a reference for available features, not proof that those features are supported by the installed version or ReScript bindings.
- Consult the ReScript React documentation to verify how React APIs are exposed through ReScript.
- Do not assume ReScript v11 syntax or configuration is compatible with v12.

## Implementation rules

- Prefer idiomatic ReScript over JavaScript-style translations.
- Use ReScript's type system instead of unnecessary runtime validation.
- Prefer pattern matching and explicit domain types.
- Avoid unnecessary JavaScript interop.
- Keep external library bindings isolated and documented.
- Follow the existing module and file organization.
- Use the official React bindings rather than inventing custom React abstractions.

## React

- Use function components and React hooks.
- Follow React's rules of hooks.
- Respect React rendering, state and effect semantics.
- Prefer typed component props.
- Follow existing conventions for events, refs, keys and JSX.
- Follow current official React recommendations rather than relying on potentially outdated LLM knowledge.
- Do not introduce React APIs or patterns without verifying their availability in the installed version and ReScript bindings.

## Validation

- Run the ReScript compiler after making changes.
- Run relevant tests.
- Never assume generated JavaScript is correct without successful compilation.
- Fix compiler errors rather than suppressing them.
- Verify JavaScript/TypeScript interoperability at integration boundaries.

## Before completing a task

- Report the files changed.
- Report validation commands and their results.
- Identify any unverified assumptions or missing bindings.
