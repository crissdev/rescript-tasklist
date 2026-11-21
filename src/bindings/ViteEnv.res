// Vite's `import.meta.env`. Only variables prefixed with `VITE_` are exposed to client code.
// https://vite.dev/guide/env-and-mode

type env = {
  @as("MODE") mode: string,
  @as("DEV") dev: bool,
  @as("VITE_SENTRY_DSN") sentryDsn?: string,
  // Set by Vercel at build time.
  // https://vercel.com/docs/environment-variables/framework-environment-variables
  @as("VITE_VERCEL_ENV") vercelEnv?: string,
  @as("VITE_VERCEL_GIT_COMMIT_SHA") vercelGitCommitSha?: string,
}

type importMeta = {env: env}

external importMeta: importMeta = "import.meta"
