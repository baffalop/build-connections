%%raw(`import './App.css'`)

let toCards = (values: array<array<string>>): array<Puzzle.card> => {
  Belt.Array.zip(Group.rainbow, values)->Belt.Array.flatMap(((group, row)) =>
    row->Belt.Array.map(value => {Puzzle.group, value: Js.String.trim(value)})
  )
}

module CardInput = {
  @react.component
  let make = (~group: Group.t, ~value: string, ~onInput: string => unit) => {
    let toBg = color => `bg-${color}-400 focus-within:bg-${color}-300`
    let (bg, border) = switch group {
    | Yellow => (toBg("yellow"), "focus:border-yellow-600")
    | Green => (toBg("green"), "focus:border-green-600")
    | Blue => (toBg("blue"), "focus:border-blue-600")
    | Purple => (toBg("purple"), "focus:border-purple-600")
    }

    <div className={`p-2 rounded-lg ${bg}`}>
      <input
        type_="text"
        value
        onInput={e => ReactEvent.Form.currentTarget(e)["value"]->onInput}
        className={`p-4 rounded-md w-28 bg-transparent font-medium flex justify-center appearance-none outline-none uppercase
        border border-dashed border-transparent ${border}`}
      />
    </div>
  }
}

module ClearButton = {
  @react.component
  let make = (~onClick) => {
    <button
      type_="button"
      className="rounded-full px-1.5 pb-0.5 leading-snug text-white font-bold bg-neutral-400 hover:bg-neutral-500 self-center justify-self-center"
      title="Clear row"
      tabIndex={-1}
      onClick>
      {React.string("×")}
    </button>
  }
}

@react.component
let make = (~onCreate: array<Puzzle.card> => unit) => {
  let (values, setValues) = React.useState(() => Belt.Array.make(4, Belt.Array.make(4, "")))

  let setValue = (row, col, value) => {
    setValues(values => {
      Utils.Array.setAt(values, row, Belt.Array.getExn(values, row)->Utils.Array.setAt(col, value))
    })
  }

  let clearRow = row => setValues(Utils.Array.setAt(_, row, Belt.Array.make(4, "")))

  let allValuesFilled = values->Belt.Array.every(Belt.Array.every(_, v => Js.String.trim(v) != ""))

  <form
    className="m-8 space-y-6"
    onSubmit={e => {
      ReactEvent.Form.preventDefault(e)
      values->toCards->onCreate
    }}>
    <div className="grid gap-3 grid-cols-[1fr_1fr_1fr_1fr_auto] max-w-sm">
      {Belt.Array.zip(Group.rainbow, values)
      ->Belt.Array.mapWithIndex((row, (group, groupValues)) => {
        Belt.Array.mapWithIndex(groupValues, (col, value) => {
          let key = `${Group.name(group)}-${Belt.Int.toString(col)}`
          <CardInput key group value onInput={setValue(row, col, _)} />
        })->Utils.Array.append(
          <ClearButton key={`clear-${Belt.Int.toString(row)}`} onClick={_ => clearRow(row)} />,
        )
      })
      ->Belt.Array.concatMany
      ->React.array}
    </div>
    <button type_="submit" className="action" disabled={!allValuesFilled}>
      {React.string("Create")}
    </button>
  </form>
}
