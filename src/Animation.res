let shakeSelected = async () => {
  await FramerMotion.animate(".card.selected", {"x": [0, -10, 10, -10, 0]}, {"duration": 0.3})
  await Utils.Time.wait(300)
}

type reveal = {
  revealSolution: Group.t => promise<unit>,
  revealAll: unit => promise<unit>,
}

let useReveal = (
  ~connections: Puzzle.connections,
  ~solved: Puzzle.solved,
  ~unsolved: Puzzle.cards,
  ~setUnsolved: (Puzzle.cards => Puzzle.cards) => unit,
  ~setSolved: (Puzzle.solved => Puzzle.solved) => unit,
  ~setSelection: array<Puzzle.cardId> => unit,
): reveal => {
  let revealSolution = React.useMemo1(() => {
    async (group: Group.t) => {
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
  }, [connections])

  let revealAll = React.useMemo2(() => {
    async () => {
      connections
      ->Puzzle.remainingSolutions(solved)
      ->Utils.Array.sequence(async ({group}) => {
        await Utils.Time.wait(500)
        setSelection(
          unsolved->Belt.Array.keepMap(
            card => card->Puzzle.cardInGroup(group) ? Some(card.id) : None,
          ),
        )
        await revealSolution(group)
        setSelection([])
      })
      ->Promise.done
    }
  }, (connections, solved))

  {revealSolution, revealAll}
}
