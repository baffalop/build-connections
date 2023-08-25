@react.component
let make = (~cards: Puzzle.cards) => {
  let (unsolved, setUnsolved) = React.useState(() => Belt.Array.shuffle(cards))
  let (selection, setSelection) = React.useState((): array<Puzzle.cardId> => [])
  let (solved, setSolved) = React.useState((): array<Puzzle.solved> => [])

  let hasSelection = Belt.Array.length(selection) > 0
  let hasFullSelection = Belt.Array.length(selection) >= 4

  let isSelected = id => Belt.Array.some(selection, s => s == id)
  let select = (id: Puzzle.cardId) =>
    if !hasFullSelection {
      setSelection(Utils.Array.append(_, id))
    }
  let deselect = (id: Puzzle.cardId) => setSelection(Belt.Array.keep(_, s => s != id))
  let deselectAll = () => setSelection(_ => [])

  let solve = () => {
    if hasFullSelection {
      let selectedCards = unsolved->Belt.Array.keep(({id}) => isSelected(id))
      switch Puzzle.matchingGroup(selectedCards) {
      | Some(group) => {
          setUnsolved(Belt.Array.keep(_, ({id}) => !isSelected(id)))
          setSolved(
            Utils.Array.append(
              _,
              {group, cards: selectedCards->Belt.Array.map(({value}) => value)},
            ),
          )
        }
      | None => deselectAll()
      }
    }
  }

  <Form
    buttons={<>
      <button type_="button" className="action" onClick={_ => setUnsolved(Belt.Array.shuffle)}>
        {React.string("Shuffle")}
      </button>
      <button
        type_="button" className="action" onClick={_ => deselectAll()} disabled={!hasSelection}>
        {React.string("Deselect All")}
      </button>
      <button type_="submit" className="action primary" disabled={!hasFullSelection}>
        {React.string("Submit")}
      </button>
    </>}
    onSubmit={solve}>
    <div className="grid grid-cols-[auto_auto_auto_auto] gap-3">
      {solved
      ->Belt.Array.map(({group, cards}) => {
        <div
          key={`solved-${Group.name(group)}`}
          className={`card p-6 ${Group.bgColor(group)} col-span-full text-center`}>
          {cards->Belt.Array.joinWith(", ", v => v)->React.string}
        </div>
      })
      ->React.array}
      {unsolved
      ->Belt.Array.map(({id, value}) => {
        let selected = isSelected(id)
        let selectedStyle = selected
          ? "bg-neutral-600 text-white"
          : "bg-neutral-200 hover:bg-neutral-300"

        <button
          key={Puzzle.cardKey(id)}
          className={`card p-6 w-32 cursor-pointer ${selectedStyle}`}
          onClick={_ => id->(selected ? deselect : select)}>
          {React.string(value)}
        </button>
      })
      ->React.array}
    </div>
  </Form>
}
