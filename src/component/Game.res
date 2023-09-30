type gameState = Playing | Solved | Lost

module Solution = {
  @react.component
  let make = (~group, ~title, ~values) => {
    open FramerMotion

    <AnimatePresence>
      <Motion.Div
        className={`card px-4 py-2 text-base ${Group.bgColor(
            group,
          )} col-span-full flex flex-col items-center justify-center`}
        initial={{"scale": 0.9}}
        animate={{"scale": 1}}
        transition={{"type": #spring, "duration": 0.5, "bounce": 0.4}}>
        <h4 className="font-bold uppercase"> {React.string(title)} </h4>
        <p className="font-normal"> {values->Belt.Array.joinWith(", ", v => v)->React.string} </p>
      </Motion.Div>
    </AnimatePresence>
  }
}

module Card = {
  @react.component
  let make = (~children: string, ~selected: bool, ~onClick: unit => unit) => {
    let (buttonRef, {UseHooks.width: buttonWidth, height: buttonHeight}) = UseHooks.useMeasure()
    let (textRef, {UseHooks.width: textWidth, height: textHeight}) = UseHooks.useMeasure()

    let textIntrinsicWidth = Hooks.useFirstValue(textWidth)
    let textIntrinsicHeight = Hooks.useFirstValue(textHeight)

    let scale = React.useMemo2(() => {
      let widthScale = switch (textIntrinsicWidth, buttonWidth->Js.Nullable.toOption) {
      | (Some(text), Some(button)) => min(button /. text, 1.0)
      | _ => 1.0
      }

      let heightScale = switch (textIntrinsicHeight, buttonHeight->Js.Nullable.toOption) {
      | (Some(text), Some(button)) => min(button /. text, 1.0)
      | _ => 1.0
      }

      min(widthScale, heightScale)
    }, ([textIntrinsicWidth, textIntrinsicHeight], [buttonWidth, buttonHeight]))

    open FramerMotion

    <Motion.Button
      ref={buttonRef}
      \"type"="button"
      className={`card h-0 py-3 px-2 cursor-pointer text-base !font-semibold flex justify-center items-center
            ${selected
          ? "selected bg-neutral-600 text-white"
          : "bg-neutral-200 hover:bg-neutral-300"}
            disabled:cursor-default disabled:bg-neutral-200 disabled:text-neutral-600`}
      onClick={onClick}
      layout={true}>
      <div
        ref={textRef}
        className="min-w-min max-w-max"
        style={{transform: `scale(${scale->Float.toString})`}}>
        {React.string(children)}
      </div>
    </Motion.Button>
  }
}

@react.component
let make = (~connections: Puzzle.connections, ~slug: string) => {
  let (guesses, setGuesses) = Hooks.useLocalStorage(
    () => [],
    `guesses-${slug}`,
    Puzzle.Decode.guesses,
    Puzzle.Encode.guesses,
  )

  let wrongGuesses = React.useMemo1(() => {
    guesses->Belt.Array.keep(guess =>
      guess->Utils.Array.matchAllBy(Puzzle.groupFromId)->Option.isNone
    )
  }, [guesses])
  let lives = 4 - Array.length(wrongGuesses)

  let (solved, setSolved) = React.useState(() => {
    let solved = guesses->Belt.Array.keepMap(Puzzle.findSolution(_, connections))
    lives > 0 ? solved : solved->Belt.Array.concat(connections->Puzzle.remainingSolutions(solved))
  })
  let (unsolved, setUnsolved) = React.useState(() => {
    connections
    ->Puzzle.makeCards
    ->Belt.Array.keep(({group}) => solved->Belt.Array.every(solved => solved.group != group))
    ->Belt.Array.shuffle
  })
  let (selection, setSelection) = React.useState((): array<Puzzle.cardId> => [])

  let (showToast, toast) = Toast.useToast()

  let {revealSolution, revealAll, animating} = Animation.useReveal(
    ~connections,
    ~solved,
    ~unsolved,
    ~setUnsolved,
    ~setSolved,
    ~setSelection=s => setSelection(_ => s),
  )

  let hasSelection = !animating && Belt.Array.length(selection) > 0
  let hasFullSelection = !animating && Belt.Array.length(selection) >= 4

  let isSelected = id => Belt.Array.some(selection, s => s == id)
  let select = (id: Puzzle.cardId) =>
    if !hasFullSelection {
      setSelection(Utils.Array.append(_, id))
    }
  let deselect = (id: Puzzle.cardId) => setSelection(Belt.Array.keep(_, s => s != id))
  let deselectAll = () => setSelection(_ => [])

  let (showingResults, setShowResults) = React.useState(() => false)

  let gameState = switch (lives, unsolved) {
  | (0, _) => Lost
  | (_, []) => Solved
  | _ => Playing
  }

  let submitGuess = async () => {
    if hasFullSelection {
      let guess = selection->Puzzle.inCanonicalOrder

      if guesses->Belt.Array.some(Belt.Array.eq(_, guess, Utils.Id.eq)) {
        showToast("Already guessed")
      } else {
        await FramerMotion.animate(
          ".card.selected",
          {"y": [0, -10, 0]},
          {"duration": 0.25, "delay": FramerMotion.stagger(0.1)},
        )
        await Utils.Time.wait(300)

        switch guess->Utils.Array.matchBy(Puzzle.groupFromId) {
        | NoMatch => await Animation.shakeSelected()
        | OneAway(_, _) => {
            showToast("One away...")
            await Animation.shakeSelected()
          }
        | Match(group) => await revealSolution(group)
        }

        deselectAll()
        setGuesses(Utils.Array.append(_, guess))
      }
    }
  }

  React.useEffect1(() => {
    if gameState == Lost {
      revealAll()->Promise.done
    }
    None
  }, [gameState])

  open FramerMotion

  <Form
    title="Custom Connections"
    className="max-w-lg"
    description={<>
      <p> {"Find four groups of four!"->React.string} </p>
      <p>
        {"A custom "->React.string}
        <a target="_blank" href="https://www.nytimes.com/games/connections">
          {"Connections"->React.string}
        </a>
        {" puzzle. "->React.string}
        <ReactRouter.Link href="/"> {"Build your own"->React.string} </ReactRouter.Link>
        {"."->React.string}
      </p>
    </>}
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
      <button type_="button" className="action" onClick={_ => setShowResults(_ => true)}>
        {React.string("Show Results")}
      </button>
    }}
    message={<>
      {toast}
      {switch gameState {
      | Lost | Solved =>
        <AnimatePresence>
          {showingResults
            ? <Results guesses lives close={() => setShowResults(_ => false)} />
            : React.null}
        </AnimatePresence>
      | Playing => React.null
      }}
      <div className="flex items-center justify-center gap-2">
        {switch gameState {
        | Lost => React.string("Game over!")
        | Solved => React.string("Well done!")
        | Playing =>
          <>
            <span> {React.string("Mistakes remaining:")} </span>
            <div className="flex gap-2 w-20">
              <AnimatePresence>
                {Belt.Array.range(1, lives)
                ->Belt.Array.map(i =>
                  <Motion.Div
                    key={Belt.Int.toString(i)}
                    className="bg-neutral-500 rounded-full w-4 h-4 flex-shrink-0"
                    animate={{"scale": 1}}
                    exit={{"scale": 0}}
                    transition={{"duration": 0.3}}
                  />
                )
                ->React.array}
              </AnimatePresence>
            </div>
          </>
        }}
      </div>
    </>}
    onSubmit={() => submitGuess()->Promise.done}>
    <div className="grid grid-cols-4 gap-1.5 sm:gap-2.5">
      {solved
      ->Belt.Array.map(({group, title, values}) =>
        <Solution key={`solved-${Group.name(group)}`} group title values />
      )
      ->React.array}
      {unsolved
      ->Belt.Array.map(({id, value}) => {
        let selected = isSelected(id)

        <Card key={Puzzle.cardKey(id)} selected onClick={() => id->(selected ? deselect : select)}>
          {value}
        </Card>
      })
      ->React.array}
    </div>
  </Form>
}
