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
        className={`${inputRole} rounded-md w-full bg-transparent uppercase text-base
          flex justify-center appearance-none outline-none
          border border-dashed border-transparent ${border}`}
      />
    </div>
  }
}

module InputSection = {
  @react.component
  let make = (
    ~id: Puzzle.rowId,
    ~group: Group.t,
    ~row: Puzzle.connection,
    ~setRow: (Puzzle.rowId, Puzzle.connection) => unit,
  ) => {
    open FramerMotion

    let dragControls = Reorder.useDragControls()

    let {title, values} = row

    let setValue = (col: int, value: string) =>
      setRow(id, {...row, values: values->Utils.Array.setAt(col, value)})
    let setTitle = (title: string) => setRow(id, {...row, title})
    let clearRow = id => setRow(id, Puzzle.blankRow)

    let iconColor = Group.iconColorDark(group)

    <Reorder.Item
      \"as"="section"
      value={id}
      dragListener={false}
      dragControls
      className={`card p-3 ${Group.bgColor(group)} space-y-3`}>
      <div className="flex px-1 gap-2.5 items-center">
        <DragHandle group dragControls />
        <CardInput group role={#title} value={title} onInput={setTitle} />
        <button
          type_="button"
          title="Clear row"
          tabIndex={-1}
          className={`text-2xl font-bold ${iconColor} cursor-pointer flex-shrink-0`}
          onClick={_ => clearRow(id)}>
          {React.string("×")}
        </button>
      </div>
      <div className="grid gap-3 grid-cols-2 sm:grid-cols-4 justify-stretch">
        {values
        ->Belt.Array.mapWithIndex((col, value) => {
          let key = `${Group.name(group)}-${Belt.Int.toString(col)}`
          <CardInput key group value onInput={setValue(col, _)} />
        })
        ->React.array}
      </div>
    </Reorder.Item>
  }
}

@react.component
let make = () => {
  let navigate = ReactRouter.useNavigate()

  let (rows, setRows) = React.useState(() => Puzzle.blankRows)
  let setRow = (id, row) => setRows(Puzzle.setRow(_, id, row))
  let clearAll = _ => setRows(_ => Puzzle.blankRows)

  let allValuesFilled =
    rows->List.every(((_, {values})) => Belt.Array.every(values, v => Js.String.trim(v) != ""))

  let ids = React.useMemo1(() => rows->List.unzip->Utils.Tuple.fst->List.toArray, [rows])

  let onReorder = ids => {
    setRows(rows => ids->List.fromArray->List.map(id => (id, rows->Puzzle.getRow(id))))
  }

  let create = () => {
    if allValuesFilled {
      rows->Puzzle.toConnections->Puzzle.Encode.slug->navigate(None)
    }
  }

  <Form
    title="Build Connections"
    description={<p>
      {"Build your own "->React.string}
      <a target="_blank" href="https://www.nytimes.com/games/connections">
        {"Connections"->React.string}
      </a>
      {" puzzle: create four groups of four cards, each connected in some way. "->React.string}
    </p>}
    buttons={<>
      <button type_="button" className="action" onClick={clearAll}>
        {React.string("Clear All")}
      </button>
      <button type_="submit" className="action primary" disabled={!allValuesFilled}>
        {React.string("Create")}
      </button>
    </>}
    onSubmit={create}>
    <FramerMotion.Reorder.Group
      \"as"="div"
      axis={#y}
      values={ids}
      onReorder
      className="flex flex-col items-stretch justify-start gap-3">
      {rows
      ->List.zipBy(Group.rainbow, ((id, row), group) =>
        <InputSection key={Puzzle.rowKey(id)} id group row setRow />
      )
      ->List.toArray
      ->React.array}
    </FramerMotion.Reorder.Group>
  </Form>
}
