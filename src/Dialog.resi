@react.component
let make: (
  ~isOpen: bool,
  ~onClose: unit => unit,
  ~title: string,
  ~size: [#default | #sm]=?,
  ~children: React.element,
) => Jsx.element
