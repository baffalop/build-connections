@react.component
let make = (~guesses: array<array<Puzzle.cardId>>) => {
  <div
    className="fixed !m-auto inset-0 max-w-max max-h-max
      rounded-lg bg-neutral-50 border border-neutral-800 p-6 flex items-center justify-center">
    <div className="grid grid-cols-[auto_auto_auto_auto] gap-x-1 gap-y-2">
      {guesses
      ->Belt.Array.mapWithIndex((i, guess) =>
        guess->Belt.Array.mapWithIndex((j, cardId) => {
          let key = `${Int.toString(i)},${Int.toString(j)}`
          let color = cardId->Puzzle.groupFromId->Group.bgColor

          <div key className={`w-12 h-12 rounded ${color}`} />
        })
      )
      ->Belt.Array.concatMany
      ->React.array}
    </div>
  </div>
}
