@react.component
let make = (~cards: Puzzle.cards) => {
  let (unsolved, setUnsolved) = React.useState(() => Belt.Array.shuffle(cards))

  <div className="grid grid-cols-[auto_auto_auto_auto] gap-3">
    {unsolved
    ->Belt.Array.map(({group, key, value}) => {
      <button
        key={`${Group.name(group)}-${Belt.Int.toString(key)}`}
        className="card p-6 w-32 bg-neutral-200 hover:bg-neutral-300 cursor-pointer">
        {React.string(value)}
      </button>
    })
    ->React.array}
  </div>
}
