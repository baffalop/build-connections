@react.component
let make = (~cards: Puzzle.cards) => {
  let (unsolved, setUnsolved) = React.useState(() => Belt.Array.shuffle(cards))

  <div className="grid grid-cols-4 gap-3 max-w-md">
    {unsolved
    ->Belt.Array.map(({value}) => {
      <button className="p-6 rounded-lg w-32 bg-neutral-200 cursor-pointer">
        {React.string(value)}
      </button>
    })
    ->React.array}
  </div>
}
