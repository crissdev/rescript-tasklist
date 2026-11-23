@react.component
let make: (
  ~label: string,
  ~value: string,
  ~onChange: string => unit,
  ~name: string=?,
  ~required: bool=?,
  ~rows: int=?,
  ~dataTestId: string=?,
) => Jsx.element
