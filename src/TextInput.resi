@react.component
let make: (
  ~label: string,
  ~value: string,
  ~onChange: string => unit,
  ~name: string=?,
  ~required: bool=?,
  ~dataTestId: string=?,
) => Jsx.element
