module CardInput = {
  @react.component
  let make = (
    ~group: Group.t,
    ~value: string,
    ~onInput: string => unit,
    ~role: [#card | #title]=#card,
  ) => {
    let border = switch group {
    | Yellow => "focus:border-yellow-600"
    | Green => "focus:border-green-600"
    | Blue => "focus:border-blue-600"
    | Purple => "focus:border-purple-600"
    }

    let (containerRole, inputRole) = switch role {
    | #title => ("w-full", "px-2 py-1 sm:py-1.5 font-bold")
    | #card => ("", "px-2 py-3 font-medium")
    }

    <div className={`p-1 rounded-lg ${Group.bgColorLight(group)} ${containerRole}`}>
      <input
        type_="text"
        value
        onInput={e => ReactEvent.Form.currentTarget(e)["value"]->onInput}
        className={`${inputRole} rounded-md w-full bg-transparent uppercase
          flex justify-center appearance-none outline-none
          border border-dashed border-transparent ${border}`}
      />
    </div>
  }
}

let sampleValues: Puzzle.connections =
  list{
    ("things we need for our bathroom", ["yellow", "cabinet", "ivan", "tiles"]),
    ("kitchen _", ["sink", "porter", "scissors", "appliance"]),
    ("beatles titles first words", ["golden", "seargeant", "hey", "eleanor"]),
    ("magazines", ["n + 1", "tribune", "jacobin", "lrb"]),
  }->List.zipBy(Group.rainbow, ((title, values), group) => (group, {Puzzle.title, values}))

@react.component
let make = () => {
  let navigate = ReactRouter.useNavigate()

  let (rows, setRows) = React.useState(() => Puzzle.blankRows)
  let setValue = (group: Group.t, col: int, value: string) =>
    setRows(Puzzle.setValue(_, group, col, value))
  let setTitle = (group: Group.t, title: string) => setRows(Puzzle.setTitle(_, group, title))

  let allValuesFilled =
    rows->List.every(((_, {values})) => Belt.Array.every(values, v => Js.String.trim(v) != ""))

  let clearRow = group => setRows(Puzzle.setRow(_, group, Puzzle.blankRow))
  let clearAll = _ => setRows(_ => Puzzle.blankRows)

  let create = () => {
    if allValuesFilled {
      Puzzle.encode(rows)->navigate(_, None)
    }
  }

  <Form
    buttons={<>
      <button type_="button" className="action" onClick={clearAll}>
        {React.string("Clear All")}
      </button>
      <button type_="button" className="action" onClick={_ => setRows(_ => sampleValues)}>
        {React.string("Fill (test)")}
      </button>
      <button type_="submit" className="action primary" disabled={!allValuesFilled}>
        {React.string("Create")}
      </button>
    </>}
    onSubmit={create}>
    <div className="flex flex-col items-stretch justify-start gap-3">
      {rows
      ->List.map(((group, {title, values})) => {
        <section key={Group.name(group)} className={`card p-3 ${Group.bgColor(group)} space-y-3`}>
          <div className="flex gap-2 sm:gap-3 items-center">
            <CardInput group role={#title} value={title} onInput={setTitle(group, _)} />
            <button
              type_="button"
              tabIndex={-1}
              className="action flex-shrink-0"
              onClick={_ => clearRow(group)}>
              {React.string("Clear Row")}
            </button>
          </div>
          <div className="grid gap-3 grid-cols-2 sm:grid-cols-4 justify-stretch">
            {values
            ->Belt.Array.mapWithIndex((col, value) => {
              let key = `${Group.name(group)}-${Belt.Int.toString(col)}`
              <CardInput key group value onInput={setValue(group, col, _)} />
            })
            ->React.array}
          </div>
        </section>
      })
      ->List.toArray
      ->React.array}
    </div>
  </Form>
}
