// Class names shared by the labelled form controls. See "Form fields" in docs/DESIGN.md.

let fieldClassName = "flex flex-col gap-field"

let labelClassName = "text-label text-ink"

let controlClassName = "w-full rounded-control border border-border-strong bg-surface px-input-x py-input-y text-input text-ink focus-visible:outline-focus focus-visible:outline-offset-focus focus-visible:outline-focus-ring"

let eventValue = (event): string => ReactEvent.Form.currentTarget(event)["value"]
