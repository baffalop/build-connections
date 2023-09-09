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

    <Reorder.Item
      \"as"="section"
      value={id}
      dragListener={false}
      dragControls
      className={`card p-3 ${Group.bgColor(group)} space-y-3`}>
      <div className="flex gap-2 sm:gap-3 items-center">
        <div
          className="reorder-handle cursor-grab w-5 self-stretch rounded-sm border border-neutral-700"
          onPointerDown={e => dragControls.start(. e)}
        />
        <CardInput group role={#title} value={title} onInput={setTitle} />
        <button
          type_="button"
          title="Clear row"
          tabIndex={-1}
          className="text-2xl font-bold text-black/20 hover:text-black/40 cursor-pointer flex-shrink-0"
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
  let setRow = (id, row) => setRows(Puzzle.setRow(_, id, row))
  let clearAll = _ => setRows(_ => Puzzle.blankRows)

  let allValuesFilled =
    rows->List.every(((_, {values})) => Belt.Array.every(values, v => Js.String.trim(v) != ""))

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
      <button type_="button" className="action" onClick={_ => setRows(_ => sampleValues)}>
        {React.string("Fill (test)")}
      </button>
      <button type_="submit" className="action primary" disabled={!allValuesFilled}>
        {React.string("Create")}
      </button>
    </>}
    onSubmit={create}>
    <FramerMotion.Reorder.Group
      \"as"="div"
      axis={#y}
      values={rows->List.unzip->Utils.Tuple.fst->List.toArray}
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
