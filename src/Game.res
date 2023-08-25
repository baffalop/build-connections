@react.component
let make = (~cards: Puzzle.cards) => {
  let (unsolved, setUnsolved) = React.useState(() => Belt.Array.shuffle(cards))

  let (selected, setSelected) = React.useState((): array<Puzzle.cardId> => [])

  let select = (id: Puzzle.cardId) =>
    if Belt.Array.length(selected) < 4 {
      setSelected(Utils.Array.append(_, id))
    }
  let deselect = (id: Puzzle.cardId) => setSelected(Belt.Array.keep(_, s => s != id))

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
}
