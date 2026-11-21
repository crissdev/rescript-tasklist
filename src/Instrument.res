// Sentry is disabled when `VITE_SENTRY_DSN` is unset, for example in tests and CI.
let init = () => {
  let env = ViteEnv.importMeta.env
  Sentry.init({
    dsn: ?env.sentryDsn,
    environment: env.vercelEnv->Option.getOr(env.mode),
    release: ?env.vercelGitCommitSha,
    integrations: [
      Sentry.browserTracingIntegration(),
      Sentry.replayIntegration(),
      Sentry.consoleLoggingIntegration(),
    ],
    tracesSampleRate: env.dev ? 1.0 : 0.1,
    replaysSessionSampleRate: 0.1,
    replaysOnErrorSampleRate: 1.0,
  })
}
