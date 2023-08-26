type step =
  | Create
  | Game(Puzzle.cards)

@react.component
let make = () => {
  let (step, setStep) = React.useState(() => Create)

  <div className="p-3 w-screen max-w-screen-sm">
    {switch step {
    | Create => <Create onCreate={cards => setStep(_ => Game(cards))} />
    | Game(cards) => <Game cards />
    }}
  </div>
}
