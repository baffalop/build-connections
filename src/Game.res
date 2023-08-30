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
let make = () => {
  let connections: Puzzle.connections = ReactRouter.useLoaderData()

  let (unsolved, setUnsolved) = React.useState(() =>
    connections->Puzzle.makeCards->Belt.Array.shuffle
  )
  let (selection, setSelection) = React.useState((): array<Puzzle.cardId> => [])
  let (solved, setSolved) = React.useState((): Puzzle.solved => [])
  let (lives, setLives) = React.useState(() => 4)

  let hasSelection = Belt.Array.length(selection) > 0
  let hasFullSelection = Belt.Array.length(selection) >= 4
  let hasLives = lives > 0

  let isSelected = id => Belt.Array.some(selection, s => s == id)
  let select = (id: Puzzle.cardId) =>
    if !hasFullSelection {
      setSelection(Utils.Array.append(_, id))
    }
  let deselect = (id: Puzzle.cardId) => setSelection(Belt.Array.keep(_, s => s != id))
  let deselectAll = () => setSelection(_ => [])

  let loseLife = () =>
    if hasLives {
      setLives(l => l - 1)
    }

  let solve = () => {
    if hasFullSelection {
      let selectedCards =
        selection->Belt.Array.keepMap(id => Belt.Array.getBy(unsolved, ({id: card}) => id == card))

      switch Puzzle.matchingGroup(selectedCards) {
      | Some(group) => {
          setUnsolved(Belt.Array.keep(_, ({id}) => !isSelected(id)))
          setSolved(
            Utils.Array.append(
              _,
              {
                group,
                title: Puzzle.getRow(connections, group).title,
                values: selectedCards->Belt.Array.map(({value}) => value),
              },
            ),
          )
          deselectAll()
        }
      | None => {
          loseLife()
          deselectAll()
        }
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
    message={<div className="flex items-center justify-center gap-2 font-medium">
      {switch (lives, unsolved) {
      | (0, _) => React.string("Game over!")
      | (_, []) => React.string("Well done!")
      | (_, _) =>
        <>
          <span className="font-medium"> {React.string(`Mistakes remaining:`)} </span>
          {Belt.Array.range(1, lives)
          ->Belt.Array.map(i =>
            <div key={Belt.Int.toString(i)} className="bg-neutral-500 rounded-full w-3 h-3" />
          )
          ->React.array}
        </>
      }}
    </div>}
    onSubmit={solve}>
    <div className="grid grid-cols-4 gap-2 sm:gap-3">
      {solved
      ->Belt.Array.map(({group, title, values}) =>
        <Solution key={`solved-${Group.name(group)}`} group title values />
      )
      ->React.array}
      {if lives > 0 {
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
            disabled={!hasLives}
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
