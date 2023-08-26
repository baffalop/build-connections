%%raw(`import './App.css'`)

module CardInput = {
  @react.component
  let make = (~group: Group.t, ~value: string, ~onInput: string => unit) => {
    let border = switch group {
    | Yellow => "focus:border-yellow-600"
    | Green => "focus:border-green-600"
    | Blue => "focus:border-blue-600"
    | Purple => "focus:border-purple-600"
    }

    <div className={`p-2 rounded-lg ${Group.bgColorLight(group)}`}>
      <input
        type_="text"
        value
        onInput={e => ReactEvent.Form.currentTarget(e)["value"]->onInput}
        className={`p-4 rounded-md w-full bg-transparent font-medium flex justify-center appearance-none outline-none uppercase
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

let blankRow = Belt.Array.make(4, "")
let blankValues = Belt.Array.make(4, blankRow)

let sampleValues = [
  ["yellow", "cabinet", "ivan", "tiles"],
  ["sink", "porter", "scissors", "appliance"],
  ["golden", "seargeant", "hey", "eleanor"],
  ["n + 1", "tribune", "jacobin", "lrb"],
]

@react.component
let make = (~onCreate: array<Puzzle.card> => unit) => {
  let (values, setValues) = React.useState(() => blankValues)

  let setValue = (row, col, value) => {
    setValues(values => {
      Utils.Array.setAt(values, row, Belt.Array.getExn(values, row)->Utils.Array.setAt(col, value))
    })
  }

  let allValuesFilled = values->Belt.Array.every(Belt.Array.every(_, v => Js.String.trim(v) != ""))

  let clearRow = row => setValues(Utils.Array.setAt(_, row, blankRow))
  let clearAll = _ => setValues(_ => blankValues)

  <Form
    buttons={<>
      <button type_="button" className="action" onClick={clearAll}>
        {React.string("Clear All")}
      </button>
      <button type_="button" className="action" onClick={_ => setValues(_ => sampleValues)}>
        {React.string("Fill (test)")}
      </button>
      <button type_="submit" className="action primary" disabled={!allValuesFilled}>
        {React.string("Create")}
      </button>
    </>}
    onSubmit={() => values->Puzzle.makeCards->onCreate}>
    <div className="flex flex-col items-stretch justify-start gap-3">
      {Belt.Array.zip(Group.rainbow, values)
      ->Belt.Array.mapWithIndex((row, (group, groupValues)) => {
        <section className={`card p-4 ${Group.bgColor(group)} flex gap-3 justify-stretch`}>
          {Belt.Array.mapWithIndex(groupValues, (col, value) => {
            let key = `${Group.name(group)}-${Belt.Int.toString(col)}`
            <CardInput key group value onInput={setValue(row, col, _)} />
          })->React.array}
        </section>
      })
      ->React.array}
    </div>
  </Form>
}
