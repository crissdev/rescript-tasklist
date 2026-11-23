// The app stylesheet. Component tests do not mount `Main`, which is where the page loads it.
%%raw("import '../../src/index.css'")

// The computed focus ring. Call this in the same turn as the focus change: a transition on
// `outline-color` would still be at the text colour, and only reach the ring colour later.
// The expected colour is the browser's serialisation of `--color-focus-ring`, `oklch(56% 0.18 255)`.

type style

@val external getComputedStyle: Dom.element => style = "getComputedStyle"

@get external outlineStyle: style => string = "outlineStyle"
@get external outlineWidth: style => string = "outlineWidth"
@get external outlineColor: style => string = "outlineColor"
@get external outlineOffset: style => string = "outlineOffset"

type matcher<'a>

@module("vitest") external expect: 'a => matcher<'a> = "expect"

@send external toEqual: (matcher<'a>, 'a) => unit = "toEqual"

let expectVisible = locator => {
  let style = locator->Vitest.Locator.element->getComputedStyle
  style->outlineStyle->expect->toEqual("solid")
  style->outlineWidth->expect->toEqual("2px")
  style->outlineOffset->expect->toEqual("2px")
  style->outlineColor->expect->toEqual("oklch(0.56 0.18 255)")
}
