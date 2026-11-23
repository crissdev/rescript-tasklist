@react.component
let make = (~label, ~value, ~onChange, ~name=?, ~required=?, ~dataTestId=?) => {
  let id = React.useId()

  <div className=FormField.fieldClassName>
    <label htmlFor=id className=FormField.labelClassName> {React.string(label)} </label>
    <input
      id
      type_="text"
      className=FormField.controlClassName
      value
      onChange={event => onChange(FormField.eventValue(event))}
      ?name
      ?required
      ?dataTestId
    />
  </div>
}
