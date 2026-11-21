// Bindings for the subset of `@sentry/react` the app uses.
// https://docs.sentry.io/platforms/javascript/guides/react/

type integration

// https://docs.sentry.io/platforms/javascript/guides/react/configuration/options/
type options = {
  dsn?: string,
  environment?: string,
  release?: string,
  integrations?: array<integration>,
  tracesSampleRate?: float,
  replaysSessionSampleRate?: float,
  replaysOnErrorSampleRate?: float,
}

@module("@sentry/react") external init: options => unit = "init"

@module("@sentry/react")
external browserTracingIntegration: unit => integration = "browserTracingIntegration"

@module("@sentry/react")
external replayIntegration: unit => integration = "replayIntegration"

// Returns a handler for the React 19 root error options; see `ReactDOMClient.rootOptions`.
// The optional callback runs after Sentry captures the error and receives its event ID.
@module("@sentry/react")
external reactErrorHandler: (
  ~callback: (unknown, ReactDOMClient.errorInfo, string) => unit=?,
) => ReactDOMClient.rootErrorHandler = "reactErrorHandler"
