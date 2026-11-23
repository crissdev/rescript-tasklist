// The app stylesheet. Component tests do not mount `Main`, which is where the page loads it.
%%raw("import '../../src/index.css'")

// The computed focus ring. Focusing with `focusVisible` and reading the outline in this same
// turn does not wait for a transition. The colour is the browser's serialisation of
// `--color-focus-ring`, `oklch(56% 0.18 255)`.

type style

@val external getComputedStyle: Dom.element => style = "getComputedStyle"

@get external outlineStyle: style => string = "outlineStyle"
@get external outlineWidth: style => string = "outlineWidth"
@get external outlineColor: style => string = "outlineColor"
@get external outlineOffset: style => string = "outlineOffset"
@get external transitionProperty: style => string = "transitionProperty"
@get external transitionDuration: style => string = "transitionDuration"

@send external blur: Dom.element => unit = "blur"
@send external focus: (Dom.element, {"focusVisible": bool}) => unit = "focus"

@send external split: (string, string) => array<string> = "split"
@send external trim: string => string = "trim"

type matcher<'a>

@module("vitest") external expect: 'a => matcher<'a> = "expect"

@send external toEqual: (matcher<'a>, 'a) => unit = "toEqual"
@send external toBe: (matcher<bool>, bool) => unit = "toBe"

// `all`, `outline` and `outline-color` would animate the ring. A zero duration does not,
// which is the initial value (`all` / `0s`) on controls that set no transition.
let animatesOutline = (property, duration) =>
  if duration == "0s" {
    false
  } else {
    property
    ->split(",")
    ->Array.some(token => {
      let name = token->trim
      name == "all" || name == "outline" || name == "outline-color"
    })
  }

let expectVisible = locator => {
  let element = locator->Vitest.Locator.element
  element->blur
  element->focus({"focusVisible": true})
  let style = element->getComputedStyle
  style->outlineStyle->expect->toEqual("solid")
  style->outlineWidth->expect->toEqual("2px")
  style->outlineOffset->expect->toEqual("2px")
  style->outlineColor->expect->toEqual("oklch(0.56 0.18 255)")
  animatesOutline(style->transitionProperty, style->transitionDuration)->expect->toBe(false)
}
