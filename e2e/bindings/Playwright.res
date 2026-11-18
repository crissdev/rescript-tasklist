// Minimal bindings for the Playwright Test APIs used by the E2E suite.
// Extend them as specs need more of the API.
// - Test API: https://playwright.dev/docs/api/class-test
// - Page: https://playwright.dev/docs/api/class-page
// - Locators: https://playwright.dev/docs/api/class-locator
// - Assertions: https://playwright.dev/docs/test-assertions

module Locator = {
  type t

  @send
  external click: t => promise<unit> = "click"
}

module Page = {
  type t

  // ARIA roles accepted by `getByRole`.
  type role = [#heading]

  type byRoleOptions = {
    name?: string,
    exact?: bool,
    level?: int,
  }

  // Resolves with the main resource response, which the specs do not use.
  @send
  external goto: (t, string) => promise<unit> = "goto"

  @send
  external getByRole: (t, role, ~options: byRoleOptions=?) => Locator.t = "getByRole"

  @send
  external getByTestId: (t, string) => Locator.t = "getByTestId"
}

// Built-in fixtures passed to each test.
type fixtures = {page: Page.t}

@module("@playwright/test") @scope("test")
external describe: (string, unit => unit) => unit = "describe"

// A test callback that Playwright can read its fixtures from. Create one with `withFixtures`.
type body

// Playwright reads the fixtures a test needs from the source of its callback, whose first parameter
// must be a destructuring pattern. ReScript compiles record patterns to property access instead, so the
// callback is wrapped in a function that destructures every field of `fixtures`.
let withFixtures: (fixtures => promise<unit>) => body = %raw(`
  fn => ({ page }) => fn({ page })
`)

// Playwright records the immediate caller as the test location, so specs must call this external
// directly rather than through a ReScript wrapper.
@module("@playwright/test")
external test: (string, body) => unit = "test"

// `expect` assertions retry until they pass or time out.
module Expect = {
  module Locator = {
    type t

    @module("@playwright/test")
    external expect: Locator.t => t = "expect"

    @send
    external toBeVisible: t => promise<unit> = "toBeVisible"

    @send
    external toHaveText: (t, string) => promise<unit> = "toHaveText"
  }

  module Page = {
    type t

    @module("@playwright/test")
    external expect: Page.t => t = "expect"

    @send
    external toHaveTitle: (t, string) => promise<unit> = "toHaveTitle"
  }
}
