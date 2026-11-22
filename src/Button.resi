@react.component
let make: (
  ~variant: [#primary | #secondary | #danger]=?,
  ~type_: [#button | #submit]=?,
  ~onClick: JsxEvent.Mouse.t => unit=?,
  ~disabled: bool=?,
  ~dataTestId: string=?,
  ~children: React.element,
) => Jsx.element
