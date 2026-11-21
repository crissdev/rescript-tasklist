# Task List — Design spec

This spec describes how the Task List looks and behaves on screen. It is derived from
[`APP_DESCRIPTION.md`](APP_DESCRIPTION.md) and is the source for the Tailwind theme tokens in `src/index.css` and the
shared components (`Button`, `TextInput`, `Textarea`, `Dialog`).

Every colour, spacing, radius, shadow and typography value has a token name. Each token is written as the CSS variable
to add to `@theme`, followed by the Tailwind utility it produces. [All tokens](#all-tokens) lists them as one `@theme`
block. Components use these tokens only: no hard-coded values and no default Tailwind palette colours (`stone-*`,
`blue-*`, …).

## Contents

- [Principles](#principles)
- [Token naming](#token-naming)
- [Colours](#colours)
- [Typography](#typography)
- [Spacing](#spacing)
- [Sizes](#sizes)
- [Radius](#radius)
- [Shadows](#shadows)
- [Other tokens](#other-tokens)
- [Board layout](#board-layout)
- [Columns](#columns)
- [Cards](#cards)
- [Card style switch](#card-style-switch)
- [Buttons](#buttons)
- [Form fields](#form-fields)
- [Dialogs](#dialogs)
- [States](#states)
- [Not designed](#not-designed)
- [All tokens](#all-tokens)

## Principles

- **Quiet board, readable cards.** Neutral surfaces with a slight cool tint. Colour is reserved for actions (primary,
  danger), status accents, keyboard focus and the drop target.
- **As little information as possible.** A card shows its title, plus the start of its description in the relaxed
  style. Dates, ids and the status itself are not shown on the card; the column already says the status.
- **Every interactive element has a visible keyboard focus ring** (see [Focus ring](#focus-ring)).
- **Text meets WCAG 2.2 AA contrast** (4.5:1 for text, 3:1 for input borders and the focus ring). Ratios are listed
  under [Contrast](#contrast).
- **Light theme only.** One set of tokens; there is no dark mode.

## Token naming

Tokens use the Tailwind v4 theme namespaces, so adding them to `@theme` creates the matching utilities:

| Namespace           | Creates                                     | Example                                  |
|---------------------|---------------------------------------------|------------------------------------------|
| `--color-*`         | `bg-*`, `text-*`, `border-*`, `outline-*`   | `--color-surface` → `bg-surface`         |
| `--font-*`          | `font-*` (family)                           | `--font-sans` → `font-sans`              |
| `--text-*`          | `text-*` (size, line height and weight)     | `--text-card-title` → `text-card-title`  |
| `--spacing-*`       | `p-*`, `m-*`, `gap-*`, `size-*`             | `--spacing-card-x` → `px-card-x`         |
| `--container-*`     | `w-*`, `min-w-*`, `max-w-*`                 | `--container-board` → `max-w-board`      |
| `--radius-*`        | `rounded-*`                                 | `--radius-card` → `rounded-card`         |
| `--shadow-*`        | `shadow-*`                                  | `--shadow-card` → `shadow-card`          |
| `--opacity-*`       | `opacity-*`                                 | `--opacity-dragged` → `opacity-dragged`  |
| `--line-clamp-*`    | `line-clamp-*`                              | `--line-clamp-card-title`                |
| `--outline-width-*` | `outline-*` (width)                         | `--outline-width-focus` → `outline-focus`|
| `--outline-offset-*`| `outline-offset-*`                          | `--outline-offset-focus`                 |

Names are unique across namespaces that share a utility prefix. Otherwise Tailwind resolves the utility from the wrong
namespace:

- `--spacing-*` and `--container-*` both feed `w-*`, `min-w-*` and `max-w-*`, and spacing wins. This is why the dialog
  padding is `--spacing-dialog-inset` and not `--spacing-dialog`, which would turn `max-w-dialog` into `1.5rem`.
- `--color-*` and `--text-*` both feed `text-*`; `--color-*` and `--outline-width-*` both feed `outline-*`.

Plain Tailwind keywords that carry no design value are used as they are: `border` (1px), `border-dashed`,
`outline-dashed`, `rounded-full`, `sr-only` and `transition` (Tailwind's default 150 ms,
`--default-transition-duration`).

## Colours

All colours are `oklch()`. Neutrals share hue 260 with low chroma.

### Surfaces and borders

| Token                    | Value                        | Utility             | Used for                                          |
|--------------------------|------------------------------|---------------------|---------------------------------------------------|
| `--color-canvas`         | `oklch(98.5% 0.003 260)`     | `bg-canvas`         | Page background behind the board                  |
| `--color-surface`        | `oklch(100% 0 0)`            | `bg-surface`        | Cards, dialogs, inputs, secondary buttons         |
| `--color-surface-muted`  | `oklch(96.5% 0.006 260)`     | `bg-surface-muted`  | Column background, style switch track             |
| `--color-surface-hover`  | `oklch(95% 0.008 260)`       | `bg-surface-hover`  | Secondary button hover                            |
| `--color-border`         | `oklch(91% 0.008 260)`       | `border-border`     | Card and style switch borders (decorative)        |
| `--color-border-strong`  | `oklch(64% 0.015 260)`       | `border-border-strong` | Input and secondary button borders, empty column outline |
| `--color-backdrop`       | `oklch(24% 0.02 260 / 45%)`  | `backdrop:bg-backdrop` | Modal dialog backdrop                          |

### Text

| Token                 | Value                    | Utility           | Used for                                              |
|-----------------------|--------------------------|-------------------|-------------------------------------------------------|
| `--color-ink`         | `oklch(24% 0.02 260)`    | `text-ink`        | Board name, headings, card titles, labels, body text  |
| `--color-ink-muted`   | `oklch(48% 0.02 260)`    | `text-ink-muted`  | Card description, empty column text, unselected switch option |
| `--color-ink-inverse` | `oklch(100% 0 0)`        | `text-ink-inverse`| Text on primary and danger buttons                    |

### Actions

| Token                   | Value                   | Utility                  | Used for                                       |
|-------------------------|-------------------------|--------------------------|------------------------------------------------|
| `--color-primary`       | `oklch(51% 0.23 277)`   | `bg-primary`             | Primary button                                 |
| `--color-primary-hover` | `oklch(45% 0.21 277)`   | `enabled:hover:bg-primary-hover` | Primary button hover                   |
| `--color-danger`        | `oklch(55% 0.2 27)`     | `bg-danger`, `text-danger`, `border-danger` | Danger button, field error text and border |
| `--color-danger-hover`  | `oklch(48% 0.18 27)`    | `enabled:hover:bg-danger-hover`  | Danger button hover                    |

### Status accents

One accent per status, shown as a dot next to the column heading. The column name is always written out, so the
colour is never the only way to tell the columns apart.

| Token                        | Value                  | Utility                   | Status      |
|------------------------------|------------------------|---------------------------|-------------|
| `--color-status-todo`        | `oklch(60% 0.03 260)`  | `bg-status-todo`          | To Do       |
| `--color-status-in-progress` | `oklch(62% 0.13 70)`   | `bg-status-in-progress`   | In Progress |
| `--color-status-done`        | `oklch(60% 0.14 150)`  | `bg-status-done`          | Done        |

### Focus and drag-and-drop

| Token                  | Value                    | Utility                  | Used for                                    |
|------------------------|--------------------------|--------------------------|---------------------------------------------|
| `--color-focus-ring`   | `oklch(56% 0.18 255)`    | `outline-focus-ring`     | Keyboard focus ring on every control        |
| `--color-drop-surface` | `oklch(95.5% 0.02 277)`  | `bg-drop-surface`        | Background of the column under a dragged card |
| `--color-drop-accent`  | `oklch(55% 0.2 277)`     | `outline-drop-accent`    | Dashed outline of that column               |

### Contrast

| Foreground     | Background      | Ratio   | Requirement            |
|----------------|-----------------|---------|------------------------|
| `ink`          | `surface`       | 16.4:1  | Text, 4.5:1            |
| `ink`          | `surface-muted` | 14.9:1  | Text, 4.5:1            |
| `ink-muted`    | `surface`       | 6.5:1   | Text, 4.5:1            |
| `ink-muted`    | `surface-muted` | 5.9:1   | Text, 4.5:1            |
| `ink-muted`    | `drop-surface`  | 5.7:1   | Text, 4.5:1            |
| `ink-inverse`  | `primary`       | 6.3:1   | Text, 4.5:1            |
| `ink-inverse`  | `danger`        | 5.4:1   | Text, 4.5:1            |
| `danger`       | `surface`       | 5.4:1   | Text, 4.5:1            |
| `border-strong`| `surface`       | 3.4:1   | Input border, 3:1      |
| `focus-ring`   | `surface`       | 4.7:1   | Focus indicator, 3:1   |
| `focus-ring`   | `canvas`        | 4.5:1   | Focus indicator, 3:1   |
| `focus-ring`   | `surface-muted` | 4.3:1   | Focus indicator, 3:1   |
| `drop-accent`  | `drop-surface`  | 4.5:1   | Drop outline, 3:1      |

The focus ring sits outside the control (see [Focus ring](#focus-ring)), so it is measured against the background
around the control, not against the button colour.

## Typography

One font family: Inter when it is installed, otherwise the system UI font. No web font is downloaded.

| Token         | Value                                                    | Utility     |
|---------------|----------------------------------------------------------|-------------|
| `--font-sans` | `Inter, system-ui, Avenir, Helvetica, Arial, sans-serif` | `font-sans` |

`--font-sans` is Tailwind's default family, so the whole page uses it without adding `font-sans` anywhere. The starter
`--font-inter` token stays until the board replaces the starter page.

Each text token sets size, line height and weight together, through Tailwind's `--text-*--line-height` and
`--text-*--font-weight` sub-tokens. One utility, such as `text-card-title`, gives the complete style.

| Token                     | Size                | Line height       | Weight | Used for                              |
|---------------------------|---------------------|-------------------|--------|---------------------------------------|
| `--text-board-title`      | `1.5rem` (24px)     | `2rem` (32px)     | 600    | Board name (`h1`)                     |
| `--text-dialog-title`     | `1.125rem` (18px)   | `1.75rem` (28px)  | 600    | Dialog title (`h2`)                   |
| `--text-column-title`     | `0.875rem` (14px)   | `1.25rem` (20px)  | 600    | Column heading (`h2`)                 |
| `--text-card-title`       | `0.875rem` (14px)   | `1.25rem` (20px)  | 500    | Card title                            |
| `--text-card-description` | `0.8125rem` (13px)  | `1.125rem` (18px) | 400    | Card description (relaxed style)      |
| `--text-body`             | `0.875rem` (14px)   | `1.25rem` (20px)  | 400    | Dialog body text                      |
| `--text-label`            | `0.875rem` (14px)   | `1.25rem` (20px)  | 500    | Field labels, style switch options    |
| `--text-input`            | `1rem` (16px)       | `1.5rem` (24px)   | 400    | Text typed into inputs and textareas  |
| `--text-button`           | `0.875rem` (14px)   | `1.25rem` (20px)  | 500    | Button labels                         |
| `--text-caption`          | `0.8125rem` (13px)  | `1.125rem` (18px) | 400    | Empty column text, field error        |

Input text is 16px so mobile browsers do not zoom in when a field gets focus. Text is in sentence case; nothing is
upper-cased.

## Spacing

| Token                      | Value      | Utility               | Used for                                         |
|----------------------------|------------|-----------------------|--------------------------------------------------|
| `--spacing-page`           | `1.5rem`   | `p-page`              | Padding around the page                          |
| `--spacing-section`        | `1.5rem`   | `gap-section`         | Between the header and the columns               |
| `--spacing-toolbar`        | `0.75rem`  | `gap-toolbar`         | Between header items (board name, switch, button)|
| `--spacing-columns`        | `1rem`     | `gap-columns`         | Between columns                                  |
| `--spacing-column-inset`   | `0.75rem`  | `p-column-inset`      | Padding inside a column                          |
| `--spacing-column-stack`   | `0.75rem`  | `gap-column-stack`    | Between the column heading and its cards         |
| `--spacing-heading`        | `0.5rem`   | `gap-heading`         | Between the status dot and the column name       |
| `--spacing-status-dot`     | `0.5rem`   | `size-status-dot`     | Size of the status dot                           |
| `--spacing-cards`          | `0.5rem`   | `gap-cards`           | Between cards in a column                        |
| `--spacing-card-x`         | `0.75rem`  | `px-card-x`           | Horizontal card padding (both styles)            |
| `--spacing-card-y`         | `0.5rem`   | `py-card-y`           | Vertical card padding, normal style              |
| `--spacing-card-y-relaxed` | `0.75rem`  | `py-card-y-relaxed`   | Vertical card padding, relaxed style             |
| `--spacing-card-stack`     | `0.25rem`  | `gap-card-stack`      | Between card title and description (relaxed)     |
| `--spacing-empty-y`        | `1.5rem`   | `py-empty-y`          | Vertical padding of the empty column message     |
| `--spacing-button-x`       | `1rem`     | `px-button-x`         | Horizontal button padding                        |
| `--spacing-button-y`       | `0.5rem`   | `py-button-y`         | Vertical button padding                          |
| `--spacing-input-x`        | `0.75rem`  | `px-input-x`          | Horizontal input and textarea padding            |
| `--spacing-input-y`        | `0.5rem`   | `py-input-y`          | Vertical input and textarea padding              |
| `--spacing-field`          | `0.375rem` | `gap-field`           | Between a label, its control and its error       |
| `--spacing-fields`         | `1rem`     | `gap-fields`          | Between fields in a form                         |
| `--spacing-dialog-inset`   | `1.5rem`   | `p-dialog-inset`      | Padding inside a dialog                          |
| `--spacing-dialog-stack`   | `1.25rem`  | `gap-dialog-stack`    | Between dialog title, content and actions        |
| `--spacing-actions`        | `0.5rem`   | `gap-actions`         | Between buttons in a row                         |
| `--spacing-segment-inset`  | `0.125rem` | `p-segment-inset`     | Padding of the style switch track                |
| `--spacing-segment-x`      | `0.75rem`  | `px-segment-x`        | Horizontal padding of a style switch option      |
| `--spacing-segment-y`      | `0.375rem` | `py-segment-y`        | Vertical padding of a style switch option        |

Buttons and the style switch are both 38px tall, so they line up in the header: 1px border + 0.5rem padding + 20px line
height + 0.5rem padding + 1px border for a button; 1px border + 0.125rem inset + 0.375rem padding + 20px line height +
0.375rem padding + 0.125rem inset + 1px border for the switch.

## Sizes

| Token                 | Value    | Utility          | Used for                                         |
|-----------------------|----------|------------------|--------------------------------------------------|
| `--container-board`   | `80rem`  | `max-w-board`    | Maximum width of the header and the columns      |
| `--container-column`  | `16rem`  | `min-w-column`   | Minimum width of a column                        |
| `--container-dialog`  | `32rem`  | `max-w-dialog`   | Create and edit dialogs                          |
| `--container-dialog-sm` | `26rem`| `max-w-dialog-sm`| Delete confirmation                              |

## Radius

| Token              | Value      | Utility           | Used for                                         |
|--------------------|------------|-------------------|--------------------------------------------------|
| `--radius-control` | `0.375rem` | `rounded-control` | Buttons, inputs, textareas, selects, style switch track |
| `--radius-segment` | `0.25rem`  | `rounded-segment` | Style switch option (track radius minus its inset) |
| `--radius-card`    | `0.5rem`   | `rounded-card`    | Cards, empty column message                      |
| `--radius-column`  | `0.75rem`  | `rounded-column`  | Columns                                          |
| `--radius-dialog`  | `0.75rem`  | `rounded-dialog`  | Dialogs                                          |

The status dot is a circle (`rounded-full`).

## Shadows

Shadows use the ink colour at low opacity, so they match the cool neutrals.

| Token                 | Value                                          | Utility             | Used for                       |
|-----------------------|------------------------------------------------|---------------------|--------------------------------|
| `--shadow-card`       | `0 1px 2px 0 oklch(24% 0.02 260 / 8%)`         | `shadow-card`       | Card at rest                   |
| `--shadow-card-hover` | `0 2px 6px 0 oklch(24% 0.02 260 / 12%)`        | `shadow-card-hover` | Card on hover                  |
| `--shadow-card-drag`  | `0 8px 20px -4px oklch(24% 0.02 260 / 20%)`    | `shadow-card-drag`  | Drag preview, when it can be styled |
| `--shadow-segment`    | `0 1px 2px 0 oklch(24% 0.02 260 / 10%)`        | `shadow-segment`    | Selected style switch option   |
| `--shadow-dialog`     | `0 20px 48px -12px oklch(24% 0.02 260 / 30%)`  | `shadow-dialog`     | Dialogs                        |

Buttons, inputs and columns have no shadow.

## Other tokens

| Token                            | Value  | Utility                         | Used for                                  |
|----------------------------------|--------|---------------------------------|-------------------------------------------|
| `--opacity-dragged`              | `50%`  | `opacity-dragged`               | The card being dragged, left in its column |
| `--opacity-disabled`             | `50%`  | `disabled:opacity-disabled`     | Disabled buttons                          |
| `--line-clamp-card-title`        | `2`    | `line-clamp-card-title`         | Card title, both styles                   |
| `--line-clamp-card-description`  | `3`    | `line-clamp-card-description`   | Card description, relaxed style           |
| `--outline-width-focus`          | `2px`  | `outline-focus`                 | Focus ring width                          |
| `--outline-offset-focus`         | `2px`  | `outline-offset-focus`          | Gap between control and focus ring        |
| `--outline-width-drop`           | `2px`  | `outline-drop`                  | Drop target outline width                 |
| `--outline-offset-drop`          | `-2px` | `outline-offset-drop`           | Draws the drop outline inside the column  |

## Board layout

The page shows the default board: a header with the board name and the board actions, and the three columns below it.

```
┌─ page (bg-canvas, p-page) ────────────────────────────────────────────────────────────────┐
│ ┌─ header (max-w-board) ────────────────────────────────────────────────────────────────┐ │
│ │ Board name                                         [ Normal | Relaxed ]  [ New task ] │ │
│ └───────────────────────────────────────────────────────────────────────────────────────┘ │
│                                         gap-section                                       │
│ ┌─ To Do ───────────────────┐ ┌─ In Progress ─────────────┐ ┌─ Done ────────────────────┐ │
│ │ ● To Do                   │ │ ● In Progress             │ │ ● Done                    │ │
│ │ ┌───────────────────────┐ │ │ ┌───────────────────────┐ │ │ ┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐ │ │
│ │ │ Write the design spec │ │ │ │ Add theme tokens      │ │ │      No tasks             │ │
│ │ └───────────────────────┘ │ │ └───────────────────────┘ │ │ └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘ │ │
│ │ ┌───────────────────────┐ │ │                           │ │                           │ │
│ │ │ Rework Button         │ │ │                           │ │                           │ │
│ │ └───────────────────────┘ │ │                           │ │                           │ │
│ └───────────────────────────┘ └───────────────────────────┘ └───────────────────────────┘ │
└───────────────────────────────────────────────────────────────────────────────────────────┘
```

### Page

- `<main>` fills the viewport: `flex min-h-screen flex-col bg-canvas p-page text-ink`. The starter page centres
  `#root` in `index.html`; the board layout removes that centring.
- Inside it, one column of content, centred and at most `max-w-board` wide:
  `mx-auto flex w-full max-w-board flex-1 flex-col gap-section`. The columns area takes the remaining height
  (`flex-1`), so the columns, and their drop areas, reach the bottom of the viewport.

### Header

- `<header>`: `flex flex-wrap items-center justify-between gap-toolbar`.
- **Board name** on the left: the page's only `h1`, `text-board-title text-ink`. Long names wrap
  (`wrap-anywhere`); they are never truncated.
- **Board actions** on the right, in this order: the [card style switch](#card-style-switch), then the **New task**
  primary button, so the main action is last. Group them with `flex items-center gap-toolbar`.
- On narrow screens the actions wrap below the board name and stay left-aligned.

### Columns area

- Exactly three columns, left to right: **To Do**, **In Progress**, **Done**. They are always shown, even when empty,
  and cannot be added, removed or reordered.
- `flex flex-1 items-stretch gap-columns overflow-x-auto`. Each column is `flex-1 min-w-column`: the three columns
  share the width equally, from `16rem` up to about `26rem` each at `max-w-board`.
- When the viewport is narrower than three minimum-width columns (`3 × 16rem + 2 × 1rem = 50rem` plus page padding),
  the columns keep their minimum width and the columns area scrolls horizontally. Columns are never stacked.
- Because it can scroll, the columns area is a keyboard-reachable region: `role="region"` named after the board
  (`aria-labelledby` pointing at the `h1`), `tabindex="0"` and the [focus ring](#focus-ring). Keyboard users can then
  scroll it even when no column has a card.

## Columns

Each column is a `<section>` named by its heading (`aria-labelledby`).

- Container: `flex flex-col gap-column-stack rounded-column bg-surface-muted p-column-inset`.
- **Heading**: `h2` with `flex items-center gap-heading text-column-title text-ink`. It starts with the status dot,
  `size-status-dot rounded-full` and one of `bg-status-todo`, `bg-status-in-progress` or `bg-status-done`, hidden
  from assistive technology (`aria-hidden="true"`). The text is the status label: To Do, In Progress or Done.
- **Cards**: a list (`<ul>`, one `<li>` per card) with `flex flex-col gap-cards`. Cards take the full column width.
- The whole column, including the space below the last card, is the drop area for drag-and-drop.

### Empty column

A column without tasks shows a message where the cards would be:

- `rounded-card border border-dashed border-border-strong px-card-x py-empty-y text-center text-caption
  text-ink-muted`.
- Text: **No tasks**.
- The empty column stays a drop target and is highlighted like any other column.

## Cards

A card shows one task. There are two styles, chosen with the [card style switch](#card-style-switch); all cards on the
board use the same style. Normal is the default.

Both styles share:

- `w-full rounded-card border border-border bg-surface px-card-x shadow-card text-left`.
- The whole card is one focusable control that opens the **Edit task** dialog on click, <kbd>Enter</kbd> or
  <kbd>Space</kbd>. Its accessible name is the task title. The card is also the drag handle.
- Title: `text-card-title text-ink line-clamp-card-title wrap-anywhere`. Long titles and long words wrap and are cut off
  after 2 lines, so they never widen the column. The full title is in the edit dialog.

```
Normal                               Relaxed
┌──────────────────────────────┐     ┌──────────────────────────────┐
│ Write the design spec        │     │ Write the design spec        │
└──────────────────────────────┘     │ Colours, typography, spacing │
                                     │ and the board layout, with a │
                                     │ token name for every value…  │
                                     └──────────────────────────────┘
```

### Normal (default)

- Title only: `py-card-y`.
- One-line titles give a card height of 38px (1px border + 0.5rem + 20px + 0.5rem + 1px border).

### Relaxed

- Title plus the start of the description: `flex flex-col gap-card-stack py-card-y-relaxed`.
- Description: `text-card-description text-ink-muted line-clamp-card-description whitespace-pre-line wrap-anywhere`.
  It is plain text; line breaks typed by the user are kept, and the text is cut off with an ellipsis after 3 lines.
- A task without a description shows the title only, with the relaxed padding: no empty description line and no
  extra gap.

## Card style switch

A two-option switch in the header that sets the card style for the whole board.

```
┌─────────────────────────┐
│ ┌────────┐              │
│ │ Normal │   Relaxed    │
│ └────────┘              │
└─────────────────────────┘
```

- Semantics: a radio group named **Card style** with the options **Normal** and **Relaxed**. Built from native radio
  inputs, so the current option is exposed to assistive technology and the arrow keys move between options. The group
  name is visually hidden (`sr-only`); the option labels are visible.
- Track: `inline-flex rounded-control border border-border bg-surface-muted p-segment-inset`.
- Option: `rounded-segment px-segment-x py-segment-y text-label cursor-pointer`. The radio input itself is visually
  hidden; the label is the visible option.
  - Unselected: `text-ink-muted`, hover `text-ink`.
  - Selected: `bg-surface text-ink shadow-segment`.
  - Keyboard focus: the [focus ring](#focus-ring) is drawn on the label of the focused option
    (`has-focus-visible:`).

## Buttons

Shared by all variants:

- `inline-flex items-center justify-center gap-actions rounded-control border px-button-x py-button-y text-button
  cursor-pointer transition`.
- Sentence-case labels, no icons required. Default `type` is `button`; the submit button of a form uses `submit`.
- Every variant has a 1px border (transparent where it isn't visible), so all variants are the same height.

| Variant   | Rest                                             | Hover                            | Used for                              |
|-----------|--------------------------------------------------|----------------------------------|---------------------------------------|
| Primary   | `bg-primary text-ink-inverse border-transparent` | `enabled:hover:bg-primary-hover` | New task, Create, Save                |
| Secondary | `bg-surface text-ink border-border-strong`       | `enabled:hover:bg-surface-hover` | Cancel                                |
| Danger    | `bg-danger text-ink-inverse border-transparent`  | `enabled:hover:bg-danger-hover`  | Delete (edit dialog and confirmation) |

- **Disabled**: `disabled:opacity-disabled disabled:cursor-not-allowed`. Hover styles use the `enabled:` variant, so a
  disabled button does not change on hover.
- **Keyboard focus**: the [focus ring](#focus-ring).
- A dialog has at most one primary or danger button that confirms the action.

## Form fields

Text input, textarea and select share one field layout: a visible label above the control.

```
Title
┌────────────────────────────────────────────┐
│ Write the design spec                      │
└────────────────────────────────────────────┘
Title is required
```

- Field: `flex flex-col gap-field`.
- Label: `<label>` linked to the control by id, `text-label text-ink`. Labels are always visible; placeholders are not
  used instead of labels.
- Control: `w-full rounded-control border border-border-strong bg-surface px-input-x py-input-y text-input text-ink`.
- **Text input**: one line. Used for the task title.
- **Textarea**: 4 rows, resizable vertically only (`resize-y`). Used for the plain-text description.
- **Select**: the same control styling, with the native arrow. Used for the task status in the edit dialog; options in
  board order: To Do, In Progress, Done.
- **Keyboard focus**: the [focus ring](#focus-ring); the border does not change.
- **Error**: shown when the form is submitted with an empty or whitespace-only title. The control gets
  `aria-invalid="true"` and `border-danger`, and the message **Title is required** appears below it in
  `text-caption text-danger`, linked with `aria-describedby`. The error clears when the user types a title.

## Dialogs

All dialogs use the native `<dialog>` element, opened as a modal (`showModal()`).

- Dialog: `m-auto w-[calc(100%_-_2_*_var(--spacing-page))] rounded-dialog bg-surface p-dialog-inset text-ink shadow-dialog backdrop:bg-backdrop`.
  Tailwind's preflight removes the browser's `margin: auto`, so `m-auto` centres it again. The calculated width
  keeps at least `--spacing-page` free on each side, including on viewports narrower than the dialog.
- Width is a dialog option with two sizes: `max-w-dialog` (default, create and edit) and `max-w-dialog-sm` (delete
  confirmation). A dialog uses exactly one of them.
- Content: `flex flex-col gap-dialog-stack` with three parts:
  1. **Title**: `h2`, `text-dialog-title text-ink`; it is the dialog's accessible name (`aria-labelledby`).
  2. **Content**: the form fields (`flex flex-col gap-fields`) or the confirmation text (`text-body text-ink`).
  3. **Actions**: a row of buttons, `flex flex-wrap items-center justify-end gap-actions`. The confirming button is
     last. When the buttons do not fit on one line, as in the edit dialog on a 320px screen, they wrap and stay
     right-aligned, so nothing overflows the dialog padding.
- <kbd>Escape</kbd> closes the dialog like **Cancel**. Clicking the backdrop does nothing, so typed text is not lost
  by accident.
- The parent owns whether a dialog is open. Every way of closing it (<kbd>Escape</kbd>, **Cancel**, or finishing
  the action) ends in the dialog's `onClose`, so the parent's state and the `<dialog>` never disagree.
- When a dialog closes, focus returns to the control that opened it (native `<dialog>` behaviour), unless that
  control no longer exists; the edit and delete sections say where focus goes then.

```
┌────────────────────────────────────────┐   ┌────────────────────────────────────────┐
│ New task                               │   │ Edit task                              │
│                                        │   │                                        │
│ Title                                  │   │ Title                                  │
│ [                                    ] │   │ [ Write the design spec              ] │
│ Description                            │   │ Description                            │
│ [                                    ] │   │ [ Colours, typography, spacing …     ] │
│ [                                    ] │   │ [                                    ] │
│                                        │   │ Status                                 │
│                                        │   │ [ To Do                            ▾ ] │
│                                        │   │                                        │
│                  [ Cancel ] [ Create ] │   │ [ Delete ]         [ Cancel ] [ Save ] │
└────────────────────────────────────────┘   └────────────────────────────────────────┘
```

### Create task

- Opened by **New task** in the header.
- Title: **New task**. Width: `max-w-dialog`.
- Fields: **Title** (text input, required) and **Description** (textarea, optional). Both start empty. Initial focus
  is on Title.
- Actions: **Cancel** (secondary), **Create** (primary, `type="submit"`).
- The new task goes to To Do. After creating, the dialog closes and its fields are reset.

### Edit task

- Opened by selecting a card.
- Title: **Edit task**. Width: `max-w-dialog`.
- Fields: **Title** (text input, required), **Description** (textarea), **Status** (select), filled with the task's
  current values. Initial focus is on Title. Changing the status is the keyboard alternative to drag-and-drop.
- Actions: **Delete** (danger) on the left, separated from the others with `mr-auto`; then **Cancel** (secondary) and
  **Save** (primary, `type="submit"`) on the right.
- **Cancel** discards the changes. **Save** updates the task; if the status changed, the card moves to that column.
- After closing, focus returns to the edited card, in its new column if the status changed (the card element may
  have been re-created there, so focus it explicitly).

### Delete confirmation

- Opened by **Delete** in the edit dialog. It opens on top of the edit dialog (both are in the top layer).
- Title: **Delete task?** Width: `max-w-dialog-sm`.
- Content: `“<task title>” will be removed from the board. This can't be undone.` in `text-body wrap-anywhere`. The
  title is shown in full here, not clamped; long words and URLs wrap within the dialog.
- Actions: **Cancel** (secondary), **Delete** (danger). Initial focus is on **Cancel**, the safe choice.
- **Cancel** or <kbd>Escape</kbd> returns to the edit dialog. **Delete** removes the task and closes both dialogs;
  because the card no longer exists, focus moves to the **New task** button.

## States

### Focus ring

Every interactive element (cards, buttons, style switch options, inputs, textareas, selects) shows the same ring on
keyboard focus:

```
focus-visible:outline-focus focus-visible:outline-offset-focus focus-visible:outline-focus-ring
```

- A 2px solid outline, 2px outside the control, in `focus-ring`. The gap keeps the ring visible on the primary and
  danger buttons.
- Outlines, unlike box shadows, stay visible in forced-colours mode, which is why the ring is an outline and not a
  Tailwind `ring-*`.
- `focus-visible` shows the ring for keyboard focus and always for text fields, but not when a button is clicked.

### Hover

| Element             | Hover                                              |
|---------------------|----------------------------------------------------|
| Card                | `shadow-card-hover`; cursor `pointer`              |
| Primary button      | `bg-primary-hover` (enabled buttons only)          |
| Secondary button    | `bg-surface-hover` (enabled buttons only)          |
| Danger button       | `bg-danger-hover` (enabled buttons only)           |
| Style switch option | Unselected option: `text-ink`                      |
| Inputs              | No change                                          |

Hover changes use `transition`. There are no other animations.

### Dragging a card

A card can be dragged from its column and dropped on another column to change its status. Cards are not reordered
within a column.

- **Dragged card**: while a drag is in progress, the card left in its original column shows `opacity-dragged` and
  `shadow-none`, so it reads as "this is the one moving". Apply this style after the drag has started (for example on
  the next frame), so the browser's drag image is taken from the normal card.
- **Drag preview**: with the browser's built-in drag-and-drop the drag image is a snapshot of the card and cannot be
  styled. If the chosen drag-and-drop approach renders its own preview, it is the card at rest with `shadow-card-drag`.
- **Drop target**: the column under the pointer, when it is not the card's current column, gets
  `bg-drop-surface outline-drop outline-dashed outline-offset-drop outline-drop-accent`. The outline is drawn inside
  the column, so the layout does not move. Only one column is highlighted at a time. The card's own column is never
  highlighted, because dropping there changes nothing.
- When the card is dropped or the drag is cancelled, the dragged-card and drop-target styles are removed.

### Empty column

See [Empty column](#empty-column).

## Not designed

These are out of scope in `APP_DESCRIPTION.md` or the UI foundation issue, so the spec has no place for them:

- Choosing, creating or showing more than one board; there is no board picker.
- Adding, removing, renaming or reordering columns; custom statuses.
- Rich text, Markdown, HTML or attachments in descriptions.
- Showing dates, history or who changed a task; time zones.
- Dark mode, internationalisation and localisation. Texts are in English.
- Saving the card style; it resets to normal on reload.

## All tokens

The complete `@theme` block. It extends the existing `@theme` in `src/index.css`; the starter `rescript-*` palette and
`--font-inter` stay until the board layout replaces the starter page.

```css
@theme {
  /* Colours: surfaces and borders */
  --color-canvas: oklch(98.5% 0.003 260);
  --color-surface: oklch(100% 0 0);
  --color-surface-muted: oklch(96.5% 0.006 260);
  --color-surface-hover: oklch(95% 0.008 260);
  --color-border: oklch(91% 0.008 260);
  --color-border-strong: oklch(64% 0.015 260);
  --color-backdrop: oklch(24% 0.02 260 / 45%);

  /* Colours: text */
  --color-ink: oklch(24% 0.02 260);
  --color-ink-muted: oklch(48% 0.02 260);
  --color-ink-inverse: oklch(100% 0 0);

  /* Colours: actions */
  --color-primary: oklch(51% 0.23 277);
  --color-primary-hover: oklch(45% 0.21 277);
  --color-danger: oklch(55% 0.2 27);
  --color-danger-hover: oklch(48% 0.18 27);

  /* Colours: status accents */
  --color-status-todo: oklch(60% 0.03 260);
  --color-status-in-progress: oklch(62% 0.13 70);
  --color-status-done: oklch(60% 0.14 150);

  /* Colours: focus and drag-and-drop */
  --color-focus-ring: oklch(56% 0.18 255);
  --color-drop-surface: oklch(95.5% 0.02 277);
  --color-drop-accent: oklch(55% 0.2 277);

  /* Typography */
  --font-sans: Inter, system-ui, Avenir, Helvetica, Arial, sans-serif;

  --text-board-title: 1.5rem;
  --text-board-title--line-height: 2rem;
  --text-board-title--font-weight: 600;
  --text-dialog-title: 1.125rem;
  --text-dialog-title--line-height: 1.75rem;
  --text-dialog-title--font-weight: 600;
  --text-column-title: 0.875rem;
  --text-column-title--line-height: 1.25rem;
  --text-column-title--font-weight: 600;
  --text-card-title: 0.875rem;
  --text-card-title--line-height: 1.25rem;
  --text-card-title--font-weight: 500;
  --text-card-description: 0.8125rem;
  --text-card-description--line-height: 1.125rem;
  --text-card-description--font-weight: 400;
  --text-body: 0.875rem;
  --text-body--line-height: 1.25rem;
  --text-body--font-weight: 400;
  --text-label: 0.875rem;
  --text-label--line-height: 1.25rem;
  --text-label--font-weight: 500;
  --text-input: 1rem;
  --text-input--line-height: 1.5rem;
  --text-input--font-weight: 400;
  --text-button: 0.875rem;
  --text-button--line-height: 1.25rem;
  --text-button--font-weight: 500;
  --text-caption: 0.8125rem;
  --text-caption--line-height: 1.125rem;
  --text-caption--font-weight: 400;

  /* Spacing */
  --spacing-page: 1.5rem;
  --spacing-section: 1.5rem;
  --spacing-toolbar: 0.75rem;
  --spacing-columns: 1rem;
  --spacing-column-inset: 0.75rem;
  --spacing-column-stack: 0.75rem;
  --spacing-heading: 0.5rem;
  --spacing-status-dot: 0.5rem;
  --spacing-cards: 0.5rem;
  --spacing-card-x: 0.75rem;
  --spacing-card-y: 0.5rem;
  --spacing-card-y-relaxed: 0.75rem;
  --spacing-card-stack: 0.25rem;
  --spacing-empty-y: 1.5rem;
  --spacing-button-x: 1rem;
  --spacing-button-y: 0.5rem;
  --spacing-input-x: 0.75rem;
  --spacing-input-y: 0.5rem;
  --spacing-field: 0.375rem;
  --spacing-fields: 1rem;
  --spacing-dialog-inset: 1.5rem;
  --spacing-dialog-stack: 1.25rem;
  --spacing-actions: 0.5rem;
  --spacing-segment-inset: 0.125rem;
  --spacing-segment-x: 0.75rem;
  --spacing-segment-y: 0.375rem;

  /* Sizes */
  --container-board: 80rem;
  --container-column: 16rem;
  --container-dialog: 32rem;
  --container-dialog-sm: 26rem;

  /* Radius */
  --radius-control: 0.375rem;
  --radius-segment: 0.25rem;
  --radius-card: 0.5rem;
  --radius-column: 0.75rem;
  --radius-dialog: 0.75rem;

  /* Shadows */
  --shadow-card: 0 1px 2px 0 oklch(24% 0.02 260 / 8%);
  --shadow-card-hover: 0 2px 6px 0 oklch(24% 0.02 260 / 12%);
  --shadow-card-drag: 0 8px 20px -4px oklch(24% 0.02 260 / 20%);
  --shadow-segment: 0 1px 2px 0 oklch(24% 0.02 260 / 10%);
  --shadow-dialog: 0 20px 48px -12px oklch(24% 0.02 260 / 30%);

  /* Other */
  --opacity-dragged: 50%;
  --opacity-disabled: 50%;
  --line-clamp-card-title: 2;
  --line-clamp-card-description: 3;
  --outline-width-focus: 2px;
  --outline-offset-focus: 2px;
  --outline-width-drop: 2px;
  --outline-offset-drop: -2px;
}
```
