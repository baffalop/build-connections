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

let sampleValues: Puzzle.rows =
  list{
    ("things we need for our bathroom", ["yellow", "cabinet", "ivan", "tiles"]),
    ("kitchen _", ["sink", "porter", "scissors", "appliance"]),
    ("beatles titles first words", ["golden", "seargeant", "hey", "eleanor"]),
    ("magazines", ["n + 1", "tribune", "jacobin", "lrb"]),
  }->List.mapWithIndex((i, (title, values)) => (Puzzle.RowId(i), {Puzzle.title, values}))

@react.component
let make = () => {
  let navigate = ReactRouter.useNavigate()

  let (rows, setRows) = React.useState(() => Puzzle.blankRows)
  let setValue = (id: Puzzle.rowId, col: int, value: string) =>
    setRows(Puzzle.setValue(_, id, col, value))
  let setTitle = (id: Puzzle.rowId, title: string) => setRows(Puzzle.setTitle(_, id, title))

  let allValuesFilled =
    rows->List.every(((_, {values})) => Belt.Array.every(values, v => Js.String.trim(v) != ""))

  let clearRow = group => setRows(Puzzle.setRow(_, group, Puzzle.blankRow))
  let clearAll = _ => setRows(_ => Puzzle.blankRows)

  let onReorder = ids => {
    setRows(rows => ids->List.fromArray->List.map(id => (id, rows->Puzzle.getRow(id))))
  }

  let create = () => {
    if allValuesFilled {
      rows->Puzzle.toConnections->Puzzle.Encode.slug->navigate(None)
    }
  }

  open FramerMotion

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
    <Reorder.Group
      \"as"="div"
      axis={#y}
      values={rows->List.unzip->Utils.Tuple.fst->List.toArray}
      onReorder
      className="flex flex-col items-stretch justify-start gap-3">
      {rows
      ->List.zipBy(Group.rainbow, ((id, {title, values}), group) => {
        <Reorder.Item
          \"as"="section"
          key={Puzzle.rowKey(id)}
          value={id}
          className={`card p-3 ${Group.bgColor(group)} space-y-3 cursor-grab`}>
          <div className="flex gap-2 sm:gap-3 items-center">
            <CardInput group role={#title} value={title} onInput={setTitle(id, _)} />
            <button
              type_="button"
              tabIndex={-1}
              className="action flex-shrink-0"
              onClick={_ => clearRow(id)}>
              {React.string("Clear Row")}
            </button>
          </div>
          <div className="grid gap-3 grid-cols-2 sm:grid-cols-4 justify-stretch">
            {values
            ->Belt.Array.mapWithIndex((col, value) => {
              let key = `${Group.name(group)}-${Belt.Int.toString(col)}`
              <CardInput key group value onInput={setValue(id, col, _)} />
            })
            ->React.array}
          </div>
        </Reorder.Item>
      })
      ->List.toArray
      ->React.array}
    </Reorder.Group>
  </Form>
}
