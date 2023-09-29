@react.component
let make = (~guesses: array<array<Puzzle.cardId>>) => {
  <div
    className="fixed !m-auto inset-0 max-w-max max-h-max flex flex-col items-end justify-end gap-4
      rounded-lg bg-neutral-50 border border-neutral-800 px-4 pt-3 pb-4">
    <button type_="button" className="text-2xl leading-none cursor-pointer">
      {React.string("×")}
    </button>
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
