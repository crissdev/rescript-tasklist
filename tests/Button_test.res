open Vitest

describe("Button", () => {
  test("renders an accessible button with its label for each variant", async () => {
    let {locator} = await VitestBrowserReact.render(
      <>
        <Button variant=#primary> {React.string("Save")} </Button>
        <Button variant=#secondary> {React.string("Cancel")} </Button>
        <Button variant=#danger> {React.string("Delete")} </Button>
      </>,
    )

    await locator
    ->Locator.getByRole(#button, ~options={name: "Save", exact: true})
    ->Expect.element
    ->Expect.toBeVisible
    await locator
    ->Locator.getByRole(#button, ~options={name: "Cancel", exact: true})
    ->Expect.element
    ->Expect.toBeVisible
    await locator
    ->Locator.getByRole(#button, ~options={name: "Delete", exact: true})
    ->Expect.element
    ->Expect.toBeVisible
  })

  test("is a plain button unless it submits a form", async () => {
    let {locator} = await VitestBrowserReact.render(
      <>
        <Button> {React.string("New task")} </Button>
        <Button type_=#submit> {React.string("Create")} </Button>
      </>,
    )

    await locator
    ->Locator.getByRole(#button, ~options={name: "New task", exact: true})
    ->Expect.element
    ->Expect.toHaveAttribute("type", "button")
    await locator
    ->Locator.getByRole(#button, ~options={name: "Create", exact: true})
    ->Expect.element
    ->Expect.toHaveAttribute("type", "submit")
  })

  test("calls onClick when clicked", async () => {
    let onClick = Mock.fn()
    let {locator} = await VitestBrowserReact.render(
      <Button onClick={onClick->Mock.toFunction}> {React.string("Save")} </Button>,
    )

    await locator->Locator.getByRole(#button, ~options={name: "Save", exact: true})->Locator.click

    onClick->Expect.mock->Expect.toHaveBeenCalledTimes(1)
  })

  test("does not call onClick when disabled", async () => {
    let onClick = Mock.fn()
    let {locator} = await VitestBrowserReact.render(
      <Button onClick={onClick->Mock.toFunction} disabled=true> {React.string("Save")} </Button>,
    )
    let button = locator->Locator.getByRole(#button, ~options={name: "Save", exact: true})

    await button->Expect.element->Expect.toBeDisabled
    await button->Locator.click(~options={force: true})

    onClick->Expect.mock->Expect.toHaveBeenCalledTimes(0)
  })

  test("takes keyboard focus", async () => {
    let {locator} = await VitestBrowserReact.render(<Button> {React.string("Save")} </Button>)

    await UserEvent.keyboard("{Tab}")

    await locator
    ->Locator.getByRole(#button, ~options={name: "Save", exact: true})
    ->Expect.element
    ->Expect.toHaveFocus
  })

  test("sets the test id", async () => {
    let {locator} = await VitestBrowserReact.render(
      <Button dataTestId="save-button"> {React.string("Save")} </Button>,
    )

    await locator
    ->Locator.getByRole(#button, ~options={name: "Save", exact: true})
    ->Expect.element
    ->Expect.toHaveAttribute("data-testid", "save-button")
  })
})
