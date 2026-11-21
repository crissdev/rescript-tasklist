%%raw("import './index.css'")

Instrument.init()

switch ReactDOM.querySelector("#root") {
| Some(domElement) =>
  ReactDOMClient.createRoot(
    domElement,
    {
      // A custom handler replaces React's default logging of uncaught errors.
      onUncaughtError: Sentry.reactErrorHandler(~callback=(error, _, _) => Console.error(error)),
      onCaughtError: Sentry.reactErrorHandler(),
      onRecoverableError: Sentry.reactErrorHandler(),
    },
  )->ReactDOM.Client.Root.render(
    <React.StrictMode>
      <App />
    </React.StrictMode>,
  )
| None => ()
}
