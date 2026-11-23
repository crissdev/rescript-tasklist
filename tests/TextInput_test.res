open Vitest

describe("TextInput", () => {
  test("is found by its label and shows the value it is given", async () => {
    let {locator} = await VitestBrowserReact.render(
      <TextInput label="Title" value="Write the spec" onChange={_ => ()} />,
    )

    await locator
    ->Locator.getByLabelText("Title", ~options={exact: true})
    ->Expect.element
    ->Expect.toHaveValue("Write the spec")
  })

  test("calls onChange with the entered text", async () => {
    let onChange = Mock.fn()
    let {locator} = await VitestBrowserReact.render(
      <TextInput label="Title" value="" onChange={onChange->Mock.toFunction} />,
    )

    await locator->Locator.getByLabelText("Title", ~options={exact: true})->Locator.fill("Buy milk")

    onChange->Expect.mock->Expect.toHaveBeenLastCalledWith("Buy milk")
  })

  test("gives each instance its own label", async () => {
    let {locator} = await VitestBrowserReact.render(
      <>
        <TextInput label="Title" value="First" onChange={_ => ()} />
        <TextInput label="Owner" value="Second" onChange={_ => ()} />
      </>,
    )

    await locator
    ->Locator.getByLabelText("Title", ~options={exact: true})
    ->Expect.element
    ->Expect.toHaveValue("First")
    await locator
    ->Locator.getByLabelText("Owner", ~options={exact: true})
    ->Expect.element
    ->Expect.toHaveValue("Second")
  })

  test("shows the focus ring as soon as it is focused", async () => {
    let {locator} = await VitestBrowserReact.render(
      <TextInput label="Title" value="" onChange={_ => ()} />,
    )

    await UserEvent.keyboard("{Tab}")

    locator->Locator.getByLabelText("Title", ~options={exact: true})->FocusRing.expectVisible
  })

  test("takes keyboard focus", async () => {
    let {locator} = await VitestBrowserReact.render(
      <TextInput label="Title" value="" onChange={_ => ()} />,
    )

    await UserEvent.keyboard("{Tab}")

    await locator
    ->Locator.getByLabelText("Title", ~options={exact: true})
    ->Expect.element
    ->Expect.toHaveFocus
  })

  test("sets the name, required and test id attributes", async () => {
    let {locator} = await VitestBrowserReact.render(
      <TextInput
        label="Title"
        value=""
        onChange={_ => ()}
        name="title"
        required=true
        dataTestId="title-input"
      />,
    )
    let input = locator->Locator.getByLabelText("Title", ~options={exact: true})

    await input->Expect.element->Expect.toHaveAttribute("name", "title")
    await input->Expect.element->Expect.toBeRequired
    await input->Expect.element->Expect.toHaveAttribute("data-testid", "title-input")
  })
})
