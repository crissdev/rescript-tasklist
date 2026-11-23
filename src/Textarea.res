@react.component
let make = (~label, ~value, ~onChange, ~name=?, ~required=?, ~rows=4, ~dataTestId=?) => {
  let id = React.useId()

  <div className=FormField.fieldClassName>
    <label htmlFor=id className=FormField.labelClassName> {React.string(label)} </label>
    <textarea
      id
      className={`${FormField.controlClassName} resize-y`}
      value
      onChange={event => onChange(FormField.eventValue(event))}
      rows
      ?name
      ?required
      ?dataTestId
    />
  </div>
}
