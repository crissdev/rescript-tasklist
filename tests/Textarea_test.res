open Vitest

describe("Textarea", () => {
  test("is a textbox found by its label and shows the value it is given", async () => {
    let {locator} = await VitestBrowserReact.render(
      <Textarea label="Description" value="Milk and eggs" onChange={_ => ()} />,
    )

    await locator
    ->Locator.getByRole(#textbox, ~options={name: "Description", exact: true})
    ->Expect.element
    ->Expect.toHaveValue("Milk and eggs")
  })

  test("calls onChange with the entered text", async () => {
    let onChange = Mock.fn()
    let {locator} = await VitestBrowserReact.render(
      <Textarea label="Description" value="" onChange={onChange->Mock.toFunction} />,
    )

    await locator
    ->Locator.getByLabelText("Description", ~options={exact: true})
    ->Locator.fill("Two lines\nof text")

    onChange->Expect.mock->Expect.toHaveBeenLastCalledWith("Two lines\nof text")
  })

  test("shows 4 rows unless told otherwise", async () => {
    let {locator} = await VitestBrowserReact.render(
      <>
        <Textarea label="Description" value="" onChange={_ => ()} />
        <Textarea label="Notes" value="" onChange={_ => ()} rows=2 />
      </>,
    )

    await locator
    ->Locator.getByLabelText("Description", ~options={exact: true})
    ->Expect.element
    ->Expect.toHaveAttribute("rows", "4")
    await locator
    ->Locator.getByLabelText("Notes", ~options={exact: true})
    ->Expect.element
    ->Expect.toHaveAttribute("rows", "2")
  })

  test("shows the focus ring as soon as it is focused", async () => {
    let {locator} = await VitestBrowserReact.render(
      <Textarea label="Description" value="" onChange={_ => ()} />,
    )

    await UserEvent.keyboard("{Tab}")

    locator->Locator.getByLabelText("Description", ~options={exact: true})->FocusRing.expectVisible
  })

  test("takes keyboard focus", async () => {
    let {locator} = await VitestBrowserReact.render(
      <Textarea label="Description" value="" onChange={_ => ()} />,
    )

    await UserEvent.keyboard("{Tab}")

    await locator
    ->Locator.getByLabelText("Description", ~options={exact: true})
    ->Expect.element
    ->Expect.toHaveFocus
  })

  test("sets the name, required and test id attributes", async () => {
    let {locator} = await VitestBrowserReact.render(
      <Textarea
        label="Description"
        value=""
        onChange={_ => ()}
        name="description"
        required=true
        dataTestId="description-input"
      />,
    )
    let textarea = locator->Locator.getByLabelText("Description", ~options={exact: true})

    await textarea->Expect.element->Expect.toHaveAttribute("name", "description")
    await textarea->Expect.element->Expect.toBeRequired
    await textarea->Expect.element->Expect.toHaveAttribute("data-testid", "description-input")
  })
})
