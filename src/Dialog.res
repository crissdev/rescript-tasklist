// Shared modal dialog. See "Dialogs" in docs/DESIGN.md.

let className = size => {
  let width = switch size {
  | #default => "max-w-dialog"
  | #sm => "max-w-dialog-sm"
  }
  `m-auto w-[calc(100%_-_2_*_var(--spacing-page))] ${width} rounded-dialog bg-surface p-dialog-inset text-ink shadow-dialog backdrop:bg-backdrop focus-visible:outline-focus focus-visible:outline-offset-focus focus-visible:outline-focus-ring`
}

@react.component
let make = (~isOpen, ~onClose, ~title, ~size=#default, ~children) => {
  let dialogRef = React.useRef(Nullable.null)
  let onCloseRef = React.useRef(onClose)
  let openingId = React.useRef(0)
  // Opening id passed to `close()`. `close()` queues its close event, so a newer
  // opening can call `showModal()` before that event runs.
  let closeRequestedFor = React.useRef(0)
  let titleId = React.useId()
  onCloseRef.current = onClose

  React.useLayoutEffect0(() => {
    switch dialogRef.current->Nullable.toOption {
    | None => None
    | Some(dialog) =>
      let handleClose = () => {
        let requested = closeRequestedFor.current
        let current = openingId.current
        closeRequestedFor.current = 0
        // A queued event from an earlier `close()` does not belong to the opening
        // now on screen. Escape leaves `closeRequestedFor` at 0 and closes the
        // current opening, so it still notifies the parent.
        let belongsToCurrentOpening = requested == 0 || requested == current
        if belongsToCurrentOpening && !(dialog->HtmlDialog.open_) {
          onCloseRef.current()
        }
      }
      dialog->HtmlDialog.addCloseListener(handleClose)
      Some(() => dialog->HtmlDialog.removeCloseListener(handleClose))
    }
  })

  React.useLayoutEffect1(() => {
    switch dialogRef.current->Nullable.toOption {
    | None => ()
    | Some(dialog) =>
      let isDialogOpen = dialog->HtmlDialog.open_
      if isOpen && !isDialogOpen {
        openingId.current = openingId.current + 1
        dialog->HtmlDialog.showModal
      } else if !isOpen && isDialogOpen {
        closeRequestedFor.current = openingId.current
        dialog->HtmlDialog.close
      }
    }
    None
  }, [isOpen])

  <dialog ref={ReactDOM.Ref.domRef(dialogRef)} className={className(size)} ariaLabelledby=titleId>
    <div className="flex flex-col gap-dialog-stack">
      <h2 id=titleId className="text-dialog-title text-ink"> {React.string(title)} </h2>
      children
    </div>
  </dialog>
}
