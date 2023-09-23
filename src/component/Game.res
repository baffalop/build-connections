type gameState = Playing | Solved | Lost

module Solution = {
  @react.component
  let make = (~group, ~title, ~values) => {
    open FramerMotion

    <AnimatePresence>
      <Motion.Div
        className={`card p-6 ${Group.bgColor(group)} col-span-full text-center space-y-1`}
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
    let (buttonRef, {UseHooks.width: buttonWidth}) = UseHooks.useMeasure()
    let (textRef, {UseHooks.width: textWidth}) = UseHooks.useMeasure()
    let (textIntrinsicWidth, setTextIntrinsicWidth) = React.useState((): option<float> => None)

    React.useEffect1(() => {
      switch (textIntrinsicWidth, textWidth->Js.Nullable.toOption) {
      | (None, Some(width)) => setTextIntrinsicWidth(_ => Some(width))
      | _ => ()
      }
      None
    }, [textWidth])

    let scale: float = React.useMemo2(() =>
      switch (textIntrinsicWidth, buttonWidth->Js.Nullable.toOption) {
      | (Some(text), Some(button)) => min(button /. text, 1.0)
      | _ => 1.0
      }
    , (textIntrinsicWidth, buttonWidth))

    open FramerMotion

    <Motion.Button
      ref={buttonRef}
      \"type"="button"
      className={`card py-6 sm:py-8 px-1.5 cursor-pointer flex justify-center items-center text-base !font-semibold
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

  let (toastMessage, setToastMessage) = React.useState((): option<string> => None)
  let showToast = message => setToastMessage(_ => Some(message))
  let clearToast = () => setToastMessage(_ => None)

  let hasSelection = Belt.Array.length(selection) > 0
  let hasFullSelection = Belt.Array.length(selection) >= 4

  let isSelected = id => Belt.Array.some(selection, s => s == id)
  let select = (id: Puzzle.cardId) =>
    if !hasFullSelection {
      setSelection(Utils.Array.append(_, id))
    }
  let deselect = (id: Puzzle.cardId) => setSelection(Belt.Array.keep(_, s => s != id))
  let deselectAll = () => setSelection(_ => [])

  let gameState = switch (lives, unsolved) {
  | (0, _) => Lost
  | (_, []) => Solved
  | _ => Playing
  }

  let shakeSelected = async () => {
    await FramerMotion.animate(".card.selected", {"x": [0, -10, 10, -10, 0]}, {"duration": 0.3})
    await Utils.Time.wait(300)
  }

  let revealSolution = async (group: Group.t) => {
    let solution =
      connections
      ->List.getAssoc(group, Utils.Id.eq)
      ->Option.map(Puzzle.makeSolution(group, _))
      ->Option.getExn

    let waitTime = ref(500)

    // reorder cards first (they will animate)
    setUnsolved(unsolved => {
      let (solved, remaining) = unsolved->Belt.Array.partition(Puzzle.cardInGroup(_, group))
      if remaining == [] {
        // don't bother reordering if they're the only remaining cards
        waitTime.contents = 200
        solved
      } else {
        solved->Utils.Array.sortBy(({id}) => Puzzle.indexFromId(id))->Belt.Array.concat(remaining)
      }
    })

    await Utils.Time.wait(10) // allows waitTime to update
    await Utils.Time.wait(waitTime.contents)
    await FramerMotion.animate(".card.selected", {"scale": 0.9}, {"duration": 0.15})

    setUnsolved(Belt.Array.keep(_, card => !Puzzle.cardInGroup(card, group)))
    setSolved(Utils.Array.append(_, solution))
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
        | NoMatch => await shakeSelected()
        | OneAway(_, _) => {
            showToast("One away...")
            await shakeSelected()
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
      connections
      ->Puzzle.remainingSolutions(solved)
      ->Utils.Array.sequence(async ({group}) => {
        await Utils.Time.wait(500)
        setSelection(
          _ =>
            unsolved->Belt.Array.keepMap(
              card => card->Puzzle.cardInGroup(group) ? Some(card.id) : None,
            ),
        )
        await revealSolution(group)
        deselectAll()
      })
      ->Promise.done
    }
    None
  }, [gameState])

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

  <Form
    title="Custom Connections"
    description={<>
      <p>
        {"Create four groups of four! A custom "->React.string}
        <a target="_blank" href="https://www.nytimes.com/games/connections">
          {"Connections"->React.string}
        </a>
        {" puzzle. "->React.string}
      </p>
      <p>
        <ReactRouter.Link href="/"> {"Build your own"->React.string} </ReactRouter.Link>
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
      <button type_="button" className="action" onClick={_ => copyResults()->Promise.done}>
        {React.string("Copy Results")}
      </button>
    }}
    message={<>
      <Toast message={toastMessage} clear={clearToast} />
      <div className="flex items-center justify-center gap-2 font-medium">
        {switch gameState {
        | Lost => React.string("Game over!")
        | Solved => React.string("Well done!")
        | Playing =>
          <>
            <span className="font-medium"> {React.string("Mistakes remaining:")} </span>
            <div className="flex gap-2 w-20">
              <AnimatePresence>
                {Belt.Array.range(1, lives)
                ->Belt.Array.map(i =>
                  <Motion.Div
                    key={Belt.Int.toString(i)}
                    className="bg-neutral-500 rounded-full w-3 h-3"
                    animate={{"scale": 1}}
                    exit={{"scale": 0}}
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
