@react.component
let make = (~guesses: array<array<Puzzle.cardId>>, ~close: unit => unit) => {
  let copyResults = async () => {
    let grid =
      guesses->Belt.Array.joinWith(
        "\n",
        Belt.Array.joinWith(_, "", (Puzzle.CardId(group, _)) => Group.swatch(group)),
      )
    let result = `Custom Connections\n\n${grid}`

    if !(await Clipboard.writeText(result)) {
      Console.log(result)
    }
  }

  open FramerMotion

  <AnimatePresence>
    <Motion.Div
      initial={{"scale": 0.9}}
      animate={{"scale": 1}}
      transition={{"type": #spring, "duration": 0.3, "bounce": 0.4}}
      className="fixed !m-auto inset-0 max-w-max max-h-max flex flex-col items-center gap-5
    rounded-lg bg-neutral-50 border border-neutral-800 px-4 pt-4 pb-5">
      <button
        type_="button"
        className="text-2xl leading-none cursor-pointer self-end"
        onClick={_ => close()}>
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
      <button type_="button" className="action" onClick={_ => copyResults()->Promise.done}>
        {React.string("Copy Results")}
      </button>
    </Motion.Div>
  </AnimatePresence>
}
