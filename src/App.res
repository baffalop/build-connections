type step =
  | Create
  | Game(Puzzle.cards)

@react.component
let make = () => {
  let (step, setStep) = React.useState(() => Create)

  switch step {
  | Create => <CreateForm onCreate={cards => setStep(_ => Game(cards))} />
  | Game(cards) => <Game cards />
  }
}
