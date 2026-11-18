open Playwright

describe("App", () => {
  test(
    "loads the page with its title and heading",
    withFixtures(async ({page}) => {
      await page->Page.goto("/")

      await page->Expect.Page.expect->Expect.Page.toHaveTitle("ReScript + Vite + React")
      await page
      ->Page.getByRole(#heading, ~options={name: "Vite + ReScript", level: 1, exact: true})
      ->Expect.Locator.expect
      ->Expect.Locator.toBeVisible
    }),
  )

  test(
    "increments the count on every button click",
    withFixtures(async ({page}) => {
      await page->Page.goto("/")
      let button = page->Page.getByTestId("counter-button")

      await button->Expect.Locator.expect->Expect.Locator.toHaveText("count is 0")

      await button->Locator.click
      await button->Expect.Locator.expect->Expect.Locator.toHaveText("count is 1")

      await button->Locator.click
      await button->Expect.Locator.expect->Expect.Locator.toHaveText("count is 2")
    }),
  )
})
