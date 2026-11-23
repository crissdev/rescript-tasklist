// Minimal bindings for vitest-browser-react.
// https://vitest.dev/api/browser/react

type renderResult = {
  // Locator scoped to the container the component is rendered into.
  locator: Vitest.Locator.t,
  // Re-renders the same container with a new element.
  rerender: React.element => promise<unit>,
}

// Rendered components are removed automatically before the next test.
@module("vitest-browser-react")
external render: React.element => promise<renderResult> = "render"
