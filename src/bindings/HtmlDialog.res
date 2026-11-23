// Modal methods of `HTMLDialogElement`.
// `JsxDOM.domProps` includes `open_` (the `open` attribute). It does not include
// `onClose` or `onCancel`, even though React 19 listens for the dialog `close` and
// `cancel` events (https://react.dev/reference/react-dom/components/common#dialog-or-div).
// Setting `open` shows a non-modal dialog, so `Dialog` calls `showModal` and `close`
// and listens for the native `close` event instead.
// https://developer.mozilla.org/en-US/docs/Web/API/HTMLDialogElement

@send external showModal: Dom.element => unit = "showModal"
@send external close: Dom.element => unit = "close"

@get external open_: Dom.element => bool = "open"

@send
external addCloseListener: (Dom.element, @as("close") _, unit => unit) => unit = "addEventListener"

@send
external removeCloseListener: (Dom.element, @as("close") _, unit => unit) => unit =
  "removeEventListener"
