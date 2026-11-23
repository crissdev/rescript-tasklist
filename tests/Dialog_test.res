open Vitest

@send external querySelector: (Dom.element, string) => nullable<Dom.element> = "querySelector"

module Reopen = {
  @react.component
  let make = (~onClose) => {
    let rootRef = React.useRef(Nullable.null)
    let (isOpen, setIsOpen) = React.useState(() => true)
    let (closeEventSeen, setCloseEventSeen) = React.useState(() => false)
    // Closes and opens again in the same commit cycle, before the queued close event.
    React.useLayoutEffect1(() => {
      if !isOpen {
        setIsOpen(_ => true)
      }
      None
    }, [isOpen])

    // Records the native close event on this component's dialog, independent of `onClose`.
    React.useLayoutEffect0(() => {
      switch rootRef.current->Nullable.toOption {
      | None => None
      | Some(root) =>
        switch root->querySelector("dialog")->Nullable.toOption {
        | None => None
        | Some(dialog) =>
          let handleClose = () => setCloseEventSeen(_ => true)
          dialog->HtmlDialog.addCloseListener(handleClose)
          Some(() => dialog->HtmlDialog.removeCloseListener(handleClose))
        }
      }
    })

    <div ref={ReactDOM.Ref.domRef(rootRef)}>
      <Dialog isOpen onClose title="Edit task">
        <button type_="button" onClick={_ => setIsOpen(_ => false)}>
          {React.string("Cycle")}
        </button>
        {closeEventSeen ? <h2> {React.string("Close event")} </h2> : React.null}
      </Dialog>
    </div>
  }
}

describe("Dialog", () => {
  test("is not visible while closed", async () => {
    let {locator} = await VitestBrowserReact.render(
      <Dialog isOpen=false title="Edit task" onClose={_ => ()}> {React.string("Details")} </Dialog>,
    )

    await locator
    ->Locator.getByRole(#dialog, ~options={name: "Edit task", exact: true, includeHidden: true})
    ->Expect.element
    ->Expect.not
    ->Expect.toBeVisible
  })

  test("opens and is found by its title when isOpen becomes true", async () => {
    let {locator, rerender} = await VitestBrowserReact.render(
      <Dialog isOpen=false title="Edit task" onClose={_ => ()}> {React.string("Details")} </Dialog>,
    )

    await rerender(
      <Dialog isOpen=true title="Edit task" onClose={_ => ()}> {React.string("Details")} </Dialog>,
    )

    await locator
    ->Locator.getByRole(#dialog, ~options={name: "Edit task", exact: true})
    ->Expect.element
    ->Expect.toBeVisible
  })

  test("closes when isOpen becomes false", async () => {
    let {locator, rerender} = await VitestBrowserReact.render(
      <Dialog isOpen=true title="Edit task" onClose={_ => ()}> {React.string("Details")} </Dialog>,
    )

    await locator
    ->Locator.getByRole(#dialog, ~options={name: "Edit task", exact: true})
    ->Expect.element
    ->Expect.toBeVisible

    await rerender(
      <Dialog isOpen=false title="Edit task" onClose={_ => ()}> {React.string("Details")} </Dialog>,
    )

    await locator
    ->Locator.getByRole(#dialog, ~options={name: "Edit task", exact: true, includeHidden: true})
    ->Expect.element
    ->Expect.not
    ->Expect.toBeVisible
  })

  test("pressing Escape calls onClose and closes it", async () => {
    let onClose = Mock.fn()
    let {locator} = await VitestBrowserReact.render(
      <Dialog isOpen=true title="Edit task" onClose={onClose->Mock.toFunction}>
        {React.string("Details")}
      </Dialog>,
    )

    await locator
    ->Locator.getByRole(#dialog, ~options={name: "Edit task", exact: true})
    ->Expect.element
    ->Expect.toBeVisible

    await UserEvent.keyboard("{Escape}")

    onClose->Expect.mock->Expect.toHaveBeenCalledTimes(1)

    await locator
    ->Locator.getByRole(#dialog, ~options={name: "Edit task", exact: true, includeHidden: true})
    ->Expect.element
    ->Expect.not
    ->Expect.toBeVisible
  })

  test("ignores a close event from an earlier opening", async () => {
    let onClose = Mock.fn()
    let {locator} = await VitestBrowserReact.render(<Reopen onClose={onClose->Mock.toFunction} />)

    await locator->Locator.getByRole(#button, ~options={name: "Cycle", exact: true})->Locator.click
    await locator
    ->Locator.getByRole(#heading, ~options={name: "Close event", exact: true})
    ->Expect.element
    ->Expect.toBeVisible

    onClose->Expect.mock->Expect.toHaveBeenCalledTimes(0)
    await locator
    ->Locator.getByRole(#dialog, ~options={name: "Edit task", exact: true})
    ->Expect.element
    ->Expect.toBeVisible
  })

  test("moves keyboard focus to a control inside the dialog", async () => {
    let {locator} = await VitestBrowserReact.render(
      <Dialog isOpen=true title="Edit task" onClose={_ => ()}>
        <Button> {React.string("Cancel")} </Button>
      </Dialog>,
    )

    await locator
    ->Locator.getByRole(#button, ~options={name: "Cancel", exact: true})
    ->Expect.element
    ->Expect.toHaveFocus
  })
})
