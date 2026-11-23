let baseClassName = "inline-flex items-center justify-center gap-actions rounded-control border px-button-x py-button-y text-button cursor-pointer transition-[background-color] focus-visible:outline-focus focus-visible:outline-offset-focus focus-visible:outline-focus-ring disabled:opacity-disabled disabled:cursor-not-allowed"

let variantClassName = variant =>
  switch variant {
  | #primary => "bg-primary text-ink-inverse border-transparent enabled:hover:bg-primary-hover"
  | #secondary => "bg-surface text-ink border-border-strong enabled:hover:bg-surface-hover"
  | #danger => "bg-danger text-ink-inverse border-transparent enabled:hover:bg-danger-hover"
  }

@react.component
let make = (~variant=#primary, ~type_=#button, ~onClick=?, ~disabled=?, ~dataTestId=?, ~children) =>
  <button
    type_={switch type_ {
    | #button => "button"
    | #submit => "submit"
    }}
    className={`${baseClassName} ${variantClassName(variant)}`}
    ?onClick
    ?disabled
    ?dataTestId
  >
    children
  </button>
