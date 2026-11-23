// Minimal bindings for the Vitest APIs used by the test suite.
// Extend them as tests need more of the API.
// - Test API: https://vitest.dev/api/test
// - Browser Mode locators: https://vitest.dev/api/browser/locators
// - Browser Mode assertions: https://vitest.dev/api/browser/assertions
// - Interactivity API: https://vitest.dev/api/browser/interactivity
// - Mock functions: https://vitest.dev/api/mock

@module("vitest")
external describe: (string, unit => unit) => unit = "describe"

@module("vitest")
external test: (string, unit => promise<unit>) => unit = "test"

module Locator = {
  type t

  // ARIA roles accepted by `getByRole`.
  type role = [#button | #dialog | #heading | #img | #link | #textbox]

  type byRoleOptions = {
    name?: string,
    exact?: bool,
    // Also match elements hidden from the accessibility tree, such as a closed dialog.
    includeHidden?: bool,
    level?: int,
  }

  @send
  external getByRole: (t, role, ~options: byRoleOptions=?) => t = "getByRole"

  type byLabelTextOptions = {exact?: bool}

  @send
  external getByLabelText: (t, string, ~options: byLabelTextOptions=?) => t = "getByLabelText"

  type clickOptions = {
    // Skips the actionability checks, so a disabled element can be clicked.
    force?: bool,
  }

  @send
  external click: (t, ~options: clickOptions=?) => promise<unit> = "click"

  // Replaces the value of an input or textarea with the given text.
  @send
  external fill: (t, string) => promise<unit> = "fill"
}

module UserEvent = {
  // Types on the keyboard into the focused element, or the document if none is focused.
  // Supports the user-event keyboard syntax, for example `"{Escape}"`.
  @module("vitest/browser") @scope("userEvent")
  external keyboard: string => promise<unit> = "keyboard"
}

// Mock functions created with `vi.fn`.
module Mock = {
  // A mock that stands in for a function of type `'fn`.
  type t<'fn>

  // Creates a mock without an implementation. It returns `undefined`, so it only stands in for
  // functions that take one argument and return `unit`, such as event handlers.
  @module("vitest") @scope("vi")
  external fn: unit => t<'a => unit> = "fn"

  // The mock as a function, to pass where a callback is expected.
  external toFunction: t<'fn> => 'fn = "%identity"
}

// `expect.element` retries the assertion until it passes or times out.
module Expect = {
  type t

  @module("vitest") @scope("expect")
  external element: Locator.t => t = "element"

  // Negates the assertion that follows, for example `->Expect.not->Expect.toBeVisible`.
  @get
  external not: t => t = "not"

  @send
  external toBeVisible: t => promise<unit> = "toBeVisible"

  @send
  external toBeDisabled: t => promise<unit> = "toBeDisabled"

  @send
  external toBeRequired: t => promise<unit> = "toBeRequired"

  @send
  external toHaveFocus: t => promise<unit> = "toHaveFocus"

  @send
  external toHaveValue: (t, string) => promise<unit> = "toHaveValue"

  @send
  external toHaveTextContent: (t, string) => promise<unit> = "toHaveTextContent"

  @send
  external toHaveAttribute: (t, string, string) => promise<unit> = "toHaveAttribute"

  // Assertions on a mock function. They do not retry, so make them after awaiting the action
  // that calls the mock.
  type mock<'fn>

  @module("vitest")
  external mock: Mock.t<'fn> => mock<'fn> = "expect"

  @send
  external toHaveBeenCalledTimes: (mock<'fn>, int) => unit = "toHaveBeenCalledTimes"

  // Checks the argument of the last call of a mock that takes one argument.
  @send
  external toHaveBeenLastCalledWith: (mock<'a => unit>, 'a) => unit = "toHaveBeenLastCalledWith"
}
