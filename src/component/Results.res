@react.component
let make = (~guesses: array<array<Puzzle.cardId>>) => {
  <div className="fixed mt-0 inset-0 bg-neutral-50 p-4 flex items-center justify-center">
    <div className="grid grid-cols-[auto_auto_auto_auto] gap-x-1 gap-y-2">
      {guesses
      ->Belt.Array.mapWithIndex((i, guess) =>
        guess->Belt.Array.mapWithIndex((j, cardId) => {
          let key = `${Int.toString(i)},${Int.toString(j)}`
          let color = cardId->Puzzle.groupFromId->Group.bgColor

          <div key className={`w-10 h-10 rounded ${color}`} />
        })
      )
      ->Belt.Array.concatMany
      ->React.array}
    </div>
  </div>
}
