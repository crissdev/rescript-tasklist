open Vitest

describe("App", () => {
  test("renders the page heading", async () => {
    let {locator} = await VitestBrowserReact.render(<App />)

    let heading =
      locator->Locator.getByRole(
        #heading,
        ~options={name: "Vite + ReScript", level: 1, exact: true},
      )

    await heading->Expect.element->Expect.toBeVisible
  })

  test("renders the Vite and ReScript logos", async () => {
    let {locator} = await VitestBrowserReact.render(<App />)

    await locator
    ->Locator.getByRole(#img, ~options={name: "Vite logo", exact: true})
    ->Expect.element
    ->Expect.toBeVisible
    await locator
    ->Locator.getByRole(#img, ~options={name: "ReScript logo", exact: true})
    ->Expect.element
    ->Expect.toBeVisible
  })

  test("increments the count on every button click", async () => {
    let {locator} = await VitestBrowserReact.render(<App />)
    let button = locator->Locator.getByRole(#button)

    await button->Expect.element->Expect.toHaveTextContent("count is 0")

    await button->Locator.click
    await button->Expect.element->Expect.toHaveTextContent("count is 1")

    await button->Locator.click
    await button->Expect.element->Expect.toHaveTextContent("count is 2")
  })

  test("links to the ReScript website in a new tab", async () => {
    let {locator} = await VitestBrowserReact.render(<App />)
    let link = locator->Locator.getByRole(#link, ~options={name: "ReScript.", exact: true})

    await link->Expect.element->Expect.toHaveAttribute("href", "https://rescript-lang.org/")
    await link->Expect.element->Expect.toHaveAttribute("target", "_blank")
  })
})
