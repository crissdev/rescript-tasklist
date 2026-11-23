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
  let titleId = React.useId()
  onCloseRef.current = onClose

  React.useLayoutEffect0(() => {
    switch dialogRef.current->Nullable.toOption {
    | None => None
    | Some(dialog) =>
      let handleClose = () => onCloseRef.current()
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
        dialog->HtmlDialog.showModal
      } else if !isOpen && isDialogOpen {
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
