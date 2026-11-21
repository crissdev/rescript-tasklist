// Exercises the bindings at runtime, because a wrong JavaScript name still compiles.
open Vitest

module Form = {
  @react.component
  let make = (~onChange) =>
    <form>
      <label htmlFor="name"> {React.string("Name")} </label>
      <input id="name" onChange />
      <label htmlFor="notes"> {React.string("Notes")} </label>
      <textarea id="notes" />
    </form>
}

module DialogFixture = {
  @send external showModal: Dom.element => unit = "showModal"

  @react.component
  let make = (~onOpen) => {
    let dialogRef = React.useRef(Nullable.null)

    let openDialog = event => {
      onOpen(event)
      dialogRef.current->Nullable.forEach(showModal)
    }

    <>
      <button onClick=openDialog> {React.string("Open")} </button>
      <dialog ref={ReactDOM.Ref.domRef(dialogRef)} ariaLabel="Details">
        <input ariaLabel="Title" autoFocus=true />
      </dialog>
    </>
  }
}

describe("Vitest bindings", () => {
  test("fill types into the input found by its label and calls its change handler", async () => {
    let onChange = Mock.fn()
    let {locator} = await VitestBrowserReact.render(<Form onChange={onChange->Mock.toFunction} />)
    let name = locator->Locator.getByLabelText("Name", ~options={exact: true})

    await name->Locator.fill("Groceries")

    await name->Expect.element->Expect.toHaveValue("Groceries")
    onChange->Expect.mock->Expect.toHaveBeenCalledTimes(1)
  })

  test("a textarea has the textbox role", async () => {
    let {locator} = await VitestBrowserReact.render(<Form onChange={_ => ()} />)
    let notes = locator->Locator.getByRole(#textbox, ~options={name: "Notes", exact: true})

    await notes->Locator.fill("Milk")

    await notes->Expect.element->Expect.toHaveValue("Milk")
  })

  test("a modal dialog opens on click, takes focus and closes on Escape", async () => {
    let onOpen = Mock.fn()
    let {locator} = await VitestBrowserReact.render(
      <DialogFixture onOpen={onOpen->Mock.toFunction} />,
    )
    let dialog =
      locator->Locator.getByRole(
        #dialog,
        ~options={name: "Details", exact: true, includeHidden: true},
      )

    await dialog->Expect.element->Expect.not->Expect.toBeVisible
    onOpen->Expect.mock->Expect.toHaveBeenCalledTimes(0)

    await locator->Locator.getByRole(#button, ~options={name: "Open", exact: true})->Locator.click

    onOpen->Expect.mock->Expect.toHaveBeenCalledTimes(1)
    await dialog->Expect.element->Expect.toBeVisible
    await locator
    ->Locator.getByLabelText("Title", ~options={exact: true})
    ->Expect.element
    ->Expect.toHaveFocus

    await UserEvent.keyboard("{Escape}")

    await dialog->Expect.element->Expect.not->Expect.toBeVisible
  })
})
