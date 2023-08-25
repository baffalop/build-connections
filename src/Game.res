@react.component
let make = (~cards: Puzzle.cards) => {
  let (unsolved, setUnsolved) = React.useState(() => Belt.Array.shuffle(cards))

  let (selected, setSelected) = React.useState((): array<Puzzle.cardId> => [])

  let hasSelected = Belt.Array.length(selected) > 0
  let hasFullSelection = Belt.Array.length(selected) >= 4

  let select = (id: Puzzle.cardId) =>
    if !hasFullSelection {
      setSelected(Utils.Array.append(_, id))
    }
  let deselect = (id: Puzzle.cardId) => setSelected(Belt.Array.keep(_, s => s != id))

  <Form
    buttons={<>
      <button type_="button" className="action" onClick={_ => setUnsolved(Belt.Array.shuffle)}>
        {React.string("Shuffle")}
      </button>
      <button
        type_="button"
        className="action"
        onClick={_ => setSelected(_ => [])}
        disabled={!hasSelected}>
        {React.string("Deselect All")}
      </button>
      <button
        type_="submit"
        className="action primary"
        disabled={!hasFullSelection}
        onClick={_ => Console.log("Submit")}>
        {React.string("Submit")}
      </button>
    </>}
    onSubmit={() => Console.log("Submit")}>
    <div className="grid grid-cols-[auto_auto_auto_auto] gap-3">
      {unsolved
      ->Belt.Array.map(({id, value}) => {
        let isSelected = Belt.Array.some(selected, s => s == id)
        let selectedStyle = isSelected
          ? "bg-neutral-600 text-white"
          : "bg-neutral-200 hover:bg-neutral-300"

        <button
          key={Puzzle.cardKey(id)}
          className={`card p-6 w-32 cursor-pointer ${selectedStyle}`}
          onClick={_ => id->(isSelected ? deselect : select)}>
          {React.string(value)}
        </button>
      })
      ->React.array}
    </div>
  </Form>
}
