open Vitest

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
