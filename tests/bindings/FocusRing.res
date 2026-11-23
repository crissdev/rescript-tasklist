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

// `all`, `outline` and `outline-color` animate the ring when their duration is not zero.
// Durations pair with properties by index, and the shorter list repeats, as CSS does.
// The initial value on a control that sets no transition is `all` / `0s`.
let animatesOutline = (property, duration) => {
  let names = property->split(",")
  let durations = duration->split(",")
  let count = Array.length(durations)
  // The shorter list repeats. The last entry that targets the outline wins, as CSS does.
  let index = ref(0)
  let winning = ref(None)
  for i in 0 to Array.length(names) - 1 {
    let name = switch names->Array.get(i) {
    | Some(token) => token->trim
    | None => ""
    }
    let step = if count == 0 {
      "0s"
    } else {
      let current = index.contents
      index := if current + 1 == count {
          0
        } else {
          current + 1
        }
      switch durations->Array.get(current) {
      | Some(token) => token->trim
      | None => "0s"
      }
    }
    if name == "all" || name == "outline" || name == "outline-color" {
      winning := Some(step)
    }
  }
  switch winning.contents {
  | Some(step) => step != "0s"
  | None => false
  }
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
