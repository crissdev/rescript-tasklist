// Minimal bindings for the Vitest APIs used by the test suite.
// Extend them as tests need more of the API.
// - Test API: https://vitest.dev/api/test
// - Browser Mode locators: https://vitest.dev/api/browser/locators
// - Browser Mode assertions: https://vitest.dev/api/browser/assertions

@module("vitest")
external describe: (string, unit => unit) => unit = "describe"

@module("vitest")
external test: (string, unit => promise<unit>) => unit = "test"

module Locator = {
  type t

  // ARIA roles accepted by `getByRole`.
  type role = [#button | #heading | #img | #link]

  type byRoleOptions = {
    name?: string,
    exact?: bool,
    level?: int,
  }

  @send
  external getByRole: (t, role, ~options: byRoleOptions=?) => t = "getByRole"

  @send
  external click: t => promise<unit> = "click"
}

// `expect.element` retries the assertion until it passes or times out.
module Expect = {
  type t

  @module("vitest") @scope("expect")
  external element: Locator.t => t = "element"

  @send
  external toBeVisible: t => promise<unit> = "toBeVisible"

  @send
  external toHaveTextContent: (t, string) => promise<unit> = "toHaveTextContent"

  @send
  external toHaveAttribute: (t, string, string) => promise<unit> = "toHaveAttribute"
}
