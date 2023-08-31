type gameState = Playing | Solved | Lost

module Solution = {
  @react.component
  let make = (~group, ~title, ~values) =>
    <div className={`card p-6 ${Group.bgColor(group)} col-span-full text-center space-y-1`}>
      <h4 className="font-bold uppercase"> {React.string(title)} </h4>
      <p className="font-normal"> {values->Belt.Array.joinWith(", ", v => v)->React.string} </p>
    </div>
}

let {sampleValues: connections} = module(Create)

@react.component
let make = (~showToast: string => unit) => {
  let (connections, slug): (Puzzle.connections, string) = ReactRouter.useLoaderData()
  let (guesses, setGuesses) = Hooks.useLocalStorage(
    () => [],
    `guesses-${slug}`,
    Puzzle.Decode.guesses,
    Puzzle.Encode.guesses,
  )

  let (solved, setSolved) = React.useState(() =>
    guesses->Belt.Array.keepMap(Puzzle.findSolution(_, connections))
  )
  let (unsolved, setUnsolved) = React.useState(() => {
    connections
    ->Puzzle.makeCards
    ->Belt.Array.keep(({group}) => solved->Belt.Array.every(solved => solved.group != group))
    ->Belt.Array.shuffle
  })
  let (selection, setSelection) = React.useState((): array<Puzzle.cardId> => [])

  let hasSelection = Belt.Array.length(selection) > 0
  let hasFullSelection = Belt.Array.length(selection) >= 4

  let isSelected = id => Belt.Array.some(selection, s => s == id)
  let select = (id: Puzzle.cardId) =>
    if !hasFullSelection {
      setSelection(Utils.Array.append(_, id))
    }
  let deselect = (id: Puzzle.cardId) => setSelection(Belt.Array.keep(_, s => s != id))
  let deselectAll = () => setSelection(_ => [])

  let wrongGuesses = React.useMemo1(() => {
    guesses->Belt.Array.keep(guess =>
      guess->Utils.Array.matchAllBy(Puzzle.groupFromId)->Option.isNone
    )
  }, [guesses])

  let lives = 4 - Array.length(wrongGuesses)
  let gameState = switch (lives, unsolved) {
  | (0, _) => Lost
  | (_, []) => Solved
  | _ => Playing
  }

  let guess = () => {
    if hasFullSelection {
      switch selection->Utils.Array.matchBy(Puzzle.groupFromId) {
      | NoMatch => showToast(lives <= 1 ? "Unlucky!" : "Nope")
      | OneAway(_, _) => showToast("One away...")
      | Match(group) => {
          let solution =
            connections
            ->List.getAssoc(group, Utils.Id.eq)
            ->Option.map(({title, values}) => {Puzzle.group, title, values})
            ->Option.getExn

          setUnsolved(Belt.Array.keep(_, ({id}) => !isSelected(id)))
          setSolved(Utils.Array.append(_, solution))
        }
      }

      deselectAll()
      setGuesses(Utils.Array.append(_, selection))
    }
  }

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

  <Form
    buttons={switch gameState {
    | Playing =>
      <>
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
      </>
    | _ =>
      <button type_="button" className="action" onClick={_ => copyResults()->Promise.done}>
        {React.string("Copy Results")}
      </button>
    }}
    message={<div className="flex items-center justify-center gap-2 font-medium">
      {switch gameState {
      | Lost => React.string("Game over!")
      | Solved => React.string("Well done!")
      | Playing =>
        <>
          <span className="font-medium"> {React.string("Mistakes remaining:")} </span>
          {Belt.Array.range(1, lives)
          ->Belt.Array.map(i =>
            <div key={Belt.Int.toString(i)} className="bg-neutral-500 rounded-full w-3 h-3" />
          )
          ->React.array}
        </>
      }}
    </div>}
    onSubmit={guess}>
    <div className="grid grid-cols-4 gap-2 sm:gap-3">
      {solved
      ->Belt.Array.map(({group, title, values}) =>
        <Solution key={`solved-${Group.name(group)}`} group title values />
      )
      ->React.array}
      {if gameState == Playing {
        // cards
        unsolved
        ->Belt.Array.map(({id, value}) => {
          let selected = isSelected(id)

          <button
            type_="button"
            key={Puzzle.cardKey(id)}
            className={`card py-6 sm:py-8 px-1 cursor-pointer
            ${selected ? "bg-neutral-600 text-white" : "bg-neutral-200 hover:bg-neutral-300"}
            disabled:cursor-default disabled:bg-neutral-200 disabled:text-neutral-600`}
            onClick={_ => id->(selected ? deselect : select)}>
            {React.string(value)}
          </button>
        })
        ->React.array
      } else {
        // revealed connections
        List.toArray(connections)
        ->Belt.Array.keepMap(((group, {title, values})) =>
          if Belt.Array.some(solved, ({group: solvedGroup}) => group == solvedGroup) {
            None
          } else {
            Some(<Solution key={`revealed-${Group.name(group)}`} group title values />)
          }
        )
        ->React.array
      }}
    </div>
  </Form>
}
