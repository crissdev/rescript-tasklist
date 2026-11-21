// `createRoot` with options, which `@rescript/react` does not bind.
// https://react.dev/reference/react-dom/client/createRoot#parameters

type errorInfo = {componentStack?: string}

type rootErrorHandler = (unknown, errorInfo) => unit

type rootOptions = {
  onUncaughtError?: rootErrorHandler,
  onCaughtError?: rootErrorHandler,
  onRecoverableError?: rootErrorHandler,
}

@module("react-dom/client")
external createRoot: (Dom.element, rootOptions) => ReactDOM.Client.Root.t = "createRoot"
