open Vitest

type matcher

@module("vitest") external expect: bool => matcher = "expect"

@send external toBe: (matcher, bool) => unit = "toBe"

describe("FocusRing", () => {
  test("pairs each transition property with its own duration", async () => {
    // A zero outline duration stays immediate when another property still animates.
    FocusRing.animatesOutline("background-color, outline-color", "0.15s, 0s")->expect->toBe(false)
    FocusRing.animatesOutline("outline-color, background-color", "0s, 0.15s")->expect->toBe(false)
    // One duration is repeated for every property.
    FocusRing.animatesOutline("background-color, outline-color", "0.15s")->expect->toBe(true)
    // A longer duration list ignores the extra values.
    FocusRing.animatesOutline("outline-color", "0s, 0.15s")->expect->toBe(false)
    FocusRing.animatesOutline("all", "0s")->expect->toBe(false)
    FocusRing.animatesOutline("outline-color", "0.15s")->expect->toBe(true)
    FocusRing.animatesOutline("background-color", "0.15s")->expect->toBe(false)
    // The last entry for the same property wins.
    FocusRing.animatesOutline("outline-color, outline-color", "0.15s, 0s")->expect->toBe(false)
    FocusRing.animatesOutline("outline-color, outline-color", "0s, 0.15s")->expect->toBe(true)
  })
})
